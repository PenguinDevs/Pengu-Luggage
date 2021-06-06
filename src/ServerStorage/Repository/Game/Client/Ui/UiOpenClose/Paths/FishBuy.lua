local basic = {}
basic.__index = basic

basic.uiName = "FishBuy"
--basic.obj = game.Players.LocalPlayer.PlayerGui:WaitForChild("FishMenu", math.huge).Frame
basic.obj = game.Players.LocalPlayer.PlayerGui.FishMenu.Frame

basic.openCall = nil
basic.closeCall = nil

local pageConstructor = require(script.Parent.Parent.UiPageConstructor)

function basic.new(DEBUG)
	if DEBUG then print(basic.uiName) end
	basic = setmetatable(pageConstructor.new(basic), basic)
	
	return basic
end

return setmetatable({}, basic)
