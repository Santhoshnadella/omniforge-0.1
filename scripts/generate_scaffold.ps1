<#
PowerShell Scaffold Generator for Omniforge

Run this in the directory where you want the project (e.g., K:\omniforge):
    powershell -ExecutionPolicy Bypass -File .\scripts\generate_scaffold.ps1

This script will create the directory tree and write starter files.
#>

$files = @{
    "CMakeLists.txt" = @'
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
option(USE_NCNN "Enable ncnn-vulkan" OFF)

add_subdirectory(src)
if(BUILD_TESTS)
  add_subdirectory(tests)
endif()

# If external directories exist, include them as subdirectories (optional)
if(EXISTS "${CMAKE_SOURCE_DIR}/external/FSR3/CMakeLists.txt")
  add_subdirectory(external/FSR3)
endif()
if(EXISTS "${CMAKE_SOURCE_DIR}/external/minhook/CMakeLists.txt")
  add_subdirectory(external/minhook)
endif()

install(TARGETS omniforge_app RUNTIME DESTINATION bin)
'@

    ".gitignore" = @'
# Build
/build/
/CMakeFiles/
/CMakeCache.txt
/cmake_install.cmake
/Makefile

# Visual Studio
*.vcxproj*
*.sln
*.suo

# Qt Creator
*.pro.user*

# Qt Build
moc_*.cpp
qrc_*.cpp
ui_*.h

# Binaries
*.exe
*.dll
*.lib
*.pdb

# Models and large assets
/models/
'@

    "README.md" = @'
# Omniforge

Omniforge is a C++/Qt6/Vulkan-based real-time game upscaling framework scaffolded from a Waifu2x-Extension-GUI fork. This workspace contains a project skeleton (CMake) with placeholders for Vulkan capture, FSR3, ncnn-vulkan neural inference, and a Qt GUI.

Prerequisites:
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

Next steps:
1. Implement `src/capture/vulkan_capture.cpp` (hook vkQueuePresentKHR and extract VkImage).
2. Implement FSR compute dispatch in `src/pipeline/upscaler.cpp` and integrate ncnn-vulkan.
3. Flesh out the injection DLL (`src/injector/dllmain.cpp`) using MinHook.
'@

    "LICENSE" = @'
MIT License

Copyright (c) 2025 Omniforge

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
'@

    "src/CMakeLists.txt" = @'
cmake_minimum_required(VERSION 3.16)

project(omniforge_app LANGUAGES CXX)

set(SRC_FILES
  main.cpp
  gui/MainWindow.cpp
  capture/vulkan_capture.cpp
  capture/dxgi_capture.cpp
  pipeline/upscaler.cpp
  pipeline/hybrid_mode.h
  injector/dllmain.cpp
  utils/metrics.cpp
  engines/ncnn_stub.cpp
)

add_executable(omniforge_app ${SRC_FILES})

target_include_directories(omniforge_app PRIVATE ${CMAKE_CURRENT_SOURCE_DIR})

find_package(Qt6 COMPONENTS Widgets Charts QUIET)
if(Qt6_FOUND)
  target_link_libraries(omniforge_app PRIVATE Qt6::Widgets Qt6::Charts)
  target_compile_definitions(omniforge_app PRIVATE OMNIFORGE_HAVE_QT)
else()
  message(WARNING "Qt6 not found. GUI will not be enabled until Qt6 is available.")
endif()

find_package(Vulkan QUIET)
if(Vulkan_FOUND)
  target_compile_definitions(omniforge_app PRIVATE OMNIFORGE_HAVE_VULKAN)
  target_include_directories(omniforge_app PRIVATE ${Vulkan_INCLUDE_DIRS})
  target_link_libraries(omniforge_app PRIVATE ${Vulkan_LIBRARIES})
else()
  message(WARNING "Vulkan SDK not found. Capture/back-end will be stubbed.")
endif()

target_compile_features(omniforge_app PRIVATE cxx_std_17)
'@

    "src/main.cpp" = @'
#include <iostream>
#ifdef OMNIFORGE_HAVE_QT
#include <QApplication>
#include "gui/MainWindow.h"
#endif

int main(int argc, char** argv) {
#ifdef OMNIFORGE_HAVE_QT
    QApplication app(argc, argv);
    MainWindow w;
    w.show();
    return app.exec();
#else
    std::cout << "Omniforge scaffold - Qt not available. Build with Qt6 to run the GUI." << std::endl;
    return 0;
#endif
}
'@

    "src/gui/MainWindow.h" = @'
#pragma once

#ifdef OMNIFORGE_HAVE_QT
#include <QMainWindow>

QT_BEGIN_NAMESPACE
namespace Ui { class MainWindow; }
QT_END_NAMESPACE

class MainWindow : public QMainWindow {
    Q_OBJECT
public:
    explicit MainWindow(QWidget *parent = nullptr);
    ~MainWindow() override;

public slots:
    void onInjectClicked();

signals:
    void injectionRequested(const QString &exePath, const QString &dllPath);

private:
    Ui::MainWindow *ui;
};
#endif
'@

    "src/gui/MainWindow.cpp" = @'
#ifdef OMNIFORGE_HAVE_QT
#include "MainWindow.h"
#include "ui_MainWindow.h"
#include <QFileDialog>
#include <QMessageBox>

MainWindow::MainWindow(QWidget *parent) : QMainWindow(parent), ui(new Ui::MainWindow) {
    ui->setupUi(this);
    if (ui->tabWidget) {
        auto injectBtn = ui->centralWidget->findChild<QPushButton*>("injectButton");
        if (injectBtn) connect(injectBtn, &QPushButton::clicked, this, &MainWindow::onInjectClicked);
    }
}

MainWindow::~MainWindow() {
    delete ui;
}

void MainWindow::onInjectClicked() {
    QString exePath = QFileDialog::getOpenFileName(this, tr("Select Game Executable"));
    if (exePath.isEmpty()) return;
    QString dllPath = "omniforge_inject.dll";
    emit injectionRequested(exePath, dllPath);
    QMessageBox::information(this, tr("Inject"), tr("Injection request sent (stub)."));
}
#endif
'@

    "src/gui/ui/MainWindow.ui" = @'
<?xml version="1.0" encoding="UTF-8"?>
<ui version="4.0">
 <class>MainWindow</class>
 <widget class="QMainWindow" name="MainWindow">
  <property name="geometry">
   <rect>
    <x>0</x>
    <y>0</y>
    <width>800</width>
    <height>600</height>
   </rect>
  </property>
  <widget class="QWidget" name="centralWidget">
   <layout class="QVBoxLayout" name="verticalLayout">
    <item>
     <widget class="QTabWidget" name="tabWidget">
      <widget class="QWidget" name="tabBatch">
       <attribute name="title">
        <string>Batch</string>
       </attribute>
      </widget>
      <widget class="QWidget" name="tabRealtime">
       <attribute name="title">
        <string>Real-Time</string>
       </attribute>
       <widget class="QPushButton" name="injectButton">
        <property name="text">
         <string>Inject</string>
        </property>
       </widget>
      </widget>
     </widget>
    </item>
   </layout>
  </widget>
 </widget>
</ui>
'@

    "src/capture/vulkan_capture.cpp" = @'
// vulkan_capture.cpp - stub
#include <iostream>

extern "C" {
    bool initializeCapture() {
        std::cerr << "vulkan_capture: initializeCapture() stub called" << std::endl;
        return false;
    }

    void shutdownCapture() {
        std::cerr << "vulkan_capture: shutdownCapture() stub called" << std::endl;
    }
}
'

    "src/capture/dxgi_capture.cpp" = @'
// dxgi_capture.cpp - stub
#include <iostream>

extern "C" {
    bool initializeCaptureDXGI() {
        std::cerr << "dxgi_capture: initializeCaptureDXGI() stub called" << std::endl;
        return false;
    }

    void shutdownCaptureDXGI() {
        std::cerr << "dxgi_capture: shutdownCaptureDXGI() stub called" << std::endl;
    }
}
'

    "src/pipeline/hybrid_mode.h" = @'
#pragma once

enum class UpscaleMode { FSR_ONLY = 0, NEURAL_ONLY = 1, HYBRID = 2 };
'

    "src/pipeline/upscaler.cpp" = @'
// upscaler.cpp - stub
#include "hybrid_mode.h"
#include <iostream>

void processFrame(void* inputImage, int width, int height, UpscaleMode mode) {
    std::cerr << "upscaler: processFrame stub called (" << width << "x" << height << ")" << std::endl;
}
'

    "src/injector/dllmain.cpp" = @'
// dllmain.cpp - injector DLL entry and MinHook stubs
#include <windows.h>
#include <iostream>

BOOL WINAPI DllMain(HINSTANCE hinstDLL, DWORD fdwReason, LPVOID lpReserved) {
    switch (fdwReason) {
        case DLL_PROCESS_ATTACH:
            DisableThreadLibraryCalls(hinstDLL);
            std::cerr << "omniforge injector DLL attached (stub)" << std::endl;
            break;
        case DLL_PROCESS_DETACH:
            std::cerr << "omniforge injector DLL detached" << std::endl;
            break;
    }
    return TRUE;
}

extern "C" __declspec(dllexport) bool installHooks() {
    std::cerr << "installHooks() stub called - implement MinHook hooks here" << std::endl;
    return false;
}
'

    "src/utils/metrics.h" = @'
#pragma once

class Metrics {
public:
    Metrics();
    ~Metrics();
    void framePresented();
    double getFPS() const;
private:
    struct Impl;
    Impl* p;
};
'

    "src/utils/metrics.cpp" = @'
// metrics.cpp - simple FPS/latency counters (stub)
#include <chrono>
#include <mutex>
#include "metrics.h"

using namespace std::chrono;

struct Metrics::Impl {
    std::mutex m;
    steady_clock::time_point last = steady_clock::now();
    int frames = 0;
    double fps = 0.0;
};

Metrics::Metrics() : p(new Impl) {}
Metrics::~Metrics() = default;

void Metrics::framePresented() {
    std::lock_guard<std::mutex> lk(p->m);
    ++p->frames;
    auto now = steady_clock::now();
    double dt = duration_cast<duration<double>>(now - p->last).count();
    if (dt >= 1.0) {
        p->fps = p->frames / dt;
        p->frames = 0;
        p->last = now;
    }
}

double Metrics::getFPS() const {
    std::lock_guard<std::mutex> lk(p->m);
    return p->fps;
}
'

    "src/utils/latency_queue.h" = @'
#pragma once
#include <queue>
#include <mutex>
#include <condition_variable>

template<typename T>
class LatencyQueue {
public:
    void push(T item) {
        {
            std::lock_guard<std::mutex> lk(m_);
            q_.push(std::move(item));
        }
        cv_.notify_one();
    }
    T pop() {
        std::unique_lock<std::mutex> lk(m_);
        cv_.wait(lk, [this]{ return !q_.empty(); });
        T v = std::move(q_.front());
        q_.pop();
        return v;
    }
    bool try_pop(T &out) {
        std::lock_guard<std::mutex> lk(m_);
        if (q_.empty()) return false;
        out = std::move(q_.front());
        q_.pop();
        return true;
    }
    size_t size() const {
        std::lock_guard<std::mutex> lk(m_);
        return q_.size();
    }
private:
    mutable std::mutex m_;
    std::condition_variable cv_;
    std::queue<T> q_;
};
'

    "src/engines/ncnn_stub.cpp" = @'
// ncnn_stub.cpp - placeholder for ncnn-vulkan integration
#include <iostream>

bool initNcnnVulkan() {
    std::cerr << "ncnn_stub: initNcnnVulkan() called (stub)" << std::endl;
    return false;
}

bool runNcnnInference(void* input, void* output) {
    std::cerr << "ncnn_stub: runNcnnInference() called (stub)" << std::endl;
    return false;
}
'

    "tests/CMakeLists.txt" = @'
cmake_minimum_required(VERSION 3.16)

project(omniforge_tests)

add_executable(omniforge_tests test_capture_stub.cpp)
target_include_directories(omniforge_tests PRIVATE ${CMAKE_SOURCE_DIR}/src)

if(BUILD_TESTS)
  enable_testing()
  add_test(NAME capture_stub COMMAND omniforge_tests)
endif()
'

    "tests/test_capture_stub.cpp" = @'
#include <iostream>

extern "C" bool initializeCapture();

int main() {
    bool ok = initializeCapture();
    std::cout << "initializeCapture returned: " << ok << std::endl;
    return ok ? 0 : 1;
}
'
}

# Create files
foreach ($relPath in $files.Keys) {
    $content = $files[$relPath]
    $dir = Split-Path -Parent $relPath
    if ($dir -ne "") {
        New-Item -ItemType Directory -Force -Path $dir | Out-Null
    }
    Write-Host "Writing $relPath"
    $content | Out-File -FilePath $relPath -Encoding UTF8 -Force
}

Write-Host "Scaffold generation complete. Run the following to configure and build:"
Write-Host "mkdir build; cd build; cmake -G \"Ninja\" .. -DBUILD_TESTS=ON -DENABLE_DLSS=OFF; cmake --build . --config Release"
