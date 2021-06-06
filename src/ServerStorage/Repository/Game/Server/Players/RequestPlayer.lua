local Resources = require(game.ReplicatedStorage.Resources)
local PlayerProfiles = Resources:LoadLibrary("PlayerProfiles")
local DataStore2 = Resources:LoadLibrary("DataStore2")
local DefaultDS = Resources:LoadLibrary("DefaultDS")
local getCustomerAmount = Resources:LoadLibrary("GetCustomerAmount")
local getCustomerSatisfaction = Resources:LoadLibrary("GetCustomerSatisfaction")

local module = {}

Resources:GetRemote("RequestPlayer").OnServerInvoke = function(_, player)
    local requestedProfile = PlayerProfiles:getProfile(player)
    if not requestedProfile then return end
    local build1Store = DataStore2("build1", player)
    local fishHoldStore = DataStore2("fishHold", player)
    if not requestedProfile.landPlots then
        return nil
    end
    local data = {
        customers = getCustomerAmount(build1Store:Get(DefaultDS.build1));
        satisfaction = getCustomerSatisfaction(build1Store:Get(DefaultDS.build1), fishHoldStore:Get(DefaultDS.fishHold));
        plot = requestedProfile.landPlots.plotI;
    }
    return data
end

return module