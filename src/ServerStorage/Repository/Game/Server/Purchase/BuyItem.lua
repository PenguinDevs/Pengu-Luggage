local Resources = require(game.ReplicatedStorage.Resources)
local PlayerProfiles = Resources:LoadLibrary("PlayerProfiles")
local DataStore2 = Resources:LoadLibrary("DataStore2")
local DefaultDS = Resources:LoadLibrary("DefaultDS")
local ItemStats = Resources:LoadLibrary("ItemStats")
local VectorTable = Resources:LoadLibrary("VectorTable")
local FishHoldIndexer = Resources:LoadLibrary("FishHoldIndexer")

local module = {}

function CheckiPosLegal(plots, iPos)
	local targetPos = VectorTable.rconvert(iPos)
	local safe = false
	for plotiPos, _ in pairs(plots) do
		local plotPos = VectorTable.rconvert(plotiPos)
		local offsetX = 0
		local offsetY = 0
		local minX = plotPos.X * 16 - 7 + offsetX
		local maxX = plotPos.X * 16 + 8 + offsetX
		local minY = plotPos.Y * 16 - 0 + offsetY
		local maxY = plotPos.Y * 16 + 15 + offsetY
		--print(minX, maxX, minY, maxY, ":", targetPos)
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

function module:perform(player, itemName, iPos, rot, c3)
	local playerProfile = PlayerProfiles:getProfile(player)
	local moneyStore = DataStore2("money", player)
	local moneyCache = moneyStore:Get(DefaultDS.money)
	local build1Store = DataStore2("build1", player)
	local build1Cache = build1Store:Get(DefaultDS.build1)
	local itemStat = ItemStats[itemName]
	local pos = VectorTable.rconvert(iPos)
	
	local pendingDrag = playerProfile.drag.pendingDrag.item or {}

	if itemStat.reqPass == "VIP" then
		if not playerProfile.passes[itemStat.reqPass] then
			warn("does not have VIP when placing item", player)
			return
		end
	end

	if not itemStat then return end
	-- if pos.X > 10 then return end
	-- if pos.X < -9 then return end
	-- if pos.Y < 0 then return end
	-- if pos.Y > 19 then return end
	if build1Cache.items[iPos] then return end
	if itemName ~= pendingDrag.name then
		if moneyCache < itemStat.price then return end
	end
	if not CheckiPosLegal(build1Cache.plots, iPos) then return end
	build1Cache.items[iPos] = {
		item = itemName;
		rot = rot;
		colour = {math.floor(c3.R * 255), math.floor(c3.G * 255), math.floor(c3.B * 255)};
	}

	local fishHoldCache
	if itemName == pendingDrag.name then
		if pendingDrag.fishHoldStat then
			local fishHoldStore = DataStore2("fishHold", player)
			fishHoldCache = fishHoldStore:Get(DefaultDS.fishHold)
			local fishHoldIndex = FishHoldIndexer.convert("item", iPos)
			fishHoldCache[fishHoldIndex] = pendingDrag.fishHoldStat
			--fishHoldStore:Set(fishHoldCache)
		end
		playerProfile.drag.pendingDrag.item = nil
	else
		playerProfile.data:incrVal("money", -itemStat.price)
	end
	playerProfile.data:setVal("build1", build1Cache)
	playerProfile.itemBuild:update()
	if fishHoldCache then
		playerProfile.data:setVal("fishHold", fishHoldCache)
	end
end
Resources:GetRemote("BuildItem").OnServerEvent:Connect(function(...) module:perform(...) end)

return module
