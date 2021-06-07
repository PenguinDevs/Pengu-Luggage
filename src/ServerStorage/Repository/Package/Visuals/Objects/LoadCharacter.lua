local Players = game:GetService("Players")
local PhysicsService = game:GetService("PhysicsService")

return function(userId, parent, isR15)
	--local userId = Players:GetUserIdFromNameAsync(username)
	local characterData
	local s = pcall(function()
		characterData = Players:GetCharacterAppearanceAsync(userId)
	end)
	if not s then return script.R15:Clone() end
	
	local characterModel = isR15 == nil and (script[characterData.IsR15.Value and "R15" or "R6"]:Clone()) or script[isR15 and "R15" or "R6"]:Clone()
	local characterHead = characterModel.Head
	local characterHumanoid = characterModel.Humanoid
	isR15 = characterModel.Name == "R15" -- populate the variable if isR15 was not supplied
	
	for _,obj in next, characterData:GetChildren() do
		if obj:IsA("Accessory") then
			characterHumanoid:AddAccessory(obj)
		end
	end
	
	for _,obj in next, characterData:GetChildren() do
		if obj:IsA("ValueBase") and isR15 then
			obj.Parent = characterHumanoid
		end
	end
	
	for _,obj in next, characterData:GetChildren() do
		if isR15 then
			if obj.Name == "R15ArtistIntent" then
				for _,bodyPart in next, obj:GetChildren() do
					characterHumanoid:ReplaceBodyPartR15(Enum.BodyPartR15[bodyPart.Name], bodyPart)
					PhysicsService:SetPartCollisionGroup(bodyPart, "Players")
				end
			end
		else
			if obj.Name == "R6" then
				obj:GetChildren()[1].Parent = characterModel
			end
		end
	end
	
	local bodyColors = characterData:FindFirstChild("Body Colors")
	if bodyColors then
		bodyColors.Parent = characterModel
	end
	
	local shirt = characterData:FindFirstChild("Shirt")
	if shirt then
		shirt.Parent = characterModel
	end
	
	local tshirt = characterData:FindFirstChild("Shirt Graphic")
	if tshirt then
		tshirt.Parent = characterModel
	end
	
	local pants = characterData:FindFirstChild("Pants")
	if pants then
		pants.Parent = characterModel
	end
	
	local head = characterData:FindFirstChild("Mesh")
	if head then
		characterHead.Mesh:Destroy()
		head.Parent = characterHead
	end
	
	local face = characterData:FindFirstChild("face")
	if face then
		characterHead.face:Destroy()
		face.Parent = characterHead
	end
	
	--characterModel.Name = username
	characterModel.Parent = parent
	
	characterData:Destroy()
	
	return characterModel
end