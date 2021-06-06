local player = game.Players.LocalPlayer

local openTime = 0.1
local closeTime = 0.1

local module = {
	["InterfaceCurrencyUi"] = {
		obj = player.PlayerGui.InGame.Frame.Currency;
		open = {
			pos = UDim2.new(0.5 - 0.25/2, 0, -0.5, 0);
			direction = Enum.EasingDirection.Out;
			easing = Enum.EasingStyle.Sine;
			time = openTime;
		};
		close = {
			pos = UDim2.new(0.5 - 0.25/2, 0, 1.1, 0);
			direction = Enum.EasingDirection.Out;
			easing = Enum.EasingStyle.Sine;
			time = closeTime;
		};
	};
	["InterfaceFishUi"] = {
		obj = player.PlayerGui.InGame.Frame.Fish;
		open = {
			pos = UDim2.new(0.635, 0, 0, 0);
			direction = Enum.EasingDirection.Out;
			easing = Enum.EasingStyle.Sine;
			time = openTime;
		};
		close = {
			pos = UDim2.new(0.635, 0, 1.1, 0);
			direction = Enum.EasingDirection.Out;
			easing = Enum.EasingStyle.Sine;
			time = closeTime;
		};
	};
	["InterfaceBuildUi"] = {
		obj = player.PlayerGui.InGame.Frame.Build;
		open = {
			pos = UDim2.new(0.365, 0, 0, 0);
			direction = Enum.EasingDirection.Out;
			easing = Enum.EasingStyle.Sine;
			time = openTime;
		};
		close = {
			pos = UDim2.new(0.365, 0, 1.1, 0);
			direction = Enum.EasingDirection.Out;
			easing = Enum.EasingStyle.Sine;
			time = closeTime;
		};
	};
    ["InterfacePeopleUi"] = {
		obj = player.PlayerGui.InGame.Frame.Currency.People;
		open = {
			pos = UDim2.new(0.15, 0, -0.6, 0);
			direction = Enum.EasingDirection.Out;
			easing = Enum.EasingStyle.Sine;
			time = openTime;
		};
		close = {
			pos = UDim2.new(0.15, 0, 0, 0);
			direction = Enum.EasingDirection.Out;
			easing = Enum.EasingStyle.Sine;
			time = closeTime;
		};
	};
    ["InterfaceNeedsUi"] = {
		obj = player.PlayerGui.InGame.Frame.Currency.People;
		open = {
			pos = UDim2.new(0.15, 0, -2.2, 0);
			direction = Enum.EasingDirection.Out;
			easing = Enum.EasingStyle.Sine;
			time = openTime;
		};
		close = {
			pos = UDim2.new(0.15, 0, -0.6, 0);
			direction = Enum.EasingDirection.Out;
			easing = Enum.EasingStyle.Sine;
			time = closeTime;
		};
	};
	-- ["EditorFilterUi"] = {
	-- 	obj = player.PlayerGui.Editor.Frame.List.Filter;
	-- 	open = {
	-- 		pos = UDim2.new(0.67, 0, -1, 0);
	-- 		direction = Enum.EasingDirection.Out;
	-- 		easing = Enum.EasingStyle.Sine;
	-- 		time = openTime;
	-- 	};
	-- 	close = {
	-- 		pos = UDim2.new(0.67, 0, 1, 0);
	-- 		direction = Enum.EasingDirection.Out;
	-- 		easing = Enum.EasingStyle.Sine;
	-- 		time = closeTime;
	-- 	};
	-- };
	-- ["EditorExitUi"] = {
	-- 	obj = player.PlayerGui.Editor.Frame.List.Exit;
	-- 	open = {
	-- 		pos = UDim2.new(-0.075, 0, 0.25, 0);
	-- 		direction = Enum.EasingDirection.Out;
	-- 		easing = Enum.EasingStyle.Sine;
	-- 		time = openTime;
	-- 	};
	-- 	close = {
	-- 		pos = UDim2.new(-0.075, 0, 1, 0);
	-- 		direction = Enum.EasingDirection.Out;
	-- 		easing = Enum.EasingStyle.Sine;
	-- 		time = closeTime;
	-- 	};
	-- };
	-- ["EditorDeleteUi"] = {
	-- 	obj = player.PlayerGui.Editor.Frame.List.Delete;
	-- 	open = {
	-- 		pos = UDim2.new(0.15, 0, -0.5, 0);
	-- 		direction = Enum.EasingDirection.Out;
	-- 		easing = Enum.EasingStyle.Sine;
	-- 		time = openTime;
	-- 	};
	-- 	close = {
	-- 		pos = UDim2.new(0.15, 0, 0.1, 0);
	-- 		direction = Enum.EasingDirection.Out;
	-- 		easing = Enum.EasingStyle.Sine;
	-- 		time = closeTime;
	-- 	};
	-- };
	-- ["EditorCurrencyUi"] = {
	-- 	obj = player.PlayerGui.Editor.Frame.List.Currency;
	-- 	open = {
	-- 		pos = UDim2.new(0.33, 0, -0.5, 0);
	-- 		direction = Enum.EasingDirection.Out;
	-- 		easing = Enum.EasingStyle.Sine;
	-- 		time = openTime;
	-- 	};
	-- 	close = {
	-- 		pos = UDim2.new(0.33, 0, 0.1, 0);
	-- 		direction = Enum.EasingDirection.Out;
	-- 		easing = Enum.EasingStyle.Sine;
	-- 		time = closeTime;
	-- 	};
	-- };
	-- ["EditorPickerUi"] = {
	-- 	obj = player.PlayerGui.Editor.Frame.List.Picker;
	-- 	open = {
	-- 		pos = UDim2.new(0.61, 0, 0.1, 0);
	-- 		direction = Enum.EasingDirection.Out;
	-- 		easing = Enum.EasingStyle.Sine;
	-- 		time = openTime;
	-- 	};
	-- 	close = {
	-- 		pos = UDim2.new(0.61, 0, 0.1, 0);
	-- 		direction = Enum.EasingDirection.Out;
	-- 		easing = Enum.EasingStyle.Sine;
	-- 		time = closeTime;
	-- 	};
	-- };
	
	["TasksListUi"] = {
		obj = player.PlayerGui.TasksGui.Frame;
		open = {
			pos = UDim2.new(1, 0, 0, 0);
			direction = Enum.EasingDirection.Out;
			easing = Enum.EasingStyle.Sine;
			time = openTime;
		};
		close = {
			pos = UDim2.new(1.3, 0, 0, 0);
			direction = Enum.EasingDirection.Out;
			easing = Enum.EasingStyle.Sine;
			time = closeTime;
		};
	};
}

return module
