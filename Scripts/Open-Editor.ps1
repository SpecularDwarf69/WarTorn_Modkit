[CmdletBinding()]
param(
    [string]$EngineRoot = "C:\EpicGames_games\UE_4.27"
)

$repoDir = Split-Path -Parent $PSScriptRoot
$projectFile = Join-Path $repoDir "WarTorn_ModKit.uproject"
$editorExe = Join-Path $EngineRoot "Engine\Binaries\Win64\UE4Editor.exe"

if (-not (Test-Path -LiteralPath $projectFile)) {
    throw "Could not find the project file: $projectFile"
}

if (-not (Test-Path -LiteralPath $editorExe)) {
    throw "Could not find UE4Editor.exe: $editorExe"
}

Write-Host "Opening WarTorn_ModKit in UE4..."
Start-Process -FilePath $editorExe -ArgumentList "`"$projectFile`""
