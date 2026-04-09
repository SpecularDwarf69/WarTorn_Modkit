[CmdletBinding()]
param(
    [string]$ModName = "WTSpawnTest",
    [string]$PakPath = "",
    [string]$CookRoot = "",
    [string]$GameRoot = "",
    [switch]$CopyConfig
)

$projectRoot = Split-Path -Parent $PSScriptRoot

if ([string]::IsNullOrWhiteSpace($GameRoot)) {
    $GameRoot = $env:WARTORN_GAME_ROOT
}

if ([string]::IsNullOrWhiteSpace($GameRoot)) {
    throw "GameRoot is not set. Pass -GameRoot or set the WARTORN_GAME_ROOT environment variable."
}

$logicModsRoot = Join-Path $GameRoot "Content\Paks\LogicMods"

if (-not (Test-Path -LiteralPath $logicModsRoot)) {
    $null = New-Item -ItemType Directory -Force -Path $logicModsRoot
}

if ([string]::IsNullOrWhiteSpace($CookRoot)) {
    $CookRoot = Join-Path $projectRoot "Build\Cooked"
}

if ([string]::IsNullOrWhiteSpace($PakPath)) {
    $preferredPak = Join-Path $projectRoot ("Build\Paks\" + $ModName + ".pak")
    if (Test-Path -LiteralPath $preferredPak) {
        $PakPath = $preferredPak
    }
}

if ([string]::IsNullOrWhiteSpace($PakPath)) {
    $candidate = Get-ChildItem -LiteralPath $CookRoot -Recurse -Filter *.pak -ErrorAction SilentlyContinue |
        Sort-Object LastWriteTime -Descending |
        Select-Object -First 1

    if (-not $candidate) {
        throw "No cooked pak found under: $CookRoot"
    }

    $PakPath = $candidate.FullName
}

if (-not (Test-Path -LiteralPath $PakPath)) {
    throw "Pak file not found: $PakPath"
}

$targetPak = Join-Path $logicModsRoot ($ModName + ".pak")
Copy-Item -LiteralPath $PakPath -Destination $targetPak -Force

$configSource = Join-Path $projectRoot ("Deploy\LogicMods\" + $ModName + "\config.lua")
$configTargetDir = Join-Path $logicModsRoot $ModName
$configTarget = Join-Path $configTargetDir "config.lua"

if ($CopyConfig) {
    if (-not (Test-Path -LiteralPath $configSource)) {
        throw "Config template not found: $configSource"
    }

    $null = New-Item -ItemType Directory -Force -Path $configTargetDir
    Copy-Item -LiteralPath $configSource -Destination $configTarget -Force
}

Write-Host "Deployed pak: $targetPak"
if ($CopyConfig) {
    Write-Host "Deployed config: $configTarget"
}
