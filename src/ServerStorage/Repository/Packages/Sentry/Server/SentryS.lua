-- Sentry.io integration for remote error monitoring
-- @filtering Server
-- @author Validark

--[[
	Example, client:
	local Try = require("Try")
	local Sentry = require("Sentry")
	Try(function(x) error("test client error " .. x) end, "1")
		:Catch(Sentry.Post)
--]]

-- Configuration
local DSN = "https://10fa8b4f8f5c4b049bca9cc69839f041:2ee2164de3d846afb5fc5dc25ad1a089@o478558.ingest.sentry.io/5521246"
local ENABLE_WARNINGS = true -- Doesn't affect uploading, just puts them in the Server Logs
local MAX_CLIENT_ERROR_COUNT = 10

-- Module Data
local SDK_NAME = "Sentry"
local SDK_VERSION = "RoStrap"
local SENTRY_VERSION = "7"

-- Assertions
local Protocol, PublicKey, SecretKey, Host, DSNPath, ProjectId = DSN:match("^([^:]+)://([^:]+):([^@]+)@([^/]+)(.*/)(%d+)$")
assert(Protocol and Protocol:match("^https?$"), "invalid DSN: protocol not valid")
assert(PublicKey, "invalid DSN: public key not valid")
assert(SecretKey, "invalid DSN: secret key not valid")
assert(Host, "invalid DSN: host not valid")
assert(DSNPath, "invalid DSN: path not valid")
assert(ProjectId, "invalid DSN: project ID not valid")

-- Constants
local RequestUrl = ("%s://%s%sapi/%d/store/"):format(Protocol, Host, DSNPath, ProjectId)
local AuthHeader = ("Sentry sentry_version=%d,sentry_timestamp=%%s,sentry_key=%s,sentry_secret=%s,sentry_client=%s/%s"):format(SENTRY_VERSION, PublicKey, SecretKey, SDK_NAME, SDK_VERSION)

-- Services
local HttpService = game:GetService("HttpService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- RoStrap Core
local Resources = require(ReplicatedStorage:WaitForChild("Resources"))

-- Libraries
local Try = Resources:LoadLibrary("Try")
local Date = Resources:LoadLibrary("Date")
local Table = Resources:LoadLibrary("Table")
local Enumeration = Resources:LoadLibrary("Enumeration")

Enumeration.IssueType = {"Debug", "Info", "Warning", "Error", "Fatal"}

local IssueTypes = Enumeration.IssueType:GetEnumerationItems()

for i = 1, #IssueTypes do
	IssueTypes[i - 1] = IssueTypes[i].Name:gsub("^%u", string.lower, 1)
end

-- RemoteEvent
local RemoteEvent = Resources:GetRemoteEvent("Sentry")

-- Module Table
local Sentry = {}

-- Mute Warnings if ENABLE_WARNINGS is not true
local warn = ENABLE_WARNINGS and warn or function() end

local LockedSentry = Table.Lock(Sentry)

local function Post(self, Message, Traceback, MessageType, Logger)
	if self ~= LockedSentry then
		Message, Traceback, MessageType, Logger = self, Message, Traceback, MessageType
	end

	local Level

	if type(MessageType) == "number" then
		Level = IssueTypes[MessageType]
	elseif typeof(MessageType) == "EnumItem" then
		Level = MessageType.Name:gsub("Message", "", 1):gsub("^%u", string.lower, 1):gsub("output", "debug", 1)
	elseif type(MessageType) == "userdata" then
		Level = IssueTypes[MessageType.Value]
	end

	local Timestamp = Date("!%Y-%m-%dT%H:%M:%S")

	local Packet = {
		level = Level or "error";
		message = Message;
		event_id = HttpService:GenerateGUID(false):gsub("%-", "");
		timestamp = Timestamp;
		logger = Logger or "server";
		platform = "other";
		sdk = {
			name = SDK_NAME;
			version = SDK_VERSION;
		}
	}

	local Headers = {
		Authorization = AuthHeader:format(Timestamp);
	}

	local StackTrace = {}
	local Count = 0

	Traceback = (Traceback or debug.traceback()):gsub("([\r\n])[^\r\n]+upvalue Error[\r\n]", "%1", 1)

	for Line in Traceback:gmatch("[^\n\r]+") do
		if Line ~= "Stack Begin" and Line ~= "Stack End" then
			local Path, LineNum, Value = Line:match("^Script '(.-)', Line (%d+)%s?%-?%s?(.*)$")
			if Path and LineNum and Value then
				Count = Count + 1
				StackTrace[Count] = {
					["filename"] = Path;
					["function"] = Value;
					["lineno"] = LineNum;
				}
			else
				Count = 0
				break
			end
		end
	end

	--if Count == 0 then
	--	warn("[Sentry] Failed to convert string traceback to stacktrace: invalid traceback:", Traceback)
	--else
		Packet.culprit = StackTrace[1].filename

		-- Flip StackTrace around
		for a = 1, 0.5 * Count do
			local b = 1 + Count - a
			StackTrace[a], StackTrace[b] = StackTrace[b], StackTrace[a]
		end

		Packet.exception = {{
			type = Packet.logger:gsub("^%l", string.upper, 1) .. Packet.level:gsub("^%l", string.upper, 1);
			value = Message;
			stacktrace = {frames = StackTrace}
		}}
	--end

	Try(function()
		return HttpService:JSONEncode(Packet)
	end)
	:Then(function(JSONPacket)
		HttpService:PostAsync(RequestUrl, JSONPacket, Enum.HttpContentType.ApplicationJson, true, Headers)
	end)

	:Catch("HTTP 429", function()
		warn("[Sentry] HTTP 429 Retry-After in TrySend, disabling SDK for this server.")
	end)

	:Catch("HTTP 401", function()
		warn("[Sentry] Please check the validity of your DSN.")
	end)

	:Catch("HTTP 4", function(Error, StackTraceback, Attempt)
		local HeaderString = ""
		for i, v in next, Headers do
			HeaderString = HeaderString .. "\t" .. i .. " " .. v .. "\n"
		end
		warn(("[Sentry] HTTP %d in TrySend, JSON packet:"):format(Error:match("^HTTP (%d+)")), "\n", Attempt.LastArguments[1], "\nHeaders:\n", HeaderString, "Response:", Error)
	end)

	return true
end

function Sentry:Post(Message, Traceback, MessageType)
	-- Post(string Message [string MessageType, string Traceback])
	-- Posts parameters to Sentry.io
	-- Supports hybrid syntax calling

	return Post(self, Message, Traceback, MessageType, "server")
end

local ErrorCount = {}

RemoteEvent.OnServerEvent:Connect(function(Player, Message, Traceback, MessageType)
	local PlayerName = Player.Name
	local Count = ErrorCount[PlayerName] or MAX_CLIENT_ERROR_COUNT

	if Count ~= 0 then
		if type(Message) == "string" and type(MessageType) == "number" and (type(Traceback) == "string" or Traceback == nil) and Post(Message, Traceback, MessageType, "client") then
			ErrorCount[PlayerName] = Count - 1
		else
			error(("[Sentry] Player '%s' tried to send spoofed data, their ability to report errors has been disabled. Message:\n%s\nTraceback:\n%s"):format(PlayerName, tostring(Message), tostring(Traceback)))
			ErrorCount[PlayerName] = 0
		end
	end
end)

return LockedSentry