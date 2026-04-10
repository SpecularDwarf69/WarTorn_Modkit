local Shared = require("wt_shared")

local TraceKeywords = {
    "spawn",
    "car",
    "vehicle",
    "plane",
    "flying",
    "enter",
    "exit",
    "drive",
    "summon",
    "cheat",
    "possess",
    "console",
}

local function SafeCall(Callback)
    local Success, Result = pcall(Callback)
    if Success then
        return Result
    end

    return nil
end

local function UnwrapValue(Value, Depth)
    if Depth == nil then
        Depth = 0
    end

    if Depth >= 3 or Value == nil then
        return Value
    end

    if type(Value) == "userdata" then
        local InnerValue = SafeCall(function()
            return Value:get()
        end)

        if InnerValue ~= nil and InnerValue ~= Value then
            return UnwrapValue(InnerValue, Depth + 1)
        end
    end

    return Value
end

local function ValueToString(Value)
    Value = UnwrapValue(Value)

    if Value == nil then
        return "<nil>"
    end

    local ValueType = type(Value)
    if ValueType == "string" or ValueType == "number" or ValueType == "boolean" then
        return tostring(Value)
    end

    if ValueType == "userdata" then
        local TypeName = SafeCall(function()
            return Value:type()
        end)

        if TypeName == "FString" or TypeName == "FName" or TypeName == "FText" then
            local AsString = SafeCall(function()
                return Value:ToString()
            end)
            if AsString and AsString ~= "" then
                return AsString
            end
        end

        local FullName = SafeCall(function()
            return Value:GetFullName()
        end)
        if FullName and FullName ~= "" then
            return FullName
        end

        if TypeName and TypeName ~= "" then
            return string.format("<userdata %s>", TypeName)
        end
    end

    return tostring(Value)
end

local function ShouldTrace(JoinedText)
    local Lowered = string.lower(JoinedText)
    for _, Keyword in ipairs(TraceKeywords) do
        if string.find(Lowered, Keyword, 1, true) then
            return true
        end
    end

    return false
end

local function TraceHook(HookName, ...)
    if not Shared.GetTraceExecEnabled() then
        return nil
    end

    local ArgCount = select("#", ...)
    local Parts = {}
    for Index = 1, ArgCount do
        Parts[Index] = ValueToString(select(Index, ...))
    end

    local Joined = table.concat(Parts, " | ")
    if Joined == "" or not ShouldTrace(Joined) then
        return nil
    end

    Shared.Log(string.format("[WTConsoleTools] %s: %s", HookName, Joined))
    return nil
end

RegisterProcessConsoleExecPreHook(function(...)
    return TraceHook("ProcessConsoleExecPreHook", ...)
end)

RegisterULocalPlayerExecPreHook(function(...)
    return TraceHook("ULocalPlayerExecPreHook", ...)
end)

RegisterCallFunctionByNameWithArgumentsPreHook(function(...)
    return TraceHook("CallFunctionByNameWithArgumentsPreHook", ...)
end)

RegisterConsoleCommandHandler("wt_trace_exec", function(FullCommand, Parameters, Ar)
    Shared.SetOutputDevice(Ar)
    Shared.LogCommand(FullCommand)

    local Action = Parameters[1] and string.lower(Parameters[1]) or "status"
    if Action == "on" then
        Shared.SetTraceExecEnabled(true)
        Shared.Log("[WTConsoleTools] Exec tracing is ON. Vehicle-related exec/function calls will be logged.")
        return true
    end

    if Action == "off" then
        Shared.SetTraceExecEnabled(false)
        Shared.Log("[WTConsoleTools] Exec tracing is OFF.")
        return true
    end

    if Action == "status" then
        if Shared.GetTraceExecEnabled() then
            Shared.Log("[WTConsoleTools] Exec tracing is currently ON.")
        else
            Shared.Log("[WTConsoleTools] Exec tracing is currently OFF.")
        end
        return true
    end

    Shared.Log("[WTConsoleTools] Usage: wt_trace_exec on | off | status")
    return true
end)
