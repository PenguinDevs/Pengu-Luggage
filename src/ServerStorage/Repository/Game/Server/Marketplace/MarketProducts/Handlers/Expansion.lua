local Resources = require(game.ReplicatedStorage.Resources)
local PlayerProfile = Resources:LoadLibrary("PlayerProfiles")
local DataStore2 = Resources:LoadLibrary("DataStore2")
local DefaultDS = Resources:LoadLibrary("DefaultDS")

local module = {}

return setmetatable(module, {
    __call = function(_, ...)
        local player, product = ...
        local playerProfile = PlayerProfile:getProfile(player)
        
        local build1Store = DataStore2("build1", player)
	    local build1Cache = build1Store:Get(DefaultDS.build1)
        
        build1Cache.plots[playerProfile.wantedPlot] = true

        playerProfile.data:setVal("build1", build1Cache)

        playerProfile.landPlots:updatePlots()
        return "Succesfully bought land!"
    end
})