local ESX = exports["es_extended"]:getSharedObject()
local vehicleMenuActive = false
local allowedToStartEngine = {}

CreateThread(function()
    while true do
        Wait(500)
        local ped = PlayerPedId()
        local vehicle = GetVehiclePedIsIn(ped, false)

        if vehicle ~= 0 and GetPedInVehicleSeat(vehicle, -1) == ped then
            if not allowedToStartEngine[vehicle] then
                SetVehicleEngineOn(vehicle, false, true, true)
            end
        end
    end
end)

local function isPlayerNearVehicle()
    local ped = PlayerPedId()
    local vehicle = GetVehiclePedIsIn(ped, false)
    
    if vehicle ~= 0 then
        return vehicle, true 
    end
    
    local pos = GetEntityCoords(ped)
    vehicle = GetClosestVehicle(pos.x, pos.y, pos.z, 5.0, 0, 71)
    
    if vehicle ~= 0 then
        local vehPos = GetEntityCoords(vehicle)
        local distance = #(pos - vehPos)
        if distance <= 3.0 then
            return vehicle, false 
        end
    end
    
    return nil, false
end

local function toggleDoor(vehicle, doorIndex, doorName)
    local isDoorOpen = GetVehicleDoorAngleRatio(vehicle, doorIndex) > 0.1
    if isDoorOpen then
        SetVehicleDoorShut(vehicle, doorIndex, false)
        ESX.ShowNotification("~g~" .. doorName .. " closed")
    else
        SetVehicleDoorOpen(vehicle, doorIndex, false, false)
        ESX.ShowNotification("~g~" .. doorName .. " opened")
    end
end

local function toggleWindow(vehicle, windowIndex, windowName)
    local isWindowDown = not IsVehicleWindowIntact(vehicle, windowIndex)
    if isWindowDown then
        RollUpWindow(vehicle, windowIndex)
        ESX.ShowNotification("~g~" .. windowName .. " rolled up")
    else
        RollDownWindow(vehicle, windowIndex)
        ESX.ShowNotification("~g~" .. windowName .. " rolled down")
    end
end

local function toggleEngine(vehicle)
    local isEngineOn = GetIsVehicleEngineRunning(vehicle)

    if isEngineOn then
        SetVehicleEngineOn(vehicle, false, true, true)
        allowedToStartEngine[vehicle] = false
        ESX.ShowNotification("~r~Engine turned off")
    else
        allowedToStartEngine[vehicle] = true
        SetVehicleEngineOn(vehicle, true, false, true)
        ESX.ShowNotification("~g~Engine turned on")
    end
end

lib.registerRadial({
    id = 'vehicle_doors',
    items = {
        {
            label = 'Front Left',
            icon = 'door-open',
            onSelect = function()
                local vehicle = isPlayerNearVehicle()
                if vehicle then
                    toggleDoor(vehicle, 0, "Front Left Door")
                end
            end
        },
        {
            label = 'Front Right',
            icon = 'door-open',
            onSelect = function()
                local vehicle = isPlayerNearVehicle()
                if vehicle then
                    toggleDoor(vehicle, 1, "Front Right Door")
                end
            end
        },
        {
            label = 'Rear Left',
            icon = 'door-open',
            onSelect = function()
                local vehicle = isPlayerNearVehicle()
                if vehicle then
                    toggleDoor(vehicle, 2, "Rear Left Door")
                end
            end
        },
        {
            label = 'Rear Right',
            icon = 'door-open',
            onSelect = function()
                local vehicle = isPlayerNearVehicle()
                if vehicle then
                    toggleDoor(vehicle, 3, "Rear Right Door")
                end
            end
        },
        {
            label = 'Hood',
            icon = 'car',
            onSelect = function()
                local vehicle = isPlayerNearVehicle()
                if vehicle then
                    toggleDoor(vehicle, 4, "Hood")
                end
            end
        },
        {
            label = 'Trunk',
            icon = 'suitcase',
            onSelect = function()
                local vehicle = isPlayerNearVehicle()
                if vehicle then
                    toggleDoor(vehicle, 5, "Trunk")
                end
            end
        }
    }
})

lib.registerRadial({
    id = 'vehicle_windows',
    items = {
        {
            label = 'Front Left',
            icon = 'arrow-down',
            onSelect = function()
                local vehicle = isPlayerNearVehicle()
                if vehicle then
                    toggleWindow(vehicle, 0, "Front Left Window")
                end
            end
        },
        {
            label = 'Front Right',
            icon = 'arrow-down',
            onSelect = function()
                local vehicle = isPlayerNearVehicle()
                if vehicle then
                    toggleWindow(vehicle, 1, "Front Right Window")
                end
            end
        },
        {
            label = 'Rear Left',
            icon = 'arrow-down',
            onSelect = function()
                local vehicle = isPlayerNearVehicle()
                if vehicle then
                    toggleWindow(vehicle, 2, "Rear Left Window")
                end
            end
        },
        {
            label = 'Rear Right',
            icon = 'arrow-down',
            onSelect = function()
                local vehicle = isPlayerNearVehicle()
                if vehicle then
                    toggleWindow(vehicle, 3, "Rear Right Window")
                end
            end
        }
    }
})

local function addVehicleMenuItems()
    local vehicle, isInside = isPlayerNearVehicle()
    if not vehicle then return end

    lib.addRadialItem({
        id = 'vehicle_doors',
        label = 'Doors',
        icon = 'door-open',
        menu = 'vehicle_doors'
    })

    lib.addRadialItem({
        id = 'vehicle_windows',
        label = 'Windows',
        icon = 'window-maximize',
        menu = 'vehicle_windows'
    })

    if isInside and GetPedInVehicleSeat(vehicle, -1) == PlayerPedId() then
        lib.addRadialItem({
            id = 'vehicle_engine',
            label = 'Engine',
            icon = 'power-off',
            onSelect = function()
                local veh = isPlayerNearVehicle()
                if veh then
                    toggleEngine(veh)
                end
            end
        })
    end

    lib.addRadialItem({
        id = 'close_all_doors',
        label = 'Close All\nDoors',
        icon = 'times-circle',
        onSelect = function()
            local veh = isPlayerNearVehicle()
            if veh then
                for i = 0, 5 do
                    SetVehicleDoorShut(veh, i, false)
                end
                ESX.ShowNotification("~g~All doors closed")
            end
        end
    })

    lib.addRadialItem({
        id = 'roll_up_windows',
        label = 'Roll Up\nWindows',
        icon = 'arrow-up',
        onSelect = function()
            local veh = isPlayerNearVehicle()
            if veh then
                for i = 0, 3 do
                    RollUpWindow(veh, i)
                end
                ESX.ShowNotification("~g~All windows rolled up")
            end
        end
    })

    vehicleMenuActive = true
end


local function removeVehicleMenuItems()
    if not vehicleMenuActive then return end
    
    vehicleMenuActive = false
    
    lib.removeRadialItem('vehicle_doors')
    lib.removeRadialItem('vehicle_windows')
    lib.removeRadialItem('vehicle_engine')
    lib.removeRadialItem('close_all_doors')
    lib.removeRadialItem('roll_up_windows')
end

-- check proximity
local lastVehicle = nil

CreateThread(function()
    while true do
        local ped = PlayerPedId()
        local vehicle = GetVehiclePedIsIn(ped, false)

        if vehicle ~= lastVehicle then
            lastVehicle = vehicle

            if vehicle ~= 0 and GetPedInVehicleSeat(vehicle, -1) == ped then
                addVehicleMenuItems()
            else
                removeVehicleMenuItems()
            end
        end

        Wait(500)
    end
end)

AddEventHandler('onResourceStop', function(resourceName)
    if GetCurrentResourceName() == resourceName then
        removeVehicleMenuItems()
    end
end)