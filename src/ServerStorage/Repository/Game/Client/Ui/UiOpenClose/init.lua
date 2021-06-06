local main = {}

main.player = game.Players.LocalPlayer

main.currentUi = nil

local DEBUG = false

main.paths = require(script.Paths)(DEBUG)

function main:closeCurrentUi(uiName)
	if main.currentUi ~= uiName and main.currentUi then
		main.paths[main.currentUi]:close(true, true)
	end
end

script.OC.Event:Connect(function(mode, uiName, DcloseOthers)
	if mode == "open" then
		if not DcloseOthers then main:closeCurrentUi(uiName) main.currentUi = uiName end
	elseif mode == "close" then
		if not DcloseOthers then main.currentUi = nil end
	end
end)

return main
