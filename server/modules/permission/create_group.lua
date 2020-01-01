local config = require('packages/' .. GetPackageName() .. '/server/io/config')

local mod = {
    name = "Create Group",
    description = "Creates a new Group (Arg1: Name)",
    ui_component = "T"
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
        AddPlayerChat(executor, FormatMsg("msg-argument-missing", "Name"))
        return nil
    end

    _G.zeus.CreateGroup(args[1])
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