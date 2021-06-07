local module = {}

local Resources = require(game.ReplicatedStorage.Resources)
local RunService = game:GetService("RunService")

function module:loadRainbow(grad, t, range)
    local self = {}

    self.stepped = RunService.RenderStepped:Connect(function()
        if not grad:IsDescendantOf(game) then self:Destroy() return end
        local loop = tick() % t / t -- returns value from 0 to 1
        local colors = {} -- table of colors
        for i = 1, range + 1, 1 do
            local z = Color3.fromHSV(loop - ((i - 1)/range), 1, 1)  -- subtracting by a fraction essentially "rewinds" the color to a previous state
            -- I subtract one from "i" because Lua has a starting index of one
            if loop - ((i - 1) / range) < 0 then -- the minimum is 0, if it goes below, add one
                z = Color3.fromHSV((loop - ((i - 1) / range)) + 1, 1, 1)
            end
            local d = ColorSequenceKeypoint.new((i - 1) / range, z)
            table.insert(colors, #colors + 1, d) -- insert color into table
        end
        grad.Color = ColorSequence.new(colors) -- apply colorsequence
    end)

    function self:Destroy()
        self.stepped:Disconnect()
        self.stepped = nil
        self = nil
    end

    return self
end

return module