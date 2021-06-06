local module = {}

local Resources = require(game.ReplicatedStorage.Resources)
local DefaultDS = Resources:LoadLibrary("DefaultDS")
local DataStore2 = Resources:LoadLibrary("DataStore2")
local D2BeforeGet = Resources:LoadLibrary("D2BeforeGet")
local DataFetchRemote = Resources:GetRemote("DataRetrieve")
local PlayerProfiles = Resources:LoadLibrary("PlayerProfiles")

local specialLinks = {
	["settings"] = function(origSettings)
		local DefaultSettings = Resources:LoadLibrary("DefaultUserSettings")
		for setting, value in pairs(DefaultSettings) do
			if not origSettings[setting] then
				origSettings[setting] = value
			end
		end

		return origSettings
	end
}

function DataFetchRemote.OnServerInvoke(player, dataType)
	--print(player, dataType)
	local playerProfile = PlayerProfiles:getProfile(player)
	--if not playerProfile then for i = 1, 50 do playerProfile = PlayerProfiles:getProfile(player) wait(.5) if playerProfile then break end end end
	if playerProfile then
		D2BeforeGet:playerProfileAssign(playerProfile)
	else
		D2BeforeGet:playerProfileAssign(playerProfile, player)
	end
	if not DefaultDS[dataType] then warn("requested dataType:", dataType, "not found from:", player) return end
	local store = DataStore2(dataType, player)
	--print(store:Get(DefaultDS[dataType]))
	local dataToSend = store:Get(DefaultDS[dataType])
	if specialLinks[dataType] then dataToSend = specialLinks[dataType](dataToSend) end
	return dataToSend
end

game.ReplicatedStorage.DataReady.Value = true

return module
