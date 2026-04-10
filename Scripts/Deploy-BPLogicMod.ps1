[CmdletBinding()]
param(
    [string]$ModName = "WTSpawnTest",
    [string]$PakPath = "",
    [string]$CookRoot = "",
    [string]$GameRoot = "",
    [switch]$CopyConfig
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

function Resolve-PakPath {
    param(
        [string]$RequestedPakPath,
        [string]$ModName,
        [string]$ProjectRoot,
        [string]$CookRoot
    )

    if (-not [string]::IsNullOrWhiteSpace($RequestedPakPath)) {
        if (-not (Test-Path -LiteralPath $RequestedPakPath)) {
            throw "Pak file not found: $RequestedPakPath"
        }

        return $RequestedPakPath
    }

    $preferredPak = Join-Path $ProjectRoot ("Build\Paks\" + $ModName + ".pak")
    if (Test-Path -LiteralPath $preferredPak) {
        return $preferredPak
    }

    $latestCookedPak = Get-ChildItem -LiteralPath $CookRoot -Recurse -Filter *.pak -ErrorAction SilentlyContinue |
        Sort-Object LastWriteTime -Descending |
        Select-Object -First 1

    if (-not $latestCookedPak) {
        throw "Could not find a cooked pak under: $CookRoot"
    }

    return $latestCookedPak.FullName
}

$projectRoot = Split-Path -Parent $PSScriptRoot
$resolvedGameRoot = Resolve-GameRoot -RequestedRoot $GameRoot

if ([string]::IsNullOrWhiteSpace($CookRoot)) {
    $CookRoot = Join-Path $projectRoot "Build\Cooked"
}

$logicModsRoot = Join-Path $resolvedGameRoot "Content\Paks\LogicMods"
$null = New-Item -ItemType Directory -Force -Path $logicModsRoot

$resolvedPakPath = Resolve-PakPath -RequestedPakPath $PakPath -ModName $ModName -ProjectRoot $projectRoot -CookRoot $CookRoot
$targetPakPath = Join-Path $logicModsRoot ($ModName + ".pak")

Copy-Item -LiteralPath $resolvedPakPath -Destination $targetPakPath -Force
Write-Host "Copied pak to $targetPakPath"

if ($CopyConfig) {
    $configSource = Join-Path $projectRoot ("Deploy\LogicMods\" + $ModName + "\config.lua")
    if (-not (Test-Path -LiteralPath $configSource)) {
        throw "Could not find config template: $configSource"
    }

    $configTargetDir = Join-Path $logicModsRoot $ModName
    $configTarget = Join-Path $configTargetDir "config.lua"

    $null = New-Item -ItemType Directory -Force -Path $configTargetDir
    Copy-Item -LiteralPath $configSource -Destination $configTarget -Force
    Write-Host "Copied config to $configTarget"
}
