local loading = {}

local Resources = require(game.ReplicatedStorage.Resources)
local Round = Resources:LoadLibrary("Round")
local RunService = game:GetService("RunService")
local Player = game.Players.LocalPlayer

return setmetatable(loading, {
	__call = function(_, ...)
		local Parent = ...
		
		local loadingUi = Player.PlayerGui.Loading.Loading:Clone()
		loadingUi.Visible = true
		loadingUi.Parent = Parent
		local circleAnim
		circleAnim = RunService.RenderStepped:Connect(function()
			if not loadingUi:IsDescendantOf(game) then circleAnim:Disconnect() return end
			if loadingUi:FindFirstChild("Circle") == nil then circleAnim:Disconnect() return end
			local toSub = Round(tick()/2)
			local amount = tick() - toSub * 2
			loadingUi.Circle.Rotation = 360 * amount
		end)
		--textAnim = runService.RenderStepped:Connect(function()
			
		--end)
        return loadingUi
	end
})
