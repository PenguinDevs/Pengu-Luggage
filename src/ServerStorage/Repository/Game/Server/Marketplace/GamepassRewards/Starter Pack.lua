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

            fishCache["Catfish"] = fishCache["Catfish"] or 0
            fishCache["Shark"] = fishCache["Shark"] or 0
            fishCache["Turtle"] = fishCache["Turtle"] or 0
            fishCache["Catfish"] += 3
            fishCache["Shark"] += 2
            fishCache["Turtle"] += 1

            Resources:GetRemote("Notify"):FireClient(playerProfile.obj, "Green", 20, nil,
                string.format("Thank you for purchasing the starter pack! You have received 50k in money, 3 sharks, 2 turtles and a whale!")
            )

            playerProfile.data:incrVal("money", 50000)
            playerProfile.data:setVal("fish", fishCache)
            playerProfile.data:setVal("rewarded", rewardedCache)

            fishStore:Get(DefaultDS.fish)
            rewardedStore:Get(DefaultDS.rewarded)
        end
    end
})