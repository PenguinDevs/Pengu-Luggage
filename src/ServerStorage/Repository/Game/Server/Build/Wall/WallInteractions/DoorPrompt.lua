local Resources = require(game.ReplicatedStorage.Resources)
local ServerTween = Resources:LoadLibrary("STweenS")

local module = {}

return setmetatable(module, {
    __call = function(_, ...)
        local promptVal = ...
        local prompt = promptVal.Value
        local doorObj = promptVal.DoorObj.Value
        local hingeObj = doorObj.Hinge

        local opened = false

        -- local doorCF, doorSize = doorObj:GetBoundingBox()

        -- local doorCentreObj = Instance.new("Part", doorObj)
        -- doorCentreObj.Anchored = true
        -- doorCentreObj.CanCollide = false
        -- doorCentreObj.Transparency = 1
        -- doorCentreObj.CFrame = doorCF
        -- doorObj.PrimaryPart = doorCentreObj

        -- local initOffset = hingeObj.Position - doorCentreObj.Position

        local initCF = doorObj.PrimaryPart.CFrame

        local function triggerDoor(player, override)
            local char
            if player then char = player.Character end
            opened = override or not opened
            if opened then
                local doorToChar = char.HumanoidRootPart.Position - initCF.p
                local doorLookVec = (initCF * CFrame.Angles(0, math.rad(-90), 0)).lookVector
                local cf
                if doorToChar:Dot(doorLookVec) > 0 then
                    cf = initCF * CFrame.Angles(0, math.rad(80), 0)
                else
                    cf = initCF * CFrame.Angles(0, math.rad(-80), 0)
                end
                ServerTween:tweenAllClients(doorObj, "modelCF", cf, 0.2, Enum.EasingStyle.Cubic, Enum.EasingDirection.In)
                prompt.ActionText = "Close"
            else
                local cf = initCF
                ServerTween:tweenAllClients(doorObj, "modelCF", cf, 0.2, Enum.EasingStyle.Cubic, Enum.EasingDirection.In)
                prompt.ActionText = "Open"
            end
        end

        -- prompt.Triggered:Connect(triggerDoor)

        local remote = Instance.new("RemoteEvent", doorObj.Parent)
        remote.Name = "RequestTrigger"
        remote.OnServerEvent:Connect(triggerDoor)

        local floorTrigger = Instance.new("Part", doorObj.Parent)
        floorTrigger.Name = "FloorDoorTrigger"
        floorTrigger.CanCollide = false
        floorTrigger.Size = Vector3.new(16, 1, 16)
        floorTrigger.Position = doorObj.Parent.PrimaryPart.Position + Vector3.new(0, -6.5, 0)
        floorTrigger.Anchored = true
        floorTrigger.Transparency = 1
    end;
})