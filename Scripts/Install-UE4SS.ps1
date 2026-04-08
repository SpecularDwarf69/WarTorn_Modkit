[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)]
    [string]$GameWin64Dir,
    [string]$UE4SSRoot = "C:\Tools\UE4SS_v3.0.1"
)

$requiredPaths = @(
    (Join-Path $UE4SSRoot "UE4SS.dll"),
    (Join-Path $UE4SSRoot "dwmapi.dll"),
    (Join-Path $UE4SSRoot "UE4SS-settings.ini"),
    (Join-Path $UE4SSRoot "Mods")
)

foreach ($path in $requiredPaths) {
    if (-not (Test-Path -LiteralPath $path)) {
        throw "UE4SS component missing: $path"
    }
}

if (-not (Test-Path -LiteralPath $GameWin64Dir)) {
    throw "Game Win64 folder not found: $GameWin64Dir"
}

Copy-Item -LiteralPath (Join-Path $UE4SSRoot "UE4SS.dll") -Destination $GameWin64Dir -Force
Copy-Item -LiteralPath (Join-Path $UE4SSRoot "dwmapi.dll") -Destination $GameWin64Dir -Force
Copy-Item -LiteralPath (Join-Path $UE4SSRoot "UE4SS-settings.ini") -Destination $GameWin64Dir -Force
Copy-Item -LiteralPath (Join-Path $UE4SSRoot "Mods") -Destination (Join-Path $GameWin64Dir "Mods") -Recurse -Force

Write-Host "UE4SS installed to $GameWin64Dir"
