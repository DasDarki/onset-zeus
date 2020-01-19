local zeus = require('packages/' .. GetPackageName() .. '/server/api')
local config = require('packages/' .. GetPackageName() .. '/server/io/config')
local json = require('packages/' .. GetPackageName() .. '/server/io/json')

modules = { _VERSION = "1.0:0", all = {}, groups = {}, modids = {} }

local function FormatCommand(modName)
    return string.gsub(string.lower(modName), " ", "_")
end

local function IsActive(player, module)
    return GetPlayerPropertyValue(player, 'zeus_active_' .. module) ~= nil
end

local function PutActive(player, module, args)
    SetPlayerPropertyValue(player, 'zeus_active_' .. module, args)
end

local function DeleteActive(player, module)
    SetPlayerPropertyValue(player, 'zeus_active_' .. module, nil)
end

local function GetActive(player, module)
    return GetPlayerPropertyValue(player, 'zeus_active_' .. module)
end

local function RegisterModule(group, modFile)
    local module = require('packages/' .. GetPackageName() .. '/server/modules/' .. group .. '/' .. modFile)
    modules["groups"][module:GetName()] = group
    local id = #modules["all"] + 1
    modules["all"][id] = module
    modules["modids"][module:GetName()] = id
    zeus.AddPermCommand("zeus:" .. FormatCommand(module:GetName()), "zeus.mod." .. FormatCommand(module:GetName()), function(player, ...)
        local args = { ... }
        local target = module:GetTarget(player, args)

        if target == nil then
            return
        end

        if IsActive(target, module:GetName()) then
            DeactivateModule(module, player, target)
        else
            ActivateModule(module, player, target, args)
        end
    end)
end

function GetModule(name)
    return modules["all"][modules["modids"][name]]
end

function HasModulePermission(module, player)
    if module == nil then
        AddPlayerChat(player, config["msg-error"])
        return false
    end

    return zeus.HasPermission(player, "zeus.mod." .. FormatCommand(module:GetName()))
end

function ActivateModule(module, player, target, args)
    if module == nil then
        AddPlayerChat(player, config["msg-error"])
        return
    end

    if HasModulePermission(module, player) == false then
        AddPlayerChat(player, config["msg-no-permission"])
        return
    end

    local result = module:Activate(player, target, args)
    if result == true then
        if module:IsToggleable() then
            PutActive(target, module:GetName(), args)
        end
    elseif result == false then
        AddPlayerChat(player, config["msg-error"])
    end
end

function DeactivateModule(module, player, target)
    if module == nil then
        AddPlayerChat(player, config["msg-error"])
        return
    end

    if IsActive(target, module:GetName()) == false then
        return
    end

    module:Deactivate(player, target, GetActive(target, module:GetName()))
    DeleteActive(target, module:GetName())
end

function GetAllowedModules(player)
    local mods = {}
    for _, value in ipairs(modules["all"]) do
        if HasModulePermission(value, player) then
            mods[#mods + 1] = {
                name = value:GetName(),
                group = modules["groups"][value:GetName()],
                description = value:GetDescription(),
                toggle = value:IsToggleable(),
                ui = value:GetUIComponent()
            }
        end
    end

    return mods
end

local function SplitByChunk(text, chunkSize)
    local s = {}
    local l = 0
    for i = 1, #text, chunkSize do
        s[#s + 1] = text:sub(i, i + chunkSize - 1)
        l = l + 1
    end

    return s, l
end

function OnRequestModules(player)
    local data = json_encode(GetAllowedModules(player))
    if string.len(data) < 1023 then
        CallRemoteEvent(player, "Zeus_ReceiveModules", "0" .. data)
    else
        local chunks, length = SplitByChunk(data, 1000)
        for idx, chunk in ipairs(chunks) do
            local isNext = "1"
            if idx >= length then
                isNext = "0"
            end

            CallRemoteEvent(player, "Zeus_ReceiveModules", isNext .. chunk)
        end
    end
end
_G.zeus.RefreshPlayer = function(player)
    OnRequestModules(player)
end
AddRemoteEvent("Zeus_RequestModules", OnRequestModules)

function OnActivateModule(player, jdata)
    local data = json_decode(jdata);
    local module = GetModule(data["mod"])
    local args = data["args"]
    if module ~= nil then
        local target = module:GetTarget(player, args)

        if target == nil then
            return
        end

        ActivateModule(module, player, target, args)
    end
end
AddRemoteEvent("Zeus_ActivateModule", OnActivateModule);

function OnDeactivateModule(player, jdata)
    local data = json_decode(jdata);
    local module = GetModule(data["mod"])
    local args = data["args"]
    if module ~= nil then
        local target = module:GetTarget(player, args)

        if target == nil then
            return
        end

        DeactivateModule(module, player, target)
    end
end
AddRemoteEvent("Zeus_DectivateModule", OnDeactivateModule);

RegisterModule("admin", "kick")
RegisterModule("admin", "ban")
RegisterModule("admin", "tempban")
RegisterModule("admin", "unban")
RegisterModule("admin", "make_admin")
RegisterModule("admin", "remove_admin")
RegisterModule("utils", "teleport")
RegisterModule("utils", "tppos")
RegisterModule("utils", "tpdim")
RegisterModule("utils", "bring")
RegisterModule("utils", "refresh_player")
RegisterModule("spawning", "vehicle_spawner")
RegisterModule("others", "kill")
RegisterModule("others", "spectate")
RegisterModule("permission", "set_group")
RegisterModule("permission", "create_group")
RegisterModule("permission", "delete_group")
RegisterModule("permission", "add_permission")
RegisterModule("permission", "add_player_permission")
RegisterModule("permission", "remove_permission")
RegisterModule("permission", "remove_player_permission")
RegisterModule("fun", "armor")
RegisterModule("fun", "heal")
RegisterModule("fun", "ragdoll")
RegisterModule("fun", "god")

zeus.AddPermCommand("zeus", "zeus.main.openui", function(player)
    CallRemoteEvent(player, "Zeus_ShowUI")
end)

function OnPlayerSteamAuth(player)
    local banned, reason = zeus.IsBanned(player)

    if banned == true then
        KickPlayer(player, FormatMsg("msg-banned", reason))
    end
end
AddEvent("OnPlayerSteamAuth", OnPlayerSteamAuth)

print("Zeus v" .. zeus._VERSION .. " by DasDarki started!")
if config["dev-mode"] == true then
    print("--- !!!WARNING!!! ZEUS IS IN DEV MODE !!!WARNING!!! ---")
    print("As long as the Dev Mode is enabled, everyone has Admin Permission!")
    print("You can disable the Dev Mode in the Config: packages/zeus/server/io/config.lua")
    print("--- !!!WARNING!!! ZEUS IS IN DEV MODE !!!WARNING!!! ---")
end