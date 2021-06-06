local basic = {}
basic.__index = basic

basic.uiName = "Stats"
--basic.obj = game.Players.LocalPlayer.PlayerGui:WaitForChild("FishFillMenu", math.huge).Frame
basic.obj = game.Players.LocalPlayer.PlayerGui.StatsMenu.Frame

local Resources = require(game.ReplicatedStorage.Resources)

basic.openCall = Resources:LoadLibrary("UserStatsUi").refresh

local pageConstructor = require(script.Parent.Parent.UiPageConstructor)

function basic.new(DEBUG)
	if DEBUG then print(basic.uiName) end
	basic = setmetatable(pageConstructor.new(basic), basic)
	
	return basic
end

return setmetatable({}, basic)
