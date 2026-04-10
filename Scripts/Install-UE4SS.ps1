[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)]
    [string]$GameWin64Dir,
    [string]$UE4SSRoot = "C:\Tools\UE4SS_v3.0.1"
)

$requiredItems = @(
    (Join-Path $UE4SSRoot "UE4SS.dll"),
    (Join-Path $UE4SSRoot "dwmapi.dll"),
    (Join-Path $UE4SSRoot "UE4SS-settings.ini"),
    (Join-Path $UE4SSRoot "Mods")
)

foreach ($item in $requiredItems) {
    if (-not (Test-Path -LiteralPath $item)) {
        throw "Missing UE4SS file or folder: $item"
    }
}

if (-not (Test-Path -LiteralPath $GameWin64Dir)) {
    throw "Could not find the game's Win64 folder: $GameWin64Dir"
}

Copy-Item -LiteralPath (Join-Path $UE4SSRoot "UE4SS.dll") -Destination $GameWin64Dir -Force
Copy-Item -LiteralPath (Join-Path $UE4SSRoot "dwmapi.dll") -Destination $GameWin64Dir -Force
Copy-Item -LiteralPath (Join-Path $UE4SSRoot "UE4SS-settings.ini") -Destination $GameWin64Dir -Force
Copy-Item -LiteralPath (Join-Path $UE4SSRoot "Mods") -Destination (Join-Path $GameWin64Dir "Mods") -Recurse -Force

Write-Host "Installed UE4SS into $GameWin64Dir"
