# Mod Making Guide

This is the "what should I actually make first?" guide for the repo.

Use [../README.md](../README.md) for setup. Use this file once the editor, UE4SS, and the live game are already talking to each other.

## Maintenance Note

This repo is probably not getting active development anymore.

The notes are still useful, and I think the project is still a decent starting point if you want to continue the work, but you should assume some parts are incomplete, experimental, or just frozen in whatever state I last left them in.

## The Three Lanes

There are really three modding lanes in this project:

1. map content
2. Blueprint logic mods through `BPModLoader`
3. vehicle content

They can overlap, but they are not equally hard.

If you want the least painful path, start with maps and Blueprint logic. Leave vehicles for later.

## What Is Actually Working Well

At the moment, the most reliable workflow is:

- make or edit a map in the Unreal project
- cook and repack it
- use `WTSpawnTest` or another Blueprint logic mod to prove runtime behavior
- use UE4SS helpers for inspection and debugging

That is enough for stuff like:

- test maps
- training ranges
- simple scenario setups
- debug helpers
- light custom rule logic

## Map Mods

### What a War-Torn map seems to need

Real maps are more than geometry. From the live dumps and extracted references, they tend to rely on actors like:

- `PlayerStart`
- `Spawn_C`
- `NavMeshBoundsVolume`
- `RecastNavMesh`
- `ObjectiveSpawn_C`
- `SpawnWalls_C`
- `StaticTurretSpawn_C`

Useful companion notes:

- [WarTorn-Reference.md](WarTorn-Reference.md)
- [ActorDump-Analysis.md](ActorDump-Analysis.md)

### Good first target

Do not start with a giant battlefield. Start with a test range or a small blockout map.

If your first map has:

- one valid player spawn
- working navmesh
- a couple of gameplay actors
- a clean cook/deploy/test loop

that is already a win.

### Suggested workflow

1. Build the level under `Content/Maps`.
2. Copy patterns from `Range` or another stock map instead of inventing actor layouts from scratch.
3. Cook with `Scripts/Cook-Win64.ps1`.
4. If needed, build a manual patch pak from `LoosePak`.
5. Test in the live game with logs open.

## Blueprint Logic Mods

This is the easiest way to add runtime behavior without replacing the game's whole flow.

### Expected asset layout

If your pak is named `WTSpawnTest.pak`, `BPModLoader` expects:

- asset path: `/Game/Mods/WTSpawnTest/ModActor`
- generated class: `ModActor_C`

So the matching editor asset lives at:

- `Content/Mods/WTSpawnTest/ModActor`

### Why this path matters

Blueprint logic mods are the bridge between static cooked content and runtime behavior.

They are good for:

- map-side helper logic
- debug output
- world detection
- lightweight rule changes
- experiments that do not need native code

The included starter mod is documented here:

- [WTSpawnTest-Guide.md](WTSpawnTest-Guide.md)

### Important reality check

Manual runtime spawning of Blueprint logic actors through helper commands is unstable right now. The safe path is still:

- cook the mod
- let `BPModLoader` load it normally
- use `Insert` if you need to reload logic mods in a live session

## Vehicle Mods

This is the hardest lane in the repo right now.

### What the stock car tells us

Live inspection showed the drivable car is tied into:

- `Car_C`
- `WheeledVehicleMovementComponent4W`
- `VehicleComponent_C`
- seat data
- turret child actors
- server-authoritative gameplay logic

So a drivable vehicle is not just:

- a mesh swap
- four wheels
- a new Blueprint dropped into the game

### Best first vehicle target

Treat the stock car as the framework and build from there.

Recommended order:

1. reuse the stock car setup
2. swap or adapt the visible mesh
3. keep the existing seat and movement logic as long as possible
4. only then start pushing toward a more original vehicle

### Using Fab or other donor assets

Donor vehicle packs are best treated as art sources, not ready-made gameplay systems.

Use them for:

- skeletal meshes
- wheel placement reference
- art direction
- rigging reference

Do not expect their Blueprint gameplay logic to drop straight into War-Torn.

### Static prop versus drivable vehicle

This distinction matters:

- static prop vehicle
  - easy
  - fine for scenery or set dressing
- drivable vehicle
  - much harder
  - depends on runtime systems we are still tracing

If you only need a parked truck or car wreck, do not overbuild it.

## Recommended Development Order

If you are starting from scratch, this order is the least frustrating:

1. get UE4SS working
2. get `WTSpawnTest` loading cleanly
3. make a tiny map edit or a small test map
4. place props or simple gameplay actors
5. add Blueprint helper logic
6. only then start touching vehicles

## If You Are Picking This Up Later

My honest advice is: do not go straight for the flashy stuff.

There is enough here to be useful, but the stable parts and unstable parts are mixed together. If you want to keep building on it, these are probably the safest priorities:

1. keep the editor project healthy
2. keep the cook and repack flow repeatable
3. keep BP mod loading simple and observable
4. use live vehicle inspection as reference, not as proof that runtime spawning is solved

If you treat this repo like a reference-heavy sandbox instead of a finished SDK, it makes a lot more sense.

## Folders You Will Actually Touch

- `Content/Maps`
- `Content/Mods`
- `Content/Vehicles`
- `Deploy/LogicMods`
- `Scripts`
- `Docs`

## Companion Docs

- [WarTorn-Reference.md](WarTorn-Reference.md)
- [ActorDump-Analysis.md](ActorDump-Analysis.md)
- [UE4SS-FirstRun.md](UE4SS-FirstRun.md)
- [WTSpawnTest-Guide.md](WTSpawnTest-Guide.md)
