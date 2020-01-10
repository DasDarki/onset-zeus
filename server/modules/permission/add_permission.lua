local config = require('packages/' .. GetPackageName() .. '/server/io/config')

local mod = {
    name = "Add Permission",
    description = "Adds a Permission to the Group",
    ui_component = "T(Group)T(Permission)"
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
        AddPlayerChat(executor, FormatMsg("msg-argument-missing", "Group"))
        return nil
    end

    if args[2] == nil then
        AddPlayerChat(executor, FormatMsg("msg-argument-missing", "Permission"))
        return nil
    end

    if _G.zeus.AddPermission(args[1], args[2]) == false then
        AddPlayerChat(executor, FormatMsg("msg-mod-failed", mod.name, "the group is not existing"))
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