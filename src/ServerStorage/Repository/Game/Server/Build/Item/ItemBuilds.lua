local module = {}

local Resources = require(game.ReplicatedStorage.Resources)
local DataStore2 = Resources:LoadLibrary("DataStore2")
local DefaultDS = Resources:LoadLibrary("DefaultDS")
local VectorTable = Resources:LoadLibrary("VectorTable")
--local Tween = Resources:LoadLibrary("Tween")
--local Enumeration = Resources:LoadLibrary("Enumeration")
--local TweenModel = Resources:LoadLibrary("TweenModel")
local ServerTween = Resources:LoadLibrary("STweenS")
local ItemStats = Resources:LoadLibrary("ItemStats")
local ItemInteractions = Resources:LoadLibrary("ItemInteractions")
local TankDecors = Resources:LoadLibrary("TankDecors")
local TankProfitLabel = Resources:LoadLibrary("TankProfitLabel")

--local OutCubic = Enumeration.EasingFunction.OutCubic.Value

function colourModel(model, c3)
	for _, obj in pairs(model:GetDescendants()) do
		if obj:IsA("BasePart") and obj.Name == "Col1" then
			obj.Color = c3
		end
	end
end

function getOffsetFromRotation(size, rotation)
	local x = size.X
	local y = size.Y
	if rotation == 1 then
		x *= -1
		x += 4
		y -= 4
	elseif rotation == 2 then
		local tempX = x
		local tempY = y
		x = -tempY + 4
		y = -tempX + 4
	elseif rotation == 3 then
		y *= -1
		y += 4
		x -= 4
	elseif rotation == 4 then
		local tempX = x
		local tempY = y
		x = tempY - 4
		y = tempX - 4
	end
	return Vector3.new(x, 0, y)/2 --+ Vector3.new(2, 0, -2)
end

function module:updateItems(playerProfile, group, ignoreAnim)
	local build1Store = DataStore2("build1", playerProfile.obj)
	local build1Cache = build1Store:Get(DefaultDS.build1)
	local plot = playerProfile.landPlots.obj.Plot
	for _, itemObj in pairs(group:GetChildren()) do
		if not build1Cache.items[itemObj.Name] then
			itemObj.Parent = workspace
			for _, obj in pairs(itemObj:GetDescendants()) do
				if obj:IsA("BasePart") or obj:IsA("Texture") or obj:IsA("Decal") then
					--Tween(obj, "Transparency", 1, OutCubic, 1, true):Wait()
					ServerTween:tweenClient(playerProfile.obj, false, obj, "Transparency", 1, "OutCubic", 1, true)
				end
			end
			spawn(function()
				wait(1)
				itemObj:Destroy()
			end)
		end
	end
	for itemPos, itemDet in pairs(build1Cache.items) do
		local itemObj = group:FindFirstChild(itemPos)
		if not itemObj then
			local itemStat = ItemStats[itemDet.item]
			
			if not Resources:GetBuildItem("Item"):FindFirstChild(itemDet.item) then
				warn("Cannot find", itemDet.item)
				continue
			end

			itemObj = Resources:GetBuildItem("Item")[itemDet.item]:Clone()
			itemObj.Name = itemPos
			itemObj.Parent = group

			local collisionPart = Instance.new("Part", itemObj)
			collisionPart.Anchored = true
			collisionPart.Name = "CollisionBox"
			collisionPart.Size = Vector3.new(itemStat.size.X - 4, 16, itemStat.size.Y - 4)
			collisionPart.CanCollide = false
			collisionPart.Position = itemObj.PrimaryPart.CFrame * Vector3.new(0, 8, 0)
			collisionPart.Transparency = 1

			local itemNameVal = Instance.new("StringValue", itemObj)
			itemNameVal.Name = "ItemName"
			itemNameVal.Value = itemDet.item

			local footerPart = Instance.new("Part")
			footerPart.Size = Vector3.new(itemStat.size.X, 5, itemStat.size.Y)
			footerPart.Position = itemObj.PrimaryPart.Position + Vector3.new(0, -2.5, 0)

			colourModel(itemObj, Color3.fromRGB(table.unpack(itemDet.colour)))
			
			if itemObj:FindFirstChild("SandBase") then TankDecors:decorTank(itemStat, itemObj) end
			if itemStat.fishHold then TankProfitLabel:getLabel(playerProfile, itemObj) end

			if itemStat.fishHold then
				local fishObjsFolder = itemObj:FindFirstChild("FishObjs")
				if not fishObjsFolder then
					fishObjsFolder = Instance.new("Folder", itemObj)
					fishObjsFolder.Name = "FishObjs"
				end
			end

			local origin = Vector3.new(2, 0, 30)
			--Instance.new("Part", workspace).Position = plot["0:0"].Mid.CFrame * origin
			local v2 = VectorTable.rconvert(itemPos)
			local v3 = -Vector3.new(v2.X * 4, 0, v2.Y * 4) + origin - getOffsetFromRotation(itemStat.size, itemDet.rot)
			local targetCF = CFrame.new(plot["0:0"].Mid.CFrame * v3) * CFrame.Angles(0, math.rad(-90 * (itemDet.rot - 1)), 0)
			if ignoreAnim then
				itemObj:SetPrimaryPartCFrame(targetCF)
				ItemInteractions:process(itemObj, playerProfile)
			else
				itemObj:SetPrimaryPartCFrame(targetCF * CFrame.new(0, 10, 0))
				for _, obj in pairs(itemObj:GetDescendants()) do
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
				--TweenModel:tweenModel(itemObj, targetCF, TweenInfo.new(1, Enum.EasingStyle.Cubic, Enum.EasingDirection.Out)):Play()
				ServerTween:tweenClient(playerProfile.obj, false, itemObj, "modelCF", targetCF, 1, Enum.EasingStyle.Cubic, Enum.EasingDirection.Out)
				spawn(function()
					wait(1)
					itemObj:SetPrimaryPartCFrame(targetCF)
					ItemInteractions:process(itemObj, playerProfile)
				end)
			end
		end
	end
end

function module:playerProfileAssign(playerProfile)
	local itemGroup = Instance.new("Folder", playerProfile.landPlots.obj)
	itemGroup.Name = "Items"
	
	local buildProfile = {}
	buildProfile.player = playerProfile
	
	--local build1Store = DataStore2("build1", playerProfile.obj)
	function buildProfile:update(ignoreAnim)
		module:updateItems(playerProfile, itemGroup, ignoreAnim)
	end
	function buildProfile:destroy()
		itemGroup:Destroy()
	end
	playerProfile.leave:Connect(buildProfile.destroy)
	
	buildProfile:update(true)
	
	return buildProfile
end

return module
