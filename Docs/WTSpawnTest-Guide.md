# WTSpawnTest Guide

`WTSpawnTest` is the tiny smoke-test Blueprint mod that ships with this repo.

It is not meant to be impressive at all. Its whole job is to answer one question: "Does the cooked Blueprint logic mod path still work on this setup?"

## What it proves

If `WTSpawnTest` works, you know:

- your cook step worked
- the repacked mod mounts under the right path
- `BPModLoader` found the asset
- the `ModActor` made it into the live world
- your Blueprint logic is actually running

For a very small mod, it clears up a surprising amount of uncertainty.

## Files involved

- project: `<repo-root>\WarTorn_ModKit.uproject`
- deploy script: `<repo-root>\Scripts\Deploy-BPLogicMod.ps1`
- repack script: `<repo-root>\Scripts\Repack-BPLogicMod.ps1`
- log watcher: `<repo-root>\Scripts\Watch-GameLogs.ps1`
- config template: `<repo-root>\Deploy\LogicMods\WTSpawnTest\config.lua`
- live game folder: `<game-root>\Content\Paks\LogicMods`

## Expected asset path

If the pak is named `WTSpawnTest.pak`, `BPModLoader` will look for:

- asset path: `/Game/Mods/WTSpawnTest/ModActor`
- generated class: `ModActor_C`

So in the editor, the asset should be:

- `Content/Mods/WTSpawnTest/ModActor`

## In the editor

1. Open the project with `Scripts\Open-Editor.ps1`.
2. Create `Content/Mods/WTSpawnTest` if it does not already exist.
3. Create a Blueprint Class based on `Actor`.
4. Name it `ModActor`.

## Blueprint setup

Create two Blueprint functions on `ModActor`:

- `PreBeginPlay`
- `PostBeginPlay`

`BPModLoader` looks for those exact names.

### Suggested `PreBeginPlay`

Keep it simple:

1. `Print String`
2. text: `WTSpawnTest PreBeginPlay`
3. duration: `10`

### Suggested `PostBeginPlay`

Again, keep it obvious and boring:

1. `Print String`
2. text: `WTSpawnTest PostBeginPlay`
3. duration: `10`

If you want one extra confirmation, add:

1. `Get Current Level Name`
2. `Print String`

That way you know the mod loaded and which map it attached to without having to guess.

## Cook

From the repo root:

```powershell
& ".\Scripts\Cook-Win64.ps1"
```

## Repack

The cooked project pak needs to be repacked so it mounts under `WarTorn/...` instead of the mirror project root.

```powershell
& ".\Scripts\Repack-BPLogicMod.ps1" -ModName WTSpawnTest
```

## Deploy

```powershell
& ".\Scripts\Deploy-BPLogicMod.ps1" -ModName WTSpawnTest -CopyConfig
```

That script will:

- prefer `Build\Paks\WTSpawnTest.pak` if it already exists
- otherwise use the newest cooked pak it can find
- copy it into `WarTorn\Content\Paks\LogicMods\WTSpawnTest.pak`
- optionally copy the config template too

## Test loop

In another PowerShell window:

```powershell
& ".\Scripts\Watch-GameLogs.ps1"
```

Then:

1. launch the game
2. load into a real map
3. look for the `Print String` output from `PreBeginPlay` and `PostBeginPlay`
4. if you need to reload logic mods in a live session, press `Insert`
5. check `UE4SS.log` and `WTDebugHelper.log` if the Blueprint output is not obvious

## Useful helper hotkeys while testing

- `Insert`
  - reload Blueprint logic mods
- `Ctrl+F4`
  - class-count snapshot
- `Ctrl+F5`
  - detailed live vehicle inspection
- `Ctrl+F6`
  - deeper component dump
- `Ctrl+F7`
  - inspect the actor under your crosshair

## After it works

Once `WTSpawnTest` is reliable, I would not immediately make it bigger. The better next step is to make it more useful:

- detect the current world
- log more useful state
- spawn helper actors from Blueprint
- prototype simple rules or world-side logic

That is the point where it stops being a smoke test and starts being the base for a real mod.
