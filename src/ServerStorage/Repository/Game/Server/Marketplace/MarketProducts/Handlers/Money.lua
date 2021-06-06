local Resources = require(game.ReplicatedStorage.Resources)
local PlayerProfile = Resources:LoadLibrary("PlayerProfiles")

local module = {}

return setmetatable(module, {
    __call = function(_, ...)
        local player, product = ...
        local playerProfile = PlayerProfile:getProfile(player)
        playerProfile.data:incrVal("money", product.reward, true)
        return string.format("Here, take %s for your aquarium!", product.reward)
    end
})