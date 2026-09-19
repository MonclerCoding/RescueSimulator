param(
    [Parameter(Mandatory=$true)]
    [string]$ProjectPath,

    [int]$IntervalSeconds = 15
)

$ErrorActionPreference = "Continue"

try {
    $ProjectPath = (Resolve-Path $ProjectPath -ErrorAction Stop).Path.TrimEnd("\")
    Set-Location $ProjectPath -ErrorAction Stop
}
catch {
    exit 1
}

function Log($Message, $Color = "Gray") {
    $time = Get-Date -Format "HH:mm:ss"
    Write-Host "[$time] $Message" -ForegroundColor $Color
}

if (-not (Test-Path ".git")) {
    Log "Brak .git w $ProjectPath" Red
    exit 1
}

$branch = (git branch --show-current 2>$null | Out-String).Trim()
if ([string]::IsNullOrWhiteSpace($branch)) {
    $branch = "main"
}

Log "AutoPull ON: origin/$branch co $IntervalSeconds s" Green

while ($true) {
    try {
        Set-Location $ProjectPath -ErrorAction Stop

        $dirty = @(git status --porcelain 2>$null)
        if ($dirty.Count -gt 0) {
            Log "Lokalne zmiany - czekam, niczego nie nadpisuje." Yellow
            Start-Sleep -Seconds $IntervalSeconds
            continue
        }

        git fetch --quiet origin $branch 2>$null
        if ($LASTEXITCODE -ne 0) {
            Log "Fetch GitHub nieudany." Red
            Start-Sleep -Seconds $IntervalSeconds
            continue
        }

        git show-ref --verify --quiet "refs/remotes/origin/$branch"
        if ($LASTEXITCODE -ne 0) {
            Start-Sleep -Seconds $IntervalSeconds
            continue
        }

        $local = (git rev-parse HEAD 2>$null | Out-String).Trim()
        $remote = (git rev-parse "origin/$branch" 2>$null | Out-String).Trim()

        if ([string]::IsNullOrWhiteSpace($remote) -or $local -eq $remote) {
            Start-Sleep -Seconds $IntervalSeconds
            continue
        }

        $base = (git merge-base HEAD "origin/$branch" 2>$null | Out-String).Trim()

        if ($base -eq $local) {
            Log "Nowa wersja na GitHub - pobieram..." Cyan
            git merge --ff-only "origin/$branch" 2>$null

            if ($LASTEXITCODE -eq 0) {
                $short = (git rev-parse --short HEAD | Out-String).Trim()
                $subject = (git log -1 --pretty=%s | Out-String).Trim()
                Log "UPDATE $short - $subject" Green
            }
            else {
                Log "Fast-forward nieudany." Red
            }
        }
        elseif ($base -eq $remote) {
            Log "Lokalny branch jest do przodu. Uzyj PUSH_LOCAL.bat." Yellow
        }
        else {
            Log "Historia lokalna i GitHub sa rozbiezne. Nie robie automatycznego merge." Red
        }
    }
    catch {
        Log ("Blad AutoPull: " + $_.Exception.Message) Red
    }

    Start-Sleep -Seconds $IntervalSeconds
}
