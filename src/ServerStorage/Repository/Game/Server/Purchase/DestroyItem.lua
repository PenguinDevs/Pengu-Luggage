local Resources = require(game.ReplicatedStorage.Resources)
local PlayerProfiles = Resources:LoadLibrary("PlayerProfiles")
local DataStore2 = Resources:LoadLibrary("DataStore2")
local DefaultDS = Resources:LoadLibrary("DefaultDS")
local ItemStats = Resources:LoadLibrary("ItemStats")
local VectorTable = Resources:LoadLibrary("VectorTable")
local Round = Resources:LoadLibrary("Round")
local FishHoldIndexer = Resources:LoadLibrary("FishHoldIndexer")

local module = {}

function module:perform(player, iPos, ignoreRefund)
	local playerProfile = PlayerProfiles:getProfile(player)
	local moneyStore = DataStore2("money", player)
	local moneyCache = moneyStore:Get(DefaultDS.money)
	local build1Store = DataStore2("build1", player)
	local build1Cache = build1Store:Get(DefaultDS.build1)
	local itemOwned = build1Cache.items[iPos]
	if not itemOwned then return end
	local itemStat = ItemStats[itemOwned.item]
	if not itemStat then return end
	
	if itemStat.fishHold then
		-- local fishStore = DataStore2("fish", player)
		-- local fishCache = fishStore:Get(DefaultDS.fish)
		local fishHoldStore = DataStore2("fishHold", player)
		local fishHoldCache = fishHoldStore:Get(DefaultDS.fishHold)
		local fishHoldIndex = FishHoldIndexer.convert("item", iPos)
		if fishHoldCache[fishHoldIndex] then
			fishHoldCache[fishHoldIndex] = nil
			playerProfile.data:setVal("fishHold", fishHoldCache)
		end
	end

	build1Cache.items[iPos] = nil

	if not ignoreRefund then
		playerProfile.data:incrVal("money", Round(itemStat.price * 0.5))
	end
	playerProfile.data:setVal("build1", build1Cache)
	playerProfile.itemBuild:update()
end
Resources:GetRemote("DestroyItem").OnServerEvent:Connect(function(...) module:perform(...) end)

return module
