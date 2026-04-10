[CmdletBinding()]
param(
    [string]$GameRoot = "",
    [int]$Tail = 30,
    [int]$PollMilliseconds = 1000,
    [switch]$IncludeActorDump
)

function Resolve-GameRoot {
    param([string]$RequestedRoot)

    if (-not [string]::IsNullOrWhiteSpace($RequestedRoot)) {
        return $RequestedRoot
    }

    if (-not [string]::IsNullOrWhiteSpace($env:WARTORN_GAME_ROOT)) {
        return $env:WARTORN_GAME_ROOT
    }

    throw "GameRoot is not set. Pass -GameRoot or set WARTORN_GAME_ROOT first."
}

function Get-LogTargets {
    param(
        [string]$ResolvedGameRoot,
        [switch]$WantActorDump
    )

    $targets = @(
        @{
            Name = "UE4SS"
            Path = Join-Path $ResolvedGameRoot "Binaries\Win64\UE4SS.log"
        },
        @{
            Name = "WTDebugHelper"
            Path = Join-Path $ResolvedGameRoot "Binaries\Win64\WTDebugHelper.log"
        }
    )

    if ($WantActorDump) {
        $targets += @{
            Name = "ActorDump"
            Path = Join-Path $ResolvedGameRoot "Binaries\Win64\ActorDump.txt"
        }
    }

    return $targets
}

function Get-LogLines {
    param([string]$Path)

    $lines = Get-Content -LiteralPath $Path -ErrorAction SilentlyContinue
    if ($null -eq $lines) {
        return @()
    }

    return @($lines)
}

function Write-LogBlock {
    param(
        [string]$Name,
        [string[]]$Lines,
        [int]$StartIndex
    )

    for ($i = $StartIndex; $i -lt $Lines.Count; $i++) {
        Write-Host "[$Name] $($Lines[$i])"
    }
}

$resolvedGameRoot = Resolve-GameRoot -RequestedRoot $GameRoot
$targets = Get-LogTargets -ResolvedGameRoot $resolvedGameRoot -WantActorDump:$IncludeActorDump
$knownLineCounts = @{}

foreach ($target in $targets) {
    if (-not (Test-Path -LiteralPath $target.Path)) {
        Write-Host "[$($target.Name)] Waiting for log file: $($target.Path)"
        $knownLineCounts[$target.Path] = 0
        continue
    }

    $lines = Get-LogLines -Path $target.Path
    $startIndex = [Math]::Max(0, $lines.Count - $Tail)
    Write-LogBlock -Name $target.Name -Lines $lines -StartIndex $startIndex
    $knownLineCounts[$target.Path] = $lines.Count
}

Write-Host "Watching game logs. Press Ctrl+C to stop."

while ($true) {
    Start-Sleep -Milliseconds $PollMilliseconds

    foreach ($target in $targets) {
        if (-not (Test-Path -LiteralPath $target.Path)) {
            continue
        }

        $lines = Get-LogLines -Path $target.Path
        $previousCount = if ($knownLineCounts.ContainsKey($target.Path)) { [int]$knownLineCounts[$target.Path] } else { 0 }

        if ($lines.Count -lt $previousCount) {
            $previousCount = 0
        }

        if ($lines.Count -gt $previousCount) {
            Write-LogBlock -Name $target.Name -Lines $lines -StartIndex $previousCount
        }

        $knownLineCounts[$target.Path] = $lines.Count
    }
}
