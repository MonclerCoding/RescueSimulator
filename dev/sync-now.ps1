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

function Say($Message, $Color = "Gray") {
    Write-Host $Message -ForegroundColor $Color
}

if (-not (Test-Path ".git")) {
    Say "[BLAD] Brak .git." Red
    exit 1
}

$origin = (git remote get-url origin 2>$null | Out-String).Trim()
if ([string]::IsNullOrWhiteSpace($origin)) {
    Say "[BLAD] Brak remote origin." Red
    exit 1
}

$branch = (git branch --show-current 2>$null | Out-String).Trim()
if ([string]::IsNullOrWhiteSpace($branch)) {
    $branch = "main"
}

$dirty = @(git status --porcelain 2>$null)
if ($dirty.Count -gt 0) {
    Say "[STOP] Masz lokalne zmiany. Nie pobieram GitHub, zeby ich nie nadpisac." Yellow
    git status --short
    exit 2
}

Say "[SYNC] Sprawdzam origin/$branch..." Cyan

git fetch origin $branch --prune 2>$null
if ($LASTEXITCODE -ne 0) {
    Say "[BLAD] git fetch nieudany." Red
    exit 3
}

git show-ref --verify --quiet "refs/remotes/origin/$branch"
if ($LASTEXITCODE -ne 0) {
    Say "[INFO] GitHub nie ma jeszcze brancha $branch." Yellow
    exit 0
}

$local = (git rev-parse HEAD 2>$null | Out-String).Trim()
$remote = (git rev-parse "origin/$branch" 2>$null | Out-String).Trim()

if ($local -eq $remote) {
    Say "[OK] PC ma juz najnowsza wersje GitHub." Green
    exit 0
}

$base = (git merge-base HEAD "origin/$branch" 2>$null | Out-String).Trim()

if ($base -eq $local) {
    git merge --ff-only "origin/$branch" 2>$null
    if ($LASTEXITCODE -ne 0) {
        Say "[BLAD] Fast-forward nieudany." Red
        exit 4
    }
}
elseif ($base -eq $remote) {
    Say "[INFO] Lokalny branch jest do przodu. Uzyj PUSH_LOCAL.bat." Yellow
    exit 0
}
else {
    Say "[BLAD] Historia lokalna i GitHub sa rozbiezne. Niczego nie wymuszam." Red
    exit 5
}

$head = (git log -1 --oneline | Out-String).Trim()
Say "[OK] GitHub -> PC: $head" Green
