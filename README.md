# Zeus
Zeus is an Administration Tool for [Onset](https://playonset.com/) created for all Players free to use. Zeus is module-based, which means that it can be expanded easily and without much effort. All you have to do is write modules for Zeus in LUA and enter them into the system. See below under "Module API". 
Zeus also provides a complete ban and permission system, which even has a simple command interface for commands with permissions. 

## Installation
Just download the ZIP-Archive from [here](https://github.com/DasDarki/onset-zeus/releases/tag/v1.0.2) and put the folder from it into the packages folder of your server. Than add "zeus" to the packages in server_config.json and start the server.

## Configuration
Zeus is fully adjustable and uses only one file for all configurations. The config can be found in *packages/zeus/server/io/config.lua* and looks like this by default:
```lua
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
```
**Please do not change any of the functions, returns or variables itself. Please change only the values according to your wishes.**
The entries with a **msg-** at the beginning are all messages printed by Zeus. You can change them like you want to. Some messages have placeholders (e.g. *{1}*) this placeholders will be replaced by Zeus with values dynamically. You can use them, too but you don't need to.   
The **custom-chat** flag is a feature which isn't implemented yet.   
The **store-type** value is a feature which is implemented but can't be changed yet. In the future you will have the chance to store the data in a MySql database.   
In the **admins** table you can enter your SteamID in the 64 format like this `{ "YOUR_STEAM_ID_64_HERE", "ANOTHER_HERE" }`. Zeus will than see the players with this id as super admin with all permission.   
The **dev-mode** flag is default *true* and if the flag is true, every player on the server is an admin. Zeus will warn you on server start, if the flag is true.   


## Credits
Zeus is created by DasDarki, and Contributers and is licensed unter the MIT License.
