local UEHelpers = require("UEHelpers")
local Shared = require("wt_shared")

local function SafeCall(Callback)
    local Success, Result = pcall(Callback)
    if Success then
        return Result
    end

    return nil
end

local function IsAlive(Object)
    if Object == nil then
        return false
    end

    local IsValid = SafeCall(function()
        return Object:IsValid()
    end)

    return IsValid == true
end

local function TryGetFunction(TargetObject, FunctionName)
    if not IsAlive(TargetObject) then
        return nil
    end

    local FoundFunction = SafeCall(function()
        return TargetObject:GetFunctionByNameInChain(FunctionName)
    end)
    if IsAlive(FoundFunction) then
        return FoundFunction
    end

    return SafeCall(function()
        return TargetObject:GetFunctionByName(FunctionName)
    end)
end

local function LogObject(Label, Object)
    if not IsAlive(Object) then
        Shared.Log(string.format("[WTConsoleTools] %s <invalid>", Label))
        return
    end

    local Class = SafeCall(function()
        return Object:GetClass()
    end)
    local ClassName = "<unknown class>"
    if IsAlive(Class) then
        ClassName = Class:GetFullName()
    end

    Shared.Log(string.format("[WTConsoleTools] %s object=%s", Label, Object:GetFullName()))
    Shared.Log(string.format("[WTConsoleTools] %s class=%s", Label, ClassName))
end

local function LogFunctionAvailability(TargetLabel, TargetObject, FunctionName)
    if not IsAlive(TargetObject) then
        Shared.Log(string.format("[WTConsoleTools] %s.%s = unavailable (target invalid)", TargetLabel, FunctionName))
        return
    end

    local FoundFunction = TryGetFunction(TargetObject, FunctionName)
    if IsAlive(FoundFunction) then
        Shared.Log(string.format(
            "[WTConsoleTools] %s.%s = callable via %s",
            TargetLabel,
            FunctionName,
            FoundFunction:GetFullName()
        ))
    else
        Shared.Log(string.format("[WTConsoleTools] %s.%s = missing", TargetLabel, FunctionName))
    end
end

RegisterConsoleCommandHandler("wt_probe_console_path", function(FullCommand, Parameters, Ar)
    Shared.SetOutputDevice(Ar)
    Shared.LogCommand(FullCommand)
    Shared.Log("[WTConsoleTools] Read-only console-path probe. No commands will be executed.")

    local PlayerController = SafeCall(function()
        return UEHelpers.GetPlayerController()
    end)
    LogObject("PlayerController", PlayerController)

    local Player = SafeCall(function()
        return PlayerController.Player
    end)
    LogObject("PlayerController.Player", Player)

    local ViewportClient = SafeCall(function()
        return Player.ViewportClient
    end)
    LogObject("PlayerController.Player.ViewportClient", ViewportClient)

    local ViewportConsole = SafeCall(function()
        return ViewportClient.ViewportConsole
    end)
    LogObject("PlayerController.Player.ViewportClient.ViewportConsole", ViewportConsole)

    local CheatManager = SafeCall(function()
        return PlayerController.CheatManager
    end)
    LogObject("PlayerController.CheatManager", CheatManager)

    local KismetSystemLibrary = SafeCall(function()
        return UEHelpers.GetKismetSystemLibrary()
    end)
    LogObject("KismetSystemLibrary", KismetSystemLibrary)

    LogFunctionAvailability("PlayerController", PlayerController, "SendToConsole")
    LogFunctionAvailability("PlayerController", PlayerController, "ConsoleCommand")
    LogFunctionAvailability("PlayerController", PlayerController, "ProcessConsoleExec")
    LogFunctionAvailability("PlayerController.CheatManager", CheatManager, "Summon")
    LogFunctionAvailability("KismetSystemLibrary", KismetSystemLibrary, "ExecuteConsoleCommand")

    return true
end)
