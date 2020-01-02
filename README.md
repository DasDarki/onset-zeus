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
> Please do not change any of the functions, returns or variables itself. Please change only the values according to your wishes.  
   
| Config Key | Default Value | Possible Values | Description | 
| ---------- | -------------| -------------  | -----------|
| **msg-** | *see above*| *every text* | This are the i18n messages printed by Zeus. You can change them like you want to. Some messages have placeholders (e.g. *{1}*) this placeholders will be replaced by Zeus with values dynamically. You can use them, too but you don't need to. |
| **custom-chat** | false | false / true | *not implemented yet* |
| **store-type** | LOCAL | LOCAL / MYSQL (*not implemented yet*) | The way Zeus stores its data |
| **admins** | { } | Lua Table | Users which SteamID64 is entered in this table are counting as admins and have all permissions |
| **dev-mode** | true | false / true | When enabled, every player on the server has all permissions. Zeus will warn you on server start, if the dev mode is enabled | 

## Modules
Modules are the main components of Zeus. Without them, Zeus is only a frame. In Zeus are some default modules which offers only the basics. But with a little bit of work and the knowledge to code in LUA you can create own ones easily.   
If you created a module and want to share it, so that it will be in the default Zeus package, just [create an Issue](https://github.com/DasDarki/onset-zeus/issues/new) and promote it. Read below for more information.

### Submit a Module
To submit a module you need to create an Issue [here](https://github.com/DasDarki/onset-zeus/issues/new). We need the code of the module, and a description of it. By submitting a module you agree, that the module is written by you or you have the permission to share it from the developer. We do not liable for any kind of problems.   
Please understand, however, that we can only accept modules that use English as their language.

### Create a Module
Under *zeus/server/modules* you find the *__TEMPLATE_MOD__lua* which is a template for creating a module. If you can't find the file, here is how it should look like:
```lua
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
    return player -- Return the target of this module
end

function mod:GetUIComponent()
    -- The UI component is the structure of the UI. The UI manager from Zeus will transform this string to a form
    -- The form can than be used by the players to input the arguments. There are some default UI controls listed below.
    -- [P] Player Select. Selects a player from a list with all online players
    -- [T] Text Input. Takes text input from the player
    -- [N] Number(float) Input. Takes number input from the player
    -- Add a ? after the Component if it is optional
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
```
We suggest that you read through the existing modules to learn a bit more about the Zeus system. The template is also filled with comments to help you understand the basic structure.   
After you wrote the module file itself you need to register the module in two ways:   
**package.json**: You need to register the file in the package.json of Zeus, so the server knows that your written file is a server file.   
**Zeus Module Manager**: You also need to register your module in the module manager fo zeus. To do that you need to go to *zeus/server/index.lua* and enter your module below where the other modules are registered (via `RegisterModule()`). The first parameter is the module group (see below for all groups) and the second parameter is the module name.   
    
> **IMPORTANT**    
There are a few things to consider. First, the name entered as the second parameter in the RegisterModule method must be the same as the name of the file without the .lua extension. Furthermore, the file must be located in the folder under *zeus/server/modules/XXX*, in which group the module should be divided.

**Allowed Groups**
- admin
- fun
- others
- permission
- spawning
- utils

If you need help or just have questions, you can open an issue at any time.

## Group and Permission System
As described above, Zeus offers a complete permission system on its own. Below you can see how it works and how it can be adjusted.

### Setup Groups
Zeus offers modules such as *Create Group*, *Delete Group*, *Add Permission* and *Remove Permission*. With these modules you can create groups and setting them up. With the module *Set Group* you can set the group of a player. By default players have the *def_group* which is the default group. You can change the permission of the groups with the Add and Remove Permission module.

### Permission Handling
When asked for the rights of a player, the system goes through 3 layers. Starting with the admin layer, which defines the admins on the server. These can be defined by entering them in the **admins** table in the config. If the player is not an admin, the second layer, the player-permissions-layer, is considered. In this layer you can define the rights for a specific player. This is done via the modules *Add Player Permission* and *Remove Player Permission*. After this layer comes the last one, the group layer. Here the permissions of the group are considered.   

### Permission Pathing
Basically, permissions are structured according to the name-point-name principle, for example *zeus.mod.add_permission* This permission describes the use of the module *Add Permission*.  You should adhere strictly to this principle, since there is a special rule:   
The parts of the permission are taken and divided. After each group part there is a star permission (an all permission). For example, if you have the *zeus.\** permission, you have all permissions over Zeus, if you only have the *zeus.mod.\** permission, you only have all permissions over all modules. There is also the basic all-permission *\**. With this permission you have all permissions over everything.

### Permission Commands
Zeus provides an API interface with which permission-based commands can be created. This is very simple:
```lua
zeus.AddPermCommand("helloworld", "github.test.helloworld", function(player)
    print("Hello World")
end)
```
Only those who have the permission *github.test.helloworld* can execute this command.   
To implement the API interface, see below under **Zeus API**.

## Zeus API
To use the API, you must first import the package into your package. To do this, simply use the [ImportPackage](https://dev.playonset.com/wiki/ImportPackage) method as follows:
```lua
zeus = ImportPackage("zeus")
```
Now you can use all methods of the API interface via *zeus.X()*. 
Since we don't want to explain the complete API, which is explained by the names of the methods themselves, we refer to the API file here: [zeus/server/api.lua](https://github.com/DasDarki/onset-zeus/blob/master/server/api.lua)

## Credits
Zeus is created by DasDarki, and Contributers and is licensed unter the MIT License.
