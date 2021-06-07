-- Copies a table by looping through i and v depending on copy level
-- @author PenguinDevs

local module = {}

function module:ShallowCopy(original)
	local copy = {}
	for key, value in pairs(original) do
		copy[key] = value
	end
	return copy
end

function module:DeepCopy(original)
	local copy = {}
	for k, v in pairs(original) do
		if type(v) == "table" then
			v = module:DeepCopy(v)
		end
		copy[k] = v
	end
	return copy
end

return module
