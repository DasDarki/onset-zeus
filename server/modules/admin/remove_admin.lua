local config = require('packages/' .. GetPackageName() .. '/server/io/config')

local mod = {
    name = "Remove Admin",
    description = "Removes a Players Admin Privileges",
    ui_component = "P(Target)?T(SteamID64)?"
}

function mod:GetName()
    return mod.name
end

function mod:GetTarget(player, args)
    local target = nil

    if args[1] ~= nil and IsValidPlayer(args[1]) then
        target = args[1]
    elseif args[2] ~= nil then
        target = args[2]
    end

    if target == nil then
        AddPlayerChat(player, FormatMsg("msg-argument-invalid", "Target"))
        return nil
    end

    return target
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
    if _G.zeus.RemoveAdmin(target) == false then
        AddPlayerChat(executor, FormatMsg("msg-mod-failed", mod.name, "the player is not an admin"))
        return nil
    end

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