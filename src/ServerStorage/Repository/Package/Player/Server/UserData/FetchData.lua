-- Responsible for sending back data requested to the client using ProfileService
-- @author PenguinDevs

local module = {}

local Resources = require(game.ReplicatedStorage.Resources)

function module:init()
    Resources:GetRemote("FetchData").OnServerInvoke = function(player, requestedData)
        
    end
end

return module