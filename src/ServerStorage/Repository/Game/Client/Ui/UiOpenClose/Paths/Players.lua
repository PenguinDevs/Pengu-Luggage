local basic = {}
basic.__index = basic

basic.uiName = "Players"
--basic.obj = game.Players.LocalPlayer.PlayerGui:WaitForChild("PlayersMenu", math.huge).Frame
basic.obj = game.Players.LocalPlayer.PlayerGui.PlayersMenu.Frame

basic.openCall = require(game.ReplicatedStorage.Resources):LoadLibrary("PlayersMenuUi").refreshPage;
basic.closeCall = nil

local pageConstructor = require(script.Parent.Parent.UiPageConstructor)

function basic.new(DEBUG)
	if DEBUG then print(basic.uiName) end
	basic = setmetatable(pageConstructor.new(basic), basic)
	
	return basic
end

return setmetatable({}, basic)
