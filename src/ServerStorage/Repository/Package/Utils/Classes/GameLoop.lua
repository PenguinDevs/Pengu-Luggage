-- Responsible for creating game loop classes and are to be run by this module
-- @PenguinDevs

local RunService = game:GetService("RunService")
local CollectedGameLoops = 0

local module = {}

module.STOP_VALUE = "abc123"

function module.new(func, interval, name, ...)
	assert(type(func) == "function", "Expected function, got " .. type(func))
	local args = table.pack(...)
	CollectedGameLoops += 1
	name = name or ("GameLoop" .. tostring(CollectedGameLoops))
	return setmetatable({func = func, interval = interval, name = name, enabled = false, args = args}, {
		__call = function()
			local stepped
			if interval <= 0 then
				stepped = function() RunService.RenderStepped:Wait() end
			else
				stepped = function() wait(interval) end
			end

			while true do
				stepped()
				func(table.unpack(args))
			end
		end
	})
end

return module
