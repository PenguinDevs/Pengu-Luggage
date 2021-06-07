local module = {}

local Resources = require(game.ReplicatedStorage.Resources)
local GameLoop = Resources:LoadLibrary("GameLoop")
local Player = game.Players.LocalPlayer

function module:scanPlayers()
    if not Player.Character then return end
    local origRootPart = Player.Character:FindFirstChild("HumanoidRootPart")
    if not origRootPart then return end
    for _, player in pairs(game.Players:GetPlayers()) do
        if not player.Character then continue end
        local rootPart = player.Character:FindFirstChild("HumanoidRootPart")
        if not rootPart then continue end
        -- print((origRootPart.Position - rootPart.Position).Magnitude)
        if (origRootPart.Position - rootPart.Position).Magnitude > 1000 then
            if not player.Character:IsDescendantOf(game.Lighting) then
                print(string.format("Reparenting %s to lighting", tostring(player)))
                player.Character.Parent = game.Lighting
            end
        else
            if not player.Character:IsDescendantOf(workspace.Players) then
                print(string.format("Reparenting %s to workspace Players folder", tostring(player)))
                player.Character.Parent = workspace.Players
            end
        end
    end
end

module.update = GameLoop.new(module.scanPlayers, 3)

return module