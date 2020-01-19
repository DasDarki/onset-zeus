local content = { _VERSION = "1.0:0" }

content["msg-error"] = "[Zeus] An error occurred while trying to perfom this action!"
content["msg-no-permission"] = "[Zeus] You have no permissions to do that!"
content["msg-argument-missing"] = "[Zeus] Failed to executed because Argument {1} is missing!"
content["msg-argument-invalid"] = "[Zeus] Failed to executed because Argument {1} is invalid!"
content["msg-mod-success"] = "[Zeus] Module {1} was successfully executed!"
content["msg-mod-disabled"] = "[Zeus] Module {1} was successfully disabled!"
content["msg-mod-failed"] = "[Zeus] Module {1} failed because {2}!"
content["msg-banned"] = "You are banned: {1}"
content["msg-veh-model-not-exist"] = "[Zeus] The Vehicle Model {1} does not exist!"

content["custom-chat"] = false -- coming soon: mysql
content["store-type"] = "LOCAL" -- or MYSQL
--[[
INFORMATION ABOUT THE DEV MODE

By default the dev mode is on, as long as the dev mode is on, all players are considered admin and 
have all rights over the server and Zeus. Please only use this mode as long as nobody is admin, 
because without an admin nobody can do anything with Zeus. To appoint someone as an admin, 
open Zeus with /zeus and select the "Make Admin" module under Administration. 
Then you only have to select a player and click on Activate. The player will then be appointed as admin. 
Then you can turn off the dev mode, restart the server and administrate your server without any problems.
]]--
content["dev-mode"] = true 

content["db-host"] = "localhost"
content["db-user"] = "zeus-db"
content["db-password"] = "this-is-a-safe-pw"
content["db-name"] = "zeus-db"
content["db-charset"] = "utf8mb4"

function GetDatabaseConnection()
    return content["db-host"], content["db-user"], content["db-password"], content["db-name"]
end

function IsLocalStorage()
    return content["store-type"] == "LOCAL"
end

function FormatMsg(key, ...)
    local msg = content[key]
    for key, value in pairs({ ... }) do
        msg = string.gsub(msg, "{" .. key .. "}", value)
    end

    return msg
end

return content