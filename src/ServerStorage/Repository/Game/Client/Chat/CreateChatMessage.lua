local chatMsg = {}

local starterGui = game:GetService("StarterGui")
local Resources = require(game.ReplicatedStorage.Resources)

function chatMsg:message(...)
	local msg, colour, font, textSize = ...
	
	local success, errorMessage = pcall(function()
		starterGui:SetCore("ChatMakeSystemMessage", {
			Text = msg;
			Color = colour or Color3.new(255, 255, 255);
			Font = font or Enum.Font.FredokaOne;
			TextSize = textSize or 16
		})
	end)
	if not success then self:message(errorMessage, Color3.fromRGB(255, 0, 0)) end
end

Resources:GetRemote("Message").OnClientEvent:Connect(function(message, colour)
	chatMsg:message(message, colour)
end)
	

--[[script.Parent.Parent.Signals.doChat.Event:Connect(function(...)
	chatMsg:createChatMessage(...)
end)]]--

return chatMsg
