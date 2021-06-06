local module = {}

local Resources = require(game.ReplicatedStorage.Resources)
local PlayerProfiles = Resources:LoadLibrary("PlayerProfiles")
local Players = game:GetService("Players")
local MarketplaceService = game:GetService("MarketplaceService")
local GamepassStats = Resources:LoadLibrary("GamepassStats")

function module:getRadio(character, playerProfile)
    if playerProfile.passes.finished then playerProfile.passes.finished:Wait() end
    if playerProfile.passes["Radio"] then
        local radio = Resources:GetParticle("Radio"):Clone()
        radio.Parent = character
        --radio.PrimaryPart.Anchored = true
        radio:SetPrimaryPartCFrame(character.PrimaryPart.CFrame)
        radio.PrimaryPart.BodyPosition.Position = character.PrimaryPart.Position
        radio.PrimaryPart:SetNetworkOwner(playerProfile.obj)
    end
end

Resources:GetRemote("Radio").OnServerEvent:Connect(function(player, action, ...)
    local playerProfile = PlayerProfiles:getProfile(player)
    if not playerProfile.passes["Radio"] then
        MarketplaceService:PromptGamePassPurchase(player, GamepassStats["Radio"].id)
        return
    end
    local character = player.Character
    local radio = character:FindFirstChild("Radio")
    if action == "Play" then
        local audioId = ...
        radio.RadioAudio.Value.SoundId = string.format("rbxassetid://%s", audioId)
        radio.RadioAudio.Value:Play()
    elseif action == "Stop" then
        radio.RadioAudio.Value:Stop()
    end
end)

return module