local config = require('packages/' .. GetPackageName() .. '/server/io/config')
local database = require('packages/' .. GetPackageName() .. '/server/io/database')
database.Init()
local store = { _VERSION = "1.1:0" }

function format(player)
    if IsValidPlayer(player) then
        return tostring(GetPlayerSteamId(player))
    end

    return nil
end

function initPlayer(player)
    if not database.Exists(mariadb_prepare(database.Handle(), "SELECT * FROM zeus_players WHERE SteamID = '?'", tostring(player))) then
        database.Insert(mariadb_prepare(database.Handle(), "INSERT INTO zeus_players (SteamID) VALUES ('?')", tostring(player)))
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

function isAdminInDb(steamId)
    return tostring(database.Get(mariadb_prepare(database.Handle(), "SELECT IsAdmin FROM zeus_players WHERE SteamID = '?'", tostring(steamId)), "IsAdmin", "0")) == "1"
end

function store:IsAdmin(playerId)
    if config["dev-mode"] == true then
        return true
    end

    local steamId = returnSteam(playerId)
    return isAdminInDb(steamId)
end

function store:MakeAdmin(playerId, enable)
    local steamId = returnSteam(playerId)
    if enable == true then
        if not isAdminInDb(steamId) then
            database.Insert(mariadb_prepare(database.Handle(), "UPDATE zeus_players SET IsAdmin = '?' WHERE SteamID = '?'", 1, tostring(steamId)))
            return true
        end
    else
        if isAdminInDb(steamId) then
            database.Insert(mariadb_prepare(database.Handle(), "UPDATE zeus_players SET IsAdmin = '?' WHERE SteamID = '?'", 0, tostring(steamId)))
            return true
        end
    end

    return false
end

function hasPermission(player, playerId, permission)
    if store:IsAdmin(player) then
        return true
    end

    if not database.Exists(mariadb_prepare(database.Handle(), "SELECT * FROM zeus_playerperms WHERE Player = '?' AND Permission = '?'", tostring(player), tostring(permission))) then
        if not store:HasGroupPermission(store:GetGroup(playerId), permission) then
            return false
        end
    end
    return true
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

function store:Unban(playerId)
    local player = format(playerId)
    if player == nil then
        return false
    end

    initPlayer(player)
    database.Insert(mariadb_prepare(database.Handle(), "DELETE FROM zeus_playerbans WHERE Player = '?'", tostring(player)))
end

function store:TempBan(playerId, time, reasonText)
    local player = format(playerId)
    if player == nil then
        return false
    end

    initPlayer(player)
    if not store:IsBanned(playerId) then
        local date = _G.zeus.FormatDate(time)
        database.Insert(mariadb_prepare(database.Handle(), "INSERT INTO zeus_playerbans (Player, Duration, Reason) VALUES ('?', '?', '?')", tostring(player), tostring(date), tostring(reasonText)))
        return true
    end

    return false
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
    if not database.Exists(mariadb_prepare(database.current, "SELECT * FROM zeus_playerbans WHERE Player = '?'", tostring(player))) then
        return false, nil
    end

    local exp, reason = database.GetTwo(mariadb_prepare(database.current, "SELECT * FROM zeus_playerbans WHERE Player = '?'", tostring(player)), "Duration", "Reason", nil, "")
    if exp == nil then
        return false
    end

    return not _G.zeus.IsDateExpired(exp), reason
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
    if not database.Exists(mariadb_prepare(database.Handle(), "SELECT * FROM zeus_playerperms WHERE Permission = '?'", tostring(permission))) then
        database.Insert(mariadb_prepare(database.Handle(), "INSERT INTO zeus_playerperms (Player, Permission) VALUES ('?', '?')", tostring(player), tostring(permission)))
    end
    return true
end

function store:RemovePlayerPermission(playerId, permission)
    local player = format(playerId)
    if player == nil then
        return false
    end

    initPlayer(player)
    if database.Exists(mariadb_prepare(database.Handle(), "SELECT * FROM zeus_playerperms WHERE Player = '?' AND Permission = '?'", tostring(player), tostring(permission))) then
        database.Insert(mariadb_prepare(database.Handle(), "DELETE FROM zeus_playerperms WHERE Player = '?' AND Permission = '?'", tostring(player), tostring(permission)))
    end
    return true
end

function store:HasGroup(playerId, group)
    local player = format(playerId)
    if player == nil then
        return false
    end

    initPlayer(player)
    return database.Exists(mariadb_prepare(database.Handle(), "SELECT * FROM zeus_players WHERE SteamID = '?' AND GroupName = '?'", tostring(player), tostring(group)))
end

function store:AddGroup(playerId, group)
    local player = format(playerId)
    if player == nil then
        return false
    end

    initPlayer(player)
    database.Insert(mariadb_prepare(database.Handle(), "UPDATE zeus_players SET GroupName = '?' WHERE SteamID = '?'", tostring(group), tostring(player)))
    return true
end

function store:GetGroup(playerId)
    local player = format(playerId)
    if player == nil then
        return "def_group"
    end

    initPlayer(player)
    return database.Get(mariadb_prepare(database.Handle(), "SELECT GroupName FROM zeus_players WHERE SteamID = '?'", tostring(player)), "GroupName", "def_group")
end

function store:RemoveGroup(playerId, group)
    local player = format(playerId)
    if player == nil then
        return false
    end

    initPlayer(player)
    if store:HasGroup(playerId, group) then
        database.Insert(mariadb_prepare(database.Handle(), "UPDATE zeus_players SET GroupName = '?' WHERE SteamID = '?'", "def_group", tostring(player)))
        return true
    end
    return false
end

function store:ExistsGroup(group)
    return database.Exists(mariadb_prepare(database.Handle(), "SELECT * FROM zeus_groups WHERE GroupName = '?'", tostring(group)))
end

function store:CreateGroup(group)
    if not store:ExistsGroup(group) then
        database.Insert(mariadb_prepare(database.Handle(), "INSERT INTO zeus_groups (GroupName, Format) VALUES ('?', '?')", tostring(group), tostring("soon")))
        return true
    end
    return false
end

function store:DeleteGroup(group)
    if store:ExistsGroup(group) then
        database.Insert(mariadb_prepare(database.Handle(), "DELETE FROM zeus_groups WHERE GroupName = '?'", tostring(group)))
        return true
    end
    return false
end

function store:AddPermission(group, permission)
    if store:ExistsGroup(group) and not store:HasGroupPermission(group, permission) then
        database.Insert(mariadb_prepare(database.Handle(), "INSERT INTO zeus_groupperms (GroupName, Permission) VALUES ('?', '?')", tostring(group), tostring(permission)))
        return true
    end
    return false
end

function store:RemovePermission(group, permission)
    if store:ExistsGroup(group) and store:HasGroupPermission(group, permission) then
        database.Insert(mariadb_prepare(database.Handle(), "DELETE FROM zeus_groupperms WHERE GroupName = '?' AND Permission = '?'", tostring(group), tostring(permission)))
        return true
    end
    return false
end

function store:HasGroupPermission(group, permission)
    return database.Exists(mariadb_prepare(database.Handle(), "SELECT * FROM zeus_groupperms WHERE GroupName = '?' AND Permission = '?'", tostring(group), tostring(permission)))
end

AddEvent("OnPackageStop", function()
    database.Close()
end)

return store