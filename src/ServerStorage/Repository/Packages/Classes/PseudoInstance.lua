-- Rigidly defined PseudoInstance class system to instantiate Roblox-like instances
-- @documentation https://rostrap.github.io/Libraries/Classes/PseudoInstance/
-- @author Validark

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Resources = require(ReplicatedStorage:WaitForChild("Resources"))

local Debug = Resources:LoadLibrary("Debug")
local Table = Resources:LoadLibrary("Table")
local Typer = Resources:LoadLibrary("Typer")
local Signal = Resources:LoadLibrary("Signal")
local Janitor = Resources:LoadLibrary("Janitor")
local SortedArray = Resources:LoadLibrary("SortedArray")
local Enumeration = Resources:LoadLibrary("Enumeration")

local Templates = Resources:GetLocalTable("Templates")
local Metatables = setmetatable({}, {__mode = "kv"})

local function Empty() end

local function Metatable__index(this, i)
	local self = Metatables[this] or this -- self is the internal copy
	local Value = self.__rawdata[i]
	local ClassTemplate = self.__class

	if Value == nil then
		Value = ClassTemplate.Methods[i]
	else
		return Value
	end

	if Value == nil and not ClassTemplate.Properties[i] then
		local GetConstructorAndDestructor = ClassTemplate.Events[i]

		if GetConstructorAndDestructor then
			if self == this then -- if internal access
				local Event = Signal.new(GetConstructorAndDestructor(self))
				rawset(self, i, Event)
				return Event
			else
				return self[i].Event
			end
		elseif ClassTemplate.Internals[i] == nil or self ~= this then
			Debug.Error("[%s] is not a valid Property of " .. tostring(self), i)
		end
	else
		return Value
	end
end

local function Metatable__newindex(this, i, v)
	local self = Metatables[this] or this
	local Type = self.__class.Properties[i]

	if Type then
		Type(self, v)
	elseif self == this and self.__class.Internals[i] ~= nil then
		rawset(self, i, v)
	else
		Debug.Error(i .. " is not a modifiable property")
	end
end

local function Metatable__tostring(self)
	return (Metatables[self] or self).__class.ClassName
end

local function Metatable__rawset(self, Property, Value)
	self.__rawdata[Property] = Value
	return self
end

local function ReturnHelper(Success, ...)
	if Success then
		return ...
	else
		Debug.Error(...)
	end
end

local ThreadDepthTracker = setmetatable({}, {__mode = "k"})

local function Metatable__super(self, MethodName, ...)
	local Thread = coroutine.running()
	local InSuperclass = ThreadDepthTracker[Thread]
	local PreviousClass = InSuperclass or self.__class
	local Class = PreviousClass

	while Class.HasSuperclass do
		Class = Class.Superclass
		local Function = Class.Methods[MethodName]

		if Function and Function ~= PreviousClass.Methods[MethodName] then
			if InSuperclass then
				ThreadDepthTracker[Thread] = Class
				return Function(self, ...)
			else
				local NewThread = coroutine.create(Function)
				ThreadDepthTracker[NewThread] = Class

				return ReturnHelper(coroutine.resume(NewThread, self, ...))
			end
		end
	end

	return Debug.Error("Could not find parent method " .. MethodName .. " of " .. PreviousClass.ClassName)
end

local PseudoInstance = {}

local function DefaultInit(self, ...)
	self:superinit(...)
end

local DataTableNames = SortedArray.new{"Events", "Methods", "Properties", "Internals"}
local MethodIndex = DataTableNames:Find("Methods")

local function Filter(this, self, ...)
	-- Filter out `this` and convert to `self`
	-- Try not to construct a table if possible (we keep it light up in here)

	local ArgumentCount = select("#", ...)

	if ArgumentCount > 2 then
		local Arguments

		for i = 1, ArgumentCount do
			if select(i, ...) == this then
				Arguments = {...} -- Create a table if absolutely necessary
				Arguments[i] = self

				for j = i + 1, ArgumentCount do -- Just loop through the rest normally if a table was already created
					if Arguments[j] == this then
						Arguments[j] = self
					end
				end

				return unpack(Arguments)
			end
		end

		return ...
	else
		if this == ... then -- Optimize for most cases where they only returned a single parameter
			return self
		else
			return ...
		end
	end
end

local function superinit(self, ...)
	local CurrentClass = self.currentclass

	if CurrentClass.HasSuperclass then
		self.currentclass = CurrentClass.Superclass
	else
		self.currentclass = nil
		self.superinit = nil
	end

	CurrentClass.Init(self, ...)
end

function PseudoInstance.Register(_, ClassName, ClassData, Superclass)
	if type(ClassData) ~= "table" then Debug.Error("Register takes parameters (string ClassName, table ClassData, Superclass)") end

	for i = 1, #DataTableNames do
		local DataTableName = DataTableNames[i]

		if not ClassData[DataTableName] then
			ClassData[DataTableName] = {}
		end
	end

	for Property, Function in next, ClassData.Properties do
		if type(Function) == "table" then
			ClassData.Properties[Property] = Typer.AssignSignature(2, Function, function(self, Value)
				self:rawset(Property, Value)
			end)
		end
	end

	local Internals = ClassData.Internals

	for i = 1, #Internals do
		Internals[Internals[i]] = false
		Internals[i] = nil
	end

	local Events = ClassData.Events

	for i = 1, #Events do
		Events[Events[i]] = Empty
		Events[i] = nil
	end

	ClassData.Abstract = false

	for MethodName, Method in next, ClassData.Methods do -- Wrap to give internal access to private metatable members
		if Method == 0 then
			ClassData.Abstract = true
		else
			ClassData.Methods[MethodName] = function(self, ...)
				local this = Metatables[self]

				if this then -- External method call
					return Filter(this, self, Method(this, ...))
				else -- Internal method call
					return Method(self, ...)
				end
			end
		end
	end

	ClassData.Init = ClassData.Init or DefaultInit
	ClassData.ClassName = ClassName

	-- Make properties of internal objects externally accessible
	if ClassData.WrappedProperties then
		for ObjectName, Properties in next, ClassData.WrappedProperties do
			for i = 1, #Properties do
				local Property = Properties[i]

				if ClassData.Properties[Property] then
					Debug.Error("Identifier \"" .. Property .. "\" was used in both Properties and WrappedProperties")
				else
					ClassData.Properties[Property] = function(this, Value)
						local Object = this[ObjectName]

						if Object then
							Object[Property] = Value
						end

						this:rawset(Property, Value)
					end
				end
			end
		end

		local PreviousInit = ClassData.Init

		ClassData.Init = function(self, ...)
			PreviousInit(self, ...)

			for ObjectName, Properties in next, ClassData.WrappedProperties do
				for i = 1, #Properties do
					local Property = Properties[i]
					local Object = self[ObjectName]

					if Object then
						if self[Property] == nil then
							self[Property] = Object[Property] -- This will implicitly error if they do something stupid
						end
					else
						Debug.Error(ObjectName .. " is not a valid member of " .. ClassName)
					end
				end
			end
		end
	end

	if Superclass == nil then
		Superclass = Templates.PseudoInstance
	end

	if Superclass then -- Copy inherited stuff into ClassData
		ClassData.HasSuperclass = true
		ClassData.Superclass = Superclass

		for a = 1, #DataTableNames do
			local DataTable = DataTableNames[a]
			local ClassTable = ClassData[DataTable]
			for i, v in next, Superclass[DataTable] do
				if not ClassTable[i] then
					ClassTable[i] = v == 0 and Debug.Error(ClassName .. " failed to implement " .. i .. " from its superclass " .. Superclass.ClassName) or v
				end
			end
		end
	else
		ClassData.HasSuperclass = false
	end

	local Identifiers = {} -- Make sure all identifiers are unique

	for a = 1, #DataTableNames do -- Make sure there aren't any duplicate names
		local DataTableName = DataTableNames[a]
		for i in next, ClassData[DataTableName] do
			if type(i) == "string" then
				if Identifiers[i] then
					Debug.Error("Identifier \"" .. i .. "\" was used in both " .. DataTableNames[Identifiers[i]] .. " and " .. DataTableName)
				else
					Identifiers[i] = a
				end
			else
				Debug.Error("%q is not a valid Identifier, found inside " .. DataTableName, i)
			end
		end
	end

	local LockedClass = Table.Lock(ClassData)
	Templates[ClassName] = LockedClass
	return LockedClass
end

local function AccessProperty(self, Property)
	local _ = self[Property]
end

PseudoInstance:Register("PseudoInstance", { -- Generates a rigidly defined userdata class with `.new()` instantiator
	Internals = {
		"Children", "PropertyChangedSignals", "Janitor";

		rawset = function(self, Property, Value)
			self.__rawdata[Property] = Value
			local PropertyChangedSignal = self.PropertyChangedSignals and self.PropertyChangedSignals[Property]

			if PropertyChangedSignal and PropertyChangedSignal.Active then
				PropertyChangedSignal:Fire(Value)
			end

			return self
		end;

		SortByName = function(a, b)
			return a.Name < b.Name
		end;

		ParentalChange = function(self)
			local this = Metatables[self.Parent]

			if this then
				this.Children:Insert(self)
			end
		end;

		ChildNameMatchesObject = function(ChildName, b)
			return ChildName == b.Name
		end;

		ChildNamePrecedesObject = function(ChildName, b)
			return ChildName < b.Name
		end;

		SetEventActive = function(Event)
			Event.Active = true
		end;

		SetEventInactive = function(Event)
			Event.Active = false
		end;
	};

	Properties = { -- Only Indeces within this table are writable, and these are the default values
		Archivable = Typer.Boolean; -- Values written to these indeces must match the initial type (unless it is a function, see below)
		Parent = Typer.OptionalInstance;
		Name = Typer.String;
	};

	Events = {
		Changed = function(self)
			local Assigned = Janitor.new()

			return function(Event)
				for Property in next, self.__class.Properties do
					Assigned:Add(self:GetPropertyChangedSignal(Property):Connect(function()
						Event:Fire(Property)
					end), "Disconnect")
				end
			end, Assigned
		end;
	};

	Methods = {
		Clone = function(self)
			if self.Archivable then
				local CurrentClass = self.__class
				local New = Resources:LoadLibrary("PseudoInstance").new(CurrentClass.ClassName)

				repeat
					for Property in next, CurrentClass.Properties do
						if Property ~= "Parent" then
							local Old = self[Property]
							if Old ~= nil then
								if Typer.Instance(Old) then
									Old = Old:Clone()
								end

								New[Property] = Old
							end
						end
					end
					CurrentClass = CurrentClass.HasSuperclass and CurrentClass.Superclass
				until not CurrentClass

				return New
			else
				return nil
			end
		end;

		GetFullName = function(self)
			return (self.Parent and self.Parent:GetFullName() .. "." or "") .. self.Name
		end;

		IsDescendantOf = function(self, Grandparent)
			return self.Parent == Grandparent or (self.Parent and self.Parent:IsDescendantOf(Grandparent)) or false
		end;

		GetPropertyChangedSignal = function(self, String)
			if type(String) ~= "string" then Debug.Error("invalid argument 2: string expected, got %s", String) end
			local PropertyChangedSignal = self.PropertyChangedSignals[String]

			if not PropertyChangedSignal then
				if not pcall(AccessProperty, self, String) then Debug.Error("%s is not a valid Property of " .. tostring(self), String) end
				PropertyChangedSignal = Signal.new(self.SetEventActive, self.SetEventInactive)
				self.Janitor:Add(PropertyChangedSignal, "Destroy")
				self.PropertyChangedSignals[String] = PropertyChangedSignal
			end

			return PropertyChangedSignal.Event
		end;

		FindFirstChild = function(self, ChildName, Recursive)
			local Children = self.Children

			if Recursive then
				for i = 1, #Children do
					local Child = Children[i]

					if Child.Name == ChildName then
						return Child
					end

					local Grandchild = Child:FindFirstChild(ChildName, Recursive)

					if Grandchild then
						return Grandchild
					end
				end
			else -- Much faster than recursive
				return Children:Find(ChildName, self.ChildNameMatchesObject, self.ChildNamePrecedesObject)
			end
		end;

		GetChildren = function(self)
			return self.Children:Copy()
		end;

		IsA = function(self, ClassName)
			local CurrentClass = self.__class

			repeat
				if ClassName == CurrentClass.ClassName then
					return true
				end
				CurrentClass = CurrentClass.HasSuperclass and CurrentClass.Superclass
			until not CurrentClass

			return ClassName == "<<</sc>>>" -- This is a reference to the old Roblox chat...
		end;

		Destroy = function(self)
			self.Archivable = false
			self.Parent = nil

			for GlobalSelf, InternalSelf in next, Metatables do
				if self == InternalSelf then
					self.Janitor[GlobalSelf] = nil
					Metatables[GlobalSelf] = nil
				end
			end

			self.Janitor:Cleanup()

			-- Nuke the object
			if self.__rawdata then
				for i in next, self.__rawdata do
					rawset(self.__rawdata, i, nil)
				end
			end

			for i, v in next, self do
				if Signal.IsA(v) then
					v:Destroy()
				end

				rawset(self, i, nil)
			end
		end;
	};

	Init = function(self)
		local Name = self.__class.ClassName

		-- Default properties
		self.Name = Name
		self.Archivable = true

		-- Read-only
		self:rawset("ClassName", Name)

		-- Internals
		self.Children = SortedArray.new(nil, self.SortByName)
		self.PropertyChangedSignals = {}

		self:GetPropertyChangedSignal("Parent"):Connect(self.ParentalChange, self)
	end;
}, false)

function PseudoInstance.new(ClassName, ...)
	local Class = Templates[ClassName]

	if not Class then
		Resources:LoadLibrary(ClassName)
		Class = Templates[ClassName] or Debug.Error("Invalid ClassName: " .. ClassName)
	end

	if Class.Abstract then
		Debug.Error("Cannot instantiate an abstract " .. ClassName)
	end

	local self = newproxy(true)
	local Mt = getmetatable(self)

	-- This one can be overwritten by an internal function if so desired :D
	Mt.rawset = Metatable__rawset

	for i, v in next, Class.Internals do
		Mt[i] = v
	end

	-- Internal members
	Mt.__class = Class
	Mt.__index = Metatable__index
	Mt.__rawdata = {}
	Mt.__newindex = Metatable__newindex
	Mt.__tostring = Metatable__tostring
	Mt.__metatable = "[PseudoInstance] Locked metatable"
	Mt.__type = ClassName -- Calling `typeof` will error without having this value :/

	-- Internally accessible methods
	Mt.super = Metatable__super

	-- These two are only around for instantiation and are cleared after a successful and full instantiation
	Mt.superinit = superinit
	Mt.currentclass = Class

	-- Internally accessible cleaner
	Mt.Janitor = Janitor.new()

	Metatables[self] = setmetatable(Mt, Mt)

	Mt.Janitor:Add(self, "Destroy")
	Mt:superinit(...)

	if rawget(Mt, "currentclass") then
		local StoppedOnClass = Class

		while StoppedOnClass.HasSuperclass and StoppedOnClass.Superclass ~= Mt.currentclass do
			StoppedOnClass = StoppedOnClass.Superclass
		end

		Debug.Error("Must call self:superinit(...) from " .. StoppedOnClass.ClassName .. ".Init")
	end

	return self
end

function PseudoInstance.Make(ClassName, Properties, ...)
	local Object = PseudoInstance.new(ClassName)
	local Parent = Properties.Parent

	if Parent then
		Properties.Parent = nil
	end

	for Property, Value in next, Properties do
		if type(Property) == "number" then
			Value.Parent = Object
		elseif Object[Property] ~= Value then
			Object[Property] = Value
		end
	end

	if Parent then
		Object.Parent = Parent
	end

	if ... then
		local Objects = {...}
		for a = 1, #Objects do
			local Object = Object:Clone()
			for Property, Value in next, Objects[a] do
				if type(Property) == "number" then
					Value.Parent = Object
				else
					Object[Property] = Value
				end
			end
			Object.Parent = not Object.Parent and Parent
			Objects[a] = Object
		end
		return Object, unpack(Objects)
	else
		return Object
	end
end

return Table.Lock(PseudoInstance)
