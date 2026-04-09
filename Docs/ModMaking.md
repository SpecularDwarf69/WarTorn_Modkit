# Mod Making Guide

This guide is the practical workflow for making `War-Torn` mods with this repo.

Use [../README.md](../README.md) for install and setup. Use this document once the toolchain is already working.

## The Three Mod Types

In this project, there are three realistic kinds of mods:

1. `Map content mods`
2. `Blueprint logic mods` loaded through `BPModLoader`
3. `Vehicle content mods`

You can combine them in one mod, but each one has a different workflow and different technical blockers.

## 1. Map Mods

### What a War-Torn map seems to need

From the live dumps and extracted references, real maps are not just geometry. They rely on placed gameplay actors such as:

- `PlayerStart`
- `Spawn_C`
- `NavMeshBoundsVolume`
- `RecastNavMesh`
- `ObjectiveSpawn_C`
- `SpawnWalls_C`
- `StaticTurretSpawn_C`
- optional weather, AI, loot, or target spawners

Reference notes:

- [WarTorn-Reference.md](WarTorn-Reference.md)
- [ActorDump-Analysis.md](ActorDump-Analysis.md)

### Good first map target

Start with a small test or training map, not a full production battlefield.

Recommended first goals:

- one valid `PlayerStart`
- one valid `Spawn_C` equivalent setup
- navmesh that builds correctly
- simple terrain or blockout geometry
- one or two test props or mounted weapons

### Suggested workflow

1. Build or block out the level in `Content/Maps/WT_TestRange`.
2. Copy the actor pattern of `Range` instead of guessing.
3. Cook with `Scripts/Cook-Win64.ps1`.
4. If you need a manual patch pak, stage files under `LoosePak/WarTorn/...` and run `Scripts/Pack-LoosePak.ps1`.
5. Test in the live game with log watching enabled.

## 2. Blueprint Logic Mods

`BPModLoader` gives you a way to inject runtime Blueprint logic without replacing the entire game.

### Required asset layout

If your mod pak is named `WTSpawnTest.pak`, `BPModLoader` expects:

- asset path: `/Game/Mods/WTSpawnTest/ModActor`
- generated class: `ModActor_C`

That means the asset should live in:

- `Content/Mods/WTSpawnTest/ModActor`

### Starter workflow

The included starter mod is `WTSpawnTest`.

Use it to prove:

- your cooked pak mounts
- `BPModLoader` finds the Blueprint
- `PreBeginPlay` runs
- `PostBeginPlay` runs

Detailed walkthrough:

- [WTSpawnTest-Guide.md](WTSpawnTest-Guide.md)

### Why this matters

Blueprint logic mods are the easiest way to bridge the gap between:

- map content you build in the editor
- runtime actors that War-Torn normally spawns by command or game logic

This is especially useful for:

- map-side helper spawning
- debugging the current world
- vehicle experiments
- inspecting live actor classes

## 3. Vehicle Mods

### What we know about the stock car

Live inspection showed the stock drivable car is:

- class: `/Game/Blueprints/Vehicles/Car.Car_C`
- based on `WheeledVehicleMovementComponent4W`
- using `VehicleComponent_C`
- using seat data and a turret child actor
- replicated as server-authoritative gameplay logic

That means a drivable vehicle is more than a mesh swap. It needs:

- a skeletal mesh
- wheel bones
- a physics asset
- wheel blueprints
- a vehicle blueprint
- seat and control logic
- a valid runtime spawn path

### Easiest vehicle path

The safest first vehicle mod is a `car derivative`, not a fully new system.

Recommended order:

1. reuse the stock car framework
2. replace or adapt the visible mesh
3. keep the stock wheel and seat logic at first
4. only then move toward full custom handling

### Using Fab vehicles

If you use a Fab vehicle pack, treat it as a `donor asset pack`, not a drop-in War-Torn gameplay system.

Best use of a Fab vehicle:

- import its skeletal mesh
- inspect its skeleton and wheel placement
- reuse or adapt its art and rig
- rebuild the gameplay side around War-Torn's existing car framework

Do not assume the donor pack's own vehicle Blueprint logic will match War-Torn's runtime systems.

### Using Blender

If you are preparing a custom drivable car in Blender, the working pattern is:

- one root/chassis bone
- four wheel bones centered in the wheel hubs
- all wheel bones parented to the root
- body weighted to the root
- each wheel weighted to its own wheel bone

For `UE 4.27`, export the rigged vehicle as `FBX`, then import it into Unreal as a `Skeletal Mesh`.

### Static mesh props versus drivable vehicles

A parked prop car and a drivable car are different things.

- `Static mesh prop`
  - easy to place in maps
  - no wheel bones
  - no vehicle movement
- `Drivable vehicle`
  - requires the full skeletal vehicle pipeline
  - requires runtime logic compatibility

If you only want scenery, a static mesh prop is enough. If you want real driving, build for the drivable path from the start.

## Recommended Development Order

If you are starting from zero, this is the least painful sequence:

1. confirm UE4SS and `WTSpawnTest` still work
2. make a tiny map edit or test map
3. make a simple prop or static placement mod
4. clone the stock car workflow
5. swap in a new donor vehicle mesh
6. only after that try a full custom vehicle

## Repo Folders You Will Touch Most

- `Content/Maps`
- `Content/Mods`
- `Content/Vehicles`
- `Deploy/LogicMods`
- `Scripts`
- `Docs`

## Useful Companion Docs

- [WarTorn-Reference.md](WarTorn-Reference.md)
- [ActorDump-Analysis.md](ActorDump-Analysis.md)
- [UE4SS-FirstRun.md](UE4SS-FirstRun.md)
- [WTSpawnTest-Guide.md](WTSpawnTest-Guide.md)
