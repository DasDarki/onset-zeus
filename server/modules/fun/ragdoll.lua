local config = require('packages/' .. GetPackageName() .. '/server/io/config')

local mod = {
    name = "Ragdoll",
    description = "Ragdolls yourself or a player",
    ui_component = "P?"
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
    return true -- Whether the module is toggleable or not
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

function mod:Activate(player, target, args)
    SetPlayerRagdoll(target, true)
    AddPlayerChat(player, FormatMsg("msg-mod-success", mod.name))
    return true -- Return false, if any error occurred, or return nil if any error occurred, but the messaging was managed in the function itself
end

function mod:Deactivate(player, target, args)
    SetPlayerRagdoll(target, false)

    if IsValidPlayer(player) then
        AddPlayerChat(player, FormatMsg("msg-mod-disabled", mod.name))
    end
end

return mod