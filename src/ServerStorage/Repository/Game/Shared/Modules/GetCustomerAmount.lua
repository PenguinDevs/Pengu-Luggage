local module = {}

local Resources = require(game.ReplicatedStorage.Resources)
local FloorStats = Resources:LoadLibrary("FloorStats")
local ItemStats = Resources:LoadLibrary("ItemStats")
local Round = Resources:LoadLibrary("Round")
local GameSettings = Resources:LoadLibrary("GameSettings")

return setmetatable(module, {
    __call = function(_, ...)
        local build1Cache, init = ...
        local tankWorth = init or 0
        --local tankCount = 0
        for _, floorOwned in pairs(build1Cache.floors) do
            local floorStat = FloorStats[floorOwned.floor]
            if floorStat.fishHold then
                tankWorth += floorStat.price
            end
        end
        for _, itemOwned in pairs(build1Cache.items) do
            local itemStat = ItemStats[itemOwned.item]
            if not itemStat then warn("Cannot get", itemOwned.item, "'s item stat for .fishHold in GetCustomerAmount.lua", ItemStats) continue end
            if itemStat.fishHold then
                tankWorth += itemStat.price
            end
        end
        --tankCount = Round(tankWorth/600)
        --local customerAmount = tankCount

        local customerAmount = 1

        local added = 0
        local lastDiv = 0
        while true do
            local div = (tankWorth - added)/GameSettings.tankNeededPerCustomer
            if div > 1 then
                added += GameSettings.tankNeededPerCustomer * customerAmount
                customerAmount += 1
                lastDiv = div
            else
                break
            end
        end

        return customerAmount, lastDiv
    end
})