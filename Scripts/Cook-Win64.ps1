[CmdletBinding()]
param(
    [string]$EngineRoot = "C:\EpicGames_games\UE_4.27",
    [string]$Configuration = "Shipping",
    [string[]]$Maps = @(),
    [string]$ArchiveDir = ""
)

$projectRoot = Split-Path -Parent $PSScriptRoot
$uproject = Join-Path $projectRoot "WarTorn_ModKit.uproject"
$uat = Join-Path $EngineRoot "Engine\Build\BatchFiles\RunUAT.bat"

if (-not (Test-Path -LiteralPath $uproject)) {
    throw "Project file not found: $uproject"
}

if (-not (Test-Path -LiteralPath $uat)) {
    throw "RunUAT.bat not found: $uat"
}

if ([string]::IsNullOrWhiteSpace($ArchiveDir)) {
    $ArchiveDir = Join-Path $projectRoot "Build\Cooked"
}

$args = @(
    "BuildCookRun",
    "-project=$uproject",
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
    $args += "-map=$($Maps -join '+')"
}

& $uat @args
exit $LASTEXITCODE
