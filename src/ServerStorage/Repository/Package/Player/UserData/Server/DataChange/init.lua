local module = {}

local Resources = require(game.ReplicatedStorage.Resources)
local DefaultDS = Resources:LoadLibrary("DefaultDS")
local DataStore2 = Resources:LoadLibrary("DataStore2")
local Signal = Resources:LoadLibrary("Signal")
local SetDataRemote = Resources:GetRemote("Data")

local LeaderboardWhitelist = {
	["money"] = true;
	["build1"] = true;
}

local TotalLinks = {
	["money"] = "tMoney";
}

function module:playerProfileAssign(playerProfile)
	local returner = {}
	
	local function handleRest(valName, valAmount)
		SetDataRemote:FireClient(playerProfile.obj, valName, valAmount)
		
		if LeaderboardWhitelist[valName] then playerProfile.leaderstats:update() end
		--avoiding updating lData on update since this is supposed to be total accumulated points, as well avoiding decreases from purchases
		
		require(script.DataTypeLinks)(playerProfile, valName, valAmount)
	end
	
	function returner:incrVal(valName, valAmount, ignoreMult)
		local store = DataStore2(valName, playerProfile.obj)
		
		if not ignoreMult then
			if valAmount > 0 then
				if valName == "money" then
					if playerProfile.passes then
						if playerProfile.passes["2x Money"] then
							valAmount *= 2
						end
					end
					-- valAmount *= module._boostsHandler:getBoosts(playerStat)["snow"]
					-- valAmount += playerStat.pets:getMults()["snow"] or 0
				end
			end
		end
		
		--if playerStat.lData.data[valName] then if valAmount > 0 then playerStat.lData:incrVal(valName, valAmount) end end
		if TotalLinks[valName] then if valAmount > 0 then playerProfile.data:incrVal(TotalLinks[valName], valAmount) end end
		
		local valAmount = store:Get(DefaultDS[valName]) < 0 and valAmount - store:Get(DefaultDS[valName]) or valAmount
		store:Increment(valAmount)
		
		handleRest(valName, store:Get(DefaultDS[valName]))
	end
	
	function returner:setVal(valName, valAmount)
		local store = DataStore2(valName, playerProfile.obj)
		store:Set(valAmount)
		
		handleRest(valName, valAmount)
	end
	
	returner.setValEvent = Signal.new()
	returner.setValEvent:Connect(function(...) returner:setVal(...) end)
	
	returner.incrValEvent = Signal.new()
	returner.incrValEvent:Connect(function(...) returner:incrVal(...) end)
	
	playerProfile.leave:Connect(function()
		returner.setValEvent:Destroy()
		returner.incrValEvent:Destroy()
	end)
	
	return returner
end

return module
