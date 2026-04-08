# WTSpawnTest Guide

This is the first Blueprint mod to build in the mirror project.

Goal:

- prove that BPModLoader loads your cooked pak
- prove that a custom Blueprint actor can run code in the live game
- establish the path `/Game/Mods/WTSpawnTest/ModActor`

## Files involved

- Project: `C:\Users\ukuto\Desktop\Projects\WarTorn_ModKit\WarTorn_ModKit.uproject`
- Deploy script: `C:\Users\ukuto\Desktop\Projects\WarTorn_ModKit\Scripts\Deploy-BPLogicMod.ps1`
- Log watcher: `C:\Users\ukuto\Desktop\Projects\WarTorn_ModKit\Scripts\Watch-GameLogs.ps1`
- Repack script: `C:\Users\ukuto\Desktop\Projects\WarTorn_ModKit\Scripts\Repack-BPLogicMod.ps1`
- Config template: `C:\Users\ukuto\Desktop\Projects\WarTorn_ModKit\Deploy\LogicMods\WTSpawnTest\config.lua`
- Game LogicMods folder: `C:\Users\ukuto\Desktop\Projects\War-Torn_decomp\War-Torn_Remastered.v35.9\WarTorn\Content\Paks\LogicMods`

## What BPModLoader expects

BPModLoader will load any `.pak` placed in `Content\Paks\LogicMods`.

If the pak is named `WTSpawnTest.pak`, it will look for this Blueprint by default:

- Asset path: `/Game/Mods/WTSpawnTest/ModActor`
- Generated class name: `ModActor_C`

That means the `config.lua` file is helpful but not strictly required as long as you follow the default naming convention.

BPModLoader then:

- spawns your `ModActor`
- calls `PreBeginPlay()` manually if it exists
- waits for normal BeginPlay
- calls `PostBeginPlay()` if it exists

There is also a manual reload key:

- `Insert` reloads Blueprint logic mods

## In the editor

1. Open the project with `Scripts\Open-Editor.ps1`.
2. In the Content Browser, create folder `Mods`.
3. Inside `Mods`, create folder `WTSpawnTest`.
4. Inside `WTSpawnTest`, create a Blueprint Class based on `Actor`.
5. Name it `ModActor`.

The final asset path must be:

- `/Game/Mods/WTSpawnTest/ModActor`

## Blueprint setup

Create two Blueprint functions on `ModActor`:

- `PreBeginPlay`
- `PostBeginPlay`

BPModLoader looks for those names specifically.

### `PreBeginPlay`

Put these nodes in `PreBeginPlay`:

1. `Print String`
2. Text: `WTSpawnTest PreBeginPlay`
3. Duration: `10`

### `PostBeginPlay`

Put these nodes in `PostBeginPlay`:

1. `Print String`
2. Text: `WTSpawnTest PostBeginPlay`
3. Duration: `10`

Optional extra nodes in `PostBeginPlay`:

1. `Get Display Name`
2. `Self`
3. `Print String`

That gives you a visible confirmation that the mod actor exists in the game world.

Recommended first graph:

1. Add a `Print String` with `WTSpawnTest PostBeginPlay`.
2. Add `Get Current Level Name`.
3. Add another `Print String` that includes the level name.

This makes it obvious that the Blueprint loaded in the live game and tells you which map it attached to.

## Cook

From the project root:

```powershell
& ".\Scripts\Cook-Win64.ps1"
```

## Repack

The cooked project pak uses the mirror project root name, which the live game does not resolve correctly for BPModLoader.
Repack the cooked files so they mount under `WarTorn/...` instead:

```powershell
& ".\Scripts\Repack-BPLogicMod.ps1" -ModName WTSpawnTest
```

## Deploy

From the project root:

```powershell
& ".\Scripts\Deploy-BPLogicMod.ps1" -ModName WTSpawnTest -CopyConfig
```

The script will:

- prefer `Build\Paks\WTSpawnTest.pak` if it exists
- otherwise find the newest cooked pak under `Build\Cooked`
- copy it to `WarTorn\Content\Paks\LogicMods\WTSpawnTest.pak`
- copy the config template to `WarTorn\Content\Paks\LogicMods\WTSpawnTest\config.lua`

## Test

First, in a separate PowerShell window, watch the runtime logs:

```powershell
& ".\Scripts\Watch-GameLogs.ps1"
```

1. Launch the game.
2. Load into a map.
3. Look for the `Print String` messages from `PreBeginPlay` and `PostBeginPlay`.
4. If you want to force a reload after the map is already open, press `Insert`.
5. If you want a runtime actor count snapshot, press `Ctrl+F4`.
6. If you want detailed live vehicle info, press `Ctrl+F5`.
7. If you want deep component and filtered property dumps for live vehicles, press `Ctrl+F6`.
8. If you want to inspect the exact prop you are looking at, aim at it and press `Ctrl+F7`.
9. Check `UE4SS.log` and `WTDebugHelper.log` if needed.

## After it works

Once this loads correctly, the next upgrade is:

- add more logging in `PostBeginPlay`
- detect the current world name
- start interacting with runtime-spawned actors such as `Car_C` and `FlyingPawn_C`

## WTDebugHelper inspection keys

The runtime helper at `WarTorn\Binaries\Win64\Mods\WTDebugHelper\Scripts\main.lua` now supports:

- `Ctrl+F4` for a quick class count snapshot
- `Ctrl+F5` for detailed `Car_C` and `FlyingPawn_C` inspection
- `Ctrl+F6` for deep `VehicleComponent`, movement, turret, health, mesh, and controller-linked subobject dumps
- `Ctrl+F7` for a look-at inspector that identifies the exact actor and mesh paths of the prop under your crosshair

`Ctrl+F5` writes:

- actor full name
- class name
- world name
- actor address
- location if a safe getter is available
- rotation if a safe getter is available

`Ctrl+F6` writes:

- the live actor identity again
- reflected details for `VehicleComponent`
- reflected details for movement-related subobjects
- reflected details for turret and health subobjects
- filtered vehicle-relevant properties so the log stays readable

`Ctrl+F7` writes:

- the exact actor under your crosshair
- its class path
- its world name
- its transform
- filtered reflected properties on the actor itself
- filtered reflected properties on likely mesh-bearing subobjects such as `RootComponent`, `Mesh`, `StaticMeshComponent`, and `SkeletalMeshComponent`
