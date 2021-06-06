local module = {}

local Resources = require(game.ReplicatedStorage.Resources)
-- local MouseOverUi = Resources:LoadLibrary("MouseOverUi")
local Player = game.Players.LocalPlayer
local Tween = Resources:LoadLibrary("Tween")
local Enumeration = Resources:LoadLibrary("Enumeration")
local Tween = Resources:LoadLibrary("Tween")
local Enumeration = Resources:LoadLibrary("Enumeration")
local AudioHandler = Resources:LoadLibrary("AudioHandler")

local InOutQuint = Enumeration.EasingFunction.InOutQuint.Value

local function loadObj(obj, defaultEnterLeave)
    if not obj.Name == "Base" then return end
    if not obj:FindFirstChild("UIGradient") then return end
    if not obj:FindFirstChild("UICorner") then return end
    if not obj:FindFirstChildOfClass("ImageButton") then return end
    local button = obj:FindFirstChildOfClass("ImageButton")

    local initPosBase = obj.Position
    local initPosBG = obj.Parent.Background.Position

    local enter, leave = button.MouseEnter, button.MouseLeave -- MouseOverUi.MouseEnterLeaveEvent(button)
    if defaultEnterLeave then enter, leave = button.MouseEnter, button.MouseLeave end
    enter:Connect(function()
        Tween(obj.UIGradient, "Offset", Vector2.new(0, 0), InOutQuint, 0.3, true)
    end)
    leave:Connect(function()
        Tween(obj.UIGradient, "Offset", Vector2.new(0, 0.5), InOutQuint, 0.3, true)
        Tween(obj, "Position", initPosBase, InOutQuint, 0.3, true)
        Tween(obj.Parent.Background, "Position", initPosBG, InOutQuint, 0.3, true)
    end)

    button.MouseButton1Down:Connect(function()
        --Tween(button, "Size", UDim2.new(1.05, 0, 1, 0), InOutQuint, 0.3, true)
        --Tween(button, "Position", UDim2.new(-0.025, 0, -0.05, 0), InOutQuint, 0.3, true)
        Tween(obj, "Position", initPosBase + UDim2.new(0, 0, 0, 8), InOutQuint, 0.3, true)
        Tween(obj.Parent.Background, "Position", initPosBG + UDim2.new(0, 0, 0, 8), InOutQuint, 0.3, true)
    end)
    button.MouseButton1Up:Connect(function()
        --Tween(button, "Size", UDim2.new(1, 0, 0.9, 0), InOutQuint, 0.3, true)
        --Tween(button, "Position", UDim2.new(0, 0, 0, 0), InOutQuint, 0.3, true)
        wait(0.1)
        Tween(obj, "Position", initPosBase, InOutQuint, 0.3, true)
        Tween(obj.Parent.Background, "Position", initPosBG, InOutQuint, 0.3, true)
    end)
end

local function loadButton(button)
    local enter, leave = button.MouseEnter, button.MouseLeave -- MouseOverUi.MouseEnterLeaveEvent(button)
    enter:Connect(function()
        AudioHandler:playAudio("Hover")
    end)
    button.MouseButton1Down:Connect(function()
        AudioHandler:playAudio("Click")
    end)
end

for _, obj in pairs(Player.PlayerGui:GetDescendants()) do
    if obj:IsA("ImageButton") then loadButton(obj) continue end
    if not obj.Name == "Base" then continue end
    if not obj:FindFirstChild("UIGradient") then continue end
    if not obj:FindFirstChild("UICorner") then continue end
    if not obj:FindFirstChildOfClass("ImageButton") then continue end
    loadObj(obj)
end

workspace.GamepassBoards.DescendantAdded:Connect(function(obj)
    if obj:IsA("ImageButton") then loadButton(obj) return end
    if not obj.Name == "Base" then return end
    if not obj:FindFirstChild("UIGradient") then return end
    if not obj:FindFirstChild("UICorner") then return end
    if not obj:FindFirstChildOfClass("ImageButton") then return end
    loadObj(obj, true)
end)

Player.PlayerGui.DescendantAdded:Connect(function(obj)
    if obj:IsA("ImageButton") then loadButton(obj) return end
    loadObj(obj)
end)

return module