local module = {}

local Resources = require(game.ReplicatedStorage.Resources)
local Signal = Resources:LoadLibrary("Signal")
local DefaultDS = Resources:LoadLibrary("DefaultDS")

local CollectedSnow = {}

local FetchDataRemote = Resources:GetRemote("DataRetrieve")
local SetDataRemote = Resources:GetRemote("Data")
local SetGameRemote = Resources:GetRemote("Game")

local GamepassStats = Resources:LoadLibrary("GamepassStats")

local Player = game.Players.LocalPlayer

module.joinedTime = os.time()

local UniversalGamepasses = Resources:LoadLibrary("UniversalGamepass")

local MarketplaceService = game:GetService("MarketplaceService")

local LData = {}

local DataTypes = {}
for i, v in pairs(DefaultDS) do table.insert(DataTypes, 1, i) end
local DataFetchTimeout = 30
module.data = {}
module.passes = {}
module.game = {}

script.GetPasses.OnInvoke = function()
	local collected = {}
	for i, v in pairs(module.passes) do collected[i] = v end
	return collected
end

function module:fetchData()
	local signalsCollected = {}
	local tempCollected = {}
	local ready = Signal.new()
	
	local function fetchType(type)
		--print(type)
		signalsCollected[type] = Signal.new()
		--spawn(function()
		ready:Connect(function()
			tempCollected[type] = FetchDataRemote:InvokeServer(type)
			if tempCollected[type] == nil then warn("data fetch", type, "== nil") end
			signalsCollected[type]:Fire()
			--print("fired")
		end)
	end
	--print(1)
	for _, dataType in pairs(DataTypes) do fetchType(dataType) end
	--print(2)
	local yielder = true
	local function yieldType(type)
		signalsCollected[type]:Connect(function()
			local amount = 0
			for i, tempDataType in pairs(DataTypes) do
				if tempCollected[tempDataType] == nil then return end
				amount = i
			end
			--print("a")
			--print(((#DataTypes < 5) and 5 or 0), #DataTypes, (#DataTypes < 5))
			if amount < ((#DataTypes > 5) and 5 or 0) then return end
			--print("b")
			yielder = false
		end)
	end
	for _, dataType in pairs(DataTypes) do yieldType(dataType) end
	ready:Fire()
	---print(3)
	spawn(function()
		local function timeOut()
			wait(DataFetchTimeout)
			for _, tempDataType in pairs(DataTypes) do
				if tempCollected[tempDataType] == nil then warn("data fetch timeout of", DataFetchTimeout, "seconds, trying again") module:fetchData() spawn(timeOut) end
			end
		end
		timeOut()
	end)
	while wait() do if not yielder then break end end
	--print(4)
	module.data = tempCollected
	for i, signal in pairs(signalsCollected) do signal:Destroy() signalsCollected[i] = nil end
end

function module:fetchGamepasses()
	local signalsCollected = {}
	local tempCollected = {}
	
	local function fetchPass(pass)
		if not signalsCollected[pass.name] then
			signalsCollected[pass.name] = Signal.new()
		end
		spawn(function()
			spawn(function()
				wait(30)
				if tempCollected[pass.name] == nil then warn("refetching", pass.name, "from marketplace due to 30 seconds timeout") end
			end)
			local success = pcall(function()
				local gamepassOverrideList = UniversalGamepasses[Player.UserId]
				local gamepassOverride
				if gamepassOverrideList then gamepassOverride = gamepassOverrideList[pass.name] end
				if gamepassOverride ~= nil then
					tempCollected[pass.name] = gamepassOverride
				else
					tempCollected[pass.name] = MarketplaceService:UserOwnsGamePassAsync(Player.UserId, pass.id)
				end
			end)
			if not success then warn("refetching", pass.name, "from marketplace") fetchPass(pass) end
			signalsCollected[pass.name]:Fire()
		end)
	end
	
	for _, pass in pairs(GamepassStats) do
		fetchPass(pass)
	end
	
	local yielder = true
	for _, pass in pairs(GamepassStats) do
		signalsCollected[pass.name]:Connect(function()
			for _, tempPass in pairs(GamepassStats) do
				if tempCollected[tempPass.name] == nil then return end
			end
			yielder = false
		end)
	end
	
	while wait() do if not yielder then break end end
	module.passes = tempCollected
	for i, signal in pairs(signalsCollected) do signal:Destroy() signalsCollected[i] = nil end
end

--print(1)
if not game.ReplicatedStorage.DataReady.Value then game.ReplicatedStorage.DataReady.Changed:Wait() end
local dataFetched = false
local passesFetched = false
spawn(function() module:fetchData() dataFetched = true print("data fetched") end)
spawn(function() module:fetchGamepasses() passesFetched = true print("gamepasses fetched") end)
--print(2)
while wait() do if dataFetched and passesFetched then break end end
--print(3)
print("fetch complete", module.data, module.passes)
for dataType, val in pairs(module.data) do spawn(function() require(script.DataTypeLink)(dataType, val) end) end

SetDataRemote.OnClientEvent:Connect(function(dataType, val)
	local diff = 0
	if typeof(module.data[dataType]) == "number" then
		diff = val - module.data[dataType]
	end
 	module.data[dataType] = val
	require(script.DataTypeLink)(dataType, val, diff)
end)

SetGameRemote.OnClientEvent:Connect(function(dataType, val)
	module.game[dataType] = val
	spawn(function() require(script.GameTypeLink)(dataType, val) end)
end)

Resources:GetRemote("LData").OnClientEvent:Connect(function(dataType, val)
	if not dataType and val then return end
	LData[dataType] = val
end)

return module
