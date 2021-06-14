-- Retrieves whether a user owns gamepasses
-- @author PenguinDevs

local module = {}

local Resources = require(game.ReplicatedStorage.Resources)
local Promise = Resources:LoadLibrary("Promise")
local UniversalGamePasses = Resources:LoadLibrary("UniversalGamePasses")
local GamePassStats = Resources:LoadLibrary("GamePassStats")

local MarketplaceService = game:GetService("MarketplaceService")

function module:retrieveId(userId, id, tableToAssign, indexToAssign, pResolve)
    local TIME_OUT = 30
    local MAX_RETRIES = 3
    
    Promise.retry(function()
        return Promise.new(function(resolve, reject)
            local retrieved
            local s, err = pcall(function()
                retrieved = MarketplaceService:UserOwnsGamePassAsync(userId, id)
            end)
            if s then
                resolve(retrieved)
            else
                reject(err)
            end
        end):timeout(TIME_OUT)
    end, MAX_RETRIES):andThen(function(...)
        tableToAssign[indexToAssign] = ...

        for _, gamepass in pairs(GamePassStats) do
            local empty = false
            if tableToAssign[gamepass.name] == nil then
                empty = true
                break
            end
            if not empty then pResolve() end
        end
    end):catch(function(err)
        warn(err)
    end)
end

function module:retrieveForPlayer(userId)
    local collected = {}

    local preOwned = UniversalGamePasses[userId] or {}

    Promise.new(function(resolve, reject)
        for _, gamepass in pairs(GamePassStats) do
            if preOwned[gamepass.name] then
                collected[gamepass.name] = true
                return
            end
            module:retrieveId(userId, gamepass.id, collected, gamepass.name, resolve)
        end
    end):catch(function(err)
        warn(string.format("ERROR WHEN RETRIEVING PLAYER GAMEPASSESS || %s", err))
    end)
    :timeout(50)
    :await()

    return collected
end

function module.playerProfileAssign(PlayerProfile)
    return module:retrieveForPlayer(PlayerProfile.id)
end

return module