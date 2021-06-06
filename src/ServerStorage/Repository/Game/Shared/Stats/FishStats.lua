local Resources = require(game.ReplicatedStorage.Resources)
local Round = Resources:LoadLibrary("Round")
local GameSettings = Resources:LoadLibrary("GameSettings")

local module = {
    ["Carp"] = {
        price = 15;
        primaryAnim = "http://www.roblox.com/asset/?id=6517535973";
        weight = 1;
    };
    ["Goldfish"] = { -- 2
        price = 120;
        primaryAnim = "http://www.roblox.com/asset/?id=6517535973";
        weight = 1;
    };
    ["Dory"] = {
        price = 300;
        primaryAnim = "http://www.roblox.com/asset/?id=6553115113";
        weight = 1;
    };
    ["Frosty Dory"] = {
        price = 400;
        primaryAnim = "http://www.roblox.com/asset/?id=6553115113";
        weight = 1;
        disallow = true;
    };
    ["Nemo"] = {
        price = 700;
        primaryAnim = "http://www.roblox.com/asset/?id=6553115113";
        weight = 1;
    };
    ["Dorado"] = { -- 2
        price = 2 * 800;
        primaryAnim = "http://www.roblox.com/asset/?id=6682935021";
        weight = 2;
    };
    ["Barracuda"] = {
        price = 2 * 1800;
        primaryAnim = "http://www.roblox.com/asset/?id=6682935021";
        weight = 2;
    };
    ["Rockfish"] = { -- 2
        price = 2 * 3000;
        primaryAnim = "http://www.roblox.com/asset/?id=6682935021";
        weight = 2;
    };
    ["Swordfish"] = {
        price = 2 * 9000;
        primaryAnim = "http://www.roblox.com/asset/?id=6682935021";
        weight = 2;
    };
    ["Catfish"] = {
        price = 4 * 25000;
        primaryAnim = "http://www.roblox.com/asset/?id=6682935021";
        weight = 2;
    };
    ["Shark"] = {
        price = 4 * 90000;
        primaryAnim = "http://www.roblox.com/asset/?id=6548094121";
        weight = 2;
    };
    ["Turtle"] = { -- 2
        price = 7 * 200000;
        primaryAnim = "http://www.roblox.com/asset/?id=6609582853";
        weight = 7;
    };
    ["Stingray"] = {
        price = 6 * 450000;
        primaryAnim = "http://www.roblox.com/asset/?id=6721473578";
        weight = 7;
    };
    ["Whale"] = { -- 2
        price = 10 * 1200000;
        primaryAnim = "http://www.roblox.com/asset/?id=6649047427";
        weight = 10;
    };

    ["Neon Carp"] = {
        price = 15 * 3;
        primaryAnim = "http://www.roblox.com/asset/?id=6517535973";
        weight = 1;
        reqPass = "Legendary Fish";
    };
    ["Ghost Fish"] = {
        price = 2 * 150 * 3;
        primaryAnim = "http://www.roblox.com/asset/?id=6682935021";
        weight = 2;
        reqPass = "Legendary Fish";
    };
    ["Spiked Shark"] = {
        price = 4 * 450 * 3;
        primaryAnim = "http://www.roblox.com/asset/?id=6548094121";
        weight = 2;
        reqPass = "Legendary Fish";
    };
}

for fishName, fishStat in pairs(module) do
    fishStat.profit = Round((fishStat.price/GameSettings.fishProfit) ^ 0.75) + GameSettings.fishProfitInit
    if fishStat.reqPass == "Legendary Fish" then
        fishStat.profit *= 2
    end
end

return module