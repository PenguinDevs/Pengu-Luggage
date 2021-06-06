local module = {}

local Resources = require(game.ReplicatedStorage.Resources)
local Status = Resources:LoadLibrary("Status")
local WorkspaceMouse = Resources:LoadLibrary("WorkspaceMouse")
local UserInputService = game:GetService("UserInputService")
local Janitor = Resources:LoadLibrary("Janitor")
local Tween = Resources:LoadLibrary("Tween")
local Enumeration = Resources:LoadLibrary("Enumeration")
local UiShowHide = Resources:LoadLibrary("UiShowHide")
local Player = game.Players.LocalPlayer
local Mouse = Player:GetMouse()
local TextLoader = Resources:LoadLibrary("TextLoader")
local Notify = Resources:LoadLibrary("NotifyHandler")
local Camera = workspace.CurrentCamera
-- local ShopUi = Resources:LoadLibrary("ShopUi")
-- local BindUiOpenClose = Resources:LoadLibrary("BindUiOpenClose")
local MarketplaceService = game:GetService("MarketplaceService")
local ProductStats = Resources:LoadLibrary("ProductStats")

local InOutSine = Enumeration.EasingFunction.InOutSine.Value

local InputJanitor
local LastPlotSelected
local Purchasing = false

function module:on()
	if InputJanitor then
		return
		--InputJanitor:Cleanup()
	end
	local plot = workspace.Game.PlayerPlots:FindFirstChild(tostring(Status.game.plotNo)).Plot
	plot.Parent.Grid.Texture.Transparency = 0.8
	plot.Parent.Grid.Texture.StudsPerTileU = 64
	plot.Parent.Grid.Texture.StudsPerTileV = 64
	Camera.CameraType = Enum.CameraType.Scriptable
	Tween(Camera, "CFrame", plot.Parent.PlotModels.PlotBuyCam.CFrame, InOutSine, 2, true)
	Tween(Camera, "FieldOfView", 90, InOutSine, 2, true)
	InputJanitor = Janitor.new()
	InputJanitor:Add(UiShowHide.tweened:Connect(function(ui, state)
		if ui == "LandUi" and state == "close" then
			module:off()
		end
	end), "Disconnect")
	local function updateMoved()
		if Purchasing then return end
		local raycastP = RaycastParams.new()
		raycastP.FilterType = Enum.RaycastFilterType.Whitelist
		raycastP.FilterDescendantsInstances = {plot.Parent.Plot}
		local target = WorkspaceMouse:getTarget(300, raycastP) -- WorkspaceMouse.LocalPlayerParams)
		local function quit()
			if LastPlotSelected then
				Tween(LastPlotSelected, "Transparency", 1, InOutSine, 0.5, true)
				LastPlotSelected = nil
			end
		end
		if target then
			if not target:IsDescendantOf(plot) then
				--print(target, target:IsDescendantOf(plot), (Status.game.plotNo), plot)
				target = nil
				quit()
				return
			else
				for i = 1, 10 do
					target = target:FindFirstAncestorWhichIsA("Model")
					if target.Parent == plot then target = target.Base break end
				end
				--if not target:IsDescendantOf(plot) then quit() return end
				if Status.data.build1.plots[target.Parent.Name] then quit() return end
			end
			if target == LastPlotSelected then
				
			else
				if LastPlotSelected then
					Tween(LastPlotSelected, "Transparency", 1, InOutSine, 0.5, true)
				end
				Tween(target, "Transparency", 0.5, InOutSine, 0.5, true)
				LastPlotSelected = target
			end
		else
			quit()
		end
	end
	InputJanitor:Add(UserInputService.InputChanged:Connect(function()
		updateMoved()
	end), "Disconnect")
	InputJanitor:Add(UserInputService.InputBegan:Connect(function(input, proc)
		if proc then return end
		if not InputJanitor then return end
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			updateMoved()
			if not Purchasing then
				if LastPlotSelected then
					module:view(LastPlotSelected)
				end
			else
				module:hide()
			end
		end
	end), "Disconnect")
	module:updatePlots()
end

local function retrieveDefaultCF()
	local playerPosition = Player.Character.HumanoidRootPart.Position
	local currentDist = 20 --Player.CameraZoomCurrentDistance
	local cameraPosition = playerPosition + Vector3.new(currentDist, currentDist, currentDist)
	-- local tempCam = Instance.new("Camera", workspace)
	-- tempCam.CameraType = Enum.CameraType.Custom
	-- tempCam.CameraSubject = Player.Character.Humanoid
	-- tempCam.CFrame = CFrame.new(cameraPosition, playerPosition)
	local cf = CFrame.new(cameraPosition, playerPosition) --tempCam.CFrame
	--tempCam:Destroy()
	return cf
end

function module:off()
	--Tween(Camera, "CFrame", retrieveDefaultCF(), InOutSine, 2, true)
	local origMin = Player.CameraMinZoomDistance
	local origMax = Player.CameraMaxZoomDistance
	Player.CameraMinZoomDistance = 20
	Player.CameraMaxZoomDistance = 20
	Player.CameraMinZoomDistance = origMin
	Player.CameraMaxZoomDistance = origMax
	local origCF = Camera.CFrame
	spawn(function()
		Tween.new(2, InOutSine, function(amount)
			Camera.CFrame = origCF:Lerp(retrieveDefaultCF(), amount)
		end):Wait()
		Camera.CameraType = Enum.CameraType.Custom
	end)
	Tween(Camera, "FieldOfView", 70, InOutSine, 2, true)
	local plot = workspace.Game.PlayerPlots:FindFirstChild(tostring(Status.game.plotNo)).Plot
	plot.Parent.Grid.Texture.Transparency = 1
	if InputJanitor then
		InputJanitor:Cleanup()
		InputJanitor = nil
	end
	module:hide()
	if LastPlotSelected then
		--Tween(LastPlotSelected, "Transparency", 1, InOutSine, 0.5, true)
		LastPlotSelected = nil
	end
	for plotPos, _ in pairs(Status.data.build1.plots) do
		Tween(plot[plotPos].Base, "Transparency", 1, InOutSine, 0.5, true)
	end
end

function module:updatePlots()
	if InputJanitor then
		local plot = workspace.Game.PlayerPlots:FindFirstChild(tostring(Status.game.plotNo)).Plot
		for plotPos, _ in pairs(Status.data.build1.plots) do
			--print(plot[plotPos], plotPos)
			Tween(plot[plotPos].Base, "Transparency", 0.2, InOutSine, 0.5, true)
		end
	end
end

function module:view(plotBaseObj)
	Purchasing = true
	Tween(plotBaseObj, "Transparency", 0.2, InOutSine, 0.3, true)
	
	local plotsOwnedNo = 0
	for _, _ in pairs(Status.data.build1.plots) do plotsOwnedNo += 1 end
	local plotPrice = Resources:LoadLibrary("PlotPrice"):getPriceFromPlotNo(plotsOwnedNo)
	local textlabel = Player.PlayerGui.BuildLand.Frame.Buy.Base.Frame.Build.Base.Frame.TextLabel
	textlabel.Text = "$" .. TextLoader:ConvertShort(plotPrice)
	if plotPrice > Status.data.money then
		textlabel.TextColor3 = Color3.fromRGB(255, 73, 73)
	else
		textlabel.TextColor3 = Color3.fromRGB(95, 235, 132)
	end
	UiShowHide:tweenMenu("LandBuyUi", "open")
end

function module:hide()
	if LastPlotSelected then
		Tween(LastPlotSelected, "Transparency", 1, InOutSine, 0.3, true)
		LastPlotSelected = nil
	end
	Purchasing = false
	UiShowHide:tweenMenu("LandBuyUi", "close")
end

Player.PlayerGui.BuildLand.Frame.Buy.Base.Frame.Build.Base.Frame.MouseButton1Click:Connect(function()
	if Purchasing then
		local plotsOwnedNo = 0
		for _, _ in pairs(Status.data.build1.plots) do plotsOwnedNo += 1 end
		local plotPrice = Resources:LoadLibrary("PlotPrice"):getPriceFromPlotNo(plotsOwnedNo)
		UiShowHide:tweenMenu("MoneyBuyUi", "close")
		if plotPrice > Status.data.money then
			Notify:addItem("Issue", 3, nil, string.format("Cannot build! You need $%s more money to buy more land", TextLoader:ConvertShort(plotPrice - Status.data.money)))
			-- ShopUi:updatePage("Money")
			-- BindUiOpenClose.binds.Shop.sigs.open:Fire()
			UiShowHide:tweenMenu("MoneyBuyUi", "open")
		else
			Resources:GetRemote("BuyPlot"):FireServer(LastPlotSelected.Parent)
			module:hide()
		end
	end
end)

Player.PlayerGui.BuildLand.Frame.Buy.Base.Frame.Robux.Base.Frame.MouseButton1Click:Connect(function()
	if Purchasing then
		UiShowHide:tweenMenu("MoneyBuyUi", "close")

		Resources:GetRemote("RobuxLand"):FireServer(LastPlotSelected.Parent)
		module:hide()
		MarketplaceService:PromptProductPurchase(Player, ProductStats["Expansion"].id)
	end
end)

return module
