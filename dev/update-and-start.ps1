param(
    [string]$ProjectPath = "E:\RobloxGame\RescueSimulator"
)

$ErrorActionPreference = "Continue"
$ProjectPath = $ProjectPath.Trim().Trim('"').TrimEnd('\')

function Fail($m) {
    Write-Host "[BLAD] $m" -ForegroundColor Red
    pause
    exit 1
}

function Ok($m) {
    Write-Host "[ OK ] $m" -ForegroundColor Green
}

function Info($m) {
    Write-Host "[INFO] $m" -ForegroundColor Cyan
}

if (-not (Test-Path $ProjectPath)) {
    Fail "Brak folderu: $ProjectPath"
}

Set-Location $ProjectPath

if (-not (Test-Path ".git")) {
    Fail "Brak .git w $ProjectPath"
}
if (-not (Test-Path "default.project.json")) {
    Fail "Brak default.project.json w ROOT projektu."
}
if (-not (Get-Command git -ErrorAction SilentlyContinue)) {
    Fail "Brak Git."
}
if (-not (Get-Command rojo -ErrorAction SilentlyContinue)) {
    Fail "Brak Rojo CLI."
}

Write-Host ""
Write-Host "============================================================" -ForegroundColor Cyan
Write-Host " RESCUE SIMULATOR - UPDATE + ROJO + STUDIO" -ForegroundColor Cyan
Write-Host "============================================================" -ForegroundColor Cyan
Write-Host "GitHub:  MonclerCoding/RescueSimulator"
Write-Host "Folder:  $ProjectPath"
Write-Host ""

$dirty = @(git status --porcelain 2>$null)
if ($dirty.Count -gt 0) {
    $stamp = Get-Date -Format "yyyyMMdd_HHmmss"
    Info "Wykryto lokalne zmiany. Zabezpieczam je w git stash: $stamp"
    git stash push -u -m "Auto backup before update $stamp" 2>$null

    if ($LASTEXITCODE -ne 0) {
        Fail "Nie udalo sie zabezpieczyc lokalnych zmian."
    }
}

Info "Pobieram najnowsza wersje z GitHub..."
git fetch origin main --prune 2>$null
if ($LASTEXITCODE -ne 0) {
    Fail "git fetch nieudany."
}

git checkout main 2>$null
git pull --ff-only origin main 2>$null
if ($LASTEXITCODE -ne 0) {
    Fail "git pull --ff-only nieudany. Historia lokalna i GitHub moga sie roznic."
}

Ok "GitHub -> E:\RobloxGame\RescueSimulator zaktualizowane."

$buildDir = Join-Path $ProjectPath "build"
New-Item -ItemType Directory -Path $buildDir -Force | Out-Null
$placeFile = Join-Path $buildDir "RescueSimulator.rbxlx"

Info "Buduje place przez Rojo..."
rojo build default.project.json -o $placeFile
if ($LASTEXITCODE -ne 0 -or -not (Test-Path $placeFile)) {
    Fail "rojo build nieudany."
}
Ok "Build gotowy."

# Stop old Rojo servers for this project.
Get-CimInstance Win32_Process -ErrorAction SilentlyContinue |
    Where-Object {
        $_.CommandLine -like "*rojo*serve*" -and
        $_.CommandLine -like "*RescueSimulator*"
    } |
    ForEach-Object {
        Stop-Process -Id $_.ProcessId -Force -ErrorAction SilentlyContinue
    }

# Start one background auto-pull loop.
$autoScript = Join-Path $ProjectPath "dev\auto-pull.ps1"
$autoRunning = Get-CimInstance Win32_Process -ErrorAction SilentlyContinue |
    Where-Object {
        $_.CommandLine -like "*auto-pull.ps1*" -and
        $_.CommandLine -like "*RescueSimulator*"
    }

if (-not $autoRunning) {
    Start-Process powershell.exe -WindowStyle Hidden -ArgumentList @(
        "-NoProfile",
        "-ExecutionPolicy", "Bypass",
        "-File", "`"$autoScript`"",
        "-ProjectPath", "`"$ProjectPath`"",
        "-IntervalSeconds", "15"
    )
}

$serveCommand = @"
Set-Location '$ProjectPath'
Write-Host ''
Write-Host '================================================' -ForegroundColor Cyan
Write-Host ' RESCUE SIMULATOR - ROJO LIVE' -ForegroundColor Cyan
Write-Host '================================================' -ForegroundColor Cyan
Write-Host 'Folder: $ProjectPath'
Write-Host 'Host:   127.0.0.1'
Write-Host 'Port:   34872'
Write-Host 'AutoPull GitHub: ON'
Write-Host ''
rojo serve default.project.json --address 127.0.0.1 --port 34872
pause
"@

Start-Process powershell.exe -ArgumentList @(
    "-NoExit",
    "-NoProfile",
    "-ExecutionPolicy", "Bypass",
    "-Command", $serveCommand
)

Start-Sleep -Seconds 2

Info "Otwieram gotowy place w Roblox Studio..."
try {
    Start-Process -FilePath $placeFile
    Ok "Studio uruchomione."
}
catch {
    Write-Host "[WARN] Otworz recznie:" -ForegroundColor Yellow
    Write-Host $placeFile
}

Write-Host ""
Write-Host "W Studio:" -ForegroundColor Cyan
Write-Host "  Plugins -> Rojo -> Connect"
Write-Host "  127.0.0.1:34872"
Write-Host ""
Write-Host "Od teraz ten jeden plik robi:" -ForegroundColor Green
Write-Host "  GitHub -> Pull -> Build -> Rojo -> Studio -> AutoPull"
Write-Host ""
