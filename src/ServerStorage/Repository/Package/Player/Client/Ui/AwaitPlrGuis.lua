local module = {}

local PlayersService = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Player = PlayersService.LocalPlayer

function module:init()
    if not game.IsLoaded then
		game.Loaded:Wait()
	end
    
	for _, gui in pairs(ReplicatedStorage.Guis:GetChildren()) do
		gui:Clone().Parent = Player.PlayerGui
	end
end

return module