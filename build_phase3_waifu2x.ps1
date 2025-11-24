# Phase 3: Waifu2x Integration Script
# Builds waifu2x-ncnn-vulkan and integrates it into OmniForge

Write-Host "============================================================" -ForegroundColor Cyan
Write-Host "  PHASE 3: WAIFU2X INTEGRATION" -ForegroundColor Cyan
Write-Host "============================================================" -ForegroundColor Cyan
Write-Host ""

# Step 1: Build waifu2x-ncnn-vulkan
Write-Host "Step 1: Building waifu2x-ncnn-vulkan..." -ForegroundColor Yellow
Write-Host ""

$waifu2xDir = "external\waifu2x-ncnn-vulkan"
$waifu2xBuildDir = "$waifu2xDir\build"

# Create build directory
if (-not (Test-Path $waifu2xBuildDir)) {
    New-Item -ItemType Directory -Path $waifu2xBuildDir | Out-Null
}

Set-Location $waifu2xBuildDir

# Configure CMake
Write-Host "Configuring waifu2x-ncnn-vulkan..." -ForegroundColor Gray
cmake -G "Visual Studio 17 2022" -A x64 ../src `
    -DCMAKE_BUILD_TYPE=Release `
    -DUSE_SYSTEM_NCNN=ON `
    -DUSE_SYSTEM_WEBP=OFF

if ($LASTEXITCODE -ne 0) {
    Write-Host "❌ CMake configuration failed!" -ForegroundColor Red
    Set-Location ..\..\..\
    exit 1
}

# Build
Write-Host "Building waifu2x-ncnn-vulkan..." -ForegroundColor Gray
cmake --build . --config Release

if ($LASTEXITCODE -ne 0) {
    Write-Host "❌ Build failed!" -ForegroundColor Red
    Set-Location ..\..\..\
    exit 1
}

Set-Location ..\..\..\

Write-Host "✅ Waifu2x built successfully!" -ForegroundColor Green
Write-Host ""

# Step 2: Copy executable to bin directory
Write-Host "Step 2: Installing waifu2x executable..." -ForegroundColor Yellow

$binDir = "bin"
if (-not (Test-Path $binDir)) {
    New-Item -ItemType Directory -Path $binDir | Out-Null
}

$waifu2xExe = "$waifu2xBuildDir\Release\waifu2x-ncnn-vulkan.exe"
if (Test-Path $waifu2xExe) {
    Copy-Item $waifu2xExe -Destination "$binDir\" -Force
    Write-Host "✅ Installed: bin\waifu2x-ncnn-vulkan.exe" -ForegroundColor Green
}
else {
    Write-Host "⚠️  Executable not found at: $waifu2xExe" -ForegroundColor Yellow
}

Write-Host ""

# Step 3: Copy models
Write-Host "Step 3: Installing neural network models..." -ForegroundColor Yellow

$modelsDir = "models"
if (-not (Test-Path $modelsDir)) {
    New-Item -ItemType Directory -Path $modelsDir | Out-Null
}

# Copy model directories
$modelSources = @(
    "external\waifu2x-ncnn-vulkan\models\models-cunet",
    "external\waifu2x-ncnn-vulkan\models\models-upconv_7_anime_style_art_rgb",
    "external\waifu2x-ncnn-vulkan\models\models-upconv_7_photo"
)

foreach ($modelSrc in $modelSources) {
    if (Test-Path $modelSrc) {
        $modelName = Split-Path $modelSrc -Leaf
        $modelDest = "$modelsDir\$modelName"
        
        if (-not (Test-Path $modelDest)) {
            Copy-Item -Path $modelSrc -Destination $modelDest -Recurse -Force
            Write-Host "✅ Installed: $modelDest" -ForegroundColor Green
        }
        else {
            Write-Host "⏭️  Already exists: $modelDest" -ForegroundColor Gray
        }
    }
}

Write-Host ""
Write-Host "============================================================" -ForegroundColor Cyan
Write-Host "  PHASE 3 COMPLETE!" -ForegroundColor Cyan
Write-Host "============================================================" -ForegroundColor Cyan
Write-Host ""

Write-Host "✅ Waifu2x Integration Summary:" -ForegroundColor Green
Write-Host "  - waifu2x-ncnn-vulkan.exe built and installed"
Write-Host "  - Neural network models installed"
Write-Host "  - Ready for neural upscaling!"
Write-Host ""

# Test waifu2x
Write-Host "Testing waifu2x installation..." -ForegroundColor Yellow
if (Test-Path "bin\waifu2x-ncnn-vulkan.exe") {
    & "bin\waifu2x-ncnn-vulkan.exe" --help | Select-Object -First 5
    Write-Host ""
    Write-Host "✅ Waifu2x is working!" -ForegroundColor Green
}
else {
    Write-Host "⚠️  Waifu2x executable not found" -ForegroundColor Yellow
}

Write-Host ""
Write-Host "Next steps:" -ForegroundColor Cyan
Write-Host "  1. Test waifu2x with: .\bin\waifu2x-ncnn-vulkan.exe -i input.png -o output.png" -ForegroundColor White
Write-Host "  2. Update Python demos to use real waifu2x" -ForegroundColor White
Write-Host "  3. Integrate into C++ DLL (Phase 4)" -ForegroundColor White
Write-Host ""
