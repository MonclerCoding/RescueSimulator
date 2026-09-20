param(
    [string]$ProjectPath = "E:\RobloxGame\RescueSimulator",
    [int]$IntervalSeconds = 15
)

$ErrorActionPreference = "Continue"
$ProjectPath = $ProjectPath.Trim().Trim('"').TrimEnd('\')

if (-not (Test-Path (Join-Path $ProjectPath ".git"))) {
    exit 1
}

Set-Location $ProjectPath

while ($true) {
    try {
        $dirty = @(git status --porcelain 2>$null)
        if ($dirty.Count -eq 0) {
            git fetch --quiet origin main 2>$null

            if ($LASTEXITCODE -eq 0) {
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
        }
    }
    catch {
    }

    Start-Sleep -Seconds $IntervalSeconds
}
