local handler = {}

local physicsService = game:GetService("PhysicsService")

local playerCollisionGroupName = "Players"
--physicsService:CreateCollisionGroup(playerCollisionGroupName)
physicsService:CollisionGroupSetCollidable(playerCollisionGroupName, playerCollisionGroupName, false)
 
--local previousCollisionGroups = {}
 
function handler:setCollisionGroup(object)
	if not object then return end
	if object:IsA("BasePart") then
		--previousCollisionGroups[object] = object.CollisionGroupId
		physicsService:SetPartCollisionGroup(object, playerCollisionGroupName)
	end
end

function handler:setCollisionGroupRecursive(object)
	self:setCollisionGroup(object)
 
	for _, child in ipairs(object:GetChildren()) do	
		self:setCollisionGroupRecursive(child)
	end
end

function handler:setCollisionGroupOnce(object)
	self:setCollisionGroup(object)
 
	for _, child in ipairs(object:GetChildren()) do
		self:setCollisionGroup(child)
	end
end

-- function handler:resetCollisionGroup(object)
-- 	local previousCollisionGroupId = previousCollisionGroups[object]
-- 	if not previousCollisionGroupId then return end
 
-- 	local previousCollisionGroupName = physicsService:GetCollisionGroupName(previousCollisionGroupId)
-- 	if not previousCollisionGroupName then return end
 
-- 	physicsService:SetPartCollisionGroup(object, previousCollisionGroupName)
-- 	previousCollisionGroups[object] = nil
-- end

return handler
