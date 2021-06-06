local module = {}

local Resources = require(game.ReplicatedStorage.Resources)

function module:addLabel(character, playerProfile)
    local head = character:WaitForChild("Head")
    local nameTag = Resources:GetVisual("NameTag"):Clone()
    nameTag.TextLabel.Text = character.Name
    nameTag.Parent = character
    nameTag.Adornee = head
    nameTag.PlayerToHideFrom = playerProfile.obj

    local hum = character:WaitForChild("Humanoid")
    hum.DisplayDistanceType = Enum.HumanoidDisplayDistanceType.None
end

return module