-- HTML Parsing Object
-- @author Validark

local Resources = require(game:GetService("ReplicatedStorage"):WaitForChild("Resources"))
local Table = Resources:LoadLibrary("Table")

local HTMLParser = {}
HTMLParser.__index = {Position = 0}

function HTMLParser.new(HTML)
	return setmetatable({
		HTML = HTML:gsub("%s+", " "):gsub("> <", "><"):gsub(" >", ">"):gsub("< ", "<");
	}, HTMLParser)
end

function HTMLParser.__index:Next()
	local StartPosition
	StartPosition, self.Position = self.HTML:find("<([^>]+)>([^<]*)", self.Position + 1)

	if StartPosition then
		self.Tag, self.Data = self.HTML:sub(StartPosition, self.Position):match("<([^>]+)>([^<]*)")
	else
		self.Tag, self.Data = nil, nil
	end

	return self
end

return Table.Lock(HTMLParser)
