local module = {}

local Resources = require(game.ReplicatedStorage.Resources)
local DataStore2 = Resources:LoadLibrary("DataStore2")
local DefaultDS = Resources:LoadLibrary("DefaultDS")

return setmetatable(module, {
    __call = function(_, ...)
        local playerProfile = ...

        local rewardedStore = DataStore2("rewarded", playerProfile.obj)
        local rewardedCache = rewardedStore:Get(DefaultDS.rewarded)

        if not rewardedCache[script.Name] then
            rewardedCache[script.Name] = true
            
            local fishStore = DataStore2("fish", playerProfile.obj)
            local fishCache = fishStore:Get(DefaultDS.fish)
            
            fishCache["Frosty Dory"] = fishCache["Frosty Dory"] or 0
            fishCache["Frosty Dory"] += 3

            Resources:GetRemote("Notify"):FireClient(playerProfile.obj, "Green", 20, nil,
                string.format("Thanks for liking the game and joining the group! You received a frosty dory!")
            )

            playerProfile.data:setVal("fish", fishCache)
            playerProfile.data:setVal("rewarded", rewardedCache)
            
            fishStore:Get(DefaultDS.fish)
            rewardedStore:Get(DefaultDS.rewarded)
        end
    end
})