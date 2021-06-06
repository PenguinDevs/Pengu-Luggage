local module = {}

return setmetatable(module, {
    __call = function(_, ...)
        local playerProfile, amount = ...
        playerProfile.data:incrVal("money", amount)
        return string.format("Successfully received %s money from using a code!", amount)
    end
})