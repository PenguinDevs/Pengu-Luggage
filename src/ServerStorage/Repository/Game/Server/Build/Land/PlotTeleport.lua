local Resources = require(game.ReplicatedStorage.Resources)
local PlayerProfiles = Resources:LoadLibrary("PlayerProfiles")
local Players = game:GetService("Players")

local module = {}

Resources:GetRemote("PlotTeleport").OnServerEvent:Connect(function(player, playerRequested)
    local playerProfile = PlayerProfiles:getProfile(player)
    if not playerProfile.landPlots then return end
    if playerProfile.landPlots.visitingLeaveEvent then
        playerProfile.landPlots.visitingLeaveEvent:Disconnect()
        playerProfile.landPlots.visitingLeaveEvent = nil
        Resources:GetRemote("Game"):FireClient(player, "visiting", false)
    end
    if playerRequested == "H" then
        player.Character:SetPrimaryPartCFrame(workspace.HangoutModels.SPAWNREF.CFrame)

        -- if playerProfile.visiting ~= tostring(playerProfile.id) then
        --     local requestedPlayerProfile = 
        --     requestedPlayerProfile[tostring(playerProfile.id)] = nil
        -- end
    else
        local requestedPlayerProfile = PlayerProfiles:getProfile(playerRequested)
        if not requestedPlayerProfile then return end
        local plot = requestedPlayerProfile.landPlots.obj
        player.Character:SetPrimaryPartCFrame(plot.PlotModels.PlayerSpawn.CFrame * CFrame.new(0, 4, 0))
        if playerProfile.id ~= requestedPlayerProfile.id then
            playerProfile.landPlots.visitingLeaveEvent = requestedPlayerProfile.leave:Connect(function()
                if not player.Character then return end
                player.Character:SetPrimaryPartCFrame(playerProfile.landPlots.obj.PlotModels.PlayerSpawn.CFrame * CFrame.new(0, 4, 0))
                Resources:GetRemote("Game"):FireClient(player, "visiting", false)
            end)
            Resources:GetRemote("Game"):FireClient(player, "visiting", requestedPlayerProfile.landPlots.plotI)
        end
        -- playerProfile.landPlots.visiting = tostring(requestedPlayerProfile.id)
        -- requestedPlayerProfile.landPlots.visitors[tostring(playerProfile.id)] = true
    end
end)

workspace.HangoutModels.TELEPORTREF.Touched:Connect(function(touched)
    local character = touched:FindFirstAncestorOfClass("Model")
    if not character then return end
    local humanoid = character:FindFirstChild("Humanoid")
    if not humanoid then return end
    local player = Players:GetPlayerFromCharacter(character)
    if not player then return end
    local requestedPlayerProfile = PlayerProfiles:getProfile(player)
    local plot = requestedPlayerProfile.landPlots.obj
    player.Character:SetPrimaryPartCFrame(plot.PlotModels.PlayerSpawn.CFrame * CFrame.new(0, 4, 0))
end)

return module