local Resources = require(game.ReplicatedStorage.Resources)
local GameLoop = Resources:LoadLibrary("GameLoop")
local Debris = game:GetService("Debris")

local module = {}

return setmetatable(module, {
    __call = function(_, ...)
        local moneySpawnBase, playerProfile = ...

        local loop
        loop = GameLoop.new(function()
            if not moneySpawnBase:IsDescendantOf(game) then
                loop.Enabled = false
                return
            end

            local plot = playerProfile.landPlots.obj -- moneySpawnBase:FindFirstAncestorOfClass("Model").Parent.Parent

            local cashObj = Resources:GetParticle("Cash"):Clone()
            cashObj.Parent = plot
            local claimed = false
            cashObj.Prompt.Value.Triggered:Connect(function(player)
                -- if player ~= playerProfile.obj then return end
                if claimed then return end
                claimed = true
                playerProfile.data:incrVal("money", 5000)
                cashObj:Destroy()
            end)
            Debris:AddItem(cashObj, 60)

            -- local randCF = CFrame.new(Vector3.new(
            --     moneySpawnBase.Position.X + math.random(1, 20) - 10,
            --     0,
            --     moneySpawnBase.Position.Z + math.random(1, 20) - 10
            -- )) * CFrame.Angles(0, math.rad(math.random(1, 360)), 0)
            local randCF = CFrame.new(moneySpawnBase.CFrame * CFrame.Angles(0, math.rad(math.random(1, 360)), 0) * Vector3.new(
                math.random(10, 20)
            )) * CFrame.Angles(0, math.rad(math.random(1, 360)), 0)
            cashObj:SetPrimaryPartCFrame(randCF)
        end, 45)
        GameLoop:handle(loop)
    end;
})