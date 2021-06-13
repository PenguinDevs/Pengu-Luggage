-- Loads prioritised modules using RoStrap with an array containing priority and module name
-- @author PenguinDevs

local module = {}

local Resources = require(game.ReplicatedStorage.Resources)
local Promise = Resources:LoadLibrary("Promise")

return setmetatable(module, {
    __call = function(_, ...)
        local initMods, assignToTable = ...
        
        local failed = false

        table.sort(initMods,
            function(a, b)
                return a.priority < b.priority
            end
        )
        for no, loadUnit in pairs(initMods) do
            if failed then return false, failed end

            local name = loadUnit.module
            assert(typeof(name) == "string", string.format("Expected string, got %s %s", typeof(name), tostring(name)))

            local function errorHandle(func, step, ...)
                if failed then return end

                local retrievedVal

                local args = table.pack(...)
                print(string.format("pend %s || %s", name, step))
                Promise.new(function(resolve, reject)
                    local val
                    local s, err = pcall(function()
                        val = table.pack(func(table.unpack(args)))
                    end)
                    if s then
                        resolve(table.unpack(val))
                    else
                        reject(err)
                    end
                end):andThen(function(...)
                    -- print(string.format("%s || %s", name, step))
                    retrievedVal = table.pack(...)
                    -- loading ui stuff
                end):catch(function(err)
                    warn(string.format("ERROR || %s || %s || %s", name, step, err))
                    failed = err
                end):await()

                return table.unpack(retrievedVal)
            end
            
            errorHandle(function()
                loadUnit.module = Resources:LoadLibrary(loadUnit.module)
                -- if assignToTable then assignToTable[loadUnit.assign] = loadUnit.module end
            end, "require")
            if typeof(loadUnit.module) == "table" then
                if loadUnit.module.init then errorHandle(loadUnit.module.init, "init") end
                if loadUnit.module.update then errorHandle(loadUnit.module.update, "update") end
                if loadUnit.module.playerProfileAssign and assignToTable then
                    -- print(assignToTable, loadUnit.assign)
                    assignToTable[loadUnit.assign] = errorHandle(loadUnit.module.playerProfileAssign, "assign player profile", assignToTable)
                end
            end
        end

        return true
    end
})