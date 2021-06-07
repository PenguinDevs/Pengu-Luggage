-- Auto-Replicating PseudoInstances
-- @documentation https://rostrap.github.io/Libraries/Classes/ReplicatedPseudoInstance/
-- @author Validark

--[[
	ReplicatedPseudoInstances are PseudoInstances which, when inherited from, automatically replicate.

	CONSTRAINTS:
		You can't have read-only values in a class which auto-replicates.
			If you want that, use internal values and make a Get() function
		Events of ReplicatedPseudoInstances should always be fired with LocalPlayer as the first parameter

	BEHAVIOR:
		PseudoInstances, when instantiated, replicate to all subscribers.
			A "subscriber" is a Player which objects should be replicated to.
			A single Player is a subscriber if the Object is a Descendant of their Player object
			Every Player is a Subscriber if the Object is or is a Descendant of Workspace or ReplicatedStorage

		Replication has two phases:
			Initial Replication: this is when a table value is sent over with all the data in an object
			Partial Replication: this is when a single property is updated

	IMPLEMENTATION:
		PseudoInstances with lower ParentalDepth are replicated before Objects with higher ParentalDepths
			A ParentalDepth is the number of Parents an Object has before reaching game
			This must be the case, because we can't replicate Objects which are parented to other PseudoInstances until after those Parental PseudoInstances exist

--]]

local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")
local HttpService = game:GetService("HttpService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local IsServer = RunService:IsServer()
local IsClient = RunService:IsClient()

local Resources = require(ReplicatedStorage:WaitForChild("Resources"))
local Debug = Resources:LoadLibrary("Debug")
local Enumeration = Resources:LoadLibrary("Enumeration")
local SortedArray = Resources:LoadLibrary("SortedArray")
local PseudoInstance = Resources:LoadLibrary("PseudoInstance")

local Templates = Resources:GetLocalTable("Templates")

local RemoteEvent = Resources:GetRemoteEvent("PseudoInstanceReplicator")
local RemoteFunction = Resources:GetRemoteFunction("PseudoInstanceStartupVerify")

local AutoReplicatedInstances = {}
local LoadedPlayers = setmetatable({}, {__mode = "k"})

local FireClient

local function YieldUntilReadyToFire(Player, ...)
	repeat until LoadedPlayers[Player] or not wait()
	FireClient(Player, ...)
end

function FireClient(Player, ...)
	local Old = LoadedPlayers[Player]

	if Old then
		LoadedPlayers[Player] = Old + 1
		RemoteEvent:FireClient(Player, Old + 1, ...)
	else
		coroutine.resume(coroutine.create(YieldUntilReadyToFire), Player, ...)
	end
end

local function FireAllClientsExcept(Player1, ...)
	local Playerlist = Players:GetPlayers()

	for i = 1, #Playerlist do
		local Player2 = Playerlist[i]

		if Player1 ~= Player2 then
			FireClient(Player2, ...)
		end
	end
end

local SubscribingIndividuals = {} -- For when only ONE player receives updates
local ParentalDepths = {}

-- A SortedArray of Ids to objects sorted according to Parental depth
-- This will ensure that you don't replicate child instances and try to set their parents before the parents exist
local ReplicationOrder = SortedArray.new(nil, function(a, b)
	local d_a = ParentalDepths[a]
	local d_b = ParentalDepths[b]

	if d_a == d_b then
		return a < b
	else
		return d_a < d_b
	end
end)

local function ReplicateUpdateToInterestedParties(self, Id, i, v)
	if AutoReplicatedInstances[Id] then
		FireAllClientsExcept(nil, self.__class.ClassName, Id, i, v)
	else
		local PlayerToReplicateTo = SubscribingIndividuals[Id]

		if PlayerToReplicateTo then
			FireClient(PlayerToReplicateTo, self.__class.ClassName, Id, i, v)
		end
	end
end

local function OnPropertyChanged(self, i)
	local v = self[i]
	local Id = self.__id

	if i == "Parent" then
		local PlayerToReplicateTo

		if v then
			local ReplicateToAllPlayers = v == Players or v == Workspace or v == ReplicatedStorage or v:IsDescendantOf(Workspace) or v:IsDescendantOf(ReplicatedStorage)

			if not ReplicateToAllPlayers and v:IsDescendantOf(Players) then
				PlayerToReplicateTo = v
				while PlayerToReplicateTo.ClassName ~= "Player" do
					PlayerToReplicateTo = PlayerToReplicateTo.Parent
				end
			end

			-- If replicating to the server, we want to cache these and replicate them upon player joining (conditional upon parent)
			if ReplicateToAllPlayers then
				-- Get parental depth and cache it
				local ParentalDepth = 0
				local Current = self

				repeat
					Current = Current.Parent
					ParentalDepth = ParentalDepth + 1
				until Current == nil

				local Position = ReplicationOrder:Find(Id)
				ParentalDepths[Id] = ParentalDepth
				AutoReplicatedInstances[Id] = self

				if Position then
					ReplicationOrder:SortIndex(Position)
				else
					ReplicationOrder:Insert(Id)
				end

				FireAllClientsExcept(SubscribingIndividuals[Id], self.__class.ClassName, Id, self.__rawdata)
				SubscribingIndividuals[Id] = nil

				return
			elseif PlayerToReplicateTo then
				SubscribingIndividuals[Id] = PlayerToReplicateTo
				FireClient(PlayerToReplicateTo, self.__class.ClassName, Id, self.__rawdata)
			end
		end

		if not PlayerToReplicateTo then
			local PreviousSubscriber = SubscribingIndividuals[Id]

			if PreviousSubscriber then
				FireClient(PreviousSubscriber, self.__class.ClassName, Id)
				SubscribingIndividuals[Id] = nil
			end
		end

		-- If Parent was set to something that doesn't ReplicateToAllPlayers, take it out of auto-replicate
		if AutoReplicatedInstances[Id] then -- Destroy the element if it was previously replicating
			-- Destroy for everyone but who we are now replicating to (may be nil)
			FireAllClientsExcept(PlayerToReplicateTo, self.__class.ClassName, Id)
			AutoReplicatedInstances[Id] = nil
			ReplicationOrder:RemoveElement(Id)
		end
	else
		ReplicateUpdateToInterestedParties(self, Id, i, v)
	end
end

if IsServer then
	Players.PlayerAdded:Connect(function(Player)
		pcall(function()
			if RemoteFunction:InvokeClient(Player) then -- Yield until player loads
				local NumReplicationOrder = #ReplicationOrder

				for i = 1, NumReplicationOrder do
					local Id = ReplicationOrder[i]
					local self = AutoReplicatedInstances[Id]

					RemoteEvent:FireClient(Player, i, self.__class.ClassName, Id, self.__rawdata)
				end

			LoadedPlayers[Player] = NumReplicationOrder
			end
		end)
	end)

	RemoteEvent.OnServerEvent:Connect(function(Player, ClassName, Id, Event, ...) -- Fire events on the Server after they are fired on the client
		Event = (Templates[ClassName].Storage[Id] or Debug.Error("Object not found"))[Event]
		-- On the server, the first parameter will always be Player. This removes a duplicate.
		-- This also adds some security because a client cannot simply spoof it

		Event:Fire(Player, select(2, ...))
	end)
elseif IsClient then
	local OnClientEventNumber = 1 -- Guarenteed that this will resolve in the order in which replication is intended to occur

	RemoteEvent.OnClientEvent:Connect(function(EventNumber, ClassName, Id, RawData, Assigned) -- Handle objects being replicated to clients
		repeat until OnClientEventNumber == EventNumber or not wait()

		local Template = Templates[ClassName]

		if not Template then
			Resources:LoadLibrary(ClassName)
			Template = Templates[ClassName] or Debug.Error("Invalid ClassName")
		end

		local Object = Template.Storage[Id]

		if not Object then
			Object = PseudoInstance.new(ClassName, Id)
			Template.Storage[Id] = Object
		end

		local RawDataType = type(RawData)

		if RawDataType == "table" then
			for Property, Value in next, RawData do
				if Object[Property] ~= Value then
					Object[Property] = Value
				end
			end
		elseif RawDataType == "nil" then
			Object:Destroy()
		elseif RawDataType == "string" then
			Object[RawData] = Assigned
		else
			Debug.Error("Invalid RawData type, expected table, nil, or string, got %s", RawDataType)
		end

		OnClientEventNumber = OnClientEventNumber + 1
	end)

	function RemoteFunction.OnClientInvoke()
		return true
	end
end

local Ids = 0 -- Globally shared Id for instances, would break beyond 2^53 instances ever

return PseudoInstance:Register("ReplicatedPseudoInstance", {
	Storage = false; -- Mark this Class as abstract
	Internals = {"__id"};
	Properties = {};
	Events = {};
	Methods = {
		Destroy = function(self)
			local Id = self.__id

			if Id then
				self.__class.Storage[Id] = nil
				ReplicationOrder:RemoveElement(Id)

				if IsServer then -- Replicate Destroy
					ReplicateUpdateToInterestedParties(self, Id)
				end

				SubscribingIndividuals[Id] = nil
				AutoReplicatedInstances[Id] = nil
			end
			self:super("Destroy")
		end;
	};

	Init = function(self, Id)
		self:superinit()

		if IsServer then
			if not Id then
				Id = Ids + 1
				Ids = Id
			end
			self.Changed:Connect(OnPropertyChanged, self)
		elseif IsClient then
			if Id then
				for Event in next, self.__class.Events do
					if Event ~= "Changed" then
						self[Event]:Connect(function(...)
							RemoteEvent:FireServer(self.__class.ClassName, Id, Event, ...)
						end)
					end
				end
			end
		end

		if Id then
			(self.__class.Storage or Debug.Error(self.__class.ClassName .. " is an abstract class and cannot be instantiated"))[Id] = self
			self.__id = Id
		end
	end;
})
