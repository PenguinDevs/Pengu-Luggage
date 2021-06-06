local module = {}

local Resources = require(game.ReplicatedStorage.Resources)
local DataStore2 = Resources:LoadLibrary("DataStore2")
local DefaultDS = Resources:LoadLibrary("DefaultDS")
local ItemStats = Resources:LoadLibrary("ItemStats")
local FloorStats = Resources:LoadLibrary("FloorStats")
local WallStats = Resources:LoadLibrary("WallStats")
local FishHoldIndexer = Resources:LoadLibrary("FishHoldIndexer")

function parseData(serialized, stats)
    local deserialized = {}

    for itemPos, itemOwned in pairs(serialized) do
        local name = itemOwned.item or itemOwned.floor or itemOwned.wall
        if stats[name] then
            deserialized[itemPos] = itemOwned
        else
            warn("Deleting", name)
        end
    end

    return deserialized
end

function module:playerProfileAssign(playerProfile, player)
    if playerProfile then if playerProfile.beforeGet then return end end
    player = player or playerProfile.obj
    local build1Store = DataStore2("build1", player)
    build1Store:BeforeInitialGet(function(serialized)
        local deserialized = {}
    
        deserialized.plots = serialized.plots
        deserialized.items = parseData(serialized.items, ItemStats)
        deserialized.walls = {}
        deserialized.walls.h = parseData(serialized.walls.h, WallStats)
        deserialized.walls.v = parseData(serialized.walls.v, WallStats)
        deserialized.floors = parseData(serialized.floors, FloorStats)
    
        return deserialized
    end)

    local fishHoldStore = DataStore2("fishHold", player)
    fishHoldStore:BeforeInitialGet(function(serialized)
        local deserialized = {}
    
        local build1Cache = build1Store:Get(DefaultDS.build1)
        for index, fishHold in pairs(serialized) do
            local itemType, itemPos = FishHoldIndexer.rconvert(index)
            if itemType == "floor" then
                deserialized[index] = fishHold
            elseif itemType == "item" then
                deserialized[index] = fishHold
            end
        end

        return deserialized
    end)

    return {}
end

return module