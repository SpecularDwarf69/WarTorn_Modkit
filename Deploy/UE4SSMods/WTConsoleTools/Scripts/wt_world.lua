local Shared = require("wt_shared")

RegisterConsoleCommandHandler("wt_world", function(FullCommand, Parameters, Ar)
    Shared.SetOutputDevice(Ar)
    Shared.LogCommand(FullCommand)

    local World = Shared.GetWorld()
    if not World then
        Shared.Log("[WTConsoleTools] No playable world is loaded yet.")
        return true
    end

    Shared.SetLastWorldName(World:GetFullName())
    Shared.Log(string.format("[WTConsoleTools] Current world: %s", World:GetFullName()))

    local ActiveModeName = Shared.GetActiveModeName()
    if ActiveModeName then
        Shared.Log(string.format("[WTConsoleTools] Active custom mode label: %s", ActiveModeName))
    else
        Shared.Log("[WTConsoleTools] No custom mode label is currently active.")
    end

    return true
end)
