local config = require('packages/' .. GetPackageName() .. '/server/io/config')

local mod = {
    name = "Tempban",
    description = "Bans a Player for a specific Time (y = years, M = months, w = weeks, d = days, h = hours, m = minutes, s = seconds)",
    ui_component = "P(Target)T(Time)T(Reason)"
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
    return false -- Whether the module is toggleable or not
end

function mod:Activate(executor, target, args)
    if args[1] == nil then
        AddPlayerChat(executor, FormatMsg("msg-argument-missing", "Player"))
        return nil
    end

    if not IsValidPlayer(args[1]) then
        AddPlayerChat(executor, FormatMsg("msg-argument-invalid", "Player"))
        return nil
    end

    if args[2] == nil then
        AddPlayerChat(executor, FormatMsg("msg-argument-missing", "Time"))
        return nil
    end

    if args[3] == nil then
        AddPlayerChat(executor, FormatMsg("msg-argument-missing", "Reason"))
        return nil
    end

    _G.zeus.TempBan(args[1], args[2], args[3])
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