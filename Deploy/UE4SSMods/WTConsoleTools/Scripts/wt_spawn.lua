local Shared = require("wt_shared")

local function LogDisabledSpawnWarning(CommandLabel)
    Shared.Log(string.format(
        "[WTConsoleTools] %s is disabled because direct SpawnActor vehicle spawning crashes this War-Torn build after the actor is created.",
        CommandLabel
    ))
    Shared.Log("[WTConsoleTools] Use the built-in `summon` command directly for experiments, or keep tracing the stock path with `wt_trace_exec on`.")
end

RegisterConsoleCommandHandler("wt_spawncar", function(FullCommand, Parameters, Ar)
    Shared.SetOutputDevice(Ar)
    Shared.LogCommand(FullCommand)
    LogDisabledSpawnWarning("wt_spawncar")
    return true
end)

RegisterConsoleCommandHandler("wt_spawnplane", function(FullCommand, Parameters, Ar)
    Shared.SetOutputDevice(Ar)
    Shared.LogCommand(FullCommand)
    LogDisabledSpawnWarning("wt_spawnplane")
    return true
end)
