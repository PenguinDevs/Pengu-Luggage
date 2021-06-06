local Resources = require(game.ReplicatedStorage.Resources)
local Signal = Resources:LoadLibrary("Signal")
local RunService = game:GetService("RunService")
local FishStats = Resources:LoadLibrary("FishStats")
local Tween = Resources:LoadLibrary("Tween")
local Enumeration = Resources:LoadLibrary("Enumeration")
local Janitor = Resources:LoadLibrary("Janitor")
local VectorTable = Resources:LoadLibrary("VectorTable")
local Table = Resources:LoadLibrary("Table")
local Camera = workspace.CurrentCamera
local Status = Resources:LoadLibrary("Status")
local FishHoldIndexer = Resources:LoadLibrary("FishHoldIndexer")
local TweenService = game:GetService("TweenService")

local referencePart = Instance.new("Part")

local InOutSine = Enumeration.EasingFunction["InOutSine"].Value
local Linear = Enumeration.EasingFunction["Linear"].Value

local Event = RunService.RenderStepped

local module = {}
module.__index = module

local DEBUG = false

local Collected = {}

module.ON = false

module.RefreshAnimations = Signal.new()

local KillAll = Signal.new()

function module.new(fishObj, tankObj)
    --if true then return end
    -- local oldFishObj = fishObj
    -- fishObj = Resources:GetAnimal(oldFishObj.Name):Clone()
    -- fishObj.Parent = oldFishObj.Parent.Parent
    -- --fishObj:SetPrimaryPartCFrame(oldFishObj.PrimaryPart.CFrame)
    -- fishObj:SetPrimaryPartCFrame(tankObj.FishHold:GetChildren()[1].CFrame)
    -- --print(fishObj.PrimaryPart.Position, tankObj.FishHold:GetChildren()[1].Position)
    -- oldFishObj:SetPrimaryPartCFrame(CFrame.new(0, 0, -10000))
    -- oldFishObj.AncestryChanged:Connect(function()
    --     if not oldFishObj:IsDescendantOf(game) then
    --         fishObj:Destroy()
    --     end
    -- end)

    Collected[fishObj] = {
        fish = fishObj;
        tank = tankObj;
    }
    if module.ON then
        module:spawnFish(fishObj, tankObj)
    end
end

function module:spawnFish(fishObj, tankObj)
    --if true then return end
    local fish = setmetatable({}, module)
    fish.janitor = Janitor.new()

    fish.obj = fishObj
    fish.tankObj = tankObj
    fish.alive = true
    fish.cfs = {}
    --for i = 1, 100 do wait() if fishObj.PrimaryPart then break end end
    if not fishObj.PrimaryPart then fishObj:GetPropertyChangedSignal("PrimaryPart"):Wait() end
    fish.cfs.pos = CFrame.new(tankObj.FishHold:GetChildren()[1].Position)
    fish.cfs.rot = CFrame.Angles(0, 0, 0)

    local fishStat = FishStats[fishObj.Name]

    -- if not fish.bp and not fish.bg then
    --     fish.bp = Instance.new("BodyPosition", fishObj.PrimaryPart)
    --     fish.bp.D = 2500
    --     fish.bp.Position = tankObj.FishHold:GetChildren()[1].Position
    --     fish.bg = Instance.new("BodyGyro", fishObj.PrimaryPart)
    --     fish.bg.D = 600
    --     for _, obj in pairs(fishObj:GetDescendants()) do
    --         if obj:IsA("BasePart") then obj.Anchored = false obj.CanCollide = true end
    --     end
    --     fishObj.PrimaryPart.CanCollide = true
    -- end

    spawn(function()
        local function loadAnimation()
            local animation = fishObj:FindFirstChildOfClass("Animation") or Instance.new("Animation")
            animation.AnimationId = fishStat.primaryAnim
            animation.Parent = fishObj
            local animationController = fishObj:WaitForChild("AnimationController")
            fish.animTrack = animationController:LoadAnimation(animation)
            fish.animTrack:Play()
        end
        if not Collected[fishObj].animTrack then
           loadAnimation()
        elseif not Collected[fishObj].animTrack.IsPlaying then
            Collected[fishObj].animTrack:Play()
        end
    end)
    
    spawn(function()
        if not Collected[fishObj].event then
            Collected[fishObj].event = fishObj.AncestryChanged:Connect(function()
                if not fishObj:IsDescendantOf(game) then
                    fish:Destroy()
                    Collected[fishObj] = nil
                end
            end)
        end
    end)

    fish:loadMovementBehaviour(tankObj.FishHold, fish)

    --fish.janitor:Add(RunService.RenderStepped:Connect(function()
        -- local finalCF = CFrame.new(0, 0, 0)
        -- for _, cf in pairs(fish.cfs) do
        --     finalCF *= cf
        -- end
        --print(fish.cfs.rot)
    -- spawn(function() while true do
    --     wait()
    --     RunService.Heartbeat:Wait()
    --     local finalCF = fish.cfs.pos * fish.cfs.rot
    --     local fishToChar = finalCF.p - workspace.CurrentCamera.CFrame.p
    -- 	local fishLookVec = (Camera.CFrame * CFrame.Angles(0, 0, 0)).lookVector
    -- 	if fishToChar:Dot(fishLookVec) > 0 then
    --         if fishToChar.Magnitude > 100 then
    --             fishObj:SetPrimaryPartCFrame(CFrame.new(0, 0, -10000))
    --             wait(2)
    --         else
    --             fishObj:SetPrimaryPartCFrame(finalCF)
    --             print("show")
    --         end
    --     else
    --         fishObj:SetPrimaryPartCFrame(CFrame.new(0, 0, -10000))
    --         wait(2)
    --     end
    -- end end)

    --end), "Disconnect")

    local listen
    listen = KillAll:Connect(function()
        fish.alive = false
        fish.obj:SetPrimaryPartCFrame(CFrame.new(0, 0, -10000))
        if fish.animTrack then
            fish.animTrack:Stop()
        end
        listen:Disconnect()
    end)

    return fish
end

function module:toggleFishes(on)
    if on == module.ON then return end
    module.ON = on
    if module.ON then
        for _, fishInfo in pairs(Collected) do
            if not fishInfo.fish.PrimaryPart then fishInfo.fish:GetPropertyChangedSignal("PrimaryPart"):Wait() end
            fishInfo.fish:SetPrimaryPartCFrame(CFrame.new(fishInfo.tank.FishHold:GetChildren()[1].Position))
            module:spawnFish(fishInfo.fish, fishInfo.tank)
        end
    else
        KillAll:Fire()
    end
end

local function tweenFishCF(t, i, cf, time, extraFunc)
    local origCF = t[i]
    if (origCF.p - cf.p).magnitude <= 0 then return end -- possible NaN
    local val = Instance.new("CFrameValue")
    val.Value = origCF
    local listen
    listen = val.Changed:Connect(function()
        t[i] = val.Value
        if extraFunc then extraFunc() end
    end)
    spawn(function()
        --Tween(val, "Value", cf, InOutSine, time):Wait()
        local tween = TweenService:Create(val, TweenInfo.new(time, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {Value = cf})
        tween:Play()
        tween.Completed:Wait()
        tween:Cancel()
        tween:Destroy()
        listen:Disconnect()
        val:Destroy()
        t[i] = cf
    end)
end

function module:loadMovementBehaviour(areasFolder, fish)
    spawn(function()
        local plot = areasFolder:FindFirstAncestorOfClass("Folder").Parent
        local lastFlooriPos
        -- if areasFolder:IsDescendantOf(plot.Floors) then -- UNCOMMENT TO ENABLE MOVE TO OTHER FLOOR TANKS
        --     lastFlooriPos = areasFolder.Parent.Name
        -- end
        local function randPos()
            if lastFlooriPos then
                local pos = VectorTable.rconvert(lastFlooriPos)
                local posList = {
                    pos + Vector2.new(1, 0);
                    pos + Vector2.new(0, 1);
                    pos + Vector2.new(-1, 0);
                    pos + Vector2.new(0, -1);
                }
                Table.Shuffle(posList)
                for _, pos in pairs(posList) do
                    local iPos = VectorTable.convert(pos)
                    if not plot:FindFirstChild("Floors") then return end
                    local tankObj = plot.Floors:FindFirstChild(iPos)
                    if tankObj then
                        if tankObj:FindFirstChild("FishHold") then
                            areasFolder = tankObj.FishHold
                            lastFlooriPos = iPos
                            break
                        end
                    end
                end
            end
            local objsList = areasFolder:GetChildren()
            local randObj = objsList[math.random(1, #objsList)]
            local offsetX = 0
            local offsetZ = 0
            local offsetY = 0
            local fishCF, fishSize = fish.obj:GetBoundingBox()
            offsetX = (fishSize.Z > fishSize.X) and fishSize.Z or fishSize.X
            offsetZ = (fishSize.Z > fishSize.X) and fishSize.Z or fishSize.X
            offsetY = fishSize.Y

            local function getRandPosAxis(obj, offset, axis, axisSize)
                local sizeAxis = axisSize or axis
                -- if axisSize then
                --     if obj.Size.X > obj.Size.Z then
                --         sizeAxis = "X"
                --     else
                --         sizeAxis = "Z"
                --     end
                -- end
                --print(obj.Size[sizeAxis]/2 - 0.05)
                if obj.Size[sizeAxis]/2 < 1 then return obj.Position[axis] end
                offset = math.clamp(offset, 0, obj.Size[sizeAxis]/2 - 0.05)
                return math.random(
                    obj.Position[axis] - obj.Size[sizeAxis]/2 + offset,
                    obj.Position[axis] + obj.Size[sizeAxis]/2 - offset
                )
            end
            local xPos
            local zPos
            if randObj.Orientation.Y == 180 or randObj.Orientation.Y == 0 then
                xPos = getRandPosAxis(randObj, offsetX, "X")
                zPos = getRandPosAxis(randObj, offsetZ, "Z")
            else
                xPos = getRandPosAxis(randObj, offsetX, "X", "Z")
                zPos = getRandPosAxis(randObj, offsetZ, "Z", "X")
            end
            local yPos = getRandPosAxis(randObj, offsetY, "Y")
            local v3Pos = Vector3.new(xPos, yPos, zPos)
            return v3Pos
        end

        fish.cfs.pos = CFrame.new(randPos())
        fish.cfs.rot = CFrame.Angles(0, math.rad(math.random(1, 360)), 0)
        local initCF = fish.cfs.pos * fish.cfs.rot
        fish.obj:SetPrimaryPartCFrame(initCF)
        -- if true then return end

        local function updateAnimation()
            local fishToChar = fish.cfs.pos.p - workspace.CurrentCamera.CFrame.p
            if fishToChar.Magnitude > 2000 then
                if fish.animTrack then
                    if fish.animTrack.IsPlaying then
                        fish.animTrack:Stop()
                        print("stopped fish animation")
                    end
                end
            else
                if fish.animTrack then
                    if not fish.animTrack.IsPlaying then
                        fish.animTrack:Play()
                        print("playing fish animation")
                    end
                end
            end
        end
        fish.janitor:Add(module.RefreshAnimations:Connect(updateAnimation), "Disconnect")

        spawn(function()
            local lastDist = 0
            local lastCFPos = fish.cfs.pos
            local speed = 1
            while true do
                if not fish.alive then break end
                local v3Pos = randPos()
                wait(math.random(80, 100)/10 + lastDist * speed)
                local finalCF = fish.cfs.pos * fish.cfs.rot
                local fishToChar = finalCF.p - workspace.CurrentCamera.CFrame.p
                local fishLookVec = (Camera.CFrame * CFrame.Angles(0, 0, 0)).lookVector
                updateAnimation()
                if fishToChar:Dot(fishLookVec) > 0 then
                    if fishToChar.Magnitude > 20 then
                        wait(60)
                    else
                        -- continue from here, no waits
                    end
                else
                    wait(60)
                end
                if not fish.alive then break end
                lastDist = (v3Pos - fish.obj.PrimaryPart.Position).magnitude
                local dirX, dirY, dirZ = CFrame.new(fish.obj.PrimaryPart.Position, v3Pos):ToEulerAnglesXYZ()
                local lastDirX, lastDirY, lastDirZ = fish.cfs.rot:ToEulerAnglesXYZ()
                local rotDiff = (Vector3.new(dirX, dirY, dirZ) - Vector3.new(lastDirX, lastDirY, lastDirZ)).magnitude
                --print(rotDiff)

                local rotSpeed = 0.6
                referencePart.CFrame = CFrame.Angles(dirX, dirY, dirZ)
                local cfRot = CFrame.Angles(0, math.rad(referencePart.Orientation.Y), 0)
                tweenFishCF(fish.cfs, "rot", cfRot, rotDiff * rotSpeed)

                if lastDist > 1 then
                    tweenFishCF(fish.cfs, "pos", CFrame.new(v3Pos), lastDist * speed, function()
                        if not fish.alive then return end
                        local finalCF = fish.cfs.pos * fish.cfs.rot
                        fish.obj:SetPrimaryPartCFrame(finalCF)
                    end)
                end
                -- --local cfRot = CFrame.Angles(math.rad(360 * dir.X), math.rad(360 * dir.Y), math.rad(360 * dir.Z))

                -- fish.bp.Position = v3Pos
                -- fish.bg.CFrame = cfRot
                

                -- local tween = Tween.new(lastDist * speed, Linear, function()
                --     if not fish.alive then return end
                --     local finalCF = fish.cfs.pos * fish.cfs.rot
                --     fish.obj:SetPrimaryPartCFrame(finalCF)
                -- end)
                -- spawn(function()
                    
                -- end)
                
                if DEBUG then
                    local debugPart = Instance.new("Part", workspace)
                    debugPart.Anchored = true
                    debugPart.Material = Enum.Material.Neon
                    debugPart.BrickColor = BrickColor.new("Really Red")
                    debugPart.Position = v3Pos
                    debugPart.Size = Vector3.new(0.4, 0.4, 0.4)
                end
                if DEBUG then
                    local debugPart = Instance.new("Part", workspace)
                    debugPart.Anchored = true
                    debugPart.Material = Enum.Material.Neon
                    debugPart.Color = Color3.fromRGB(255, 0, 0)
                    local distance = (lastCFPos.p - v3Pos).magnitude
                    debugPart.Size = Vector3.new(0.1, 0.1, distance)
                    debugPart.CFrame = CFrame.new(lastCFPos.p - Vector3.new(0, 0.05, 0), v3Pos - Vector3.new(0, 0.05, 0)) * CFrame.new(0, 0, -distance / 2)
                end
                lastCFPos = CFrame.new(v3Pos)
            end
        end)

        -- spawn(function()
        --     while true do
        --         if not fish.alive then break end
        --         local finalCF = fish.cfs.pos * fish.cfs.rot
        --         local fishToChar = finalCF.p - workspace.CurrentCamera.CFrame.p
        --         local fishLookVec = (Camera.CFrame * CFrame.Angles(0, 0, 0)).lookVector
        --         if fishToChar:Dot(fishLookVec) > 0 then
        --             if fishToChar.Magnitude > 100 then
        --                 wait(4)
        --             else
        --                 local tween = Tween.new(10, Linear, function(amount)
        --                     if not fish.alive then return end
        --                     local finalCF = fish.cfs.pos * fish.cfs.rot
        --                     fish.obj:SetPrimaryPartCFrame(finalCF)
        --                 end)
        --                 while tween.Running do
        --                     Event:Wait()
        --                     wait(2)
        --                 end
        --                 tween:Stop()
        --             end
        --         else
        --             wait(4)
        --         end
        --     end
        -- end)
    end)
end

function module:Destroy()
    self.alive = false
    if self.animTrack then
        self.animTrack:Destroy()
        self.animTrack = nil
    end
    self = nil
end

return module