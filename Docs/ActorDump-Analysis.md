# Actor Dump Analysis

Source dump:

- `C:\Users\ukuto\Desktop\Projects\War-Torn_decomp\War-Torn_Remastered.v35.9\WarTorn\Binaries\Win64\ActorDump.txt`

## Dump sessions observed

- `MainMenu`: 14 actors
- `ShootingRange/Range`: 826 actors
- `ShootingRange/Sauvere`: 1233 to 1234 actors

The dump file appends new sessions each time the actor dumper runs.

## Recurring core gameplay actors

These showed up across the sampled playable maps and are likely part of the minimum runtime setup for a real level:

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

Interpretation:

- The real playable maps are not just geometry. They rely on placed gameplay blueprints plus the default runtime classes spawned by the game mode.
- `Spawn_C` is the main placed spawn helper to imitate when rebuilding multiplayer maps.
- `PlayerStart` still exists, but the custom `Spawn_C` actors appear to carry the game-specific spawn logic.

## `Range` checklist

Observed world:

- `/Game/Maps/ShootingRange/Range.Range`

Notable classes:

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

Mounted weapon related actors in the map:

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

Interpretation:

- `Range` is a blueprint-heavy training map.
- AI and targets are driven by explicit placed spawners.
- Mounted weapons are not dropped in as raw meshes; the map uses `StaticTurretSpawn_C` helpers that then own or spawn turret child actors and gun actors.

## `Sauvere` checklist

Observed world:

- `/Game/Maps/ShootingRange/Sauvere.Sauvere`

Notable classes:

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

Interpretation:

- `Sauvere` appears to support multiple gameplay layers in one map through placed actors.
- `BattleRoyaleLootSpawn_C` suggests battle-royale or free-loot support.
- `ObjectiveSpawn_C` and many `SpawnWalls_C` suggest objective-mode flow with controlled attack/defense spaces.
- `Spawn_C` count is much higher than in `Range`, which fits a larger multiplayer level rather than a simple training space.
- `NavModifierVolume` usage suggests the level actively shapes navigation in different subareas instead of relying on a single plain nav volume.

## Modding implications

## New map

- Start from a small target map and copy the actor pattern of the stock map closest to your intended mode.
- For a training or test map, `Range` is the best reference because it has fewer systems:
  - `PlayerStart`
  - `Spawn_C`
  - `NavMeshBoundsVolume`
  - `RecastNavMesh`
  - optional `StaticTurretSpawn_C`
  - optional target or AI spawner blueprints
- For an objective map, `Sauvere` is the better reference:
  - multiple `Spawn_C`
  - `SpawnWalls_C`
  - `ObjectiveSpawn_C`
  - large nav setup

## New mounted weapon

- The easiest weapon-style vehicle mod is probably an emplaced gun using the same pattern as the range map.
- The evidence points to `StaticTurretSpawn_C` as the map-facing placement actor, with separate turret and gun actor classes behind it.

## New drivable vehicle

- Neither `Range` nor `Sauvere` showed obvious placed drivable vehicle actors in the dump.
- That supports the earlier conclusion that drivable vehicles are a more code-coupled system than static turrets.
- Treat mounted guns and static spawnable turrets as the easier first "vehicle" mod target.

## Vehicle spawning note

- The extracted `FirstPersonPlayerController` data references `/Game/Blueprints/Vehicles/Car`, `ExecuteConsoleCommand`, `BeginDeferredActorSpawnFromClass`, `FinishSpawningActor`, `ExitVehicleServer`, and several spawn-related strings.
- That strongly supports the in-game observation that the drivable car is spawned by a command rather than being pre-placed in the map.
- Practical implication: a future vehicle mod may not need a placed map actor at all. It may need:
  - a valid vehicle blueprint class
  - a server-authoritative spawn path
  - either a console command, cheat path, or mod hook that calls the same spawn flow
- This makes custom vehicles more like runtime gameplay mods than pure map-content mods.

## Runtime-spawned actors confirmed in dump

In a later `Sauvere` dump with spawned vehicles present, these runtime actors appeared:

- `Car_C`
- `FlyingPawn_C`
- `AIController`
- `Turret_C`

Interpretation:

- The spawned car is the expected runtime vehicle actor class.
- The spawned plane is a separate flying actor class, not just a static mesh.
- The flying actor appears to use the same seat/component framework as vehicles.
- The extra `AIController` and `Turret_C` entries suggest the plane may spawn supporting actors or child actors as part of its runtime setup.
