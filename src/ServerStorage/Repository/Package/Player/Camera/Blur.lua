local blur = {}

blur._resources = require(game.ReplicatedStorage.Resources)
blur._enumeration = blur._resources:LoadLibrary("Enumeration")
blur._tweener = blur._resources:LoadLibrary("Tween")

function createBlurObj()
	local obj = Instance.new("BlurEffect", game.Lighting)
	obj.Name = "localBlur"
	obj.Size = 0
	return obj
end

blur.blurObj = game.Lighting:FindFirstChild("localBlur") or createBlurObj()

function blur:blur(amount, time)
	local InOutBack = blur._enumeration.EasingFunction.InOutBack.Value
	local tween = blur._tweener(blur.blurObj, "Size", amount, InOutBack, time, true)

	local returner = {}
	function returner:yield()
		tween.Completed:Wait()
	end
	return returner
end

function blur:blurDefault()
	return self:blur(20, 0.5)
end

function blur:returnBlur()
	return self:blur(0, 0.5)
end

return blur
