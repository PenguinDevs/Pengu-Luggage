local Resources = require(game.ReplicatedStorage.Resources)
local PlayerProfiles = Resources:LoadLibrary("PlayerProfiles")
local DataStore2 = Resources:LoadLibrary("DataStore2")
local DefaultDS = Resources:LoadLibrary("DefaultDS")
local FloorStats = Resources:LoadLibrary("FloorStats")
local VectorTable = Resources:LoadLibrary("VectorTable")

local module = {}

function CheckiPosLegal(plots, iPos)
	local targetPos = VectorTable.rconvert(iPos)
	local safe = false
	for plotiPos, _ in pairs(plots) do
		local plotPos = VectorTable.rconvert(plotiPos)
		local offsetX = 2
		local offsetY = 3
		local minX = plotPos.X * 4 - 3 + offsetX
		local maxX = plotPos.X * 4 + 0 + offsetX
		local minY = plotPos.Y * 4 - 3 + offsetY
		local maxY = plotPos.Y * 4 + 0 + offsetY
		--print(minX, maxX, minY, maxY, iPos)
		if targetPos.X < minX then continue end
		if targetPos.X > maxX then continue end
		if targetPos.Y < minY then continue end
		if targetPos.Y > maxY then continue end
		safe = true
		break
	end
	if safe then
		return true
	else
		return false
	end
end

Resources:GetRemote("BuildFloor").OnServerEvent:Connect(function(player, itemName, iPos, c3)
	local playerProfile = PlayerProfiles:getProfile(player)
	local moneyStore = DataStore2("money", player)
	local moneyCache = moneyStore:Get(DefaultDS.money)
	local build1Store = DataStore2("build1", player)
	local build1Cache = build1Store:Get(DefaultDS.build1)
	local floorStat = FloorStats[itemName]
	local pos = VectorTable.rconvert(iPos)
	
	if not floorStat then return end
	if pos.X > 10 then return end
	if pos.X < -9 then return end
	if pos.Y < 0 then return end
	if pos.Y > 19 then return end
	if build1Cache.floors[iPos] then return end
	if moneyCache < floorStat.price then return end
	if not CheckiPosLegal(build1Cache.plots, iPos) then return end
	build1Cache.floors[iPos] = {
		floor = itemName;
		colour = {math.floor(c3.R * 255), math.floor(c3.G * 255), math.floor(c3.B * 255)};
	}

	playerProfile.data:incrVal("money", -floorStat.price)
	playerProfile.data:setVal("build1", build1Cache)
	playerProfile.floorBuild:update()
end)

return module
