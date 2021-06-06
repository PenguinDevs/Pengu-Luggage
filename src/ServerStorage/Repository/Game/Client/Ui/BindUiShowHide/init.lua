local module = {}

local Resources = require(game.ReplicatedStorage.Resources)
local Binds = require(script.Binds)
local UiShowHide = Resources:LoadLibrary("UiShowHide")

for _, bind in pairs(Binds) do
	bind.event:Connect(function()
		if bind.check then if not bind.check() then return end end
		for _, action in pairs(bind.actions) do
			if type(action) == "table" then
				UiShowHide:tweenMenu(action.ui, action.action)
			elseif type(action) == "function" then
				action()
			end
			--print("ah", action.ui, action.action)
		end
	end)
end

return module
