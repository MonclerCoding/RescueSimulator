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

if (-not (Test-Path $ProjectPath)) {
    Fail "Nie istnieje folder $ProjectPath"
}

Set-Location $ProjectPath

if (-not (Test-Path "default.project.json")) {
    Fail "Brak default.project.json bezposrednio w $ProjectPath"
}

if (-not (Get-Command rojo -ErrorAction SilentlyContinue)) {
    Fail "Brak Rojo CLI w PATH."
}

if (Test-Path ".git") {
    $dirty = @(git status --porcelain 2>$null)

    if ($dirty.Count -eq 0) {
        Write-Host "[SYNC] Sprawdzam GitHub..." -ForegroundColor Cyan
        git fetch origin main --prune 2>$null
        git show-ref --verify --quiet "refs/remotes/origin/main"

        if ($LASTEXITCODE -eq 0) {
            $local = (git rev-parse HEAD 2>$null | Out-String).Trim()
            $remote = (git rev-parse origin/main 2>$null | Out-String).Trim()
            $base = (git merge-base HEAD origin/main 2>$null | Out-String).Trim()

            if ($local -ne $remote -and $base -eq $local) {
                git merge --ff-only origin/main 2>$null
            }
        }
    }
    else {
        Write-Host "[WARN] Sa lokalne zmiany - nie robie automatycznego pull." -ForegroundColor Yellow
    }
}

$buildDir = Join-Path $ProjectPath "build"
New-Item -ItemType Directory -Path $buildDir -Force | Out-Null
$placeFile = Join-Path $buildDir "RescueSimulator.rbxlx"

Write-Host "[BUILD] Buduje pelny place przez Rojo..." -ForegroundColor Cyan
rojo build default.project.json -o $placeFile

if ($LASTEXITCODE -ne 0 -or -not (Test-Path $placeFile)) {
    Fail "rojo build nie utworzyl RescueSimulator.rbxlx"
}

Ok "Mapa zostala zbudowana do $placeFile"

# Zamknij poprzedni rojo serve tylko dla tego projektu.
Get-CimInstance Win32_Process -ErrorAction SilentlyContinue |
    Where-Object {
        $_.CommandLine -like "*rojo*serve*" -and
        $_.CommandLine -like "*RescueSimulator*"
    } |
    ForEach-Object {
        Stop-Process -Id $_.ProcessId -Force -ErrorAction SilentlyContinue
    }

$serveCommand = @"
Set-Location '$ProjectPath'
Write-Host ''
Write-Host '============================================' -ForegroundColor Cyan
Write-Host ' RESCUE SIMULATOR - ROJO LIVE SERVER' -ForegroundColor Cyan
Write-Host '============================================' -ForegroundColor Cyan
Write-Host 'Folder: $ProjectPath'
Write-Host 'Host:   127.0.0.1'
Write-Host 'Port:   34872'
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

Write-Host ""
Write-Host "Otwieram GOTOWY place w Roblox Studio." -ForegroundColor Cyan
Write-Host "Mapa bedzie widoczna nawet przed podlaczeniem pluginu Rojo." -ForegroundColor Yellow
Write-Host ""

try {
    Start-Process -FilePath $placeFile
    Ok "Uruchomiono $placeFile"
}
catch {
    Write-Host "[WARN] Windows nie otworzyl rbxlx automatycznie." -ForegroundColor Yellow
    Write-Host "Otworz recznie plik:"
    Write-Host "  $placeFile"
}

Write-Host ""
Write-Host "W Studio, kiedy place sie otworzy:" -ForegroundColor Cyan
Write-Host "  Plugins -> Rojo -> Connect"
Write-Host "  127.0.0.1:34872"
Write-Host ""
Write-Host "Explorer powinien pokazac:"
Write-Host "  Workspace -> GeneratedRescueMap"
Write-Host ""
