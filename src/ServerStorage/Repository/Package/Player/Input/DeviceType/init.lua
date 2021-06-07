local module = {}

local Resources = require(game.ReplicatedStorage.Resources)
local UserInputService = game:GetService("UserInputService")

module.lastDevice = nil

return setmetatable(module, {
    __call = function(_, ...)
        local function getDevice()
            if UserInputService.GamepadEnabled then
                return "gamepad"
            elseif UserInputService.KeyboardEnabled then
                return "keyboard"
            elseif UserInputService.TouchEnabled then
                return "touch"
            else
                warn("got unknown device")
                return "unknown"
            end
        end
        local device = getDevice()
        if module.lastDevice ~= device then
            module.lastDevice = device
            local mod = script:FindFirstChild(device)
            if mod then spawn(require(mod)) end
        end
        return device
    end
})