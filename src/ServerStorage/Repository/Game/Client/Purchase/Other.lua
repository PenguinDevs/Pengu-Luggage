local Resources = require(game.ReplicatedStorage.Resources)
local Player = game.Players.LocalPlayer
local ProductStats = Resources:LoadLibrary("ProductStats")
local MarketplaceService = game:GetService("MarketplaceService")

local module = {}

module.obj = Player.PlayerGui.ShopMenu.Frame.Other
local Footer = Player.PlayerGui.ShopMenu.Frame.Footer
local Header = Player.PlayerGui.ShopMenu.Frame.Header

function module:showPage()
    module.obj.Visible = true
    Footer.Gamepass.Visible = true
    Footer.Money.Visible = false
    Footer.Other.Visible = true
    Header.Head.Base.Frame.TextLabel.Text = "OTHER"
end

function module:hidePage()
    module.obj.Visible = false
end

function module:init()
    local collected = {}
    for _, productDet in pairs(ProductStats) do
        if productDet.type ~= "money" then
            table.insert(collected, 1, productDet)
        end
    end
    table.sort(collected,
        function(a, b)
            return a.price < b.price
        end
    )
    for i, productDet in pairs(collected) do
        local ui = module.obj.TEMP:Clone()
        ui.Name = string.rep("a", i)
        ui.Parent = module.obj
        ui.Icon.ImageLabel.Image = productDet.icon
        ui.Body.Base.NameLabel.Text = productDet.name
        ui.Body.Base.DescLabel.Text = productDet.desc
        ui.Body.Base.PriceLabel.Text = string.format("R$%s", productDet.price)
        ui.Button.MouseButton1Click:Connect(function()
            MarketplaceService:PromptProductPurchase(Player, productDet.id)
        end)
    end
    module.obj.TEMP:Destroy()
end

return module