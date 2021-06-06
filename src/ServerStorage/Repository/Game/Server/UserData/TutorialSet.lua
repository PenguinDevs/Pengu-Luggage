local module = {}

local Resources = require(game.ReplicatedStorage.Resources)
local DataStore2 = Resources:LoadLibrary("DataStore2")
local DefaultDS = Resources:LoadLibrary("DefaultDS")
local BadgeService = game:GetService("BadgeService")

Resources:GetRemote("Tutorial").OnServerEvent:Connect(function(player)
    local PlayerProfiles = Resources:LoadLibrary("PlayerProfiles")
    local playerProfile = PlayerProfiles:getProfile(player)
    playerProfile.data:setVal("hadTutorial", 1)
    BadgeService:AwardBadge(player.UserId, 2124742617)
end)

function module:playerProfileAssign(playerProfile)
    -- local hadTutorialStore = DataStore2("hadTutorial", playerProfile.obj)
    -- if hadTutorialStore:Get(DefaultDS.hadTutorial) == 0 then
    --     local build1Store = DataStore2("build1", playerProfile.obj)
    --     local build1Cache = build1Store:Get(DefaultDS.build1)
    --     local fishStore = DataStore2("fish", playerProfile.obj)
    --     local fishCache = fishStore:Get(DefaultDS.fish)
    --     local moneyStore = DataStore2("money", playerProfile.obj)
    --     local moneyCache = moneyStore:Get(DefaultDS.money)

    --     playerProfile.data:setVal(DefaultDS.DATA_NO, {})
    --     DataStore2(DefaultDS.DATA_NO, playerProfile.obj):Get({})
    --     playerProfile.data:setVal("build1", build1Cache)
    --     build1Store:Get(DefaultDS.build1)
    --     playerProfile.data:setVal("fish", fishCache)
    --     fishStore:Get(DefaultDS.fish)
    --     playerProfile.data:setVal("money", moneyCache)
    --     moneyStore:Get(DefaultDS.money)
    -- else
    --     spawn(function()
    --         if not BadgeService:UserHasBadgeAsync(playerProfile.id, 2124742617) then
    --             BadgeService:AwardBadge(playerProfile.id, 2124742617)
    --         end
    --     end)
    -- end

    if not BadgeService:UserHasBadgeAsync(playerProfile.id, 2124742617) then
        BadgeService:AwardBadge(playerProfile.id, 2124742617)
    end
end

return module
