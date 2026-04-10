[CmdletBinding()]
param(
    [string]$ModName = "WTSpawnTest",
    [string]$CookRoot = "",
    [string]$ProjectCookName = "WarTorn_ModKit",
    [string]$PakName = ""
)

$repoDir = Split-Path -Parent $PSScriptRoot

if ([string]::IsNullOrWhiteSpace($CookRoot)) {
    $savedCookRoot = Join-Path $repoDir "Saved\Cooked\WindowsNoEditor\$ProjectCookName"
    $archivedCookRoot = Join-Path $repoDir "Build\Cooked\WindowsNoEditor\$ProjectCookName"

    if (Test-Path -LiteralPath $savedCookRoot) {
        $CookRoot = $savedCookRoot
    } else {
        $CookRoot = $archivedCookRoot
    }
}

if ([string]::IsNullOrWhiteSpace($PakName)) {
    $PakName = "$ModName.pak"
}

$cookedModContent = Join-Path $CookRoot "Content\Mods\$ModName"
$cookedAssetRegistry = Join-Path $CookRoot "AssetRegistry.bin"

if (-not (Test-Path -LiteralPath $cookedModContent)) {
    throw "Could not find cooked mod content: $cookedModContent"
}

if (-not (Test-Path -LiteralPath $cookedAssetRegistry)) {
    throw "Could not find cooked AssetRegistry.bin: $cookedAssetRegistry"
}

$looseRoot = Join-Path $repoDir "Build\LoosePak\$ModName"
$warTornRoot = Join-Path $looseRoot "WarTorn"
$modsRoot = Join-Path $warTornRoot "Content\Mods"
$assetRegistryTarget = Join-Path $warTornRoot "AssetRegistry.bin"

if (Test-Path -LiteralPath $looseRoot) {
    Remove-Item -LiteralPath $looseRoot -Recurse -Force
}

$null = New-Item -ItemType Directory -Force -Path $modsRoot
Copy-Item -LiteralPath $cookedAssetRegistry -Destination $assetRegistryTarget -Force
Copy-Item -LiteralPath $cookedModContent -Destination $modsRoot -Recurse -Force

$packScript = Join-Path $repoDir "Scripts\Pack-LoosePak.ps1"
if (-not (Test-Path -LiteralPath $packScript)) {
    throw "Could not find Pack-LoosePak.ps1: $packScript"
}

Write-Host "Repacking $ModName so it mounts under WarTorn/..."
& $packScript -LooseRoot $looseRoot -PakName $PakName
exit $LASTEXITCODE
