local anim = {}

function anim:getAll(hum)
	return hum:GetPlayingAnimationTracks()
end

function anim:getSpecByName(hum, animName)
	local animsList = self:getAll(hum)
	for i, track in pairs(animsList) do
		if track.Name == animName then return track end
	end
end

function anim:getSpecById(hum, animId)
	local animsList = self:getAll(hum)
	for i, track in pairs(animsList) do
		if track.Animation.AnimationId == animId then return track end
	end
end

return anim
