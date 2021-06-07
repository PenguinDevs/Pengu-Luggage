-- Responsible for creating game loop classes and are to be run by this module
-- @PenguinDevs

local RunService = game:GetService("RunService")
local CollectedGameLoops = 0

local module = {}

module.STOP_VALUE = "abc123"

function module.new(func, interval, name)
	assert(type(func) == "function", "Expected function, got " .. type(func))
	CollectedGameLoops += 1
	--name = name or ("GameLoop" .. tostring(CollectedGameLoops))
	return {func = func, interval = interval, name = name, enabled = false}
end

function module:handle(gameLoop, ...)
	assert(type(gameLoop) == "table", "Expected GameLoop, got " .. type(gameLoop))
	local args = table.pack(...)
	local function callFunc()
		-- if gameLoop.name then
		-- 	debug.profilebegin(gameLoop.name)
		-- end
		return gameLoop.func(table.unpack(args))
		-- if gameLoop.name then
		-- 	debug.profileend()
		-- end
	end
	gameLoop.Enabled = true
	local steppedEvent
	if RunService:IsClient() then
		steppedEvent = RunService.RenderStepped
	else
		steppedEvent = RunService.Heartbeat
	end
	if not gameLoop.interval or gameLoop.interval == 0 then
		spawn(function()
			while true do
				if not gameLoop.Enabled then break end
				steppedEvent:Wait()
				if callFunc() == module.STOP_VALUE then break end
			end
		end)
	else
		spawn(function()
			while wait(gameLoop.interval) do
				if not gameLoop.Enabled then break end
				steppedEvent:Wait()
				callFunc()
				if callFunc() == module.STOP_VALUE then break end
			end
		end)
	end
end

return module
