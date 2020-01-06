local config = require('packages/' .. GetPackageName() .. '/server/io/config')

local mod = {
    name = "Heal",
    description = "Heal yourself or another player",
    ui_component = "N(Amount)?P(Target)?"
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
    local target = nil

    if args[2] ~= nil then
        target = args[2]

        if not IsValidPlayer(target) then
            target = nil
        end
    end

    if target == nil then
        target = player
    end

    return target
end

function mod:Activate(player, target, args)
    local amount = 0

    if args[1] ~= nil then
        amount = tonumber(args[1])

        if amount == nil then
            amount = 0
        end
    end

    if amount <= 0 then
        amount = 100
    end

    SetPlayerHealth(target, amount)
    AddPlayerChat(player, FormatMsg("msg-mod-success", mod.name))
    return true -- Return false, if any error occurred, or return nil if any error occurred, but the messaging was managed in the function itself
end

function mod:Deactivate(player, args)
    -- PLACE DEACTIVATION CODE HERE
    -- CAN BE IGNORED IF TOGGLEABLE IS FALSE
end

return mod