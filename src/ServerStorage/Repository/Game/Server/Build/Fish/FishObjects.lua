local Resources = require(game.ReplicatedStorage.Resources)
local DataStore2 = Resources:LoadLibrary("DataStore2")
local DefaultDS = Resources:LoadLibrary("DefaultDS")
local FishHoldIndexer = Resources:LoadLibrary("FishHoldIndexer")
local FloorStats = Resources:LoadLibrary("FloorStats")
local ItemStats = Resources:LoadLibrary("ItemStats")

local module = {}

function updateTank(tankObj, fishList)
    local fishObjsFolder = tankObj:FindFirstChild("FishObjs")
    if not fishObjsFolder then
        fishObjsFolder = Instance.new("Folder", tankObj)
        fishObjsFolder.Name = "FishObjs"
    end
    local collectedCurrentFish = {["Carp"] = {}}
    for _, obj in pairs(fishObjsFolder:GetChildren()) do
        if not collectedCurrentFish[obj.Name] then collectedCurrentFish[obj.Name] = {} end
        table.insert(collectedCurrentFish[obj.Name], 1, obj)
    end
    local function countFish(collectedFish)
        
    end
    for fishName, amount in pairs(fishList) do
        local currentAmount = 0
        if collectedCurrentFish[fishName] then currentAmount = #collectedCurrentFish[fishName] end
        -- if currentAmount > amount then
        --     print("remove")
        --     for i = 1, currentAmount - amount do
        --         local obj = collectedCurrentFish[fishName][currentAmount - (i - 1)]
        --         print("destroy", i)
        --         obj:Destroy()
        --     end
        -- else
        if currentAmount < amount then
            for i = 1, amount - currentAmount do
                local fishObj = Resources:GetAnimal(fishName):Clone()
                fishObj.Parent = fishObjsFolder
                fishObj:SetPrimaryPartCFrame(tankObj.FishHold:GetChildren()[1].CFrame) 
            end
        end
    end
    for fishName, fishObjs in pairs(collectedCurrentFish) do
        local amount = #fishObjs
        local currentAmount = fishList[fishName] or 0
        --if collectedCurrentFish[fishName] then currentAmount = #collectedCurrentFish[fishName] end
        if currentAmount < amount then
            for i = 1, amount - currentAmount do
                local obj = collectedCurrentFish[fishName][amount - (i - 1)]
                obj:Destroy()
            end
        end
        -- else
        --     print("add", currentAmount - amount)
        --     for i = 1, currentAmount - amount do
        --         local fishObj = Resources:GetAnimal(fishName):Clone()
        --         fishObj.Parent = fishObjsFolder
        --         fishObj:SetPrimaryPartCFrame(tankObj.FishHold:GetChildren()[1].CFrame) 
        --     end
        -- end
    end
end

function module:playerProfileAssign(playerProfile)
    local fishObjectsHandler = {}
    
    function fishObjectsHandler:update()
        local fishHoldStore = DataStore2("fishHold", playerProfile.obj)
        local fishHoldCache = fishHoldStore:Get(DefaultDS.fishHold)
        local build1Store = DataStore2("build1", playerProfile.obj)
        local build1Cache = build1Store:Get(DefaultDS.build1)
        -- for fishHoldIndex, fishList in pairs(fishHoldCache) do
        --     local itemType, iPos = FishHoldIndexer.rconvert(fishHoldIndex)
        --     local itemObj
        --     if itemType == "item" then
        --         itemObj = playerProfile.landPlots.obj.Items[iPos]
        --     elseif itemType == "floor" then
        --         itemObj = playerProfile.landPlots.obj.Floors[iPos]
        --     end
        --     updateTank(itemObj, fishList)
        -- end
        for _, itemObj in pairs(playerProfile.landPlots.obj.Items:GetChildren()) do
            local iPos = itemObj.Name

            local itemOwned = build1Cache.items[iPos]
            local itemStat = ItemStats[itemOwned.item]

            if itemStat.fishHold then
                local fishHoldIndex = FishHoldIndexer.convert("item", iPos)
                local fishList = fishHoldCache[fishHoldIndex] or {}
                updateTank(itemObj, fishList)
            end
        end
        for _, itemObj in pairs(playerProfile.landPlots.obj.Floors:GetChildren()) do
            local iPos = itemObj.Name

            local floorOwned = build1Cache.floors[iPos]
            local floorStat = FloorStats[floorOwned.floor]

            if floorStat.fishHold then
                local fishHoldIndex = FishHoldIndexer.convert("floor", iPos)
                local fishList = fishHoldCache[fishHoldIndex] or {}
                updateTank(itemObj, fishList)
            end
        end
    end
    fishObjectsHandler:update()
    
    return fishObjectsHandler
end

return module