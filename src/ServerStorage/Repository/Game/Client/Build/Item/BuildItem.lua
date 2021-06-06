local module = {}

local Resources = require(game.ReplicatedStorage.Resources)
local EditorMenuUi = Resources:LoadLibrary("EditorMenuUi")
local Janitor = Resources:LoadLibrary("Janitor")
local ItemStats = Resources:LoadLibrary("ItemStats")
local ItemObjs = Resources:GetBuildItem("Item")
local UserInputService = game:GetService("UserInputService")
local WorkspaceMouse = Resources:LoadLibrary("WorkspaceMouse")
local Status = Resources:LoadLibrary("Status")
local Round = Resources:LoadLibrary("Round")
local Tween = Resources:LoadLibrary("Tween")
local Enumeration = Resources:LoadLibrary("Enumeration")
local VectorTable = Resources:LoadLibrary("VectorTable")
local Player = game.Players.LocalPlayer
local Mouse = Player:GetMouse()
local Keys = Resources:LoadLibrary("Keys")
local RunService = game:GetService("RunService")
local ColourPicker = Resources:LoadLibrary("ColourPicker")
local Notify = Resources:LoadLibrary("NotifyHandler")
local TextLoader = Resources:LoadLibrary("TextLoader")
local CeilingHideShow = Resources:LoadLibrary("CeilingHideShow")
local FishHoldIndexer = Resources:LoadLibrary("FishHoldIndexer")
local FishStats = Resources:LoadLibrary("FishStats")
local FloorStats = Resources:LoadLibrary("FloorStats")
local Debris = game:GetService("Debris")
local UiShowHide = Resources:LoadLibrary("UiShowHide")
local AudioHandler = Resources:LoadLibrary("AudioHandler")
local TutorialHandler = Resources:LoadLibrary("TutorialHandler")

local OutQuint = Enumeration.EasingFunction.OutQuint.Value
local OutBack = Enumeration.EasingFunction.OutBack.Value

local CurrentJanitor

local DeleteSelectionObj = Instance.new("SelectionBox", workspace)
DeleteSelectionObj.SurfaceTransparency = 0.5
DeleteSelectionObj.Transparency = 0.5
DeleteSelectionObj.Color3 = Color3.fromRGB(255, 84, 84)
DeleteSelectionObj.SurfaceColor3 = Color3.fromRGB(255, 84, 84)

local SelectSelectionObj = Instance.new("SelectionBox", workspace)
SelectSelectionObj.SurfaceTransparency = 0.5
SelectSelectionObj.Transparency = 0.5
SelectSelectionObj.Color3 = Color3.fromRGB(250, 253, 36)
SelectSelectionObj.SurfaceColor3 = Color3.fromRGB(250, 253, 36)

local ItemHoverGui = Player.PlayerGui.ItemHoverGui

local ItemDragging


local DebugJanitor
local function v3FromV2(v2)
	local plot = workspace.Game.PlayerPlots:FindFirstChild(tostring(Status.game.plotNo)).Plot
	local origin = Vector3.new(2, 0, 30)
	local v3 = -Vector3.new(v2.X * 4, 0, v2.Y * 4) + origin
	return plot["0:0"].Mid.CFrame * v3
end
local function debugPart(iPos, color)
	local v2 = VectorTable.rconvert(iPos)
	local targetCF = CFrame.new(v3FromV2(v2))
	local part = Instance.new("Part", workspace)
	if not DebugJanitor then DebugJanitor = Janitor.new() end
	DebugJanitor:Add(part, "Destroy")
	part.Size = Vector3.new(4, 1, 4)
	part.Anchored = true
	part.CanCollide = false
	part.Transparency = 0.5
	part.CFrame = targetCF
	part.Color = color
end

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
	return -Vector3.new(x, 0, y)/2 --+ Vector3.new(2, 0, -2)
end

function CheckiPosLegal(plots, iPos)
	local targetPos = VectorTable.rconvert(iPos)
	local safe = false
	for plotiPos, _ in pairs(plots) do
		local plotPos = VectorTable.rconvert(plotiPos)
		local offsetX = 0
		local offsetY = 0
		local minX = plotPos.X * 16 - 7 + offsetX
		local maxX = plotPos.X * 16 + 8 + offsetX
		local minY = plotPos.Y * 16 - 0 + offsetY
		local maxY = plotPos.Y * 16 + 15 + offsetY
		--print(minX, maxX, minY, maxY, ":", targetPos)
		--print(minX, maxX, minY, maxY, iPos)
		if targetPos.X < minX then continue end
		if targetPos.X > maxX then continue end
		if targetPos.Y < minY then continue end
		if targetPos.Y > maxY then continue end
		safe = true
		break
	end
	if safe then
		return true
	else
		return false
	end
end

function CheckPosCollide(itemCache, iPos, size, rot)
	local overridedPositions = {}
	for itemPos, itemDet in pairs(itemCache) do
		local itemStat = ItemStats[itemDet.item]
		local pos0 = VectorTable.rconvert(itemPos)
		local offset = getOffsetFromRotation(itemStat.size, itemDet.rot)
		local pos1 = pos0-- + Vector2.new(offset.X, offset.Z)
		local pos2 = pos0 - Vector2.new(offset.X, offset.Z)/2
		
		local startX = (pos1.X < pos2.X) and pos1.X or pos2.X
		local endX = (startX == pos2.X) and pos1.X or pos2.X
		local startY = (pos1.Y < pos2.Y) and pos1.Y or pos2.Y
		local endY = (startY == pos2.Y) and pos1.Y or pos2.Y
		for x = startX, endX do
			for y = startY, endY do
				--debugPart(VectorTable.convert(Vector2.new(x, y)), Color3.fromRGB(255, 255, 0))
				overridedPositions[VectorTable.convert(Vector2.new(x, y))] = true
			end
		end
	end
	
	--print(overridedPositions)
	if overridedPositions[iPos] then return true end
	
	local pos0 = VectorTable.rconvert(iPos)
	local offset = getOffsetFromRotation(size, rot)
	local pos1 = pos0-- + Vector2.new(offset.X, offset.Z)
	local pos2 = pos0 - Vector2.new(offset.X, offset.Z)/2

	local startX = (pos1.X < pos2.X) and pos1.X or pos2.X
	local endX = (startX == pos2.X) and pos1.X or pos2.X
	local startY = (pos1.Y < pos2.Y) and pos1.Y or pos2.Y
	local endY = (startY == pos2.Y) and pos1.Y or pos2.Y
	for x = startX, endX do
		for y = startY, endY do
			local iPos = VectorTable.convert(Vector2.new(x, y))
			if overridedPositions[iPos] then return true end
			if not CheckiPosLegal(Status.data.build1.plots, iPos) then return true end
		end
	end
end

function getiPosFromPos(pos, plot, posOffsetRot, offset)
	offset = offset or 0
	return VectorTable.convert(Vector2.new(-Round((pos.X - plot["0:0"].Mid.Position.X - posOffsetRot.X)/4) + 1 + offset, -Round((pos.Y - plot["0:0"].Mid.Position.Z - posOffsetRot.Z)/4) + 8 + offset))
end

local placeFunc

function module:on()
	if CurrentJanitor then return end
	CurrentJanitor = Janitor.new()

	CeilingHideShow:hide()

	local editorHandler = EditorMenuUi.new()
	CurrentJanitor:Add(editorHandler, "Destroy")
	editorHandler:initItems(ItemStats, ItemObjs)
	editorHandler.allow = ItemDragging and false or true
	
	local pickerHandler = ColourPicker.new()
	CurrentJanitor:Add(pickerHandler, "Destroy")
	pickerHandler:init(Player.PlayerGui.Editor.Frame.List.Picker.Base, Player.PlayerGui.Editor.Frame.List.Picker.Base)

	local cfVal = Instance.new("CFrameValue")
	CurrentJanitor:Add(cfVal, "Destroy")

	CurrentJanitor:Add(UiShowHide.tweened:Connect(function(ui, state)
		if ui == "EditorUiWPicker" and state == "close" then
			module:off()
		end
	end), "Disconnect")

	if UserInputService.TouchEnabled then
		-- UiShowHide:tweenMenu("EditorRotateUi", "open")
		-- UiShowHide:tweenMenu("EditorPlaceUi", "open")
		-- UiShowHide:tweenMenu("EditorCancelUi", "open")
	else
		UiShowHide:tweenMenu("EditorControlsUi", "open")
	end

	--local currentlySelecting
	local lastItem
	local function loadItem(itemName, overrideColour)
		if not TutorialHandler.doingTutorial then
			-- UiShowHide:tweenMenu("MoneyBuyUi", "close")
		end
		local itemStat = ItemStats[itemName]
		Player.PlayerGui.Editor.MoneyAmount.DescLabel.Text = itemName .. " $" .. TextLoader:ConvertShort(itemStat.price)
		if itemStat.price > Status.data.money then
			Player.PlayerGui.Editor.MoneyAmount.DescLabel.TextColor3 = Color3.fromRGB(255, 80, 80)
		else
			Player.PlayerGui.Editor.MoneyAmount.DescLabel.TextColor3 = Color3.fromRGB(0, 179, 255)
		end
		lastItem = itemName
		local itemStat = ItemStats[itemName]
		if editorHandler.deleting then
			editorHandler:toggleDelete(itemName)
		end
		if editorHandler.selecting then
			editorHandler:toggleSelect(itemName)
		end
		local obj = ItemObjs[itemName]:Clone()
		colourModel(obj, overrideColour or pickerHandler.cp.c3)
		for _, obj in pairs(obj:GetDescendants()) do
			if obj:IsA("BasePart") or obj:IsA("Decal") or obj:IsA("Texture") then
				--print(1 - (1 - obj.Transparency)/2, obj.Transparency)
				obj.Transparency = 1 - (1 - obj.Transparency)/2
				if obj:IsA("BasePart") then
					obj.CanCollide = false
				elseif obj:IsA("ProximityPrompt") then
					obj.Enabled = false
				end
			end
		end
		obj.PrimaryPart.Size = Vector3.new(itemStat.size.X, 1, itemStat.size.Y)
		local SelectionObj = Instance.new("SelectionBox", obj.PrimaryPart)
		SelectionObj.SurfaceTransparency = 0.5
		SelectionObj.Transparency = 0.5
		SelectionObj.Color3 = Color3.fromRGB(124, 255, 84)
		SelectionObj.SurfaceColor3 = Color3.fromRGB(124, 255, 84)
		SelectionObj.Adornee = obj.PrimaryPart

		CurrentJanitor:Add(obj, "Destroy", "Selecting")
		--currentlySelecting = obj
		obj:SetPrimaryPartCFrame(CFrame.new(0, 0, 0))
		CurrentJanitor:Add(cfVal:GetPropertyChangedSignal("Value"):Connect(function()
			--print(cfVal.Value.p, ":::", cfVal.Value)
			if obj.PrimaryPart then
				obj:SetPrimaryPartCFrame(cfVal.Value)
			else
				if RunService:IsStudio() then
					warn("missing primary part for item obj", obj)
				end
			end
		end), "Disconnect", "CF prop changed")
		obj:SetPrimaryPartCFrame(cfVal.Value)
		
		obj.Parent = workspace
	end
	editorHandler.itemPickedEvent:Connect(function(...)
		local itemName, autoColour = ...
		local randCol1
		if autoColour then
			for _, obj in pairs(Resources:GetBuildItem("Item")[itemName]:GetDescendants()) do
				if obj.Name == "Col1" then randCol1 = obj.Color break end
			end
			if randCol1 then pickerHandler:updateColour(randCol1) end
		end
		loadItem(itemName, randCol1)

		if UserInputService.TouchEnabled then
			UiShowHide:tweenMenu("EditorRotateUi", "open")
			UiShowHide:tweenMenu("EditorPlaceUi", "open")
			UiShowHide:tweenMenu("EditorCancelUi", "open")
			UiShowHide:tweenMenu("EditorMoneyAmountUi", "open")
			UiShowHide:tweenMenu("EditorBaseHideUi", "close")
			UiShowHide:tweenMenu("EditorFilterUi", "close")
		end
	end)

	if ItemDragging then
		pickerHandler:updateColour(ItemDragging.colour)
		local itemStat = ItemStats[ItemDragging.name]
		editorHandler:pickItem(ItemDragging.name, itemStat)
	end
	
	editorHandler.deletingEvent:Connect(function(deleting)
		if deleting then
			
		else
			DeleteSelectionObj.Adornee = nil
			--editorHandler:pickItem(lastItem, ItemStats[lastItem])
		end
	end)

	editorHandler.cancelEvent:Connect(function()
		CurrentJanitor:Remove("CF prop changed")
		CurrentJanitor:Remove("Selecting")
		if UserInputService.TouchEnabled then
			UiShowHide:tweenMenu("EditorRotateUi", "close")
			UiShowHide:tweenMenu("EditorPlaceUi", "close")
			UiShowHide:tweenMenu("EditorCancelUi", "close")
			UiShowHide:tweenMenu("EditorMoneyAmountUi", "close")
			UiShowHide:tweenMenu("EditorBaseHideUi", "open")
			UiShowHide:tweenMenu("EditorFilterUi", "open")
		end
	end)
	
	local function checkiPosCondition(pos, plot, posOffsetRot, lastSelectingPos, condition, itemStat)
		local iPos = getiPosFromPos(pos, plot, posOffsetRot, itemStat.offset)
		if condition(pos, plot, posOffsetRot) then return pos end
		local pos1 = pos --VectorTable.rconvert(iPos)
		local pos2 = lastSelectingPos --VectorTable.rconvert(lastSelectingPos)
		local validPos
		validPos = condition(Vector2.new(pos1.X, pos2.Y), plot, posOffsetRot)
		if validPos then return validPos end
		validPos = condition(Vector2.new(pos2.X, pos1.Y), plot, posOffsetRot)
		return validPos
	end
	
	local plot = workspace.Game.PlayerPlots:FindFirstChild(tostring(Status.game.plotNo)).Plot
	local lastSelectingiPos = "0:8"
	local lastSelectingPos = Vector2.new(0, 0)
	local deletingTarget
	local selectingTarget
	local rot = 1
	local lastRot = 1

	local function updatePlacing(ignoreNewPos)
		--if not currentlySelecting then return end
		if DebugJanitor then DebugJanitor:Cleanup() DebugJanitor = nil end
		if not editorHandler.itemPicked then return end
		local raycastP = RaycastParams.new()
		raycastP.FilterType = Enum.RaycastFilterType.Whitelist
		raycastP.FilterDescendantsInstances = {plot.Parent.Grid}
		local hit = WorkspaceMouse:getHit(300, raycastP) -- + Vector3.new(0, 0, 0)
		--print(hit)
		if not hit then
			if ignoreNewPos then
				hit = Vector3.new(lastSelectingPos.X, 0, lastSelectingPos.Y)
			else
				return
			end
		end
		--local hitOnPlot = hit + plot["0:0"].Mid.Position
		local itemPicked = editorHandler.itemPicked
		local itemStat = ItemStats[itemPicked]
		local offsetX = plot["0:0"].Mid.Position.X % 4 + 2
		local offsetZ = plot["0:0"].Mid.Position.Z % 4 + 2
		local pos = Vector2.new(Round((hit.X - offsetX)/4) * 4 + offsetX, Round(((hit.Z) - offsetZ)/4) * 4 + offsetZ)
		local xOdd = ((itemStat.size.X/4 % 2) == 0 and 2 or 0)
		local yOdd = ((itemStat.size.Y/4 % 2) == 0 and 2 or 0)
		local x = math.clamp(pos.X, plot.Parent.Grid.Position.X - plot.Parent.Grid.Size.X/2, plot.Parent.Grid.Position.X + plot.Parent.Grid.Size.X/2) + ((rot == 1 or rot == 3) and xOdd or yOdd)
		local y = math.clamp(pos.Y, plot.Parent.Grid.Position.Z - plot.Parent.Grid.Size.Z/2, plot.Parent.Grid.Position.Z + plot.Parent.Grid.Size.Z/2) + ((rot == 2 or rot == 4) and xOdd or yOdd)
		pos = Vector2.new(x, y)
		local posOffsetRot = getOffsetFromRotation(itemStat.size, rot)
		local iPos = getiPosFromPos(pos, plot, posOffsetRot, itemStat.offset)
		if iPos ~= lastSelectingiPos or rot ~= lastRot then
			lastRot = rot
			local check0 = checkiPosCondition(pos, plot, posOffsetRot, lastSelectingPos, function(pos, plot, posOffsetRot)
				iPos = getiPosFromPos(pos, plot, posOffsetRot, itemStat.offset)
				--debugPart(iPos, Color3.fromRGB(255, 0, 0))
				if not Status.data.build1.items[iPos] then return pos end
			end, itemStat)
			if not check0 then
				return
			end
			pos = check0
			local check1 = checkiPosCondition(pos, plot, posOffsetRot, lastSelectingPos, function(pos, plot, posOffsetRot)
				iPos = getiPosFromPos(pos, plot, posOffsetRot, itemStat.offset)
				--debugPart(iPos, Color3.fromRGB(0, 255, 0))
				if CheckiPosLegal(Status.data.build1.plots, iPos) then return pos end
			end, itemStat)
			if not check1 then
				return
			end
			pos = check1
			--print(pos, "c1")
			local check2 = checkiPosCondition(pos, plot, posOffsetRot, lastSelectingPos, function(pos, plot, posOffsetRot)
				iPos = getiPosFromPos(pos, plot, posOffsetRot, itemStat.offset)
				--debugPart(iPos, Color3.fromRGB(0, 0, 255))
				if not CheckPosCollide(Status.data.build1.items, iPos, itemStat.size, rot) then return pos end
				--print(Status.data.build1.items)
			end, itemStat)
			if not check2 then
				return
			end
			pos = check2
			--print(pos, "c2")
			if ignoreNewPos then
				iPos = lastSelectingiPos and lastSelectingiPos or iPos
				pos = lastSelectingPos and lastSelectingPos or pos
			else
				lastSelectingiPos = iPos
				lastSelectingPos = pos
			end
			local v3Base = Vector3.new(pos.X, plot["0:0"].Mid.Position.Y, pos.Y)
			local lastPos = cfVal.Value.p
			local direction = CFrame.new(lastPos, v3Base).LookVector.Unit
			if (lastPos - v3Base).Magnitude < 1 then direction = Vector3.new(0, 0, 0) end
			local cf1 = CFrame.new(v3Base) * CFrame.Angles(math.rad(direction.Z * 10), 0, math.rad(-direction.X * 10)) * CFrame.new(0, 1, 0) * CFrame.Angles(0, math.rad(-90 * (rot - 1)), 0)
			local cf2 = CFrame.new(v3Base) * CFrame.Angles(0, math.rad(-90 * (rot - 1)), 0)
			if not ignoreNewPos then
				if (not (cf1.p.X > 0)) and (not (cf1.p.X < 0)) then return end
			end
			local t1 = Tween(cfVal, "Value", cf1, OutQuint, 0.4, true)
			spawn(function()
				wait(0.3)
				if t1.Running then
					Tween(cfVal, "Value", cf2, OutBack, 0.7, true)
				end
			end)

			local m1Pressed, m2Pressed = false, false
			for _, button in pairs (UserInputService:GetMouseButtonsPressed()) do
				-- Check if MouseButton1 is pressed
				if (button.UserInputType.Name == "MouseButton1") then
					m1Pressed = true
				end
		
				-- Check if MouseButton2 is pressed
				if (button.UserInputType.Name == "MouseButton2") then
					m2Pressed = true
				end
			end
			-- if lastSelectingiPos and m1Pressed then
			-- 	place()
			-- end
		else
			return
		end
	end

	local function updateOnMovement()
		if not editorHandler.deleting and not editorHandler.selecting then
			updatePlacing()
		end
		local raycastP = RaycastParams.new()
		raycastP.FilterType = Enum.RaycastFilterType.Whitelist
		raycastP.FilterDescendantsInstances = {plot.Parent.Items}
		local target = WorkspaceMouse:getTarget(300, raycastP)
		local function quit()
			SelectSelectionObj.Adornee = nil
			ItemHoverGui.Adornee = nil
			ItemHoverGui.Frame.Visible = false
		end
		if TutorialHandler.doingTutorial then quit() return end
		if ItemDragging then quit() return end
		if target then
			local parentModel = target
			for i = 1, 10 do
				if not parentModel then break end
				local tempParentModel = parentModel:FindFirstAncestorWhichIsA("Model")
				parentModel = tempParentModel
				if tempParentModel.Parent == plot.Parent.Items then
					break
				end
				if i == 10 then quit() return end
			end
			if parentModel.Parent ~= plot.Parent.Items then return end
			if not parentModel then quit() return end
			if editorHandler.selecting then
				SelectSelectionObj.Adornee = parentModel
			end
			selectingTarget = parentModel
			ItemHoverGui.Adornee = selectingTarget:FindFirstChild("MoveIndicator") or selectingTarget.PrimaryPart
			ItemHoverGui.Frame.Visible = true
		else
			quit()
			return
		end
		-- elseif editorHandler.deleting then
		-- 	local raycastP = RaycastParams.new()
		-- 	raycastP.FilterType = Enum.RaycastFilterType.Whitelist
		-- 	raycastP.FilterDescendantsInstances = {plot.Parent.Items}
		-- 	local target = WorkspaceMouse:getTarget(300, raycastP)
		-- 	local function quit()
		-- 		DeleteSelectionObj.Adornee = nil
		-- 	end
		-- 	if target then
		-- 		local parentModel = target
		-- 		for i = 1, 10 do
		-- 			if not parentModel then break end
		-- 			local tempParentModel = parentModel:FindFirstAncestorWhichIsA("Model")
		-- 			parentModel = tempParentModel
		-- 			if tempParentModel.Parent == plot.Parent.Items then
		-- 				break
		-- 			end
		-- 			if i == 10 then quit() return end
		-- 		end
		-- 		if parentModel.Parent ~= plot.Parent.Items then return end
		-- 		if not parentModel then quit() return end
		-- 		DeleteSelectionObj.Adornee = parentModel
		-- 		deletingTarget = parentModel
		-- 	else
		-- 		quit()
		-- 		return
		-- 	end
	end

	CurrentJanitor:Add(UserInputService.InputChanged:Connect(function(input, proc)
		if proc then return end
		if input.UserInputType == Enum.UserInputType.MouseMovement then
			updateOnMovement()
		end
	end), "Disconnect")
	CurrentJanitor:Add(UserInputService.TouchTap:Connect(function(touchPositions, proc)
		if proc then return end
		updateOnMovement()
	end), "Disconnect")
	
	local function place(overridePos)
		-- if not calledFromPlace then updatePlacing() end
		if Status.game.placedDeb then return end
		local placeSuccess = false
		lastSelectingiPos = overridePos or lastSelectingiPos
		if editorHandler.itemPicked and lastSelectingiPos then
			local itemStat = ItemStats[editorHandler.itemPicked]
			if itemStat.price > Status.data.money and not ItemDragging then
				Notify:addItem("Issue", 3, nil, string.format("Cannot build! You need $%s more money to buy a %s!", TextLoader:ConvertShort(itemStat.price - Status.data.money), editorHandler.itemPicked))
				AudioHandler:playAudio("Error")
				-- ShopUi:updatePage("Money")
				-- BindUiOpenClose.binds.Shop.sigs.open:Fire()
				if not TutorialHandler.doingTutorial then
					UiShowHide:tweenMenu("MoneyBuyUi", "open")
					spawn(function()
						wait(4)
						UiShowHide:tweenMenu("MoneyBuyUi", "close")
					end)
				end
			else
				local origin = Vector3.new(2, 0, 30)
				local v2 = VectorTable.rconvert(lastSelectingiPos)
				local v3 = -Vector3.new(v2.X * 4, 0, v2.Y * 4) + origin -- getOffsetFromRotation(itemStat.size, rot)
				local targetCF = CFrame.new(plot["0:0"].Mid.CFrame * v3)
				local minPos = targetCF.p + Vector3.new(0, 0, 0)
				local maxPos = minPos + getOffsetFromRotation(itemStat.size, rot) * 2 + Vector3.new(0, 16, 0)
				local function debugPart(pos)
					local part = Instance.new("Part", workspace)
					part.Anchored = true
					part.Position = pos
				end
				-- Instance.new("Part", workspace).Position = minPos
				-- Instance.new("Part", workspace).Position = maxPos
				local lowerX = minPos.X > maxPos.X and maxPos.X or minPos.X
				local higherX = minPos.X > maxPos.X and minPos.X or maxPos.X
				local lowerZ = minPos.Z > maxPos.Z and maxPos.Z or minPos.Z
				local higherZ = minPos.Z > maxPos.Z and minPos.Z or maxPos.Z
				minPos = Vector3.new(lowerX, 0, lowerZ)
				maxPos = Vector3.new(higherX, 16, higherZ)
				-- debugPart(minPos)
				-- debugPart(maxPos)
				local region = Region3.new(minPos, maxPos)
				-- local whitelist = plot.Parent.HWalls:GetChildren()
				-- -- print("h", whitelist)
				-- for _, obj in pairs(plot.Parent.VWalls:GetChildren()) do
				-- 	table.insert(whitelist, 1, obj)
				-- end
				-- for _, obj in pairs(workspace.Players:GetChildren()) do
				-- 	table.insert(whitelist, 1, obj)
				-- end
				local collectedParts = workspace:FindPartsInRegion3WithWhiteList(region, {workspace.Players, plot.Parent.HWalls, plot.Parent.VWalls}, 100)
				-- print("collected", collectedParts)
				local inTheWay = false
				for _, part in pairs(collectedParts) do
					if part.Parent.Name == "Radio" then continue end
					if part.name == "FloorDoorTrigger" then continue end
					local AwaySelectionObj = Instance.new("SelectionBox", workspace)
					AwaySelectionObj.SurfaceTransparency = 0.5
					AwaySelectionObj.Transparency = 0.5
					AwaySelectionObj.Color3 = Color3.fromRGB(255, 84, 84)
					AwaySelectionObj.SurfaceColor3 = Color3.fromRGB(255, 84, 84)
					AwaySelectionObj.Adornee = part
					Debris:AddItem(AwaySelectionObj, 1)
					inTheWay = true
				end
				if inTheWay then
					Notify:addItem("Issue", 3, nil, "Something is in the way!")
					return false
				end

				if Status.game.placedDeb then return end
				local chosenDeb = tick()
				Status.game.placedDeb = chosenDeb
				Resources:GetRemote("BuildItem"):FireServer(editorHandler.itemPicked, lastSelectingiPos, rot, pickerHandler.cp.c3)
				cfVal.Value = CFrame.new(1, -20, 1)
				-- lastSelectingiPos = nil
				editorHandler:pickItem(editorHandler.itemPicked, ItemStats[editorHandler.itemPicked])
				placeSuccess = true
				--print("ah")
				AudioHandler:playAudio("Pop")
				spawn(function()
					wait(5)
					if Status.game.placedDeb == chosenDeb then
						Status.game.placedDeb = false
					else
						print("ignore")
					end
				end)
				return true
			end
		end
		--print("a", placeSuccess)
		return placeSuccess
	end
	placeFunc = place

	pickerHandler.colourDecidedSignal:Connect(function(c3)
		if lastItem then
			loadItem(lastItem)
		end
	end)

	local function proceedPlacing()
		if editorHandler.selecting then
			if selectingTarget then
				local randCol1
				for _, obj in pairs(selectingTarget:GetDescendants()) do 
					if obj.Name == "Col1" then randCol1 = obj.Color break end
				end
				if not randCol1 then return end
				pickerHandler:updateColour(randCol1)
				editorHandler:toggleSelect()
				editorHandler:pickItem(lastItem)
				SelectSelectionObj.Adornee = nil
			end
		-- elseif editorHandler.deleting then
		-- 	if deletingTarget then
		-- 		Resources:GetRemote("DestroyItem"):FireServer(deletingTarget.Name)
		-- 	end
		else
			place()
		end
	end
	-- CurrentJanitor:Add(Mouse.Button1Down:Connect(function()
	-- 	if not UserInputService.TouchEnabled then
	-- 		proceedPlacing()
	-- 	end
	-- end), "Disconnect")
	CurrentJanitor:Add(UserInputService.InputBegan:Connect(function(input, proc)
		if proc then return end
		if input.UserInputType == Enum.UserInputType.Keyboard then
			if input.KeyCode == Enum.KeyCode.Q then
				editorHandler.cancelEvent:Fire()
			elseif input.KeyCode == Enum.KeyCode.R then
				rot += 1
				if rot > 4 then rot = 1 end
				--lastSelectingiPos = nil
				updatePlacing()
			elseif input.KeyCode == Enum.KeyCode.X then
				Player.PlayerGui.Editor.Close:Fire()
			end
		-- elseif input.UserInputType == Enum.UserInputType.Touch then
		-- 	updateOnMovement()
		elseif input.UserInputType == Enum.UserInputType.MouseButton1 then
			proceedPlacing()
		end
	end), "Disconnect")
	CurrentJanitor:Add(Player.PlayerGui.Editor.Place.Base.Frame.MouseButton1Click:Connect(function()
		proceedPlacing()
	end), "Disconnect")
	CurrentJanitor:Add(Player.PlayerGui.Editor.Cancel.Base.Frame.MouseButton1Click:Connect(function()
		if TutorialHandler.doingTutorial then return end
		editorHandler.cancelEvent:Fire()
	end), "Disconnect")

	CurrentJanitor:Add(Player.PlayerGui.Editor.Rotate.Base.Frame.MouseButton1Click:Connect(function()
		rot += 1
		if rot > 4 then rot = 1 end
		--lastSelectingiPos = nil
		updatePlacing(true)
	end), "Disconnect")

	--plot.Parent.Grid.Texture.Transparency = 0.8
	--plot.Parent.Grid.Texture.StudsPerTileU = 16
	--plot.Parent.Grid.Texture.StudsPerTileV = 16
	for plotPos, _ in pairs(Status.data.build1.plots) do
		plot.Parent.Grids[plotPos].Texture.Transparency = 0.8
		plot.Parent.Grids[plotPos].Texture.StudsPerTileU = 4
		plot.Parent.Grids[plotPos].Texture.StudsPerTileV = 4
	end

	local function setupItemFloor(itemStat, obj)
		if itemStat.offset then return end
		obj.PrimaryPart.Size = Vector3.new(itemStat.size.X, 1, itemStat.size.Y)
		local SelectionObj = Instance.new("SelectionBox", obj.PrimaryPart)
		SelectionObj.SurfaceTransparency = 0.5
		SelectionObj.Transparency = 0.5
		SelectionObj.Color3 = Color3.fromRGB(229, 255, 84)
		SelectionObj.SurfaceColor3 = Color3.fromRGB(229, 255, 84)
		SelectionObj.Adornee = obj.PrimaryPart
		CurrentJanitor:Add(SelectionObj, "Destroy")

		-- local collisionBox = obj:FindFirstChild("CollisionBox") or obj:WaitForChild("CollisionBox")
		-- collisionBox.Color = Color3.fromRGB(255, 0, 0)
		-- collisionBox.Transparency = 0.5
		-- CurrentJanitor:Add(function()
		-- 	collisionBox.Transparency = 1
		-- end)

		local boundaryBox = Instance.new("Part", obj)
		boundaryBox.Name = "Boundary"
		boundaryBox.Color = Color3.fromRGB(255, 0, 0)
		boundaryBox.Anchored = true
		boundaryBox.CanCollide = false
		boundaryBox.Transparency = 0.8
		boundaryBox.Size = Vector3.new(itemStat.size.X, 16, itemStat.size.Y)
		boundaryBox.CFrame = obj.PrimaryPart.CFrame * CFrame.new(0, 8, 0)
		boundaryBox.TopSurface = Enum.SurfaceType.Smooth
		CurrentJanitor:Add(boundaryBox, "Destroy")
	end
	for _, itemObj in pairs(plot.Parent.Items:GetChildren()) do
		local itemOwned = Status.data.build1.items[itemObj.Name]
		local itemStat = ItemStats[itemOwned.item]
		setupItemFloor(itemStat, itemObj)
	end
	CurrentJanitor:Add(plot.Parent.Items.ChildAdded:Connect(function(itemObj)
		if not itemObj.PrimaryPart then itemObj:GetPropertyChangedSignal("PrimaryPart"):Wait() end
		local itemOwned = Status.data.build1.items[itemObj.Name]
		local itemStat = ItemStats[itemOwned.item]
		setupItemFloor(itemStat, itemObj)
	end), "Disconnect")

	CurrentJanitor:Add(ItemHoverGui.Frame.ImageButton.MouseButton1Click:Connect(function()
		if selectingTarget and not editorHandler.deleting and not editorHandler.selecting then
			local name = selectingTarget.Name
			local itemOwned = Status.data.build1.items[name]
			local itemName = itemOwned.item
			local itemStat = ItemStats[itemOwned.item]
			local col1 = selectingTarget:FindFirstChild("Col1", true)
			local colour = Color3.fromRGB(0, 0, 0)
			if col1 then
				colour = col1.Color
			end
			local allow = Resources:GetRemote("DragItem"):InvokeServer(name)
			if allow then
				ItemDragging = {name = itemName, colour = colour, lastPos = name}
				pickerHandler:updateColour(colour)
				editorHandler:pickItem(itemName, itemStat)
				editorHandler.allow = false
			else
				return
			end
		end
	end), "Disconnect")

	CurrentJanitor:Add(Mouse.Button1Up:Connect(function()
		if ItemDragging then
			local success = place()
			--print(success)
			if success then
				editorHandler.itemPicked = nil
				editorHandler:pickItem()
				editorHandler.allow = true
				ItemDragging = nil
			end
		end
	end), "Disconnect")
end

function module:off()
	if not CurrentJanitor then return end
	CurrentJanitor:Cleanup()
	CurrentJanitor = nil

	CeilingHideShow:show()

	ItemHoverGui.Frame.Visible = false

	DeleteSelectionObj.Adornee = nil
	SelectSelectionObj.Adornee = nil

	UiShowHide:tweenMenu("EditorControlsUi", "close")
	UiShowHide:tweenMenu("EditorRotateUi", "close")
	UiShowHide:tweenMenu("EditorPlaceUi", "close")
	UiShowHide:tweenMenu("EditorMoneyAmountUi", "close")
	UiShowHide:tweenMenu("EditorCancelUi", "close")
	
	if ItemDragging then
		placeFunc(ItemDragging.lastPos)
	end

	local plot = workspace.Game.PlayerPlots:FindFirstChild(tostring(Status.game.plotNo)).Plot
	--plot.Parent.Grid.Texture.Transparency = 1
	for _, plotObj in pairs(plot.Parent.Grids:GetChildren()) do
		plotObj.Texture.Transparency = 1
	end
end

local lastSelect
local tankGui = Player.PlayerGui.ItemTankGui
function updateTankGui()
	if Status.game.visiting then return end
	local plot = workspace.Game.PlayerPlots:FindFirstChild(tostring(Status.game.plotNo)).Plot
	local raycastP = RaycastParams.new()
	raycastP.FilterType = Enum.RaycastFilterType.Whitelist
	if not plot.Parent:FindFirstChild("Items") or not plot.Parent:FindFirstChild("Floors") then return end
	raycastP.FilterDescendantsInstances = {plot.Parent.Items, plot.Parent.Floors}
	local target = WorkspaceMouse:getTarget(100, raycastP)

	local function removeLastSelect()
		if lastSelect then
			tankGui.Adornee = nil
			tankGui.Frame.Visible = false
			tankGui.Frame:TweenPosition(UDim2.new(0.5, 0, -0.5, 0), Enum.EasingDirection.InOut, Enum.EasingStyle.Quint, 0.5, true)
		end
		lastSelect = nil
	end

	if not target then removeLastSelect() return end
	local parentModel = target
	if target then
		for i = 1, 2 do
			if not parentModel then break end
			local tempParentModel = parentModel:FindFirstAncestorWhichIsA("Model")
			parentModel = tempParentModel
			if tempParentModel.Parent == plot.Parent.Items or tempParentModel.Parent == plot.Parent.Floors then
				break
			end
			if i == 2 then removeLastSelect() return end
		end
		if parentModel.Parent ~= plot.Parent.Items and parentModel.Parent ~= plot.Parent.Floors then removeLastSelect() print(2) return end
		if not parentModel then removeLastSelect() return end
	else
		removeLastSelect()
		return
	end

	if lastSelect == parentModel then return end -- removeLastSelect() return end
	lastSelect = parentModel
	local itemOwned = Status.data.build1.items[parentModel.Name] or Status.data.build1.floors[parentModel.Name]
	if not itemOwned then removeLastSelect() return end
	local itemStat = ItemStats[itemOwned.item] or FloorStats[itemOwned.floor]
	-- if parentModel:FindFirstChild("FillEmpty") then removeLastSelect() return end
	if itemStat.itemType == "fish" then
		tankGui.Adornee = parentModel.PrimaryPart
		tankGui.Frame.Visible = true
		tankGui.Frame:TweenPosition(UDim2.new(0.5, 0, 0.5, 0), Enum.EasingDirection.InOut, Enum.EasingStyle.Quint, 0.5, true)
		lastSelect = parentModel
		tankGui.Frame.Body.TankName.Text = (itemOwned.item or itemOwned.floor)
		local fishHoldIndex = FishHoldIndexer.convert("item", parentModel.Name)
		if itemOwned.floor then
			fishHoldIndex = FishHoldIndexer.convert("floor", parentModel.Name)
		end
		if Status.data.fishHold[fishHoldIndex] then
			local fishForConcat = {}
			local totalFishWeight = 0
			for fishName, fishAmount in pairs(Status.data.fishHold[fishHoldIndex]) do
				local fishStat = FishStats[fishName]
				totalFishWeight += fishAmount * fishStat.weight
				table.insert(fishForConcat, 1, string.format("%s %s", fishAmount, fishName))
			end
			tankGui.Frame.Body.AmountLabel.Text = string.format("%s/%s", totalFishWeight, itemStat.fishHold)
			tankGui.Frame.Body.FishLabel.Text = table.concat(fishForConcat, ", ")
		else
			tankGui.Frame.Body.AmountLabel.Text = string.format("%s/%s", 0, itemStat.fishHold)
			tankGui.Frame.Body.FishLabel.Text = "This tank earns no money with no fish, <color='rgb(255, 85, 127)'>CLICK FILL TO ADD FISH</font>"
		end
	else
		removeLastSelect()
		return
	end
end
UserInputService.InputChanged:Connect(function(input, proc)
	if proc then return end
	if input.UserInputType == Enum.UserInputType.MouseMovement then
		updateTankGui()
	end
end)

UserInputService.TouchMoved:Connect(function(touch, proc)
	if proc then return end
	local touchPos = touch.Position
	updateTankGui()
end)
UserInputService.TouchStarted:Connect(function(touch, proc)
	if proc then return end
	local touchPos = touch.Position
	updateTankGui()
end)

return module
