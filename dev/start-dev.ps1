param(
    [Parameter(Mandatory=$true)]
    [string]$ProjectPath
)

# Native programs such as git/rojo often write normal status text to STDERR.
# "Continue" prevents PowerShell 5.1 from treating that normal text as a fatal exception.
$ErrorActionPreference = "Continue"

try {
    $ProjectPath = (Resolve-Path $ProjectPath -ErrorAction Stop).Path.TrimEnd("\")
    Set-Location $ProjectPath -ErrorAction Stop
}
catch {
    Write-Host "[BLAD] Nie moge wejsc do folderu projektu: $ProjectPath" -ForegroundColor Red
    exit 1
}

function Fail($Message) {
    Write-Host "[BLAD] $Message" -ForegroundColor Red
    exit 1
}

if (-not (Get-Command git -ErrorAction SilentlyContinue)) {
    Fail "Git nie jest dostepny w PATH."
}

if (-not (Test-Path ".git")) {
    Fail "Brak .git. Uruchom ponownie paczke DEPLOY_FIXED."
}

if (-not (Test-Path "default.project.json")) {
    Fail "Brak default.project.json."
}

if (-not (Get-Command rojo -ErrorAction SilentlyContinue)) {
    Fail "Rojo CLI nie jest zainstalowane albo nie jest w PATH."
}

Write-Host ""
Write-Host "====================================================" -ForegroundColor Cyan
Write-Host " RESCUE SIMULATOR DEV" -ForegroundColor Cyan
Write-Host "====================================================" -ForegroundColor Cyan
Write-Host "Folder:   $ProjectPath"
Write-Host "GitHub:   https://github.com/MonclerCoding/RescueSimulator"
Write-Host "AutoPull: GitHub -> PC co 15 sekund" -ForegroundColor Green
Write-Host "Rojo:     127.0.0.1:34872" -ForegroundColor Green
Write-Host "====================================================" -ForegroundColor Cyan
Write-Host ""

# Bezpieczny sync przed startem.
$syncScript = Join-Path $ProjectPath "dev\sync-now.ps1"
& powershell.exe -NoProfile -ExecutionPolicy Bypass -File $syncScript -ProjectPath $ProjectPath
$syncExit = $LASTEXITCODE

if ($syncExit -ne 0 -and $syncExit -ne 2) {
    Write-Host "[WARN] Sync zwrocil kod $syncExit. Rojo i tak zostanie uruchomione." -ForegroundColor Yellow
}

# Jeden AutoPull na projekt.
$autoScript = Join-Path $ProjectPath "dev\github-auto-pull.ps1"
$existing = Get-CimInstance Win32_Process -ErrorAction SilentlyContinue |
    Where-Object {
        $_.Name -eq "powershell.exe" -and
        $_.CommandLine -like "*github-auto-pull.ps1*" -and
        $_.CommandLine -like "*$ProjectPath*"
    }

if (-not $existing) {
    Start-Process powershell.exe -WindowStyle Hidden -ArgumentList @(
        "-NoProfile",
        "-ExecutionPolicy", "Bypass",
        "-File", "`"$autoScript`"",
        "-ProjectPath", "`"$ProjectPath`"",
        "-IntervalSeconds", "15"
    )
    Write-Host "[OK] AutoPull uruchomiony." -ForegroundColor Green
}
else {
    Write-Host "[OK] AutoPull juz dziala." -ForegroundColor Green
}

Write-Host ""
Write-Host "W Roblox Studio:" -ForegroundColor Cyan
Write-Host "  Plugins -> Rojo -> Connect"
Write-Host "  Host: 127.0.0.1"
Write-Host "  Port: 34872"
Write-Host ""
Write-Host "Zostaw to okno otwarte podczas pracy." -ForegroundColor Yellow
Write-Host ""

rojo serve default.project.json --address 127.0.0.1 --port 34872
$rojoExit = $LASTEXITCODE

if ($rojoExit -ne 0) {
    Write-Host ""
    Write-Host "[BLAD] Rojo zakonczyl prace z kodem $rojoExit." -ForegroundColor Red
    exit $rojoExit
}
