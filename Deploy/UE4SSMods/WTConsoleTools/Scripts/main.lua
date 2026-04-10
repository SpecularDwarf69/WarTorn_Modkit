local Shared = require("wt_shared")

local function LoadModule(ModuleName)
    local Ok, ModuleOrError = pcall(require, ModuleName)
    if Ok then
        return ModuleOrError
    end

    Shared.Log(string.format("[WTConsoleTools] Could not load %s: %s", ModuleName, tostring(ModuleOrError)))
    return nil
end

local function ReadWorldFromHook(WorldParam)
    if WorldParam == nil then
        return nil
    end

    return Shared.SafeCall(function()
        return WorldParam:get()
    end)
end

LoadModule("wt_world")
LoadModule("wt_mode")
LoadModule("wt_bpmod")
LoadModule("wt_spawn")
LoadModule("wt_trace")
LoadModule("wt_probe")
LoadModule("wt_live_car")
LoadModule("wt_console_probe")

RegisterConsoleCommandHandler("wt_help", function(FullCommand, Parameters, Ar)
    Shared.SetOutputDevice(Ar)
    Shared.LogCommand(FullCommand)
    Shared.PrintHelp()
    return true
end)

RegisterLoadMapPostHook(function(Engine, WorldParam)
    local World = ReadWorldFromHook(WorldParam)
    if not Shared.IsAlive(World) then
        return
    end

    local WorldName = Shared.SafeCall(function()
        return World:GetFullName()
    end) or tostring(World)

    Shared.SetLastWorldName(WorldName)

    local ActiveModeName = Shared.GetActiveModeName()
    if ActiveModeName then
        Shared.Log(string.format("[WTConsoleTools] Map loaded: %s | active mode: %s", WorldName, ActiveModeName))
    else
        Shared.Log(string.format("[WTConsoleTools] Map loaded: %s", WorldName))
    end
end)
