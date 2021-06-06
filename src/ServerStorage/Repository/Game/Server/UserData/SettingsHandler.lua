local module = {}

local Resources = require(game.ReplicatedStorage.Resources)
local PlayerProfiles = Resources:LoadLibrary("PlayerProfiles")

Resources:GetRemote("Settings").OnServerEvent:Connect(function(player, settings)
    local playerProfile = PlayerProfiles:getProfile(player)
    playerProfile.data:setVal("settings", settings)
end)

return module