local module = {}

function module:scaleModel(model, scale, ignoreChecks)
	local collectedOrigSizes = {}
	local collectedOrigCF = {}

	local PrimaryPart = model.PrimaryPart
	local PrimaryPartCFrame = model:GetPrimaryPartCFrame()

	--Destroy welds
	for _,object in pairs(model:GetDescendants()) do
		if object:IsA('BasePart') then
			for _,object in pairs(object:GetDescendants()) do
				if object:IsA('Weld') or object:IsA('ManualWeld') or object:IsA('WeldConstraint') then
					pcall(function()
						object.Part0.Anchored = true
						object.Part1.Anchored = true
					end)
					object:Destroy()
				end
			end
		end
	end

	--Scale BaseParts
	for _,object in pairs(model:GetDescendants()) do
		if object:IsA('BasePart') then
			if not collectedOrigSizes[object] then
				collectedOrigSizes[object] = object.Size
			end
			if not collectedOrigCF[object] then
				collectedOrigCF[object] = object.CFrame
			end
			object.Size = collectedOrigSizes[object]*scale

			local distance = (collectedOrigCF[object].p - PrimaryPartCFrame.p)
			local rotation = (collectedOrigCF[object] - collectedOrigCF[object].p)
			object.CFrame = (CFrame.new(PrimaryPartCFrame.p + distance*scale) * rotation)
		end
	end
end

return module
