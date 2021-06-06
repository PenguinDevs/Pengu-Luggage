local Resources = require(game.ReplicatedStorage.Resources)
local GameLoop = Resources:LoadLibrary("GameLoop")
local getAmountFromTick = Resources:LoadLibrary("GetAmountFromTick")
local Camera = workspace.CurrentCamera
local RunService = game:GetService("RunService")
local Tween = Resources:LoadLibrary("Tween")
local Enumeration = Resources:LoadLibrary("Enumeration")

local Linear = Enumeration.EasingFunction.Linear.Value

local module = {}

local RandColours = {
    Color3.fromRGB(74, 61, 255),
    Color3.fromRGB(238, 108, 255),
    Color3.fromRGB(56, 176, 255)
}

local Collected = {}

local cos = math.cos
local sin = math.sin
local rad = math.rad
local Vector3New = Vector3.new
local CFAngles = CFrame.Angles
local CFNew = CFrame.new
local Event = RunService.RenderStepped

for _, orbBase in pairs(workspace.Visuals.Orbs:GetChildren()) do
    local stat = {}
    stat.base = orbBase
    if orbBase:FindFirstChild("OrbSpin") then
        stat.orbSpin = {}
        local spinStat = stat.orbSpin
        for i = 1, orbBase.OrbSpin.Value do
            local orb = Resources:GetVisual("Orbs").OrbSpin:Clone()
            orb.Parent = orbBase
            local colour = RandColours[math.random(1, #RandColours)]
            orb.Color = colour
            orb.SpotLight.Color = colour
            orb.Trail.Color = ColorSequence.new({
                ColorSequenceKeypoint.new(0, colour), ColorSequenceKeypoint.new(1, colour)
            })
            math.randomseed(tick() + i)
            local randDist = math.random(400, 700)/100
            local randAngle = math.random(30, 150) - 90
            local randTime = math.random(0, 100)/10
            local randSpeed = math.random(10, 30)/10
            local spinStat = {
                obj = orb;
                dist = randDist;
                angle = randAngle;
                t = randTime;
                speed = randSpeed;
            }
            table.insert(spinStat, 1, spinStat)

            spawn(function()
                local tween = Tween.new(randSpeed * 10, Linear, function(amount)
                    amount *= 10
                    if (orbBase.Position - Camera.CFrame.p).magnitude > 100 then return end
                    spinStat.obj.Position = (orbBase.CFrame * CFAngles(0, rad(360 * amount), 0))
                        * Vector3New(
                            cos(rad(spinStat.angle)) * spinStat.dist,
                            sin(rad(spinStat.angle)) * spinStat.dist,
                            0
                        )
                end)
                while true do
                    
                    --while tween.Running do wait(0.5) end end
                    while tween.Running do Event:Wait() wait(2) end
                    tween:Restart()
                end
            end)
        end
    end
    if orbBase:FindFirstChild("CubeSpin") then
        stat.cubeSpin = {}
        local spinStat = stat.cubeSpin
        for i = 1, orbBase.CubeSpin.Value do
            local cube = Resources:GetVisual("Orbs").CubeSpin:Clone()
            cube.Parent = orbBase
            local colour = RandColours[i] or RandColours[math.random(1, #RandColours)]
            cube.Color = colour
            math.randomseed(tick() + i)
            local randAngles = Vector3.new(math.random(400, 800)/100, math.random(400, 800)/100, math.random(400, 800)/100)
            local spinStat = {
                obj = cube;
                angles = randAngles;
            }
            spinStat.obj.Position = orbBase.Position
            table.insert(spinStat, 1, spinStat)

            spawn(function()
                local tween = Tween.new(math.random(150, 200)/10 * 10, Linear, function(amount)
                    amount *= 10
                    if (orbBase.Position - Camera.CFrame.p).magnitude > 100 then return end
                    spinStat.obj.CFrame = CFNew(orbBase.Position) * CFAngles(
                        rad((amount + randAngles.X) * 360),
                        rad((amount + randAngles.Y) * 360),
                        rad((amount + randAngles.Z) * 360)
                    )
                    -- spinStat.obj.Orientation = Vector3.new(
                    --     (amount + randAngles.X) * 360,
                    --     (amount + randAngles.Y) * 360,
                    --     (amount + randAngles.Z) * 360
                    -- )
                end)
                while true do
                    -- local tween = Tween.new(5, Linear, function()
                    --     if (orbBase.Position - Camera.CFrame.p).magnitude > 100 then return end
                    --     local finalAngles = {x = 0, y = 0, z = 0}
                    --     local function getSpinAngle(angle, influence)
                    --         local amount = getAmountFromTick(influence)
                    --         print(amount)
                    --         finalAngles[angle] = amount * 360
                    --     end
                    --     getSpinAngle("x", spinStat.angles.X)
                    --     getSpinAngle("y", spinStat.angles.Y)
                    --     getSpinAngle("z", spinStat.angles.Z)
                    --     --spinStat.obj.CFrame = CFrame.new(orbBase.Position) * CFrame.Angles(finalAngles.x, finalAngles.y, finalAngles.z)
                    --     spinStat.obj.Position = orbBase.Position
                    --     spinStat.obj.Orientation = Vector3New(finalAngles.x, finalAngles.y, finalAngles.z)
                    -- end)
                    while tween.Running do Event:Wait() wait(2) end
                    tween:Restart()
                end
            end)
        end
    end
    
    Collected[orbBase] = stat
end

-- module.update = GameLoop.new(function()
--     for _, orbBase in pairs(workspace.Visuals.Orbs:GetChildren()) do
--         if (orbBase.Position - Camera.CFrame.p).magnitude > 100 then wait(1) continue end
--         local stat = Collected[orbBase]
--         -- if stat.orbSpin then
--         --     for _, spinStat in pairs(stat.orbSpin) do
--         --         wait()
--         --         local amount = getAmountFromTick(spinStat.speed, spinStat.t)/spinStat.speed
--         --         spinStat.obj.Position = (orbBase.CFrame * CFrame.Angles(0, 360 * amount, 0)) * Vector3.new(math.cos(math.rad(spinStat.angle)) * spinStat.dist, math.sin(math.rad(spinStat.angle)) * spinStat.dist, 0)
--         --     end
--         -- end
--         if stat.cubeSpin then
--             for _, spinStat in pairs(stat.cubeSpin) do
--                 local finalAngles = {x = 0, y = 0, z = 0}
--                 local function getSpinAngle(angle, influence)
--                     local amount = getAmountFromTick(influence)
--                     print(amount)
--                     finalAngles[angle] = amount * 360
--                 end
--                 getSpinAngle("x", spinStat.angles.X)
--                 getSpinAngle("y", spinStat.angles.Y)
--                 getSpinAngle("z", spinStat.angles.Z)
--                 --spinStat.obj.CFrame = CFrame.new(orbBase.Position) * CFrame.Angles(finalAngles.x, finalAngles.y, finalAngles.z)
--                 spinStat.obj.Position = orbBase.Position
--                 spinStat.obj.Orientation = Vector3.new(finalAngles.x, finalAngles.y, finalAngles.z)
--             end
--         end
--     end
--     --RunService.RenderStepped:Wait()
-- end, 0) --, "OrbsMovement")

return module