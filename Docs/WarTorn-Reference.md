# War-Torn Reference

This is the short reference sheet to keep coming back to while working in the repo.

It is not a full reverse-engineering dump. It is just the set of paths and classes that keep being useful.

## Project defaults

- game instance: `/Game/Blueprints/Player/WTGameInstance.WTGameInstance_C`
- default menu map: `/Game/Maps/MainMenu.MainMenu`
- default server map: `/Game/Maps/Qarya/Qarya.Qarya`
- default game mode: `/Game/Blueprints/Player/FirstPersonGameMode.FirstPersonGameMode_C`

## Map-side gameplay actors

- player spawn: `/Game/Blueprints/Player/Spawn`
- Battle Royale loot spawn: `/Game/Blueprints/Items/BattleRoyale/BattleRoyaleLootSpawn`
- bomb spawn: `/Game/Blueprints/Items/Bomb/BombSpawn`
- CTF flag spawn 1: `/Game/Blueprints/Items/CTF/FlagSpawn1`
- CTF flag spawn 2: `/Game/Blueprints/Items/CTF/FlagSpawn2`
- CTF dropoff 1: `/Game/Blueprints/Items/CTF/FlagDropOff1`
- CTF dropoff 2: `/Game/Blueprints/Items/CTF/FlagDropOff2`
- objective spawn: `/Game/Blueprints/Items/Objective/ObjectiveSpawn`
- spawn walls: `/Game/Blueprints/Items/MasterItems/SpawnWalls`
- static turret spawn helper: `/Game/Maps/StaticTurretSpawn`
- weather manager: `/Game/Maps/BP_WeatherManager`

## Useful stock map references

These are the maps I would copy from before I started guessing:

- `/Game/Maps/Qarya/Qarya`
- `/Game/Maps/QaryaObj`
- `/Game/Maps/ShootingRange/Range`

## Vehicle assets

- main vehicle blueprint: `/Game/Blueprints/Vehicles/Car`
- vehicle component: `/Game/Blueprints/Vehicles/VehicleComponent`
- vehicle interface: `/Game/Blueprints/Vehicles/VehicleInterface`
- vehicle seat struct: `/Game/Blueprints/Vehicles/VehicleSeat`
- front wheel: `/Game/Blueprints/Vehicles/Vehicle_FrontWheel`
- back wheel: `/Game/Blueprints/Vehicles/Vehicle_BackWheel`
- tire data: `/Game/Blueprints/Vehicles/TireData`
- turret base: `/Game/Blueprints/Vehicles/Turrets/Turret`

## Flying assets

- flying pawn: `/Game/FlyingBP/Blueprints/FlyingPawn`
- plane support blueprint: `/Game/Blueprints/Guns/FireSupports/PlaneSupport`

## Sedan reference assets

- skeletal mesh: `/Game/VehicleBP/Sedan/Sedan/Sedan_SkelMesh`
- skeleton: `/Game/VehicleBP/Sedan/Sedan/Sedan_Skeleton`
- physics asset: `/Game/VehicleBP/Sedan/Sedan/Sedan_PhysicsAsset`
- physical material: `/Game/VehicleBP/Sedan/Sedan/Sedan_PhysMat`
- anim BP: `/Game/VehicleBP/Sedan/Sedan/Sedan_AnimBP`

## Practical takeaways

- maps are mostly world geometry plus placed gameplay blueprints
- vehicles are using the PhysX vehicle stack here, not a simple prop workflow
- runtime drivable/flyable actors appear to share the same seat and vehicle component framework

If you need more context than this sheet gives you, go to:

- [ActorDump-Analysis.md](ActorDump-Analysis.md)
- `UE4SS.log`
- the extracted assets in `War-Torn_decomp`
