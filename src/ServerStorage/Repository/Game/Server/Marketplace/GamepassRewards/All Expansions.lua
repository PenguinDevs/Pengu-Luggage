local module = {}

local Resources = require(game.ReplicatedStorage.Resources)
local DataStore2 = Resources:LoadLibrary("DataStore2")
local DefaultDS = Resources:LoadLibrary("DefaultDS")
local VectorTable = Resources:LoadLibrary("VectorTable")

return setmetatable(module, {
    __call = function(_, ...)
        local playerProfile = ...

        local rewardedStore = DataStore2("rewarded", playerProfile.obj)
        local rewardedCache = rewardedStore:Get(DefaultDS.rewarded)

        if not rewardedCache[script.Name] then
            rewardedCache[script.Name] = true
            
            local build1Store = DataStore2("build1", playerProfile.obj)
            local build1Cache = build1Store:Get(DefaultDS.build1)
            
            for x = 1, 5 do
                for y = 1, 5 do
                    build1Cache.plots[VectorTable.convert(Vector2.new(x - 3, y - 1))] = true
                end
            end
            
            Resources:GetRemote("Notify"):FireClient(playerProfile.obj, "Green", 20, nil,
                string.format("Thank you for purchasing the All Expansions gamepass! All the expansions on your plot is yours for free!")
            )

            playerProfile.data:setVal("build1", build1Cache)
            playerProfile.data:setVal("rewarded", rewardedCache)
            
            build1Store:Get(DefaultDS.build1)
            rewardedStore:Get(DefaultDS.rewarded)
        end
    end
})