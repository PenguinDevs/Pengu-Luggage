-- Loads prioritised modules using RoStrap with an array containing priority and module name
-- @author PenguinDevs

local module = {}

local Resources = require(game.ReplicatedStorage.Resources)
local Promise = Resources:LoadLibrary("Promise")

return setmetatable(module, {
    __call = function(_, ...)
        local ClientInitMods = ...
        
        table.sort(ClientInitMods,
            function(a, b)
                return a.priority < b.priority
            end
        )
        for no, loadUnit in pairs(ClientInitMods) do
            local name = loadUnit.module

            local function errorHandle(func, ...)
                local args = table.pack(...)
                Promise.new(function(resolve, reject)
                    local s, err = pcall(func, table.unpack(args))
                    if s then
                        resolve()
                    else
                        reject(err)
                    end
                end):andThen(function()
                    print(name)
                    -- loading ui stuff
                end):catch(function(err)
                    warn(err)
                end)
            end
            
            errorHandle(function()
                loadUnit.module = Resources:LoadLibrary(loadUnit.module)
            end)
            errorHandle(function()
                if typeof(loadUnit.module) == "table" then
                    if loadUnit.module.init then loadUnit.module:init() end
                end
            end)
            errorHandle(function()
                if typeof(loadUnit.module) == "table" then
                    if loadUnit.module.update then loadUnit.module.update() end
                end
            end)
        end
    end
})