local ADMIN_KEY = "F5" -- nil if disabled

local web_ui
local modules_cache = ""

local function OpenUI()
    if web_ui ~= nil then
        SetIgnoreLookInput(true)
        SetIgnoreMoveInput(true)
        ShowMouseCursor(true)
        SetInputMode(INPUT_GAMEANDUI)
        SetWebVisibility(web_ui, WEB_VISIBLE)
    end
end

function OnPackageStart()
    web_ui = CreateWebUI(0, 0, 0, 0, 1, 60)
    LoadWebFile(web_ui, "http://asset/" .. GetPackageName() .. "/client/ui/index.html")
    SetWebAlignment(web_ui, 0.0, 0.0)
    SetWebAnchors(web_ui, 0.0, 0.0, 1.0, 1.0)
    SetWebVisibility(web_ui, WEB_HIDDEN)
end
AddEvent("OnPackageStart", OnPackageStart)

function OnRetrievePlayers()
    local players = {}
    for _, value in ipairs(GetStreamedPlayers()) do
        players[#players + 1] = { name = GetPlayerName(value), id = value }
    end

    players[#players + 1] = { name = GetPlayerName(GetPlayerId()), id = GetPlayerId() }
    local json = json_encode(players)
    ExecuteWebJS(web_ui, "retrievePlayers('" .. json .. "')")
end
AddEvent("Zeus_RetrievePlayers", OnRetrievePlayers)

function OnCloseUI()
    SetIgnoreLookInput(false)
    SetIgnoreMoveInput(false)
    ShowMouseCursor(false)
    SetInputMode(INPUT_GAME)
    SetWebVisibility(web_ui, WEB_HIDDEN)
end
AddEvent("Zeus_CloseUI", OnCloseUI)

function OnActivateModule(data)
    CallRemoteEvent("Zeus_ActivateModule", data);
end
AddEvent("Zeus_ActivateModule", OnActivateModule);

function OnDeactivateModule(data)
    CallRemoteEvent("Zeus_DectivateModule", data);
end
AddEvent("Zeus_DeactivateModule", OnDeactivateModule);

function OnShowUI()
    OpenUI()
end
AddRemoteEvent("Zeus_ShowUI", OnShowUI)

function OnReceiveModules(data)
    local next = string.sub(data, 1, 1)
    modules_cache = modules_cache .. string.sub(data, 2)
    if next == "0" then
        ExecuteWebJS(web_ui, "setup('" .. modules_cache .. "')")
        modules_cache = ""
    end
end
AddRemoteEvent("Zeus_ReceiveModules", OnReceiveModules)

function OnCompleteWebLoad(web)
    if web == web_ui then
        CallRemoteEvent('Zeus_RequestModules')
    end
end
AddEvent("OnWebLoadComplete", OnCompleteWebLoad)

AddEvent("OnKeyPress", function(key)
    if ADMIN_KEY == nil then
        return
    end

    if key == ADMIN_KEY then
        OpenUI()
    end
end)

function OnDebug(message)
    AddPlayerChat(message)
end
AddEvent("Zeus_Debug", OnDebug)

-------------------------------------------------------------------------------
-- JSON Encode Copyright (c) 2019 rxi
-------------------------------------------------------------------------------

local encode

local escape_char_map = {
    ["\\"] = "\\\\",
    ["\""] = "\\\"",
    ["\b"] = "\\b",
    ["\f"] = "\\f",
    ["\n"] = "\\n",
    ["\r"] = "\\r",
    ["\t"] = "\\t",
}

local escape_char_map_inv = { ["\\/"] = "/" }
for k, v in pairs(escape_char_map) do
    escape_char_map_inv[v] = k
end

local function escape_char(c)
    return escape_char_map[c] or string.format("\\u%04x", c:byte())
end

local function encode_nil(val)
    return "null"
end

local function encode_table(val, stack)
    local res = {}
    stack = stack or {}

    -- Circular reference?
    if stack[val] then
        error("circular reference")
    end

    stack[val] = true

    if val[1] ~= nil or next(val) == nil then
        -- Treat as array -- check keys are valid and it is not sparse
        local n = 0
        for k in pairs(val) do
            if type(k) ~= "number" then
                error("invalid table: mixed or invalid key types")
            end
            n = n + 1
        end
        if n ~= #val then
            error("invalid table: sparse array")
        end
        -- Encode
        for i, v in ipairs(val) do
            table.insert(res, encode(v, stack))
        end
        stack[val] = nil
        return "[" .. table.concat(res, ",") .. "]"

    else
        -- Treat as an object
        for k, v in pairs(val) do
            if type(k) ~= "string" then
                error("invalid table: mixed or invalid key types")
            end
            table.insert(res, encode(k, stack) .. ":" .. encode(v, stack))
        end
        stack[val] = nil
        return "{" .. table.concat(res, ",") .. "}"
    end
end

local function encode_string(val)
    return '"' .. val:gsub('[%z\1-\31\\"]', escape_char) .. '"'
end

local function encode_number(val)
    return string.format("%.14g", val)
end

local type_func_map = {
    ["nil"] = encode_nil,
    ["table"] = encode_table,
    ["string"] = encode_string,
    ["number"] = encode_number,
    ["boolean"] = tostring,
}

encode = function(val, stack)
    local t = type(val)
    local f = type_func_map[t]
    if f then
        return f(val, stack)
    end
    error("unexpected type '" .. t .. "'")
end

function json_encode(val)
    return (encode(val))
end