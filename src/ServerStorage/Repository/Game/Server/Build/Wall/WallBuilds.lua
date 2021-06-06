local module = {}

local Resources = require(game.ReplicatedStorage.Resources)
local DataStore2 = Resources:LoadLibrary("DataStore2")
local DefaultDS = Resources:LoadLibrary("DefaultDS")
local VectorTable = Resources:LoadLibrary("VectorTable")
--local Tween = Resources:LoadLibrary("Tween")
--local Enumeration = Resources:LoadLibrary("Enumeration")
--local TweenModel = Resources:LoadLibrary("TweenModel")
local ServerTween = Resources:LoadLibrary("STweenS")
local WallInteractions = Resources:LoadLibrary("WallInteractions")
local DEBUG = false

--local OutCubic = Enumeration.EasingFunction.OutCubic.Value

function colourModel(model, c3)
	for _, obj in pairs(model:GetDescendants()) do
		if obj:IsA("BasePart") and obj.Name == "Col1" then
			obj.Color = c3
		end
	end
end

function module:updateHWalls(playerProfile, group, ignoreAnim)
	local build1Store = DataStore2("build1", playerProfile.obj)
	local build1Cache = build1Store:Get(DefaultDS.build1)
	local plot = playerProfile.landPlots.obj.Plot
	for _, wallObj in pairs(group:GetChildren()) do
		if not build1Cache.walls.h[wallObj.Name] then
			wallObj.Parent = workspace
			for _, obj in pairs(wallObj:GetDescendants()) do
				if obj:IsA("BasePart") or obj:IsA("Texture") or obj:IsA("Decal") then
					--Tween(obj, "Transparency", 1, OutCubic, 1, true):Wait()
					ServerTween:tweenClient(playerProfile.obj, false, obj, "Transparency", 1, "OutCubic", 1, true)
				end
			end
			spawn(function()
				wait(1)
				wallObj:Destroy()
			end)
		end
	end
	for wallPos, wallDet in pairs(build1Cache.walls.h) do
		if not group:FindFirstChild(wallPos) then
			local wallObj = Resources:GetBuildItem("Wall")[wallDet.wall]:Clone()
			wallObj.Name = wallPos
			wallObj.Parent = group
			colourModel(wallObj, Color3.fromRGB(table.unpack(wallDet.colour)))
			if DEBUG then
				local gui = Resources:GetDebugItem("BillboardGui"):Clone()
				gui.Parent = wallObj.PrimaryPart
				gui.TextLabel.Text = "H" .. wallPos
			end

			local origin = Vector3.new(8, 8, 32)
			--Instance.new("Part", workspace).Position = plot["0:0"].Mid.CFrame * origin
			local v2 = VectorTable.rconvert(wallPos)
			local v3 = -Vector3.new(v2.X * 16, 0, v2.Y * 16) + origin
			local targetCF = CFrame.new(plot["0:0"].Mid.CFrame * v3) * CFrame.Angles(0, math.rad(wallDet.rot * 180 - 90), 0)
			if not wallObj.PrimaryPart then warn("CANNOT FIND .PRIMARYPART FOR", wallDet.wall) return end
			if ignoreAnim then
				wallObj:SetPrimaryPartCFrame(targetCF)
				WallInteractions:process(wallObj, playerProfile)
			else
				wallObj:SetPrimaryPartCFrame(targetCF * CFrame.new(0, 10, 0))
				for _, obj in pairs(wallObj:GetDescendants()) do
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
				ServerTween:tweenClient(playerProfile.obj, false, wallObj, "modelCF", targetCF, 1, Enum.EasingStyle.Cubic, Enum.EasingDirection.Out)
				spawn(function()
					wait(1)
					wallObj:SetPrimaryPartCFrame(targetCF)
					WallInteractions:process(wallObj, playerProfile)
				end)
			end
		end
	end
end

function module:updateVWalls(playerProfile, group, ignoreAnim)
	local build1Store = DataStore2("build1", playerProfile.obj)
	local build1Cache = build1Store:Get(DefaultDS.build1)
	local plot = playerProfile.landPlots.obj.Plot
	for _, wallObj in pairs(group:GetChildren()) do
		if not build1Cache.walls.v[wallObj.Name] then
			wallObj.Parent = workspace
			for _, obj in pairs(wallObj:GetDescendants()) do
				if obj:IsA("BasePart") or obj:IsA("Texture") or obj:IsA("Decal") then
					--Tween(obj, "Transparency", 1, OutCubic, 1, true):Wait()
					ServerTween:tweenClient(playerProfile.obj, false, obj, "Transparency", 1, "OutCubic", 1, true)
				end
			end
			spawn(function()
				wait(1)
				wallObj:Destroy()
			end)
		end
	end
	for wallPos, wallDet in pairs(build1Cache.walls.v) do
		if not group:FindFirstChild(wallPos) then
			local wallObj = Resources:GetBuildItem("Wall")[wallDet.wall]:Clone()
			wallObj.Name = wallPos
			wallObj.Parent = group
			colourModel(wallObj, Color3.fromRGB(table.unpack(wallDet.colour)))
			if DEBUG then
				local gui = Resources:GetDebugItem("BillboardGui"):Clone()
				gui.Parent = wallObj.PrimaryPart
				gui.TextLabel.Text = "V" .. wallPos
			end

			local origin = Vector3.new(0, 8, 24)
			--Instance.new("Part", workspace).Position = plot["0:0"].Mid.CFrame * origin
			local v2 = VectorTable.rconvert(wallPos)
			local v3 = -Vector3.new(v2.X * 16, 0, v2.Y * 16) + origin
			local targetCF = CFrame.new(plot["0:0"].Mid.CFrame * v3) * CFrame.Angles(0, math.rad(wallDet.rot * 180), 0)
			if not wallObj.PrimaryPart then warn("CANNOT FIND .PRIMARYPART FOR", wallDet.wall) return end
			if ignoreAnim then
				wallObj:SetPrimaryPartCFrame(targetCF)
			else
				wallObj:SetPrimaryPartCFrame(targetCF * CFrame.new(0, 10, 0))
				for _, obj in pairs(wallObj:GetDescendants()) do
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
				ServerTween:tweenClient(playerProfile.obj, false, wallObj, "modelCF", targetCF, 1, Enum.EasingStyle.Cubic, Enum.EasingDirection.Out)
			end
			spawn(function()
				wait(1)
				if wallObj.PrimaryPart then
					wallObj:SetPrimaryPartCFrame(targetCF)
					WallInteractions:process(wallObj, playerProfile)
				else
					warn("Cannot find .PrimaryPart for", wallObj, "in WallBuilds when placing")
				end
			end)
		end
	end
end

function module:playerProfileAssign(playerProfile)
	local hWallGroup = Instance.new("Folder", playerProfile.landPlots.obj)
	hWallGroup.Name = "HWalls"
	
	local vWallGroup = Instance.new("Folder", playerProfile.landPlots.obj)
	vWallGroup.Name = "VWalls"
	
	local buildProfile = {}
	buildProfile.player = playerProfile
	
	--local build1Store = DataStore2("build1", playerProfile.obj)
	function buildProfile:update(ignoreAnim)
		module:updateHWalls(playerProfile, hWallGroup, ignoreAnim)
		module:updateVWalls(playerProfile, vWallGroup, ignoreAnim)
		playerProfile.ceilingBuild:update(ignoreAnim)
	end
	function buildProfile:destroy()
		hWallGroup:Destroy()
		vWallGroup:Destroy()
	end
	playerProfile.leave:Connect(buildProfile.destroy)
	
	buildProfile:update(true)
	
	return buildProfile
end

return module
