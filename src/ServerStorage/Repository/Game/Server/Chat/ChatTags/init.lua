local module = {}

local TagList = require(script.List)
local ChatService
local RunService = game:GetService("RunService")

function module:playerProfileAssign(playerProfile)
	local self = {}

	spawn(function()
		if not ChatService then ChatService = require(game:GetService('ServerScriptService'):WaitForChild('ChatServiceRunner'):WaitForChild('ChatService')) end
		local speaker = ChatService:GetSpeaker(playerProfile.obj.Name)
		local role
		local success = pcall(function()
			role = playerProfile.obj:GetRoleInGroup(9551267)
		end)
		local count = 50
		local function getSpeaker()
			count -= 1
			if count <= 0 then print("a") return end
			wait(1)
			speaker = ChatService:GetSpeaker(playerProfile.obj.Name)
			if not speaker then getSpeaker() end
		end
		if playerProfile.passes.finished then playerProfile.passes.finished:Wait() end
		if not speaker then getSpeaker() end
		if not speaker then print("No speaker") return end
		if TagList.users[playerProfile.id] then
			local stat = TagList.users[playerProfile.id]
			speaker:SetExtraData("Tags", {{TagText = stat.tag, TagColor = stat.colour}})
			speaker:SetExtraData("ChatColor", stat.chatColour)
		elseif playerProfile.passes["VIP"] and (role == "Fishies" or role == "Guest") then
			speaker:SetExtraData("Tags", {{TagText = "VIP 👑", TagColor = Color3.fromRGB(255, 255, 0)}})
			speaker:SetExtraData("ChatColor", Color3.fromRGB(255, 115, 0))
		elseif playerProfile.obj.MembershipType == Enum.MembershipType.Premium then
			speaker:SetExtraData("Tags", {{TagText = "PREMIUM 💎", TagColor = Color3.fromRGB(0, 255, 255)}})
			speaker:SetExtraData("ChatColor", Color3.fromRGB(255, 115, 0))
		elseif TagList.roles[role] then
			local stat = TagList.roles[role]
			speaker:SetExtraData("Tags", {{TagText = stat.tag, TagColor = stat.colour}})
			speaker:SetExtraData("ChatColor", stat.chatColour)
		end
		self.speaker = speaker
	end)

	return self
end

return module
