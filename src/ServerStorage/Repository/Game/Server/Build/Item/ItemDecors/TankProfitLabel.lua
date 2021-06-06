local module = {}

local Resources = require(game.ReplicatedStorage.Resources)
local DataStore2 = Resources:LoadLibrary("DataStore2")
local DefaultDS = Resources:LoadLibrary("DefaultDS")
local FishHoldIndexer = Resources:LoadLibrary("FishHoldIndexer")
local FishStats = Resources:LoadLibrary("FishStats")
local TextLoader = Resources:LoadLibrary("TextLoader")

function module:getLabel(playerProfile, tankObj, overrideFishHold)
    if not tankObj then return end
    local gui = tankObj:FindFirstChild("PriceGui")
    if not gui then
        gui = Resources:GetVisual("PriceGui"):Clone()
        gui.Parent = tankObj
        gui.Adornee = tankObj.PrimaryPart
        gui.Parent = tankObj
    end
    
    local fishHold
    if not overrideFishHold then
        local itemType = (tankObj.Parent.Name == "Items" and "item") or (tankObj.Parent.Name == "Floors" and "floor")
        local fishHoldIndex = FishHoldIndexer.convert(itemType, tankObj.Name)
        
        local fishHoldStore = DataStore2("fishHold", playerProfile.obj)
        local fishHoldCache = fishHoldStore:Get(DefaultDS.fishHold)
        fishHold = fishHoldCache[fishHoldIndex]
    else
        fishHold = overrideFishHold
    end
    local tankIncome = 0
    if fishHold then
        for fishName, fishAmount in pairs(fishHold) do
            local fishStat = FishStats[fishName]
            tankIncome += fishStat.profit * fishAmount
        end
        if playerProfile.passes["2x Money"] then tankIncome *= 2 end
    end

    gui.TextLabel.Text = "$" .. TextLoader:ConvertShort(tankIncome) .. "/min"
end

return module