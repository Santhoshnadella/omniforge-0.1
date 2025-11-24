// upscaler.cpp
// Stubs for FSR compute dispatch and neural chain (ncnn-vulkan) integration.

#include "hybrid_mode.h"
#include <cmath>
#include <cstdint>
#include <iostream>
#include <vector>


#ifdef OMNIFORGE_HAVE_VULKAN
#include <vulkan/vulkan.h>
#endif

#define A_CPU 1
// Use relative paths to ensure they are found even if include path is wonky
#include "../../external/FidelityFX-FSR/ffx-fsr/ffx_a.h"
#include "../../external/FidelityFX-FSR/ffx-fsr/ffx_fsr1.h"

// Forward declarations
bool runNcnnInference(void *input, void *output, int width, int height);

struct FsrConstants {
  uint32_t easu[4][4];
  uint32_t rcas[4][4];
};

void setupFSR(FsrConstants &consts, int inputWidth, int inputHeight,
              int outputWidth, int outputHeight) {
  // EASU setup
  // FsrEasuCon expects AU1* (uint32_t*)
  FsrEasuCon(reinterpret_cast<AU1 *>(consts.easu[0]),
             reinterpret_cast<AU1 *>(consts.easu[1]),
             reinterpret_cast<AU1 *>(consts.easu[2]),
             reinterpret_cast<AU1 *>(consts.easu[3]),
             static_cast<AF1>(inputWidth),
             static_cast<AF1>(inputHeight), // Viewport size
             static_cast<AF1>(inputWidth),
             static_cast<AF1>(inputHeight), // Input image size
             static_cast<AF1>(outputWidth),
             static_cast<AF1>(outputHeight) // Output size
  );

  // RCAS setup (sharpness 0.2 default)
  const float sharpness = 0.2f;
  FsrRcasCon(reinterpret_cast<AU1 *>(consts.rcas[0]), sharpness);
}

void processFrame(void *inputImage, int width, int height, UpscaleMode mode) {
  // std::cerr << "upscaler: processFrame called (" << width << "x" << height <<
  // ")" << std::endl;

  // Calculate output dimensions (assuming 2x upscale for this example)
  int outWidth = width * 2;
  int outHeight = height * 2;

  // UpscaleMode::HYBRID = 2
  if (mode == UpscaleMode::FSR_ONLY || mode == static_cast<UpscaleMode>(2)) {
    FsrConstants fsrConsts;
    setupFSR(fsrConsts, width, height, outWidth, outHeight);

    // In a real implementation:
    // 1. Update Uniform Buffer with fsrConsts
    // 2. Bind FSR pipeline
    // 3. Dispatch Compute Shader
    // vkCmdDispatch(cmdBuffer, (outWidth + 15)/16, (outHeight + 15)/16, 1);
    // std::cout << "FSR Constants generated. Dispatching FSR..." << std::endl;
  }

  if (mode == UpscaleMode::NEURAL_ONLY || mode == static_cast<UpscaleMode>(2)) {
    // Call ncnn-vulkan inference path
    // For hybrid, input might be the output of FSR (if doing RCAS -> Neural, or
    // Neural -> RCAS) Here we assume parallel or sequential based on mode.
    runNcnnInference(inputImage, nullptr, width, height);
  }
}
