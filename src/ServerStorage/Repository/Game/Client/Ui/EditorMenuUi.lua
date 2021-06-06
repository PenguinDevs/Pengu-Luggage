local module = {}

module.uiShowHide = nil

local Player = game.Players.LocalPlayer

local Resources = require(game.ReplicatedStorage.Resources)
local Signal = Resources:LoadLibrary("Signal")
local Janitor = Resources:LoadLibrary("Janitor")
local TextLoader = Resources:LoadLibrary("TextLoader")
local Status = Resources:LoadLibrary("Status")
--local Mouse = Player:GetMouse()
local UserInputService = game:GetService("UserInputService")
local CopyTable = Resources:LoadLibrary("CopyTable")
local Notify = Resources:LoadLibrary("NotifyHandler")
local ItemTypes = Resources:LoadLibrary("ItemTypes")
local WorkspaceMouse = Resources:LoadLibrary("WorkspaceMouse")
local Mouse = Player:GetMouse()
local TutorialHandler = Resources:LoadLibrary("TutorialHandler")
local MarketplaceService = game:GetService("MarketplaceService")
local GamepassStats = Resources:LoadLibrary("GamepassStats")
local GetCustomerAmount = Resources:LoadLibrary("GetCustomerAmount")
local GameSettings = Resources:LoadLibrary("GameSettings")
local Round = Resources:LoadLibrary("Round")

local DeleteSelectionObj = Instance.new("SelectionBox", workspace)
DeleteSelectionObj.SurfaceTransparency = 0.5
DeleteSelectionObj.Transparency = 0.5
DeleteSelectionObj.Color3 = Color3.fromRGB(255, 84, 84)
DeleteSelectionObj.SurfaceColor3 = Color3.fromRGB(255, 0, 0)

local EditorUi = Player.PlayerGui.Editor.Frame

local CurrentHandler

local SlotCache = {}
local ItemObjCache = {}

function module.new()
	if CurrentHandler then
		CurrentHandler:Destroy()
		CurrentHandler = nil
	end
	
	local plot = workspace.Game.PlayerPlots:FindFirstChild(tostring(Status.game.plotNo)).Plot

	local handler = {}
	CurrentHandler = handler
	handler.janitor = Janitor.new()
	handler.slotUis = {}
	handler.slotUisAmount = 0
	handler.slotUisOrder = {}
	handler.allow = true
	handler.objs = {}
	function handler:Destroy()
		handler.janitor:Cleanup()
		for _, slotUi in pairs(handler.slotUis) do
			table.insert(SlotCache, 1, slotUi)
			slotUi.Parent = game
		end
		for i, obj in pairs(handler.objs) do
			ItemObjCache[i] = obj
			obj.Parent = game
		end
		handler = nil
		CurrentHandler = nil
	end
	
	handler.itemPickedEvent = Signal.new()
	handler.janitor:Add(handler.itemPickedEvent, "Destroy")
	handler.itemPicked = nil
	
	handler.deletingEvent = Signal.new()
	handler.janitor:Add(handler.deletingEvent, "Destroy")
	handler.deleting = false

	handler.deletingTarget = nil

	handler.selectingEvent = Signal.new()
	handler.janitor:Add(handler.selectingEvent, "Destroy")
	handler.selecting = false

	handler.cancelEvent = Signal.new()
	handler.janitor:Add(handler.cancelEvent, "Destroy")
	
	handler.itemList = nil
	handler.itemAmount = 0
	
	handler.itemTypeViewing = nil

	function handler:updateItemFilters()
		for _, filterUi in pairs(Player.PlayerGui.Editor.Frame.List.Filter:GetChildren()) do
			if not filterUi:IsA("GuiObject") then continue end
			if Status.data.settings.dark then
				if handler.itemTypeViewing == filterUi.Name then
					filterUi.Base.BackgroundColor3 = Color3.fromRGB(85, 85, 85)
				else
					filterUi.Base.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
				end
			else
				if handler.itemTypeViewing == filterUi.Name then
					filterUi.Base.BackgroundColor3 = Color3.fromRGB(201, 201, 201)
				else
					filterUi.Base.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
				end
			end
		end
	end

	for _, filterUi in pairs(Player.PlayerGui.Editor.Frame.List.Filter:GetChildren()) do
		if not filterUi:IsA("GuiObject") then continue end
		local itemTypeStat = ItemTypes[filterUi.Name]
		filterUi.Base.Frame.ImageLabel.Image = itemTypeStat.image
		filterUi.Base.Frame.ImageLabel.ImageColor3 = itemTypeStat.colour
		filterUi.Base.Frame.TextLabel.TextColor3 = itemTypeStat.colour
		filterUi.Base.Frame.TextLabel.Text = string.upper(string.sub(filterUi.Name, 1, 1)) .. string.sub(filterUi.Name, 2)
		filterUi.Visible = false

		handler.janitor:Add(filterUi.Base.Frame.MouseButton1Click:Connect(function()
			if TutorialHandler.doingTutorial then
				Notify:addItem("Issue", 3, nil, "Please follow the tutorial! Don't try and mess around 😒")
				return
			end
			if handler.itemTypeViewing == filterUi.Name then
				handler.itemTypeViewing = nil
			else
				handler.itemTypeViewing = filterUi.Name
			end
			handler:updateItemFilters()
			handler:pickItem()
		end), "Disconnect")
	end
	handler:updateItemFilters()

	local scrollPos = 1
	local function scroll(dir)
		scrollPos += dir
		if scrollPos > handler.itemAmount then scrollPos = 1 end
		if scrollPos < 0 then scrollPos = handler.itemAmount end
		local startPos = UDim2.fromScale(-0.06, 1)
		local endPos = UDim2.fromScale(1.06, 1)
		for i, slotUi in pairs(handler.slotUisOrder) do
			local pos = (i - 1) + (scrollPos - 1) - 1
			if pos == -1 then slotUi.Visible = false end
			if pos == 18 then slotUi.Visible = false end
			if pos > 17 then
				pos = pos - 18
			elseif pos < -1 then
				pos = 18 + pos
			end
			local targetPos = UDim2.fromScale(0.06 * (pos - 1), 1)
			slotUi:TweenPosition(targetPos, Enum.EasingDirection.Out, Enum.EasingStyle.Sine, 0.1, true, function()
				slotUi.Visible = true
			end)
			slotUi.DEB.Text = pos
		end
	end
	
	function handler:initItems(itemList, itemObjs)
		handler.itemList = itemList
		local i = 0
		
		local sorted = {}
		for itemName, item in pairs(itemList) do
			--local copy = CopyTable:DeepCopy(item)
			item.name = itemName
			table.insert(sorted, 1, item)
		end
		local indexList = {
			["fish"] = 1;
			["food"] = 2;
			["drink"] = 3;
			["toilet"] = 4;
			["fun"] = 5;
			["seat"] = 6;
		}
		local passList = {
			["none"] = 1;
			["VIP"] = 2;
		}
		table.sort(sorted, function(a, b)
			local aPass = passList[a.reqPass or "none"] or 5
			local bPass = passList[b.reqPass or "none"] or 5

			-- print(aPass, bPass, a.reqPass, b.reqPass)

			if aPass ~= bPass then
				return aPass < bPass
			end

			local aType = indexList[a.itemType] or 100
			local bType = indexList[b.itemType] or 100
			if aType ~= bType then
				return aType < bType
			end

			if a.price ~= b.price then
				return a.price < b.price
			end

			for i = 1, #a.name do
				if not string.sub(b.name, i, i) then return a end
				if string.sub(a.name, i, i) == string.sub(b.name, i, i) then continue end
				if string.sub(a.name, i, i) > string.sub(b.name, i, i) then
					return false
				else
					return true
				end
			end
			return false
		end)
		-- local firstItem = sorted[1]
		-- table.remove(sorted, 1)
		-- table.insert(sorted, #sorted + 1, firstItem)

		for i, item in pairs(sorted) do
			handler.itemAmount += 1
			i += 1
			local slotUi
			if #SlotCache > 0 then
				slotUi = SlotCache[1]
				table.remove(SlotCache, 1)
			else
				slotUi = Player.PlayerGui.Editor.Frame.List.Menu.Cache.TEMP:Clone()
				local camera = Instance.new("Camera", slotUi.Base.View)
				slotUi.Base.View.CurrentCamera = camera
			end
			slotUi.Name = string.rep(".", handler.slotUisAmount + 1)
			if ItemTypes[item.itemType] then
				slotUi.Base.IconType.Image = ItemTypes[item.itemType].image
				slotUi.Base.IconType.ImageColor3 = ItemTypes[item.itemType].colour
				slotUi.Base.IconType.Visible = true

				Player.PlayerGui.Editor.Frame.List.Filter:FindFirstChild(item.itemType).Visible = true
			else
				slotUi.Base.IconType.Visible = false
			end

			-- if item.reqPass == "VIP" then
			-- 	slotUi.Base.VIP.Visible = true
			-- 	slotUi.Base.BackgroundColor3 = Color3.fromRGB(249, 253, 0)
			-- else
			-- 	slotUi.Base.VIP.Visible = false
			-- 	slotUi.Base.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
			-- end
			--table.insert(handler.slotUis, 1, slotUi)
			handler.slotUis[item.name] = slotUi
			handler.slotUisAmount += 1
			table.insert(handler.slotUisOrder, 1, slotUi)
			slotUi.Position = UDim2.fromScale(0.062 * (i - 1), 1)
			
			local camera = slotUi.Base.View.Camera
			
			handler.janitor:Add(slotUi.MouseButton1Click:Connect(function()
				if handler.allow then
					if item.name == handler.itemPicked then
						handler.cancelEvent:Fire()
						return
					end

					if item.reqPass then
						if Status.passes[item.reqPass] then
							handler:pickItem(item.name, item, true)
						else
							local gamepassStat = GamepassStats[item.reqPass]
							MarketplaceService:PromptGamePassPurchase(Player, gamepassStat.id)
							return
						end
					else
						handler:pickItem(item.name, item, true)
					end
				end
			end), "Disconnect")
			
			local obj
			if not itemObjs:FindFirstChild(item.name) then
				warn("Cannot find", item.name, "in editor menu ui")
				continue
			end
			if ItemObjCache[itemObjs[item.name]] then
				obj = ItemObjCache[itemObjs[item.name]]
			else
				obj = itemObjs[item.name]:Clone()
			end
			--table.insert(handler.objs, 1, obj)
			handler.objs[itemObjs[item.name]] = obj
			--handler.janitor:Add(obj, "Destroy")
			obj.Parent = slotUi.Base.View
			if not obj.PrimaryPart then warn("No primary part for", item.name) continue end
			obj:SetPrimaryPartCFrame(CFrame.new(0, 0, 0))
			local objCF, objSize = obj:GetBoundingBox()
			local dist = objSize.Magnitude/2
			camera.CFrame = CFrame.new(Vector3.new(dist, dist, -dist), objCF.p)
			
			slotUi.Base.PriceLabel.Text = "$" .. TextLoader:ConvertShort(item.price)
			
			slotUi.Parent = Player.PlayerGui.Editor.Frame.List.Menu
			slotUi.Visible = true

			--handler:pickItem()
		end
		
		--print(handler.itemAmount, handler.slotUisOrder)
		
		handler.janitor:Add(function()
			DeleteSelectionObj.Adornee = nil
			module.uiShowHide:tweenMenu("DeleteNotifyUi", "close")
		end)

		if handler.itemAmount > 16 and false then
			--local hovering = false
			--handler.janitor:Add(Player.PlayerGui.Editor.Frame.List.Hovering.MouseEnter:Connect(function()
			--	hovering = true
			--end), "Disconnect")
			--handler.janitor:Add(Player.PlayerGui.Editor.Frame.List.Hovering.MouseLeave:Connect(function()
			--	hovering = false
			--end), "Disconnect")
			
			local function hovering()
				if UserInputService:GetMouseLocation().Y > Player.PlayerGui.Editor.Frame.List.AbsolutePosition.Y then
					return true
				else
					return false
				end
			end
			
			--handler.janitor:Add(Mouse.WheelForward:Connect(function()
			--	if hovering() then
			--		scroll(1)
			--	end
			--end), "Disconnect")
			--handler.janitor:Add(Mouse.WheelBackward:Connect(function()
			--	if hovering() then
			--		scroll(-1)
			--	end
			--end), "Disconnect")
			handler.janitor:Add(UserInputService.InputChanged:Connect(function(input, proc)
				if proc then return end
				if input.UserInputType == Enum.UserInputType.MouseWheel and hovering() then
					scroll(input.Position.Z)
				end
			end), "Disconnect")
		else
			-- local uiPageLayout = Player.PlayerGui.Editor.Frame.List.Menu.UIPageLayout
			-- uiPageLayout.Parent = nil
			-- wait()
			-- uiPageLayout.Parent = Player.PlayerGui.Editor.Frame.List.Menu
		end

		handler:pickItem()
	end

	local function updateOnMovement()
		if handler.deleting then
			local raycastP = RaycastParams.new()
			raycastP.FilterType = Enum.RaycastFilterType.Whitelist
			raycastP.FilterDescendantsInstances = {plot.Parent.HWalls, plot.Parent.VWalls, plot.Parent.Floors, plot.Parent.Items}
			local target = WorkspaceMouse:getTarget(300, raycastP)
			local function quit()
				DeleteSelectionObj.Adornee = nil
			end
			if target then
				local parentModel = target
				for i = 1, 10 do
					if not parentModel then break end
					local tempParentModel = parentModel:FindFirstAncestorWhichIsA("Model")
					parentModel = tempParentModel
					if tempParentModel.Parent == plot.Parent.HWalls
					or tempParentModel.Parent == plot.Parent.VWalls
					or tempParentModel.Parent == plot.Parent.Items
					or tempParentModel.Parent == plot.Parent.Floors
					then
						break
					end
					if i == 10 then quit() return end
				end
				if parentModel.Parent ~= plot.Parent.HWalls
				and parentModel.Parent ~= plot.Parent.VWalls
				and parentModel.Parent ~= plot.Parent.Items
				and parentModel.Parent ~= plot.Parent.Floors
				then
					return
				end
				if not parentModel then quit() return end
				DeleteSelectionObj.Adornee = parentModel
				handler.deletingTarget = parentModel
			else
				quit()
				return
			end
		end
		if not handler.deleting then
			DeleteSelectionObj.Adornee = nil
		end
	end

	handler.janitor:Add(UserInputService.InputChanged:Connect(function(input, proc)
		if proc then return end
		if input.UserInputType == Enum.UserInputType.MouseMovement then
			updateOnMovement()
		end
	end), "Disconnect")
	handler.janitor:Add(UserInputService.TouchTap:Connect(function(touchPositions, proc)
		if proc then return end
		updateOnMovement()
	end), "Disconnect")
	
	local function performDelete()
		if handler.deleting then
			if handler.deletingTarget then
				if handler.deletingTarget.Parent == plot.Parent.Items then
					Resources:GetRemote("DestroyItem"):FireServer(handler.deletingTarget.Name)
				elseif handler.deletingTarget.Parent == plot.Parent.Floors then
					Resources:GetRemote("DestroyFloor"):FireServer(handler.deletingTarget.Name)
				elseif handler.deletingTarget.Parent == plot.Parent.HWalls or handler.deletingTarget.Parent == plot.Parent.VWalls then
					Resources:GetRemote("DestroyWall"):FireServer(handler.deletingTarget.Name, handler.deletingTarget.Parent)
				else
					warn("No parent for", handler.deletingTarget.Parent, "when deleting")
				end
				DeleteSelectionObj.Adornee = nil
			end
		end
	end
	handler.janitor:Add(Mouse.Button1Down:Connect(function()
		if UserInputService.TouchEnabled then return end
		performDelete()
	end), "Disconnect")
	handler.janitor:Add(Player.PlayerGui.Editor.Delete.Base.Frame.MouseButton1Click:Connect(function()
		performDelete()
	end), "Disconnect")

	function handler:pickItem(itemName, item, autoColour)
		if itemName then
			handler.itemPicked = itemName
			handler.itemPickedEvent:Fire(handler.itemPicked, autoColour)
		end
		if not itemName and not item then
			itemName = handler.itemPicked
			if handler.itemList then
				item = handler.itemList[itemName]
			end
		elseif not item and itemName then
			if handler.itemList then
				item = handler.itemList[itemName]
			end
		end
		if handler.itemPicked then
			EditorUi.List.Selecting.Base.Frame.InfoLabel.Text = handler.itemPicked
			if item.fishHold then
				-- local customersAmount, lastDiv = GetCustomerAmount(Status.data.build1)
				-- local customersAmountTank, lastDivTank = GetCustomerAmount(Status.data.build1, item.price)
				-- local attraction = lastDivTank/GameSettings.tankNeededPerCustomer - lastDiv/GameSettings.tankNeededPerCustomer
				-- print(lastDivTank/GameSettings.tankNeededPerCustomer, lastDiv/GameSettings.tankNeededPerCustomer)
				-- if attraction < 0 then attraction *= -1 end
				-- attraction = tostring(Round(attraction * 100)/100)
				local attraction = TextLoader:ConvertShort(item.price/50)
				EditorUi.List.Selecting.Base.Frame.InfoLabel.Text = string.format("%s\nCapacity: %s\nAttraction: +%s", handler.itemPicked, item.fishHold, attraction)
			end
			EditorUi.List.Selecting.Base.Frame.PriceLabel.Text = "$" .. TextLoader:ConvertShort(item.price)
			if item.price > Status.data.money then
				EditorUi.List.Selecting.Base.Frame.PriceLabel.TextColor3 = Color3.fromRGB(255, 73, 73)
			else
				EditorUi.List.Selecting.Base.Frame.PriceLabel.TextColor3 = Color3.fromRGB(95, 235, 132)
			end
		else
			if handler.deleting then
				EditorUi.List.Selecting.Base.Frame.InfoLabel.Text = "Click on an item to delete"
				EditorUi.List.Selecting.Base.Frame.PriceLabel.Text = ""
			else
				EditorUi.List.Selecting.Base.Frame.InfoLabel.Text = "Click on an item to begin placing"
				EditorUi.List.Selecting.Base.Frame.PriceLabel.Text = "-"
			end
		end
		local itemAmount = 0
		local absoluteSizeX = 0
		for itemName, slotUi in pairs(handler.slotUis) do
			local item = handler.itemList[itemName]
			if itemName == handler.itemPicked then
				if slotUi:IsDescendantOf(game) then
					slotUi:TweenSize(UDim2.new(0.1, 0, 1.1, -8), Enum.EasingDirection.InOut, Enum.EasingStyle.Quint, 0.2, true)
				end
				if Status.data.settings.dark then
					slotUi.Base.BackgroundColor3 = Color3.fromRGB(85, 85, 85)
				else
					slotUi.Base.BackgroundColor3 = Color3.fromRGB(201, 201, 201)
				end
			else
				if slotUi:IsDescendantOf(game) then
					slotUi:TweenSize(UDim2.new(0.1, 0, 1, -8), Enum.EasingDirection.InOut, Enum.EasingStyle.Quint, 0.2, true)
				end
				if Status.data.settings.dark then
					slotUi.Base.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
				else
					slotUi.Base.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
				end
			end

			if item.price > Status.data.money then
				slotUi.Base.BackgroundColor3 = Color3.fromRGB(255, 73, 73)
				slotUi.Base.Bank.Visible = true
			else
				if item.reqPass then
					slotUi.Base.Pass.Visible = true
					local gamepassStat = GamepassStats[item.reqPass]
					slotUi.Base.Pass.Image = gamepassStat.icon
					slotUi.Base.BackgroundColor3 = gamepassStat.colour
				else
					slotUi.Base.Pass.Visible = false
					if Status.data.settings.dark then
						slotUi.Base.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
					else
						slotUi.Base.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
					end
				end
			end

			local function isVis()
				itemAmount += 1
				absoluteSizeX = slotUi.AbsoluteSize.X
			end
			if handler.itemTypeViewing then
				if handler.itemTypeViewing == item.itemType then
					slotUi.Visible = true
					isVis()
				else
					slotUi.Visible = false
				end
			else
				slotUi.Visible = true
				isVis()
			end
		end

		EditorUi.List.Menu.CanvasSize = UDim2.fromOffset((4 + absoluteSizeX) * itemAmount, 0)
		--EditorUi.List.Menu.CanvasSize = UDim2.fromScale(itemAmount * 0.063, 0)
	end
	
	function handler:updateDelete()
		if handler.deleting then
			Player.PlayerGui.Editor.Frame.List.Delete.Base.Frame.Yes.Visible = false
			Player.PlayerGui.Editor.Frame.List.Delete.Base.Frame.No.Visible = true
		else
			Player.PlayerGui.Editor.Frame.List.Delete.Base.Frame.Yes.Visible = true
			Player.PlayerGui.Editor.Frame.List.Delete.Base.Frame.No.Visible = false
		end
	end
	handler:updateDelete()
	
	function handler:toggleDelete(v1)
		handler.cancelEvent:Fire()
		if TutorialHandler.doingTutorial then
			Notify:addItem("Issue", 3, nil, "Please follow the tutorial! Don't try and mess around 😒")
			return
		end
		if handler.selecting then
			handler:toggleSelect()
		end
		handler.deleting = not handler.deleting
		handler.deletingEvent:Fire(handler.deleting)
		handler.itemPicked = nil
		if handler.deleting then
			handler:pickItem()
			module.uiShowHide:tweenMenu("DeleteNotifyUi", "open")

			if UserInputService.TouchEnabled then
				module.uiShowHide:tweenMenu("EditorPlaceUi", "close")
				module.uiShowHide:tweenMenu("EditorMoneyAmountUi", "close")
				module.uiShowHide:tweenMenu("EditorCancelUi", "close")
				module.uiShowHide:tweenMenu("EditorRotateUi", "close")
				module.uiShowHide:tweenMenu("EditorDeleteUi2", "open")
				module.uiShowHide:tweenMenu("EditorBaseHideUi", "close")
				module.uiShowHide:tweenMenu("EditorFilterUi", "close")
			end
		else
			handler.itemPicked = handler.itemPicked or v1
			DeleteSelectionObj.Adornee = nil
			module.uiShowHide:tweenMenu("DeleteNotifyUi", "close")

			if UserInputService.TouchEnabled then
				-- module.uiShowHide:tweenMenu("EditorPlaceUi", "open")
				-- module.uiShowHide:tweenMenu("EditorCancelUi", "open")
				-- module.uiShowHide:tweenMenu("EditorRotateUi", "open")
				module.uiShowHide:tweenMenu("EditorDeleteUi2", "close")
				module.uiShowHide:tweenMenu("EditorBaseHideUi", "open")
				module.uiShowHide:tweenMenu("EditorFilterUi", "open")
			end
		end
		handler:updateDelete()
	end
	handler.janitor:Add(Player.PlayerGui.Editor.Frame.List.Delete.Base.Frame.MouseButton1Click:Connect(handler.toggleDelete), "Disconnect")
	
	handler.janitor:Add(function()
		module.uiShowHide:tweenMenu("EditorDeleteUi2", "close")
	end)

	handler.janitor:Add(Player.PlayerGui.Editor.DeleteNotify.Base.Cancel.Base.Frame.MouseButton1Click:Connect(function()
		module.uiShowHide:tweenMenu("DeleteNotifyUi", "close")
		handler:toggleDelete()
	end), "Disconnect")

	function handler:toggleSelect(v1)
		if handler.deleting then
			handler:toggleDelete()
		end
		handler.selecting = not handler.selecting
		handler.selectingEvent:Fire(handler.selecting)
		handler.itemPicked = nil
		if handler.selecting then
			handler:pickItem()
		else
			handler.itemPicked = handler.itemPicked or v1
			handler:pickItem()
		end
	end
	handler.janitor:Add(Player.PlayerGui.Editor.Frame.List.Picker.Base.Picker.MouseButton1Click:Connect(handler.toggleSelect), "Disconnect")
	
	handler.cancelEvent:Connect(function()
		handler.itemPicked = nil
		handler:pickItem()
	end)

	return handler
end

function module:updateSlots()
	if CurrentHandler then
		CurrentHandler:pickItem(CurrentHandler.itemPicked, CurrentHandler.itemList[CurrentHandler.itemPicked])
	end
end

return module
