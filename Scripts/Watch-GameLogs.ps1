[CmdletBinding()]
param(
    [string]$GameRoot = "C:\Users\ukuto\Desktop\Projects\War-Torn_decomp\War-Torn_Remastered.v35.9\WarTorn",
    [int]$Tail = 30,
    [int]$PollMilliseconds = 1000,
    [switch]$IncludeActorDump
)

$targets = @(
    @{
        Name = "UE4SS"
        Path = Join-Path $GameRoot "Binaries\Win64\UE4SS.log"
    },
    @{
        Name = "WTDebugHelper"
        Path = Join-Path $GameRoot "Binaries\Win64\WTDebugHelper.log"
    }
)

if ($IncludeActorDump) {
    $targets += @{
        Name = "ActorDump"
        Path = Join-Path $GameRoot "Binaries\Win64\ActorDump.txt"
    }
}

$states = @{}

foreach ($target in $targets) {
    $path = $target.Path
    $name = $target.Name

    if (-not (Test-Path -LiteralPath $path)) {
        Write-Host "[$name] Waiting for file: $path"
        $states[$path] = 0
        continue
    }

    $lines = Get-Content -LiteralPath $path -ErrorAction SilentlyContinue
    $count = if ($lines) { $lines.Count } else { 0 }
    $startIndex = [Math]::Max(0, $count - $Tail)

    for ($index = $startIndex; $index -lt $count; $index++) {
        Write-Host "[$name] $($lines[$index])"
    }

    $states[$path] = $count
}

Write-Host "Watching game logs. Press Ctrl+C to stop."

while ($true) {
    Start-Sleep -Milliseconds $PollMilliseconds

    foreach ($target in $targets) {
        $path = $target.Path
        $name = $target.Name

        if (-not (Test-Path -LiteralPath $path)) {
            continue
        }

        $lines = Get-Content -LiteralPath $path -ErrorAction SilentlyContinue
        $count = if ($lines) { $lines.Count } else { 0 }
        $knownCount = if ($states.ContainsKey($path)) { [int]$states[$path] } else { 0 }

        if ($count -lt $knownCount) {
            $knownCount = 0
        }

        if ($count -gt $knownCount) {
            for ($index = $knownCount; $index -lt $count; $index++) {
                Write-Host "[$name] $($lines[$index])"
            }
        }

        $states[$path] = $count
    }
}
