-- Module for :GetMouse().Hit/Target, collision groups and range parameters are providable
-- @author PenguinDevs

local module = {}

local Camera = workspace.CurrentCamera
local UserInputService = game:GetService("UserInputService")
local GuiService = game:GetService("GuiService")

module.LocalPlayerParams = RaycastParams.new()
module.LocalPlayerParams.FilterType = Enum.RaycastFilterType.Blacklist
module.LocalPlayerParams.FilterDescendantsInstances = {game.Players.LocalPlayer.Character}
game.Players.LocalPlayer.CharacterAdded:Connect(function(char)
	module.LocalPlayerParams.FilterDescendantsInstances = {char}
end)

function module:getHitTarget(range, params)
	local screenLocation = UserInputService:GetMouseLocation() - GuiService:GetGuiInset()
	local unitRay1 = Camera:ScreenPointToRay(screenLocation.X, screenLocation.Y)
	local unitRay2 = Ray.new(unitRay1.Origin, unitRay1.Direction)
	local raycastResult = workspace:Raycast(unitRay2.Origin, unitRay2.Direction * (range or 5000), params or RaycastParams.new())
	if raycastResult then
		return raycastResult.Position, raycastResult.Instance
	end
end

function module:getHit(range, params)
	return table.pack(module:getHitTarget(range, params))[1]
end

function module:getTarget(range, params)
	return table.pack(module:getHitTarget(range, params))[2]
end

return module
