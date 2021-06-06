local round = {}

return setmetatable(round, {
	__call = function(_, ...)
		local n = ...
		return n - (n) % 1
	end
})
