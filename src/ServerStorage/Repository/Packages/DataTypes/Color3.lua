local Color3 = setmetatable({
	fromInt = function(i)
		return Color3.fromRGB(math.floor(i / 65536) % 256, math.floor(i / 256) % 256, i % 256)
	end;
	toInt = function(col)
		return math.floor(col.r*255)*256^2+math.floor(col.g*255)*256+math.floor(col.b*255)
	end;
}, {__index = Color3})

return Color3