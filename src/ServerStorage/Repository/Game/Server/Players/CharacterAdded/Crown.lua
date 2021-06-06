local module = {}

local Resources = require(game.ReplicatedStorage.Resources)

function module:updateCrown(character, playerProfile)
    if playerProfile.passes.finished then playerProfile.passes.finished:Wait() end
    if playerProfile.passes["VIP"] then
        local crownObj = Resources:GetParticle("Crown"):Clone()
        --crownObj.HeadVal.Value = character.Head
        local weld = Instance.new("Weld", crownObj)
        weld.Part0 = character.Head
        weld.Part1 = crownObj.PrimaryPart
        weld.C0 = CFrame.new(0, 1.5, 0)
        crownObj:SetPrimaryPartCFrame(character.HumanoidRootPart.CFrame)
        crownObj.Parent = character
    end
end

return module