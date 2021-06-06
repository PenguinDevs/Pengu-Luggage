local incr = 8

local list = {
    {
        name = "$40,000";
        price = 49;
        type = "money";
        reward = 50/50 * 5000 * incr;
        icon = "rbxassetid://6721717059";
        id = 1162563961;
        desc = "";
    };
    {
        name = "$120,000";
        price = 149;
        type = "money";
        reward = (150/50 + 1) * 5000 * incr;
        icon = "rbxassetid://6721716397";
        id = 1162563988;
        desc = "";
    };
    {
        name = "$240,000";
        price = 299;
        type = "money";
        reward = (300/50 + 2) * 5000 * incr;
        icon = "rbxassetid://6721715952";
        id = 1162564019;
        desc = "";
    };
    {
        name = "$520,000";
        price = 649;
        type = "money";
        reward = (750/50 + 3) * 5000 * incr;
        icon = "rbxassetid://6721715746";
        id = 1162564042;
        desc = "";
    };
    {
        name = "$1,040,000";
        price = 1299;
        type = "money";
        reward = (1300/50 + 4) * 5000 * incr;
        icon = "rbxassetid://6721715464";
        id = 1162564065;
        desc = "";
    };
    {
        name = "$2,800,000";
        price = 3499;
        type = "money";
        reward = (3500/50 + 5) * 5000 * incr;
        icon = "rbxassetid://6721714955";
        id = 1162564091;
        desc = "";
        message = "BEST VALUE"
    };
    {
        name = "Expansion";
        price = 49;
        icon = "";
        id = 1174173767;
        desc = "";
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