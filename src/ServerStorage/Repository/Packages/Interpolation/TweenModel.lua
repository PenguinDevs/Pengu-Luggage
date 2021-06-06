local module = {}

local tweenService = game:GetService("TweenService")

function module:tweenModel(model, CF, tweenInfo)
	local info = tweenInfo

	local CFrameValue = Instance.new("CFrameValue")
	CFrameValue.Value = model.PrimaryPart.CFrame

	CFrameValue:GetPropertyChangedSignal("Value"):connect(function()
		if model.PrimaryPart == nil then return end
		model:SetPrimaryPartCFrame(CFrameValue.Value)
	end)

	local tween = tweenService:Create(CFrameValue, info, {Value = CF})
	
	tween.Completed:connect(function()
		CFrameValue:Destroy()
		tween:Destroy()
		tween = nil
	end)
	
	return tween
end

return module
