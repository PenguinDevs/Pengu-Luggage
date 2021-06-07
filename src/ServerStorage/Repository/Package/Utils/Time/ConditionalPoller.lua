-- A class that continually calls a callback as long as a condition is true
-- @author Evaera
-- Calling :Poll() while already polling is ignored

local ConditionalPoller = {}
ConditionalPoller.__index = ConditionalPoller

function ConditionalPoller.new(interval, pollCallback, conditionCallback)
	return setmetatable({
		ConditionCallback = conditionCallback or function() return true end;
		PollCallback = pollCallback;
		Interval = interval;
		Polling = false;
		Destroyed = false;
	}, ConditionalPoller)
end

function ConditionalPoller:Poll()
	if self.Polling or self.Destroyed then
		return
	end

	self.Polling = true

	spawn(function()
		while self.ConditionCallback(self) and self.Polling do
			self.PollCallback(self)
			wait(self.Interval)
		end

		self.Polling = false
	end)

end

function ConditionalPoller:Cancel()
	self.Polling = false
end

function ConditionalPoller:Destroy()
	self:Cancel()
	self.Destroyed = true
end

return ConditionalPoller