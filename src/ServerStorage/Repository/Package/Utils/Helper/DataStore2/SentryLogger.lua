local module = {}

module._resources = require(game.ReplicatedStorage.Resources)
module._sentry = module._resources:LoadLibrary("SentryS")

function module:log(message)
	print(message)
	module._sentry:Post(message)
end

return module
