-- Pure-lua implementation of Roblox-style Enums
-- @author Validark

local Resources = require(game:GetService("ReplicatedStorage"):WaitForChild("Resources"))
local Debug = Resources:LoadLibrary("Debug")
local Typer = Resources:LoadLibrary("Typer")
local SortedArray = Resources:LoadLibrary("SortedArray")

local Error__index = {
	__index = function(_, i)
		Debug.Error(tostring(i) .. " is not a valid EnumerationItem")
	end;
}

local Error__index2 = {
	__index = function(_, i)
		Debug.Error(tostring(i) .. " is not a valid member")
	end;
}

local EnumerationsArray = SortedArray.new(nil, function(Left, Right)
	return tostring(Left) < tostring(Right)
end)

local Enumerations = setmetatable({}, Error__index)

function Enumerations:GetEnumerations()
	return EnumerationsArray:Copy()
end

local function ReadOnlyNewIndex(_, Index, _)
	Debug.Error("Cannot write to index [%q]", Index)
end

local function CompareEnumTypes(EnumItem1, EnumItem2)
	return EnumItem1.Value < EnumItem2.Value
end

local Casts = {}
local EnumContainerTemplate = {}
EnumContainerTemplate.__index = setmetatable({}, Error__index)

function EnumContainerTemplate.__index:GetEnumerationItems()
	local Array = {}
	local Count = 0

	for _, Item in next, EnumContainerTemplate[self] do
		Count = Count + 1
		Array[Count] = Item
	end

	table.sort(Array, CompareEnumTypes)
	return Array
end

function EnumContainerTemplate.__index:Cast(Value)
	local Castables = Casts[self]
	local Cast = Castables[Value]

	if Cast then
		return Cast
	else
		return false, "[" .. Debug.Inspect(Value) .. "] is not a valid " .. tostring(self)
	end
end

local function ConstructUserdata(__index, __newindex, __tostring)
	local Enumeration = newproxy(true)

	local EnumerationMetatable = getmetatable(Enumeration)
	EnumerationMetatable.__index = __index
	EnumerationMetatable.__newindex = __newindex
	EnumerationMetatable.__tostring = function() return __tostring end
	EnumerationMetatable.__metatable = "[Enumeration] Requested metatable is locked"

	return Enumeration
end

local function ConstructEnumerationItem(Name, Value, EnumContainer, LockedEnumContainer, EnumerationStringStub, Castables)
	local Item = ConstructUserdata(setmetatable({
		Name = Name;
		Value = Value;
		EnumerationType = LockedEnumContainer
	}, Error__index2), ReadOnlyNewIndex, EnumerationStringStub .. Name, Castables)

	Castables[Name] = Item
	Castables[Value] = Item
	Castables[Item] = Item

	EnumContainer[Name] = Item
end

local MakeEnumeration = Typer.AssignSignature(2, Typer.String, Typer.ArrayOfStringsOrDictionaryOfNumbers, function(_, EnumType, EnumTypes)
	if rawget(Enumerations, EnumType) then Debug.Error("Enumeration of EnumType " .. EnumType .. " already exists") end

	local Castables = {}
	local EnumContainer = setmetatable({}, EnumContainerTemplate)
	local LockedEnumContainer = ConstructUserdata(EnumContainer, ReadOnlyNewIndex, EnumType)
	local EnumerationStringStub = "Enumeration." .. EnumType .. "."
	local NumEnumTypes = #EnumTypes

	if NumEnumTypes > 0 then
		for i = 1, NumEnumTypes do
			ConstructEnumerationItem(EnumTypes[i], i - 1, EnumContainer, LockedEnumContainer, EnumerationStringStub, Castables)
		end
	else
		for Name, Value in next, EnumTypes do
			ConstructEnumerationItem(Name, Value, EnumContainer, LockedEnumContainer, EnumerationStringStub, Castables)
		end
	end

	Casts[LockedEnumContainer] = Castables
	EnumContainerTemplate[LockedEnumContainer] = EnumContainer
	EnumerationsArray:Insert(LockedEnumContainer)
	Enumerations[EnumType] = LockedEnumContainer
end)

return ConstructUserdata(Enumerations, MakeEnumeration, "Enumerations")
