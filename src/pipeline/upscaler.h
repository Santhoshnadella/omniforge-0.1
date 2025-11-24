#pragma once
#include "hybrid_mode.h"

// Forward declaration for Vulkan handles if not already included
// But usually we include vulkan.h before this if needed, or use void*
// For simplicity in the header, we can use void* for the image handle
// or include vulkan if OMNIFORGE_HAVE_VULKAN is defined.

void processFrame(void *inputImage, int width, int height, UpscaleMode mode);
