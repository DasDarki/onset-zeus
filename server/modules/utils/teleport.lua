local config = require('packages/' .. GetPackageName() .. '/server/io/config')

local mod = {
    name = "Teleport",
    description = "Teleports yourself to a player",
    ui_component = "P"
}

function mod:GetName()
    return mod.name
end

function mod:GetUIComponent()
    return mod.ui_component
end

function mod:GetDescription()
    return mod.description
end

function mod:IsToggleable()
    return false -- Whether the module is toggleable or not
end

function mod:GetTarget(player, args)
    if args[1] == nil then
        AddPlayerChat(player, FormatMsg("msg-argument-missing", "Player"))
        return nil
    end

    if not IsValidPlayer(args[1]) then
        AddPlayerChat(player, FormatMsg("msg-argument-invalid", "Player"))
        return nil
    end

    return args[1] -- Return the target of this module
end

function mod:Activate(player, target, args)
    local x, y, z = GetPlayerLocation(target)
    SetPlayerLocation(player, x, y, z)
    AddPlayerChat(player, FormatMsg("msg-mod-success", mod.name))
    return true -- Return false, if any error occurred, or return nil if any error occurred, but the messaging was managed in the function itself
end

function mod:Deactivate(player, args)
    -- PLACE DEACTIVATION CODE HERE
    -- CAN BE IGNORED IF TOGGLEABLE IS FALSE
end

return mod