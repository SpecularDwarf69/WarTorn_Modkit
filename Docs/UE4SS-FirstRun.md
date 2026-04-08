# UE4SS First Run

UE4SS has been installed to:

- `C:\Users\ukuto\Desktop\Projects\War-Torn_decomp\War-Torn_Remastered.v35.9\WarTorn\Binaries\Win64`

## Enabled mods

- `ActorDumperMod`
- `ConsoleCommandsMod`
- `ConsoleEnablerMod`
- `BPModLoaderMod`
- `BPML_GenericFunctions`
- `CheatManagerEnablerMod`

## First launch goal

Use the live game to confirm that UE4SS injects correctly and to inspect actors in a loaded level.

## Actor dump hotkey

- `Ctrl+Num3`

The bundled `ActorDumperMod` script iterates the current `Level.Actors` array and prints each actor address and full class/object name.

## What to do

1. Launch `WarTorn-Win64-Shipping.exe`.
2. Load into a real map, not just the menu.
3. Press `Ctrl+Num3`.
4. Watch the UE4SS output window or log output for actor names.

## What to look for

- `PlayerStart`
- spawn blueprints
- objective actors
- vehicle actors
- turrets
- navigation-related actors

## Why this matters

This is the fastest way to confirm the real actor classes placed in stock maps before recreating them in the mirror UE 4.27 mod project.
