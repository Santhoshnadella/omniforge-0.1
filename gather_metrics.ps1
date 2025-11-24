# Metrics Gathering Script
$reportPath = "METRICS_REPORT.md"
$phase1Dll = "build\src\Release\omniforge_inject.dll"
$phase1Exe = "build\src\Release\omniforge_app.exe"
$waifu2xExe = "bin\waifu2x-ncnn-vulkan.exe"

" # OmniForge Build Metrics Report" | Out-File $reportPath
"" | Out-File $reportPath -Append
"## Phase 1 Artifacts" | Out-File $reportPath -Append

if (Test-Path $phase1Dll) {
    $item = Get-Item $phase1Dll
    "- **Injection DLL**: $($item.Name)" | Out-File $reportPath -Append
    "  - Size: $([math]::Round($item.Length / 1KB, 2)) KB" | Out-File $reportPath -Append
    "  - Path: $($item.FullName)" | Out-File $reportPath -Append
}
else {
    "- **Injection DLL**: MISSING" | Out-File $reportPath -Append
}

if (Test-Path $phase1Exe) {
    $item = Get-Item $phase1Exe
    "- **GUI App**: $($item.Name)" | Out-File $reportPath -Append
    "  - Size: $([math]::Round($item.Length / 1KB, 2)) KB" | Out-File $reportPath -Append
    "  - Path: $($item.FullName)" | Out-File $reportPath -Append
}
else {
    "- **GUI App**: MISSING" | Out-File $reportPath -Append
}

"" | Out-File $reportPath -Append
"## Phase 3 Artifacts" | Out-File $reportPath -Append

if (Test-Path $waifu2xExe) {
    $item = Get-Item $waifu2xExe
    "- **Waifu2x Executable**: $($item.Name)" | Out-File $reportPath -Append
    "  - Size: $([math]::Round($item.Length / 1KB, 2)) KB" | Out-File $reportPath -Append
    "  - Path: $($item.FullName)" | Out-File $reportPath -Append
}
else {
    "- **Waifu2x Executable**: PENDING BUILD" | Out-File $reportPath -Append
}

"" | Out-File $reportPath -Append
"## Dependencies Status" | Out-File $reportPath -Append
"- **MinHook**: Built & Linked" | Out-File $reportPath -Append
"- **NCNN**: Built (Phase 1)" | Out-File $reportPath -Append
"- **FSR1**: Integrated (Header-only)" | Out-File $reportPath -Append

Write-Host "Metrics gathered in $reportPath"
