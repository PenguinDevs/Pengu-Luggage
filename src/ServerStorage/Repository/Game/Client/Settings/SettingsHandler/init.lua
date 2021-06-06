local module = {}

local Resources = require(game.ReplicatedStorage.Resources)
local Status = Resources:LoadLibrary("Status")

local Collected = {}

function module:init()
    for _, settingsModule in pairs(script:GetChildren()) do
        Collected[settingsModule.Name] = require(settingsModule)
        Collected[settingsModule.Name].mainHandler = module
        Collected[settingsModule.Name]:init()
    end
    module:updateSettings()
end

function module:updateSettings(settings, spec)
    settings = settings or Status.data.settings
    if spec then
        local setting = Collected[spec]
        setting:update(settings[spec])
    else
        for settingName, setting in pairs(Collected) do
            setting:update(settings[settingName])
        end
    end
end

return module