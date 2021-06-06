local module = {}

local Resources = require(game.ReplicatedStorage.Resources)
local PlayerProfiles = Resources:LoadLibrary("PlayerProfiles")
local DataStore2 = Resources:LoadLibrary("DataStore2")
local DefaultDS = Resources:LoadLibrary("DefaultDS")
local FishStats = Resources:LoadLibrary("FishStats")
local Round = Resources:LoadLibrary("Round")

Resources:GetRemote("BuyFish").OnServerEvent:Connect(function(player, fishName, amount)
    local playerProfile = PlayerProfiles:getProfile(player)
	local moneyStore = DataStore2("money", player)
	local moneyCache = moneyStore:Get(DefaultDS.money)
    local fishStore = DataStore2("fish", player)
	local fishCache = fishStore:Get(DefaultDS.fish)
    local fishStat = FishStats[fishName]

    local price = fishStat.price
    if playerProfile.passes["VIP"] then price *= 0.7 end
    price = Round(price)

    local totalPrice = amount * price
    if moneyCache < totalPrice then return end
    if not fishCache[fishName] then fishCache[fishName] = 0 end
    fishCache[fishName] += amount

    playerProfile.data:incrVal("money", -totalPrice)
    playerProfile.data:setVal("fish", fishCache)
end)

return module