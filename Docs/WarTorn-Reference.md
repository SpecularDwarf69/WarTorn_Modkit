# War-Torn Reference

This note captures the most useful paths found in the extracted game data.

## Project defaults

- Game instance: `/Game/Blueprints/Player/WTGameInstance.WTGameInstance_C`
- Default menu map: `/Game/Maps/MainMenu.MainMenu`
- Default server map: `/Game/Maps/Qarya/Qarya.Qarya`
- Default game mode: `/Game/Blueprints/Player/FirstPersonGameMode.FirstPersonGameMode_C`

## Key map gameplay actors

- Player spawn: `/Game/Blueprints/Player/Spawn`
- Battle Royale loot spawn: `/Game/Blueprints/Items/BattleRoyale/BattleRoyaleLootSpawn`
- Bomb spawn: `/Game/Blueprints/Items/Bomb/BombSpawn`
- CTF flag spawns: `/Game/Blueprints/Items/CTF/FlagSpawn1` and `/Game/Blueprints/Items/CTF/FlagSpawn2`
- CTF dropoffs: `/Game/Blueprints/Items/CTF/FlagDropOff1` and `/Game/Blueprints/Items/CTF/FlagDropOff2`
- Objective spawn: `/Game/Blueprints/Items/Objective/ObjectiveSpawn`
- Spawn walls: `/Game/Blueprints/Items/MasterItems/SpawnWalls`
- Static turret spawn helper: `/Game/Maps/StaticTurretSpawn`
- Weather manager: `/Game/Maps/BP_WeatherManager`

## Map structure clues

- Maps commonly contain `PlayerStart`, `NavMeshBoundsVolume`, `RecastNavMesh`, `Landscape`, and mode-specific blueprint actors.
- Useful reference maps:
  - `/Game/Maps/Qarya/Qarya`
  - `/Game/Maps/QaryaObj`
  - `/Game/Maps/ShootingRange/Range`
  - `/Game/Maps/TestMaps/Test/Dev`

## Vehicle assets

- Main vehicle blueprint: `/Game/Blueprints/Vehicles/Car`
- Vehicle component: `/Game/Blueprints/Vehicles/VehicleComponent`
- Vehicle interface: `/Game/Blueprints/Vehicles/VehicleInterface`
- Vehicle seat: `/Game/Blueprints/Vehicles/VehicleSeat`
- Front wheel: `/Game/Blueprints/Vehicles/Vehicle_FrontWheel`
- Back wheel: `/Game/Blueprints/Vehicles/Vehicle_BackWheel`
- Tire data: `/Game/Blueprints/Vehicles/TireData`
- Turret base: `/Game/Blueprints/Vehicles/Turrets/Turret`

## Flying assets

- Flying pawn: `/Game/FlyingBP/Blueprints/FlyingPawn`
- Plane support blueprint: `/Game/Blueprints/Guns/FireSupports/PlaneSupport`

## Sedan reference assets

- Skeletal mesh: `/Game/VehicleBP/Sedan/Sedan/Sedan_SkelMesh`
- Skeleton: `/Game/VehicleBP/Sedan/Sedan/Sedan_Skeleton`
- Physics asset: `/Game/VehicleBP/Sedan/Sedan/Sedan_PhysicsAsset`
- Physical material: `/Game/VehicleBP/Sedan/Sedan/Sedan_PhysMat`
- Anim BP: `/Game/VehicleBP/Sedan/Sedan/Sedan_AnimBP`

## Practical interpretation

- Maps are mostly world geometry plus placed gameplay blueprints.
- Vehicles use the UE4 PhysXVehicles stack, not Chaos Vehicles as the primary runtime path.
- Runtime-spawned drivable or flyable actors appear to reuse the same `VehicleComponent` and `VehicleSeat` gameplay framework.
