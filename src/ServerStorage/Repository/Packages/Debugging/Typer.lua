-- Powerful, light-weight type checker
-- @documentation https://rostrap.github.io/Libraries/Debugging/Typer/
-- @author Validark

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Resources = require(ReplicatedStorage:WaitForChild("Resources"))

local Table = Resources:LoadLibrary("Table")

local BuiltInTypes = {
	Nil = "nil";
	Bool = "boolean";
	Boolean = "boolean";
	Number = "number";
	String = "string";
	Userdata = "userdata";
	Function = "function";
	Thread = "thread";
	Table = "table";
}

local CustomTypes = {
	Any = function()
		return true
	end;

	Array = function(Array, Type, Callback, Castable)
		if Type ~= "table" then
			return false
		end

		local Size = #Array
		local Bool = false

		for Key, Value in next, Array do
			Bool = true
			if type(Key) ~= "number" or Key % 1 ~= 0 or Key < 1 or Key > Size then
				return false
			elseif Callback then
				local Success = Callback(Value)

				if Success then
					if Castable then
						Array[Key] = Success
					end
				else
					return false
				end
			end
		end

		return Bool
	end;

	Dictionary = function(Dictionary, Type, Callback, Castable)
		if Type ~= "table" then
			return false
		end

		local Bool = false

		for Key, Value in next, Dictionary do
			Bool = true
			if type(Key) == "number" then
				return false
			elseif Callback then
				local Success = Callback(Value)

				if Success then
					if Castable then
						Dictionary[Key] = Success
					end
				else
					return false
				end
			end
		end

		return Bool
	end;

	Table = function(Table, Type, Callback, Castable)
		if Type ~= "table" then
			return false
		end

		if Callback then
			local Bool = false

			for Key, Value in next, Table do
				Bool = true
				local Success = Callback(Value)

				if Success then
					if Castable then
						Table[Key] = Success
					end
				else
					return false
				end
			end

			return Bool
		else
			return true
		end
	end;

	EmptyTable = function(Value, Type)
		return Type ~= "table" or next(Value) == nil
	end;

	NonNil = function(Value)
		return Value ~= nil
	end;

	Integer = function(Value, Type)
		return Type == "number" and Value % 1 == 0
	end;

	PositiveInteger = function(Value, Type)
		return Type == "number" and Value > 0 and Value % 1 == 0
	end;

	NegativeInteger = function(Value, Type)
		return Type == "number" and Value < 0 and Value % 1 == 0
	end;

	NonPositiveInteger = function(Value, Type)
		return Type == "number" and Value <= 0 and Value % 1 == 0
	end;

	NonNegativeInteger = function(Value, Type)
		return Type == "number" and Value >= 0 and Value % 1 == 0
	end;

	PositiveNumber = function(Value, Type)
		return Type == "number" and Value > 0
	end;

	NegativeNumber = function(Value, Type)
		return Type == "number" and Value < 0
	end;

	NonPositiveNumber = function(Value, Type)
		return Type == "number" and Value <= 0
	end;

	NonNegativeNumber = function(Value, Type)
		return Type == "number" and Value >= 0
	end;

	Truthy = function(Value)
		return Value and true or false
	end;

	Falsy = function(Value)
		return not Value
	end;

	Enum = function(_, Type)
		return Type == "Enum" or Type == "EnumItem"
	end;

	EnumType = function(_, Type) -- For whatever reason, typeof() returns "Enum" for EnumItems
		return Type == "Enum"
	end;

	True = function(Value)
		return Value == true
	end;

	False = function(Value)
		return Value == false
	end;
}

local function TransformTableCheckerData(PotentialTypes)
	-- [0] is the Expectation string
	-- Array in the form {"number", "string", "nil"} where each value is a string matchable by typeof()
	-- Key-Value pairs in the form {[string Name] = function}

	if not PotentialTypes[0] then -- It was already transformed if written to 0, no haxing pls
		local Expectation = ": expected "
		PotentialTypes[0] = Expectation

		for Name in next, PotentialTypes do
			local NameType = type(Name)

			if NameType == "string" then
				Expectation = Expectation .. Name .. " or "
			elseif NameType ~= "number" then
				Resources:LoadLibrary("Debug").Error("Key-Value pairs should be in the form [string Name] = function, got %s", Name)
			end
		end

		local i = 0
		local AmountPotentialTypes = #PotentialTypes

		while i < AmountPotentialTypes do
			i = i + 1
			local PotentialType = PotentialTypes[i]

			if type(PotentialType) ~= "string" then
				Resources:LoadLibrary("Debug").Error("PotentialTypes in the array section must be strings in the form {\"number\", \"string\", \"nil\"}")
			end

			Expectation = Expectation .. PotentialType .. " or "
			local TypeCheck = CustomTypes[PotentialType]

			if TypeCheck then
				table.remove(PotentialTypes, i)
				i = i - 1
				AmountPotentialTypes = AmountPotentialTypes - 1
				PotentialTypes[PotentialType] = TypeCheck
			end
		end

		PotentialTypes[0] = Expectation:sub(1, -5)
	end

	return PotentialTypes
end

local function Check(PotentialTypes, Parameter, ArgumentNumOrName)
	local TypeOf = typeof(Parameter)

	for i = 1, #PotentialTypes do
		if PotentialTypes[i] == TypeOf then
			return Parameter or true
		end
	end

	for Key, CheckFunction in next, PotentialTypes do
		if type(Key) == "string" then
			local Success = CheckFunction(Parameter, TypeOf)

			if Success then
				return Key:find("^Enum") and Success or Parameter or true
			end
		end
	end

	local ArgumentNumberType = type(ArgumentNumOrName)

	return false, "bad argument"
		.. (ArgumentNumOrName and (ArgumentNumberType == "number" and " #" .. ArgumentNumOrName or ArgumentNumberType == "string" and " to " .. ArgumentNumOrName) or "")
		.. PotentialTypes[0] .. ", got " .. Resources:LoadLibrary("Debug").Inspect(Parameter)
end

local Typer = {}

local CallToCheck = {__call = Check}

setmetatable(Typer, {
	__index = function(self, index)
		local t = {}
		self[index] = t

		for i in (index .. "Or"):gmatch("(%w-)Or") do -- Not the prettiest, but hey, we got parsing baby!
			if i:find("^Optional") then
				i = i:sub(9)
				t[1] = "nil"
			end

			if i:find("^InstanceOfClass") then
				local ClassName = i:sub(16)

				t["Instance of class " .. ClassName] = function(Value, Type)
					return Type == "Instance" and Value.ClassName == ClassName
				end
			elseif i:find("^InstanceWhichIsA") then
				local ClassName = i:sub(17)

				t["Instance which is a " .. ClassName] = function(Value, Type)
					return Type == "Instance" and Value:IsA(ClassName)
				end
			elseif i:find("^EnumOfType") then
				i = i:sub(11)
				local Castables = {}
				local Enumerators = Enum[i]:GetEnumItems()

				for a = 1, #Enumerators do
					local Enumerator = Enumerators[a]
					Castables[Enumerator] = Enumerator
					Castables[Enumerator.Name] = Enumerator
					Castables[Enumerator.Value] = Enumerator
				end

				t["Enum of type " .. i] = function(Value)
					return Castables[Value] or false
				end
			elseif i:find("^EnumerationOfType") then
				i = i:sub(18)
				local EnumerationType = Resources:LoadLibrary("Enumeration")[i]

				t["Enumeration of type " .. i] = function(Value)
					return EnumerationType:Cast(Value)
				end
			elseif i:find("^ArrayOf%a+s$") then
				i = i:match("^ArrayOf(%a+)s$")
				local ArrayType = Typer[i]
				local Function = CustomTypes.Array
				local Castable = i:find("^Enum") and true or false

				t["Array of " .. ArrayType[0]:sub(12):gsub("%S+", "%1s", 1)] = function(Value, Type)
					return Function(Value, Type, ArrayType, Castable)
				end
			elseif i:find("^DictionaryOf%a+s$") then
				i = i:match("^DictionaryOf(%a+)s$")
				local DictionaryType = Typer[i]
				local Function = CustomTypes.Dictionary
				local Castable = i:find("^Enum") and true or false

				t["Dictionary of " .. DictionaryType[0]:sub(12):gsub("%S+", "%1s", 1)] = function(Value, Type)
					return Function(Value, Type, DictionaryType, Castable)
				end
			elseif i:find("^TableOf%a+s$") then
				i = i:match("^TableOf(%a+)s$")
				local TableType = Typer[i]
				local Function = CustomTypes.Table
				local Castable = i:find("^Enum") and true or false

				t["Table of " .. TableType[0]:sub(12):gsub("%S+", "%1s", 1)] = function(Value, Type)
					return Function(Value, Type, TableType, Castable)
				end
			else
				t[#t + 1] = BuiltInTypes[i] or i
			end
		end

		return setmetatable(TransformTableCheckerData(t), CallToCheck)
	end;
})

function Typer.AssignSignature(...)
	local FirstValueToCheckOffset = 0
	local StackSignature

	if CustomTypes.PositiveInteger(..., type((...))) then
		FirstValueToCheckOffset = ... - 1
		StackSignature = {select(2, ...)}
	else
		StackSignature = {...}
	end

	local Function = table.remove(StackSignature)

	local NumTypes = #StackSignature
	local Castable

	for a = 1, NumTypes do
		local ParameterSignature = StackSignature[a]

		if type(ParameterSignature) == "table" then
			for i in next, TransformTableCheckerData(ParameterSignature) do
				if type(i) == "string" and i:find("^Enum") then
					if not Castable then
						Castable = {}

						for b = 1, a - 1 do
							Castable[b] = false
						end
					end

					Castable[a] = true
				end
			end

			if Castable and not Castable[a] then
				Castable[a] = false
			end
		else
			Resources:LoadLibrary("Debug").Error("Definition for parameter #" .. a .. " must be a table")
		end
	end

	if Castable then
		return function(...)
			local NumParameters = select("#", ...) -- This preserves nil's on the stack
			local Stack = {...}

			for a = 1, NumParameters < NumTypes and NumTypes or NumParameters do
				local Success, Error = Check(StackSignature[a] or Typer.Nil, Stack[a + FirstValueToCheckOffset], a + FirstValueToCheckOffset)

				if Success then
					if Castable[a] and Success ~= true then
						Stack[a + FirstValueToCheckOffset] = Success
					end
				elseif not Success then
					return Resources:LoadLibrary("Debug").Error(Error)
				end
			end

			return Function(unpack(Stack, 1, NumParameters))
		end
	else -- Don't penalize cases which don't need to cast an Enum
		return function(...)
			local NumParameters = select("#", ...)

			for a = 1, NumParameters < NumTypes and NumTypes or NumParameters do
				local Success, Error = Check(StackSignature[a] or Typer.Nil, select(a + FirstValueToCheckOffset, ...), a + FirstValueToCheckOffset)

				if not Success then
					return Resources:LoadLibrary("Debug").Error(Error)
				end
			end

			return Function(...)
		end
	end
end

local ExternalTransformTable = Typer.AssignSignature(Typer.Table, TransformTableCheckerData)

Typer.Check = function(PotentialTypes, Parameter, ArgumentNumOrName)
	return Check(ExternalTransformTable(PotentialTypes), Parameter, ArgumentNumOrName)
end

Typer.MapDefinition = Typer.AssignSignature(Typer.Table, function(self)
	for _, Type in next, self do
		ExternalTransformTable(Type)
	end

	return function(Tab)
		if type(Tab) ~= "table" then
			return false, "|Map.__call| Must be called with a Table"
		end

		for Index in next, Tab do
			if not self[Index] then
				return false, "|Map.__call| " .. Resources:LoadLibrary("Debug").Inspect(Index) .. " is not a valid Key"
			end
		end

		for Index, Type in next, self do
			local Success, Error = Typer.Check(Type, Tab[Index], Index)

			if not Success then
				return false, "|Map.__call| " .. Error
			end
		end

		return Tab
	end;
end)

return Table.Lock(Typer)
