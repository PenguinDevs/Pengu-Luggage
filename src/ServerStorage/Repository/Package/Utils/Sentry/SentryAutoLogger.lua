-- [ORIGINAL]
-- Sentry.io integration for remote error monitoring
-- Automatically logs errors, warnings, and prints
-- @author Validark

-- [FORKED]
-- Handled posting to sentry inside a promise
-- @author PenguinDevs

-- Types of Console Outputs to automatically Post to Sentry
local AutoSendTypes = {
	[Enum.MessageType.MessageOutput] = false;
	[Enum.MessageType.MessageInfo] = false;
	[Enum.MessageType.MessageWarning] = true;
	[Enum.MessageType.MessageError] = true;
}

local LogService = game:GetService("LogService")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- RoStrap Core
local Resources = require(ReplicatedStorage:WaitForChild("Resources"))
local Promise = Resources:LoadLibrary("Promise")

if not RunService:IsStudio() then
	local Sentry = Resources:LoadLibrary("Sentry")

	-- Connection
	LogService.MessageOut:Connect(function(Message, MessageType)
		if AutoSendTypes[MessageType] then
			local Traceback
			if MessageType == Enum.MessageType.MessageError then
				local t = {}
				repeat
					local Message2, MessageType2 = LogService.MessageOut:Wait()
					if MessageType2 == Enum.MessageType.MessageInfo then
						table.insert(t, Message2)
					end
				until Message2 == "Stack End" and MessageType2 == Enum.MessageType.MessageInfo
				Traceback = table.concat(t, "\n")
			end

			Promise.new(function(resolve, reject)
				local s, m = pcall(function()
					Sentry:Post(Message, Traceback or debug.traceback(), MessageType)
				end)
				local body = Message .. " " .. tostring(MessageType)
				if s then
					resolve(body)
				else
					reject(m, body)
				end
			end):andThen(function(body)
				print(string.format("Log sent: %s", body))
			end):catch(function(err, body)
				warn(string.format("Log failed to send: %s || Tried sending: %s", err, body))
			end)
		end
	end)
end

return false