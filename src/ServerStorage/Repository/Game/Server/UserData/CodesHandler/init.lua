local Resources = require(game.ReplicatedStorage.Resources)
local DataStore2 = Resources:LoadLibrary("DataStore2")
local DefaultDS = Resources:LoadLibrary("DefaultDS")
local PlayerProfiles = Resources:LoadLibrary("PlayerProfiles")
local CodeStats = Resources:LoadLibrary("CodeStats")

local module = {}

function module.checkCode(player, code)
    if type(code) ~= "string" and type(code) ~= "number" then return false, "You gotta actually type a code above" end
    code = string.lower(code)
    local playerProfile = PlayerProfiles:getProfile(player)
    local codeStat = CodeStats[code]
    if not codeStat then return false, "That code dosen't exist" end
    local codesStore = DataStore2("codes", player)
    local codesCache = codesStore:Get(DefaultDS.codes)
    
    if codesCache[code] then
        return false, string.format("Already redeemed code: %s", code)
    end
    codesCache[code] = true
    for reward, amount in pairs(codeStat.rewards) do
        local message = require(script[reward])(playerProfile, amount)
        playerProfile.data:setVal("codes", codesCache)
        return true, message
    end
end
Resources:GetRemote("Codes").OnServerInvoke = module.checkCode

return module