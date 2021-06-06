local module = {}

local RunService = game:GetService("RunService")

function module:teleportPlayer(character, playerProfile)
    local plot = playerProfile.landPlots.obj
    -- if not RunService:IsStudio() then
        character:SetPrimaryPartCFrame(plot.PlotModels.PlayerSpawn.CFrame * CFrame.new(0, 4, 0))
    -- end
end

return module