local basic = {}
basic.__index = basic

basic.uiName = "Codes"
basic.obj = game.Players.LocalPlayer.PlayerGui.CodesMenu.Frame

basic.openCall = nil
basic.closeCall = nil

local pageConstructor = require(script.Parent.Parent.UiPageConstructor)

function basic.new(DEBUG)
	if DEBUG then print(basic.uiName) end
	basic = setmetatable(pageConstructor.new(basic), basic)
	
	return basic
end

return setmetatable({}, basic)
