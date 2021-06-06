local uiOC = {}
uiOC.__index = uiOC

local tweenService = game:GetService("TweenService")
local runService = game:GetService("RunService")

function uiOC:open(ui, currentStat)
	local uiTweenStats = currentStat

--[[
	local info = TweenInfo.new(0.5, Enum.EasingStyle.Bounce, Enum.EasingDirection.Out)
	
	local posValue = Instance.new("NumberValue")
	posValue.Value = ui.Position.Y.Scale
	
	posValue:GetPropertyChangedSignal("Value"):connect(function()
		ui.Position = UDim2.new(0.5, 0, posValue.Value, 0)
	end)
	
	local function finaliseTweening()
		if uiTweenStats == nil then uiTweenStats = {} end
		uiTweenStats["pos"] = tweenService:Create(posValue, info, {Value = 0.5})
		uiTweenStats["pos"]:Play()
		uiTweenStats["pos"].Completed:connect(function()
			posValue:Destroy()
		end)
	end
	finaliseTweening()
--]]

	-- ui:TweenPosition(currentStat.closePos or UDim2.new(0.5, 0, -0.6, 0), Enum.EasingDirection.Out, Enum.EasingStyle.Linear, 0, true)
	ui:TweenPosition(currentStat.openPos or UDim2.new(0.5, 0, 0.5, 0), Enum.EasingDirection.InOut, Enum.EasingStyle.Quint, 0.15, true)
	runService.RenderStepped:Wait()
	return uiTweenStats
end

function uiOC:close(ui, currentStat)
	local uiTweenStats = currentStat

--[[
	local info = TweenInfo.new(0.5, Enum.EasingStyle.Bounce, Enum.EasingDirection.Out)
	
	local posValue = Instance.new("NumberValue")
	posValue.Value = ui.Position.Y.Scale
	
	posValue:GetPropertyChangedSignal("Value"):connect(function()
		ui.Position = UDim2.new(0.5, 0, posValue.Value, 0)
	end)
	local function finaliseTweening()
		if uiTweenStats == nil then uiTweenStats = {} end
		uiTweenStats["pos"] = tweenService:Create(posValue, info, {Value = -0.5})
		uiTweenStats["pos"]:Play()
		uiTweenStats["pos"].Completed:connect(function()
			posValue:Destroy()
		end)
	end
	finaliseTweening()
--]]
	
	ui:TweenPosition(currentStat.closePos or UDim2.new(0.5, 0, -0.6, 0), Enum.EasingDirection.InOut, Enum.EasingStyle.Quint, 0.15, true)
	-- ui:TweenPosition(currentStat.closePos or UDim2.new(0.5, 0, 1.6, 0), Enum.EasingDirection.In, Enum.EasingStyle.Quint, 0.5, true)
	-- spawn(function()
	-- 	wait(0.5)
	-- 	if not currentStat._shown then
	-- 		ui:TweenPosition(currentStat.closePos or UDim2.new(0.5, 0, -0.6, 0), Enum.EasingDirection.Out, Enum.EasingStyle.Linear, 0, true)
	-- 	end
	-- end)
	runService.RenderStepped:Wait()
	return uiTweenStats
end

return uiOC
