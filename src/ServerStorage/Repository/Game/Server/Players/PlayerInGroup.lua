local module = {}

local Resources = require(game.ReplicatedStorage.Resources)

function module:playerProfileAssign(playerProfile)
    local inGroup = playerProfile.obj:IsInGroup(9551267)
    Resources:GetRemote("Game"):FireClient(playerProfile.obj, "inGroup", inGroup)
    return inGroup
end

return module