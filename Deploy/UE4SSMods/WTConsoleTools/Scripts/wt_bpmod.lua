local Shared = require("wt_shared")

local function IsInWorld(Object, World)
    if not Shared.IsAlive(Object) or not Shared.IsAlive(World) then
        return false
    end

    local ObjectWorld = Shared.SafeCall(function()
        return Object:GetWorld()
    end)
    if not Shared.IsAlive(ObjectWorld) then
        return false
    end

    local ObjectWorldName = Shared.SafeCall(function()
        return ObjectWorld:GetFullName()
    end)
    local WorldName = Shared.SafeCall(function()
        return World:GetFullName()
    end)

    return ObjectWorldName ~= nil and ObjectWorldName == WorldName
end

local function CountLiveActors(ClassName, World)
    local FoundObjects = Shared.SafeCall(function()
        return FindAllOf(ClassName)
    end) or {}

    local MatchCount = 0
    for _, FoundObject in pairs(FoundObjects) do
        if Shared.IsAlive(FoundObject) and IsInWorld(FoundObject, World) then
            MatchCount = MatchCount + 1
        end
    end

    return MatchCount
end

local function ExplainBpModStatus(ModName, AssetPath, AssetClassName)
    local World = Shared.GetWorld()
    if not World then
        Shared.Log("[WTConsoleTools] No playable world is loaded yet, so there is nothing useful to check.")
        return
    end

    local LiveCount = CountLiveActors(AssetClassName, World)

    Shared.Log("[WTConsoleTools] wt_load_bpmod is read-only in this build.")
    Shared.Log("[WTConsoleTools] Manual BP mod spawning looked like it was tripping over War-Torn's own BPModLoader flow and causing crashes, so this command only reports what it would try to load.")
    Shared.Log(string.format("[WTConsoleTools] Mod name: %s", ModName))
    Shared.Log(string.format("[WTConsoleTools] Expected asset path: %s", AssetPath))
    Shared.Log(string.format("[WTConsoleTools] Expected class: %s", AssetClassName))
    Shared.Log(string.format("[WTConsoleTools] Live %s actor count in this world: %d", AssetClassName, LiveCount))
    Shared.Log("[WTConsoleTools] If you want to actually reload Blueprint logic mods, use the normal map load path or press Insert.")
end

RegisterConsoleCommandHandler("wt_load_bpmod", function(FullCommand, Parameters, Ar)
    Shared.SetOutputDevice(Ar)
    Shared.LogCommand(FullCommand)

    if #Parameters < 1 then
        Shared.Log("[WTConsoleTools] Usage: wt_load_bpmod <ModName> [AssetPath] [AssetClass]")
        return true
    end

    local ModName = Parameters[1]
    local AssetPath = Parameters[2] or string.format("/Game/Mods/%s/ModActor", ModName)
    local AssetClassName = Parameters[3] or "ModActor_C"

    ExplainBpModStatus(ModName, AssetPath, AssetClassName)
    return true
end)

RegisterConsoleCommandHandler("wt_last_bpmod", function(FullCommand, Parameters, Ar)
    Shared.SetOutputDevice(Ar)
    Shared.LogCommand(FullCommand)

    local LastActorName = Shared.GetLastSpawnedBpModActor()
    if LastActorName then
        Shared.Log(string.format("[WTConsoleTools] Last BP mod actor tracked by WTConsoleTools: %s", LastActorName))
    else
        Shared.Log("[WTConsoleTools] WTConsoleTools has not tracked a BP mod actor in this session.")
    end

    return true
end)
