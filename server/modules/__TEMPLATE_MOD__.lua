local config = require('packages/' .. GetPackageName() .. '/server/io/config')

local mod = {
    name = "NAME_OF_MODULE",
    description = "DESCRIPTION_OF_MODULE",
    ui_component = "UI_COMPONENT_OF_MODULE"
}

function mod:GetName()
    return mod.name
end

function mod:GetTarget(player, args)
    return player
end

function mod:GetUIComponent()
    -- The UI component is the structure of the UI. The UI manager from Zeus will transform this string to a form
    -- The form can than be used by the players to input the arguments. There are some default UI controls listed below.
    -- [P] Player Select. Selects a player from a list with all online players
    -- [T] Text Input. Takes text input from the player
    -- [N] Number(float) Input. Takes number input from the player
    -- Add a ? after the Component if it is optional
    -- You can also Name components via Brackets, like: P(Test), then in the Placeholder of this Player Select stands "Test", the optional marker must be at the end ()?
    -- Example. PT? - Player must be entered, Text can be entered, but did not need to
    return mod.ui_component
end

function mod:GetDescription()
    return mod.description
end

function mod:IsToggleable()
    return false -- Whether the module is toggleable or not
end

function mod:Activate(executor, target, args)
    -- PLACE ACTIVATION CODE HERE

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