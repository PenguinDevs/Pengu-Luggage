local module = {}

local Resources = require(game.ReplicatedStorage.Resources)

function module:playerProfileAssign(playerProfile, overridePasses)
    for passName, owned in pairs(overridePasses or playerProfile.passes) do
        if not owned then continue end
        if not type(passName) == "string" then continue end
        local mod = script:FindFirstChild(passName)
        if mod then
            require(mod)(playerProfile)
        end
    end
end

return module