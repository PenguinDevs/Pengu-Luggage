local Resources = require(game.ReplicatedStorage.Resources)
local GameLoop = Resources:LoadLibrary("GameLoop")
local Camera = workspace.CurrentCamera
local Tween = Resources:LoadLibrary("Tween")
local Enumeration = Resources:LoadLibrary("Enumeration")

local Linear = Enumeration.EasingFunction.Linear.Value

local module = {}

local Collected = {}

for _, plot in pairs(workspace.Game.PlayerPlots:GetChildren()) do
	for _, waveObj in pairs(plot.Visuals.WaterWaves:GetChildren()) do
		local pos = waveObj.Position
        pos = Vector3.new(pos.x, pos.y-0.2, pos.z)
        local x = 0
        local z = 0
        local T = -99999
        local tall = 5
        math.randomseed(tick())
        local rand = (math.random(0,20))/1
        Collected[waveObj] = {
            pos = pos;
            tall = tall;
            T = T;
            x = x;
            z = z;
            y = pos.Y
        }
    end
end

local function perform(waveObj)
    --if (waveObj.Position - Camera.CFrame.p).magnitude > 100 then return end
    local stat = Collected[waveObj]
    stat.x = stat.pos.x + ((math.sin(stat.T + (stat.pos.x/3)) * math.sin(stat.T/70))/15) * 20
    stat.z = stat.pos.z + ((math.sin(stat.T + (stat.pos.z/4)) * math.sin(stat.T/10))/12) * 20
    waveObj.CFrame = CFrame.new(stat.x, stat.y, stat.z) --* CFrame.Angles((stat.z-stat.pos.z)/stat.tall, 0,(stat.x-stat.pos.x)/-stat.tall)
    stat.T = stat.T + 0.03
end

for _, plot in pairs(workspace.Game.PlayerPlots:GetChildren()) do
    for _, waveObj in pairs(plot.Visuals.WaterWaves:GetChildren()) do
        spawn(function()
            while true do
                local tween = Tween.new(5, Linear, function()
                    perform(waveObj)
                end)
                while true do wait() if not tween.Running then break end end
            end
        end)
    end
end

-- module.update = GameLoop.new(function()
--     local function perform(waveObj)
--         --if (waveObj.Position - Camera.CFrame.p).magnitude > 100 then return end
--         local stat = Collected[waveObj]
--         stat.x = stat.pos.x + ((math.sin(stat.T + (stat.pos.x/3)) * math.sin(stat.T/70))/15) * 20
--         stat.z = stat.pos.z + ((math.sin(stat.T + (stat.pos.z/4)) * math.sin(stat.T/10))/12) * 20
--         waveObj.CFrame = CFrame.new(stat.x, stat.y, stat.z) --* CFrame.Angles((stat.z-stat.pos.z)/stat.tall, 0,(stat.x-stat.pos.x)/-stat.tall)
--         stat.T = stat.T + 0.03
--     end
--     -- for _, waveObj in pairs(workspace.Visuals.WaterWaves:GetChildren()) do
--     --     perform(waveObj)
--     -- end
--     for _, plot in pairs(workspace.Game.PlayerPlots:GetChildren()) do
-- 		for _, waveObj in pairs(plot.Visuals.WaterWaves:GetChildren()) do
-- 			perform(waveObj)
-- 		end
-- 	end
-- end, 0, "WavesMovement")

return module