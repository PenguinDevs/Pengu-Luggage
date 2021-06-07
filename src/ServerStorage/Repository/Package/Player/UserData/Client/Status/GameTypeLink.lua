local Resources = require(game.ReplicatedStorage.Resources)
local BindUiOpenClose = Resources:LoadLibrary("BindUiOpenClose")

local module = {
	["visiting"] = function(dataType, val)
		-- print(dataType, val)
		Resources:LoadLibrary("PlayersMenuUi").updateVisiting()
		Resources:LoadLibrary("DaltonControl").refreshDaltons()
		Resources:LoadLibrary("PathfindingMaps"):updateMap(val)
		Resources:LoadLibrary("FishAgent").RefreshAnimations:Fire()
	end;
	["p1build1"] = function()
		Resources:LoadLibrary("PathfindingMaps"):updateMap(1)
	end;
	["p2build1"] = function()
		Resources:LoadLibrary("PathfindingMaps"):updateMap(2)
	end;
	["p3build1"] = function()
		Resources:LoadLibrary("PathfindingMaps"):updateMap(3)
	end;
	["p4build1"] = function()
		Resources:LoadLibrary("PathfindingMaps"):updateMap(4)
	end;
	["p5build1"] = function()
		Resources:LoadLibrary("PathfindingMaps"):updateMap(5)
	end;
	["inGroup"] = function(dataType, val)
		if val == false then
			-- BindUiOpenClose.binds.FrostyDory.sigs.open:Fire()
		end
	end;
	["plotNo"] = function()
		Resources:LoadLibrary("DailyReward"):setup()
	end;
}

function module.__call(_, ...)
	local dataType, val = ...
	if module[dataType] then module[dataType](dataType, val) end
end

return setmetatable({}, module)
