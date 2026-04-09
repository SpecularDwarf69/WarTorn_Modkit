# WarTorn ModKit

This repository is a clean `UE 4.27` mirror project for building `War-Torn` mods.

It is not the extracted game project. The files under `War-Torn_decomp` are cooked runtime assets and metadata. Use those cooked files for reference, discovery, and reverse-engineering. Build new content in this project.

## What This Repo Is For

- opening a safe editable `UE 4.27` project
- cooking and repacking test mods
- deploying Blueprint logic mods into the live game
- keeping notes, helper scripts, and reverse-engineering findings in one place

If you want the actual mod-making workflow, read [Docs/ModMaking.md](Docs/ModMaking.md).

## Requirements

- `Unreal Engine 4.27`
- `FModel`
- `UAssetGUI`
- `UE4SS`
- `UnrealPak.exe`
- the extracted or installed `War-Torn` game files

Local paths used by the helper scripts by default:

- Engine root: `C:\EpicGames_games\UE_4.27`
- UE4SS root: `C:\Tools\UE4SS_v3.0.1`
- Game root: `C:\Users\ukuto\Desktop\Projects\War-Torn_decomp\War-Torn_Remastered.v35.9\WarTorn`

If your paths differ, pass them explicitly to the scripts with `-EngineRoot`, `-UE4SSRoot`, `-GameRoot`, or `-GameWin64Dir`.

## Repo Layout

- `Content`
  - editable Unreal assets for maps, vehicles, and Blueprint mods
- `Deploy`
  - mod-specific deployment templates such as `LogicMods/<ModName>/config.lua`
- `Docs`
  - setup notes, reverse-engineering notes, and modding guides
- `LoosePak`
  - loose-file staging area for manual pak builds
- `Scripts`
  - helper scripts for editor launch, cooking, repacking, deployment, and log watching

## First-Time Setup

### 1. Open the project

From the repo root:

```powershell
& ".\Scripts\Open-Editor.ps1"
```

If Unreal is installed somewhere else:

```powershell
& ".\Scripts\Open-Editor.ps1" -EngineRoot "D:\Epic Games\UE_4.27"
```

### 2. Install UE4SS into the game

Point the installer at the live game's `Binaries\Win64` folder:

```powershell
& ".\Scripts\Install-UE4SS.ps1" `
  -GameWin64Dir "C:\Users\ukuto\Desktop\Projects\War-Torn_decomp\War-Torn_Remastered.v35.9\WarTorn\Binaries\Win64"
```

This copies:

- `UE4SS.dll`
- `dwmapi.dll`
- `UE4SS-settings.ini`
- the UE4SS `Mods` folder

### 3. Verify the runtime hooks

Open a second PowerShell window and watch the live logs:

```powershell
& ".\Scripts\Watch-GameLogs.ps1"
```

Then:

1. Launch `WarTorn-Win64-Shipping.exe`
2. load into a real map
3. confirm new lines appear in `UE4SS.log`

Useful runtime helper keys:

- `Insert` reloads Blueprint logic mods
- `Ctrl+F4` writes a class-count snapshot
- `Ctrl+F5` writes detailed live `Car_C` and `FlyingPawn_C` info
- `Ctrl+F6` writes deeper component and movement info
- `Ctrl+F7` inspects the actor under your crosshair

See [Docs/UE4SS-FirstRun.md](Docs/UE4SS-FirstRun.md) for more context.

### 4. Build and deploy the first Blueprint logic mod

The included starter test mod is `WTSpawnTest`.

Cook the project:

```powershell
& ".\Scripts\Cook-Win64.ps1"
```

Repack the cooked Blueprint logic mod so it mounts under `WarTorn/...`:

```powershell
& ".\Scripts\Repack-BPLogicMod.ps1" -ModName WTSpawnTest
```

Deploy it into the game's `Content\Paks\LogicMods` folder:

```powershell
& ".\Scripts\Deploy-BPLogicMod.ps1" -ModName WTSpawnTest -CopyConfig
```

See [Docs/WTSpawnTest-Guide.md](Docs/WTSpawnTest-Guide.md) for the full walkthrough.

## Common Commands

Open the editor:

```powershell
& ".\Scripts\Open-Editor.ps1"
```

Cook the project:

```powershell
& ".\Scripts\Cook-Win64.ps1"
```

Build a patch pak from `LoosePak`:

```powershell
& ".\Scripts\Pack-LoosePak.ps1"
```

Repack a Blueprint logic mod:

```powershell
& ".\Scripts\Repack-BPLogicMod.ps1" -ModName WTSpawnTest
```

Deploy a Blueprint logic mod:

```powershell
& ".\Scripts\Deploy-BPLogicMod.ps1" -ModName WTSpawnTest -CopyConfig
```

Watch runtime logs:

```powershell
& ".\Scripts\Watch-GameLogs.ps1"
```

## Existing Reference Docs

- [Docs/ModMaking.md](Docs/ModMaking.md)
- [Docs/WarTorn-Reference.md](Docs/WarTorn-Reference.md)
- [Docs/ActorDump-Analysis.md](Docs/ActorDump-Analysis.md)
- [Docs/UE4SS-FirstRun.md](Docs/UE4SS-FirstRun.md)
- [Docs/WTSpawnTest-Guide.md](Docs/WTSpawnTest-Guide.md)

## Important Limits

- New maps must exist on the server and all clients.
- New drivable vehicles are harder than maps because they depend on replicated gameplay logic, seat setup, wheel setup, and runtime spawn/control paths.
- Cooked game assets are reference material, not a full editable source project.
- A safe first vehicle target is a variant of the existing car framework, not a fully original vehicle from zero.
