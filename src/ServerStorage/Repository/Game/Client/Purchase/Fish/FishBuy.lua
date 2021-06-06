local Resources = require(game.ReplicatedStorage.Resources)
local Player = game.Players.LocalPlayer
local Signal = Resources:LoadLibrary("Signal")
local UserInputService = game:GetService("UserInputService")
local WorkspaceMouse = Resources:LoadLibrary("WorkspaceMouse")
local BindUiOpenClose = Resources:LoadLibrary("BindUiOpenClose")
local UserMouse = Player:GetMouse()
local FishStats = Resources:LoadLibrary("FishStats")
local Status = Resources:LoadLibrary("Status")
local TextLoader = Resources:LoadLibrary("TextLoader")
local FishFill = Resources:LoadLibrary("FishFill")
local Notify = Resources:LoadLibrary("NotifyHandler")
local MarketplaceService = game:GetService("MarketplaceService")
local GamepassStats = Resources:LoadLibrary("GamepassStats")
local RainbowGradient = Resources:LoadLibrary("RainbowGradient")
local AudioHandler = Resources:LoadLibrary("AudioHandler")
local Round = Resources:LoadLibrary("Round")
-- local MarketplaceService = game:GetService("MarketplaceService")
-- local GamepassStats = Resources:LoadLibrary("GamepassStats")
local UiShowHide = Resources:LoadLibrary("UiShowHide")

local module = {}
FishFill.FishBuy = module

local boatHighlight
local isHoveringBoat = false

function module:init()
    local sorted = {}
    for fishName, fish in pairs(FishStats) do
        --local copy = CopyTable:DeepCopy(item)
        fish.name = fishName
        table.insert(sorted, 1, fish)
    end
    table.sort(sorted, function(a, b)
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

    local lastOffsetYSize = 0
    local count = 0
    for _, fishStat in pairs(sorted) do
        if fishStat.disallow then continue end
        count += 1
        local fishName = fishStat.name
        local ui = Player.PlayerGui.FishMenu.Frame.ScrollingFrame.TEMP:Clone()
        ui.Name = fishName
        local obj = Resources:GetAnimal(fishName):Clone()
        local camera = Instance.new("Camera", ui.Base.View)
        --camera.CameraType = Enum.CameraType.Scriptable
        obj.Parent = ui.Base.View.WorldModel
        obj.PrimaryPart.Anchored = true
        local objOrientation, objSize = obj:GetBoundingBox()
        local dist = objSize.Magnitude
        obj:SetPrimaryPartCFrame(CFrame.new(0, 0, -dist/3 * 2) * CFrame.Angles(0, math.rad(90), 0))
        camera.CFrame = CFrame.new(Vector3.new(dist, dist, dist), objOrientation.p)
        -- local animation = Instance.new("Animation")
        -- animation.AnimationId = fishStat.primaryAnim
        -- animation.Parent = obj
        -- local animationController = obj:FindFirstChild("AnimationController")
        -- local humanoid = obj:FindFirstChild("Humanoid")
        -- if animationController then
        --     animationController:Destroy()
        -- end
        -- if not humanoid then
        --     humanoid = Instance.new("Humanoid", obj)
        -- end
        -- humanoid:LoadAnimation(animation):Play()

        ui.Base.NameLabel.Text = fishName
        ui.Base.PriceLabel.Text = "$" .. TextLoader:ConvertShort(fishStat.profit) .. "/min"
        ui.Base.WeightLabel.Text = "Size: " .. tostring(fishStat.weight)
        local ownedAmount = Status.data.fish[fishName] or 0
        ui.Base.OwnedLabel.Text = "Owned:\n" .. TextLoader:ConvertShort(ownedAmount)
        local lastText = "1"
        ui.Base.AmountBox.FocusLost:Connect(function()
            local newText = ui.Base.AmountBox.Text
            if not tonumber(newText) then
                ui.Base.AmountBox.Text = lastText
            else
                lastText = newText
            end
        end)
        local function updatePriceText(amount)
            if amount then
                local price = fishStat.price
                if Status.passes["VIP"] then price *= 0.7 end
                price = Round(price)

                local price = amount * price
                ui.Base.Buy.Base.Frame.TextLabel.Text = "$" .. TextLoader:ConvertShort(price)
                if Status.data.money >= price then
                    ui.Base.Buy.Base.Frame.TextLabel.TextColor3 = Color3.fromRGB(45, 240, 38)
                else
                    ui.Base.Buy.Base.Frame.TextLabel.TextColor3 = Color3.fromRGB(255, 73, 73)
                end
            end
        end
        ui.Base.AmountBox:GetPropertyChangedSignal("Text"):Connect(function()
            local newText = ui.Base.AmountBox.Text
            updatePriceText(tonumber(newText))
        end)
        --print(fishStat.reqPass)
        if fishStat.reqPass then
            -- ui.Base.BackgroundColor3 = Color3.fromRGB(255, 153, 0)
            local grad = ui.Base:FindFirstChild("UIGradient")
            if not grad:FindFirstChild("Rainbow") then
                Instance.new("BoolValue", grad).Name = "Rainbow"
                RainbowGradient:loadRainbow(grad, 5, 1)
                grad.Rotation = -45
                ui.Base.BackgroundColor3 = Color3.fromRGB(250, 250, 250)
            end
        else
            if Status.data.settings.dark then
                ui.Base.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
            else
                ui.Base.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
            end
        end
        ui.Base.AmountBox.Text = "1"
        ui.Base.Buy.Base.Frame.MouseButton1Click:Connect(function()
            local amount = tonumber(ui.Base.AmountBox.Text)
            if not amount then return end
            
            if fishStat.reqPass then
                if Status.passes[fishStat.reqPass] then
                    
                else
                    local gamepassStat = GamepassStats[fishStat.reqPass]
                    MarketplaceService:PromptGamePassPurchase(Player, gamepassStat.id)
                    return
                end
            end

            local price = fishStat.price
            if Status.passes["VIP"] then price *= 0.7 end
            price = Round(price)
            if Status.data.money >= amount * price then
                Resources:GetRemote("BuyFish"):FireServer(fishName, amount)
                AudioHandler:playAudio("Cha Ching")
            else
                Notify:addItem("Issue", 3, nil, string.format("Cannot purchase! You need $%s more money to buy %s %s!", TextLoader:ConvertShort(amount * price - Status.data.money), amount, fishName))
                AudioHandler:playAudio("Error")
                UiShowHide:tweenMenu("MoneyBuyUi", "open")
				spawn(function()
					wait(4)
					UiShowHide:tweenMenu("MoneyBuyUi", "close")
				end)
            end
        end)
        ui.Visible = true
        ui.Parent = Player.PlayerGui.FishMenu.Frame.ScrollingFrame
        lastOffsetYSize = ui.AbsoluteSize.Y
        -- animationController:LoadAnimation(animation):Play()
    end

    Player.PlayerGui.FishMenu.Frame.ScrollingFrame.CanvasSize = UDim2.fromOffset(0, (lastOffsetYSize + 4) * count)
    -- print(lastOffsetYSize, Player.PlayerGui.FishMenu.Frame.ScrollingFrame.CanvasSize)
end

function module:updateList()
    for _, obj in pairs(Player.PlayerGui.FishMenu.Frame.ScrollingFrame:GetChildren()) do
        if obj:IsA("Frame") and obj.Name ~= "TEMP" then
            local ownedAmount = Status.data.fish[obj.Name] or 0
            obj.Base.OwnedLabel.Text = "Owned:\n" .. TextLoader:ConvertShort(ownedAmount)

            local newText = obj.Base.AmountBox.Text
            local amount = tonumber(newText)
            local fishStat = FishStats[obj.Name]
            if amount then
                local price = fishStat.price
                if Status.passes["VIP"] then price *= 0.7 end
                price = Round(price)
                price *= amount
                obj.Base.Buy.Base.Frame.TextLabel.Text = "$" .. TextLoader:ConvertShort(price)
                if Status.data.money >= price then
                    obj.Base.Buy.Base.Frame.TextLabel.TextColor3 = Color3.fromRGB(45, 240, 38)
                else
                    obj.Base.Buy.Base.Frame.TextLabel.TextColor3 = Color3.fromRGB(255, 73, 73)
                end
            end
        end
    end
    FishFill:updateList()
end

UserInputService.InputChanged:Connect(function()
    local plot = workspace.Game.PlayerPlots:FindFirstChild(tostring(Status.game.plotNo))
    local raycastP = RaycastParams.new()
	raycastP.FilterType = Enum.RaycastFilterType.Blacklist
    if not plot then return end
    if not plot:FindFirstChild("Boundary") then return end
	raycastP.FilterDescendantsInstances = {plot.Boundary, Player.Character}
    local target = WorkspaceMouse:getTarget(300, raycastP)
    if not plot then return end
    if not boatHighlight then
        boatHighlight = plot.Visuals.Boats.Boat.Highlight --workspace.Visuals.Boats.Boat.Highlight
    end
    if target then
        if target.Parent:IsA("Model") and target.Parent.Name == "Boat" and target:IsDescendantOf(plot.Visuals.Boats.Boat) then
            boatHighlight.Transparency = 0.5
            isHoveringBoat = true
        else
            boatHighlight.Transparency = 1
            isHoveringBoat = false
        end
    end
end)

UserMouse.Button1Down:Connect(function()
    if isHoveringBoat then
        BindUiOpenClose.binds.FishBuy.sigs.open:Fire()
    end
end)

Player.PlayerGui.FishMenu.Frame.VIP.Button.MouseButton1Click:Connect(function()
    MarketplaceService:PromptGamePassPurchase(Player, GamepassStats["VIP"].id)
end)
Player.PlayerGui.FishMenu.Frame.VIP.Buy.Base.Frame.MouseButton1Click:Connect(function()
    MarketplaceService:PromptGamePassPurchase(Player, GamepassStats["VIP"].id)
end)

return module