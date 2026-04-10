# UE4SS First Run

This is the first sanity check after installing UE4SS into the live game.

The goal is simple: confirm that the runtime is injected, the helper mods are loading, and you can see real actors from a live map.

## Expected install location

- `<game-root>\Binaries\Win64`

## Mods that should be enabled

At minimum, these are the ones you want to see working:

- `ActorDumperMod`
- `ConsoleCommandsMod`
- `ConsoleEnablerMod`
- `BPModLoaderMod`
- `BPML_GenericFunctions`
- `CheatManagerEnablerMod`

## First thing to test

Use the bundled actor dump.

Hotkey:

- `Ctrl+Num3`

That should dump the current actor list once you are inside a real level.

## Test loop

1. Launch `WarTorn-Win64-Shipping.exe`.
2. Load into a real map, not just the menu.
3. Press `Ctrl+Num3`.
4. Watch the UE4SS window or `UE4SS.log`.

## What success looks like

You should start seeing actor names that prove the runtime is looking at the live level, for example:

- `PlayerStart`
- spawn-related blueprints
- objective actors
- turrets
- vehicles
- navmesh helpers

## If nothing happens

Check the this stuff first:

- `mods.txt` really has the mods enabled
- you are in a loaded level, not the menu
- `UE4SS.log` is being written at all
- the install path is actually the game's `Binaries\Win64` folder

## Why this matters

This is the fastest way to test if the install worked.

Once the dump works, you can start comparing stock actor layouts against what you place in the editable project. That is the foundation for pretty much everything else in this repo.
