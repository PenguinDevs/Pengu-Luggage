local timer = {}

local function roundDown(n)
	return n - (n) % 1
end

return setmetatable(timer, {
	__call = function(_, ...)
		local sec = ...
		
		sec = roundDown(sec)
		
		local secondsElapsed = sec --* (60 ^ 2)
		local hours = roundDown(secondsElapsed/60 ^ 2)
		local minutes = roundDown(secondsElapsed/60 - hours * 60)
		local seconds = roundDown(secondsElapsed - minutes * 60 - hours * (60 ^ 2))
		return seconds, minutes, hours
	end
})
