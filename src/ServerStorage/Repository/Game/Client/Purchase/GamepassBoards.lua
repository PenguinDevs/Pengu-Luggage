local module = {}

local Player = game.Players.LocalPlayer
local Resources = require(game.ReplicatedStorage.Resources)
local GamepassesStats = Resources:LoadLibrary("GamepassStats")
local MarketplaceService = game:GetService("MarketplaceService")
local Status = Resources:LoadLibrary("Status")

function module:updateLabels(purchased)
	for _, board in pairs(workspace.GamepassBoards:GetChildren()) do
		for _, ui in pairs(board.Board.SurfaceGui.ScrollingFrame:GetChildren()) do
			if not ui:IsA("GuiObject") or ui.Name == "TEMP" then continue end
			if Status.passes[ui.Name] or purchased == GamepassesStats[ui.Name].id then
				ui.Base.Owned.Visible = true
			else
				ui.Base.Owned.Visible = false
			end
		end
	end
end

for _, board in pairs(workspace.GamepassBoards:GetChildren()) do
	local tempUi = board.Board.SurfaceGui.ScrollingFrame.TEMP
	for _, gamepassStat in pairs(GamepassesStats) do
		local ui = tempUi:Clone()
		
		ui.Base.Frame.ImageLabel.Image = gamepassStat.icon
		ui.Base.Frame.TextLabel.Text = gamepassStat.name
		
		ui.Base.Frame.MouseButton1Click:Connect(function()
			MarketplaceService:PromptGamePassPurchase(Player, gamepassStat.id)
		end)
		
		ui.Name = gamepassStat.name
		ui.Parent = board.Board.SurfaceGui.ScrollingFrame
		ui.Visible = true
	end
end
module:updateLabels()

MarketplaceService.PromptGamePassPurchaseFinished:Connect(function(player, id, wasPurchased)
    if not wasPurchased then return end
	if player ~= Player then return end
    module:updateLabels(id)
end)

return module
