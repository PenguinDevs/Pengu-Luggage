local module = {}

local Resources = require(game.ReplicatedStorage.Resources)
local DataStore2 = Resources:LoadLibrary("DataStore2")
local DefaultDS = Resources:LoadLibrary("DefaultDS")
local VectorTable = Resources:LoadLibrary("VectorTable")
--local Tween = Resources:LoadLibrary("Tween")
--local Enumeration = Resources:LoadLibrary("Enumeration")
--local TweenModel = Resources:LoadLibrary("TweenModel")
local ServerTween = Resources:LoadLibrary("STweenS")
local FloorStats = Resources:LoadLibrary("FloorStats")
local TankDecors = Resources:LoadLibrary("TankDecors")
local TankProfitLabel = Resources:LoadLibrary("TankProfitLabel")
local DEBUG = false

--local OutCubic = Enumeration.EasingFunction.OutCubic.Value

function colourModel(model, c3)
	for _, obj in pairs(model:GetDescendants()) do
		if obj:IsA("BasePart") and obj.Name == "Col1" then
			obj.Color = c3
		end
	end
end

function module:updateFloors(playerProfile, group, ignoreAnim)
	local build1Store = DataStore2("build1", playerProfile.obj)
	local build1Cache = build1Store:Get(DefaultDS.build1)
	local plot = playerProfile.landPlots.obj.Plot
	for _, floorObj in pairs(group:GetChildren()) do
		if not build1Cache.floors[floorObj.Name] then
			floorObj.Parent = workspace
			for _, obj in pairs(floorObj:GetDescendants()) do
				if obj:IsA("BasePart") or obj:IsA("Texture") or obj:IsA("Decal") then
					--Tween(obj, "Transparency", 1, OutCubic, 1, true):Wait()
					ServerTween:tweenClient(playerProfile.obj, false, obj, "Transparency", 1, "OutCubic", 1, true)
				end
			end
			spawn(function()
				wait(1)
				floorObj:Destroy()
			end)
		end
	end
	for floorPos, floorDet in pairs(build1Cache.floors) do
		local floorObj = group:FindFirstChild(floorPos)
		if not floorObj then
			floorObj = Resources:GetBuildItem("Floor")[floorDet.floor]:Clone()
			floorObj.Name = floorPos
			floorObj.Parent = group
			colourModel(floorObj, Color3.fromRGB(table.unpack(floorDet.colour)))
			if DEBUG then
				local gui = Resources:GetDebugItem("BillboardGui"):Clone()
				gui.Parent = floorObj.PrimaryPart
				gui.TextLabel.Text = "F" .. floorPos
			end

			local floorStat = FloorStats[floorDet.floor]
			if floorObj:FindFirstChild("SandBase") then TankDecors:decorTank(floorStat, floorObj) end
			if floorStat.fishHold then TankProfitLabel:getLabel(playerProfile, floorObj) end

			if floorStat.fishHold then
				local fishObjsFolder = floorObj:FindFirstChild("FishObjs")
				if not fishObjsFolder then
					fishObjsFolder = Instance.new("Folder", floorObj)
					fishObjsFolder.Name = "FishObjs"
				end
			end

			local origin = Vector3.new(8, 0, 24)
			--Instance.new("Part", workspace).Position = plot["0:0"].Mid.CFrame * origin
			local v2 = VectorTable.rconvert(floorPos)
			local v3 = -Vector3.new(v2.X * 16, 0, v2.Y * 16) + origin + Vector3.new(0, -0.2, 0)
			local targetCF = CFrame.new(plot["0:0"].Mid.CFrame * v3)
			if ignoreAnim then
				floorObj:SetPrimaryPartCFrame(targetCF)
			else
				floorObj:SetPrimaryPartCFrame(targetCF * CFrame.new(0, 10, 0))
				for _, obj in pairs(floorObj:GetDescendants()) do
					if obj:IsA("BasePart") or obj:IsA("Texture") or obj:IsA("Decal") then
						local orig = obj.Transparency
						obj.Transparency = 1
						spawn(function()
							wait(1)
							obj.Transparency = orig
						end)
						--Tween(obj, "Transparency", orig, OutCubic, 1, true)
						ServerTween:tweenClient(playerProfile.obj, false, obj, "Transparency", orig, "OutCubic", 1, true)
					end
				end
				--TweenModel:tweenModel(floorObj, targetCF, TweenInfo.new(1, Enum.EasingStyle.Cubic, Enum.EasingDirection.Out)):Play()
				ServerTween:tweenClient(playerProfile.obj, false, floorObj, "modelCF", targetCF, 1, Enum.EasingStyle.Cubic, Enum.EasingDirection.Out)
				spawn(function()
					wait(1)
					floorObj:SetPrimaryPartCFrame(targetCF)
				end)
			end
		end
		if not floorObj then continue end
		local floorStat = FloorStats[floorDet.floor]
		if floorStat.careWalls then
			local function isNeighbourCommon(iPos)
				local tempFloorDet = build1Cache.floors[iPos]
				if tempFloorDet then
					if tempFloorDet.floor == floorDet.floor then
						return true
					end
				end
			end
			local pos = VectorTable.rconvert(floorPos)
			local function procWall(dir)
				local iPos = VectorTable.convert(pos + dir)
				if isNeighbourCommon(iPos) then
					floorObj.Walls[VectorTable.convert(dir)]:SetPrimaryPartCFrame(floorObj.PrimaryPart.CFrame * CFrame.new(0, -100, 0))
				else
					floorObj.Walls[VectorTable.convert(dir)]:SetPrimaryPartCFrame(floorObj.PrimaryPart.CFrame)
				end
			end
			procWall(Vector2.new(0, 1))
			procWall(Vector2.new(0, -1))
			procWall(Vector2.new(1, 0))
			procWall(Vector2.new(-1, 0))
		end
	end
end

function module:playerProfileAssign(playerProfile)
	local floorGroup = Instance.new("Folder", playerProfile.landPlots.obj)
	floorGroup.Name = "Floors"
	
	local buildProfile = {}
	buildProfile.player = playerProfile
	
	--local build1Store = DataStore2("build1", playerProfile.obj)
	function buildProfile:update(ignoreAnim)
		module:updateFloors(playerProfile, floorGroup, ignoreAnim)
	end
	function buildProfile:destroy()
		floorGroup:Destroy()
	end
	playerProfile.leave:Connect(buildProfile.destroy)
	
	buildProfile:update(true)
	
	return buildProfile
end

return module
