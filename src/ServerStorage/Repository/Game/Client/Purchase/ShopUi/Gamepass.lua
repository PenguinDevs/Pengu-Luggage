local Resources = require(game.ReplicatedStorage.Resources)
local Player = game.Players.LocalPlayer
local GamepassStats = Resources:LoadLibrary("GamepassStats")
local MarketplaceService = game:GetService("MarketplaceService")
local Status = Resources:LoadLibrary("Status")

local module = {}

module.obj = Player.PlayerGui.ShopMenu.Frame.Gamepass
local Footer = Player.PlayerGui.ShopMenu.Frame.Footer
local Header = Player.PlayerGui.ShopMenu.Frame.Header

function module:showPage()
    module.obj.Visible = true
    -- Footer.Gamepass.Visible = false
    -- Footer.Money.Visible = true
    if Status.data.settings.dark then
        Footer.Gamepass.Base.BackgroundColor3 = Color3.fromRGB(85, 85, 85)
        Footer.Money.Base.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
    else
        Footer.Gamepass.Base.BackgroundColor3 = Color3.fromRGB(201, 201, 201)
        Footer.Money.Base.BackgroundColor3 = Color3.fromRGB(255, 255, 255) 
    end
    Header.Head.Base.Frame.TextLabel.TextColor3 = Color3.fromRGB(85, 170, 255)
    --Footer.Other.Visible = true
    Header.Head.Base.Frame.TextLabel.Text = "GAMEPASSES"
end

function module:hidePage()
    module.obj.Visible = false
end

function module:init()
    local collected = {}
    for _, passDet in pairs(GamepassStats) do
        table.insert(collected, 1, passDet)
    end
    table.sort(collected,
        function(a, b)
            return a.price < b.price
        end
    )
    for i, passDet in pairs(collected) do
        local ui = module.obj.TEMP:Clone()
        ui.Name = string.rep("a", i)
        ui.Parent = module.obj
        ui.Icon.ImageLabel.Image = passDet.icon
        ui.Body.Base.NameLabel.Text = passDet.name
        ui.Name = passDet.name
        -- ui.Body.Base.DescLabel.Text = passDet.desc
        -- ui.Body.Base.PriceLabel.Text = string.format("R$%s", passDet.price)
        -- ui.Button.MouseButton1Click:Connect(function()
        --     MarketplaceService:PromptGamePassPurchase(Player, passDet.id)
        -- end)
        ui.Body.Base.Buy.Base.Frame.PriceLabel.Text = string.format("R$%s", passDet.price)
        ui.Button.MouseButton1Click:Connect(function()
            MarketplaceService:PromptGamePassPurchase(Player, passDet.id)
        end)

        if Status.passes[passDet.name] then
            ui.Owned.Visible = true
        else
            ui.Owned.Visible = false
        end
    end
    module.obj.TEMP:Destroy()
end

function module:updateIcons(purchased)
    for passName, passDet in pairs(GamepassStats) do
        local ui = module.obj:FindFirstChild(passName)
        if Status.passes[passDet.name] or passDet.id == purchased then
            ui.Owned.Visible = true
        else
            ui.Owned.Visible = false
        end
    end
end

MarketplaceService.PromptGamePassPurchaseFinished:Connect(function(player, id, wasPurchased)
    if not wasPurchased then return end
    if player ~= Player then return end
    module:updateIcons(id)
end)

return module