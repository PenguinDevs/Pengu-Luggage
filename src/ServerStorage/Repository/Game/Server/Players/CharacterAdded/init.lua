local Resources = require(game.ReplicatedStorage.Resources)
local Signal = Resources:LoadLibrary("Signal")

local module = {}

function module:playerProfileAssign(playerProfile)
    local returner = {}

    returner.obj = nil
    returner.CharacterAddedListener = Signal.new()
    playerProfile.leave:Connect(function() returner.CharacterAddedListener:Destroy() end)
    returner.CharacterAddedListener:Connect(function(character)
        if not character then character = playerProfile.obj.Character end
        --if initFired then initFired = false return end
        --character:WaitForChild("HumanoidRootPart", 20)
        if not playerProfile.obj.HasAppearanceLoaded then
            playerProfile.obj.CharacterAppearanceLoaded:Wait()
        end
        if not character:IsDescendantOf(game) then
            character.AncestryChanged:Wait()
        --     character.Parent = workspace.Players
        -- else
        --     character.Parent = workspace.Players
        end
        require(script.SpawnLocation):teleportPlayer(character, playerProfile)
        require(script.CollisionGroups):setCollisionGroupOnce(character)
        require(script.HumanoidSetup):setHumanoid(character, playerProfile)
        require(script.Crown):updateCrown(character, playerProfile)
        require(script.PlayerRadio):getRadio(character, playerProfile)
        require(script.NameTags):addLabel(character, playerProfile)
        wait() -- hack I dont know why I have to do
        character.Parent = workspace.Players
        
        character.ChildAdded:Connect(function(...) require(script.CollisionGroups):setCollisionGroup(...) end)
        returner.obj = character
    end)
    spawn(function ()
        returner.CharacterAddedListener:Fire(playerProfile.obj.Character or playerProfile.obj.CharacterAdded:Wait() and playerProfile.obj.Character)
        playerProfile.obj.CharacterAdded:Connect(function(...) returner.CharacterAddedListener:Fire(...) end)
    end)

    return returner
end

return module