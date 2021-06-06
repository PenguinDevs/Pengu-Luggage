local Resources = require(game.ReplicatedStorage.Resources)
local PlayerProfiles = Resources:LoadLibrary("PlayerProfiles")
local DataStore2 = Resources:LoadLibrary("DataStore2")
local DefaultDS = Resources:LoadLibrary("DefaultDS")
local WallStats = Resources:LoadLibrary("WallStats")
local VectorTable = Resources:LoadLibrary("VectorTable")
local Round = Resources:LoadLibrary("Round")

local module = {}

Resources:GetRemote("DestroyWall").OnServerEvent:Connect(function(player, iPos, parent)
	local playerProfile = PlayerProfiles:getProfile(player)
	local moneyStore = DataStore2("money", player)
	local moneyCache = moneyStore:Get(DefaultDS.money)
	local build1Store = DataStore2("build1", player)
	local build1Cache = build1Store:Get(DefaultDS.build1)
	if not parent then return end
	local dir = (parent.Name == "HWalls") and "h" or "v"
	local wallOwned = build1Cache.walls[dir][iPos]
	if not wallOwned then return end
	local wallStat = WallStats[wallOwned.wall]
	if not wallStat then return end
	
	build1Cache.walls[dir][iPos] = nil

	playerProfile.data:incrVal("money", Round(wallStat.price * 0.5))
	playerProfile.data:setVal("build1", build1Cache)
	playerProfile.wallBuild:update()
end)

return module
