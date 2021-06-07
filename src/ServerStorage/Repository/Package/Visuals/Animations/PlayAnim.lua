local anim = {}

local GetAnimations = require(script.Parent.GetAnimations)

anim.animationList = {}

function anim:playAnimObjOnHum(hum, anim, neverCancel, looped)
	local temp = GetAnimations:getSpecById(hum, anim.AnimationId)
	if temp then temp:Stop() end
	local track = hum:LoadAnimation(anim)
	if looped then track.Looped = true else track.Looped = false end
	track:Play()
	--[[if neverCancel then
		track.Stopped:Connect(function()
			local idleAnim = hum:LoadAnimation(anim)
			idleAnim:Play()
		end)
	end]]--
	return track
end

function anim:playOnHum(hum, id, name, neverCancel, looped)
	local animObj
	if not anim.animationList[id] then
		animObj = Instance.new("Animation", workspace)
		animObj.Name = name or animObj.Name
		animObj.AnimationId = id
		anim.animationList[id] = animObj
	else
		animObj = anim.animationList[id]
		animObj.Name = name or animObj.Name
	end
	
	local track = self:playAnimObjOnHum(hum, animObj, neverCancel, looped)
	
	return track
end

return anim
