local module = {}

local Resources = require(game.ReplicatedStorage.Resources)
local FloorStats = Resources:LoadLibrary("FloorStats")
local ItemStats = Resources:LoadLibrary("ItemStats")
local Round = Resources:LoadLibrary("Round")
local FishStats = Resources:LoadLibrary("FishStats")
local GetCustomerAmount = Resources:LoadLibrary("GetCustomerAmount")

local DEBUG = false

return setmetatable(module, {
    __call = function(_, ...)
        local build1Cache, fishHoldCache, getAll = ...
        
        local initValue = 10

        local seatsTotal = 10 + initValue
        local fishTotal = 2 + initValue
        local foodTotal = 1 * 10 + initValue
        local drinkTotal = 1 * 10 + initValue
        local funTotal = 1 * 10 + initValue
        local toiletTotal = 1 * 50 + initValue

        for _, fishHold in pairs(fishHoldCache) do
            for fishName, fishAmount in pairs(fishHold) do
                local fishStat = FishStats[fishName]
                fishTotal += fishAmount * Round(fishStat.price/10)
            end
        end
        for _, itemOwned in pairs(build1Cache.items) do
            local itemStat = ItemStats[itemOwned.item]
            if itemStat.itemType == "seat" then
                seatsTotal += 1 * Round(itemStat.price * 8)
            elseif itemStat.itemType == "food" then
                foodTotal += 1 * Round(itemStat.price * 25)
            elseif itemStat.itemType == "drink" then
                drinkTotal += 1 * Round(itemStat.price * 25)
            elseif itemStat.itemType == "fun" then
                funTotal += 1 * Round(itemStat.price * 25)
            elseif itemStat.itemType == "toilet" then
                toiletTotal += 1 * Round(itemStat.price * 20)
            end
        end
        
        local customerAmount = GetCustomerAmount(build1Cache)
        local function clampTotal(total)
            return math.clamp(total-initValue, 0, customerAmount * 250) + initValue
        end
        seatsTotal = clampTotal(seatsTotal)
        fishTotal = clampTotal(fishTotal)
        foodTotal = clampTotal(foodTotal)
        drinkTotal = clampTotal(drinkTotal)
        funTotal = clampTotal(funTotal)
        toiletTotal = clampTotal(toiletTotal)

        local highestTotal = 0
        local function compareTotals(t1, t2)
            if t1 > highestTotal then highestTotal = t1 end
            if t2 > highestTotal then highestTotal = t2 end
            return (t1 + t2)/2
        end
        local satisfactionAmount = compareTotals(seatsTotal, fishTotal)
        satisfactionAmount = compareTotals(satisfactionAmount, foodTotal)
        satisfactionAmount = compareTotals(satisfactionAmount, drinkTotal)
        satisfactionAmount = compareTotals(satisfactionAmount, toiletTotal)
        satisfactionAmount = compareTotals(satisfactionAmount, funTotal)
        
        if DEBUG then
            print(satisfactionAmount, highestTotal)
        end
        satisfactionAmount = satisfactionAmount/highestTotal

        local collectedNeeds = {}
        local function checkNeed(name, total)
            --print(name, total)
            if total/highestTotal < 0.8 or getAll then
               table.insert(collectedNeeds, 1, {name = name, satisfaction = total/highestTotal})
            end
        end
        checkNeed("seat", seatsTotal)
        checkNeed("fish", fishTotal)
        checkNeed("food", foodTotal)
        checkNeed("drink", drinkTotal)
        checkNeed("toilet", toiletTotal)
        checkNeed("fun", funTotal)

        table.sort(collectedNeeds, function(a,b)
            return a.satisfaction < b.satisfaction
        end)
        if DEBUG then
            print(collectedNeeds)
            print(satisfactionAmount)
            print("seat", seatsTotal)
            print("fish", fishTotal)
            print("food", foodTotal)
            print("drink", drinkTotal)
            print("toilet", toiletTotal)
            print("fun", funTotal)
        end
        return satisfactionAmount, collectedNeeds
    end
})