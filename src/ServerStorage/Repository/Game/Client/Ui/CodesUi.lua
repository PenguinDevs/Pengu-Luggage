local module = {}

local Resources = require(game.ReplicatedStorage.Resources)
local Player = game.Players.LocalPlayer
local NotifyHandler = Resources:LoadLibrary("NotifyHandler")

local CodesMenu = Player.PlayerGui.CodesMenu

function module:enterCode()
    local code = CodesMenu.Frame.Body.TextBox.Text
    local success, message = Resources:GetRemote("Codes"):InvokeServer(code)
    
    if success then
        CodesMenu.Frame.Body.ResultLabel.TextColor3 = Color3.fromRGB(95, 235, 132)
        NotifyHandler:addItem("Green", 5, nil, message)
    else
        CodesMenu.Frame.Body.ResultLabel.TextColor3 = Color3.fromRGB(255, 73, 73)
        NotifyHandler:addItem("Yellow", 5, nil, message)
    end
    CodesMenu.Frame.Body.ResultLabel.Text = message
end

CodesMenu.Frame.Body.TextBox.FocusLost:Connect(function(enterPressed)
    if enterPressed then
        module:enterCode()
    end
end)
CodesMenu.Frame.Body.Codes.Base.Frame.MouseButton1Click:Connect(function()
    module:enterCode()
end)

return module