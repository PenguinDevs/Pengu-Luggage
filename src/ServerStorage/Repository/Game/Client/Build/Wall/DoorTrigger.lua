local Resources = require(game.ReplicatedStorage.Resources)
local FloorCast = Resources:LoadLibrary("FloorCast")

local module = {}

local oldDoor

function module:init()
    FloorCast.floorUpdated:Connect(function()
        local obj = FloorCast.currentFloor
        local finalDoor
        if obj then
            if obj.Name == "FloorDoorTrigger" then
                local remote = obj.Parent:FindFirstChild("RequestTrigger")
                if remote then
                    remote:FireServer(true)
                    finalDoor = obj.Parent
                end
            end
        end

        if finalDoor ~= oldDoor then
            if oldDoor then
                oldDoor.RequestTrigger:FireServer(false)
            end
            oldDoor = finalDoor
        end
    end)
end

return module