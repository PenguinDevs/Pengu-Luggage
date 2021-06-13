local list = {
    {
        name = "BoostedArrows";
        price = 399;
        icon = "rbxassetid://6649647952";
        id = 18761773;
        desc = "Earn 2x the money you earn! (Multipliers stacks with other multiplier game passes and features)";
    };
}

local module = {}
local indexedByName = {}

for _, productDet in pairs(list) do
    module[tostring(productDet.id)] = productDet
    indexedByName[productDet.name] = productDet
end

return setmetatable(module, {
    __index = function(_, i)
        if type(i) == "number" then
            error(string.format("You sure you shouldn't be indexing via string? %s %s", i, type(i)))
        else
            if indexedByName[i] then
                return indexedByName[i]
            end
            error(string.format("%s isn't even a thing bud"), i)
        end
    end
})