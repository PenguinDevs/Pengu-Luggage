local module = {}

local RemoteEvent = Instance.new("RemoteEvent", game.ReplicatedStorage)
RemoteEvent.Name = "ServerTween"

function tweenForClient(player, ignoreSync, ...)
	RemoteEvent:FireClient(player, false, ...)
	if not ignoreSync then
		for _, player in pairs(game.Players:GetPlayers()) do
			RemoteEvent:FireClient(player, true, ...)
		end
	end
end

function module:tweenAllClients(...)
	--for _, player in pairs(game.Players:GetPlayers()) do
	--	tweenForClient(player, ...)
	--end
	RemoteEvent:FireAllClients(false, ...)
end

function module:tweenClient(...)
	tweenForClient(...)
end

return module
