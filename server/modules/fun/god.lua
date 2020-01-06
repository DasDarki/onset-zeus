local config = require('packages/' .. GetPackageName() .. '/server/io/config')

local mod = {
    name = "God",
    description = "Enable / Disable God Mode",
    ui_component = "P(Target)?"
}

function mod:GetName()
    return mod.name
end

function mod:GetTarget(player, args)
    local target = nil

    if args[1] ~= nil then
        target = args[1]

        if not IsValidPlayer(target) then
            target = nil
        end
    end

    if target == nil then
        target = player
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
    return true -- Whether the module is toggleable or not
end

function mod:Activate(executor, target, args)
    SetPlayerPropertyValue(target, "zeus-god", true, true)
    AddPlayerChat(executor, FormatMsg("msg-mod-success", mod.name))
    return true -- Return false, if any error occurred, or return nil if any error occurred, but the messaging was managed in the function itself
end

function mod:Deactivate(executor, target, args)
    SetPlayerPropertyValue(target, "zeus-god", nil, true)
    if IsValidPlayer(executor) then
        AddPlayerChat(executor, FormatMsg("msg-mod-disabled", mod.name))
    end
end

function OnPlayerDamage(player, damagetype, amount)
    local god = GetPlayerPropertyValue(player, "zeus-god")
    if god ~= nil then
        if god == true then
            local health = GetPlayerHealth(player)
            SetPlayerHealth(player, health + amount)
        end
    end
end
AddEvent("OnPlayerDamage", OnPlayerDamage)

return mod