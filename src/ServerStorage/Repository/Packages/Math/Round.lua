local round = {}

return setmetatable(round, {
	__call = function(_, ...)
		local n = ...
		return math.floor(n + 0.5)
	end
})
