local module = {}

local Resources = require(game.ReplicatedStorage.Resources)
local Status = Resources:LoadLibrary("Status")
local Player = game.Players.LocalPlayer
local FishAgent = Resources:LoadLibrary("FishAgent")
local Notify = Resources:LoadLibrary("NotifyHandler")
local Round = Resources:LoadLibrary("Round")

local ui = Player.PlayerGui.SettingsMenu.Frame.ScrollingFrame.Performance.Frame.Body.Fish
local setting = "fish"

module.mainHandler = nil

local deb = tick()

function module:init()
    ui.Body.Button.MouseButton1Click:Connect(function()
        if tick() - deb < 5 then
            Notify:addItem("Issue", 3, nil, string.format("You must wait %s seconds before changing this setting again", Round(5 - tick() + deb)))
            return
        end
        deb = tick()
        Status.data.settings[setting] = not Status.data.settings[setting]
        
        if Status.data.settings[setting] then
            ui.Body.Button.ImageTransparency = 0
        else
            ui.Body.Button.ImageTransparency = 1
        end

        Resources:GetRemote("Settings"):FireServer(Status.data.settings)
        module.mainHandler:updateSettings(Status.data.settings, setting)
    end)
end

function module:update(val)
    if val == nil then return end
    if val then
        ui.Body.Button.ImageTransparency = 0
    else
        ui.Body.Button.ImageTransparency = 1
    end
    FishAgent:toggleFishes(val)
end

return module