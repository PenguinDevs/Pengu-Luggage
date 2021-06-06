local Resources = require(game.ReplicatedStorage.Resources)
local RoundDown = Resources:LoadLibrary("RoundDown")

local module = {}

return setmetatable(module, {
    __call = function(_, ...)
        local dur, offset = ...
        if offset == nil then offset = 0 end
        local toSub = RoundDown((tick() - offset)/dur)
        return ((tick() - offset) - toSub * dur)/dur
    end
})