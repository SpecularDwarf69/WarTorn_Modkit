# WTConsoleTools Guide

`WTConsoleTools` is the little UE4SS Lua mod in this repo that adds extra commands to the in-game console opened with `L`.

It is not a polished end-user mod. It is more like a toolbox I kept adding random useful things to while trying to figure the game out.

## Files involved

- mod source: `Deploy/UE4SSMods/WTConsoleTools`
- deploy script: `Scripts/Deploy-UE4SSMod.ps1`
- UE4SS installer: `Scripts/Install-UE4SS.ps1`

## Install it into the live game

Make sure UE4SS is already installed into the game's `Binaries\Win64` folder, then run:

```powershell
& ".\Scripts\Deploy-UE4SSMod.ps1" `
  -GameWin64Dir "D:\Games\WarTorn\WarTorn\Binaries\Win64" `
  -ModName WTConsoleTools
```

The deploy script now cleans the target folder first, which matters because stale Lua files caused confusion during earlier testing.

## What is safe right now

These are the commands I would actually trust using:

- `wt_help`
- `wt_world`
- `wt_mode set <name>`
- `wt_mode status`
- `wt_mode clear`
- `wt_trace_exec on | off | status`
- `wt_probe_console_path`
- `wt_probe_vehicle_funcs`
- `wt_probe_live_car [index]`
- `wt_load_bpmod <ModName> [AssetPath] [AssetClass]`
- `wt_last_bpmod`

## What is intentionally limited

Some commands are still there, but they are deliberately limited:

- `wt_spawncar`
  - disabled because direct `SpawnActor` crashes this game build
- `wt_spawnplane`
  - disabled for the same reason
- `wt_load_bpmod`
  - now a safe status/diagnostic command only
  - it does not manually spawn Blueprint mod actors anymore because that path looked like it was re-entering asset or lifecycle handling and crashing the game

## Command list

Open the in-game console with `L`, then try:

```text
wt_help
wt_world
wt_mode set testmode
wt_mode status
wt_trace_exec on
wt_trace_exec status
wt_probe_console_path
wt_probe_vehicle_funcs
wt_probe_live_car
wt_load_bpmod WTSpawnTest
wt_last_bpmod
```

## What each command does

- `wt_help`
  - prints the command list
- `wt_world`
  - prints the current world and the active mode label
- `wt_mode set <name>`
  - stores a simple runtime label so you can keep track of the mode you are testing
- `wt_mode status`
  - prints the current mode label
- `wt_mode clear`
  - clears the label
- `wt_trace_exec on | off | status`
  - logs vehicle-related exec and function-call traffic
  - useful when you are trying to find the stock game path instead of forcing a spawn
- `wt_probe_console_path`
  - checks whether likely console dispatch functions exist on the current build
  - read-only, nothing gets executed
- `wt_probe_vehicle_funcs`
  - broad reflection pass over controller, world, vehicle, and helper objects
  - useful, but noisy
- `wt_probe_live_car [index]`
  - inspects a live `Car_C` already present in the world
  - this is the safer way to learn how the stock vehicle setup hangs together
- `wt_load_bpmod <ModName> [AssetPath] [AssetClass]`
  - safe diagnostic check only
  - prints the expected asset path and class
  - reports how many actors of that class already exist in the current world
- `wt_last_bpmod`
  - prints the last BP mod actor name that `WTConsoleTools` spawned in older builds
  - mostly useful for historical debugging at this point

## Why `wt_load_bpmod` is now diagnostic-only

The original idea was handy: type a command and spawn a logic-mod actor on demand.

In practice, it looked like a bad fit for War-Torn's current BP mod loading path. Manual spawning appeared to overlap with BPModLoader's own lifecycle handling and caused crashes. So the command now stays on the safe side and only reports status.

If you want to actually load or reload Blueprint logic mods, use:

- normal map load
- `Insert` for BPModLoader reloads

## Vehicle tracing workflow

If you want to learn how the stock vehicle path works without crashing the game, this is the loop I would use:

1. `wt_trace_exec on`
2. perform the stock action you care about
3. inspect `UE4SS.log`
4. `wt_trace_exec off`

The useful lines will usually start with:

- `ProcessConsoleExecPreHook`
- `ULocalPlayerExecPreHook`
- `CallFunctionByNameWithArgumentsPreHook`

## Extending the mod

Add new Lua files under:

- `Deploy/UE4SSMods/WTConsoleTools/Scripts`

The normal pattern is:

```lua
RegisterConsoleCommandHandler("wt_mycommand", function(FullCommand, Parameters, Ar)
    -- your logic here
    return true
end)
```

If you add new commands, aim for read-only or clearly reversible behavior first. That has been the most stable path so far.

## Recommended first test loop

1. Deploy `WTConsoleTools`.
2. Launch the game.
3. Load into a real map.
4. Press `L`.
5. Run `wt_help`.
6. Run `wt_world`.
7. Run `wt_probe_console_path`.
8. Run `wt_probe_vehicle_funcs` only if you actually need the extra detail.
