@echo off
echo ============================================================
echo   OMNIFORGE PRODUCTION BUILD
echo ============================================================
echo.

REM Check if build directory exists
if exist build (
    echo Build directory exists
) else (
    echo Creating build directory...
    mkdir build
)

cd build

echo.
echo ============================================================
echo   PHASE 1: CMAKE CONFIGURATION
echo ============================================================
echo.

cmake -G "Ninja" .. -DCMAKE_BUILD_TYPE=Release -DUSE_FSR3=ON -DUSE_NCNN=ON -DUSE_MINHOOK=ON -DBUILD_TESTS=ON

if %ERRORLEVEL% NEQ 0 (
    echo CMake configuration failed!
    cd ..
    exit /b 1
)

echo.
echo ============================================================
echo   PHASE 2: BUILD COMPILATION
echo ============================================================
echo.

cmake --build . --config Release --parallel

if %ERRORLEVEL% NEQ 0 (
    echo Build failed!
    cd ..
    exit /b 1
)

cd ..

echo.
echo ============================================================
echo   BUILD COMPLETE!
echo ============================================================
echo.

if exist "build\src\Release\omniforge_inject.dll" (
    echo [OK] omniforge_inject.dll
) else (
    echo [FAIL] omniforge_inject.dll not found
)

if exist "build\src\Release\omniforge_app.exe" (
    echo [OK] omniforge_app.exe
) else (
    echo [FAIL] omniforge_app.exe not found
)

echo.
echo Build directory: %CD%\build
echo.
