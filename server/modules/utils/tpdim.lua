local config = require('packages/' .. GetPackageName() .. '/server/io/config')

local mod = {
    name = "TPDim",
    description = "Teleports a Player into another Dimension (Arg1: Dimension)",
    ui_component = "NP?"
}

function mod:GetName()
    return mod.name
end

function mod:GetTarget(player, args)
    local target = player

    if args[2] ~= nil then
        if IsValidPlayer(args[2]) then
            target = args[2]
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
    return false -- Whether the module is toggleable or not
end

function mod:Activate(executor, target, args)
    local dim = 0

    if args[1] ~= nil then
        dim = tonumber(args[1])

        if dim == nil then
            AddPlayerChat(executor, FormatMsg("msg-argument-invalid", "Dimension"))
            return
        else
            if dim < 0 or dim > 4294967295 then
                AddPlayerChat(executor, FormatMsg("msg-argument-invalid", "Dimension"))
                return nil
            end
        end
    else
        AddPlayerChat(executor, FormatMsg("msg-argument-invalid", "Dimension"))
        return
    end

    SetPlayerDimension(target, dim)
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