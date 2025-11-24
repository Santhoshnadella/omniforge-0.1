# Omniforge

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

Real-time game upscaling framework using Vulkan/DXGI capture, AMD FSR3, and neural upscaling (Waifu2x/ncnn). Inject into games to render at lower resolution and upscale with hybrid AI+FSR pipeline. Qt6 GUI with live metrics dashboard. Boost FPS while maintaining visual quality.

## Features
- 🎮 **Game Injection**: Hook Vulkan/DXGI frame presents
- 🚀 **Hybrid Upscaling**: AMD FSR3 + Neural models (Waifu2x/ncnn-vulkan)
- 📊 **Live Dashboard**: Real-time metrics overlay with FPS graphs
- ⚡ **Low Latency**: Async pipeline for minimal overhead
- 🎯 **Qt6 GUI**: Easy injection and monitoring interface

Prerequisites
- Qt6 (Widgets, Charts)
- Vulkan SDK
- CMake >= 3.16
- A C++ compiler (MSVC or clang/clang-cl)

Quick build (Windows PowerShell):
```powershell
mkdir build; cd build
cmake -G "Ninja" .. -DBUILD_TESTS=ON -DENABLE_DLSS=OFF
cmake --build . --config Release
```

Notes
- External dependencies (FSR3, MinHook, ncnn-vulkan) are added as placeholders in `external/` and controlled by CMake options. Add them as git submodules and enable the options to build.
- This scaffold intentionally keeps external deps optional so CMake configure can run on systems without them.

Next steps
1. Implement `src/capture/vulkan_capture.cpp` (hook vkQueuePresentKHR and extract VkImage).
2. Implement FSR compute dispatch in `src/pipeline/upscaler.cpp` and integrate ncnn-vulkan.
3. Flesh out the injection DLL (`src/injector/dllmain.cpp`) using MinHook.
4. Add models to `models/` and tune quantized inference.
