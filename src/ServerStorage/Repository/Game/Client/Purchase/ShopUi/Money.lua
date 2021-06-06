local Resources = require(game.ReplicatedStorage.Resources)
local Player = game.Players.LocalPlayer
local ProductStats = Resources:LoadLibrary("ProductStats")
local MarketplaceService = game:GetService("MarketplaceService")
local TextLoader = Resources:LoadLibrary("TextLoader")
local Status = Resources:LoadLibrary("Status")

local module = {}

module.obj = Player.PlayerGui.ShopMenu.Frame.Money
local Footer = Player.PlayerGui.ShopMenu.Frame.Footer
local Header = Player.PlayerGui.ShopMenu.Frame.Header

function module:showPage()
    module.obj.Visible = true
    -- Footer.Gamepass.Visible = true
    -- Footer.Money.Visible = false
    if Status.data.settings.dark then
        Footer.Gamepass.Base.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
        Footer.Money.Base.BackgroundColor3 = Color3.fromRGB(85, 85, 85)
    else
        Footer.Gamepass.Base.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        Footer.Money.Base.BackgroundColor3 = Color3.fromRGB(201, 201, 201)
    end
    Header.Head.Base.Frame.TextLabel.TextColor3 = Color3.fromRGB(95, 235, 132)
    --Footer.Other.Visible = true
    Header.Head.Base.Frame.TextLabel.Text = "MONEY"
end

function module:hidePage()
    module.obj.Visible = false
end

function module:init()
    local collected = {}
    for _, productDet in pairs(ProductStats) do
        if productDet.type == "money" then
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
        --ui.Body.Base.DescLabel.Text = string.format("Get $%s instantly by purchasing this!", productDet.reward)
        -- ui.Body.Base.PriceLabel.Text = string.format("R$%s", productDet.price)
        -- ui.Button.MouseButton1Click:Connect(function()
        --     MarketplaceService:PromptProductPurchase(Player, productDet.id)
        -- end)
        ui.Body.Base.Buy.Base.Frame.PriceLabel.Text = string.format("R$%s", productDet.price)
        ui.Button.MouseButton1Click:Connect(function()
            MarketplaceService:PromptProductPurchase(Player, productDet.id)
        end)

        if productDet.message then
            ui.Message.Visible = true
            ui.Message.TextLabel.Text = productDet.message
        end
    end
    module.obj.TEMP:Destroy()
end

return module
