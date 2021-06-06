local Resources = require(game.ReplicatedStorage.Resources)
local PlayerProfiles = Resources:LoadLibrary("PlayerProfiles")
local DataStore2 = Resources:LoadLibrary("DataStore2")
local DefaultDS = Resources:LoadLibrary("DefaultDS")
local VectorTable = Resources:LoadLibrary("VectorTable")

local module = {}

Resources:GetRemote("BuyPlot").OnServerEvent:Connect(function(player, plot)
	local playerProfile = PlayerProfiles:getProfile(player)
	local moneyStore = DataStore2("money", player)
	local moneyCache = moneyStore:Get(DefaultDS.money)
	local build1Store = DataStore2("build1", player)
	local build1Cache = build1Store:Get(DefaultDS.build1)
	
	local plotsOwnedNo = 0
	for _, _ in pairs(build1Cache.plots) do plotsOwnedNo += 1 end
	local plotPrice = Resources:LoadLibrary("PlotPrice"):getPriceFromPlotNo(plotsOwnedNo)
	if moneyCache < plotPrice then return end
	build1Cache.plots[plot.Name] = true
	
	playerProfile.data:incrVal("money", -plotPrice)
	playerProfile.data:setVal("build1", build1Cache)
	playerProfile.landPlots:updatePlots()
end)

Resources:GetRemote("RobuxLand").OnServerEvent:Connect(function(player, plot)
	local playerProfile = PlayerProfiles:getProfile(player)

	playerProfile.wantedPlot = plot.Name
end)

return module
