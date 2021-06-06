local Resources = require(game.ReplicatedStorage.Resources)
local GameLoop = Resources:LoadLibrary("GameLoop")
local DataStore2 = Resources:LoadLibrary("DataStore2")
local DefaultDS = Resources:LoadLibrary("DefaultDS")
local FishStats = Resources:LoadLibrary("FishStats")
local GetCustomerAmount = Resources:LoadLibrary("GetCustomerAmount")
local GetCustomerSatisfaction = Resources:LoadLibrary("GetCustomerSatisfaction")
local TextLoader = Resources:LoadLibrary("TextLoader")
local Round = Resources:LoadLibrary("Round")
local GameSettings = Resources:LoadLibrary("GameSettings")

local module = {}

local CurrencySpeed = 30

function module:playerProfileAssign(playerProfile)
    local incomeHandler = {}

    local fishHoldStore = DataStore2("fishHold", playerProfile.obj)
    local build1Store = DataStore2("build1", playerProfile.obj)
    local moneyIncomeLoop
    moneyIncomeLoop = GameLoop.new(function()
        local totalIncome = 15

        if not playerProfile.obj:IsDescendantOf(game) then
            moneyIncomeLoop.Enabled = false
            return
        end

        local fishHoldCache = fishHoldStore:Get(DefaultDS.fishHold)
        for _, fishHold in pairs(fishHoldCache) do
            for fishName, fishAmount in pairs(fishHold) do
                local fishStat = FishStats[fishName]
                totalIncome += fishStat.profit * fishAmount
            end
        end

        local customerAmount = GetCustomerAmount(build1Store:Get(DefaultDS.build1))
        totalIncome += customerAmount * GameSettings.incomePerCustomer

        totalIncome /= CurrencySpeed --/6 --/3

        if playerProfile.passes["Rich Guests (2x Income)"] then totalIncome *= 2 end
        if playerProfile.inGroup then totalIncome *= 1.1 end
        -- if playerProfile.obj.MembershipType == Enum.MembershipType.Premium then totalIncome *= 1.5 end
        -- totalIncome *= math.clamp(GetCustomerSatisfaction(build1Store:Get(DefaultDS.build1), fishHoldStore:Get(DefaultDS.fishHold)), 0.3, 1)
        totalIncome = Round(totalIncome)
        playerProfile.data:incrVal("money", totalIncome)

        local mult = 1
        if playerProfile.passes["2x Money"] then mult *= 2 end
        -- Resources:GetRemote("Notify"):FireClient(playerProfile.obj, "ImageText", 8, "rbxassetid://6385560117",
        --     string.format("You received your $%s income!", TextLoader:ConvertShort(totalIncome * mult)),
        --     Color3.fromRGB(95, 235, 132)
        -- )
    end, 60/CurrencySpeed, "FishIncome:" .. playerProfile.obj.Name)
    -- 6 -- 3
    local tipLoop
    tipLoop = GameLoop.new(function()
        local totalTip = 0

        if not playerProfile.obj:IsDescendantOf(game) then
            tipLoop.Enabled = false
            return
        end

        local customerAmount = GetCustomerAmount(build1Store:Get(DefaultDS.build1))
        local customerSatisfaction = GetCustomerSatisfaction(build1Store:Get(DefaultDS.build1), fishHoldStore:Get(DefaultDS.fishHold))

        totalTip = Round(100 * customerSatisfaction * customerAmount)
        if playerProfile.passes then
            if playerProfile.passes["Extra Tips"] then
                totalTip *= 1.8
            end
            if playerProfile.passes["VIP"] then
                totalTip *= 2
            end
        end

        playerProfile.data:incrVal("money", totalTip)

        local mult = 1
        if playerProfile.passes["2x Money"] then mult += 1 end
        Resources:GetRemote("Notify"):FireClient(playerProfile.obj, "ImageText", 8, "rbxassetid://6578574501",
            string.format("You received $%s tip from your %s customers who are %.0f%% happy!", TextLoader:ConvertShort(totalTip * mult), customerAmount, Round(customerSatisfaction * 100)),
            Color3.fromRGB(0, 170, 255)
        )
    end, 90, "TipLoop:" .. playerProfile.obj.Name)

    GameLoop:handle(moneyIncomeLoop)
    GameLoop:handle(tipLoop)

    return incomeHandler
end

return module