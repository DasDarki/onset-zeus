local config = require('packages/' .. GetPackageName() .. '/server/io/config')

local mod = {
    name = "Kill Player",
    description = "Kills the given Player",
    ui_component = "P(Target)"
}

function mod:GetName()
    return mod.name
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

    return args[1]
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

function mod:Activate(executor, target, args)
    SetPlayerHealth(target, 0)
    AddPlayerChat(executor, FormatMsg("msg-mod-success", mod.name))
    return true -- Return false, if any error occurred, or return nil if any error occurred, but the messaging was managed in the function itself
end

function mod:Deactivate(executor, target, args)
    -- PLACE DEACTIVATION CODE HERE
    -- CAN BE IGNORED IF TOGGLEABLE IS FALSE
    if IsValidPlayer(executor) then
        AddPlayerChat(executor, FormatMsg("msg-mod-disabled", mod.name))
    end
end

return mod