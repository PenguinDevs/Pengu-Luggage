local goto = {}

local Player = game.Players.LocalPlayer
local Resources = require(game.ReplicatedStorage.Resources)

local runService = game:GetService("RunService")

return setmetatable(goto, {
	__call = function(_, ...)
		local pos = ...
		
		local arrowsModel = Resources:GetParticle("GoToArrows"):Clone()
		arrowsModel.Parent = workspace
		local arrows
		arrows = runService.RenderStepped:Connect(function()
			if not arrows then arrows:Disconnect() return end
			if not arrowsModel:IsDescendantOf(game) then arrows:Disconnect() return end
			if not arrowsModel:FindFirstChild("Part1") or not arrowsModel:FindFirstChild("Part2") then arrows:Disconnect() return end
			if not Player.Character:FindFirstChild("HumanoidRootPart") then return end
			arrowsModel.Part1.CFrame = CFrame.new(Player.Character.HumanoidRootPart.Position, pos)
			arrowsModel.Part2.CFrame = CFrame.new(pos, Player.Character.HumanoidRootPart.Position) * CFrame.fromEulerAnglesXYZ(0, math.rad(180), 0)
		end)
	--	local plrWeld = Instance.new("Weld", arrowsModel)
	--	plrWeld.Part0 = goto.player.Character.HumanoidRootPart
	--	plrWeld.Part1 = arrowsModel.Part1
		return arrowsModel
	end
})
