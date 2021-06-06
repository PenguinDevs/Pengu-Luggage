local module = {}

local Resources = require(game.ReplicatedStorage.Resources)
local PlayerProfiles = Resources:LoadLibrary("PlayerProfiles")
local DataStore2 = Resources:LoadLibrary("DataStore2")
local DefaultDS = Resources:LoadLibrary("DefaultDS")

game.Players.PlayerAdded:Connect(function(player)
    for _, tempProfile in pairs(PlayerProfiles.profiles) do
		if tempProfile.landPlots then
			if tempProfile.landPlots.plotNo then
				local build1Store = DataStore2("build1", tempProfile.obj)
				Resources:GetRemote("Game"):FireClient(player, string.format("p%sbuild1", tempProfile.landPlots.plotNo), build1Store:Get(DefaultDS.build1))
			end
		end
	end
end)

return module