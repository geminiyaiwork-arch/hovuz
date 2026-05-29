# PowerShell — Hovuz Windows build skripti.
# Windows mashinada ishga tushiring:
#   1. PowerShell ochib: cd <repo>
#   2. .\packaging\windows\build_windows.ps1
#
# Talab: Flutter SDK + Visual Studio 2022 build tools + Inno Setup 6+.

$ErrorActionPreference = "Stop"

Push-Location (Join-Path $PSScriptRoot "..\..")

Write-Host "==> flutter pub get"
flutter pub get

Write-Host "==> flutter build windows --release"
flutter build windows --release

$bundleDir = "build\windows\x64\runner\Release"
if (-not (Test-Path $bundleDir)) {
    throw "Build folder not found: $bundleDir"
}

Write-Host "==> Inno Setup compile"
$iscc = "C:\Program Files (x86)\Inno Setup 6\ISCC.exe"
if (-not (Test-Path $iscc)) {
    $iscc = "C:\Program Files\Inno Setup 6\ISCC.exe"
}
if (-not (Test-Path $iscc)) {
    Write-Warning "Inno Setup topilmadi. .exe bundle: $bundleDir"
    Write-Warning "Installer yasash uchun https://jrsoftware.org/isdl.php dan o'rnating."
    exit 0
}

& $iscc "packaging\windows\hovuz_setup.iss"

if (Test-Path "dist") {
    Write-Host ""
    Write-Host "✅  dist\HovuzSetup-*.exe tayyor"
    Get-ChildItem dist\HovuzSetup-*.exe | ForEach-Object { Write-Host "    $($_.FullName)" }
}

Pop-Location
