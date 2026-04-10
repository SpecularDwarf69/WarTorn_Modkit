[CmdletBinding()]
param(
    [string]$EngineRoot = "C:\EpicGames_games\UE_4.27",
    [string]$Configuration = "Shipping",
    [string[]]$Maps = @(),
    [string]$ArchiveDir = ""
)

$repoDir = Split-Path -Parent $PSScriptRoot
$projectFile = Join-Path $repoDir "WarTorn_ModKit.uproject"
$uatBat = Join-Path $EngineRoot "Engine\Build\BatchFiles\RunUAT.bat"

if (-not (Test-Path -LiteralPath $projectFile)) {
    throw "Could not find the project file: $projectFile"
}

if (-not (Test-Path -LiteralPath $uatBat)) {
    throw "Could not find RunUAT.bat: $uatBat"
}

if ([string]::IsNullOrWhiteSpace($ArchiveDir)) {
    $ArchiveDir = Join-Path $repoDir "Build\Cooked"
}

$uatArgs = @(
    "BuildCookRun",
    "-project=$projectFile",
    "-noP4",
    "-platform=Win64",
    "-clientconfig=$Configuration",
    "-cook",
    "-stage",
    "-pak",
    "-archive",
    "-archivedirectory=$ArchiveDir",
    "-SkipCookingEditorContent"
)

if ($Maps.Count -gt 0) {
    $uatArgs += "-map=$($Maps -join '+')"
}

Write-Host "Cooking WarTorn_ModKit for Win64..."
& $uatBat @uatArgs
exit $LASTEXITCODE
