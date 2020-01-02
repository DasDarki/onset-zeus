local content = { _VERSION = "1.0:0" }

content["msg-error"] = "[Zeus] An error occurred while trying to perfom this action!"
content["msg-no-permission"] = "[Zeus] You have no permissions to do that!"
content["msg-argument-missing"] = "[Zeus] Failed to executed because Argument {1} is missing!"
content["msg-argument-invalid"] = "[Zeus] Failed to executed because Argument {1} is invalid!"
content["msg-mod-success"] = "[Zeus] Module {1} was successfully executed!"
content["msg-mod-disabled"] = "[Zeus] Module {1} was successfully disabled!"
content["msg-banned"] = "You are banned: {1}"
-- VEH SPAWN --
content["msg-veh-model-not-exist"] = "[Zeus] The Vehicle Model {1} does not exist!"

content["custom-chat"] = false
content["store-type"] = "LOCAL" -- coming soon: mysql
content["admins"] = {  } -- Enter SteamID64 in here which will have all permissions
content["dev-mode"] = true -- Every User on the Server has Admin Permissions, when true

function IsLocalStorage()
    return content["store-type"] == "LOCAL"
end

function IsAdmin(steamID)
    if content["dev-mode"] == true then
        return true
    end

    for _, value in ipairs(content["admins"]) do
        if tostring(value) == steamID then
            return true
        end
    end

    return false
end

function FormatMsg(key, ...)
    local msg = content[key]
    for key, value in pairs({ ... }) do
        msg = string.gsub(msg, "{" .. key .. "}", value)
    end

    return msg
end

return content