local module = {}

local Resources = require(game.ReplicatedStorage.Resources)
local DataStore2 = Resources:LoadLibrary("DataStore2")
local DefaultDS = Resources:LoadLibrary("DefaultDS")

function module:playerProfileAssign(playerProfile)
    --Resources:GetRemote("Ui"):FireClient(playerProfile.obj, "FrostyDory", "open")
    if playerProfile.inGroup then
        require(script.FrostyDory)(playerProfile)
    else
        local hadTutorialStore = DataStore2("hadTutorial", playerProfile.obj)
        if hadTutorialStore:Get(DefaultDS.hadTutorial) ~= 0 then
            -- Resources:GetRemote("Ui"):FireClient(playerProfile.obj, "FrostyDory", "open")
        end
    end
end

return module
