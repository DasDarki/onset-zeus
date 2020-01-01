local config = require('packages/' .. GetPackageName() .. '/server/io/config')

local mod = {
    name = "Equip Weapon",
    description = "Change the Weapon Equipment Slot (Arg1: Slot)",
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
    local slot = 0

    if args[1] ~= nil then
        slot = tonumber(args[1])

        if slot == nil then
            AddPlayerChat(executor, FormatMsg("msg-argument-invalid", "Slot"))
            return
        else
            if slot < 0 or slot > 3 then
                AddPlayerChat(executor, FormatMsg("msg-argument-invalid", "Slot"))
                return nil
            end
        end
    else
        AddPlayerChat(executor, FormatMsg("msg-argument-missing", "Slot"))
        return
    end

    EquipPlayerWeaponSlot(target, slot)
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