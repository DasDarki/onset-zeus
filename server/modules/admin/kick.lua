local config = require('packages/' .. GetPackageName() .. '/server/io/config')

local mod = {
    name = "Kick",
    description = "Kicks a player",
    ui_component = "P(Target)T(Reason)"
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

    return args[1]
end

function mod:Activate(player, target, args)
    local current = 0
    local reason = ""
    for _, value in ipairs(args) do
        if current == 0 then
            current = current + 1
        else
            if reason == "" then
                reason = value
            else
                reason = reason .. " " .. value
            end
        end
    end

    KickPlayer(target, reason)
    AddPlayerChat(player, FormatMsg("msg-mod-success", mod.name))
    return true -- Return false, if any error occurred, or return nil if any error occurred, but the messaging was managed in the function itself
end

function mod:Deactivate(player, target, args)
    -- PLACE DEACTIVATION CODE HERE
    -- CAN BE IGNORED IF TOGGLEABLE IS FALSE
end

return mod