local Resources = require(game.ReplicatedStorage.Resources)
local GameLoop = Resources:LoadLibrary("GameLoop")
local Debris = game:GetService("Debris")
local DataStore2 = Resources:LoadLibrary("DataStore2")
local DefaultDS = Resources:LoadLibrary("DefaultDS")
local GetCustomerAmount = Resources:LoadLibrary("GetCustomerAmount")
local FloorStats = Resources:LoadLibrary("FloorStats")

local module = {}

local function getRandomInPart(part, offset)
    local MinX, MaxX = part.Position.X - part.Size.X/2, part.Position.X + part.Size.X/2
    local MinZ, MaxZ = part.Position.Z - part.Size.Z/2, part.Position.Z + part.Size.Z/2
    -- print(MinX, MaxX)
    -- print(MinZ, MaxZ)

    local RNG = Random.new()
    local RandomX = RNG:NextNumber(MinX, MaxX)
	local RandomZ = RNG:NextNumber(MinZ, MaxZ)
    
    return Vector3.new(RandomX, part.Position.Y, RandomZ)
end

function module:playerProfileAssign(playerProfile)
    local incomeHandler = {}

    local build1Store = DataStore2("build1", playerProfile.obj)
    local spawnLoop
    spawnLoop = GameLoop.new(function()
        if not playerProfile.obj:IsDescendantOf(game) then spawnLoop.Enabled = false return end

        local build1Cache = build1Store:Get(DefaultDS.build1)

        for floorPos, floorOwned in pairs(build1Cache.floors) do
            local floorStat = FloorStats[floorOwned.floor]
            if floorStat.fishHold then continue end
            if math.random(1, 60) == 1 then
                local walletObj = Resources:GetParticle("Wallet"):Clone()

                walletObj.Parent = playerProfile.landPlots.obj
        
                local plot = playerProfile.landPlots.obj
                -- local floorFolder = plot.Floors:GetChildren()
                -- local randFloor = floorFolder[math.random(1, #floorFolder)]
                local randFloor = plot.Floors[floorPos]
                local randPos = getRandomInPart(randFloor.PrimaryPart)
        
                walletObj:SetPrimaryPartCFrame(CFrame.new(randPos) * CFrame.fromOrientation(0, math.random(1, 360), 0))
        
                local claimed = false
                walletObj.Prompt.Value.Triggered:Connect(function(player)
                    -- if player ~= playerProfile.obj then return end
                    if claimed then return end
                    claimed = true
                    local customerAmount = GetCustomerAmount(build1Store:Get(DefaultDS.build1)) --build1Cache)
                    playerProfile.data:incrVal("money", customerAmount * 30)
                    walletObj:Destroy()
                end)
                Debris:AddItem(walletObj, 120)
            end
        end
        -- local walletObj = Resources:GetParticle("Wallet"):Clone()

        -- walletObj.Parent = playerProfile.landPlots.obj

        -- local plot = playerProfile.landPlots.obj
        -- local floorFolder = plot.Floors:GetChildren()
        -- local randFloor = floorFolder[math.random(1, #floorFolder)]
        -- local randPos = getRandomInPart(randFloor.PrimaryPart)

        -- walletObj:SetPrimaryPartCFrame(CFrame.new(randPos) * CFrame.fromOrientation(0, math.random(1, 360), 0))

        -- walletObj.Prompt.Value.Triggered:Connect(function()
        --     local customerAmount = GetCustomerAmount()
        --     playerProfile.data:incrVal("money", customerAmount * 20)
        --     walletObj:Destroy()
        -- end)
        -- Debris:AddItem(walletObj, 120)
    end, 20, "WalletLoop:" .. playerProfile.obj.Name)

    GameLoop:handle(spawnLoop)

    return incomeHandler
end

return module