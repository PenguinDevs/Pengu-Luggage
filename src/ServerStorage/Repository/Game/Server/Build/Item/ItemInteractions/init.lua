local Resources = require(game.ReplicatedStorage.Resources)

local module = {}

local CollectedInteractModules = {}
for _, moduleObj in pairs(script:GetChildren()) do
    local module = require(moduleObj)
    CollectedInteractModules[moduleObj.Name] = module
end

function module:process(itemObj, playerProfile)
    for name, module in pairs(CollectedInteractModules) do
        local found = itemObj:FindFirstChild(name)
        if found then module(found, playerProfile) end
    end
end

return module