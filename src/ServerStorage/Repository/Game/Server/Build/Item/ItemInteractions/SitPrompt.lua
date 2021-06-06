local Resources = require(game.ReplicatedStorage.Resources)

local module = {}

return setmetatable(module, {
    __call = function(_, ...)
        local promptVal = ...
        local prompt = promptVal.Value
        local seatObj = promptVal.SeatObj.Value

        local function sit(player)
            seatObj:Sit(player.Character.Humanoid)
            --print("seated")
        end

        seatObj:GetPropertyChangedSignal("Occupant"):Connect(function()
            local humanoid = seatObj.Occupant 
            if humanoid then
                prompt.Enabled = false
            else
                prompt.Enabled = true
            end
        end)

        prompt.Triggered:Connect(sit)
    end;
})