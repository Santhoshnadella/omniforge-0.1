cmake_minimum_required(VERSION 3.16)

project(omniforge_tests)

add_executable(omniforge_tests test_capture_stub.cpp)
target_include_directories(omniforge_tests PRIVATE ${CMAKE_SOURCE_DIR}/src)

if(BUILD_TESTS)
  enable_testing()
  add_test(NAME capture_stub COMMAND omniforge_tests)
endif()
