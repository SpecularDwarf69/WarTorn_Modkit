[CmdletBinding()]
param(
    [string]$ModName = "WTSpawnTest",
    [string]$CookRoot = "",
    [string]$ProjectCookName = "WarTorn_ModKit",
    [string]$PakName = ""
)

$projectRoot = Split-Path -Parent $PSScriptRoot

if ([string]::IsNullOrWhiteSpace($CookRoot)) {
    $savedCookRoot = Join-Path $projectRoot "Saved\Cooked\WindowsNoEditor\$ProjectCookName"
    $archivedCookRoot = Join-Path $projectRoot "Build\Cooked\WindowsNoEditor\$ProjectCookName"

    if (Test-Path -LiteralPath $savedCookRoot) {
        $CookRoot = $savedCookRoot
    } else {
        $CookRoot = $archivedCookRoot
    }
}

if ([string]::IsNullOrWhiteSpace($PakName)) {
    $PakName = "$ModName.pak"
}

$contentSource = Join-Path $CookRoot "Content\Mods\$ModName"
$assetRegistrySource = Join-Path $CookRoot "AssetRegistry.bin"

if (-not (Test-Path -LiteralPath $contentSource)) {
    throw "Cooked mod content not found: $contentSource"
}

if (-not (Test-Path -LiteralPath $assetRegistrySource)) {
    throw "Cooked AssetRegistry.bin not found: $assetRegistrySource"
}

$looseRoot = Join-Path $projectRoot "Build\LoosePak\$ModName"
$warTornRoot = Join-Path $looseRoot "WarTorn"
$contentTarget = Join-Path $warTornRoot "Content\Mods\$ModName"
$modsTargetRoot = Join-Path $warTornRoot "Content\Mods"
$assetRegistryTarget = Join-Path $warTornRoot "AssetRegistry.bin"

if (Test-Path -LiteralPath $looseRoot) {
    Remove-Item -LiteralPath $looseRoot -Recurse -Force
}

$null = New-Item -ItemType Directory -Force -Path $modsTargetRoot
Copy-Item -LiteralPath $assetRegistrySource -Destination $assetRegistryTarget -Force
Copy-Item -LiteralPath $contentSource -Destination $modsTargetRoot -Recurse -Force

$packScript = Join-Path $projectRoot "Scripts\Pack-LoosePak.ps1"
if (-not (Test-Path -LiteralPath $packScript)) {
    throw "Pack-LoosePak.ps1 not found: $packScript"
}

& $packScript -LooseRoot $looseRoot -PakName $PakName
exit $LASTEXITCODE
