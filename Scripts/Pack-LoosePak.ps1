[CmdletBinding()]
param(
    [string]$EngineRoot = "C:\EpicGames_games\UE_4.27",
    [string]$LooseRoot = "",
    [string]$PakName = "WarTorn_Mod_P.pak"
)

$projectRoot = Split-Path -Parent $PSScriptRoot
$unrealPak = Join-Path $EngineRoot "Engine\Binaries\Win64\UnrealPak.exe"

if (-not (Test-Path -LiteralPath $unrealPak)) {
    throw "UnrealPak.exe not found: $unrealPak"
}

if ([string]::IsNullOrWhiteSpace($LooseRoot)) {
    $LooseRoot = Join-Path $projectRoot "LoosePak"
}

$warTornRoot = Join-Path $LooseRoot "WarTorn"

if (-not (Test-Path -LiteralPath $warTornRoot)) {
    throw "Loose pak root not found: $warTornRoot"
}

$pakDir = Join-Path $projectRoot "Build\Paks"
$responseDir = Join-Path $projectRoot "Build\ResponseFiles"
$null = New-Item -ItemType Directory -Force -Path $pakDir, $responseDir

$responseFile = Join-Path $responseDir "WarTorn_Mod_Response.txt"
$pakPath = Join-Path $pakDir $PakName
$files = Get-ChildItem -LiteralPath $warTornRoot -Recurse -File

if ($files.Count -eq 0) {
    throw "No staged files found under: $warTornRoot"
}

$lines = foreach ($file in $files) {
    $relative = $file.FullName.Substring($LooseRoot.Length).TrimStart('\')
    $mountPoint = "../../../" + ($relative -replace "\\", "/")
    """$($file.FullName)"" ""$mountPoint"""
}

Set-Content -LiteralPath $responseFile -Value $lines -Encoding ascii

& $unrealPak $pakPath "-Create=$responseFile" "-compress"
exit $LASTEXITCODE
