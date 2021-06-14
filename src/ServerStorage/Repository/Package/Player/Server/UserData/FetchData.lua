-- Responsible for sending back data requested to the client using ProfileService
-- @author PenguinDevs

local module = {}

local Resources = require(game.ReplicatedStorage.Resources)
local PlayerProfiles = Resources:LoadLibrary("PlayerProfiles")
local DefaultDS = Resources:LoadLibrary("DefaultDS")

function module:init()
    Resources:GetRemote("FetchData").OnServerInvoke = function(player, requestedData)
        local collectedReturn = {}

        local PlayerProfile = PlayerProfiles:get(player)

        for _, dataType in pairs(requestedData) do
            if DefaultDS[dataType] then
                collectedReturn[dataType] = PlayerProfile.data:get(dataType)
            else
                error(string.format("%s is not reigstered on DefaultDS module", dataType))
            end
        end

        return collectedReturn
    end
end

return module