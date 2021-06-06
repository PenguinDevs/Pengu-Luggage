local MarketplaceService = game:GetService("MarketplaceService")
local Resources = require(game.ReplicatedStorage.Resources)
local Players = game:GetService("Players")
local ProductStats = Resources:LoadLibrary("ProductStats")
local Links = require(script.Links)

local module = {}

MarketplaceService.PromptProductPurchaseFinished:Connect(function(userId, assetId, isPurchased)
    local player = Players:GetPlayerByUserId(userId)
    local product = ProductStats[tostring(assetId)]
    if not isPurchased then
        Resources:GetRemote("Notify"):FireClient(player, "Yellow", 4, nil,
            string.format("Imagine not buying %s for %s robux to feed my family :c", product.name, product.price)
        )
    else
        local initText = "Wow, you're an actual lad for purchasing %s for %s robux!"

        initText = initText .. (Links[product.name](player, product) or "")

        Resources:GetRemote("Notify"):FireClient(player, "Green", 20, nil,
            string.format(initText, product.name, product.price)
        )
    end
end)

return module