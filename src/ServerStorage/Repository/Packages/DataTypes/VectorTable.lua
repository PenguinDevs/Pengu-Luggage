local module = {}

function convert(vector)
	local x = tostring(vector.X)
	local y = tostring(vector.Y)
	if x == "-0" then x = "0" end
	if y == "-0" then y = "0" end
	return x .. ":" .. y
end
module.convert = convert

function rconvert(i)
	return Vector2.new(
		tonumber(string.sub(i, 0, string.find(i, ":") - 1)),
		tonumber(string.sub(i, string.find(i, ":") + 1))
	)
end
module.rconvert = rconvert

function module.read(t, vector)
	local v = t[convert(vector)]
	return v
end

function module.write(t, vector, v)
	t[convert(vector)] = v
end

return module
