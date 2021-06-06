local module = {}

local Resources = require(game.ReplicatedStorage.Resources)
local DataStore2 = Resources:LoadLibrary("DataStore2")
local DefaultDS = Resources:LoadLibrary("DefaultDS")
local DailyRewardList = Resources:LoadLibrary("DailyRewardList")
local PlayerProfiles = Resources:LoadLibrary("PlayerProfiles")

local Time = 60 ^ 2 * 12

Resources:GetRemote("ClaimDaily").OnServerEvent:Connect(function(player)
    local playerProfile = PlayerProfiles:getProfile(player)
    local dailyCollectedStore = DataStore2("dailyCollected", player)
    local dailyCollectedCache = dailyCollectedStore:Get(DefaultDS.dailyCollected)
    local dailyStreakStore = DataStore2("dailyStreak", player)
    local dailyStreakCache = dailyStreakStore:Get(DefaultDS.dailyStreak)

    if os.time() - dailyCollectedCache > Time then
        dailyStreakCache += 1
        dailyStreakCache = math.clamp(dailyStreakCache, 1, 5)
        local reward = DailyRewardList[dailyStreakCache]
        if reward.type == "money" then
            playerProfile.data:incrVal("money", reward.reward)
            Resources:GetRemote("Notify"):FireClient(playerProfile.obj, "Green", 20, nil,
                string.format(string.format("You received $%s from daily rewards! Come back tommorow!", reward.reward))
            )
        elseif reward.type == "fish" then
            local fishStore = DataStore2("fish", playerProfile.obj)
            local fishCache = fishStore:Get(DefaultDS.fish)
            
            fishCache["Shark"] = fishCache["Shark"] or 0
            fishCache["Shark"] += 1

            playerProfile.data:setVal("fish", fishCache)
            fishStore:Get(DefaultDS.fish)

            Resources:GetRemote("Notify"):FireClient(playerProfile.obj, "Green", 20, nil,
                string.format(string.format("You received a %s from daily rewards! Come back tommorow!", reward.reward))
            )
        end
        playerProfile.data:incrVal("dailyStreak", 1)
        playerProfile.data:setVal("dailyCollected", os.time())
    end
end)

return module