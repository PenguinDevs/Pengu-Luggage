local Resources = require(game.ReplicatedStorage.Resources)
local PlayerProfiles = Resources:LoadLibrary("PlayerProfiles")
local DataStore2 = Resources:LoadLibrary("DataStore2")
local DefaultDS = Resources:LoadLibrary("DefaultDS")
local WallStats = Resources:LoadLibrary("WallStats")
local VectorTable = Resources:LoadLibrary("VectorTable")
local GamepassStats = Resources:LoadLibrary("GamepassStats")

local module = {}

function CheckiPosLegalV(plots, iPos)
	local targetPos = VectorTable.rconvert(iPos)
	local safe = false
	for plotiPos, _ in pairs(plots) do
		local plotPos = VectorTable.rconvert(plotiPos)
		local offsetX = 2
		local offsetY = 3
		local minX = plotPos.X * 4 - 4 + offsetX
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

function CheckiPosLegalH(plots, iPos)
	local targetPos = VectorTable.rconvert(iPos)
	local safe = false
	for plotiPos, _ in pairs(plots) do
		local plotPos = VectorTable.rconvert(plotiPos)
		local offsetX = 2
		local offsetY = 3
		local minX = plotPos.X * 4 - 3 + offsetX
		local maxX = plotPos.X * 4 + 0 + offsetX
		local minY = plotPos.Y * 4 - 3 + offsetY
		local maxY = plotPos.Y * 4 + 1 + offsetY
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

Resources:GetRemote("BuildWall").OnServerEvent:Connect(function(player, itemName, iPos, rot, c3)
	local playerProfile = PlayerProfiles:getProfile(player)
	local moneyStore = DataStore2("money", player)
	local moneyCache = moneyStore:Get(DefaultDS.money)
	local build1Store = DataStore2("build1", player)
	local build1Cache = build1Store:Get(DefaultDS.build1)
	local wallStat = WallStats[itemName]
	local pos = VectorTable.rconvert(iPos)
	local dir = (rot == 1 or rot == 3) and "v" or "h"
	local dirRot
	if rot == 1 then dirRot = 2 end
	if rot == 2 then dirRot = 1 end
	if rot == 3 then dirRot = 1 end
	if rot == 4 then dirRot = 2 end
	
	if wallStat.reqPass == "VIP" then
		if not playerProfile.passes[wallStat.reqPass] then
			warn("does not have VIP when placing wall", player)
			return
		end
	end

	if not wallStat then return end
	if build1Cache.walls[dir][iPos] then return end
	if moneyCache < wallStat.price then return end
	if dir == "v" then
		if not CheckiPosLegalV(build1Cache.plots, iPos) then return end
	else
		if not CheckiPosLegalH(build1Cache.plots, iPos) then return end
	end
	build1Cache.walls[dir][iPos] = {
		wall = itemName;
		rot = dirRot;
		colour = {math.floor(c3.R * 255), math.floor(c3.G * 255), math.floor(c3.B * 255)};
	}

	playerProfile.data:incrVal("money", -wallStat.price)
	playerProfile.data:setVal("build1", build1Cache)
	playerProfile.wallBuild:update()
end)

return module
