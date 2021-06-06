local Resources = require(game.ReplicatedStorage.Resources)

local module = {}

for _, character in pairs(workspace.Visuals.Animations:GetChildren()) do
    local humanoid = character:FindFirstChildOfClass("Humanoid") or character:FindFirstChildOfClass("AnimationController")
    local animation = character:FindFirstChildOfClass("Animation")
    humanoid:LoadAnimation(animation):Play()
end

return module
