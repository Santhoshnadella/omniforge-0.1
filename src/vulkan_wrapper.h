// Vulkan wrapper to exclude problematic video codec headers
#ifndef OMNIFORGE_VULKAN_WRAPPER_H
#define OMNIFORGE_VULKAN_WRAPPER_H

// Define this BEFORE including vulkan headers to exclude video extensions
#define VK_NO_STDINT_H
#define VULKAN_HPP_NO_EXCEPTIONS

// Windows platform
#ifdef _WIN32
#define VK_USE_PLATFORM_WIN32_KHR
#include <windows.h>
#endif

// Include only core Vulkan without video extensions
#define VK_VERSION_1_0 1
#define VK_VERSION_1_1 1
#define VK_VERSION_1_2 1

// Basic Vulkan types we need
typedef uint32_t VkFlags;
typedef uint64_t VkDeviceSize;
typedef void *VkInstance;
typedef void *VkPhysicalDevice;
typedef void *VkDevice;
typedef void *VkQueue;
typedef void *VkCommandBuffer;
typedef void *VkImage;
typedef void *VkSwapchainKHR;

// Vulkan result codes
typedef enum VkResult {
  VK_SUCCESS = 0,
  VK_ERROR_INITIALIZATION_FAILED = -3,
} VkResult;

// Extent structure
typedef struct VkExtent2D {
  uint32_t width;
  uint32_t height;
} VkExtent2D;

// Present info structure
typedef struct VkPresentInfoKHR {
  uint32_t swapchainCount;
  const VkSwapchainKHR *pSwapchains;
  const uint32_t *pImageIndices;
} VkPresentInfoKHR;

// Swapchain create info structure
typedef struct VkSwapchainCreateInfoKHR {
  VkExtent2D imageExtent;
} VkSwapchainCreateInfoKHR;

// Allocation callbacks
typedef struct VkAllocationCallbacks {
  void *pUserData;
} VkAllocationCallbacks;

// Calling convention
#define VKAPI_PTR

#endif // OMNIFORGE_VULKAN_WRAPPER_H
