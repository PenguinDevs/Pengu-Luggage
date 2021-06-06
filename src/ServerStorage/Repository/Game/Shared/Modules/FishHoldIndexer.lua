local module = {}

local Resources = require(game.ReplicatedStorage.Resources)
local VecotorTable = Resources:LoadLibrary("VectorTable")

function convert(item, iPos)
    if typeof(iPos) == "Vector2" then iPos = VecotorTable.convert(iPos) end
	return item .. ":" .. iPos
end
module.convert = convert

function rconvert(i)
	return string.sub(i, 0, string.find(i, ":") - 1), string.sub(i, string.find(i, ":") + 1)
end
module.rconvert = rconvert

return module