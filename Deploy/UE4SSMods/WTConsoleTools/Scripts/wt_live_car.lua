local UEHelpers = require("UEHelpers")
local Shared = require("wt_shared")

local ExactPropertyNames = {
    ["Owner"] = true,
    ["Instigator"] = true,
    ["Controller"] = true,
    ["Pawn"] = true,
    ["PlayerState"] = true,
    ["Vehicle"] = true,
    ["CurrentVehicle"] = true,
    ["VehicleActor"] = true,
    ["VehicleComponent"] = true,
    ["CurrentVehicleComponent"] = true,
    ["VehicleMovement"] = true,
    ["VehicleMovementComponent"] = true,
    ["MovementComponent"] = true,
    ["UpdatedComponent"] = true,
    ["UpdatedPrimitive"] = true,
    ["AttachParent"] = true,
    ["Seats"] = true,
    ["Seat"] = true,
    ["SeatIndex"] = true,
    ["SeatID"] = true,
    ["CurrentSeat"] = true,
    ["CurrentSeatIndex"] = true,
    ["VehicleSeat"] = true,
    ["VehicleSeatIndex"] = true,
    ["VehicleSeatID"] = true,
    ["SeatTime"] = true,
    ["Driver"] = true,
    ["Occupant"] = true,
    ["OccupyingPawn"] = true,
    ["Passenger"] = true,
    ["Passengers"] = true,
    ["bIsDriver"] = true,
    ["bDriver"] = true,
    ["bDriving"] = true,
    ["bInVehicle"] = true,
    ["bUsingVehicle"] = true,
    ["Health"] = true,
    ["ThrottleInput"] = true,
    ["BrakeInput"] = true,
    ["SteeringInput"] = true,
    ["HandbrakeInput"] = true,
    ["CurrentGear"] = true,
    ["Role"] = true,
    ["RemoteRole"] = true,
    ["bReplicates"] = true,
    ["bReplicateMovement"] = true,
}

local KeywordFilters = {
    "vehicle",
    "seat",
    "turret",
    "driver",
    "pilot",
    "occup",
    "drive",
    "enter",
    "exit",
    "pawn",
    "controller",
    "health",
    "throttle",
    "brake",
    "steer",
    "gear",
    "speed",
    "replic",
}

local MovementFunctionNames = {
    "SetThrottleInput",
    "SetBrakeInput",
    "SetSteeringInput",
    "SetHandbrakeInput",
    "GetForwardSpeed",
    "GetEngineRotationSpeed",
    "GetCurrentGear",
    "ServerUpdateState",
}

local ControllerFunctionNames = {
    "Possess",
    "UnPossess",
    "ReceivePossess",
    "ReceiveUnPossess",
}

local VehicleComponentFunctionNames = {
    "DamageVehicle",
}

local PlayerFunctionNames = {
    "TryEnterVehicle",
    "EnterVehicle",
    "EnterVehicleServer",
    "LeaveVehicleSeat",
    "ExitVehicleServer",
    "ChangeSeat",
    "OnRep_Vehicle",
    "VehicleMoveForwardServer",
    "VehicleMoveRightServer",
    "VehicleAccelerateServer",
    "VehicleServerPrimary",
    "VehicleServerSecondary",
    "TurretRotServer",
}

local PlayerLinkPropertyNames = {
    "Vehicle",
    "CurrentVehicle",
    "VehicleActor",
    "VehicleComponent",
    "CurrentVehicleComponent",
    "Seat",
    "SeatIndex",
    "SeatID",
    "CurrentSeat",
    "CurrentSeatIndex",
    "VehicleSeat",
    "VehicleSeatIndex",
    "VehicleSeatID",
    "SeatTime",
    "Driver",
    "Occupant",
    "OccupyingPawn",
    "Passenger",
    "Passengers",
    "bIsDriver",
    "bDriver",
    "bDriving",
    "bInVehicle",
    "bUsingVehicle",
}

local SeatFieldNames = {
    "SeatIndex",
    "SeatID",
    "SeatName",
    "SocketName",
    "EnterSocket",
    "ExitSocket",
    "CameraSocket",
    "SeatCameraSocket",
    "Occupant",
    "OccupyingPawn",
    "Passenger",
    "Driver",
    "bDriver",
    "bIsDriver",
    "IsDriverSeat",
    "IsTurretSeat",
    "bTurret",
    "CanDrive",
    "CanFire",
    "RelativeLocation",
    "RelativeRotation",
}

local MaxPropertyHits = 24
local MaxSeatDetails = 6
local MaxStructFieldHits = 20

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

local function GetFullNameSafe(Object)
    if IsAlive(Object) then
        return Object:GetFullName()
    end

    return "<invalid>"
end

local function GetClassNameSafe(Object)
    if not IsAlive(Object) then
        return "<invalid>"
    end

    local Class = SafeCall(function()
        return Object:GetClass()
    end)
    if IsAlive(Class) then
        return Class:GetFullName()
    end

    return "<unknown class>"
end

local function SameWorld(Object, World)
    if not IsAlive(Object) or not IsAlive(World) then
        return false
    end

    local ObjectWorld = SafeCall(function()
        return Object:GetWorld()
    end)
    if not IsAlive(ObjectWorld) then
        return false
    end

    return ObjectWorld:GetFullName() == World:GetFullName()
end

local function UnwrapValue(Value, Depth)
    Depth = Depth or 0
    if Depth >= 3 or Value == nil then
        return Value
    end

    if type(Value) == "userdata" then
        local Inner = SafeCall(function()
            return Value:get()
        end)
        if Inner ~= nil and Inner ~= Value then
            return UnwrapValue(Inner, Depth + 1)
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
        local ArrayNum = SafeCall(function()
            return Value:GetArrayNum()
        end)
        if type(ArrayNum) == "number" then
            local ArrayMax = SafeCall(function()
                return Value:GetArrayMax()
            end) or ArrayNum
            return string.format("<array %d/%d>", ArrayNum, ArrayMax)
        end

        local TypeName = SafeCall(function()
            return Value:type()
        end)
        if TypeName == "FName" or TypeName == "FString" or TypeName == "FText" then
            local AsString = SafeCall(function()
                return Value:ToString()
            end)
            if AsString then
                return AsString
            end
        end

        if IsAlive(Value) then
            return Value:GetFullName()
        end

        if TypeName then
            return string.format("<userdata %s>", TypeName)
        end
    end

    return tostring(Value)
end

local function TryAddress(Object)
    if not IsAlive(Object) then
        return nil
    end

    return SafeCall(function()
        return Object:GetAddress()
    end)
end

local function TryLooseFullName(Value)
    Value = UnwrapValue(Value)
    if Value == nil then
        return nil
    end

    return SafeCall(function()
        return Value:GetFullName()
    end)
end

local function TryLooseAddress(Value)
    Value = UnwrapValue(Value)
    if Value == nil then
        return nil
    end

    return SafeCall(function()
        return Value:GetAddress()
    end)
end

local function TryTypeName(Value)
    Value = UnwrapValue(Value)
    if Value == nil then
        return nil
    end

    return SafeCall(function()
        return Value:type()
    end)
end

local function SameObject(Left, Right)
    local LeftAddress = TryLooseAddress(Left)
    local RightAddress = TryLooseAddress(Right)
    if LeftAddress ~= nil and RightAddress ~= nil then
        return LeftAddress == RightAddress
    end

    local LeftName = TryLooseFullName(Left)
    local RightName = TryLooseFullName(Right)
    if LeftName ~= nil and RightName ~= nil then
        return LeftName == RightName
    end

    return false
end

local function StringMatchesKeyword(Text)
    if type(Text) ~= "string" or Text == "" then
        return false
    end

    if ExactPropertyNames[Text] then
        return true
    end

    local Lowered = string.lower(Text)
    for _, Keyword in ipairs(KeywordFilters) do
        if string.find(Lowered, Keyword, 1, true) then
            return true
        end
    end

    return false
end

local function FormatVector(Vector)
    if not Vector then
        return "<unavailable>"
    end

    return string.format(
        "(X=%.2f, Y=%.2f, Z=%.2f)",
        Vector.X or 0.0,
        Vector.Y or 0.0,
        Vector.Z or 0.0
    )
end

local function FormatRotator(Rotator)
    if not Rotator then
        return "<unavailable>"
    end

    return string.format(
        "(Pitch=%.2f, Yaw=%.2f, Roll=%.2f)",
        Rotator.Pitch or 0.0,
        Rotator.Yaw or 0.0,
        Rotator.Roll or 0.0
    )
end

local function TryLocation(Actor)
    return SafeCall(function()
        return Actor:K2_GetActorLocation()
    end)
end

local function TryRotation(Actor)
    return SafeCall(function()
        return Actor:K2_GetActorRotation()
    end)
end

local function TryGetFunction(TargetObject, FunctionName)
    if not IsAlive(TargetObject) then
        return nil
    end

    local FoundFunction = SafeCall(function()
        return TargetObject:GetFunctionByName(FunctionName)
    end)
    if IsAlive(FoundFunction) then
        return FoundFunction
    end

    FoundFunction = SafeCall(function()
        return TargetObject:GetFunctionByNameInChain(FunctionName)
    end)
    if IsAlive(FoundFunction) then
        return FoundFunction
    end

    return nil
end

local function LogNamedFunctions(Label, Object, FunctionNames)
    if not IsAlive(Object) then
        return
    end

    for _, FunctionName in ipairs(FunctionNames) do
        local FoundFunction = TryGetFunction(Object, FunctionName)
        if IsAlive(FoundFunction) then
            Shared.Log(string.format(
                "[WTConsoleTools] %s function %s",
                Label,
                FoundFunction:GetFullName()
            ))
        end
    end
end

local function LogInterestingProperties(Label, Object)
    if not IsAlive(Object) then
        Shared.Log(string.format("[WTConsoleTools] %s <invalid>", Label))
        return
    end

    Shared.Log(string.format("[WTConsoleTools] %s object=%s", Label, GetFullNameSafe(Object)))
    Shared.Log(string.format("[WTConsoleTools] %s class=%s", Label, GetClassNameSafe(Object)))

    local CurrentClass = SafeCall(function()
        return Object:GetClass()
    end)
    local Seen = {}
    local HitCount = 0

    while IsAlive(CurrentClass) and HitCount < MaxPropertyHits do
        local ClassName = CurrentClass:GetFullName()

        SafeCall(function()
            CurrentClass:ForEachProperty(function(Property)
                if HitCount >= MaxPropertyHits then
                    return true
                end

                local PropertyName = SafeCall(function()
                    return Property:GetFName():ToString()
                end)
                if not PropertyName or Seen[PropertyName] or not StringMatchesKeyword(PropertyName) then
                    return false
                end

                Seen[PropertyName] = true
                local PropertyType = SafeCall(function()
                    return Property:GetClass():GetFName():ToString()
                end) or "<unknown>"
                local PropertyValue = SafeCall(function()
                    return Object[PropertyName]
                end)

                Shared.Log(string.format(
                    "[WTConsoleTools] %s %s (%s @ %s) = %s",
                    Label,
                    PropertyName,
                    PropertyType,
                    ClassName,
                    ValueToString(PropertyValue)
                ))
                HitCount = HitCount + 1
                return false
            end)
        end)

        CurrentClass = SafeCall(function()
            return CurrentClass:GetSuperStruct()
        end)
    end

    if HitCount >= MaxPropertyHits then
        Shared.Log(string.format("[WTConsoleTools] %s property output truncated at %d hit(s).", Label, MaxPropertyHits))
    end
end

local function AddKnownReference(KnownReferences, Label, Object)
    if Object == nil then
        return
    end

    local Address = TryLooseAddress(Object)
    local FullName = TryLooseFullName(Object)
    if Address == nil and FullName == nil then
        return
    end

    table.insert(KnownReferences, {
        Label = Label,
        Address = Address,
        FullName = FullName,
    })
end

local function FindKnownReferenceMatch(Value, KnownReferences)
    if KnownReferences == nil then
        return nil
    end

    local ValueAddress = TryLooseAddress(Value)
    if ValueAddress ~= nil then
        for _, Reference in ipairs(KnownReferences) do
            if Reference.Address ~= nil and Reference.Address == ValueAddress then
                return Reference.Label
            end
        end
    end

    local ValueName = TryLooseFullName(Value)
    if ValueName ~= nil then
        for _, Reference in ipairs(KnownReferences) do
            if Reference.FullName ~= nil and Reference.FullName == ValueName then
                return Reference.Label
            end
        end
    end

    return nil
end

local function DescribeValue(Value, KnownReferences)
    local Description = ValueToString(Value)
    local MatchLabel = FindKnownReferenceMatch(Value, KnownReferences)
    if MatchLabel ~= nil then
        return string.format("%s [matches %s]", Description, MatchLabel)
    end

    local TypeName = TryTypeName(Value)
    if Description == "<userdata UObject>" then
        local Address = TryLooseAddress(Value)
        if Address ~= nil then
            return string.format("<userdata UObject @ 0x%X>", Address)
        end

        if TypeName ~= nil then
            return string.format("<userdata %s unresolved>", TypeName)
        end
    end

    return Description
end

local function LogNamedPropertyValues(Label, Container, PropertyNames, KnownReferences)
    local HitCount = 0

    for _, PropertyName in ipairs(PropertyNames) do
        local PropertyValue = SafeCall(function()
            return Container[PropertyName]
        end)

        if PropertyValue ~= nil then
            Shared.Log(string.format(
                "[WTConsoleTools] %s %s = %s",
                Label,
                PropertyName,
                DescribeValue(PropertyValue, KnownReferences)
            ))
            HitCount = HitCount + 1
        end
    end

    return HitCount
end

local function LogStructSchema(Label, StructObject, KnownReferences)
    if not IsAlive(StructObject) then
        return false
    end

    local HitCount = 0
    local Seen = {}
    local Succeeded = SafeCall(function()
        StructObject:ForEachProperty(function(Property)
            if HitCount >= MaxStructFieldHits then
                return true
            end

            local PropertyName = SafeCall(function()
                return Property:GetFName():ToString()
            end)
            if not PropertyName or Seen[PropertyName] then
                return false
            end

            Seen[PropertyName] = true
            local PropertyType = SafeCall(function()
                return Property:GetClass():GetFName():ToString()
            end) or "<unknown>"
            local PropertyValue = SafeCall(function()
                return StructObject[PropertyName]
            end)

            Shared.Log(string.format(
                "[WTConsoleTools] %s schema %s (%s) = %s",
                Label,
                PropertyName,
                PropertyType,
                DescribeValue(PropertyValue, KnownReferences)
            ))
            HitCount = HitCount + 1
            return false
        end)
        return true
    end)

    if Succeeded and HitCount >= MaxStructFieldHits then
        Shared.Log(string.format(
            "[WTConsoleTools] %s schema output truncated at %d field(s).",
            Label,
            MaxStructFieldHits
        ))
    end

    return Succeeded == true and HitCount > 0
end

local function LogSeats(Label, VehicleComponent, KnownReferences)
    if not IsAlive(VehicleComponent) then
        return
    end

    local Seats = SafeCall(function()
        return VehicleComponent.Seats
    end)
    if Seats == nil then
        Shared.Log(string.format("[WTConsoleTools] %s seats property is unavailable.", Label))
        return
    end

    local SeatCount = SafeCall(function()
        return Seats:GetArrayNum()
    end)
    local SeatCapacity = SafeCall(function()
        return Seats:GetArrayMax()
    end) or SeatCount or 0

    if SeatCount == nil then
        Shared.Log(string.format("[WTConsoleTools] %s seats value is not an enumerable array: %s", Label, ValueToString(Seats)))
        return
    end

    Shared.Log(string.format("[WTConsoleTools] %s seats=%d/%d", Label, SeatCount, SeatCapacity))

    local LoggedSeats = 0
    if SeatCount > 0 then
        SafeCall(function()
            Seats:ForEach(function(Index, Element)
                if LoggedSeats >= MaxSeatDetails then
                    return true
                end

                local SeatObject = UnwrapValue(Element)
                LoggedSeats = LoggedSeats + 1
                local SeatLabel = string.format("%s.Seat[%d]", Label, Index - 1)
                Shared.Log(string.format("[WTConsoleTools] %s = %s", SeatLabel, DescribeValue(SeatObject, KnownReferences)))
                local NamedHits = LogNamedPropertyValues(SeatLabel, SeatObject, SeatFieldNames, KnownReferences)
                if NamedHits == 0 and IsAlive(SeatObject) then
                    LogInterestingProperties(SeatLabel, SeatObject)
                end
                if Index == 1 and IsAlive(SeatObject) then
                    if not LogStructSchema(SeatLabel, SeatObject, KnownReferences) then
                        Shared.Log(string.format("[WTConsoleTools] %s schema reflection is unavailable on this build.", SeatLabel))
                    end
                end

                return false
            end)
        end)
    end

    if SeatCount > MaxSeatDetails then
        Shared.Log(string.format(
            "[WTConsoleTools] %s seat output truncated at %d seat(s).",
            Label,
            MaxSeatDetails
        ))
    end
end

local function BuildKnownReferences(Car, CarLabel, PlayerController, PlayerPawn)
    local KnownReferences = {}

    AddKnownReference(KnownReferences, CarLabel, Car)
    AddKnownReference(KnownReferences, CarLabel .. ".Controller", SafeCall(function()
        return Car.Controller
    end))
    AddKnownReference(KnownReferences, CarLabel .. ".VehicleComponent", SafeCall(function()
        return Car.VehicleComponent
    end))
    AddKnownReference(KnownReferences, CarLabel .. ".VehicleMovement", SafeCall(function()
        return Car.VehicleMovement
    end) or SafeCall(function()
        return Car.VehicleMovementComponent
    end) or SafeCall(function()
        return Car.MovementComponent
    end))
    AddKnownReference(KnownReferences, "PlayerController", PlayerController)
    AddKnownReference(KnownReferences, "PlayerController.Pawn", PlayerPawn)
    AddKnownReference(KnownReferences, "PlayerController.PlayerState", SafeCall(function()
        return PlayerController.PlayerState
    end))
    AddKnownReference(KnownReferences, "PlayerController.Pawn.Vehicle", SafeCall(function()
        return PlayerPawn.Vehicle
    end))
    AddKnownReference(KnownReferences, "PlayerController.Pawn.VehicleComponent", SafeCall(function()
        return PlayerPawn.VehicleComponent
    end))

    return KnownReferences
end

local function LogPlayerContext(Car, CarLabel)
    local PlayerController = SafeCall(function()
        return UEHelpers.GetPlayerController()
    end)
    if not IsAlive(PlayerController) then
        Shared.Log("[WTConsoleTools] PlayerController <invalid>")
        return nil
    end

    local PlayerPawn = SafeCall(function()
        return PlayerController.Pawn
    end)
    local KnownReferences = BuildKnownReferences(Car, CarLabel, PlayerController, PlayerPawn)

    LogInterestingProperties("PlayerController", PlayerController)

    if not IsAlive(PlayerPawn) then
        Shared.Log("[WTConsoleTools] PlayerController.Pawn <invalid>")
        return KnownReferences
    end

    Shared.Log(string.format("[WTConsoleTools] PlayerController.Pawn matches %s = %s", CarLabel, tostring(SameObject(PlayerPawn, Car))))
    LogNamedFunctions("PlayerController.Pawn", PlayerPawn, PlayerFunctionNames)
    LogInterestingProperties("PlayerController.Pawn", PlayerPawn)
    LogNamedPropertyValues("PlayerController.Pawn", PlayerPawn, PlayerLinkPropertyNames, KnownReferences)

    local VehicleLink = SafeCall(function()
        return PlayerPawn.Vehicle
    end) or SafeCall(function()
        return PlayerPawn.CurrentVehicle
    end) or SafeCall(function()
        return PlayerPawn.VehicleActor
    end)
    if VehicleLink ~= nil then
        Shared.Log(string.format(
            "[WTConsoleTools] PlayerController.Pawn vehicle link matches %s = %s",
            CarLabel,
            tostring(SameObject(VehicleLink, Car))
        ))
    end

    return KnownReferences
end

local function GetCarsInCurrentWorld()
    local World = Shared.GetWorld()
    if not IsAlive(World) then
        return {}, nil
    end

    local Cars = {}
    local Objects = SafeCall(function()
        return FindAllOf("Car_C")
    end) or {}

    for _, Object in pairs(Objects) do
        if IsAlive(Object) and SameWorld(Object, World) then
            table.insert(Cars, Object)
        end
    end

    return Cars, World
end

RegisterConsoleCommandHandler("wt_probe_live_car", function(FullCommand, Parameters, Ar)
    Shared.SetOutputDevice(Ar)
    Shared.LogCommand(FullCommand)

    local Cars, World = GetCarsInCurrentWorld()
    if not IsAlive(World) then
        Shared.Log("[WTConsoleTools] No playable world is loaded yet.")
        return true
    end

    Shared.Log(string.format("[WTConsoleTools] Live car probe world: %s", World:GetFullName()))
    Shared.Log(string.format("[WTConsoleTools] Live car count in current world: %d", #Cars))

    if #Cars == 0 then
        Shared.Log("[WTConsoleTools] No Car_C actor is currently alive in this world.")
        return true
    end

    local RequestedIndex = tonumber(Parameters[1] or "1") or 1
    if RequestedIndex < 1 or RequestedIndex > #Cars then
        Shared.Log(string.format("[WTConsoleTools] Car index %d is out of range. Valid range: 1-%d", RequestedIndex, #Cars))
        return true
    end

    local Car = Cars[RequestedIndex]
    local Label = string.format("Car_C[%d]", RequestedIndex)
    local Address = SafeCall(function()
        return Car:GetAddress()
    end)

    Shared.Log(string.format("[WTConsoleTools] Inspecting %s: %s", Label, GetFullNameSafe(Car)))
    if Address then
        Shared.Log(string.format("[WTConsoleTools] %s address=0x%X", Label, Address))
    end
    Shared.Log(string.format("[WTConsoleTools] %s location=%s", Label, FormatVector(TryLocation(Car))))
    Shared.Log(string.format("[WTConsoleTools] %s rotation=%s", Label, FormatRotator(TryRotation(Car))))
    LogInterestingProperties(Label, Car)
    local KnownReferences = LogPlayerContext(Car, Label)

    local Controller = SafeCall(function()
        return Car.Controller
    end)
    if IsAlive(Controller) then
        LogNamedFunctions(Label .. ".Controller", Controller, ControllerFunctionNames)
        LogInterestingProperties(Label .. ".Controller", Controller)
    else
        Shared.Log(string.format("[WTConsoleTools] %s.Controller <invalid>", Label))
    end

    local VehicleMovement = SafeCall(function()
        return Car.VehicleMovement
    end) or SafeCall(function()
        return Car.VehicleMovementComponent
    end) or SafeCall(function()
        return Car.MovementComponent
    end)
    if IsAlive(VehicleMovement) then
        LogNamedFunctions(Label .. ".VehicleMovement", VehicleMovement, MovementFunctionNames)
        LogInterestingProperties(Label .. ".VehicleMovement", VehicleMovement)
    else
        Shared.Log(string.format("[WTConsoleTools] %s.VehicleMovement <invalid>", Label))
    end

    local VehicleComponent = SafeCall(function()
        return Car.VehicleComponent
    end)
    if IsAlive(VehicleComponent) then
        LogNamedFunctions(Label .. ".VehicleComponent", VehicleComponent, VehicleComponentFunctionNames)
        LogInterestingProperties(Label .. ".VehicleComponent", VehicleComponent)
        LogSeats(Label .. ".VehicleComponent", VehicleComponent, KnownReferences)
    else
        Shared.Log(string.format("[WTConsoleTools] %s.VehicleComponent <invalid>", Label))
    end

    local Turret = SafeCall(function()
        return Car.Turret
    end)
    if Turret ~= nil then
        LogInterestingProperties(Label .. ".Turret", Turret)
    end

    return true
end)
