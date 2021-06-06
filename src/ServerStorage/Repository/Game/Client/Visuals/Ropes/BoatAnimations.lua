local module = {}

local Resources = require(game.ReplicatedStorage.Resources)
local GameLoop = Resources:LoadLibrary("GameLoop")
local RoundDown = Resources:LoadLibrary("RoundDown")
local Enumeration = Resources:LoadLibrary("Enumeration")
local EasingFunctions = Resources:LoadLibrary("EasingFunctions")
local EasingFunctionEnumerationItems = Enumeration.EasingFunction:GetEnumerationItems()
local Camera = workspace.CurrentCamera
local Tween = Resources:LoadLibrary("Tween")
local Enumeration = Resources:LoadLibrary("Enumeration")

local Linear = Enumeration.EasingFunction.Linear.Value

local InQuad = EasingFunctions[Enumeration.EasingFunction.InQuad.Value]
local OutQuad = EasingFunctions[Enumeration.EasingFunction.OutQuad.Value]
local InOutSine = EasingFunctions[Enumeration.EasingFunction.InOutSine.Value]

local BoatsCF = {}
for _, plot in pairs(workspace.Game.PlayerPlots:GetChildren()) do
	for _, boat in pairs(plot.Visuals.Boats:GetChildren()) do
		BoatsCF[boat] = boat.PrimaryPart.CFrame
	end
end

--for _, boat in pairs(workspace.Visuals.Boats:GetChildren()) do
--	local partsOffsets = {}
--	local partsRotXY = {}
--	for _, tempPart in pairs(boat:GetChildren()) do
--		partsOffsets[tempPart] = boat.Move.Position - tempPart.Position
--		partsRotXY[tempPart] = Vector3.new(tempPart.Orientation.X, 0, tempPart.Orientation.Z)
--	end
--end

local function perform(boat)
	if (boat.PrimaryPart.Position - Camera.CFrame.p).magnitude > 600 then return end
	--if true then break end
	local currentTick = tick() -- + tickDifferntiator
	local div2 = currentTick/8
	local amount = currentTick - RoundDown(div2) * 8

	local degToSet = 0

	if amount >= 7.95 then
		--if doFix ~= true then
		--	allowMovement = false
		--	for part, offset in pairs(partsOffsets) do
		--		part.Position = boat.Move.Position - offset
		--	end
		--	for part, rot in pairs(partsRotXY) do
		--		part.Orientation = rot + Vector3.new(0, part.Orientation.Y, 0)
		--	end
		--	boat.Move.Orientation = Vector3.new(0, boat.Move.Orientation.Y, 0)
		--	allowMovement = true
		--end
	elseif amount >= 6 then
		local toTimes = InQuad(amount - 6, -1, 1, 2)
		degToSet = toTimes * 3
	elseif amount >= 4 then
		local toTimes = OutQuad(amount - 4, 0, -1, 2)
		degToSet = toTimes * 3
	elseif amount >= 2 then
		local toTimes = InQuad(amount - 2, 1, -1, 2)
		degToSet = toTimes * 3
	else
		local toTimes = OutQuad(amount, 0, 1, 2)
		degToSet = toTimes * 3
	end

	local Rocking1 = CFrame.Angles(0, 0, math.rad(degToSet))

	local heightToSet = 0

	if amount >= 4 then
		local toTimes = InOutSine(amount - 4, 1, -1, 4)
		heightToSet = toTimes * 1.3
	else
		local toTimes = InOutSine(amount, 0, 1, 4)
		heightToSet = toTimes * 1.3
	end

	local Rocking2 = CFrame.new(0, heightToSet, 0)
	
	boat:SetPrimaryPartCFrame(BoatsCF[boat] * Rocking1 * Rocking2)
end

for _, plot in pairs(workspace.Game.PlayerPlots:GetChildren()) do
	for _, boat in pairs(plot.Visuals.Boats:GetChildren()) do
		spawn(function()
			while true do
				local tween = Tween.new(5, Linear, function()
					perform(boat)
				end)
				while true do wait() if not tween.Running then break end end
			end
		end)
	end
end

-- module.update = GameLoop.new(function()
-- 	local done = false

-- 	-- for _, boat in pairs(workspace.Visuals.Boats:GetChildren()) do
-- 	-- 	perform(boat)
-- 	-- end
	

-- 	if not done then
-- 		wait(3)
-- 	end
-- end, 0) --, "BoatRockingVisual")

return module
