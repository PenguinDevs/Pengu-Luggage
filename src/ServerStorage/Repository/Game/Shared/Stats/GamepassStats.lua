local list = {
    {
        name = "2x Money";
        price = 399;
        icon = "rbxassetid://6649647952";
        id = 15022772;
        desc = "Earn 2x the money you earn! (Multipliers stacks with other multiplier game passes and features)";
    };
    {
        name = "Extra Tips";
        price = 259;
        icon = "rbxassetid://6649647666";
        id = 16580381;
        desc = "Get extra money everytime you earn tips! (Multipliers stacks with other multiplier game passes and features)";
    };
    {
        name = "Radio";
        price = 179;
        icon = "rbxassetid://6649647231";
        id = 16580399;
        desc = "Play music in your plot!";
    };
    {
        name = "2x Speed";
        price = 129;
        icon = "rbxassetid://6675139254";
        id = 16641061;
        desc = "Run twice the speed anywhere!";
    };
    {
        name = "VIP";
        price = 449;
        icon = "rbxassetid://6709100387";
        id = 17044167;
        desc = "Exclusive VIP items, VIP tag, 30% off on fishes and 2x tips! (Multipliers stacks with other multiplier game passes and features)";
        colour = Color3.fromRGB(249, 253, 0);
    };
    {
        name = "Legendary Fish";
        price = 299;
        icon = "rbxassetid://6716200683";
        id = 17044344;
        desc = "Be able to purchase as much ghost fish, neon carp and spiked sharks! As well as receive 3 of each on purchase! (These fish earn you 2x the profit they normally would)";
    };
    {
        name = "Starter Pack";
        price = 249;
        icon = "rbxassetid://6709101280";
        id = 17044445;
        desc = "Receive $50,000 money, three catfish, two sharks and one turtle!";
    };
    {
        name = "All Expansions";
        price = 859;
        icon = "rbxassetid://6769560681";
        id = 17540778;
        desc = "Unlock every land on your plot FOR FREE!";
    };
    {
        name = "Rich Guests (2x Income)";
        price = 199;
        icon = "rbxassetid://6769559997";
        id = 17540887;
        desc = "Get rich guests to come visit your plot! Increases income and tips by 2x! (Multipliers stacks with other multiplier game passes and features)";
    };
    {
        name = "OP Money Fountain";
        price = 229;
        icon = "rbxassetid://6769560426";
        id = 17541027;
        desc = "Get a cool looking fountain that creates money... somehow?";
        colour = Color3.fromRGB(255, 170, 0);
    };
}

local module = {}

for _, productDet in pairs(list) do
    module[tostring(productDet.name)] = productDet
end

return setmetatable(module, {
    __index = function(_, i)
        if type(i) == "number" then
            error(string.format("You sure you shouldn't be indexing via string? %s %s", i, type(i)))
        else
            error(string.format("%s isn't even a thing bud"), i)
        end
    end
})