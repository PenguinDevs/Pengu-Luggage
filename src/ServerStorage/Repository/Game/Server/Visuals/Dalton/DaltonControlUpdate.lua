local Resources = require(game.ReplicatedStorage.Resources)
local GetCustomerAmount = Resources:LoadLibrary("GetCustomerAmount")
local DataStore2 = Resources:LoadLibrary("DataStore2")
local DefaultDS = Resources:LoadLibrary("DefaultDS")

local module = {}

function module:playerProfileAssign(playerProfile)
    local controller = {}

    local build1Store = DataStore2("build1", playerProfile.obj)
    function controller:update()
        local customerAmount = GetCustomerAmount(build1Store:Get(DefaultDS.build1))
        --for _, player in pairs(game.Players:GetPlayers()) do
            Resources:GetRemote("UpdateDaltons"):FireAllClients(playerProfile.obj, playerProfile.landPlots.plotI, customerAmount)
        --end
    end

    playerProfile.leave:Connect(function()
        Resources:GetRemote("UpdateDaltons"):FireAllClients(playerProfile.obj, playerProfile.landPlots.plotI, 0)
    end)

    return controller
end

Resources:GetRemote("GetDaltons").OnServerInvoke = function()
    local list = {}

    for _, player in pairs(game.Players:GetPlayers()) do
        local playerProfile = Resources:LoadLibrary("PlayerProfiles"):getProfile(player)
        if playerProfile then
            local build1Store = DataStore2("build1", playerProfile.obj)
            if playerProfile.landPlots then
                table.insert(list, 1, {
                    player = player;
                    amount = GetCustomerAmount(build1Store:Get(DefaultDS.build1));
                    plotNo = playerProfile.landPlots.plotI;
                    rich = playerProfile.passes["Rich Guests (2x Income)"]
                })
            else
                warn(string.format("Ignoring %s because .landPlots == nil for playerProfile when GetDaltons was invoked on server from client for DaltonControlUpdate", tostring(player)))
            end
        end
    end

    return list
end

return module