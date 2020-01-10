local storage = require('packages/' .. GetPackageName() .. '/server/io/storage')
local config = require('packages/' .. GetPackageName() .. '/server/io/config')
local store = { _VERSION = "1.0:0" }
local groups = storage.Load("groups", function()
    local new = {}
    new["def_group"] = {
        permissions = {},
        format = "[Player] %display_name%: %message%"
    }
    return new
end)
local players = storage.Load("players", function()
    return {}
end)
local admins = storage.Load("admins", function()
    return {}
end)

function format(player)
    if IsValidPlayer(player) then
        return tostring(GetPlayerSteamId(player))
    end

    return nil
end

function hasPermission(player, playerId, permission)
    if store:IsAdmin(player) then
        return true
    end

    if players[player] == nil then
        return false
    end

    if players[player]["permissions"] == nil then
        return false
    end

    if containsValue(players[player]["permissions"], permission) then
        return true
    end

    if store:HasGroupPermission(store:GetGroup(playerId), permission) then
        return true
    end
    return false
end

function split(inputstr, sep)
    if sep == nil then
        sep = "%s"
    end
    local t = {}
    for str in string.gmatch(inputstr, "([^" .. sep .. "]+)") do
        t[#t + 1] = str
    end
    return t
end

function formatPermissions(permission)
    local permissions = {}
    permissions[#permissions + 1] = "*"
    permissions[#permissions + 1] = permission

    local parts = split(permission, ".")
    local len = #parts - 1
    if len >= 1 then
        for i = 1, len do
            local newPermission = ""
            for j = 1, i do
                if newPermission == "" then
                    newPermission = parts[j]
                else
                    newPermission = newPermission .. "." .. parts[j]
                end
            end
            permissions[#permissions + 1] = newPermission .. ".*"
        end
    end
    return permissions
end

function containsValue(table, val)
    for _, v in ipairs(table) do
        if v == val then
            return true
        end
    end
    return false
end

function getKey(table, val)
    for key, v in ipairs(table) do
        if v == val then
            return key
        end
    end
    return nil
end

function removeValue(table, val)
    local key = getKey(table, val)
    if key ~= nil then
        table[key] = nil
    end
end

function initPlayer(player)
    if players[tostring(player)] == nil then
        players[tostring(player)] = {
            permissions = {},
            group = "def_group"
        }
    end
end

function returnSteam(id)
    local steamId = id

    if IsValidPlayer(id) then
        steamId = tostring(GetPlayerSteamId(id))
    end

    initPlayer(steamId)
    return steamId
end

function store:IsAdmin(playerId)
    if config["dev-mode"] == true then
        return true
    end

    local steamId = returnSteam(playerId)
    return containsValue(admins, tostring(steamId))
end

function store:MakeAdmin(playerId, enable)
    local steamId = returnSteam(playerId)
    if enable == true then
        if not containsValue(admins, tostring(steamId)) then
            admins[#admins + 1] = tostring(steamId)
            return true
        end
    else
        if containsValue(admins, tostring(steamId)) then
            removeValue(admins, tostring(steamId))
            return true
        end
    end

    return false
end

function store:Unban(playerId)
    local player = tostring(playerId)
    if players[player] ~= nil then
        players[player]["ban"] = nil
    end
end

function store:TempBan(playerId, time, reasonText)
    local player = format(playerId)
    if player == nil then
        return false
    end

    initPlayer(player)
    local date = _G.zeus.FormatDate(time)
    players[player]["ban"] = {
        exp = date,
        reason = reasonText
    }
    return true
end

function store:Ban(player, reason)
    return store:TempBan(player, "P", reason)
end

-- First: true or false (if player is banned), Second: the ban reason
function store:IsBanned(playerId)
    local player = format(playerId)
    if player == nil then
        return false
    end

    initPlayer(player)
    if players[player] == nil then
        return false, nil
    end

    if players[player]["ban"] == nil then
        return false, nil
    end

    local ban = players[player]["ban"]
    return not _G.zeus.IsDateExpired(ban["exp"]), ban["reason"]
end

function store:HasPermission(playerId, permission)
    local player = format(playerId)
    if player == nil then
        return false
    end

    initPlayer(player)
    for _, perm in ipairs(formatPermissions(permission)) do
        if hasPermission(player, playerId, perm) then
            return true
        end
    end
    return false
end

function store:AddPlayerPermission(playerId, permission)
    local player = format(playerId)
    if player == nil then
        return false
    end

    initPlayer(player)
    if not containsValue(players[tostring(player)]["permissions"], permission) then
        players[tostring(player)]["permissions"][#players[tostring(player)]["permissions"] + 1] = permission
    end
    return true
end

function store:RemovePlayerPermission(playerId, permission)
    local player = format(playerId)
    if player == nil then
        return false
    end

    initPlayer(player)
    if containsValue(players[tostring(player)]["permissions"], permission) then
        removeValue(players[tostring(player)]["permissions"], permission)
    end
    return true
end

function store:HasGroup(playerId, group)
    local player = format(playerId)
    if player == nil then
        return false
    end

    return players[tostring(player)]["group"] == group
end

function store:AddGroup(playerId, group)
    local player = format(playerId)
    if player == nil then
        return false
    end

    players[tostring(player)]["group"] = group
    return true
end

function store:GetGroup(playerId)
    local player = format(playerId)
    if player == nil then
        return "def_group"
    end

    return players[tostring(player)]["group"]
end

function store:RemoveGroup(playerId, group)
    local player = format(playerId)
    if player == nil then
        return false
    end

    if store:HasGroup(playerId, group) then
        players[tostring(player)]["group"] = "def_group"
        return true
    end
    return false
end

function store:ExistsGroup(group)
    return groups[group] ~= nil
end

function store:CreateGroup(group)
    if not store:ExistsGroup(group) then
        groups[group] = {
            permissions = {}
        }
        return true
    end
    return false
end

function store:DeleteGroup(group)
    if store:ExistsGroup(group) then
        groups[group] = nil
        return true
    end
    return false
end

function store:AddPermission(group, permission)
    if store:ExistsGroup(group) then
        groups[group]["permissions"][#groups[group]["permissions"] + 1] = permission
        return true
    end
    return false
end

function store:RemovePermission(group, permission)
    if store:ExistsGroup(group) then
        removeValue(groups[group]["permissions"], permission)
        return true
    end
    return false
end

function store:HasGroupPermission(group, permission)
    if store:ExistsGroup(group) then
        return containsValue(groups[group]["permissions"], permission)
    end
    return false
end

AddEvent("OnPackageStop", function()
    storage.Save("groups", groups)
    storage.Save("players", players)
    storage.Save("admins", admins)
end)

return store