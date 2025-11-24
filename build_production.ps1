# OmniForge Production Build Script
# This script builds all components needed for production deployment

param(
    [switch]$Clean = $false,
    [switch]$SkipTests = $false,
    [string]$BuildType = "Release"
)

$ErrorActionPreference = "Stop"

Write-Host "============================================================" -ForegroundColor Cyan
Write-Host "  OMNIFORGE PRODUCTION BUILD" -ForegroundColor Cyan
Write-Host "============================================================" -ForegroundColor Cyan
Write-Host ""

# Check prerequisites
Write-Host "Checking prerequisites..." -ForegroundColor Yellow

# Check CMake
try {
    $cmakeVersion = cmake --version | Select-Object -First 1
    Write-Host "✅ CMake found: $cmakeVersion" -ForegroundColor Green
}
catch {
    Write-Host "❌ CMake not found! Please install CMake 3.16+" -ForegroundColor Red
    exit 1
}

# Check Vulkan SDK
if ($env:VULKAN_SDK) {
    Write-Host "✅ Vulkan SDK found: $env:VULKAN_SDK" -ForegroundColor Green
}
else {
    Write-Host "⚠️  Vulkan SDK not found in environment" -ForegroundColor Yellow
    Write-Host "   Attempting to find Vulkan..." -ForegroundColor Yellow
}

# Check Qt6
$qt6Path = $null
$possibleQt6Paths = @(
    "C:\Qt\6.5.0\msvc2019_64",
    "C:\Qt\6.6.0\msvc2019_64",
    "C:\Qt\6.7.0\msvc2019_64",
    "$env:USERPROFILE\Qt\6.5.0\msvc2019_64"
)

foreach ($path in $possibleQt6Paths) {
    if (Test-Path $path) {
        $qt6Path = $path
        Write-Host "✅ Qt6 found: $qt6Path" -ForegroundColor Green
        break
    }
}

if (-not $qt6Path) {
    Write-Host "⚠️  Qt6 not found automatically" -ForegroundColor Yellow
    Write-Host "   GUI will be disabled unless Qt6 is in PATH" -ForegroundColor Yellow
}

Write-Host ""

# Clean build directory if requested
if ($Clean -and (Test-Path "build")) {
    Write-Host "🧹 Cleaning build directory..." -ForegroundColor Yellow
    Remove-Item -Recurse -Force "build"
    Write-Host "✅ Build directory cleaned" -ForegroundColor Green
}

# Create build directory
if (-not (Test-Path "build")) {
    Write-Host "📁 Creating build directory..." -ForegroundColor Yellow
    New-Item -ItemType Directory -Path "build" | Out-Null
}

Set-Location "build"

Write-Host ""
Write-Host "============================================================" -ForegroundColor Cyan
Write-Host "  PHASE 1: CMAKE CONFIGURATION" -ForegroundColor Cyan
Write-Host "============================================================" -ForegroundColor Cyan
Write-Host ""

# Prepare CMake arguments
$cmakeArgs = @(
    "-G", "Ninja",
    "..",
    "-DCMAKE_BUILD_TYPE=$BuildType",
    "-DUSE_FSR3=ON",
    "-DUSE_NCNN=ON",
    "-DUSE_MINHOOK=ON",
    "-DBUILD_TESTS=ON"
)

# Add Qt6 path if found
if ($qt6Path) {
    $cmakeArgs += "-DCMAKE_PREFIX_PATH=$qt6Path"
}

# Add Vulkan SDK if found
if ($env:VULKAN_SDK) {
    $cmakeArgs += "-DVULKAN_SDK=$env:VULKAN_SDK"
}

Write-Host "Running CMake configuration..." -ForegroundColor Yellow
Write-Host "Command: cmake $($cmakeArgs -join ' ')" -ForegroundColor Gray
Write-Host ""

try {
    & cmake @cmakeArgs
    if ($LASTEXITCODE -ne 0) {
        throw "CMake configuration failed"
    }
    Write-Host ""
    Write-Host "✅ CMake configuration successful" -ForegroundColor Green
}
catch {
    Write-Host "❌ CMake configuration failed: $_" -ForegroundColor Red
    Set-Location ..
    exit 1
}

Write-Host ""
Write-Host "============================================================" -ForegroundColor Cyan
Write-Host "  PHASE 2: BUILD COMPILATION" -ForegroundColor Cyan
Write-Host "============================================================" -ForegroundColor Cyan
Write-Host ""

Write-Host "Building OmniForge components..." -ForegroundColor Yellow
Write-Host ""

try {
    cmake --build . --config $BuildType --parallel
    if ($LASTEXITCODE -ne 0) {
        throw "Build failed"
    }
    Write-Host ""
    Write-Host "✅ Build successful" -ForegroundColor Green
}
catch {
    Write-Host "❌ Build failed: $_" -ForegroundColor Red
    Set-Location ..
    exit 1
}

Write-Host ""
Write-Host "============================================================" -ForegroundColor Cyan
Write-Host "  PHASE 3: RUNNING TESTS" -ForegroundColor Cyan
Write-Host "============================================================" -ForegroundColor Cyan
Write-Host ""

if (-not $SkipTests) {
    Write-Host "Running tests..." -ForegroundColor Yellow
    Write-Host ""
    
    try {
        ctest -C $BuildType --output-on-failure
        if ($LASTEXITCODE -ne 0) {
            Write-Host "⚠️  Some tests failed" -ForegroundColor Yellow
        }
        else {
            Write-Host "✅ All tests passed" -ForegroundColor Green
        }
    }
    catch {
        Write-Host "⚠️  Test execution failed: $_" -ForegroundColor Yellow
    }
}
else {
    Write-Host "⏭️  Tests skipped (use without -SkipTests to run)" -ForegroundColor Gray
}

Set-Location ..

Write-Host ""
Write-Host "============================================================" -ForegroundColor Cyan
Write-Host "  BUILD SUMMARY" -ForegroundColor Cyan
Write-Host "============================================================" -ForegroundColor Cyan
Write-Host ""

# Check what was built
$builtFiles = @()

if (Test-Path "build\src\$BuildType\omniforge_inject.dll") {
    $builtFiles += "✅ omniforge_inject.dll (Injection DLL)"
}
elseif (Test-Path "build\src\omniforge_inject.dll") {
    $builtFiles += "✅ omniforge_inject.dll (Injection DLL)"
}
else {
    $builtFiles += "❌ omniforge_inject.dll (NOT FOUND)"
}

if (Test-Path "build\src\$BuildType\omniforge_app.exe") {
    $builtFiles += "✅ omniforge_app.exe (GUI Application)"
}
elseif (Test-Path "build\src\omniforge_app.exe") {
    $builtFiles += "✅ omniforge_app.exe (GUI Application)"
}
else {
    $builtFiles += "❌ omniforge_app.exe (NOT FOUND)"
}

foreach ($file in $builtFiles) {
    Write-Host "  $file"
}

Write-Host ""
Write-Host "Build directory: $(Resolve-Path 'build')" -ForegroundColor Gray
Write-Host ""

if ($builtFiles -match "❌") {
    Write-Host "⚠️  Some components failed to build" -ForegroundColor Yellow
    Write-Host "   Check the build log above for errors" -ForegroundColor Yellow
    exit 1
}
else {
    Write-Host "🎉 BUILD COMPLETE!" -ForegroundColor Green
    Write-Host ""
    Write-Host "Next steps:" -ForegroundColor Cyan
    Write-Host "  1. Test the GUI: .\build\src\$BuildType\omniforge_app.exe" -ForegroundColor White
    Write-Host "  2. Test injection: Use GUI to inject into a game" -ForegroundColor White
    Write-Host "  3. Check logs for any runtime errors" -ForegroundColor White
}

Write-Host ""
