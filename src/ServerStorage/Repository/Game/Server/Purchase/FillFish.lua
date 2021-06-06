local Resources = require(game.ReplicatedStorage.Resources)
local FishStats = Resources:LoadLibrary("FishStats")
local ItemStats = Resources:LoadLibrary("ItemStats")
local FloorStats = Resources:LoadLibrary("FloorStats")
local PlayerProfiles = Resources:LoadLibrary("PlayerProfiles")
local DataStore2 = Resources:LoadLibrary("DataStore2")
local DefaultDS = Resources:LoadLibrary("DefaultDS")
local fishHoldIndexer = Resources:LoadLibrary("FishHoldIndexer")
local TankProfitLabel = Resources:LoadLibrary("TankProfitLabel")

local module = {}

Resources:GetRemote("FishFill").OnServerEvent:Connect(function(player, fishHoldIndex, fishName, amountToAdd)
    local playerProfile = PlayerProfiles:getProfile(player)
    local fishStore = DataStore2("fish", player)
    local fishCache = fishStore:Get(DefaultDS.fish)
    local fishHoldStore = DataStore2("fishHold", player)
    local fishHoldCache = fishHoldStore:Get(DefaultDS.fishHold)
    local build1Store = DataStore2("build1", player)
	local build1Cache = build1Store:Get(DefaultDS.build1)

    local itemType, iPos = fishHoldIndexer.rconvert(fishHoldIndex)
    local itemStat = itemType == "item" and ItemStats[build1Cache.items[iPos].item] or FloorStats[build1Cache.floors[iPos].floor]
    
    if not fishHoldCache[fishHoldIndex] then fishHoldCache[fishHoldIndex] = {} end
    if not fishHoldCache[fishHoldIndex][fishName] then fishHoldCache[fishHoldIndex][fishName] = 0 end
    local totalFishInTanks = 0
    for _, fishHolding in pairs(fishHoldCache) do
        for fishName2, fishAmount in pairs(fishHolding) do
            if fishName2 == fishName then
                totalFishInTanks += fishAmount
            end
        end
    end
    --print(fishCache[fishName], fishCache)
    fishCache[fishName] = fishCache[fishName] or 0
    if totalFishInTanks > fishCache[fishName] then return end
    fishHoldCache[fishHoldIndex][fishName] += amountToAdd
    local weightTotal = 0
    for fishName, fishAmount in pairs(fishHoldCache[fishHoldIndex]) do
        local fishStat = FishStats[fishName]
        weightTotal += fishAmount * fishStat.weight
    end
    if fishHoldCache[fishHoldIndex][fishName] < 0 then return end
    if weightTotal > itemStat.fishHold then return end
    if fishHoldCache[fishHoldIndex][fishName] == 0 then fishHoldCache[fishHoldIndex][fishName] = nil end

    --playerProfile.data:setVal("fish", fishCache)
    playerProfile.data:setVal("fishHold", fishHoldCache)

    local plot = playerProfile.landPlots.obj
    local itemObj
    if itemType == "item" then
        itemObj = plot.Items:FindFirstChild(iPos)
    else
        itemObj = plot.Items:FindFirstChild(iPos)
    end
    TankProfitLabel:getLabel(playerProfile, itemObj, fishHoldCache[fishHoldIndex])
end)

return module