-- Constructs behaviours for uis opening/closing
-- @author PenguinDevs

local module = {}

local Resources = require(game.ReplicatedStorage.Resources)
local Signal = Resources:LoadLibrary("Signal")
local PlayersService = game:GetService("Players")
local DeviceType = Resources:LoadLibrary("DeviceType")

local Player = PlayersService.LocalPlayer

local DEFAULT_O_EASE_STYLE = Enum.EasingStyle.Quad
local DEFAULT_O_EASE_DIR = Enum.EasingDirection.InOut
local DEFAULT_O_POS = UDim2.fromScale(0.5, 0.5)
local DEFAULT_O_TIME = 0.3

local DEFAULT_C_EASE_STYLE = Enum.EasingStyle.Quad
local DEFAULT_C_EASE_DIR = Enum.EasingDirection.InOut
local DEFAULT_C_POS = UDim2.fromScale(0.5, -0.5)
local DEFAULT_C_TIME = 0.3

function module.new(name, ui)
    ui.obj = Player.PlayerGui[name]:FindFirstChild("Frame")

    ui.openDetSig = Signal.new()
    ui.closeDetSig = Signal.new()
    ui.triggerSig = Signal.new()

    ui.state = "closed"

    for _, event in pairs(ui.openEvents) do
        event:Connect(function()
            ui.openDetSig:Fire()
        end)
    end
    for _, event in pairs(ui.closeEvents) do
        event:Connect(function()
            ui.closeDetSig:Fire()
        end)
    end
    for _, event in pairs(ui.triggerEvents) do
        event:Connect(function()
            ui.triggerSig:Fire()
        end)
    end

    function ui:open()
        ui.state = "opened"
        ui.obj:TweenPosition(
            ui.openDet[DeviceType()] or ui.openDet.pos or DEFAULT_O_POS,
            ui.openDet.dir or DEFAULT_O_EASE_DIR,
            ui.openDet.style or DEFAULT_O_EASE_STYLE,
            ui.openDet.dur or DEFAULT_O_TIME,
            true
        )
        local call = ui.openDet.call
        if call then call() end
    end

    function ui:close()
        ui.state = "closed"
        ui.obj:TweenPosition(
            ui.closeDet[DeviceType()] or ui.closeDet.pos or DEFAULT_C_POS,
            ui.closeDet.dir or DEFAULT_C_EASE_DIR,
            ui.closeDet.style or DEFAULT_C_EASE_STYLE,
            ui.closeDet.dur or DEFAULT_C_TIME,
            true
        )
        local call = ui.closeDet.call
        if call then call() end
    end

    function ui:trigger()
        if ui.state == "opened" then
            ui:close()
        elseif ui.state == "closed" then
            ui:open()
        end
    end

    ui.openDetSig:Connect(ui.open)
    ui.closeDetSig:Connect(ui.close)
    ui.triggerSig:Connect(ui.trigger)
    
    if ui.openDetED_ON_INIT then
        ui:open()
    else
        ui:close()
    end
end

return module