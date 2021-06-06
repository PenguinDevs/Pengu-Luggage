local module = {}

local Resources = require(game.ReplicatedStorage.Resources)
local Janitor = Resources:LoadLibrary("Janitor")
local FishBuy
local Player = game.Players.LocalPlayer
local Mouse = Player:GetMouse()
local WorkspaceMouse = Resources:LoadLibrary("WorkspaceMouse")
local Status = Resources:LoadLibrary("Status")
local UserInputService = game:GetService("UserInputService")
local FloorStats = Resources:LoadLibrary("FloorStats")
local ItemStats = Resources:LoadLibrary("ItemStats")
local FishStats = Resources:LoadLibrary("FishStats")
local FishHoldIndexer = Resources:LoadLibrary("FishHoldIndexer")
local Notify = Resources:LoadLibrary("NotifyHandler")
local TextLoader = Resources:LoadLibrary("TextLoader")
local CeilingHideShow = Resources:LoadLibrary("CeilingHideShow")
local Keys = Resources:LoadLibrary("Keys")
local BindUiOpenClose = Resources:LoadLibrary("BindUiOpenClose")
local RainbowGradient = Resources:LoadLibrary("RainbowGradient")
local AudioHandler = Resources:LoadLibrary("AudioHandler")
local Round = Resources:LoadLibrary("Round")

module.uiShowHide = nil
module.uiOpenClose = nil

local Deb = tick()

local SelectSelectionObj = Instance.new("SelectionBox", workspace)
SelectSelectionObj.SurfaceTransparency = 0.5
SelectSelectionObj.Transparency = 0.5
SelectSelectionObj.Color3 = Color3.fromRGB(250, 253, 36)
SelectSelectionObj.SurfaceColor3 = Color3.fromRGB(250, 253, 36)

local Enabled = false
local selectingTarget
local lastTargetClicked

function module:on()
    CeilingHideShow:hide()
    FishBuy = module.FishBuy
    Enabled = true
    for _, obj in pairs(Player.PlayerGui.FishFillMenu.Frame.Body.ScrollingFrame:GetChildren()) do
        if obj:IsA("Frame") and obj.Name ~= "TEMP" then
            obj:Destroy()
        end
    end
    module:updateList()
end

function module:off()
    CeilingHideShow:show()
    Enabled = false
    selectingTarget = nil
    lastTargetClicked = nil
    SelectSelectionObj.Adornee = nil
end

local function updateHovering(_, proc)
    if proc then return end
    if Status.game.visiting then return end
    local plot = workspace.Game.PlayerPlots:FindFirstChild(tostring(Status.game.plotNo))
    if not plot then return end
    plot = plot.Plot
    if Enabled then
        local raycastP = RaycastParams.new()
		raycastP.FilterType = Enum.RaycastFilterType.Whitelist
		raycastP.FilterDescendantsInstances = {plot.Parent.Items, plot.Parent.Floors}
		local target = WorkspaceMouse:getTarget(100, raycastP)
		local function quit()
			SelectSelectionObj.Adornee = nil
            selectingTarget = nil
		end
		if target then
			local parentModel = target
			for i = 1, 2 do
				if not parentModel then break end
				local tempParentModel = parentModel:FindFirstAncestorWhichIsA("Model")
				parentModel = tempParentModel
				if tempParentModel.Parent == plot.Parent.Items or tempParentModel.Parent == plot.Parent.Floors then
					break
				end
				if i == 2 then quit() return end
			end
			if parentModel.Parent ~= plot.Parent.Items and parentModel.Parent ~= plot.Parent.Floors then return end
			if not parentModel then quit() return end
            if parentModel.Parent == plot.Parent.Floors then
                local floorStat = FloorStats[Status.data.build1.floors[parentModel.Name].floor]
                if not floorStat.fishHold then return end
            elseif parentModel.Parent == plot.Parent.Items then
                local itemStat = ItemStats[Status.data.build1.items[parentModel.Name].item]
                if not itemStat.fishHold then return end
            end
			SelectSelectionObj.Adornee = parentModel
			selectingTarget = parentModel

            if UserInputService.TouchEnabled then
                lastTargetClicked = selectingTarget
                if Enabled then
                    module:updateList()
                end
            end
		else
			quit()
			return
		end
    end
end

UserInputService.InputChanged:Connect(updateHovering)
UserInputService.TouchStarted:Connect(updateHovering)

Mouse.Button1Down:Connect(function()
    lastTargetClicked = selectingTarget
    if Enabled then
        module:updateList()
    end
end)

function module:updateList()
    if not lastTargetClicked then
        Player.PlayerGui.FishFillMenu.Frame.Body.Head.NameFrame.TextLabel.Text = "None"
        Player.PlayerGui.FishFillMenu.Frame.Body.Head.AmountFrame.TextLabel.Text = "?/?"
        Player.PlayerGui.FishFillMenu.Frame.Body.Head.ContentFrame.TextLabel.Text = "Select a tank to add fish"
    else
        local plot = workspace.Game.PlayerPlots:FindFirstChild(tostring(Status.game.plotNo)).Plot
        local itemType
        local itemName
        local itemStat
        local fishHoldIndex
        local function updateFishHoldIndex()
            if lastTargetClicked.Parent == plot.Parent.Items then
                itemName = Status.data.build1.items[lastTargetClicked.Name].item
                itemStat = ItemStats[itemName]
                itemType = "item"
            elseif lastTargetClicked.Parent == plot.Parent.Floors then
                itemName = Status.data.build1.floors[lastTargetClicked.Name].floor
                itemStat = FloorStats[itemName]
                itemType = "floor"
            end
            fishHoldIndex = FishHoldIndexer.convert(itemType, lastTargetClicked.Name)
        end
        updateFishHoldIndex()
        local itemFishHold = Status.data.fishHold[fishHoldIndex] or {}
        local remainderFish = {}
        local fishContainForConcat = {}
        local fishAmount = 0
        for fishName, amount in pairs(itemFishHold) do
            table.insert(fishContainForConcat, 1, tostring(amount) .. " " .. fishName)
            local fishStat = FishStats[fishName]
            fishAmount += amount * fishStat.weight
        end
        local function updateRemainder()
            remainderFish = {}
            for fishHoldIndex, fishHold in pairs(Status.data.fishHold) do
                for fishName, amount in pairs(fishHold) do
                    if not remainderFish[fishName] then remainderFish[fishName] = Status.data.fish[fishName] end
                    local fishStat = FishStats[fishName]
                    remainderFish[fishName] -= amount
                end
            end
            for fishName, amount in pairs(Status.data.fish) do
                local fishStat = FishStats[fishName]
                if not remainderFish[fishName] then remainderFish[fishName] = amount end
            end
        end
        updateRemainder()
        Player.PlayerGui.FishFillMenu.Frame.Body.Head.NameFrame.TextLabel.Text = itemName
        Player.PlayerGui.FishFillMenu.Frame.Body.Head.AmountFrame.TextLabel.Text = fishAmount .. "/" .. itemStat.fishHold
        Player.PlayerGui.FishFillMenu.Frame.Body.Head.ContentFrame.TextLabel.Text = table.concat(fishContainForConcat, ", ")
    
        for _, obj in pairs(Player.PlayerGui.FishFillMenu.Frame.Body.ScrollingFrame:GetChildren()) do
            if obj:IsA("Frame") and obj.Name ~= "TEMP" then
                if not Status.data.fish[obj.Name] then obj:Destroy() end
            end
        end
        local lastOffsetYSize
        local count = 0
        for fishName, amount in pairs(Status.data.fish) do
            local ui = Player.PlayerGui.FishFillMenu.Frame.Body.ScrollingFrame:FindFirstChild(fishName)
            count += 1
            if not ui then
                ui = Player.PlayerGui.FishFillMenu.Frame.Body.ScrollingFrame.TEMP:Clone()
                ui.Parent = Player.PlayerGui.FishFillMenu.Frame.Body.ScrollingFrame
                ui.Name = fishName
                local obj = Resources:GetAnimal(fishName):Clone()
                local camera = Instance.new("Camera", ui.Base.View)
                local fishStat = FishStats[fishName]
                --camera.CameraType = Enum.CameraType.Scriptable
                obj.Parent = ui.Base.View.WorldModel
                obj.PrimaryPart.Anchored = true
                local objOrientation, objSize = obj:GetBoundingBox()
                local dist = objSize.Magnitude
                obj:SetPrimaryPartCFrame(CFrame.new(0, 0, -dist/3 * 2) * CFrame.Angles(0, math.rad(90), 0))
                camera.CFrame = CFrame.new(Vector3.new(dist, dist, dist), objOrientation.p)
                
                ui.Base.NameLabel.Text = fishName

                RainbowGradient:loadRainbow(ui.Base.Add.Base.Frame.TextLabel.UIGradient, 2, 2)

                ui.Base.Add.Base.Frame.MouseButton1Click:Connect(function()
                    if tick() - Deb < 0.3 then return end
                    Deb = tick()
                    updateFishHoldIndex()
                    updateRemainder()
                    local weightTotal = 0
                    if Status.data.fishHold[fishHoldIndex] then
                        for fishName2, fishAmount in pairs(Status.data.fishHold[fishHoldIndex]) do
                            local fishStat = FishStats[fishName2]
                            weightTotal += fishAmount * fishStat.weight
                        end
                    end
                    local price = fishStat.price
                    if Status.passes["VIP"] then price *= 0.7 end
                    price = Round(price)

                    if (remainderFish[fishName] or 0) > 0 then
                        if weightTotal + fishStat.weight > itemStat.fishHold then
                            Notify:addItem("Issue", 3, nil, string.format("Cannot add! You don't have enough fish space! (%s/%s), %s takes up %s!", weightTotal, itemStat.fishHold, fishName, fishStat.weight))
                        else
                            Resources:GetRemote("FishFill"):FireServer(fishHoldIndex, fishName, 1)
                        end
                    else
                        if Status.data.money >= 1 * price then
                            Resources:GetRemote("BuyFish"):FireServer(fishName, 1)
                            AudioHandler:playAudio("Cha Ching")
                        else
                            Notify:addItem("Issue", 3, nil, string.format("Cannot purchase! You need $%s more money to buy %s!", TextLoader:ConvertShort(1 * price - Status.data.money), fishName))
                            AudioHandler:playAudio("Error")
                            module.uiShowHide:tweenMenu("MoneyBuyUi", "open")
                            spawn(function()
                                wait(4)
                                module.uiShowHide:tweenMenu("MoneyBuyUi", "close")
                            end)
                        end
                        -- Notify:addItem("Issue", 3, nil, string.format("Cannot add! You don't have enough %s!", fishName))
                    end
                end)
                ui.Base.Sub.Base.Frame.MouseButton1Click:Connect(function()
                    if tick() - Deb < 0.3 then return end
                    Deb = tick()
                    updateFishHoldIndex()
                    updateRemainder()
                    if Status.data.fishHold[fishHoldIndex] then
                        if (Status.data.fishHold[fishHoldIndex][fishName] or 0) ~= 0 then
                            Resources:GetRemote("FishFill"):FireServer(fishHoldIndex, fishName, -1)
                        else
                            Notify:addItem("Issue", 3, nil, string.format("Cannot remove! There is already no %s in the tank!", fishName))
                        end
                    else
                        Notify:addItem("Issue", 3, nil, "Cannot remove! There is no fish in this tank!")
                    end
                end)
                ui.Base.WeightLabel.Text = "Size: " .. tostring(fishStat.weight)

                if fishStat.reqPass then
                    local grad = ui.Base:FindFirstChild("UIGradient")
                    if not grad:FindFirstChild("Rainbow") then
                        Instance.new("BoolValue", grad).Name = "Rainbow"
                        RainbowGradient:loadRainbow(grad, 5, 1)
                        grad.Rotation = -45
                        ui.Base.BackgroundColor3 = Color3.fromRGB(250, 250, 250)
                    end
                end

                ui.Visible = true
            end

            if (remainderFish[fishName] or 0) == 0 then
                local fishStat = FishStats[fishName]
                local price = fishStat.price
                if Status.passes["VIP"] then price *= 0.7 end
                price = Round(price)
                print(Status.passes["VIP"], Status.passes)
                if not fishStat.disallow then
                    ui.Base.Add.Base.Frame.TextLabel.Text = "$" .. TextLoader:ConvertShort(price)
                    if Status.data.money >= 1 * price then
                        ui.Base.Add.Base.Frame.TextLabel.TextColor3 = Color3.fromRGB(255, 255, 255) -- Color3.fromRGB(45, 240, 38)
                    else
                        ui.Base.Add.Base.Frame.TextLabel.TextColor3 = Color3.fromRGB(255, 73, 73)
                    end
                else
                    ui.Base.Add.Base.Frame.TextLabel.Text = "- - -"
                    ui.Base.Add.Base.Frame.TextLabel.TextColor3 = Color3.fromRGB(255, 255, 255) -- Color3.fromRGB(45, 240, 38)
                end
            else
                ui.Base.Add.Base.Frame.TextLabel.Text = "ADD"
                ui.Base.Add.Base.Frame.TextLabel.TextColor3 = Color3.fromRGB(255, 255, 255) -- Color3.fromRGB(45, 240, 38)
            end

            ui.Base.OwnedLabel.Text = "Remain:\n" .. tostring(remainderFish[fishName] or 0)
            if Status.data.fishHold[fishHoldIndex] then
                if Status.data.fishHold[fishHoldIndex][fishName] then
                    ui.Base.Sub.Visible = true
                else 
                    ui.Base.Sub.Visible = false
                end
            else
                ui.Base.Sub.Visible = false
            end

            lastOffsetYSize = ui.AbsoluteSize.Y
        end

        Player.PlayerGui.FishFillMenu.Frame.Body.ScrollingFrame.CanvasSize = UDim2.fromOffset(0, (lastOffsetYSize + 4) * count)
        -- print(UDim2.fromOffset(0, (lastOffsetYSize + 4) * count), count)
    end
end

-- Player.PlayerGui.FishFillMenu.Frame.Footer.Fish.Base.Frame.MouseButton1Click:Connect(module.off)
-- Player.PlayerGui.FishFillMenu.Frame.Header.Exit.Base.Frame.MouseButton1Click:Connect(module.off)
-- Player.PlayerGui.FishMenu.Frame.Footer.Tanks.Base.Frame.MouseButton1Click:Connect(module.on)

function openTankGui()
    local adornee = Player.PlayerGui.ItemTankGui.Adornee
    if adornee then
        lastTargetClicked = adornee:FindFirstAncestorOfClass("Model")
        BindUiOpenClose.binds.FishFill.sigs.open:Fire()
    end
end

function module:changeLastTargetClicked(...)
    lastTargetClicked = ...
end

Player.PlayerGui.ItemTankGui.Frame.Body.Fill.Base.Frame.MouseButton1Click:Connect(openTankGui)
-- Keys.E.KeyDown:Connect(openTankGui)

return module
