local Shared = require("wt_shared")

local function Usage()
    Shared.Log("[WTConsoleTools] Usage: wt_mode set <name> | wt_mode status | wt_mode clear")
end

RegisterConsoleCommandHandler("wt_mode", function(FullCommand, Parameters, Ar)
    Shared.SetOutputDevice(Ar)
    Shared.LogCommand(FullCommand)

    if #Parameters < 1 then
        Usage()
        return true
    end

    local Action = string.lower(Parameters[1])

    if Action == "set" then
        if #Parameters < 2 then
            Usage()
            return true
        end

        local ModeParts = {}
        for Index = 2, #Parameters do
            table.insert(ModeParts, Parameters[Index])
        end

        local ModeName = table.concat(ModeParts, " ")
        Shared.SetActiveModeName(ModeName)
        Shared.Log(string.format("[WTConsoleTools] Active custom mode label set to '%s'.", ModeName))
        return true
    end

    if Action == "status" then
        local ActiveModeName = Shared.GetActiveModeName()
        if ActiveModeName then
            Shared.Log(string.format("[WTConsoleTools] Active custom mode label: %s", ActiveModeName))
        else
            Shared.Log("[WTConsoleTools] No custom mode label is currently active.")
        end

        return true
    end

    if Action == "clear" then
        Shared.SetActiveModeName(nil)
        Shared.Log("[WTConsoleTools] Cleared the active custom mode label.")
        return true
    end

    Usage()
    return true
end)
