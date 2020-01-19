local json = require('packages/' .. GetPackageName() .. '/server/io/json')
local storage = { _VERSION = "1.0:0" }

function storage.Load(name, factory)
    if isDataExisting(name) then
        return json_decode(readFile(formatPath(name)))
    end

    local data = factory()
    storage.Save(name, data)
    return data
end

function storage.Save(name, data)
    initDir()
    local f, err = io.open(formatPath(name), "w")
    if f == nil then
        print("[Zeus] An error occurred while saving data to storage: " .. err)
    else
        f:write(json_encode(data))
        f:close()
    end
end

function readFile(name)
    local content = ""
    for line in io.lines(name) do
        content = content .. line
    end
    return content
end

function isDataExisting(name)
    local f = io.open(formatPath(name), "r")
    if f ~= nil then
        f:close()
        return true
    end

    return false
end

function formatPath(name)
    return 'packages/' .. GetPackageName() .. '/server/data/' .. name .. '.json'
end

function initDir()
    local dir = 'packages/' .. GetPackageName() .. '/server/data/'
    os.execute("mkdir " .. dir)
end

return storage