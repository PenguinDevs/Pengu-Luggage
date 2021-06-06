local module = {}

local Resources = require(game.ReplicatedStorage.Resources)

function module.__call(_, ...)
	local playerProfile, valName, valAmount = ...
	
	local list = {
		--["build1"] = playerProfile.landPlots.updatePlots;
		["fishHold"] = function()
			playerProfile.fishObjects:update()
			playerProfile.satisBoard:update()
			playerProfile.tasks:update()
		end;
		["build1"] = function(valName, valAmount)
			if playerProfile.daltons then
				playerProfile.daltons:update()
			end
			if playerProfile.satisBoard then
				playerProfile.satisBoard:update()
			end
			if playerProfile.landPlots then
				Resources:GetRemote("Game"):FireAllClients(string.format("p%sbuild1", playerProfile.landPlots.plotI), valAmount)
			end
			if playerProfile.tasks then
				playerProfile.tasks:update()
			end
			-- if playerProfile.fishObjects then
			-- 	playerProfile.fishObjects:update()
			-- end
			-- Resources:GetRemote("Game"):FireClient(playerProfile.obj, "placedDeb", false)
		end;
	}
	
	if list[valName] then list[valName](valName, valAmount) end
end

return setmetatable({}, module)
