-- Debugging Utilities
-- @documentation https://rostrap.github.io/Libraries/Debugging/Debug/
-- @author Validark

local Resources = require(game:GetService("ReplicatedStorage"):WaitForChild("Resources"))
local Table = Resources:LoadLibrary("Table")
local Typer = Resources:LoadLibrary("Typer")

local Debug = {}
local TAB = (" "):rep(4)

local Services = setmetatable({}, { -- Memoize GetService calls
	__index = function(self, i)
		local Success, Object = pcall(game.GetService, game, i)
		local Service = Success and Object
		self[i] = Service
		return Service
	end;
})

Debug.DirectoryToString = Typer.AssignSignature(Typer.Instance, function(Object)
	--- Gets the string of the directory of an object, properly formatted
	-- string DirectoryToString(Object)
	-- @returns Objects location in proper Lua format
	-- @author Validark
	-- My implementation of the built-in GetFullName function which returns properly formatted text.

	local FullName = {}
	local Count = 0

	while Object.Parent ~= game and Object.Parent ~= nil do
		local ObjectName = Object.Name:gsub("([\\\"])", "\\%1")

		if ObjectName:find("^[_%a][_%w]*$") then
			FullName[Count] = "." .. ObjectName
		else
			FullName[Count] = "[\"" .. ObjectName .. "\"]"
		end
		Count = Count - 1
		Object = Object.Parent
	end

	if Services[Object.ClassName] == Object then
		FullName[Count] = "game:GetService(\"" .. Object.ClassName .. "\")"
	else
		FullName[Count] = "." .. "[\"" .. Object.Name .. "\"]" -- A dot at the beginning indicates a rootless Object
	end

	return table.concat(FullName, "", Count, 0)
end)

local GetErrorData do
	-- Standard RoStrap Erroring system
	-- Prefixing errors with '!' makes Error expect the [error origin].Name as first parameter after Error string
	-- Past the initial Error string, subsequent arguments get unpacked in a string.format of the error string
	-- Arguments formmatted into the string get stringified (see above function)
	-- Assert falls back on Error
	-- Error blames the latest item on the traceback as the cause of the error
	-- Error makes it clear which Library and function are being misused
	-- @author Validark

	local Replacers = {
		["Index ?"] = "__index";
		["Newindex ?"] = "__newindex";
	}

	local function Format(String, ...)
		return String:format(...)
	end

	local CommandBar = {Name = "Command bar"}

	function GetErrorData(Err, ...) -- Make sure if you don't intend to format arguments in, you do %%f instead of %f
		if type(Err) ~= "string" then
			error(GetErrorData("!The first parameter of error formatting must be a string", "Debug"))
		end

		local t = {...}

		local Traceback = debug.traceback()
		local ErrorDepth = select(2, Traceback:gsub("\n", "")) - 2

		local Prefix
		Err, Prefix = Err:gsub("^!", "", 1)
		local ModuleName = Prefix == 1 and table.remove(t, 1) or (getfenv(ErrorDepth).script or CommandBar).Name
		local FunctionName = ""

		for i = 1, select("#", ...) do
			t[i] = Debug.Inspect(t[i])
		end

		for x in Traceback:sub(1, -11):gmatch("%- [^\r\n]+[\r\n]") do
			FunctionName = x
		end

		FunctionName = FunctionName:sub(3, -2):gsub("%l+ (%S+)$", "%1"):gsub(" ([^\n\r]+)", " %1", 1)

		local i = 0
		for x in Err:gmatch("%%%l") do
			i = i + 1
			if x == "%q" then
				t[i] = t[i]:gsub(" (%S+)$", " \"%1\"", 1)
			end
		end

		local Success, ErrorString = pcall(Format, "[%s] {%s} " .. Err:gsub("%%q", "%%s"), ModuleName, Replacers[FunctionName] or FunctionName, unpack(t))

		if Success then
			return ErrorString, ErrorDepth
		else
			error(GetErrorData("!Error formatting failed, perhaps try escaping non-formattable tags like so: %%%%f\n(Error Message): " .. ErrorString, "Debug"))
		end
	end

	function Debug.Warn(...)
		warn((GetErrorData(...)))
	end

	function Debug.Error(...)
		error(GetErrorData(...))
	end

	function Debug.Assert(Condition, ...)
		return Condition or error(GetErrorData(...))
	end
end

do
	local function Alphabetically(a, b)
		local typeA = type(a)
		local typeB = type(b)

		if typeA == typeB then
			if typeA == "number" then
				return a < b
			else
				return tostring(a):lower() < tostring(b):lower()
			end
		else
			return typeA < typeB
		end
	end

	Debug.AlphabeticalOrder = Typer.AssignSignature(Typer.Table, function(Dictionary)
		--- Iteration function that iterates over a dictionary in alphabetical order
		-- function AlphabeticalOrder(Dictionary)
		-- @param table Dictionary That which will be iterated over in alphabetical order
		-- A dictionary looks like this: {Apple = true, Noodles = 5, Soup = false}
		-- Not case-sensitive
		-- @author Validark

		local Count = 0
		local Order = {}

		for Key in next, Dictionary do
			Count = Count + 1
			Order[Count] = Key
		end

		table.sort(Order, Alphabetically)

		local i = 0

		return function(Table)
			i = i + 1
			local Key = Order[i]
			return Key, Table[Key], i
		end, Dictionary, nil
	end)
end

function Debug.UnionIteratorFunctions(...)
	-- Takes in functions ..., and returns a function which unions them, which can be called on a table
	-- Will iterate through a table, using the iterator functions passed in from left to right
	-- Will pass the CurrentIteratorFunction index in the stack as the last variable
	-- UnionIteratorFunctions(Get0, ipairs, Debug.AlphabeticalOrder)(Table)

	local IteratorFunctions = {...}

	for i = 1, #IteratorFunctions do
		if type(IteratorFunctions[i]) ~= "function" then
			error(GetErrorData("Cannot union Iterator functions which aren't functions"))
		end
	end

	return function(Table)
		local Count = 0
		local Order = {[0] = {}}
		local KeysSeen = {}

		for i = 1, #IteratorFunctions do
			local Function, TableToIterateThrough, Next = IteratorFunctions[i](Table)

			if type(Function) ~= "function" or type(TableToIterateThrough) ~= "table" then
				error(GetErrorData("Iterator function " .. i .. " must return a stack of types as follows: Function, Table, Variant"))
			end

			while true do
				local Data = {Function(TableToIterateThrough, Next)}
				Next = Data[1]
				if Next == nil then break end
				if not KeysSeen[Next] then
					KeysSeen[Next] = true
					Count = Count + 1
					Data[#Data + 1] = i
					Order[Count] = Data
				end
			end
		end

		return function(_, Previous)
			for i = 0, Count do
				if Order[i][1] == Previous then
					local Data = Order[i + 1]
					if Data then
						return unpack(Data)
					else
						return nil
					end
				end
			end

			error(GetErrorData("invalid key to unioned iterator function: " .. Previous))
		end, Table, nil
	end
end

local EachOrder do
	-- TODO: Write a function that takes multiple iterator functions and iterates through each passed in function
	-- EachOrder(Get0(Table), ipairs(Table), AlphabeticalOrder(Table))
end

do
	local typeof = typeof or type
	local ConvertTableIntoString

	local function Parse(Object, Multiline, Depth, EncounteredTables)
		local Type = typeof(Object)

		return
			Type == "table" and (EncounteredTables[Object] and "[table " .. EncounteredTables[Object] .. "]" or ConvertTableIntoString(Object, nil, Multiline, Depth + 1, EncounteredTables))
			or Type == "string" and "\"" .. Object .. "\""
			or Type == "Instance" and "<" .. Debug.DirectoryToString(Object) .. ">"
			or (Type == "function" or Type == "userdata") and Type
			or tostring(Object)
	end

	function ConvertTableIntoString(Table, TableName, Multiline, Depth, EncounteredTables)
		local n = EncounteredTables.n + 1
		EncounteredTables[Table] = n
		EncounteredTables.n = n

		local t = {}
		local CurrentArrayIndex = 1

		if TableName then
			t[1] = TableName
			t[2] = " = {"
		else
			t[1] = "{"
		end

		if not next(Table) then
			t[#t + 1] = "}"
			return table.concat(t)
		end

		for Key, Value in Debug.AlphabeticalOrder(Table) do
			if not Multiline and type(Key) == "number" then
				if Key == CurrentArrayIndex then
					CurrentArrayIndex = CurrentArrayIndex + 1
				else
					t[#t + 1] = "[" .. Key .. "] = "
				end
				t[#t + 1] = Parse(Value, Multiline, Depth, EncounteredTables)
				t[#t + 1] = ", "
			else
				if Multiline then
					t[#t + 1] = "\n"
					t[#t + 1] = (TAB):rep(Depth)
				end

				if type(Key) == "string" and Key:find("^[%a_][%w_]*$") then
					t[#t + 1] = Key
				else
					t[#t + 1] = "["
					t[#t + 1] = Parse(Key, Multiline, Depth, EncounteredTables)
					t[#t + 1] = "]"
				end

				t[#t + 1] = " = "
				t[#t + 1] = Parse(Value, Multiline, Depth, EncounteredTables)
				t[#t + 1] = Multiline and ";" or ", "
			end
		end

		if Multiline then
			t[#t + 1] = "\n"
			t[#t + 1] = (TAB):rep(Depth - 1)
		else
			t[#t] = nil
		end

		t[#t + 1] = "}"

		local Metatable = getmetatable(Table)

		if Metatable then
			t[#t + 1] = " <- "
			t[#t + 1] = type(Metatable) == "table" and ConvertTableIntoString(Metatable, nil, Multiline, Depth, EncounteredTables) or Debug.Inspect(Metatable)
		end

		return table.concat(t)
	end

	Debug.TableToString = Typer.AssignSignature(Typer.Table, Typer.OptionalBoolean, Typer.OptionalString, function(Table, Multiline, TableName)
		--- Converts a table into a readable string
		-- string TableToString(Table, TableName, Multiline)
		-- @param table Table The Table to convert into a readable string
		-- @param string TableName Optional Name parameter that puts a "[TableName] = " at the beginning
		-- @returns a readable string version of the table

		return ConvertTableIntoString(Table, TableName, Multiline, 1, {n = 0})
	end)
end

do
	local EscapedCharacters = {"%", "^", "$", "(", ")", ".", "[", "]", "*", "+", "-", "?"}
	local Escapable = "([%" .. table.concat(EscapedCharacters, "%") .. "])"

	Debug.EscapeString = Typer.AssignSignature(Typer.String, function(String)
		--- Turns strings into Lua-readble format
		-- string Debug.EscapeString(String)
		-- @returns Objects location in proper Lua format
		-- @author Validark
		-- Useful for when you are doing string-intensive coding
		-- Those minus signs always get me when I'm not using this function!

		return (
			String
				:gsub(Escapable, "%%%1")
				:gsub("([\"\'\\])", "\\%1")
		)
	end)
end

function Debug.Inspect(...)
	--- Returns a string representation of anything
	-- @param any Object The object you wish to represent as a string
	-- @returns a readable string representation of the object
	
	local List = ""
	
	for i = 1, select("#", ...) do
		local Data = select(i, ...)
		local DataType = typeof(Data)
		local DataString
	
		if DataType == "Instance" then
			DataType = Data.ClassName
			DataString = Debug.DirectoryToString(Data)
		else
			DataString = DataType == "table" and Debug.TableToString(Data)
				or DataType == "string" and "\"" .. Data .. "\""
				or tostring(Data)
		end
	
		List = List .. ", " .. ((DataType .. " " .. DataString):gsub("^" .. DataType .. " " .. DataType, DataType, 1))
	end
	
	if List == "" then
		return "NONE"
	else
		return List:sub(3)
	end
end

return Table.Lock(Debug)
