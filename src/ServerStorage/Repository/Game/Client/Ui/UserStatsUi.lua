local module = {}

local Resources = require(game.ReplicatedStorage.Resources)
local Player = game.Players.LocalPlayer
local Status = Resources:LoadLibrary("Status")
local GetCustomerAmount = Resources:LoadLibrary("GetCustomerAmount")
local GetCustomerSatisfaction = Resources:LoadLibrary("GetCustomerSatisfaction")
local Round = Resources:LoadLibrary("Round")
local FishStats = Resources:LoadLibrary("FishStats")
local GameSettings = Resources:LoadLibrary("GameSettings")
local TextLoader = Resources:LoadLibrary("TextLoader")

function module:refresh()
    local stats = {}

    local build1Cache = Status.data.build1
    local fishHoldCache = Status.data.fishHold

    local plotAmount = 0
    for _, _ in pairs(Status.data.build1.plots) do
        plotAmount += 1
    end

    local customerSatisfaction, recommendation = GetCustomerSatisfaction(build1Cache, fishHoldCache)
    local customerAmount = GetCustomerAmount(build1Cache)

    local totalIncome = 15
    totalIncome += customerAmount * GameSettings.incomePerCustomer

    for _, fishHold in pairs(Status.data.fishHold) do
        for fishName, fishAmount in pairs(fishHold) do
            local fishStat = FishStats[fishName]
            totalIncome += fishStat.profit * fishAmount
        end
    end

    if Status.passes["2x Money"] then totalIncome *= 2 end
    if Status.passes["Rich Guests (2x Income)"] then totalIncome *= 2 end
    if Status.game.inGroup then totalIncome *= 1.1 end
    -- if Player.MembershipType == Enum.MembershipType.Premium then totalIncome *= 1.5 end
    -- totalIncome *= math.clamp(customerSatisfaction, 0.3, 1)

    stats["Satisfaction"] = Round(customerSatisfaction * 100) .. "%"
    stats["Customers"] = TextLoader:ConvertComma(customerAmount)
    stats["Income"] = "$" .. TextLoader:ConvertComma(totalIncome) .. "/min"
    stats["Money"] = "$" .. TextLoader:ConvertComma(Status.data.money)
    stats["Plots"] = plotAmount .. "/" .. "25" -- #workspace.Game:FindFirstChildOfClass("Model").Grids:GetChildren()

    -- for _, ui in pairs(Player.PlayerGui.StatsMenu.Frame.Body:GetChildren()) do
        
    -- end
    for uiName, stat in pairs(stats) do
        Player.PlayerGui.StatsMenu.Frame.Body[uiName].AmountLabel.Text = stat
    end
end

return module