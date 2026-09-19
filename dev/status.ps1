param(
    [Parameter(Mandatory=$true)]
    [string]$ProjectPath
)

$ErrorActionPreference = "Continue"

try {
    $ProjectPath = (Resolve-Path $ProjectPath -ErrorAction Stop).Path.TrimEnd("\")
    Set-Location $ProjectPath -ErrorAction Stop
}
catch {
    Write-Host "[BLAD] Nie moge wejsc do $ProjectPath" -ForegroundColor Red
    exit 1
}

Write-Host ""
Write-Host "====================================================" -ForegroundColor Cyan
Write-Host " RESCUE SIMULATOR - STATUS" -ForegroundColor Cyan
Write-Host "====================================================" -ForegroundColor Cyan

if (-not (Test-Path ".git")) {
    Write-Host "Git:      BRAK .git" -ForegroundColor Red
    exit 1
}

$origin = (git remote get-url origin 2>$null | Out-String).Trim()
$branch = (git branch --show-current 2>$null | Out-String).Trim()
$head = (git log -1 --oneline 2>$null | Out-String).Trim()

Write-Host "Folder:   $ProjectPath"
Write-Host "Origin:   $origin"
Write-Host "Branch:   $branch"
Write-Host "HEAD:     $head"

$dirty = @(git status --porcelain 2>$null)
if ($dirty.Count -eq 0) {
    Write-Host "Local:    CLEAN" -ForegroundColor Green
}
else {
    Write-Host "Local:    ZMIANY" -ForegroundColor Yellow
    git status --short
}

git fetch origin --prune 2>$null
if ($LASTEXITCODE -eq 0 -and -not [string]::IsNullOrWhiteSpace($branch)) {
    git show-ref --verify --quiet "refs/remotes/origin/$branch"
    if ($LASTEXITCODE -eq 0) {
        $local = (git rev-parse HEAD 2>$null | Out-String).Trim()
        $remote = (git rev-parse "origin/$branch" 2>$null | Out-String).Trim()
        if ($local -eq $remote) {
            Write-Host "GitHub:   SYNC OK" -ForegroundColor Green
        } else {
            Write-Host "GitHub:   ROZNI SIE OD PC" -ForegroundColor Yellow
        }
    }
    else {
        Write-Host "GitHub:   BRANCH JESZCZE NIE ISTNIEJE" -ForegroundColor Yellow
    }
}
else {
    Write-Host "GitHub:   FETCH ERROR" -ForegroundColor Red
}

if (Get-Command rojo -ErrorAction SilentlyContinue) {
    Write-Host ("Rojo:     " + ((rojo --version 2>$null | Out-String).Trim())) -ForegroundColor Green
}
else {
    Write-Host "Rojo:     BRAK CLI" -ForegroundColor Red
}
