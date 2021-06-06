local module = {}

local Resources = require(game.ReplicatedStorage.Resources)
local ShopUi = Resources:LoadLibrary("ShopUi")
local BindUiOpenClose = Resources:LoadLibrary("BindUiOpenClose")
local Player = game.Players.LocalPlayer

Player.PlayerGui.Editor.MoneyBuy.Base.Buy.Base.Frame.MouseButton1Click:Connect(function()
    ShopUi:updatePage("Money")
	BindUiOpenClose.binds.Shop.sigs.open:Fire()
end)

Player.PlayerGui.InGame.Frame.Currency.Base.Add.Base.Frame.MouseButton1Click:Connect(function()
    ShopUi:updatePage("Money")
	BindUiOpenClose.binds.Shop.sigs.open:Fire()
end)

Player.PlayerGui.Editor.Frame.List.Currency.Base.Frame.Add.Base.Frame.MouseButton1Click:Connect(function()
    ShopUi:updatePage("Money")
	BindUiOpenClose.binds.Shop.sigs.open:Fire()
end)

Player.PlayerGui.FishMenu.Frame.Footer.Currency.Base.Add.Base.Frame.MouseButton1Click:Connect(function()
    ShopUi:updatePage("Money")
	BindUiOpenClose.binds.Shop.sigs.open:Fire()
end)

return module