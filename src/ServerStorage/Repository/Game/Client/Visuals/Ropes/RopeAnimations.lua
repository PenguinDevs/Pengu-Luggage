local module = {}

local Resources = require(game.ReplicatedStorage.Resources)
local GameLoop = Resources:LoadLibrary("GameLoop")
local Camera = workspace.CurrentCamera
local Tween = Resources:LoadLibrary("Tween")
local Enumeration = Resources:LoadLibrary("Enumeration")

local Linear = Enumeration.EasingFunction.Linear.Value

local function perform(folder)
	if (folder.Rope.Position - Camera.CFrame.p).magnitude > 600 then return end
	local distance = (folder.P1.Position - folder.P2.Position).magnitude
	folder.Rope.Size = Vector3.new(folder.Rope.Size.X, folder.Rope.Size.Y, distance)
	folder.Rope.CFrame = CFrame.new(folder.P1.Position - Vector3.new(0, folder.Rope.Size.Y/2, 0), folder.P2.Position - Vector3.new(0, folder.Rope.Size.Y/2, 0)) * CFrame.new(0, 0, -distance / 2)
end

for _, plot in pairs(workspace.Game.PlayerPlots:GetChildren()) do
	for _, folder in pairs(plot.Visuals.Ropes:GetChildren()) do
		spawn(function()
			while true do
				local tween = Tween.new(5, Linear, function()
					perform(folder)
				end)
				while true do wait() if not tween.Running then break end end
			end
		end)
	end
end

-- module.update = GameLoop.new(function()
-- 	local done = false
-- 	-- for _, folder in pairs(workspace.Visuals.Ropes:GetChildren()) do
-- 	-- 	perform(folder)
-- 	-- end
	

-- 	if not done then
-- 		wait(3)
-- 	end
-- end, 0) --, "RopeVisual")

return module
