[CmdletBinding()]
param(
    [string]$EngineRoot = "C:\EpicGames_games\UE_4.27"
)

$projectRoot = Split-Path -Parent $PSScriptRoot
$uproject = Join-Path $projectRoot "WarTorn_ModKit.uproject"
$editor = Join-Path $EngineRoot "Engine\Binaries\Win64\UE4Editor.exe"

if (-not (Test-Path -LiteralPath $uproject)) {
    throw "Project file not found: $uproject"
}

if (-not (Test-Path -LiteralPath $editor)) {
    throw "UE4Editor.exe not found: $editor"
}

Start-Process -FilePath $editor -ArgumentList "`"$uproject`""
