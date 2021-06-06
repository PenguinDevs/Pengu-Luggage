local module = {}

local Resources = require(game.ReplicatedStorage.Resources)
local PlayerInitPriority = Resources:LoadLibrary("PlayerInitPriority")
local GameLoop = Resources:LoadLibrary("GameLoop")
local Signal = Resources:LoadLibrary("Signal")

module.profiles = {}

function module:createProfile(player)
	local profile = {}
	module.profiles[player] = profile
	profile.obj = player
	profile.id = player.UserId
	profile.name = player.Name
	profile.leave = Signal.new()
	player.AncestryChanged:Connect(function()
		if player:IsDescendantOf(game) then return end
		profile.leave:Fire()
	end)
	profile.leave:Connect(function()
		module.profiles[player] = nil
		wait(3)
		profile.leave:Destroy()
		
		profile = nil
	end)
	local function loadPriorities()
		table.sort(PlayerInitPriority,
			function(a, b)
				return a.priority < b.priority
			end
		)
		
		for _, loadUnit in pairs(PlayerInitPriority) do
			if loadUnit.module.playerProfileAssign then
				profile[loadUnit.name] = loadUnit.module:playerProfileAssign(profile)
			end
			--if loadUnit.module.update then GameLoop:handle(loadUnit.module.update, player) end
		end
	end
	spawn(loadPriorities)
end

function module:getProfile(player)
	return module.profiles[player]
end

game.Players.PlayerAdded:Connect(function(player)
	module:createProfile(player)
end)

game.Players.PlayerRemoving:Connect(function(player)
	module.profiles[player] = nil
end)

return module
