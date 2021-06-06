local Resources = require(game.ReplicatedStorage.Resources)
local Player = game.Players.LocalPlayer
local Tween = Resources:LoadLibrary("Tween")
local Enumeration = Resources:LoadLibrary("Enumeration")

local InOutSine = Enumeration.EasingFunction.InOutSine.Value

local module = {}

local Collected = {
    Player.PlayerGui.FishFillMenu.Frame.Images;
    Player.PlayerGui.FishMenu.Frame.Images;
    Player.PlayerGui.PlayersMenu.Frame.Images;
    Player.PlayerGui.SettingsMenu.Frame.Images;
    -- Player.PlayerGui.ShopMenu.Frame.Images;
    Player.PlayerGui.CodesMenu.Frame.Images;
    Player.PlayerGui.Tutorial.Dialogue.Images;
}

function module:init()
    for _, imagesUi in pairs(Collected) do
        local trig = false
        for _, image in pairs(imagesUi:GetChildren()) do
            trig = not trig
            local pos1 = (trig) and (image.Position + UDim2.fromOffset(0, 10)) or image.Position
            local pos2 = (trig) and image.Position or (image.Position + UDim2.fromOffset(0, 10))
            
            if not trig then
                image.Position = pos2
            end

            spawn(function()
                local tween1 = Tween(image, "Position", pos1, InOutSine, 1, true)
                tween1:Wait()
                local tween2 = Tween(image, "Position", pos2, InOutSine, 1, true)
                tween2:Wait()
                while true do
                    tween1:Restart()
                    tween1:Wait()
                    tween2:Restart()
                    tween2:Wait()
                    wait()
                end
            end)
        end
    end
end

return module