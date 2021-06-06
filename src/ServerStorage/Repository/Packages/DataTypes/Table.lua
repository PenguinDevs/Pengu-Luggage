-- Utility Table functions
-- This Library is not for a bunch of for-loop wrapper functions.
-- Either write your own for-loops or learn python instead
-- @author Validark

local Resources = require(game:GetService("ReplicatedStorage"):WaitForChild("Resources"))

local Table = {}

function Table.QuickRemove(Tab, Index)
	local Size = #Tab
	Tab[Index] = Tab[Size]
	Tab[Size] = nil
end

function Table.Move(a1, f, e, t, a2)
	-- Moves elements [f, e] from array a1 into a2 starting at index t
	-- Equivalent to Lua 5.3's table.move
	-- @param table a1 from which to draw elements from range
	-- @param number f starting index for range
	-- @param number e ending index for range
	-- @param number t starting index to move elements from a1 within [f, e]
	-- @param table a2 the second table to move these elements to
	--	@default a2 = a1
	-- @returns a2

	a2 = a2 or a1
	t = t + e

	for i = e, f, -1 do
		t = t - 1
		a2[t] = a1[i]
	end

	return a2
end

function Table.Shuffle(tbl)
	for i = #tbl, 2, -1 do
		local j = math.random(i)
		tbl[i], tbl[j] = tbl[j], tbl[i]
	end
	return tbl
end

function Table.Lock(Tab, __call)
	-- Returns interface proxy which can read from table Tab but cannot modify it

	local ModuleName = getfenv(2).script.Name

	local Userdata = newproxy(true)
	local Metatable = getmetatable(Userdata)

	function Metatable:__index(Index)
		local Value = Tab[Index]
		return Value == nil and Resources:LoadLibrary("Debug").Error("!%q does not exist in read-only table", ModuleName, Index) or Value
	end

	function Metatable:__newindex(Index, Value)
		Resources:LoadLibrary("Debug").Error("!Cannot write %s to index [%q] of read-only table", ModuleName, Value, Index)
	end

	function Metatable:__tostring()
		return ModuleName
	end

	Metatable.__call = __call
	Metatable.__metatable = "[" .. ModuleName .. "] Requested metatable of read-only table is locked"

	return Userdata
end

return Table.Lock(Table)
