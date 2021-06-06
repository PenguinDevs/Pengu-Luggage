local module = {}

local datastoreService = game:GetService("DataStoreService")
local Resources = require(game.ReplicatedStorage.Resources)
local DataStore2 = Resources:LoadLibrary("DataStore2")
local DefaultDS = Resources:LoadLibrary("DefaultDS")
local Round = Resources:LoadLibrary("Round")

module._dataStoreScope = DefaultDS.DATA_NO

module._playerProfiles = nil

module._dataTypesDefVal = {
	["timeplayed"] = 0;
	["money"] = 0;
}

module._dataLink = {
	["timeplayed"] = "tTime";
	["money"] = "tMoney"
}

module.lowestVals = module._dataTypesDefVal

local function roundDown(n)
	return n - (n) % 1
end

function module:savePlayer(playerProfile, dataType)
	if not dataType then warn("dataType was not provided when :savePlayer for lData" .. tostring(debug.traceback())) end
	--	if not rawSave then
		local name = playerProfile.name
		if not playerProfile.lData then warn("could not save leaderbaord data due to .lData == nil" .. tostring(name)) return end
	
		local dataLink = module._dataLink[dataType]
		--for dataType, dataLink in pairs(module._dataLink) do
			local mainStore = DataStore2(dataLink, playerProfile.obj)
			local dataVal = Round(mainStore:Get(DefaultDS[dataLink]))
			local dataStore = datastoreService:GetOrderedDataStore(tostring("leaderboard" .. DefaultDS.LEADERBOARD_NO .. dataType .. DefaultDS.DATA_NO))
			
			--if dataType == "timeplayed" then
			--	dataVal += (tick() - playerStat.lData.lastSaved)
			--	playerStat.lData.data[dataType] = dataVal
			--	dataVal = roundDown(dataVal)
			--end
			
			dataStore:SetAsync(tostring(playerProfile.id), dataVal)
		--end
		
		--print("saved leaderboard data", name, dataType)
		--playerStat.lData.lastSaved = tick()
	--else
	--	game:BindToClose(function()
	--		for dataType, dataVal in pairs(playerStat.lData.data) do
	--			local dataStore = datastoreService:GetOrderedDataStore(tostring("leaderboard" .. dataType .. DefaultDS.DATA_NO))

	--			if dataType == "timeplayed" then
	--				dataVal += (tick() - playerStat.lData.lastSaved)
	--				playerStat.lData.data[dataType] = dataVal
	--				dataVal = roundDown(dataVal)
	--			end

	--			dataStore:SetAsync(tostring(rawSave), dataVal)
	--		end

	--		print("saved leaderboard data on raw", rawSave)
	--	end)
	--end
end

function module:retrieveData(playerProfile)
	if true then warn("deprecated for :retrieveData for lData") return end
	local returner = {}
	
	for dataType, dataVal in pairs(module._dataTypesDefVal) do
		local dataStore = datastoreService:GetOrderedDataStore(tostring("leaderboard" .. DefaultDS.LEADERBOARD_NO .. dataType .. DefaultDS.DATA_NO))
		returner[dataType] = dataStore:GetAsync(tostring(playerProfile.id))
		if not returner[dataType] then returner[dataType] = dataVal end
		Resources:GetRemote("LData"):FireClient(playerProfile.obj, dataType, returner[dataType])
	end
	
	return returner
end

function module:playerProfileAssign(playerProfile)
	local dataStore = DataStore2(module._dataStoreScope, playerProfile.obj)
	
	local id = playerProfile.id
	
	local self = {}
	self.saveListener = playerProfile.obj.AncestryChanged:Connect(function()
		if playerProfile.obj:IsDescendantOf(game) then return end
--		module:savePlayer(playerStat)
		self:clean()
	end)
	
	--self.data = {}
	--self.data = module:retrieveData(playerStat)
	
	self.lastSaved = tick()
	
	function self:clean()
		self.saveListener:Disconnect()
		self.cancelSaveLoop = true
	end
	
	local tTimeStore = DataStore2("tTime", playerProfile.obj)
	function self:checkTimeStore()
		local dataVal = tTimeStore:Get(DefaultDS["tTime"])
		dataVal += (tick() - playerProfile.lData.lastSaved)
		dataVal = roundDown(dataVal)
		playerProfile.lData.lastSaved = tick()
		playerProfile.data:setVal("tTime", dataVal)
	end
	
	self.cancelSaveLoop = false
	self.saveLoop = coroutine.wrap(function()
		while true do
			wait(60)
			if self.cancelSaveLoop then return end
			self:checkTimeStore()
			for dataType, dataLink in pairs(module._dataLink) do
				local mainStore = DataStore2(dataLink, playerProfile.obj)
				local dataVal = mainStore:Get(DefaultDS[dataLink])
				--print(dataVal, module.lowestVals[dataType], dataType)
				if dataVal >= module.lowestVals[dataType] then
					--print("saving", playerStat.obj, dataType, dataVal, module.lowestVals[dataType])
					module:savePlayer(playerProfile, dataType)
				end
			end
		end
	end)
	self.saveLoop()
	
	function self:setVal(dataType, dataVal)
		self.data[dataType] = dataVal
		Resources:GetRemote("LData"):FireClient(playerProfile.obj, dataType, self.data[dataType])
	end
	
	function self:incrVal(dataType, dataVal)
		self.data[dataType] += dataVal
		Resources:GetRemote("LData"):FireClient(playerProfile.obj, dataType, self.data[dataType])
	end
	
	tTimeStore:BeforeSave(function(beforeSaveData)
		local dataVal = beforeSaveData
		
		dataVal += (tick() - playerProfile.lData.lastSaved)
		dataVal = roundDown(dataVal)
		
		return dataVal
	end)
	
	return self
end

Resources:GetRemote("LDataRetrieve").OnServerInvoke = function(player, dataType)
	local playerProfile = module._playerProfiles:getProfile(player)
	if not playerProfile.ldata then return end
	
	return playerProfile.ldata[dataType]
end

return module
