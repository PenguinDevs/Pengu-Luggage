local module = {}

local Resources = require(game.ReplicatedStorage.Resources)
local ProfileService = Resources:LoadLibrary("ProfileService")
local DefaultDS = Resources:LoadLibrary("DefaultDS")
local Promise = Resources:LoadLibrary("Promise")
local Signal = Resources:LoadLibrary("Signal")

local TeleportService = game:GetService("TeleportService")

local ProfileStore = ProfileService.GetProfileStore(
    DefaultDS.STORE_ID,
    DefaultDS
)

function module.playerProfileAssign(PlayerProfile)
    local self = {}

    self.profile = nil
    self.retrievedSig = Signal.new()
    self.retrievedSig:Connect(function()
        PlayerProfile.janitor:Remove("retrievedSig")
    end)
    PlayerProfile.janitor:Add(self.retrievedSig, "Destroy", "retrievedSig")

    function self:set(valType, newVal)
        
    end

    function self:incr(valType, newVal)
        
    end

    function self:get(reqValType)
        if not self.profile then
            self.retrievedSig:Wait()
        end

        local retVal = self.profile.Data[reqValType]
        if retVal == nil then
            error(string.format("Could not retrieve %s from player's profile data", reqValType))
        else
            return retVal
        end
    end

    Promise.new(function(resolve, reject)
        local profile = ProfileStore:LoadProfileAsync(
            string.format("Player_%s", PlayerProfile.id),
            function()
                reject()
            end
        )

        if profile then
            if PlayerProfile.player:IsDescendantOf(game) and self.retrievedSig.Fire then
                resolve(profile)
            else
                reject(profile)
            end
        else
            reject(profile)
        end
    end):catch(function(profile)
        if PlayerProfile.player:IsDescendantOf(game) then
            TeleportService:TeleportToPlaceInstance(game.PlaceId, game.JobId, ProfileService.player)
        end
        if profile then
            profile:Release()
        end
    end):andThen(function(profile)
        self.profile = profile
        self.retrievedSig:Fire()

        PlayerProfile.janitor:Add(profile:ListenToRelease(function()
            print(string.format("Removed %s profile data", PlayerProfile.name))
            self.profile = nil
        end), "Disconnect")
        PlayerProfile.janitor:Add(function()
            if self.profile then
                self.profile:Release()
            end
        end)
    end)

    return setmetatable(self, {
        __call = function(_, ...)
            self:get(...)
        end
    })
end

return module