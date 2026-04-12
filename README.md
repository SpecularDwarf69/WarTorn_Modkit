# WarTorn ModKit

This repo was the editable side of my `War-Torn` modding setup.

The decompiled game files are still useful, but they are cooked game content and kind of miserable to treat like a real source project. This repo is the part that was actually meant to be worked in: maps, Blueprint mods, helper scripts, notes, and random UE4SS experiments.

If you just want the practical modding workflow, start with [Docs/ModMaking.md](Docs/ModMaking.md).

The game and download is [here](https://kingoftheend.itch.io/war-torn).
It was made for War-Torn v35.9. I don't know if later versions work with it.

## Project Status

This repo is very likely abandoned now.

I have other stuff to do and I do not really have the interest to keep pushing this project forward. I am leaving it up because there is still some value in it as:

- a reference for War-Torn asset paths, actor layouts, and runtime notes
- a base for anyone who wants to keep experimenting with maps, Blueprint mods, or UE4SS tooling
- a record of what already worked, what partly worked, and what turned out to be unstable

I wouldn't treat this as an actively maintained toolkit/idea anymore. But I still think it is useful enough to keep around in case someone wants to pick it up later.

## Current State

It's useful for debugging, it has the support/mods to run commands from the admin menu.

What is still rough:

 - almost everything

## What Is In Here

- `Content`
  - editable Unreal assets for maps, props, Blueprint mods, and experiments
- `Deploy`
  - deployment templates for logic mods and UE4SS mods
- `Docs`
  - workflow notes, findings, references, and setup guides
- `LoosePak`
  - loose-file staging for manual patch pak experiments
- `Scripts`
  - PowerShell helpers for opening the editor, cooking, repacking, deploying, and watching logs

## What You Need Installed

This is the toolstack the repo expects:

- `Unreal Engine 4.27`
- `UE4SS`
- `UnrealPak.exe`
- `FModel`
- `UAssetGUI`
- an installed or extracted copy of `War-Torn`

By default the scripts expect Unreal here:

- `C:\EpicGames_games\UE_4.27`

If your engine lives somewhere else, most scripts let you pass a path in directly.

## Quick Start

### 1. Open the project

```powershell
& ".\Scripts\Open-Editor.ps1"
```

If you need to point at a different engine install:

```powershell
& ".\Scripts\Open-Editor.ps1" -EngineRoot "D:\Epic Games\UE_4.27"
```

### 2. Install UE4SS into the live game

Point the installer at the game's `Binaries\Win64` folder:

```powershell
& ".\Scripts\Install-UE4SS.ps1" `
  -GameWin64Dir "D:\Games\WarTorn\WarTorn\Binaries\Win64"
```

### 3. Confirm the runtime hooks are alive

In another PowerShell window:

```powershell
& ".\Scripts\Watch-GameLogs.ps1"
```

Then:

1. Launch `WarTorn-Win64-Shipping.exe`
2. Load into a real map
3. Check that `UE4SS.log` starts moving

If you do not want to keep passing the game path around, set:

```powershell
$env:WARTORN_GAME_ROOT = "D:\Games\WarTorn\WarTorn"
```

### 4. Build the first test mod

The starter Blueprint logic mod in this repo is `WTSpawnTest`.

Cook:

```powershell
& ".\Scripts\Cook-Win64.ps1"
```

Repack:

```powershell
& ".\Scripts\Repack-BPLogicMod.ps1" -ModName WTSpawnTest
```

Deploy:

```powershell
& ".\Scripts\Deploy-BPLogicMod.ps1" -ModName WTSpawnTest -CopyConfig
```

That is the quickest end-to-end test that proves the editable project, the cook step, and the in-game logic-mod path are all working together.

## Useful Runtime Hotkeys

These come from the bundled helper mods and are handy while testing:

- `Insert`
  - reload Blueprint logic mods
- `Ctrl+F4`
  - class-count snapshot
- `Ctrl+F5`
  - live `Car_C` and `FlyingPawn_C` inspection
- `Ctrl+F6`
  - deeper vehicle/component dump
- `Ctrl+F7`
  - inspect the actor under your crosshair

## Most useful post-install commands

Open the editor:

```powershell
& ".\Scripts\Open-Editor.ps1"
```

Cook the project:

```powershell
& ".\Scripts\Cook-Win64.ps1"
```

Build a loose patch pak:

```powershell
& ".\Scripts\Pack-LoosePak.ps1"
```

Deploy a UE4SS Lua mod from this repo:

```powershell
& ".\Scripts\Deploy-UE4SSMod.ps1" `
  -GameWin64Dir "D:\Games\WarTorn\WarTorn\Binaries\Win64" `
  -ModName WTConsoleTools
```

Deploy a Blueprint logic mod:

```powershell
& ".\Scripts\Deploy-BPLogicMod.ps1" -ModName WTSpawnTest -CopyConfig
```

Watch runtime logs:

```powershell
& ".\Scripts\Watch-GameLogs.ps1"
```

## Recommended Reading Order

If you are new to the repo, this is the order I would read things:

1. [Docs/ModMaking.md](Docs/ModMaking.md)
2. [Docs/WTSpawnTest-Guide.md](Docs/WTSpawnTest-Guide.md)
3. [Docs/UE4SS-FirstRun.md](Docs/UE4SS-FirstRun.md)
4. [Docs/WarTorn-Reference.md](Docs/WarTorn-Reference.md) very technical
5. [Docs/ActorDump-Analysis.md](Docs/ActorDump-Analysis.md) very technical
6. [Docs/WTConsoleTools-Guide.md](Docs/WTConsoleTools-Guide.md)

## Notes

A few honest expectations:

- New maps are realistic.
- Blueprint logic mods are realistic.
- Vehicle variants are possible, but the runtime side is not implemented messy. (the spawning isn't working)
- A true "brand new game mode" is much harder than it sounds.
- The extracted game files are reference material, not a complete editable source tree.

This repo can still help someone, but it is not a clean modkit/SDK and it definitely is not finished.

## If You Want To Continue It

If somebody else ends up continuing this, this is where I would start:

1. make sure the basic `WTSpawnTest` cook and load path still works
2. verify the UE4SS helper mods still load cleanly on the current game build
3. treat the docs in `Docs/` as field notes, not gospel
4. focus on maps and Blueprint logic first
5. leave vehicle spawning and deeper runtime hooks for last

The repo makes more sense as a reference base than anything else. If you do keep going with it, I think the best approach is to tighten one path at a time.


## NB! A bunch of code was written or improved by AI, the dumps and some other stuff was also written and analyzed by AI.

# License

Unless a file says otherwise, the original code, scripts, docs, and original project files in this repo are licensed under `GPL-3.0-only`.

That is intentional. If someone builds on the original work from this repo and distributes the result, I want that work to stay open-source too.

Important notice:

- this applies to the stuff I made and can license (so most of the repo)
- it does not grant rights to `War-Torn`, its trademarks, or any extracted/cooked third-party game content
- extracted game files are still reference material, not mine to relicense
