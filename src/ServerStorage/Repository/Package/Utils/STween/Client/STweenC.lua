local module = {}

local Resources = require(game.ReplicatedStorage.Resources)
local Tween = Resources:LoadLibrary("Tween")
local Enumeration = Resources:LoadLibrary("Enumeration")
local TweenModel = Resources:LoadLibrary("TweenModel")
local TweenService = game:GetService("TweenService")

local Remote = game.ReplicatedStorage:WaitForChild("ServerTween")

Remote.OnClientEvent:Connect(function(ignoreTween, obj, prop, amount, ...)
	if ignoreTween then
		if prop == "modelCF" then
			obj:SetPrimaryPartCFrame(amount)
		else
			obj[prop] = amount
		end
	else
		if prop == "modelCF" then
			local dur, easingDir, easingStyle = ...
			local tweenInfo = TweenInfo.new(dur, easingDir, easingStyle)
			TweenModel:tweenModel(obj, amount, tweenInfo):Play()
		else
			-- local easing, dur, override = ...
			-- local easingStyle = Enumeration.EasingFunction[easing].Value
			-- --print(obj, prop, amount, easingStyle, dur, override)
			-- local tween = Tween(obj, prop, amount, easingStyle, dur, override)
			-- tween:Destroy()

			local easing, dur, override = ...
			local easingDir
			local foundPos
			if string.find(easing, "InOut") then
				foundPos = #"InOut"
				easingDir = Enum.EasingDirection.InOut
			elseif string.find(easing, "Out") then
				foundPos = #"Out"
				easingDir = Enum.EasingDirection.Out
			elseif string.find(easing, "In") then
				foundPos = #"In"
				easingDir = Enum.EasingDirection.In
			else
				warn("could not find easing direction for", easing)
			end
			local easingStyle = Enum.EasingStyle[string.sub(easing, foundPos + 1)]
			local target = {}
			target[prop] = amount
			local tween = TweenService:Create(obj, TweenInfo.new(dur, easingStyle, easingDir), target)
			tween:Play()
			tween.Completed:Wait()
			tween:Cancel()
			tween:Destroy()
		end
	end
end)

return module
