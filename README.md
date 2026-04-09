# WarTorn ModKit

This repo is the working home for `War-Torn` modding in `UE 4.27`.

It is meant to be the editable side of the workflow: the place where you build maps, vehicle experiments, and Blueprint logic mods. The unpacked game files under `War-Torn_decomp` are still important, but they are best treated as reference material. They are cooked game assets, not a friendly source project.

If you want the actual mod-making workflow after setup, start with [Docs/ModMaking.md](Docs/ModMaking.md).

## What This Repo Is For

Use this project when you want to:

- open a safe editable `UE 4.27` project
- cook and repack test mods
- deploy Blueprint logic mods into the live game
- keep reverse-engineering notes, helper scripts, and experiments together

## What You Need Installed

You do not need every tool open all the time, but this is the core stack:

- `Unreal Engine 4.27`
- `FModel`
- `UAssetGUI`
- `UE4SS`
- `UnrealPak.exe`
- the extracted or installed `War-Torn` game files

The helper scripts currently assume this default engine path:

- Engine root: `C:\EpicGames_games\UE_4.27`

Other paths should be passed in explicitly or supplied through environment variables. That keeps this repo portable and avoids baking personal machine paths into versioned files.

## Repo Layout

The folders you will touch most are:

- `Content`
  - your editable Unreal assets for maps, vehicles, and Blueprint mods
- `Deploy`
  - mod-specific deployment templates such as `LogicMods/<ModName>/config.lua`
- `Docs`
  - setup notes, findings, and workflow guides
- `LoosePak`
  - a loose-file staging area for manual pak experiments
- `Scripts`
  - helper scripts for opening the editor, cooking, repacking, deploying, and log watching

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
  -GameWin64Dir "D:\Games\WarTorn\WarTorn\Binaries\Win64"
```

That copies the UE4SS runtime files and the bundled mod folder into the game so you can inspect actors, read logs, and load Blueprint logic mods.

### 3. Check that the runtime hooks are alive

Open a second PowerShell window and watch the game logs:

```powershell
& ".\Scripts\Watch-GameLogs.ps1"
```

Then:

1. Launch `WarTorn-Win64-Shipping.exe`
2. load into a real map
3. make sure new lines appear in `UE4SS.log`

If you do not want to pass `-GameRoot` every time, set an environment variable first:

```powershell
$env:WARTORN_GAME_ROOT = "D:\Games\WarTorn\WarTorn"
```

Useful hotkeys while testing:

- `Insert` reloads Blueprint logic mods
- `Ctrl+F4` writes a class-count snapshot
- `Ctrl+F5` writes detailed live `Car_C` and `FlyingPawn_C` info
- `Ctrl+F6` writes deeper component and movement info
- `Ctrl+F7` inspects the actor under your crosshair

If you want the longer version of that process, read [Docs/UE4SS-FirstRun.md](Docs/UE4SS-FirstRun.md).

### 4. Build and deploy the first test mod

The starter Blueprint logic mod in this repo is `WTSpawnTest`. Its job is simple: prove that your cooked pak loads into the live game and that your `ModActor` actually runs.

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

For the full walkthrough, use [Docs/WTSpawnTest-Guide.md](Docs/WTSpawnTest-Guide.md).

## Quick Commands

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

## Other Docs

- [Docs/ModMaking.md](Docs/ModMaking.md)
- [Docs/WarTorn-Reference.md](Docs/WarTorn-Reference.md)
- [Docs/ActorDump-Analysis.md](Docs/ActorDump-Analysis.md)
- [Docs/UE4SS-FirstRun.md](Docs/UE4SS-FirstRun.md)
- [Docs/WTSpawnTest-Guide.md](Docs/WTSpawnTest-Guide.md)

## Reality Check

A few constraints are worth keeping in mind from the start:

- New maps have to exist on the server and on every client.
- New drivable vehicles are much harder than maps because they depend on replicated gameplay logic, seat setup, wheel setup, and runtime spawn/control paths.
- The extracted game files are reference material, not a complete editable source project.
- The safest first vehicle target is a variant of the existing car framework, not a fully original vehicle from scratch.
