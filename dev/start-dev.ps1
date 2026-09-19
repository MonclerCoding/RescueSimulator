param([string]$ProjectPath = "E:\RobloxGame\RescueSimulator")

$ErrorActionPreference = "Continue"
$ProjectPath = $ProjectPath.Trim().Trim('"').TrimEnd('\')

if (-not (Test-Path $ProjectPath)) {
    Write-Host "[BLAD] Brak folderu: $ProjectPath" -ForegroundColor Red
    pause
    exit 1
}

Set-Location $ProjectPath

if (-not (Test-Path "default.project.json")) {
    Write-Host "[BLAD] Brak default.project.json w $ProjectPath" -ForegroundColor Red
    pause
    exit 1
}

if (-not (Get-Command rojo -ErrorAction SilentlyContinue)) {
    Write-Host "[BLAD] Brak Rojo CLI." -ForegroundColor Red
    pause
    exit 1
}

Write-Host ""
Write-Host "============================================" -ForegroundColor Cyan
Write-Host " RESCUE SIMULATOR - ROJO SERVER" -ForegroundColor Cyan
Write-Host "============================================" -ForegroundColor Cyan
Write-Host "Project: $ProjectPath"
Write-Host "Host:    127.0.0.1"
Write-Host "Port:    34872"
Write-Host ""
Write-Host "UWAGA: jezeli Studio jest puste, uzyj START_RESCUE_STUDIO.bat" -ForegroundColor Yellow
Write-Host ""

rojo serve default.project.json --address 127.0.0.1 --port 34872
