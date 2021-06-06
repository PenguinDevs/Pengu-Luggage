local Resources = require(game.ReplicatedStorage.Resources)
local Player = game.Players.LocalPlayer
local MarketplaceService = game:GetService("MarketplaceService")
local ProductStats = Resources:LoadLibrary("ProductStats")
local GamepassStats = Resources:LoadLibrary("GamepassStats")

local module = {}

local modules = {}

function module:init()
    for _, subShop in pairs(script:GetChildren()) do
        --  table.insert(modules, 1, require(subShop))
        modules[subShop.Name] = require(subShop)
        modules[subShop.Name]:init()
    end
    module:updatePage("Money")
end

function module:updatePage(subShopName)
    for _, subShop in pairs(modules) do
        if type(subShop) == "table" then
            subShop:hidePage()
        end
    end
    local subShop = modules[subShopName]
    if subShop then
        
    else
        warn(string.format("Cannt find %s when updating page for ShopUi", subShopName))
    end
    subShop:showPage()
end

local Footer = Player.PlayerGui.ShopMenu.Frame.Footer
Footer.Gamepass.Base.Frame.MouseButton1Click:Connect(function()
    module:updatePage("Gamepass")
end)
Footer.Money.Base.Frame.MouseButton1Click:Connect(function()
    module:updatePage("Money")
end)
-- Footer.Other.Base.Frame.MouseButton1Click:Connect(function()
--     module:updatePage("Other")
-- end)

Player.PlayerGui.InGameRight.Frame.Shop.Base.Frame.MouseButton1Click:Connect(function()
    module:updatePage("Gamepass")
end)
Player.PlayerGui.InGame.Frame.Currency.Base.Balance.Button.MouseButton1Click:Connect(function()
    module:updatePage("Money")
end)
Player.PlayerGui.InGame.Frame.Currency.Base.Rate.Button.MouseButton1Click:Connect(function()
    MarketplaceService:PromptGamePassPurchase(Player, GamepassStats["2x Money"].id)
end)

return module