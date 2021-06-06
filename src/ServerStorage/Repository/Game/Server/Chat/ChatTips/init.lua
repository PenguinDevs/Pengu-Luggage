local module = {}

module.list = require(script.TipsList)

module.lastTipNo = 0

local Resources = require(game.ReplicatedStorage.Resources)
local GameLoop = Resources:LoadLibrary("GameLoop")

function module:callTip()
	module.lastTipNo += 1
	if module.lastTipNo > #module.list then
		module.lastTipNo = 1
	end
	local tip = module.list[module.lastTipNo]
	Resources:GetRemote("Message"):FireAllClients(tip, Color3.fromRGB(255, 153, 85))
end

module.update = GameLoop.new(function()
    module:callTip()
end, 120)

return module
