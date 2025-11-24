// vulkan_capture.cpp
// Capture stubs for Vulkan-based frame interception.

#include <iostream>
#include <mutex>
#include <unordered_map>
#include <vector>


#include "../pipeline/upscaler.h"
#include <MinHook.h>

#ifdef OMNIFORGE_HAVE_VULKAN
#include <vulkan/vulkan.h>

// Global state tracking
struct SwapchainData {
  VkExtent2D extent;
  std::vector<VkImage> images;
};

static std::unordered_map<VkSwapchainKHR, SwapchainData> g_swapchains;
static std::mutex g_captureMutex;

// Original function pointers
typedef VkResult(VKAPI_PTR *PFN_vkQueuePresentKHR)(VkQueue,
                                                   const VkPresentInfoKHR *);
typedef VkResult(VKAPI_PTR *PFN_vkCreateSwapchainKHR)(
    VkDevice, const VkSwapchainCreateInfoKHR *, const VkAllocationCallbacks *,
    VkSwapchainKHR *);
typedef VkResult(VKAPI_PTR *PFN_vkGetSwapchainImagesKHR)(VkDevice,
                                                         VkSwapchainKHR,
                                                         uint32_t *, VkImage *);

PFN_vkQueuePresentKHR Original_vkQueuePresentKHR = nullptr;
PFN_vkCreateSwapchainKHR Original_vkCreateSwapchainKHR = nullptr;
PFN_vkGetSwapchainImagesKHR Original_vkGetSwapchainImagesKHR = nullptr;

// Detours

VkResult VKAPI_PTR Detour_vkCreateSwapchainKHR(
    VkDevice device, const VkSwapchainCreateInfoKHR *pCreateInfo,
    const VkAllocationCallbacks *pAllocator, VkSwapchainKHR *pSwapchain) {
  VkResult result = Original_vkCreateSwapchainKHR(device, pCreateInfo,
                                                  pAllocator, pSwapchain);

  if (result == VK_SUCCESS && pSwapchain && pCreateInfo) {
    std::lock_guard<std::mutex> lock(g_captureMutex);
    g_swapchains[*pSwapchain].extent = pCreateInfo->imageExtent;
    std::cerr << "Captured Swapchain: " << pCreateInfo->imageExtent.width << "x"
              << pCreateInfo->imageExtent.height << std::endl;
  }
  return result;
}

VkResult VKAPI_PTR Detour_vkGetSwapchainImagesKHR(
    VkDevice device, VkSwapchainKHR swapchain, uint32_t *pSwapchainImageCount,
    VkImage *pSwapchainImages) {
  VkResult result = Original_vkGetSwapchainImagesKHR(
      device, swapchain, pSwapchainImageCount, pSwapchainImages);

  if (result == VK_SUCCESS && pSwapchainImages != nullptr) {
    std::lock_guard<std::mutex> lock(g_captureMutex);
    if (g_swapchains.find(swapchain) != g_swapchains.end()) {
      std::vector<VkImage> images(pSwapchainImages,
                                  pSwapchainImages + *pSwapchainImageCount);
      g_swapchains[swapchain].images = images;
      std::cerr << "Captured " << *pSwapchainImageCount << " swapchain images."
                << std::endl;
    }
  }
  return result;
}

VkResult VKAPI_PTR
Detour_vkQueuePresentKHR(VkQueue queue, const VkPresentInfoKHR *pPresentInfo) {
  if (pPresentInfo) {
    std::lock_guard<std::mutex> lock(g_captureMutex);
    for (uint32_t i = 0; i < pPresentInfo->swapchainCount; ++i) {
      VkSwapchainKHR swapchain = pPresentInfo->pSwapchains[i];
      uint32_t imageIndex = pPresentInfo->pImageIndices[i];

      if (g_swapchains.find(swapchain) != g_swapchains.end()) {
        SwapchainData &data = g_swapchains[swapchain];
        if (imageIndex < data.images.size()) {
          VkImage image = data.images[imageIndex];
          // Call the upscaler!
          // For now, hardcode HYBRID mode
          processFrame((void *)image, data.extent.width, data.extent.height,
                       UpscaleMode::HYBRID);
        }
      }
    }
  }

  if (Original_vkQueuePresentKHR) {
    return Original_vkQueuePresentKHR(queue, pPresentInfo);
  }
  return VK_ERROR_INITIALIZATION_FAILED;
}
#endif

extern "C" {
bool initializeCapture() {
#ifdef OMNIFORGE_HAVE_VULKAN
  std::cerr << "vulkan_capture: Initializing MinHook..." << std::endl;

  // We assume the game has loaded vulkan-1.dll.
  // In a robust injector, we might need to wait for the module or hook
  // GetProcAddress.
  HMODULE hVulkan = GetModuleHandleA("vulkan-1.dll");
  if (!hVulkan) {
    hVulkan = LoadLibraryA("vulkan-1.dll");
  }

  if (!hVulkan) {
    std::cerr << "vulkan_capture: Failed to get vulkan-1.dll handle."
              << std::endl;
    return false;
  }

  void *pPresent = (void *)GetProcAddress(hVulkan, "vkQueuePresentKHR");
  void *pCreateSwapchain =
      (void *)GetProcAddress(hVulkan, "vkCreateSwapchainKHR");
  void *pGetSwapchainImages =
      (void *)GetProcAddress(hVulkan, "vkGetSwapchainImagesKHR");

  if (pPresent) {
    MH_CreateHook(pPresent, (void *)&Detour_vkQueuePresentKHR,
                  (void **)&Original_vkQueuePresentKHR);
    MH_EnableHook(pPresent);
    std::cerr << "vulkan_capture: Hooked vkQueuePresentKHR" << std::endl;
  }

  if (pCreateSwapchain) {
    MH_CreateHook(pCreateSwapchain, (void *)&Detour_vkCreateSwapchainKHR,
                  (void **)&Original_vkCreateSwapchainKHR);
    MH_EnableHook(pCreateSwapchain);
    std::cerr << "vulkan_capture: Hooked vkCreateSwapchainKHR" << std::endl;
  }

  if (pGetSwapchainImages) {
    MH_CreateHook(pGetSwapchainImages, (void *)&Detour_vkGetSwapchainImagesKHR,
                  (void **)&Original_vkGetSwapchainImagesKHR);
    MH_EnableHook(pGetSwapchainImages);
    std::cerr << "vulkan_capture: Hooked vkGetSwapchainImagesKHR" << std::endl;
  }

  return true;
#else
  std::cerr << "vulkan_capture: Vulkan not available." << std::endl;
  return false;
#endif
}

void shutdownCapture() {
  std::cerr << "vulkan_capture: shutdownCapture() called." << std::endl;
  MH_DisableHook(MH_ALL_HOOKS);
}
}
