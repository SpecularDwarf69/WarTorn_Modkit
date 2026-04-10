local UEHelpers = require("UEHelpers")
local Shared = require("wt_shared")

local CandidateNames = {
    "ExecuteConsoleCommand",
    "BeginDeferredActorSpawnFromClass",
    "FinishSpawningActor",
    "ExitVehicleServer",
    "EnterVehicleServer",
    "EnterVehicle",
    "ExitVehicle",
    "UseVehicleServer",
    "UseVehicle",
    "PossessVehicleServer",
    "PossessVehicle",
    "SpawnVehicleServer",
    "SpawnVehicle",
    "SpawnCarServer",
    "SpawnCar",
    "SpawnPlaneServer",
    "SpawnPlane",
    "SpawnFlyingPawn",
    "SpawnActor",
    "ServerSpawnActor",
    "ServerSpawnVehicle",
    "ServerSpawnCar",
    "ServerSpawnPlane",
    "CreateVehicleServer",
    "CreateVehicle",
    "CreateCar",
    "CreatePlane",
    "SummonVehicle",
    "SummonCar",
    "SummonPlane",
    "RequestVehicle",
    "RequestCar",
    "RequestPlane",
    "CallVehicle",
    "CallPlane",
    "SupportPlane",
}

local KeywordFilters = {
    "vehicle",
    "car",
    "plane",
    "flying",
    "spawn",
    "summon",
    "support",
    "seat",
    "turret",
    "enter",
    "exit",
    "possess",
    "console",
    "cheat",
}

local RelationshipProperties = {
    "Owner",
    "Instigator",
    "Controller",
    "Pawn",
    "PlayerState",
    "PlayerCameraManager",
    "HUD",
    "CheatManager",
    "GameState",
    "GameSession",
    "AuthorityGameMode",
    "VehicleComponent",
    "VehicleMovement",
    "VehicleMovementComponent",
    "MovementComponent",
    "Turret",
    "Health",
    "Role",
    "RemoteRole",
    "bReplicates",
    "bReplicateMovement",
}

local NestedTargetProperties = {
    "CheatManager",
    "Pawn",
    "PlayerState",
    "PlayerCameraManager",
    "HUD",
    "Controller",
    "GameState",
    "GameSession",
    "AuthorityGameMode",
    "VehicleComponent",
    "VehicleMovement",
    "VehicleMovementComponent",
    "MovementComponent",
    "Turret",
}

local AdditionalWorldClasses = {
    { ClassName = "Car_C", MaxCount = 2 },
    { ClassName = "FlyingPawn_C", MaxCount = 2 },
    { ClassName = "VehicleComponent_C", MaxCount = 4 },
    { ClassName = "VehicleSeat_C", MaxCount = 6 },
    { ClassName = "Turret_C", MaxCount = 4 },
    { ClassName = "Spawn_C", MaxCount = 4 },
    { ClassName = "ObjectiveSpawn_C", MaxCount = 4 },
    { ClassName = "StaticTurretSpawn_C", MaxCount = 4 },
}

local MaxHitsPerSection = 20

local function SafeCall(Callback)
    local Success, Result = pcall(Callback)
    if Success then
        return Result
    end

    return nil
end

local function StringContainsKeyword(Text)
    if type(Text) ~= "string" or Text == "" then
        return false
    end

    local Lowered = string.lower(Text)
    for _, Keyword in ipairs(KeywordFilters) do
        if string.find(Lowered, Keyword, 1, true) then
            return true
        end
    end

    return false
end

local function UnwrapValue(Value, Depth)
    Depth = Depth or 0
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

        local ArrayNum = SafeCall(function()
            return Value:GetArrayNum()
        end)
        if type(ArrayNum) == "number" then
            local ArrayMax = SafeCall(function()
                return Value:GetArrayMax()
            end) or ArrayNum
            return string.format("<array %d/%d>", ArrayNum, ArrayMax)
        end

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

local function SameWorld(Object, World)
    if not Object or not Object:IsValid() or not World or not World:IsValid() then
        return true
    end

    local ObjectWorld = SafeCall(function()
        return Object:GetWorld()
    end)
    if not ObjectWorld or not ObjectWorld:IsValid() then
        return true
    end

    local ObjectWorldName = SafeCall(function()
        return ObjectWorld:GetFullName()
    end)
    local WorldName = SafeCall(function()
        return World:GetFullName()
    end)

    return ObjectWorldName ~= nil and ObjectWorldName == WorldName
end

local function GetObjectKey(Object)
    if not Object or not Object:IsValid() then
        return nil
    end

    local Address = SafeCall(function()
        return Object:GetAddress()
    end)
    local FullName = SafeCall(function()
        return Object:GetFullName()
    end) or tostring(Object)

    if Address then
        return string.format("%s|0x%X", FullName, Address)
    end

    return FullName
end

local function AddTarget(Targets, Seen, Label, Object)
    if not Object or not Object:IsValid() then
        return false
    end

    local ObjectKey = GetObjectKey(Object)
    if not ObjectKey or Seen[ObjectKey] then
        return false
    end

    Seen[ObjectKey] = true
    table.insert(Targets, {
        Label = Label,
        Object = Object,
    })
    return true
end

local function AddNestedTargets(Targets, Seen, ParentLabel, ParentObject)
    if not ParentObject or not ParentObject:IsValid() then
        return
    end

    for _, PropertyName in ipairs(NestedTargetProperties) do
        local NestedObject = SafeCall(function()
            return ParentObject[PropertyName]
        end)
        if NestedObject and NestedObject:IsValid() then
            AddTarget(Targets, Seen, string.format("%s.%s", ParentLabel, PropertyName), NestedObject)
        end
    end
end

local function AppendWorldClassTargets(Targets, Seen, World)
    for _, Entry in ipairs(AdditionalWorldClasses) do
        local Objects = SafeCall(function()
            return FindAllOf(Entry.ClassName)
        end) or {}

        local MatchCount = 0
        for _, Object in pairs(Objects) do
            if Object and Object:IsValid() and SameWorld(Object, World) then
                MatchCount = MatchCount + 1
                if MatchCount <= Entry.MaxCount then
                    AddTarget(Targets, Seen, string.format("%s[%d]", Entry.ClassName, MatchCount), Object)
                end
            end
        end

        if MatchCount > 0 then
            Shared.Log(string.format(
                "[WTConsoleTools] World class count: %s = %d",
                Entry.ClassName,
                MatchCount
            ))
        end
    end
end

local function AppendStaticTargets(Targets, Seen)
    local KismetSystemLibrary = SafeCall(function()
        return StaticFindObject("/Script/Engine.Default__KismetSystemLibrary")
    end)
    if KismetSystemLibrary and KismetSystemLibrary:IsValid() then
        AddTarget(Targets, Seen, "KismetSystemLibrary", KismetSystemLibrary)
    end

    local GameplayStatics = SafeCall(function()
        return StaticFindObject("/Script/Engine.Default__GameplayStatics")
    end)
    if GameplayStatics and GameplayStatics:IsValid() then
        AddTarget(Targets, Seen, "GameplayStatics", GameplayStatics)
    end
end

local function GetProbeTargets()
    local Targets = {}
    local Seen = {}
    local World = Shared.GetWorld()

    local PlayerController = SafeCall(function()
        return UEHelpers.GetPlayerController()
    end)
    if PlayerController and PlayerController:IsValid() then
        AddTarget(Targets, Seen, "PlayerController", PlayerController)
        AddNestedTargets(Targets, Seen, "PlayerController", PlayerController)
    end

    local WorldObject = Shared.GetWorld()
    if WorldObject and WorldObject:IsValid() then
        AddTarget(Targets, Seen, "World", WorldObject)
        AddNestedTargets(Targets, Seen, "World", WorldObject)
    end

    AppendStaticTargets(Targets, Seen)
    AppendWorldClassTargets(Targets, Seen, World)

    for _, Target in ipairs(Targets) do
        AddNestedTargets(Targets, Seen, Target.Label, Target.Object)
    end

    return Targets
end

local function TryGetFunction(TargetObject, FunctionName)
    if not TargetObject or not TargetObject:IsValid() then
        return nil
    end

    local FoundFunction = SafeCall(function()
        return TargetObject:GetFunctionByName(FunctionName)
    end)
    if FoundFunction and FoundFunction:IsValid() then
        return FoundFunction
    end

    FoundFunction = SafeCall(function()
        return TargetObject:GetFunctionByNameInChain(FunctionName)
    end)
    if FoundFunction and FoundFunction:IsValid() then
        return FoundFunction
    end

    return nil
end

local function CollectCandidateFunctionHits(TargetObject)
    local Hits = {}
    local Seen = {}

    for _, FunctionName in ipairs(CandidateNames) do
        local FoundFunction = TryGetFunction(TargetObject, FunctionName)
        if FoundFunction then
            local FullName = SafeCall(function()
                return FoundFunction:GetFullName()
            end) or FunctionName
            if not Seen[FullName] then
                Seen[FullName] = true
                table.insert(Hits, FullName)
            end
        end
    end

    return Hits
end

local function CollectEnumeratedFunctionHits(TargetObject)
    local Hits = {}
    local Seen = {}

    local Success, ErrorMessage = pcall(function()
        local CurrentClass = TargetObject:GetClass()
        while CurrentClass and CurrentClass:IsValid() do
            CurrentClass:ForEachFunction(function(Function)
                local FunctionName = SafeCall(function()
                    return Function:GetFName():ToString()
                end)
                local FullName = SafeCall(function()
                    return Function:GetFullName()
                end) or FunctionName

                if StringContainsKeyword(FunctionName) or StringContainsKeyword(FullName) then
                    if not Seen[FullName] then
                        Seen[FullName] = true
                        table.insert(Hits, FullName)
                    end
                end
            end)

            CurrentClass = CurrentClass:GetSuperStruct()
        end
    end)

    return Success, Hits, ErrorMessage
end

local function CollectRelationshipHits(TargetObject)
    local Hits = {}

    for _, PropertyName in ipairs(RelationshipProperties) do
        local Value = SafeCall(function()
            return TargetObject[PropertyName]
        end)
        if Value ~= nil then
            table.insert(Hits, string.format("%s = %s", PropertyName, ValueToString(Value)))
        end
    end

    return Hits
end

local function CollectKeywordPropertyHits(TargetObject)
    local Hits = {}
    local Seen = {}

    local CurrentClass = SafeCall(function()
        return TargetObject:GetClass()
    end)

    while CurrentClass and CurrentClass:IsValid() do
        SafeCall(function()
            CurrentClass:ForEachProperty(function(Property)
                local PropertyName = SafeCall(function()
                    return Property:GetFName():ToString()
                end)
                if not PropertyName or Seen[PropertyName] or not StringContainsKeyword(PropertyName) then
                    return false
                end

                Seen[PropertyName] = true
                local PropertyClass = SafeCall(function()
                    return Property:GetClass():GetFName():ToString()
                end) or "<unknown>"
                local Value = SafeCall(function()
                    return TargetObject[PropertyName]
                end)

                table.insert(Hits, string.format(
                    "%s (%s) = %s",
                    PropertyName,
                    PropertyClass,
                    ValueToString(Value)
                ))

                return false
            end)
        end)

        CurrentClass = SafeCall(function()
            return CurrentClass:GetSuperStruct()
        end)
    end

    return Hits
end

local function LogHitList(Prefix, Hits)
    local TotalHits = #Hits
    local MaxIndex = math.min(TotalHits, MaxHitsPerSection)

    for Index = 1, MaxIndex do
        Shared.Log(string.format("[WTConsoleTools] %s %s", Prefix, Hits[Index]))
    end

    if TotalHits > MaxHitsPerSection then
        Shared.Log(string.format(
            "[WTConsoleTools] %s ... %d more hit(s) omitted",
            Prefix,
            TotalHits - MaxHitsPerSection
        ))
    end
end

RegisterConsoleCommandHandler("wt_probe_vehicle_funcs", function(FullCommand, Parameters, Ar)
    Shared.SetOutputDevice(Ar)
    Shared.LogCommand(FullCommand)

    local Targets = GetProbeTargets()
    if #Targets == 0 then
        Shared.Log("[WTConsoleTools] No valid probe targets were found.")
        return true
    end

    local AnyHit = false
    local FunctionEnumerationSupported = false
    local FunctionEnumerationReportedUnavailable = false

    for _, Target in ipairs(Targets) do
        local TargetName = SafeCall(function()
            return Target.Object:GetFullName()
        end) or tostring(Target.Object)

        Shared.Log(string.format("[WTConsoleTools] Probing %s: %s", Target.Label, TargetName))

        local DirectFunctionHits = CollectCandidateFunctionHits(Target.Object)
        if #DirectFunctionHits > 0 then
            AnyHit = true
            LogHitList(string.format("HIT %s ->", Target.Label), DirectFunctionHits)
        end

        local EnumeratedOk, EnumeratedHits = CollectEnumeratedFunctionHits(Target.Object)
        if EnumeratedOk then
            FunctionEnumerationSupported = true
            if #EnumeratedHits > 0 then
                AnyHit = true
                LogHitList(string.format("ENUM %s ->", Target.Label), EnumeratedHits)
            end
        elseif not FunctionEnumerationReportedUnavailable then
            Shared.Log("[WTConsoleTools] Function iteration is not available on this UE4SS build; using direct lookup and property scanning.")
            FunctionEnumerationReportedUnavailable = true
        end

        local RelationshipHits = CollectRelationshipHits(Target.Object)
        if #RelationshipHits > 0 then
            AnyHit = true
            LogHitList(string.format("REL %s ->", Target.Label), RelationshipHits)
        end

        local PropertyHits = CollectKeywordPropertyHits(Target.Object)
        if #PropertyHits > 0 then
            AnyHit = true
            LogHitList(string.format("PROP %s ->", Target.Label), PropertyHits)
        end
    end

    if not AnyHit then
        Shared.Log("[WTConsoleTools] No candidate function or property hits were found on the current targets.")
    elseif FunctionEnumerationSupported then
        Shared.Log("[WTConsoleTools] Probe completed with function enumeration support.")
    else
        Shared.Log("[WTConsoleTools] Probe completed with direct lookup plus reflected-property scanning.")
    end

    return true
end)
