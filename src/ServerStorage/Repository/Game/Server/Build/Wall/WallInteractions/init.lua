local Resources = require(game.ReplicatedStorage.Resources)

local module = {}

local CollectedInteractModules = {}
for _, moduleObj in pairs(script:GetChildren()) do
    local module = require(moduleObj)
    CollectedInteractModules[moduleObj.Name] = module
end

function module:process(wallObj, playerProfile)
    for name, module in pairs(CollectedInteractModules) do
        local found = wallObj:FindFirstChild(name)
        if found then module(found, playerProfile) end
    end
end

return module