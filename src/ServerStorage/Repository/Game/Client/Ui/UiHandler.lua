local module = {}

local ReplicatedStorage = game.ReplicatedStorage
local Resources = require(ReplicatedStorage.Resources)
local Player = game.Players.LocalPlayer

local function output(message)
	if false then
		print(message)
	end
end

function module:init()
	output(-1)
	if not game.IsLoaded then
		game.Loaded:Wait()
	end
	output(0)
	for _, gui in pairs(ReplicatedStorage.Guis:GetChildren()) do
		gui:Clone().Parent = Player.PlayerGui
	end
	
	output(1)
	local UiShowHide = Resources:LoadLibrary("UiShowHide")
	output(2)
	local BindUiShowHide = Resources:LoadLibrary("BindUiShowHide")
	output(3)
	local UiOpenClose = Resources:LoadLibrary("UiOpenClose")
	output(4)
	local BindUiOpenClose = Resources:LoadLibrary("BindUiOpenClose")
	BindUiOpenClose(UiOpenClose)
	output(5)
	local ButtonEffects = Resources:LoadLibrary("ButtonEffects")
	output(6)

	UiShowHide:tweenMenu("Interface", "show")
end

return module
