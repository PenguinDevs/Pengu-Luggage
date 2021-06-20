-- Opens/close user interface
-- @PenguinDevs

local module = {}

function module:init()
    for _, mod in pairs(script.StoredUis:GetChildren()) do
        require(script.Constructor).new(mod.Name, require(mod))
    end
end

return module