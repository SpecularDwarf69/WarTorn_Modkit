[CmdletBinding()]
param(
    [string]$EngineRoot = "C:\EpicGames_games\UE_4.27",
    [string]$LooseRoot = "",
    [string]$PakName = "WarTorn_Mod_P.pak"
)

$repoDir = Split-Path -Parent $PSScriptRoot
$unrealPakExe = Join-Path $EngineRoot "Engine\Binaries\Win64\UnrealPak.exe"

if (-not (Test-Path -LiteralPath $unrealPakExe)) {
    throw "Could not find UnrealPak.exe: $unrealPakExe"
}

if ([string]::IsNullOrWhiteSpace($LooseRoot)) {
    $LooseRoot = Join-Path $repoDir "LoosePak"
}

$warTornLooseRoot = Join-Path $LooseRoot "WarTorn"
if (-not (Test-Path -LiteralPath $warTornLooseRoot)) {
    throw "Could not find the staged loose pak folder: $warTornLooseRoot"
}

$pakOutputDir = Join-Path $repoDir "Build\Paks"
$responseDir = Join-Path $repoDir "Build\ResponseFiles"
$null = New-Item -ItemType Directory -Force -Path $pakOutputDir, $responseDir

$responseFile = Join-Path $responseDir "WarTorn_Mod_Response.txt"
$pakOutputPath = Join-Path $pakOutputDir $PakName
$stagedFiles = Get-ChildItem -LiteralPath $warTornLooseRoot -Recurse -File

if ($stagedFiles.Count -eq 0) {
    throw "There are no staged files under: $warTornLooseRoot"
}

$responseLines = foreach ($file in $stagedFiles) {
    $relativePath = $file.FullName.Substring($LooseRoot.Length).TrimStart('\')
    $mountPath = "../../../" + ($relativePath -replace "\\", "/")
    """$($file.FullName)"" ""$mountPath"""
}

Set-Content -LiteralPath $responseFile -Value $responseLines -Encoding ASCII

Write-Host "Packing loose files into $pakOutputPath..."
& $unrealPakExe $pakOutputPath "-Create=$responseFile" "-compress"
exit $LASTEXITCODE
