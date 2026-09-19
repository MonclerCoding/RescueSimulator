param(
    [Parameter(Mandatory=$true)]
    [string]$ProjectPath
)

$ErrorActionPreference = "Continue"
$ProjectPath = $ProjectPath.Trim().Trim('"').TrimEnd('\')

try {
    $ProjectPath = (Resolve-Path $ProjectPath -ErrorAction Stop).Path.TrimEnd("\")
    Set-Location $ProjectPath -ErrorAction Stop
}
catch {
    Write-Host "[BLAD] Nie moge wejsc do $ProjectPath" -ForegroundColor Red
    exit 1
}

function Say($Message, $Color = "Gray") {
    Write-Host $Message -ForegroundColor $Color
}

if (-not (Test-Path ".git")) {
    Say "[BLAD] Brak repo Git." Red
    exit 1
}

$branch = (git branch --show-current 2>$null | Out-String).Trim()
if ([string]::IsNullOrWhiteSpace($branch)) {
    $branch = "main"
}

git add -A
if ($LASTEXITCODE -ne 0) {
    Say "[BLAD] git add nieudany." Red
    exit 2
}

git diff --cached --quiet
if ($LASTEXITCODE -ne 0) {
    $message = (Read-Host "Opis zmian [Enter = Local Rescue Simulator update]").Trim()
    if ([string]::IsNullOrWhiteSpace($message)) {
        $message = "Local Rescue Simulator update"
    }

    git commit -m $message
    if ($LASTEXITCODE -ne 0) {
        Say "[BLAD] Commit nieudany." Red
        exit 3
    }
}

Say "[SYNC] Sprawdzam najnowszy GitHub..." Cyan
git fetch origin $branch --prune 2>$null

# Puste repo zdalne jest OK.
git show-ref --verify --quiet "refs/remotes/origin/$branch"
$remoteExists = ($LASTEXITCODE -eq 0)

if ($remoteExists) {
    git rebase "origin/$branch"
    if ($LASTEXITCODE -ne 0) {
        git rebase --abort 2>$null
        Say "[BLAD] Konflikt podczas rebase. Niczego nie wymuszam." Red
        exit 4
    }
}

if ($remoteExists) {
    git push origin $branch
} else {
    git push -u origin $branch
}

if ($LASTEXITCODE -ne 0) {
    Say "[BLAD] Push nieudany." Red
    exit 5
}

Say "[OK] Lokalna wersja wyslana na GitHub." Green

