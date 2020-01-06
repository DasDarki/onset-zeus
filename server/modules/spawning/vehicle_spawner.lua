local config = require('packages/' .. GetPackageName() .. '/server/io/config')

local mod = {
    name = "Vehicle Spawner",
    description = "Spawns the wanted Vehicle and sets the Player into it",
    ui_component = "N(Vehicle Model)"
}

function mod:GetName()
    return mod.name
end

function mod:GetTarget(player, args)
    return player -- Return the target of this module
end

function mod:GetUIComponent()
    return mod.ui_component
end

function mod:GetDescription()
    return mod.description
end

function mod:IsToggleable()
    return false
end

function mod:Activate(executor, target, args)
    if args[1] == nil then
        AddPlayerChat(executor, FormatMsg("msg-argument-missing", "Model"))
        return nil
    end

    local model = tonumber(args[1])
    if model == nil then
        model = 0
    end

    if (model < 1 or model > 25) then
        return AddPlayerChat(executor, FormatMsg("msg-veh-model-not-exist", model))
    end

    local x, y, z = GetPlayerLocation(executor)
    local h = GetPlayerHeading(executor)

    local vehicle = CreateVehicle(model, x, y, z, h)
    if (vehicle == false) then
        return false
    end

    SetVehicleLicensePlate(vehicle, "ZEUS")
    AttachVehicleNitro(vehicle, true)
    SetPlayerInVehicle(executor, vehicle)

    AddPlayerChat(executor, FormatMsg("msg-mod-success", mod.name))
    return true -- Return false, if any error occurred
end

function mod:Deactivate(executor, target, args)
    -- PLACE DEACTIVATION CODE HERE
    -- CAN BE IGNORED IF TOGGLEABLE IS FALSE
end

return mod