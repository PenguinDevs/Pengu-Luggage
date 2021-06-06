local module = {}

local Resources = require(game.ReplicatedStorage.Resources)
local GetUserTasks = Resources:LoadLibrary("GetUserTasks")
local DataStore2 = Resources:LoadLibrary("DataStore2")
local DefaultDS = Resources:LoadLibrary("DefaultDS")
local ItemStats = Resources:LoadLibrary("ItemStats")
local FloorStats = Resources:LoadLibrary("FloorStats")

local List = {
    ["Place tanks"] = {
        title = "More fish tanks";
        desc = function(goal)
            return string.format("<font color='rgb(0, 127, 255)'>Place %s</font> fish tanks!", goal)
        end;
        get = GetUserTasks.getPlacing;
        getProg = function(playerProfile)
            local build1Store = DataStore2("build1", playerProfile.obj)
            local build1Cache = build1Store:Get(DefaultDS.build1)
            local count = 0
            for _, floorOwned in pairs(build1Cache.floors) do
                local floorStat = FloorStats[floorOwned.floor]
                if floorStat.fishHold then
                    count += 1
                end
            end
            for _, itemOwned in pairs(build1Cache.items) do
                local itemStat = ItemStats[itemOwned.item]
                if not itemStat then warn("Cannot get", itemOwned.item, "'s item stat for .fishHold in GetCustomerAmount.lua", ItemStats) continue end
                if itemStat.fishHold then
                    count += 1
                end
            end
            return count
        end;
        short = "tanks";
    };
    ["Fill Fish"] = {
        title = "Adding fish";
        desc = function(goal)
            return string.format("<font color='rgb(0, 127, 255)'>Fill %s</font> fish in tanks!", goal)
        end;
        get = GetUserTasks.getFill;
        getProg = function(playerProfile)
            local fishHoldStore = DataStore2("fishHold", playerProfile.obj)
            local fishHoldCache = fishHoldStore:Get(DefaultDS.fishHold)
            local count = 0
            for fishHoldIndex, fishHold in pairs(fishHoldCache) do
                for fishName, fishAmount in pairs(fishHold) do
                    count += fishAmount
                end
            end
            return count
        end;
        short = "fill";
    };
}

function module:playerProfileAssign(playerProfile)
    local self = {}

    function self:update()
        local tasksStore = DataStore2("tasks", playerProfile.obj)
        local tasksCache = tasksStore:Get(DefaultDS.tasks)
        local changed = false
        for taskType, info in pairs(List) do
            local level = tasksCache[info.short]
            local endGoal, reward = info.get(level)
            local prog = info.getProg(playerProfile)
            if prog >= endGoal then
                playerProfile.data:incrVal("money", reward)
                tasksCache[info.short] += 1
                changed = true
            end
        end

        if changed then
            playerProfile.data:setVal("tasks", tasksCache)
            tasksStore:Get(DefaultDS.tasks)
        end
    end
    self:update()
    
    return self
end

return module