cmake_minimum_required(VERSION 3.16)
project(Omniforge LANGUAGES CXX)

option(ENABLE_DLSS "Enable proprietary NVIDIA DLSS (requires SDK)" OFF)
option(ENABLE_ANDROID "Enable Android targets" OFF)
option(BUILD_TESTS "Build tests" ON)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

# Find Qt6 Widgets and Charts if available
find_package(Qt6 COMPONENTS Widgets Charts QUIET)

# Find Vulkan SDK if installed
find_package(Vulkan QUIET)

message(STATUS "Qt6 found: ${Qt6_FOUND}")
message(STATUS "Vulkan found: ${Vulkan_FOUND}")

# External submodules (placeholders)
option(USE_FSR3 "Enable FidelityFX FSR3 integration" OFF)
option(USE_MINHOOK "Enable MinHook" OFF)
option(USE_NCNN "Enable ncnn-vulkan" ON)

add_subdirectory(src)
if(BUILD_TESTS)
  add_subdirectory(tests)
endif()

# If external directories exist, include them as subdirectories (optional)
# If external directories exist, include them as subdirectories (optional)
if(EXISTS "${CMAKE_SOURCE_DIR}/external/FSR3/CMakeLists.txt")
  add_subdirectory(external/FSR3)
endif()
if(EXISTS "${CMAKE_SOURCE_DIR}/external/minhook/CMakeLists.txt")
  add_subdirectory(external/minhook)
endif()

if(USE_NCNN)
  set(NCNN_VULKAN ON CACHE BOOL "Enable NCNN Vulkan" FORCE)
  set(NCNN_SHARED_LIB OFF CACHE BOOL "Build NCNN as static lib" FORCE)
  set(NCNN_BUILD_TOOLS OFF CACHE BOOL "Build NCNN tools" FORCE)
  set(NCNN_BUILD_EXAMPLES OFF CACHE BOOL "Build NCNN examples" FORCE)
  set(NCNN_BUILD_BENCHMARK OFF CACHE BOOL "Build NCNN benchmark" FORCE)
  if(EXISTS "${CMAKE_SOURCE_DIR}/external/ncnn/CMakeLists.txt")
    add_subdirectory(external/ncnn)
  endif()
endif()

install(TARGETS omniforge_app RUNTIME DESTINATION bin)
