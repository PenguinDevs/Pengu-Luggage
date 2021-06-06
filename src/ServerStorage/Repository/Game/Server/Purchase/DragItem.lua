local Resources = require(game.ReplicatedStorage.Resources)
local PlayerProfiles = Resources:LoadLibrary("PlayerProfiles")
local DataStore2 = Resources:LoadLibrary("DataStore2")
local DefaultDS = Resources:LoadLibrary("DefaultDS")
local ItemStats = Resources:LoadLibrary("ItemStats")
local VectorTable = Resources:LoadLibrary("VectorTable")
local Round = Resources:LoadLibrary("Round")
local FishHoldIndexer = Resources:LoadLibrary("FishHoldIndexer")
--local DestroyItem = Resources:LoadLibrary("DestroyItem")

local module = {}

Resources:GetRemote("DragItem").OnServerInvoke = function(player, iPos)
	local playerProfile = PlayerProfiles:getProfile(player)
	local moneyStore = DataStore2("money", player)
	local moneyCache = moneyStore:Get(DefaultDS.money)
	local build1Store = DataStore2("build1", player)
	local build1Cache = build1Store:Get(DefaultDS.build1)
	local itemOwned = build1Cache.items[iPos]
	if not itemOwned then return false end
	local itemStat = ItemStats[itemOwned.item]
	if not itemStat then return false end
	
    local fishHoldStat

	if itemStat.fishHold then
		-- local fishStore = DataStore2("fish", player)
		-- local fishCache = fishStore:Get(DefaultDS.fish)
		local fishHoldStore = DataStore2("fishHold", player)
		local fishHoldCache = fishHoldStore:Get(DefaultDS.fishHold)
        local fishHoldIndex = FishHoldIndexer.convert("item", iPos)
		if fishHoldCache[fishHoldIndex] then
            fishHoldStat = fishHoldCache[fishHoldIndex]
            fishHoldCache[fishHoldIndex] = nil
            playerProfile.data:setVal("fishHold", fishHoldCache)
		end
	end
    --DestroyItem(player, iPos, true)

    build1Cache.items[iPos] = nil

    playerProfile.data:setVal("build1", build1Cache)
	playerProfile.itemBuild:update()

    playerProfile.drag.pendingDrag.item = {name = itemOwned.item, fishHoldStat = fishHoldStat}
    return true
end

return module
