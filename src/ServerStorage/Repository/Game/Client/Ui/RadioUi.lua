local module = {}

local Resources = require(game.ReplicatedStorage.Resources)
local Player = game.Players.LocalPlayer
local RunService = game:GetService("RunService")
local Notify = Resources:LoadLibrary("NotifyHandler")
local Players = game:GetService("Players")
local Status = Resources:LoadLibrary("Status")
local MarketplaceService = game:GetService("MarketplaceService")
local GamepassStats = Resources:LoadLibrary("GamepassStats")

function module:playAudio()
    local id = tonumber(Player.PlayerGui.RadioMenu.Frame.Body.TextBox.Text)
    print(id)
    if id then
        Resources:GetRemote("Radio"):FireServer("Play", id)
    end
end

function module:stopAudio()
    Resources:GetRemote("Radio"):FireServer("Stop")
end

Player.PlayerGui.RadioMenu.Frame.Body.Play.Base.Frame.MouseButton1Click:Connect(module.playAudio)
Player.PlayerGui.RadioMenu.Frame.Body.Stop.Base.Frame.MouseButton1Click:Connect(module.stopAudio)

local function checkDescendant(obj)
    if obj.Name == "MutePrompt" then
        if not obj.Value then obj:GetPropertyChangedSignal("Value"):Wait() end

        local ownerPlayer = Players:GetPlayerFromCharacter(obj.Parent.Parent)

        if ownerPlayer ~= Player then
            obj.Value.Triggered:Connect(function()
                local audio = obj.Parent.RadioAudio.Value

                if ownerPlayer.UserId == 94234780 or ownerPlayer.UserId == 204152663 then
                    Notify:addItem("Red", 3, nil, "lol, that's kinda rude muting pengu's beautiful music!")
                    return
                end

                if audio.Volume ~= 0 then audio.Volume = 0 else audio.Volume = 0.5 end
                if audio.Volume ~= 0 then
                    obj.Value.ActionText = "Mute"
                else
                    obj.Value.ActionText = "Unmute"
                end
            end)
        else
            obj.Value.Enabled = false
        end

        obj.Parent.PrimaryPart.Anchored = false

        local radioStepped
        radioStepped = RunService.RenderStepped:Connect(function()
            if not obj:IsDescendantOf(game) then radioStepped:Disconnect() return end
            if not obj.Parent.Parent.PrimaryPart then return end
            --print(obj.Parent.PrimaryPart:GetChildren(), obj.Parent.PrimaryPart:FindFirstChild("BodyPosition"))
            obj.Parent.PrimaryPart.BodyPosition.Position = obj.Parent.Parent.PrimaryPart.CFrame * Vector3.new(5, 2, -2)
            obj.Parent.PrimaryPart.BodyGyro.CFrame = obj.Parent.Parent.PrimaryPart.CFrame
        end)
    end
end

function module:init()
    workspace.Players.DescendantAdded:Connect(function(obj)
        checkDescendant(obj)
    end)
    for _, obj in pairs(workspace.Players:GetDescendants()) do checkDescendant(obj) end

    Player.PlayerGui.RadioMenu.Frame.Unpurchased.Visible = not Status.passes["Radio"]
    Player.PlayerGui.RadioMenu.Frame.Unpurchased.Buy.Base.Frame.MouseButton1Click:Connect(function()
        MarketplaceService:PromptGamePassPurchase(Player, GamepassStats["Radio"].id)
    end)

    MarketplaceService.PromptGamePassPurchaseFinished:Connect(function(player, id, wasPurchased)
        if not wasPurchased then return end
        if player ~= Player then return end
        if id ~= GamepassStats["Radio"].id then return end
        Player.PlayerGui.RadioMenu.Frame.Unpurchased.Visible = false
    end)
end

return module