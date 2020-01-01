local config = require('packages/' .. GetPackageName() .. '/server/io/config')

local mod = {
    name = "Spectate",
    description = "Change the current Player State to the Spectatore Mode",
    ui_component = "P?"
}

function mod:GetName()
    return mod.name
end

function mod:GetTarget(player, args)
    local target = player

    if args[1] ~= nil then
        if IsValidPlayer(args[1]) then
            target = args[1]
        end
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
    SetPlayerSpectate(target, true)
    AddPlayerChat(executor, FormatMsg("msg-mod-success", mod.name))
    return true -- Return false, if any error occurred, or return nil if any error occurred, but the messaging was managed in the function itself
end

function mod:Deactivate(executor, target, args)
    SetPlayerSpectate(target, false)

    if IsValidPlayer(executor) then
        AddPlayerChat(executor, FormatMsg("msg-mod-disabled", mod.name))
    end
end

return mod