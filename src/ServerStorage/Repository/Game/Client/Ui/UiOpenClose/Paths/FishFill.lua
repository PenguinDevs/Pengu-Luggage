local basic = {}
basic.__index = basic

basic.uiName = "FishFill"
basic.obj = game.Players.LocalPlayer.PlayerGui.FishFillMenu.Frame

local Resources = require(game.ReplicatedStorage.Resources)

basic.openPos = UDim2.new(0.02, 0, 0.5, 0)
basic.closePos = UDim2.new(0.02, 0, -0.6, 0)

basic.openCall = Resources:LoadLibrary("FishFill").on
basic.closeCall = Resources:LoadLibrary("FishFill").off

local pageConstructor = require(script.Parent.Parent.UiPageConstructor)

function basic.new(DEBUG)
	if DEBUG then print(basic.uiName) end
	basic = setmetatable(pageConstructor.new(basic), basic)
	
	return basic
end

return setmetatable({}, basic)
