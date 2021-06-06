local module = {}

local Player = game.Players.LocalPlayer

local Resources = require(game.ReplicatedStorage.Resources)
local Status = Resources:LoadLibrary("Status")
local TextLoader = Resources:LoadLibrary("TextLoader")
local FishStats = Resources:LoadLibrary("FishStats")
local Cache = Resources:LoadLibrary("Cache")
local Tween = Resources:LoadLibrary("Tween")
local Enumeration = Resources:LoadLibrary("Enumeration")
local GetCustomerAmount = Resources:LoadLibrary("GetCustomerAmount")
local GetCustomerSatisfaction = Resources:LoadLibrary("GetCustomerSatisfaction")
local Notify = Resources:LoadLibrary("NotifyHandler")
local ItemTypes = Resources:LoadLibrary("ItemTypes")
local Round = Resources:LoadLibrary("Round")
local RunService = game:GetService("RunService")
local GameSettings = Resources:LoadLibrary("GameSettings")
local UiShowHide = Resources:LoadLibrary("UiShowHide")
local UserInputService = game:GetService("UserInputService")
local RainbowGradient = Resources:LoadLibrary("RainbowGradient")

local OutSine = Enumeration.EasingFunction.OutSine.Value

local CurrencyLabels = {}

Cache:addItem(Player.PlayerGui.Shared.Frame.Currency.MoneyLabel, 10, Player.PlayerGui.Shared.Frame.Currency, "SharedMoneyLabel", {
    "Size";
    "Position";
    "Visible";
    "TextTransparency";
})
Cache:addItem(Player.PlayerGui.InGame.Frame.Currency.Base.Balance.MoneyLabel, 10, Player.PlayerGui.InGame.Frame.Currency.Base.Balance, "InGameMoneyLabel", {
    "Size";
    "Position";
    "Visible";
    "TextTransparency";
})
Cache:addItem(Player.PlayerGui.Editor.Frame.List.Currency.MoneyLabel, 10, Player.PlayerGui.Editor.Frame.List.Currency, "EditorMoneyLabel", {
    "Size";
    "Position";
    "Visible";
    "TextTransparency";
})
Cache:addItem(Player.PlayerGui.Editor.Frame.List.Currency.MoneyLabel, 10, Player.PlayerGui.Editor.Frame.List.Currency, "FishMenuMoneyLabel", {
    "Size";
    "Position";
    "Visible";
    "TextTransparency";
})

function module:updateCurrencyUi(textlabel, amount, prefix, suffix, hoverName, type)
    if hoverName and tonumber(amount) then
        if not CurrencyLabels[hoverName] then
            CurrencyLabels[hoverName] = tonumber(amount)
        else
            local labelHoverUi = Cache:getItem(hoverName)
            Cache:returnProps(labelHoverUi, hoverName)
            local diff = tonumber(amount) - CurrencyLabels[hoverName]
            diff *= 2
            local function proceed()
                labelHoverUi.Visible = true
                labelHoverUi:TweenPosition(UDim2.fromScale(0.5, 0), Enum.EasingDirection.Out, Enum.EasingStyle.Sine, 0.6, true)
                wait(0.3)
                Tween(labelHoverUi, "TextTransparency", 1, OutSine, 0.5, true)
                wait(0.5)
                Cache:returnItem(labelHoverUi, hoverName)
            end
            if diff == 0 then
                Cache:returnItem(labelHoverUi, hoverName)
            elseif diff > 0 then
                labelHoverUi.TextColor3 = Color3.fromRGB(95, 235, 132)
                labelHoverUi.Text = "+" .. (prefix or "") .. TextLoader:ConvertShort(diff) .. (suffix or "")
                spawn(proceed)
            elseif diff < 0 then
                labelHoverUi.TextColor3 = Color3.fromRGB(255, 67, 67)
                labelHoverUi.Text = "-" .. (prefix or "") .. TextLoader:ConvertShort(math.abs(diff)) .. (suffix or "")
                spawn(proceed)
            end
            CurrencyLabels[hoverName] = tonumber(amount)
        end
    end
    if type == "comma" then
        textlabel.Text = (prefix or "") .. TextLoader:ConvertComma(amount) .. (suffix or "")
    else
        textlabel.Text = (prefix or "") .. TextLoader:ConvertShort(amount) .. (suffix or "")
    end
end

function module:updateMoney()
	module:updateCurrencyUi(Player.PlayerGui.Shared.Frame.Currency.Base.Frame.TextLabel, Status.data.money, "$", nil, "SharedMoneyLabel")
	module:updateCurrencyUi(Player.PlayerGui.InGame.Frame.Currency.Base.Balance.TextLabel, Status.data.money, "$", nil, "InGameMoneyLabel", "comma")
	module:updateCurrencyUi(Player.PlayerGui.Editor.Frame.List.Currency.Base.Frame.TextLabel, Status.data.money, "$", nil, "EditorMoneyLabel")
    module:updateCurrencyUi(Player.PlayerGui.FishMenu.Frame.Footer.Currency.Base.Frame.TextLabel, Status.data.money, "$", nil, "FishMenuMoneyLabel")
    module:updateCurrencyUi(Player.PlayerGui.Editor.MoneyAmount, Status.data.money, "$", nil)
end

function module:updateIncome()
	local totalIncome = 15

    for _, fishHold in pairs(Status.data.fishHold) do
        for fishName, fishAmount in pairs(fishHold) do
            local fishStat = FishStats[fishName]
            totalIncome += fishStat.profit * fishAmount
        end
    end

    local build1Cache = Status.data.build1
    local fishHoldCache = Status.data.fishHold

    local customerAmount = GetCustomerAmount(build1Cache)
    totalIncome += customerAmount * GameSettings.incomePerCustomer

    if Status.passes["2x Money"] then totalIncome *= 2 end
    if Status.passes["Rich Guests (2x Income)"] then totalIncome *= 2 end
    if Status.game.inGroup then totalIncome *= 1.1 end
    -- if Player.MembershipType == Enum.MembershipType.Premium then totalIncome *= 1.5 end
    -- local customerSatisfaction, recommendation = GetCustomerSatisfaction(build1Cache, fishHoldCache)
    -- totalIncome *= math.clamp(customerSatisfaction, 0.3, 1)
    totalIncome = Round(totalIncome)

	module:updateCurrencyUi(Player.PlayerGui.InGame.Frame.Currency.Base.Rate.TextLabel, totalIncome, "$", "/min")
end

function module:updateCustomers()
    local customerAmount = GetCustomerAmount(Status.data.build1)
    module:updateCurrencyUi(Player.PlayerGui.InGame.Frame.Currency.People.Base.Upper.Customers.TextLabel, customerAmount)
end

function module:updateSatisfaction()
    local build1Cache = Status.data.build1
    local fishHoldCache = Status.data.fishHold

    local customerSatisfaction, recommendation = GetCustomerSatisfaction(build1Cache, fishHoldCache)
    module:updateCurrencyUi(Player.PlayerGui.InGame.Frame.Currency.People.Base.Upper.Satisfaction.TextLabel, customerSatisfaction * 100, nil, "%")
    --print(customerSatisfaction)
    if customerSatisfaction > 0.8 then
        Player.PlayerGui.InGame.Frame.Currency.People.Base.Upper.Satisfaction.ImageLabel.Image = "rbxassetid://6385757126"
        Player.PlayerGui.InGame.Frame.Currency.People.Base.Upper.Satisfaction.ImageLabel.ImageColor3 = Color3.fromRGB(75, 255, 105)
        Player.PlayerGui.InGame.Frame.Currency.People.Base.Upper.Satisfaction.TextLabel.TextColor3 = Color3.fromRGB(75, 255, 105)
    elseif customerSatisfaction > 0.4 then
        Player.PlayerGui.InGame.Frame.Currency.People.Base.Upper.Satisfaction.ImageLabel.Image = "rbxassetid://6385756973"
        Player.PlayerGui.InGame.Frame.Currency.People.Base.Upper.Satisfaction.ImageLabel.ImageColor3 = Color3.fromRGB(248, 225, 93)
        Player.PlayerGui.InGame.Frame.Currency.People.Base.Upper.Satisfaction.TextLabel.TextColor3 = Color3.fromRGB(248, 225, 93)
    else
        Player.PlayerGui.InGame.Frame.Currency.People.Base.Upper.Satisfaction.ImageLabel.Image = "rbxassetid://6385757245"
        Player.PlayerGui.InGame.Frame.Currency.People.Base.Upper.Satisfaction.ImageLabel.ImageColor3 = Color3.fromRGB(255, 75, 75)
        Player.PlayerGui.InGame.Frame.Currency.People.Base.Upper.Satisfaction.TextLabel.TextColor3 = Color3.fromRGB(255, 75, 75)
    end

    --print(recommendation)
    for i = 1, 3 do
        local needDet = recommendation[i]
        local ui = Player.PlayerGui.InGame.Frame.Currency.People.Base.Lower[i]
        if needDet then
            local itemType = ItemTypes[needDet.name]
            --print(needDet, itemType, i)
            ui.ImageLabel.Image = itemType.image
            ui.ImageLabel.ImageColor3 = itemType.colour
            local function c3toString(c3)
                return Round(c3.R * 255) .. ", " .. Round(c3.G * 255) .. ", " .. Round(c3.B * 255)
            end
            if needDet.name == "seat" then
                ui.TextLabel.Text = 'Your customers are tired from standing! <u><font size = "25" color="rgb(' .. c3toString(itemType.colour) .. ')">Build more chairs!</font></u>'
            elseif needDet.name == "fish" then
                ui.TextLabel.Text = 'Your customers are bored! <u><font size = "25" color="rgb(' .. c3toString(itemType.colour) .. ')">Add more fish in tanks!</font></u>'
            elseif needDet.name == "food" then
                ui.TextLabel.Text = 'Your customers are hungry! <u><font size = "25" color="rgb(' .. c3toString(itemType.colour) .. ')">Build more food stalls!</font></u>'
            elseif needDet.name == "drink" then
                ui.TextLabel.Text = 'Your customers are thirsty! <u><font size = "25" color="rgb(' .. c3toString(itemType.colour) .. ')">Build more drink stalls!</font></u>'
            elseif needDet.name == "toilet" then
                ui.TextLabel.Text = 'Your customers needs the toilet! <u><font size = "25" color="rgb(' .. c3toString(itemType.colour) .. ')">Build more toilets!!</font></u>'
            elseif needDet.name == "fun" then
                ui.TextLabel.Text = 'Your customers are bored! <u><font size = "25" color="rgb(' .. c3toString(itemType.colour) .. ')">Build more interesting items!</font></u>'
            end
        else
            ui.ImageLabel.Image = ""
            if i == 1 then
                ui.TextLabel.Text = "Seems like it's very empty here... well done! Your customers are very happy!"
            else
                ui.TextLabel.Text = ""
            end
        end
    end
end

local needsUiOpen = false
Player.PlayerGui.InGame.Frame.Currency.People.HoverButton.MouseEnter:Connect(function()
    Player.PlayerGui.InGame.Frame.Currency.People.HoverText.Visible = false
    UiShowHide:tweenMenu("InterfaceNeedsUi", "open")
    if UserInputService.TouchEnabled then
        Player.PlayerGui.InGame.Frame.Currency.People.Exit.Visible = true
    end
    wait(1)
    needsUiOpen = true
end)

Player.PlayerGui.InGame.Frame.Currency.People.HoverButton.MouseLeave:Connect(function()
    if not UserInputService.TouchEnabled then
        needsUiOpen = false
        UiShowHide:tweenMenu("InterfaceNeedsUi", "close")
        Player.PlayerGui.InGame.Frame.Currency.People.Exit.Visible = false
    end
end)

Player.PlayerGui.InGame.Frame.Currency.People.Exit.Frame.MouseButton1Click:Connect(function()
    needsUiOpen = false
    UiShowHide:tweenMenu("InterfaceNeedsUi", "close")
    Player.PlayerGui.InGame.Frame.Currency.People.Exit.Visible = false
end)

Player.PlayerGui.InGame.Frame.Currency.People.HoverButton.MouseButton1Click:Connect(function()
    if UserInputService.TouchEnabled and needsUiOpen then
        print("close")
        needsUiOpen = false
        UiShowHide:tweenMenu("InterfaceNeedsUi", "close")
        Player.PlayerGui.InGame.Frame.Currency.People.Exit.Visible = false
    end
end)

RainbowGradient:loadRainbow(Player.PlayerGui.InGameRight.Frame.Shop.Background.UIGradient, 3, 1)

-- if RunService:IsStudio() then
--     workspace.DescendantAdded:Connect(function(x)
--         print(x)
--     end)
-- end

--"You received " .. string.format("%s from your %s %s", tip, customerAmount, customerSatisfaction) .. "!"

return module
