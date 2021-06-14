-- Tween service simplified in a module, as well as supporting overrides
-- @author PenguinDevs

local Resources = require(game.ReplicatedStorage.Resources)

local TweenService = game:GetService("TweenService")
local Janitor = Resources:LoadLibrary("Janitor")

local module = {}
local meta = {}

local storedTweens = {}

function module.new(object, goals, tweenInfo, override)
	local tween = TweenService:Create(object, tweenInfo, goals)

	local self = {}
	self.tween = tween
	self.janitor = Janitor.new()

	function self:Play()
		self.tween:Play()

		local ret = {}
		function ret:await()
			if self.tween.PlaybackState == Enum.PlaybackState.Playing then
				self.tween.Completed:Wait()
			end
		end

		return ret
	end

	function self:Cancel()
		self.tween:Cancel()
	end

	function self:Destroy()
		self.janitor:Cleanup()
	end

	self = setmetatable(self, {
		__call = function()
			self:Play()
		end;
		__index = function(_, ...)
			if ... == "Status" then
				return self.tween.PlaybackState
			elseif ... == "Completed" then
				return self.tween.Completed
			else
				return self[...]
			end
		end
	})

	if override then
		if storedTweens[object] then
			storedTweens[object]:Destroy()
		end
	end
	self()

	self.janitor:Add(function()
		if self.Status == Enum.PlaybackState.Playing then
			self:Cancel()
		end
	end)
	self.janitor:Add(self.tween, "Destroy")

	storedTweens[object] = self
	self.janitor:Add(function()
		storedTweens[object] = nil
	end)

	return self
end

meta.__call = module.new

return setmetatable(module, meta)