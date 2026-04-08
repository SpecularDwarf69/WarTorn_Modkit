# WarTorn ModKit

This is a clean UE 4.27 mirror project for building War-Torn mods.

It is not the extracted game project. The unpacked files under `War-Torn_decomp` are cooked reference assets and metadata. Use them for study, naming, and asset path discovery. Build new content here.

## Toolchain

- Engine: `C:\EpicGames_games\UE_4.27`
- Asset browser: `C:\Tools\FModel\FModel.exe`
- Package inspection: `C:\Tools\UAssetGUI.exe`
- Runtime dumping and mod loading: `C:\Tools\UE4SS_v3.0.1`
- Repacking: `C:\EpicGames_games\UE_4.27\Engine\Binaries\Win64\UnrealPak.exe` and `C:\Tools\repack_cli\bin\repak.exe`

## Layout

- `Content/Maps/WT_TestRange`: first map workspace
- `Content/Vehicles/WT_SedanVariant`: first vehicle-variant workspace
- `Docs/WarTorn-Reference.md`: extracted paths and gameplay actor notes
- `LoosePak/WarTorn`: optional loose-file staging area for manual pak experiments
- `Scripts`: helper scripts for editor launch, cooking, UE4SS install, and pak creation

## Recommended workflow

1. Install UE4SS into the real game's `Binaries/Win64` folder.
2. Use UE4SS dumpers and FModel to inspect the live game and the cooked assets.
3. Create your new content in this UE 4.27 project.
4. Cook with `Scripts/Cook-Win64.ps1`.
5. If needed, stage loose files under `LoosePak/WarTorn/...` and build a patch pak with `Scripts/Pack-LoosePak.ps1`.

## Important limits

- New maps must be present on the server and clients.
- New vehicles are harder than maps because they need replication-safe gameplay logic, seat setup, wheel setup, and a valid skeletal vehicle rig.
- A fully original drivable vehicle is a phase-two goal. Start with a variant of the existing sedan/car logic.

## First targets

- Map: a small test/range map that uses the same gameplay actor pattern as the stock maps
- Vehicle: a sedan variant that proves mesh, wheel, seat, and packaging flow

## Commands

Open the project:

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
