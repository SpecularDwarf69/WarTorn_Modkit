[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)]
    [string]$GameWin64Dir,
    [Parameter(Mandatory = $true)]
    [string]$ModName
)

function Clear-DirectoryContents {
    param(
        [string]$RootPath,
        [string]$TargetPath
    )

    if (-not (Test-Path -LiteralPath $TargetPath)) {
        return
    }

    $resolvedRoot = (Resolve-Path -LiteralPath $RootPath).Path
    $resolvedTarget = (Resolve-Path -LiteralPath $TargetPath).Path

    if (-not $resolvedTarget.StartsWith($resolvedRoot, [System.StringComparison]::OrdinalIgnoreCase)) {
        throw "Refusing to clean anything outside the mods folder: $resolvedTarget"
    }

    Get-ChildItem -LiteralPath $TargetPath -Force | Remove-Item -Recurse -Force
}

function Enable-ModInModsTxt {
    param(
        [string]$ModsTxtPath,
        [string]$ModName
    )

    $desiredLine = "$ModName : 1"
    $lines = if (Test-Path -LiteralPath $ModsTxtPath) {
        @(Get-Content -LiteralPath $ModsTxtPath)
    } else {
        @()
    }

    $escapedName = [regex]::Escape($ModName)
    $replaced = $false

    for ($i = 0; $i -lt $lines.Count; $i++) {
        if ($lines[$i] -match "^\s*$escapedName\s*:") {
            $lines[$i] = $desiredLine
            $replaced = $true
        }
    }

    if (-not $replaced) {
        if ($lines.Count -gt 0 -and $lines[-1] -ne "") {
            $lines += ""
        }

        $lines += $desiredLine
    }

    Set-Content -LiteralPath $ModsTxtPath -Value $lines -Encoding ASCII
}

$repoRoot = Split-Path -Parent $PSScriptRoot
$sourceDir = Join-Path $repoRoot "Deploy\UE4SSMods\$ModName"

if (-not (Test-Path -LiteralPath $sourceDir)) {
    throw "Could not find the repo-side UE4SS mod folder: $sourceDir"
}

if (-not (Test-Path -LiteralPath $GameWin64Dir)) {
    throw "Could not find the game Win64 folder: $GameWin64Dir"
}

$modsRoot = Join-Path $GameWin64Dir "Mods"
if (-not (Test-Path -LiteralPath $modsRoot)) {
    throw "Could not find the game's Mods folder: $modsRoot"
}

$targetDir = Join-Path $modsRoot $ModName
Clear-DirectoryContents -RootPath $modsRoot -TargetPath $targetDir
$null = New-Item -ItemType Directory -Force -Path $targetDir

Get-ChildItem -LiteralPath $sourceDir -Force | ForEach-Object {
    Copy-Item -LiteralPath $_.FullName -Destination $targetDir -Recurse -Force
}

$modsTxtPath = Join-Path $modsRoot "mods.txt"
Enable-ModInModsTxt -ModsTxtPath $modsTxtPath -ModName $ModName

Write-Host "Deployed '$ModName' to $targetDir"
Write-Host "Enabled '$ModName' in $modsTxtPath"
