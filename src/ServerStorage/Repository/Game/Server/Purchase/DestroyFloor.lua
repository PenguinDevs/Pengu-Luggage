local Resources = require(game.ReplicatedStorage.Resources)
local PlayerProfiles = Resources:LoadLibrary("PlayerProfiles")
local DataStore2 = Resources:LoadLibrary("DataStore2")
local DefaultDS = Resources:LoadLibrary("DefaultDS")
local FloorStats = Resources:LoadLibrary("FloorStats")
local VectorTable = Resources:LoadLibrary("VectorTable")
local Round = Resources:LoadLibrary("Round")
local FishHoldIndexer = Resources:LoadLibrary("FishHoldIndexer")

local module = {}

Resources:GetRemote("DestroyFloor").OnServerEvent:Connect(function(player, iPos)
	local playerProfile = PlayerProfiles:getProfile(player)
	local moneyStore = DataStore2("money", player)
	local moneyCache = moneyStore:Get(DefaultDS.money)
	local build1Store = DataStore2("build1", player)
	local build1Cache = build1Store:Get(DefaultDS.build1)
	local floorOwned = build1Cache.floors[iPos]
	if not floorOwned then return end
	local floorStat = FloorStats[floorOwned.floor]
	if not floorStat then return end
	
	if floorStat.fishHold then
		-- local fishStore = DataStore2("fish", player)
		-- local fishCache = fishStore:Get(DefaultDS.fish)
		local fishHoldStore = DataStore2("fishHold", player)
		local fishHoldCache = fishHoldStore:Get(DefaultDS.fishHold)
		if fishHoldCache[FishHoldIndexer.convert("floor", iPos)] then
			fishHoldCache[FishHoldIndexer.convert("floor", iPos)] = nil
			playerProfile.data:setVal("fishHold", fishHoldCache)
		end
	end

	build1Cache.floors[iPos] = nil

	playerProfile.data:incrVal("money", Round(floorStat.price * 0.5))
	playerProfile.data:setVal("build1", build1Cache)
	playerProfile.floorBuild:update()
end)

return module
