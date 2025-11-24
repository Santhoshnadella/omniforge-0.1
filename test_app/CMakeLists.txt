cmake_minimum_required(VERSION 3.16)
project(VulkanTestApp LANGUAGES CXX)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

# Find Vulkan
find_package(Vulkan REQUIRED)

# Find GLFW for windowing
find_package(glfw3 QUIET)

if(NOT glfw3_FOUND)
    message(STATUS "GLFW not found, will download it")
    include(FetchContent)
    FetchContent_Declare(
        glfw
        GIT_REPOSITORY https://github.com/glfw/glfw.git
        GIT_TAG 3.3.8
    )
    set(GLFW_BUILD_DOCS OFF CACHE BOOL "" FORCE)
    set(GLFW_BUILD_TESTS OFF CACHE BOOL "" FORCE)
    set(GLFW_BUILD_EXAMPLES OFF CACHE BOOL "" FORCE)
    FetchContent_MakeAvailable(glfw)
endif()

add_executable(vulkan_test_app
    vulkan_test_app.cpp
)

target_link_libraries(vulkan_test_app PRIVATE
    Vulkan::Vulkan
    glfw
)

target_compile_definitions(vulkan_test_app PRIVATE
    VK_USE_PLATFORM_WIN32_KHR
)
