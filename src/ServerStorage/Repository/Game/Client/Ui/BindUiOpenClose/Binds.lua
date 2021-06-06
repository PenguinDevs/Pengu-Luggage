local player = game.Players.LocalPlayer

local userInputService = game:GetService("UserInputService")

local resources = require(game.ReplicatedStorage.Resources)
local signal = resources:LoadLibrary("Signal")
local status = resources:LoadLibrary("Status")
local notify = resources:LoadLibrary("NotifyHandler")

local eventsObj = {}

local binds = {
	FishBuy = {
		open = {
			player.PlayerGui.FishFillMenu.Frame.Footer.Fish.Base.Frame.MouseButton1Click;
			player.PlayerGui.InGame.Frame.Fish.Base.Frame.MouseButton1Click;
			player.PlayerGui.ShopMenu.Frame.Footer.Fish.Base.Frame.MouseButton1Click;
		};
		close = {
			--player.PlayerGui.FishMenu.Frame.Header.Exit.Base.Frame.MouseButton1Click;
			player.PlayerGui.FishMenu.Frame.Header.Exit.Frame.MouseButton1Click;
			player.PlayerGui.FishMenu.Frame.Footer.Tanks.Base.Frame.MouseButton1Click;
		};
		toggle = {
			
		};
		check = function()
			if status.game.visiting then
				notify:addItem("Issue", 3, nil, "You must return back to your plot to access this!")
			end
			return not status.game.visiting
		end;
		sigs = {};
		keyBind = {};
	};
	FishFill = {
		open = {
			player.PlayerGui.FishMenu.Frame.Footer.Tanks.Base.Frame.MouseButton1Click;
			--player.PlayerGui.ItemTankGui.Frame.Body.Fill.Base.Frame.MouseButton1Click;
		};
		close = {
			--player.PlayerGui.FishFillMenu.Frame.Header.Exit.Base.Frame.MouseButton1Click;
			player.PlayerGui.FishFillMenu.Frame.Header.Exit.Frame.MouseButton1Click;
			player.PlayerGui.FishFillMenu.Frame.Footer.Fish.Base.Frame.MouseButton1Click;
			player.PlayerGui.FishFillMenu.Frame.Footer.Tanks.Base.Frame.MouseButton1Click
		};
		toggle = {
			
		};
		check = function()
			if status.game.visiting then
				notify:addItem("Issue", 3, nil, "You must return back to your plot to access this!")
			end
			return not status.game.visiting
		end;
		sigs = {};
		keyBind = {};
	};
	Players = {
		open = {
			--player.PlayerGui.Edit.Frame.People.Base.Frame.MouseButton1Click;
			player.PlayerGui.InGameRight.Frame.People.Base.Frame.MouseButton1Click;
		};
		close = {
			--player.PlayerGui.PlayersMenu.Frame.Header.Exit.Base.Frame.MouseButton1Click;
			player.PlayerGui.PlayersMenu.Frame.Header.Exit.Frame.MouseButton1Click;
		};
		toggle = {
			
		};
		sigs = {};
		keyBind = {};
	};
	Shop = {
		open = {
			player.PlayerGui.InGameRight.Frame.Shop.Base.Frame.MouseButton1Click;
			--player.PlayerGui.InGame.Frame.Currency.Base.Balance.Button.MouseButton1Click;
		};
		close = {
			-- player.PlayerGui.ShopMenu.Frame.Header.Exit.Base.Frame.MouseButton1Click;
			player.PlayerGui.ShopMenu.Frame.Header.Exit.Frame.MouseButton1Click;
		};
		toggle = {
			
		};
		sigs = {};
		keyBind = {};
	};
	Codes = {
		open = {
			player.PlayerGui.InGameRight.Frame.Codes.Base.Frame.MouseButton1Click;
		};
		close = {
			--player.PlayerGui.CodesMenu.Frame.Header.Exit.Base.Frame.MouseButton1Click;
			player.PlayerGui.CodesMenu.Frame.Header.Exit.Frame.MouseButton1Click;
		};
		toggle = {
			
		};
		sigs = {};
		keyBind = {};
	};
	Settings = {
		open = {
			--player.PlayerGui.Edit.Frame.Settings.Base.Frame.MouseButton1Click;
			player.PlayerGui.InGameRight.Frame.Settings.Base.Frame.MouseButton1Click;
		};
		close = {
			--player.PlayerGui.SettingsMenu.Frame.Header.Exit.Base.Frame.MouseButton1Click;
			player.PlayerGui.SettingsMenu.Frame.Header.Exit.Frame.MouseButton1Click;
		};
		toggle = {
			
		};
		sigs = {};
		keyBind = {};
	};
	Radio = {
		open = {
			player.PlayerGui.InGameRight.Frame.Radio.Base.Frame.MouseButton1Click;
		};
		close = {
			--player.PlayerGui.RadioMenu.Frame.Header.Exit.Base.Frame.MouseButton1Click;
			player.PlayerGui.RadioMenu.Frame.Header.Exit.Frame.MouseButton1Click;
		};
		toggle = {
			
		};
		sigs = {};
		keyBind = {};
	};
	Stats = {
		open = {
			player.PlayerGui.InGameRight.Frame.Stats.Base.Frame.MouseButton1Click;
		};
		close = {
			player.PlayerGui.StatsMenu.Frame.Header.Exit.Frame.MouseButton1Click;
		};
		toggle = {
			
		};
		sigs = {};
		keyBind = {};
	};
	FrostyDory = {
		open = {
			
		};
		close = {
			player.PlayerGui.GroupFishNotif.Frame.Body.Next.Base.Frame.MouseButton1Click;
			player.PlayerGui.GroupFishNotif.Frame.Header.Exit.Frame.MouseButton1Click;
		};
		toggle = {
			
		};
		sigs = {};
		keyBind = {};
	};
}

for uiName, OCBinds in pairs(binds) do
	if OCBinds.keyBind ~= {} and OCBinds.keyBind ~= {nil} then
		for _, keyBindInput in pairs(OCBinds.keyBind) do
			local event = signal.new()
			eventsObj[keyBindInput] = event
			binds[uiName].toggle[keyBindInput] = event
		end
	end
	
	local eventClose = Instance.new("BindableEvent") --, script:FindFirstAncestor("Ui").Sigs)
	eventClose.Name = uiName.."Close"
	table.insert(OCBinds.close, #OCBinds.close + 1, eventClose.Event)
	OCBinds.sigs["close"] = eventClose

	local eventOpen = Instance.new("BindableEvent") --, script:FindFirstAncestor("Ui").Sigs)
	eventOpen.Name = uiName.."Open"
	table.insert(OCBinds.open, #OCBinds.open + 1, eventOpen.Event)
	OCBinds.sigs["open"] = eventOpen
	
	local eventToggle = Instance.new("BindableEvent") --, script:FindFirstAncestor("Ui").Sigs)
	eventToggle.Name = uiName.."Toggle"
	table.insert(OCBinds.toggle, #OCBinds.toggle + 1, eventToggle.Event)
	OCBinds.sigs["toggle"] = eventToggle
end

userInputService.InputBegan:Connect(function(input, proc)
	if not proc then
		if input.UserInputType == Enum.UserInputType.Keyboard then
			if eventsObj[input.KeyCode] then eventsObj[input.KeyCode]:Fire() end
		end
	end
end)

resources:GetRemote("Ui").OnClientEvent:Connect(function(ui, state)
	binds[ui].sigs[state]:Fire()
end)

return binds
