local config = require('packages/' .. GetPackageName() .. '/server/io/config')
local database = { _VERSION = "1.1:0", current = nil }

local function IsOpen()
    return database.current ~= false
end

local function CreateTable(name)
    if IsOpen() then
        mariadb_await_query(database.current, name, false)
    end
end

function database.Insert(query)
    if IsOpen() then
        mariadb_await_query(database.current, query, false)
    end
end

function HasRows()
    local flag = mariadb_get_row_count()

    if not flag == false then
        flag = mariadb_get_row_count() > 0
    end

    return flag
end

function database.Exists(query)
    if IsOpen() then
        local result = mariadb_await_query(database.current, query)
        local flag = HasRows()

        mariadb_delete_result(result)
        return flag
    end
    return true
end

function database.Get(query, field, def)
    local result = mariadb_await_query(database.current, query)

    local value = def
    if HasRows() then
        value = mariadb_get_value_name(1, field)

        if value == nil or value == "NULL" then
            value = def
        end
    end

    mariadb_delete_result(result)
    return value
end

function database.GetTwo(query, field1, field2, def1, def2)
    local result = mariadb_await_query(database.current, query)

    local value = def1
    local value2 = def2
    if HasRows() then
        value = mariadb_get_value_name(1, field1)
        value2 = mariadb_get_value_name(1, field2)
    end

    mariadb_delete_result(result)
    return value, value2
end

function database.Init()
    mariadb_log("error")
    database.current = mariadb_connect(GetDatabaseConnection())

    if IsOpen() then
        mariadb_set_charset(database.current, config["db-charset"])

        -- TABLES
        CreateTable([[CREATE TABLE IF NOT EXISTS  `zeus_groups` (
                      `GroupName` VARCHAR(45) NOT NULL,
                      `Format` VARCHAR(45) NULL,
                      PRIMARY KEY (`GroupName`))
                    ENGINE = InnoDB;]])
        CreateTable([[CREATE TABLE IF NOT EXISTS `zeus_groupperms` (
                      `GroupName` VARCHAR(45) NULL,
                      `Permission` VARCHAR(45) NULL,
                      CONSTRAINT `GroupPermission`
                        FOREIGN KEY (`GroupName`)
                        REFERENCES  `zeus_groups` (`GroupName`)
                        ON DELETE CASCADE
                        ON UPDATE NO ACTION)
                    ENGINE = InnoDB;]])
        CreateTable([[CREATE TABLE IF NOT EXISTS  `zeus_players` (
                      `SteamID` VARCHAR(45) NOT NULL,
                      `GroupName` VARCHAR(45) NULL DEFAULT 'def_group',
                      `IsAdmin` TINYINT(1) DEFAULT '0',
                      PRIMARY KEY (`SteamID`),
                      CONSTRAINT `PlayerGroup`
                        FOREIGN KEY (`GroupName`)
                        REFERENCES  `zeus_groups` (`GroupName`)
                        ON DELETE SET NULL
                        ON UPDATE NO ACTION)
                    ENGINE = InnoDB;]])
        CreateTable([[CREATE TABLE IF NOT EXISTS  `zeus_playerperms` (
                      `Player` VARCHAR(45) NULL,
                      `Permission` VARCHAR(45) NULL,
                      CONSTRAINT `PlayerPermission`
                        FOREIGN KEY (`Player`)
                        REFERENCES  `zeus_players` (`SteamID`)
                        ON DELETE CASCADE
                        ON UPDATE NO ACTION)
                    ENGINE = InnoDB;]])
        CreateTable([[CREATE TABLE IF NOT EXISTS  `zeus_playerbans` (
                      `Player` VARCHAR(45) NULL,
                      `Duration` VARCHAR(45) NULL,
                      `Reason` VARCHAR(45) NULL,
                      CONSTRAINT `PlayerBan`
                        FOREIGN KEY (`Player`)
                        REFERENCES  `zeus_players` (`SteamID`)
                        ON DELETE CASCADE
                        ON UPDATE NO ACTION)
                    ENGINE = InnoDB;]])

        if not database.Exists(mariadb_prepare(database.current, "SELECT * FROM zeus_groups WHERE GroupName = '?'", tostring("def_group"))) then
            database.Insert(mariadb_prepare(database.current, "INSERT INTO zeus_groups (GroupName, Format) VALUES ('?', '?')", tostring("def_group"), tostring("soon")))
        end
    end
end

function database.Handle()
    return database.current
end

function database.Close()
    if IsOpen() then
        mariadb_close(database.current)
        database.current = false
    end
end

return database