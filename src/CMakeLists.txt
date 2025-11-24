cmake_minimum_required(VERSION 3.16)
project(omniforge_src LANGUAGES CXX)

# --- Injector DLL Target ---
set(INJECT_SRC
  injector/dllmain.cpp
  capture/vulkan_capture.cpp
  capture/dxgi_capture.cpp
  pipeline/upscaler.cpp
  engines/ncnn_stub.cpp
  utils/metrics.cpp
)

add_library(omniforge_inject SHARED ${INJECT_SRC})

target_include_directories(omniforge_inject PRIVATE ${CMAKE_CURRENT_SOURCE_DIR})
target_include_directories(omniforge_inject PRIVATE "${CMAKE_SOURCE_DIR}/external/minhook/include")
target_include_directories(omniforge_inject PRIVATE "${CMAKE_CURRENT_SOURCE_DIR}/pipeline")
target_include_directories(omniforge_inject PRIVATE "${CMAKE_CURRENT_SOURCE_DIR}/injector")

# Link MinHook (Force)
target_link_libraries(omniforge_inject PRIVATE minhook)

# Link Vulkan - TEMPORARILY DISABLED to get first build working
# Will re-enable after fixing header issues
# find_package(Vulkan QUIET)
# if(Vulkan_FOUND)
#   target_compile_definitions(omniforge_inject PRIVATE OMNIFORGE_HAVE_VULKAN)
#   target_include_directories(omniforge_inject PRIVATE ${Vulkan_INCLUDE_DIRS})
#   target_link_libraries(omniforge_inject PRIVATE ${Vulkan_LIBRARIES})
# endif()

# Link DXGI/D3D11 (Windows system libs)
if(WIN32)
    target_link_libraries(omniforge_inject PRIVATE d3d11 dxgi)
endif()

# Link NCNN - TEMPORARILY DISABLED to get first build working  
# Will re-enable after fixing include paths
# if(TARGET ncnn)
#     target_link_libraries(omniforge_inject PRIVATE ncnn)
#     target_compile_definitions(omniforge_inject PRIVATE OMNIFORGE_HAVE_NCNN)
#     target_include_directories(omniforge_inject PRIVATE 
#         "${CMAKE_SOURCE_DIR}/external/ncnn/src"
#         "${CMAKE_BINARY_DIR}/external/ncnn/src"
#         "${CMAKE_SOURCE_DIR}/external/ncnn"
#     )
# endif()

# Unconditionally add FSR include
target_include_directories(omniforge_inject PRIVATE "${CMAKE_SOURCE_DIR}/external/FidelityFX-FSR/ffx-fsr")
target_compile_definitions(omniforge_inject PRIVATE OMNIFORGE_HAVE_FSR)

target_compile_features(omniforge_inject PRIVATE cxx_std_17)


# --- Main GUI App Target ---
set(APP_SRC
  main.cpp
  gui/MainWindow.cpp
  injector/injector_host.cpp
)

add_executable(omniforge_app ${APP_SRC})

target_include_directories(omniforge_app PRIVATE ${CMAKE_CURRENT_SOURCE_DIR})

find_package(Qt6 COMPONENTS Widgets Charts QUIET)
if(Qt6_FOUND)
  target_link_libraries(omniforge_app PRIVATE Qt6::Widgets Qt6::Charts)
  target_compile_definitions(omniforge_app PRIVATE OMNIFORGE_HAVE_QT)
else()
  message(WARNING "Qt6 not found. GUI will not be enabled until Qt6 is available.")
endif()

target_compile_features(omniforge_app PRIVATE cxx_std_17)
