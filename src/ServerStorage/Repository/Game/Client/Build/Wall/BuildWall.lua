local module = {}

local Resources = require(game.ReplicatedStorage.Resources)
local EditorMenuUi = Resources:LoadLibrary("EditorMenuUi")
local Janitor = Resources:LoadLibrary("Janitor")
local WallStats = Resources:LoadLibrary("WallStats")
local WallObjs = Resources:GetBuildItem("Wall")
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
local ColourPicker = Resources:LoadLibrary("ColourPicker")
local Notify = Resources:LoadLibrary("NotifyHandler")
local TextLoader = Resources:LoadLibrary("TextLoader")
local CeilingHideShow = Resources:LoadLibrary("CeilingHideShow")
local UiShowHide = Resources:LoadLibrary("UiShowHide")
local Debris = game:GetService("Debris")
local AudioHandler = Resources:LoadLibrary("AudioHandler")
local RunService = game:GetService("RunService")
-- local ShopUi = Resources:LoadLibrary("ShopUi")
-- local BindUiOpenClose = Resources:LoadLibrary("BindUiOpenClose")

local OutQuint = Enumeration.EasingFunction.OutQuint.Value
local OutBack = Enumeration.EasingFunction.OutBack.Value

local CurrentJanitor

local DeleteSelectionObj = Instance.new("SelectionBox", workspace)
DeleteSelectionObj.SurfaceTransparency = 0.5
DeleteSelectionObj.Transparency = 0.5
DeleteSelectionObj.Color3 = Color3.fromRGB(255, 84, 84)
DeleteSelectionObj.SurfaceColor3 = Color3.fromRGB(255, 0, 0)

local SelectSelectionObj = Instance.new("SelectionBox", workspace)
SelectSelectionObj.SurfaceTransparency = 0.5
SelectSelectionObj.Transparency = 0.5
SelectSelectionObj.Color3 = Color3.fromRGB(250, 253, 36)
SelectSelectionObj.SurfaceColor3 = Color3.fromRGB(250, 253, 36)

function colourModel(model, c3)
	for _, obj in pairs(model:GetDescendants()) do
		if obj:IsA("BasePart") and obj.Name == "Col1" then
			obj.Color = c3
		end
	end
end

function CheckiPosLegalV(plots, iPos)
	local targetPos = VectorTable.rconvert(iPos)
	local safe = false
	for plotiPos, _ in pairs(plots) do
		local plotPos = VectorTable.rconvert(plotiPos)
		local offsetX = 2
		local offsetY = 3
		local minX = plotPos.X * 4 - 4 + offsetX
		local maxX = plotPos.X * 4 + 0 + offsetX
		local minY = plotPos.Y * 4 - 3 + offsetY
		local maxY = plotPos.Y * 4 + 0 + offsetY
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

function CheckiPosLegalH(plots, iPos)
	local targetPos = VectorTable.rconvert(iPos)
	local safe = false
	for plotiPos, _ in pairs(plots) do
		local plotPos = VectorTable.rconvert(plotiPos)
		local offsetX = 2
		local offsetY = 3
		local minX = plotPos.X * 4 - 3 + offsetX
		local maxX = plotPos.X * 4 + 0 + offsetX
		local minY = plotPos.Y * 4 - 3 + offsetY
		local maxY = plotPos.Y * 4 + 1 + offsetY
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

function module:on()
	if CurrentJanitor then return end
	CurrentJanitor = Janitor.new()

	CeilingHideShow:hide()

	local editorHandler = EditorMenuUi.new()
	CurrentJanitor:Add(editorHandler, "Destroy")
	editorHandler:initItems(WallStats, WallObjs)
	
	local pickerHandler = ColourPicker.new()
	CurrentJanitor:Add(pickerHandler, "Destroy")
	pickerHandler:init(Player.PlayerGui.Editor.Frame.List.Picker.Base, Player.PlayerGui.Editor.Frame.List.Picker.Base)

	local cfVal = Instance.new("CFrameValue")
	CurrentJanitor:Add(cfVal, "Destroy")
	
	if UserInputService.TouchEnabled then
		-- UiShowHide:tweenMenu("EditorRotateUi", "open")
		-- UiShowHide:tweenMenu("EditorPlaceUi", "open")
		-- UiShowHide:tweenMenu("EditorCancelUi", "open")
	else
		UiShowHide:tweenMenu("EditorControlsUi", "open")
	end

	CurrentJanitor:Add(UiShowHide.tweened:Connect(function(ui, state)
		if ui == "EditorUiWPicker" and state == "close" then
			module:off()
		end
	end), "Disconnect")

	local lastItem
	local function loadItem(itemName, overrideColour)
		-- UiShowHide:tweenMenu("MoneyBuyUi", "close")
		local wallStat = WallStats[itemName]
		Player.PlayerGui.Editor.MoneyAmount.DescLabel.Text = itemName .. " $" .. TextLoader:ConvertShort(wallStat.price)
		if wallStat.price > Status.data.money then
			Player.PlayerGui.Editor.MoneyAmount.DescLabel.TextColor3 = Color3.fromRGB(255, 80, 80)
		else
			Player.PlayerGui.Editor.MoneyAmount.DescLabel.TextColor3 = Color3.fromRGB(0, 179, 255)
		end
		lastItem = itemName
		if editorHandler.deleting then
			editorHandler:toggleDelete(itemName)
		end
		if editorHandler.selecting then
			editorHandler:toggleSelect(itemName)
		end
		local obj = WallObjs[itemName]:Clone()
		colourModel(obj, overrideColour or pickerHandler.cp.c3)
		for _, obj in pairs(obj:GetDescendants()) do
			if obj:IsA("BasePart") or obj:IsA("Decal") or obj:IsA("Texture") then
				obj.Transparency = 1 - (1 - obj.Transparency)/2
				if obj:IsA("BasePart") then
					obj.CanCollide = false
				elseif obj:IsA("ProximityPrompt") then
					obj.Enabled = false
				end
			end
		end
		CurrentJanitor:Add(obj, "Destroy", "Selecting")
		--currentlySelecting = obj
		CurrentJanitor:Add(cfVal:GetPropertyChangedSignal("Value"):Connect(function()
			if obj.PrimaryPart then
				obj:SetPrimaryPartCFrame(cfVal.Value)
			else
				if RunService:IsStudio() then
					warn("missing primary part for wall obj", obj)
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
			for _, obj in pairs(Resources:GetBuildItem("Wall")[itemName]:GetDescendants()) do
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
	
	editorHandler.deletingEvent:Connect(function(deleting)
		if deleting then
			
		else
			DeleteSelectionObj.Adornee = nil
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

	local plot = workspace.Game.PlayerPlots:FindFirstChild(tostring(Status.game.plotNo)).Plot
	local lastSelectingiPos
	local lastSelectingPos
	local deletingTarget
	local selectingTarget
	local rot = 1

	local function place()
		if editorHandler.itemPicked and lastSelectingiPos then
			local wallStat = WallStats[editorHandler.itemPicked]
			if wallStat.price > Status.data.money then
				Notify:addItem("Issue", 3, nil, string.format("Cannot build! You need $%s more money to buy a %s!", TextLoader:ConvertShort(wallStat.price - Status.data.money), editorHandler.itemPicked))
				AudioHandler:playAudio("Error")
				-- ShopUi:updatePage("Money")
				-- BindUiOpenClose.binds.Shop.sigs.open:Fire()
				UiShowHide:tweenMenu("MoneyBuyUi", "open")
				spawn(function()
					wait(4)
					UiShowHide:tweenMenu("MoneyBuyUi", "close")
				end)
			else
				local v2 = VectorTable.rconvert(lastSelectingiPos)
				local region
				if rot == 1 or rot == 3 then
					local origin = Vector3.new(0, 8, 24)
					local v3 = -Vector3.new(v2.X * 16, 0, v2.Y * 16) + origin
					--Instance.new("Part", workspace).Position = v3
					region = Region3.new(
						v3 - Vector3.new(0.5, 16, 16)/2,
						v3 + Vector3.new(0.5, 16, 16)/2
					)
				else
					local origin = Vector3.new(8, 8, 32)
					local v3 = -Vector3.new(v2.X * 16, 0, v2.Y * 16) + origin
					--Instance.new("Part", workspace).Position = v3
					region = Region3.new(
						v3 - Vector3.new(16, 16, 0.5)/2,
						v3 + Vector3.new(16, 16, 0.5)/2
					)
				end
				local collectedParts = workspace:FindPartsInRegion3WithWhiteList(region, {workspace.Players, plot.Parent.Items}, 100)
				-- print("collected", collectedParts)
				local inTheWay = false
				for _, part in pairs(collectedParts) do
					if part.Parent.Name == "Radio" then continue end
					if part.Name ~= "CollisionBox" then continue end
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

				Resources:GetRemote("BuildWall"):FireServer(editorHandler.itemPicked, lastSelectingiPos, rot, pickerHandler.cp.c3)
				cfVal.Value = CFrame.new(0, -100, 0)
				lastSelectingiPos = nil
				editorHandler:pickItem(editorHandler.itemPicked, WallStats[editorHandler.itemPicked])
				AudioHandler:playAudio("Pop")
			end
		end
	end

	local function updatePlacing(ignoreNewPos)
		--if not currentlySelecting then return end
		if not editorHandler.itemPicked then return end
		local raycastP = RaycastParams.new()
		raycastP.FilterType = Enum.RaycastFilterType.Whitelist
		raycastP.FilterDescendantsInstances = {plot.Parent.Grid}
		local hit = WorkspaceMouse:getHit(300, raycastP)
		if ignoreNewPos then
			hit = Vector3.new(lastSelectingPos.X, 0, lastSelectingPos.Y)
		end
		if not hit then
			-- if ignoreNewPos then
			-- 	hit = Vector3.new(lastSelectingPos.X, 0, lastSelectingPos.Y)
			-- else
				return
			-- end
		end
		--local hitOnPlot = hit + plot["0:0"].Mid.Position
		local offsetX
		local offsetZ
		if rot == 1 or rot == 3 then
			offsetX = plot["0:0"].Mid.Position.X % 16
			offsetZ = plot["0:0"].Mid.Position.Z % 16 + 8
		else
			offsetX = plot["0:0"].Mid.Position.X % 16 + 8
			offsetZ = plot["0:0"].Mid.Position.Z % 16
		end
		local pos = Vector2.new(Round((hit.X - offsetX)/16) * 16 + offsetX, Round(((hit.Z - 3) - offsetZ)/16) * 16 + offsetZ)
		local x = math.clamp(pos.X, plot.Parent.Grid.Position.X - plot.Parent.Grid.Size.X/2, plot.Parent.Grid.Position.X + plot.Parent.Grid.Size.X/2);
		local y = math.clamp(pos.Y, plot.Parent.Grid.Position.Z - plot.Parent.Grid.Size.Z/2, plot.Parent.Grid.Position.Z + plot.Parent.Grid.Size.Z/2);
		pos = Vector2.new(x, y)
		local iPos
		if rot == 1 or rot == 3 then
			iPos = VectorTable.convert(Vector2.new(-Round((pos.X - plot["0:0"].Mid.Position.X)/16), -Round((pos.Y - plot["0:0"].Mid.Position.Z)/16) + 2))
			if Status.data.build1.walls.v[iPos] then return end
		else
			iPos = VectorTable.convert(Vector2.new(-Round((pos.X - plot["0:0"].Mid.Position.X)/16) + 1, -Round((pos.Y - plot["0:0"].Mid.Position.Z)/16) + 2))
			if Status.data.build1.walls.h[iPos] then return end	
		end
		if iPos ~= lastSelectingiPos then
			if rot == 1 or rot == 3 then
				if not CheckiPosLegalV(Status.data.build1.plots, iPos) then return end
			else
				if not CheckiPosLegalH(Status.data.build1.plots, iPos) then return end
			end
			-- if ignoreNewPos then
			-- 	iPos = lastSelectingiPos and lastSelectingiPos or iPos
			-- 	pos = lastSelectingPos and lastSelectingPos or pos
			-- else
			lastSelectingiPos = iPos
			lastSelectingPos = pos
			-- end
			if pos.X == 0 then pos = Vector2.new(0.0000000001, pos.Y) end
			local v3Base = Vector3.new(pos.X, plot["0:0"].Mid.Position.Y + 8, pos.Y)
			local cfRot = CFrame.Angles(0, math.rad(90 * rot - 90), 0)
			local lastPos = cfVal.Value.p
			local direction = CFrame.new(lastPos, v3Base).LookVector.Unit
			if (lastPos - v3Base).Magnitude < 1 then direction = Vector3.new(0, 0, 0) end
			local cf1 = CFrame.new(v3Base) * cfRot * CFrame.Angles(math.rad(direction.Z * 10), 0, math.rad(-direction.X * 10)) * CFrame.new(0, 4, 0)
			local cf2 = CFrame.new(v3Base) * cfRot
			-- if not ignoreNewPos then
				if (not (cf1.p.X > 0)) and (not (cf1.p.X < 0)) then return end
			-- end
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
			m1Pressed = not UserInputService.TouchEnabled and m1Pressed
			if iPos and m1Pressed then
				place()
			end
		else
			return
		end
	end
	CurrentJanitor:Add(UserInputService.InputChanged:Connect(function(input, proc)
		if proc then return end
		if not editorHandler.deleting and not editorHandler.selecting then
			updatePlacing()
		elseif editorHandler.selecting then
			local raycastP = RaycastParams.new()
			raycastP.FilterType = Enum.RaycastFilterType.Whitelist
			raycastP.FilterDescendantsInstances = {plot.Parent.HWalls, plot.Parent.VWalls}
			local target = WorkspaceMouse:getTarget(300, raycastP)
			local function quit()
				SelectSelectionObj.Adornee = nil
			end
			if target then
				local parentModel = target
				for i = 1, 10 do
					if not parentModel then break end
					local tempParentModel = parentModel:FindFirstAncestorWhichIsA("Model")
					parentModel = tempParentModel
					if tempParentModel.Parent == plot.Parent.VWalls or tempParentModel.Parent == plot.Parent.HWalls then
						break
					end
					if i == 10 then quit() return end
				end
				if parentModel.Parent ~= plot.Parent.VWalls and parentModel.Parent ~= plot.Parent.HWalls then return end
				if not parentModel then quit() return end
				SelectSelectionObj.Adornee = parentModel
				selectingTarget = parentModel
			else
				quit()
				return
			end
		-- elseif editorHandler.deleting then
		-- 	local raycastP = RaycastParams.new()
		-- 	raycastP.FilterType = Enum.RaycastFilterType.Whitelist
		-- 	raycastP.FilterDescendantsInstances = {plot.Parent.HWalls, plot.Parent.VWalls}
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
		-- 			if tempParentModel.Parent == plot.Parent.HWalls or tempParentModel.Parent == plot.Parent.VWalls then
		-- 				break
		-- 			end
		-- 			if i == 10 then quit() return end
		-- 		end
		-- 		if parentModel.Parent ~= plot.Parent.HWalls and parentModel.Parent ~= plot.Parent.VWalls then return end
		-- 		if not parentModel then quit() return end
		-- 		DeleteSelectionObj.Adornee = parentModel
		-- 		deletingTarget = parentModel
		-- 	else
		-- 		quit()
		-- 		return
		-- 	end
		end
	end), "Disconnect")
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
				lastSelectingiPos = nil
				updatePlacing()
			elseif input.KeyCode == Enum.KeyCode.X then
				Player.PlayerGui.Editor.Close:Fire()
			end
		elseif input.UserInputType == Enum.UserInputType.Touch then
			updatePlacing()
		elseif input.UserInputType == Enum.UserInputType.MouseButton1 then
			proceedPlacing()
		end
	end), "Disconnect")
	CurrentJanitor:Add(Player.PlayerGui.Editor.Place.Base.Frame.MouseButton1Click:Connect(function()
		proceedPlacing()
	end), "Disconnect")
	CurrentJanitor:Add(Player.PlayerGui.Editor.Cancel.Base.Frame.MouseButton1Click:Connect(function()
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
		plot.Parent.Grids[plotPos].Texture.StudsPerTileU = 16
		plot.Parent.Grids[plotPos].Texture.StudsPerTileV = 16
	end
end

function module:off()
	if not CurrentJanitor then return end
	CurrentJanitor:Cleanup()
	CurrentJanitor = nil
	
	CeilingHideShow:show()
	
	DeleteSelectionObj.Adornee = nil
	SelectSelectionObj.Adornee = nil

	UiShowHide:tweenMenu("EditorControlsUi", "close")
	UiShowHide:tweenMenu("EditorRotateUi", "close")
	UiShowHide:tweenMenu("EditorPlaceUi", "close")
	UiShowHide:tweenMenu("EditorMoneyAmountUi", "close")
	UiShowHide:tweenMenu("EditorCancelUi", "close")

	local plot = workspace.Game.PlayerPlots:FindFirstChild(tostring(Status.game.plotNo)).Plot
	--plot.Parent.Grid.Texture.Transparency = 1
	for _, plotObj in pairs(plot.Parent.Grids:GetChildren()) do
		plotObj.Texture.Transparency = 1
	end
end

return module
