local zeus = { _VERSION = "1.1:0" }
local date = require('packages/' .. GetPackageName() .. '/server/libs/date')
local config = require('packages/' .. GetPackageName() .. '/server/io/config')
local storage
if IsLocalStorage() then
    storage = require('packages/' .. GetPackageName() .. '/server/io/storage/local')
else
    storage = require('packages/' .. GetPackageName() .. '/server/io/storage/mysql')
end

function zeus.IsDateExpired(val)
    local str = tostring(val)
    if str == "-1" then
        return false
    end

    return date(str) < date()
end

function zeus.FormatDate(val)
    local str = tostring(val)
    if string.match(str, "P") then
        return "-1"
    end
    local current = date()

    local years = 0
    local months = 0
    local weeks = 0 -- needs to calculated in days
    local days = 0
    local hours = 0
    local minutes = 0
    local seconds = 0

    local num = ""
    for i = 1, #str do
        local c = str:sub(i, i)
        if c == "y" then
            local v = tonumber(num)
            if v == nil then
                error(num .. " is not a number!")
                return
            end
            years = years + v
            num = ""
        elseif c == "M" then
            local v = tonumber(num)
            if v == nil then
                error(num .. " is not a number!")
                return
            end
            months = months + v
            num = ""
        elseif c == "w" then
            local v = tonumber(num)
            if v == nil then
                error(num .. " is not a number!")
                return
            end
            weeks = weeks + v
            num = ""
        elseif c == "d" then
            local v = tonumber(num)
            if v == nil then
                error(num .. " is not a number!")
                return
            end
            days = days + v
            num = ""
        elseif c == "h" then
            local v = tonumber(num)
            if v == nil then
                error(num .. " is not a number!")
                return
            end
            hours = hours + v
            num = ""
        elseif c == "m" then
            local v = tonumber(num)
            if v == nil then
                error(num .. " is not a number!")
                return
            end
            minutes = minutes + v
            num = ""
        elseif c == "s" then
            local v = tonumber(num)
            if v == nil then
                error(num .. " is not a number!")
                return
            end
            seconds = seconds + v
            num = ""
        else
            num = num .. c
        end
    end

    current:addyears(years)
    current:addmonths(months)
    current:adddays(days + weeks * 7)
    current:addhours(hours)
    current:addminutes(minutes)
    current:addseconds(seconds)
    return current:fmt("%F %T")
end

function zeus.GetStorageType()
    return config["store-type"]
end
AddFunctionExport("GetStorageType", zeus.GetStorageType);

function zeus.IsAdmin(player)
    local steam = player
    if IsValidPlayer(player) then
        steam = GetPlayerSteamId(player)
    end

    return storage:IsAdmin(player)
end
AddFunctionExport("IsAdmin", zeus.IsAdmin);

function zeus.MakeAdmin(player)
    local steam = player
    if IsValidPlayer(player) then
        steam = GetPlayerSteamId(player)
    end

    local result = storage:MakeAdmin(player, true)
    _G.zeus.RefreshPlayer(player)
    return result
end
AddFunctionExport("MakeAdmin", zeus.MakeAdmin);

function zeus.RemoveAdmin(player)
    local steam = player
    if IsValidPlayer(player) then
        steam = GetPlayerSteamId(player)
    end

    local result = storage:MakeAdmin(player, false)
    _G.zeus.RefreshPlayer(player)
    return result
end
AddFunctionExport("RemoveAdmin", zeus.RemoveAdmin);

function zeus.Unban(player)
    return storage:Unban(player)
end
AddFunctionExport("Unban", zeus.Unban);

function zeus.TempBan(player, time, reason)
    local ret = storage:TempBan(player, time, reason)
    KickPlayer(player, FormatMsg("msg-banned", reason))
    return ret
end
AddFunctionExport("TempBan", zeus.TempBan);

function zeus.Ban(player, reason)
    return zeus.TempBan(player, "P", reason)
end
AddFunctionExport("Ban", zeus.Ban);

-- First: true or false (if player is banned), Second: the ban reason
function zeus.IsBanned(player)
    local banned, reason = storage:IsBanned(player)
    if not banned then
        zeus.Unban(player)
    end
    return banned, reason
end
AddFunctionExport("IsBanned", zeus.IsBanned);

function zeus.HasPermission(player, permission)
    return storage:HasPermission(player, permission)
end
AddFunctionExport("HasPermission", zeus.HasPermission);

function zeus.HasGroup(player, group)
    return storage:HasGroup(player, group)
end
AddFunctionExport("HasGroup", zeus.HasGroup);

function zeus.AddGroup(player, group)
    local result = storage:AddGroup(player, group)
    _G.zeus.RefreshPlayer(player)
    return result
end
AddFunctionExport("AddGroup", zeus.AddGroup);

function zeus.GetGroup(player)
    return storage:GetGroup(player)
end
AddFunctionExport("GetGroup", zeus.GetGroup);

function zeus.RemoveGroup(player, group)
    local result = storage:RemoveGroup(player, group)
    _G.zeus.RefreshPlayer(player)
    return result
end
AddFunctionExport("RemoveGroup", zeus.RemoveGroup);

function zeus.ExistsGroup(group)
    return storage:ExistsGroup(group)
end
AddFunctionExport("ExistsGroup", zeus.ExistsGroup);

function zeus.CreateGroup(group)
    return storage:CreateGroup(group)
end
AddFunctionExport("CreateGroup", zeus.CreateGroup);

function zeus.DeleteGroup(group)
    local result = storage:DeleteGroup(group)
    for _, v in pairs(GetAllPlayers()) do
        _G.zeus.RefreshPlayer(v)
    end
    return result
end
AddFunctionExport("DeleteGroup", zeus.DeleteGroup);

function zeus.AddPermission(group, permission)
    local result = storage:AddPermission(group, permission)
    for _, v in pairs(GetAllPlayers()) do
        if zeus.HasGroup(v, group) then
            _G.zeus.RefreshPlayer(v)
        end
    end
    return result
end
AddFunctionExport("AddPermission", zeus.AddPermission);

function zeus.RemovePermission(group, permission)
    local result = storage:RemovePermission(group, permission)
    for _, v in pairs(GetAllPlayers()) do
        if zeus.HasGroup(v, group) then
            _G.zeus.RefreshPlayer(v)
        end
    end
    return result
end
AddFunctionExport("RemovePermission", zeus.RemovePermission);

function zeus.AddPlayerPermission(player, permission)
    local result = storage:AddPlayerPermission(player, permission)
    _G.zeus.RefreshPlayer(player)
    return result
end
AddFunctionExport("AddPlayerPermission", zeus.AddPlayerPermission);

function zeus.RemovePlayerPermission(player, permission)
    local result = storage:RemovePlayerPermission(player, permission)
    _G.zeus.RefreshPlayer(player)
    return result
end
AddFunctionExport("RemovePlayerPermission", zeus.RemovePlayerPermission);

function zeus.HasGroupPermission(group, permission)
    return storage:HasGroupPermission(group, permission)
end
AddFunctionExport("HasGroupPermission", zeus.HasGroupPermission);

function zeus.AddPermCommand(commandName, permission, commandFunc)
    AddCommand(commandName, function(player, ...)
        if zeus.HasPermission(player, permission) then
            commandFunc(player, ...)
        else
            AddPlayerChat(player, config["msg-no-permission"])
        end
    end)
end
AddFunctionExport("AddPermCommand", zeus.AddPermCommand);

_G.zeus = zeus
return zeus