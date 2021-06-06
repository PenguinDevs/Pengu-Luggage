-- Polling synced to os.time()
-- @author Validark

local Resources = require(game:GetService("ReplicatedStorage"):WaitForChild("Resources"))
local Table = Resources:LoadLibrary("Table")

local tick, wait = tick, wait

local HourDifference do
	-- Get the difference in seconds between os.time() and tick(), rounded to the nearest 15 minutes

	local SecondsPer15Minutes = 60 * 15
	HourDifference = math.floor((os.time() - tick()) / SecondsPer15Minutes + 0.5) * SecondsPer15Minutes
end

local SyncedPoller = {}
SyncedPoller.__index = {}

function SyncedPoller.new(Interval, Func)
	-- Calls Func every Interval seconds
	-- @param number Interval How often in seconds Func() should be called
	--	Obviously this uses `wait`, so 0 is a valid interval but it will in reality be about (1 / 30)
	-- @param function Func the function to call
	
	local self = setmetatable({
		Running = true
	}, SyncedPoller)

	spawn(function()
		while true do
			local t = tick() + HourDifference
			local TimeElapsed = t + wait(Interval - t % Interval)

			if self.Running then
					Func(TimeElapsed)
			else
					break
			end
		end
	end)
	
	return self
end

--- Cancels the previously instantiated poller.
function SyncedPoller.__index:Cancel()
	self.Running = false
end

return Table.Lock(SyncedPoller)