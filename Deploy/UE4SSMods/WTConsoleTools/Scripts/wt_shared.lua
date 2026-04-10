local UEHelpers = require("UEHelpers")

local CurrentOutputDevice = nil

local Session = {
    ActiveModeName = nil,
    LastSpawnedBpModActor = nil,
    LastWorldName = nil,
    TraceExecEnabled = false
}

local Shared = {}

function Shared.SafeCall(Callback)
    local Ok, Result = pcall(Callback)
    if Ok then
        return Result
    end

    return nil
end

function Shared.IsAlive(Object)
    if Object == nil then
        return false
    end

    local IsValid = Shared.SafeCall(function()
        return Object:IsValid()
    end)

    return IsValid == true
end

function Shared.SetOutputDevice(OutputDevice)
    CurrentOutputDevice = OutputDevice
end

function Shared.Log(Message)
    print(Message .. "\n")

    local OutputType = Shared.SafeCall(function()
        if type(CurrentOutputDevice) == "userdata" then
            return CurrentOutputDevice:type()
        end

        return nil
    end)

    if OutputType == "FOutputDevice" then
        CurrentOutputDevice:Log(Message)
    end
end

function Shared.LogCommand(FullCommand)
    if not FullCommand or FullCommand == "" then
        return
    end

    Shared.Log(string.format("[WTConsoleTools] Command: %s", FullCommand))
end

function Shared.GetWorld()
    local World = Shared.SafeCall(function()
        return UEHelpers.GetWorld()
    end)

    if Shared.IsAlive(World) then
        return World
    end

    return nil
end

function Shared.SetActiveModeName(ModeName)
    Session.ActiveModeName = ModeName
end

function Shared.GetActiveModeName()
    return Session.ActiveModeName
end

function Shared.SetLastSpawnedBpModActor(ActorName)
    Session.LastSpawnedBpModActor = ActorName
end

function Shared.GetLastSpawnedBpModActor()
    return Session.LastSpawnedBpModActor
end

function Shared.SetLastWorldName(WorldName)
    Session.LastWorldName = WorldName
end

function Shared.GetLastWorldName()
    return Session.LastWorldName
end

function Shared.SetTraceExecEnabled(Enabled)
    Session.TraceExecEnabled = Enabled and true or false
end

function Shared.GetTraceExecEnabled()
    return Session.TraceExecEnabled
end

function Shared.PrintHelp()
    Shared.Log("[WTConsoleTools] Available commands:")
    Shared.Log("  wt_help")
    Shared.Log("  wt_world")
    Shared.Log("  wt_mode set <name>")
    Shared.Log("  wt_mode status")
    Shared.Log("  wt_mode clear")
    Shared.Log("  wt_spawncar")
    Shared.Log("  wt_spawnplane")
    Shared.Log("  wt_trace_exec on")
    Shared.Log("  wt_trace_exec off")
    Shared.Log("  wt_trace_exec status")
    Shared.Log("  wt_probe_console_path")
    Shared.Log("  wt_probe_vehicle_funcs")
    Shared.Log("  wt_probe_live_car [index]")
    Shared.Log("  wt_load_bpmod <ModName> [AssetPath] [AssetClass]")
    Shared.Log("  wt_last_bpmod")
end

return Shared
