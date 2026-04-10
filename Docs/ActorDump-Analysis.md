# Actor Dump Analysis

This is basically AI notes from looking through `ActorDump.txt`.

Source file:

- `<game-root>\Binaries\Win64\ActorDump.txt`

The dump keeps appending new sessions, so it is easy for it to turn into a mess if you do not keep track of which map you were in.

## Sessions that was looked at

- `MainMenu`: 14 actors
- `ShootingRange/Range`: 826 actors
- `ShootingRange/Sauvere`: 1233 to 1234 actors

## Core stuff that keeps showing up

These were in the playable maps that were checked and are probably part of the minimum real level setup:

- `WorldSettings`
- `FirstPersonGameMode_C`
- `FirstPersonGameState_C`
- `FirstPersonPlayerController_C`
- `FirstPersonPlayerState_C`
- `Player_C`
- `PlayerStart`
- `Spawn_C`
- `NavMeshBoundsVolume`
- `RecastNavMesh`
- `GameSession`
- `GameNetworkManager`
- `ParticleEventManager`

What that tells:

- playable maps are not just geometry
- `Spawn_C` matters a lot
- `PlayerStart` still exists, but War-Torn seems to lean on its own spawn helpers too

So if you are rebuilding a map, copying the stock gameplay actor pattern is probably smarter than guessing.

## `Range`

Observed world:

- `/Game/Maps/ShootingRange/Range.Range`

Stuff that stood out:

- `BP_AIKillhouseSpawn_C` x63
- `BP_AIKillhouseSpawner_C` x2
- `BP_RotatingTarget_C` x44
- `StaticTurretSpawn_C` x9
- `PlayerStart` x1
- `Spawn_C` x1
- `NavMeshBoundsVolume` x1
- `RecastNavMesh` x1
- `FirstPersonGameMode_C` x1
- `FirstPersonGameState_C` x1
- `FirstPersonPlayerController_C` x1
- `BP_WeatherManager_C` x1

Mounted weapon related classes:

- `StaticTurretSpawn_C`
- `AGS30Turret_C`
- `AGS30TurretGun_C`
- `AGS30IronsTurret_C`
- `AGS30IronsTurretGun_C`
- `AGS30SuppressedTurret_C`
- `AGS30IronsSuppressedTurretGun_C`
- `DShKTurret_C`
- `DShKTurretGun_C`
- `DShKMTurret_C`
- `DShKMTurretGun_C`
- `PKMTurret_C`
- `PKMTurretGun_C`
- `PKMSmallboxTurret_C`
- `PKMSmallBoxTurretGun_C`
- `Type54Turret_C`
- `Type54TurretGun_C`
- `W85Turret_C`
- `W85TurretGun_C`

AI's read on it:

- `Range` is pretty blueprint-heavy
- targets and AI are driven by placed helpers, not just map scripting magic
- mounted guns are not just dropped in as meshes
- `StaticTurretSpawn_C` looks like the thing the map places, then the actual turret/gun actors hang off that

So if you want to make a simple test map, `Range` is probably the best map to copy from first.

## `Sauvere`

Observed world:

- `/Game/Maps/ShootingRange/Sauvere.Sauvere`

Stuff that stood out:

- `BattleRoyaleLootSpawn_C` x112
- `Spawn_C` x30
- `SpawnWalls_C` x28
- `ObjectiveSpawn_C` x13
- `NavModifierVolume` x31
- `PlayerStart` x1
- `NavMeshBoundsVolume` x1
- `RecastNavMesh` x1
- `FirstPersonGameMode_C` x1
- `FirstPersonGameState_C` x1
- `FirstPersonPlayerController_C` x1
- `BP_WeatherManager_C` x1

What that suggests:

- this map is doing way more than `Range`
- it looks like multiple gameplay layers are supported through placed actors
- `ObjectiveSpawn_C` and `SpawnWalls_C` look important for objective flow
- `BattleRoyaleLootSpawn_C` points to BR or free-loot support
- the bigger `Spawn_C` count fits a real multiplayer map a lot more than a little training area

So if you are trying to make an objective map, `Sauvere` is a better reference than `Range`.

## What this means for modding

## New map

For a training map or test map, I would copy the simpler pattern:

- `PlayerStart`
- `Spawn_C`
- `NavMeshBoundsVolume`
- `RecastNavMesh`
- optional target spawners
- optional turret spawn helpers

For a more serious objective map, I would start looking harder at:

- multiple `Spawn_C`
- `SpawnWalls_C`
- `ObjectiveSpawn_C`
- bigger nav setup

## New mounted weapon

This looks a lot more doable than a fully custom drivable vehicle.

The main thing I would copy is:

- map places `StaticTurretSpawn_C`
- runtime ends up with turret and gun actors from that

That is a much easier target than trying to force a custom car into the game.

## New drivable vehicle

Neither `Range` nor `Sauvere` showed obvious placed drivable vehicles in the normal dump.

That lines up with the other thing I kept running into:

- the car seems more runtime-spawned than map-placed
- the vehicle side is more coupled to game logic than static turrets are

So I would treat drivable vehicles as runtime/gameplay work, not normal map-content work.

## Vehicle spawning note

The extracted `FirstPersonPlayerController` data references things like:

- `/Game/Blueprints/Vehicles/Car`
- `ExecuteConsoleCommand`
- `BeginDeferredActorSpawnFromClass`
- `FinishSpawningActor`
- `ExitVehicleServer`
- other spawn-related strings

That matches what it felt like in testing:

- the car is probably spawned through a command or game path not just placed in the map and left there

Practical takeaway:

a future custom vehicle probably needs:

- a valid vehicle blueprint
- a real server-authoritative spawn path
- some way to hook or copy the stock flow instead of raw spawning

## Runtime-spawned actors that did show up later

In a later `Sauvere` dump where spawned vehicles were present, these showed up:

- `Car_C`
- `FlyingPawn_C`
- `AIController`
- `Turret_C`

That tells:

- the car is definitely a real runtime actor class
- the plane is its own actor too, not just a prop
- extra supporting actors seem to come along with some of these runtime spawns

So yeah, vehicles in War-Torn look a lot more like live gameplay systems than normal placed map actors.
