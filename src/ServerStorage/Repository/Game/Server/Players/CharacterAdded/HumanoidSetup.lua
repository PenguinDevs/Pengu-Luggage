local module = {}

function module:setHumanoid(character, playerProfile)
    if playerProfile.passes.finished then playerProfile.passes.finished:Wait() end
    if playerProfile.passes["2x Speed"] then
        local humanoid = character:FindFirstChild("Humanoid") or character:WaitForChild("Humanoid")
        humanoid.WalkSpeed = 35
    end
end

return module