local config = require('packages/' .. GetPackageName() .. '/server/io/config')

local mod = {
    name = "TPPos",
    description = "Teleports yourself to the given X, Y, Z coordinates",
    ui_component = "NNN"
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
    return player -- Return the target of this module
end

function mod:Activate(player, target, args)
    if args[1] == nil then
        AddPlayerChat(player, FormatMsg("msg-argument-missing", "X"))
        return nil
    end
    if args[2] == nil then
        AddPlayerChat(player, FormatMsg("msg-argument-missing", "Y"))
        return nil
    end
    if args[3] == nil then
        AddPlayerChat(player, FormatMsg("msg-argument-missing", "Z"))
        return nil
    end

    SetPlayerLocation(player, args[1], args[2], args[3])
    AddPlayerChat(player, FormatMsg("msg-mod-success", mod.name))
    return true -- Return false, if any error occurred, or return nil if any error occurred, but the messaging was managed in the function itself
end

function mod:Deactivate(player, args)
    -- PLACE DEACTIVATION CODE HERE
    -- CAN BE IGNORED IF TOGGLEABLE IS FALSE
end

return mod