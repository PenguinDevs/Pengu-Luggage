local module = {}

local Resources = require(game.ReplicatedStorage.Resources)
local Round = Resources:LoadLibrary("Round")
local ScaleModel = Resources:LoadLibrary("ScaleModel")

local randInt = 0

local function getRandomInPart(part, offset)
    local MinX, MaxX = part.Position.X - part.Size.X/2 + offset.X/2, part.Position.X + part.Size.X/2 - offset.X/2
    local MinZ, MaxZ = part.Position.Z - part.Size.Z/2 + offset.Z/2, part.Position.Z + part.Size.Z/2 - offset.Z/2
    -- print(MinX, MaxX)
    -- print(MinZ, MaxZ)

    local RNG = Random.new()
    local RandomX = RNG:NextNumber(MinX, MaxX)
	local RandomZ = RNG:NextNumber(MinZ, MaxZ)
    
    return Vector3.new(RandomX, part.Position.Y, RandomZ)
end


function module:decorTank(itemStat, itemObj)
    local placeAmount = Round(itemStat.size.magnitude/5)
    --print(placeAmount)
    local decorItems = Resources:GetBuildItem("TankDecors"):GetChildren()
    local sandBaseFolder = itemObj.SandBase:GetChildren()
    for i = 1, placeAmount do
        randInt += 1
        --math.randomseed(tick() - i * randInt)
        local sandObj = sandBaseFolder[math.random(1, #sandBaseFolder)]
        local randObj
        local function getRandObj()
            return decorItems[math.random(1, #decorItems)]
        end
        for i2 = 1, 50 do
            randInt += 1
            --math.randomseed(tick() - i2 * i * randInt)
            randObj = getRandObj()
            local cf, size = randObj:GetBoundingBox()
            local sandSize = sandObj.Size
            -- print(sandSize.X, size.X)
            -- print(sandSize.Z, size.Z)
            -- print("i", i)
            if sandSize.X > size.X and sandSize.Z > size.Z then break end
            if sandSize.X > size.Z and sandSize.Z > size.X then break end
        end
        --print(randObj, sandObj)
        randObj = randObj:Clone()
        randObj.Parent = itemObj
        ScaleModel:scaleModel(randObj, itemStat.scaleDecor)

        local cf, size = randObj:GetBoundingBox()

        local targetCF = CFrame.new(getRandomInPart(sandObj, size)) * CFrame.Angles(0, math.rad(math.random(1, 360)), 0)
        randObj:SetPrimaryPartCFrame(targetCF)
    end
end

return module