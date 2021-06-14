-- Holds the status of the client such as data and joined time
-- @author PenguinDevs

local module = {}

local Resources = require(game.ReplicatedStorage.Resources)
local Promise = Resources:LoadLibrary("Promise")
local DefaultDS = Resources:LoadLibrary("DefaultDS")
local RetrieveGamePass = Resources:LoadLibrary("RetrieveGamePass")

local PlayersService = game:GetService("Players")

local Player = PlayersService.LocalPlayer

function fetchData()
    local MAX_RETRIES = 10
    local TIME_OUT = 30

    local fetchRequest = {}
    for i, v in pairs(DefaultDS) do table.insert(fetchRequest, 1, i) end

    local dataCollected
    local function fetch(resolve, reject)
        local s, err = pcall(function()
            dataCollected = Resources:GetRemote("FetchData"):InvokeServer(fetchRequest)
        end)
        if s then
            resolve()
        else
            reject(err)
        end
    end
    Promise.retry(function()
        return Promise.new(fetch)
               :timeout(TIME_OUT)
    end, MAX_RETRIES)
    :andThen(function()
        print("Data Fetched")
        module.data = dataCollected
    end):catch(function(err)
        warn(string.format("FATAL ERROR || DATA FETCH FAILED || %s", err))
    end):await()
end

function fetchPasses()
    module.passes = RetrieveGamePass:retrieveForPlayer(Player.UserId)
end

function module:init()
    module.joinedTick = os.clock()
    module.joinedTime = os.time()
    fetchData()
    fetchPasses()
end

return module