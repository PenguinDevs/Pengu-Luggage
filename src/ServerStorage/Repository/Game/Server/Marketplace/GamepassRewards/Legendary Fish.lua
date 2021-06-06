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
            
            fishCache["Neon Carp"] = fishCache["Neon Carp"] or 0
            fishCache["Spiked Shark"] = fishCache["Spiked Shark"] or 0
            fishCache["Ghost Fish"] = fishCache["Ghost Fish"] or 0
            fishCache["Neon Carp"] += 3
            fishCache["Spiked Shark"] += 3
            fishCache["Ghost Fish"] += 3

            Resources:GetRemote("Notify"):FireClient(playerProfile.obj, "Green", 20, nil,
                string.format("Thank you for purchasing the legendary fish pack! You have received 3 ghost fish, neon carp, and spiked sharks!")
            )

            playerProfile.data:setVal("fish", fishCache)
            playerProfile.data:setVal("rewarded", rewardedCache)
            
            fishStore:Get(DefaultDS.fish)
            rewardedStore:Get(DefaultDS.rewarded)
        end
    end
})