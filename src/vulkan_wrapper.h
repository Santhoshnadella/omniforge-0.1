// Vulkan wrapper to exclude problematic video codec headers
#ifndef OMNIFORGE_VULKAN_WRAPPER_H
#define OMNIFORGE_VULKAN_WRAPPER_H

// Disable video codec extensions that require missing headers
#define VK_ENABLE_BETA_EXTENSIONS 0
#define VK_NO_PROTOTYPES

// Include main Vulkan header
#include <vulkan/vulkan_core.h>

// Platform-specific
#ifdef _WIN32
#include <vulkan/vulkan_win32.h>
#endif

#endif // OMNIFORGE_VULKAN_WRAPPER_H
