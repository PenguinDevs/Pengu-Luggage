local module = {}

local Resources = require(game.ReplicatedStorage.Resources)
local Player = game.Players.LocalPlayer
local RunService = game:GetService("RunService")
local Signal = Resources:LoadLibrary("Signal")

module.floorUpdated = Signal.new()

module.currentFloor = nil

RunService.Heartbeat:Connect(function()
    if not Player.Character then return end
    if not Player.Character:FindFirstChild("HumanoidRootPart") then return end
    local raycastParams = RaycastParams.new()
    raycastParams.FilterType = Enum.RaycastFilterType.Blacklist
    raycastParams.FilterDescendantsInstances = {workspace.Players}
    raycastParams.IgnoreWater = true

    local floorCastResult = workspace:Raycast(Player.Character.HumanoidRootPart.Position, Vector3.new(0, -5, 0), raycastParams)
    if floorCastResult then
        local target = floorCastResult.Instance
        if module.currentFloor ~= target then
            module.currentFloor = target
            module.floorUpdated:Fire()
        end
        return
    end
    if module.currentFloor ~= nil then
        module.currentFloor = nil
        module.floorUpdated:Fire()
    end
end)

return module
