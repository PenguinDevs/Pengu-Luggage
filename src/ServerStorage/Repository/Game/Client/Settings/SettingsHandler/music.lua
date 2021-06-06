local module = {}

local Resources = require(game.ReplicatedStorage.Resources)
local Status = Resources:LoadLibrary("Status")
local Player = game.Players.LocalPlayer
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Round = Resources:LoadLibrary("Round")

local ui = Player.PlayerGui.SettingsMenu.Frame.ScrollingFrame.Audio.Frame.Body.Music
local setting = "music"

module.mainHandler = nil

local but = ui.Slider.Hold
local hold = but
local slider = ui.Slider

function module:init()
    local function saveResults()
        local scrollerStartX = slider.AbsolutePosition.X
        local scrollerSizeX = slider.AbsoluteSize.X
        
        local butStartX = but.AbsolutePosition.X
        
        local amount = math.clamp((butStartX - scrollerStartX + 10)/scrollerSizeX, 0, 1)

        Status.data.settings[setting] = Round(amount * 100)/100
        
        Resources:GetRemote("Settings"):FireServer(Status.data.settings)
        module.mainHandler:updateSettings(Status.data.settings, setting)
    end

    ui.AmountBox.FocusLost:Connect(function()
        local input = ui.AmountBox.Text
        if not tonumber(input.Text) then return end
        Status.data.settings[setting] = input
        Resources:GetRemote("Settings"):FireServer(Status.data.settings)
    end)

    ui.Slider.Hold.Button.MouseButton1Down:Connect(function()
        RunService:BindToRenderStep(string.format("%sHold", ui.Name), 100, function()
            local mouseLocationX = UserInputService:GetMouseLocation().X
			local scrollerStartX = slider.AbsolutePosition.X
			local scrollerSizeX = slider.AbsoluteSize.X

            local amount = math.clamp((mouseLocationX - scrollerStartX + 10)/scrollerSizeX, 0, 1)
			
			--print(mouseLocationX, scrollerStartX, scrollerStartX + scrollerSizeX, math.clamp(mouseLocationX, scrollerStartX, scrollerSizeX + scrollerStartX))
			but.Position = UDim2.new(0, math.clamp(mouseLocationX, scrollerStartX, scrollerSizeX + scrollerStartX) - scrollerStartX, 0, 0)
			
            workspace.Music.Volume = amount * 0.2

			if not UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton1) then RunService:UnbindFromRenderStep(string.format("%sHold", ui.Name)) saveResults() end
        end)
    end)
end

function module:update(val)
    if not val then return end
    local scrollerSizeX = slider.AbsoluteSize.X
    ui.Slider.Hold.Position = UDim2.fromOffset(scrollerSizeX * val, 0)
    ui.AmountBox.Text = val
    workspace.Music.Volume = Status.data.settings[setting] * 0.2
end

return module