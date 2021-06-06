local basic = {}
basic.__index = basic

basic.uiName = "FrostyDory"
basic.obj = game.Players.LocalPlayer.PlayerGui.GroupFishNotif.Frame

local pageConstructor = require(script.Parent.Parent.UiPageConstructor)

function basic.new(DEBUG)
	if DEBUG then print(basic.uiName) end
	basic = setmetatable(pageConstructor.new(basic), basic)
	
	return basic
end

return setmetatable({}, basic)
