local player = game.Players.LocalPlayer

local openTime = 0.1
local closeTime = 0.1

local module = {
	["InterfaceCurrencyUi"] = {
		obj = player.PlayerGui.InGame.Frame.Currency;
		open = {
			pos = UDim2.new(0, 0, -0.5, 0);
			direction = Enum.EasingDirection.Out;
			easing = Enum.EasingStyle.Sine;
			time = openTime;
		};
		close = {
			pos = UDim2.new(0, 0, 1.1, 0);
			direction = Enum.EasingDirection.Out;
			easing = Enum.EasingStyle.Sine;
			time = closeTime;
		};
	};
	["InterfaceFishUi"] = {
		obj = player.PlayerGui.InGame.Frame.Fish;
		open = {
			pos = UDim2.new(0.505, 0, 0, 0);
			direction = Enum.EasingDirection.Out;
			easing = Enum.EasingStyle.Sine;
			time = openTime;
		};
		close = {
			pos = UDim2.new(0.505, 0, 1.1, 0);
			direction = Enum.EasingDirection.Out;
			easing = Enum.EasingStyle.Sine;
			time = closeTime;
		};
	};
	["InterfaceBuildUi"] = {
		obj = player.PlayerGui.InGame.Frame.Build;
		open = {
			pos = UDim2.new(0.495, 0, 0, 0);
			direction = Enum.EasingDirection.Out;
			easing = Enum.EasingStyle.Sine;
			time = openTime;
		};
		close = {
			pos = UDim2.new(0.495, 0, 1.1, 0);
			direction = Enum.EasingDirection.Out;
			easing = Enum.EasingStyle.Sine;
			time = closeTime;
		};
	};
	["InterfacePeopleUi"] = {
		obj = player.PlayerGui.InGame.Frame.Currency.People;
		open = {
			pos = UDim2.new(0, 0, -0.6, 0);
			direction = Enum.EasingDirection.Out;
			easing = Enum.EasingStyle.Sine;
			time = openTime;
		};
		close = {
			pos = UDim2.new(0, 0, 0, 0);
			direction = Enum.EasingDirection.Out;
			easing = Enum.EasingStyle.Sine;
			time = closeTime;
		};
	};
	["InterfaceNeedsUi"] = {
		obj = player.PlayerGui.InGame.Frame.Currency.People;
		open = {
			pos = UDim2.new(0, 0, -2.2, 0);
			direction = Enum.EasingDirection.Out;
			easing = Enum.EasingStyle.Sine;
			time = openTime;
		};
		close = {
			pos = UDim2.new(0, 0, -0.6, 0);
			direction = Enum.EasingDirection.Out;
			easing = Enum.EasingStyle.Sine;
			time = closeTime;
		};
	};
	["InterfaceHomeUi"] = {
		obj = player.PlayerGui.InGame.Home;
		open = {
			pos = UDim2.new(0.5, 0, 0, 0);
			direction = Enum.EasingDirection.Out;
			easing = Enum.EasingStyle.Sine;
			time = openTime;
		};
		close = {
			pos = UDim2.new(0.5, 0, -0.4, 0);
			direction = Enum.EasingDirection.Out;
			easing = Enum.EasingStyle.Sine;
			time = closeTime;
		};
	};
	["BuildExitUi"] = {
		obj = player.PlayerGui.Build.Frame.Exit;
		open = {
			pos = UDim2.new(0.28, 0, 0, 0);
			direction = Enum.EasingDirection.Out;
			easing = Enum.EasingStyle.Sine;
			time = openTime;
		};
		close = {
			pos = UDim2.new(0.28, 0, 1.1, 0);
			direction = Enum.EasingDirection.Out;
			easing = Enum.EasingStyle.Sine;
			time = closeTime;
		};
	};
	["BuildItemsUi"] = {
		obj = player.PlayerGui.Build.Frame.Items;
		open = {
			pos = UDim2.new(0.39, 0, 0, 0);
			direction = Enum.EasingDirection.Out;
			easing = Enum.EasingStyle.Sine;
			time = openTime;
		};
		close = {
			pos = UDim2.new(0.39, 0, 1.1, 0);
			direction = Enum.EasingDirection.Out;
			easing = Enum.EasingStyle.Sine;
			time = closeTime;
		};
	};
	["BuildLandUi"] = {
		obj = player.PlayerGui.Build.Frame.Land;
		open = {
			pos = UDim2.new(0.72, 0, 0, 0);
			direction = Enum.EasingDirection.Out;
			easing = Enum.EasingStyle.Sine;
			time = openTime;
		};
		close = {
			pos = UDim2.new(0.72, 0, 1.1, 0);
			direction = Enum.EasingDirection.Out;
			easing = Enum.EasingStyle.Sine;
			time = closeTime;
		};
	};
	["BuildWallUi"] = {
		obj = player.PlayerGui.Build.Frame.Wall;
		open = {
			pos = UDim2.new(0.61, 0, 0, 0);
			direction = Enum.EasingDirection.Out;
			easing = Enum.EasingStyle.Sine;
			time = openTime;
		};
		close = {
			pos = UDim2.new(0.61, 0, 1.1, 0);
			direction = Enum.EasingDirection.Out;
			easing = Enum.EasingStyle.Sine;
			time = closeTime;
		};
	};
	["BuildFloorUi"] = {
		obj = player.PlayerGui.Build.Frame.Floor;
		open = {
			pos = UDim2.new(0.5, 0, 0, 0);
			direction = Enum.EasingDirection.Out;
			easing = Enum.EasingStyle.Sine;
			time = openTime;
		};
		close = {
			pos = UDim2.new(0.5, 0, 1.1, 0);
			direction = Enum.EasingDirection.Out;
			easing = Enum.EasingStyle.Sine;
			time = closeTime;
		};
	};
	["SharedCurrencyUi"] = {
		obj = player.PlayerGui.Shared.Frame.Currency;
		open = {
			pos = UDim2.new(0.39, 0, 0, 0);
			direction = Enum.EasingDirection.Out;
			easing = Enum.EasingStyle.Sine;
			time = openTime;
		};
		close = {
			pos = UDim2.new(0.39, 0, 1.1, 0);
			direction = Enum.EasingDirection.Out;
			easing = Enum.EasingStyle.Sine;
			time = closeTime;
		};
	};
	["LandExitUi"] = {
		obj = player.PlayerGui.BuildLand.Frame.Exit;
		open = {
			pos = UDim2.new(0.28, 0, 0, 0);
			direction = Enum.EasingDirection.Out;
			easing = Enum.EasingStyle.Sine;
			time = openTime;
		};
		close = {
			pos = UDim2.new(0.28, 0, 1.1, 0);
			direction = Enum.EasingDirection.Out;
			easing = Enum.EasingStyle.Sine;
			time = closeTime;
		};
	};
	["LandInfoUi"] = {
		obj = player.PlayerGui.BuildLand.Frame.Info;
		open = {
			pos = UDim2.new(0.5, 0, 0, 0);
			direction = Enum.EasingDirection.Out;
			easing = Enum.EasingStyle.Sine;
			time = openTime;
		};
		close = {
			pos = UDim2.new(0.5, 0, 1.1, 0);
			direction = Enum.EasingDirection.Out;
			easing = Enum.EasingStyle.Sine;
			time = closeTime;
		};
	};
	["LandBuyUi"] = {
		obj = player.PlayerGui.BuildLand.Frame.Buy;
		open = {
			pos = UDim2.new(0.71, 0, -1, 0);
			direction = Enum.EasingDirection.Out;
			easing = Enum.EasingStyle.Sine;
			time = openTime;
		};
		close = {
			pos = UDim2.new(0.71, 0, 1.1, 0);
			direction = Enum.EasingDirection.Out;
			easing = Enum.EasingStyle.Sine;
			time = closeTime;
		};
	};
	["EditorBaseUi"] = {
		obj = player.PlayerGui.Editor.Frame.List;
		open = {
			pos = UDim2.new(0.5, 0, 0, 0);
			direction = Enum.EasingDirection.Out;
			easing = Enum.EasingStyle.Sine;
			time = openTime;
		};
		close = {
			pos = UDim2.new(0.5, 0, 1, 0);
			direction = Enum.EasingDirection.Out;
			easing = Enum.EasingStyle.Sine;
			time = closeTime;
		};
	};
	["EditorBaseHideUi"] = {
		obj = player.PlayerGui.Editor.Frame.List;
		open = {
			pos = UDim2.new(0.5, 0, 0, 0);
			direction = Enum.EasingDirection.Out;
			easing = Enum.EasingStyle.Sine;
			time = openTime;
		};
		close = {
			pos = UDim2.new(0.5, 0, 3, 0);
			direction = Enum.EasingDirection.Out;
			easing = Enum.EasingStyle.Sine;
			time = closeTime;
		};
	};
	["EditorExitUi"] = {
		obj = player.PlayerGui.Editor.Frame.List.Exit;
		open = {
			pos = UDim2.new(-0.075, 0, 0.25, 0);
			direction = Enum.EasingDirection.Out;
			easing = Enum.EasingStyle.Sine;
			time = openTime;
		};
		close = {
			pos = UDim2.new(-0.075, 0, 0.5, 0);
			direction = Enum.EasingDirection.Out;
			easing = Enum.EasingStyle.Sine;
			time = closeTime;
		};
	};
	["EditorDeleteUi"] = {
		obj = player.PlayerGui.Editor.Frame.List.Delete;
		open = {
			pos = UDim2.new(0.33, 0, -0.5, 0);
			direction = Enum.EasingDirection.Out;
			easing = Enum.EasingStyle.Sine;
			time = openTime;
		};
		close = {
			pos = UDim2.new(0.33, 0, 0.1, 0);
			direction = Enum.EasingDirection.Out;
			easing = Enum.EasingStyle.Sine;
			time = closeTime;
		};
	};
	["EditorCurrencyUi"] = {
		obj = player.PlayerGui.Editor.Frame.List.Currency;
		open = {
			pos = UDim2.new(0.67, 0, -0.5, 0);
			direction = Enum.EasingDirection.Out;
			easing = Enum.EasingStyle.Sine;
			time = openTime;
		};
		close = {
			pos = UDim2.new(0.67, 0, 0.1, 0);
			direction = Enum.EasingDirection.Out;
			easing = Enum.EasingStyle.Sine;
			time = closeTime;
		};
	};
	["EditorSelectingUi"] = {
		obj = player.PlayerGui.Editor.Frame.List.Selecting;
		open = {
			pos = UDim2.new(0.5, 0, -0.6, 0);
			direction = Enum.EasingDirection.Out;
			easing = Enum.EasingStyle.Sine;
			time = openTime;
		};
		close = {
			pos = UDim2.new(0.5, 0, 0.1, 0);
			direction = Enum.EasingDirection.Out;
			easing = Enum.EasingStyle.Sine;
			time = closeTime;
		};
	};
	["EditorPickerUi"] = {
		obj = player.PlayerGui.Editor.Frame.List.Picker;
		open = {
			pos = UDim2.new(0.61, 0, -1, 0);
			direction = Enum.EasingDirection.Out;
			easing = Enum.EasingStyle.Sine;
			time = openTime;
		};
		close = {
			pos = UDim2.new(0.61, 0, 0.1, 0);
			direction = Enum.EasingDirection.Out;
			easing = Enum.EasingStyle.Sine;
			time = closeTime;
		};
	};
	["EditorFilterUi"] = {
		obj = player.PlayerGui.Editor.Frame.List.Filter;
		open = {
			pos = UDim2.new(0.5, 0, -4.7, 0);
			direction = Enum.EasingDirection.Out;
			easing = Enum.EasingStyle.Sine;
			time = openTime;
		};
		close = {
			pos = UDim2.new(0.5, 0, -15, 0);
			direction = Enum.EasingDirection.Out;
			easing = Enum.EasingStyle.Sine;
			time = closeTime;
		};
	};
	["EditorRotateUi"] = {
		obj = player.PlayerGui.Editor.Rotate;
		open = {
			pos = UDim2.new(0.71, 0, 1, 0);
			direction = Enum.EasingDirection.Out;
			easing = Enum.EasingStyle.Sine;
			time = openTime;
		};
		close = {
			pos = UDim2.new(0.71, 0, 1.2, 0);
			direction = Enum.EasingDirection.Out;
			easing = Enum.EasingStyle.Sine;
			time = closeTime;
		};
	};
	["EditorPlaceUi"] = {
		obj = player.PlayerGui.Editor.Place;
		open = {
			pos = UDim2.new(0.5, 0, 1, 0);
			direction = Enum.EasingDirection.Out;
			easing = Enum.EasingStyle.Sine;
			time = openTime;
		};
		close = {
			pos = UDim2.new(0.5, 0, 1.2, 0);
			direction = Enum.EasingDirection.Out;
			easing = Enum.EasingStyle.Sine;
			time = closeTime;
		};
	};
	["EditorDeleteUi2"] = {
		obj = player.PlayerGui.Editor.Delete;
		open = {
			pos = UDim2.new(0.5, 0, 1, 0);
			direction = Enum.EasingDirection.Out;
			easing = Enum.EasingStyle.Sine;
			time = openTime;
		};
		close = {
			pos = UDim2.new(0.5, 0, 1.2, 0);
			direction = Enum.EasingDirection.Out;
			easing = Enum.EasingStyle.Sine;
			time = closeTime;
		};
	};
	["EditorCancelUi"] = {
		obj = player.PlayerGui.Editor.Cancel;
		open = {
			pos = UDim2.new(0.29, 0, 1, 0);
			direction = Enum.EasingDirection.Out;
			easing = Enum.EasingStyle.Sine;
			time = openTime;
		};
		close = {
			pos = UDim2.new(0.29, 0, 1.2, 0);
			direction = Enum.EasingDirection.Out;
			easing = Enum.EasingStyle.Sine;
			time = closeTime;
		};
	};
	["EditorMoneyAmountUi"] = {
		obj = player.PlayerGui.Editor.MoneyAmount;
		open = {
			pos = UDim2.new(0.5, 0, 0.85, 0);
			direction = Enum.EasingDirection.Out;
			easing = Enum.EasingStyle.Sine;
			time = openTime;
		};
		close = {
			pos = UDim2.new(0.5, 0, 1.2, 0);
			direction = Enum.EasingDirection.Out;
			easing = Enum.EasingStyle.Sine;
			time = closeTime;
		};
	};
	["EditorControlsUi"] = {
		obj = player.PlayerGui.Editor.Controls;
		open = {
			pos = UDim2.new(1, 0, 0.4, 0);
			direction = Enum.EasingDirection.Out;
			easing = Enum.EasingStyle.Sine;
			time = openTime;
		};
		close = {
			pos = UDim2.new(1.3, 0, 0.4, 0);
			direction = Enum.EasingDirection.Out;
			easing = Enum.EasingStyle.Sine;
			time = closeTime;
		};
	};
	["MoneyBuyUi"] = {
		obj = player.PlayerGui.Editor.MoneyBuy;
		open = {
			pos = UDim2.new(0.5, 0, 0.1, 0);
			direction = Enum.EasingDirection.Out;
			easing = Enum.EasingStyle.Sine;
			time = openTime;
		};
		close = {
			pos = UDim2.new(0.5, 0, -0.4, 0);
			direction = Enum.EasingDirection.Out;
			easing = Enum.EasingStyle.Sine;
			time = closeTime;
		};
	};
	["DeleteNotifyUi"] = {
		obj = player.PlayerGui.Editor.DeleteNotify;
		open = {
			pos = UDim2.new(0.5, 0, 0, 0);
			direction = Enum.EasingDirection.Out;
			easing = Enum.EasingStyle.Sine;
			time = openTime;
		};
		close = {
			pos = UDim2.new(0.5, 0, -0.4, 0);
			direction = Enum.EasingDirection.Out;
			easing = Enum.EasingStyle.Sine;
			time = closeTime;
		};
	};
	-- ["EditExitUi"] = {
	-- 	obj = player.PlayerGui.Edit.Frame.Exit;
	-- 	open = {
	-- 		pos = UDim2.new(0.385, 0, 0, 0);
	-- 		direction = Enum.EasingDirection.Out;
	-- 		easing = Enum.EasingStyle.Sine;
	-- 		time = openTime;
	-- 	};
	-- 	close = {
	-- 		pos = UDim2.new(0.385, 0, 1.1, 0);
	-- 		direction = Enum.EasingDirection.Out;
	-- 		easing = Enum.EasingStyle.Sine;
	-- 		time = closeTime;
	-- 	};
	-- };
	-- ["EditSettingsUi"] = {
	-- 	obj = player.PlayerGui.Edit.Frame.Settings;
	-- 	open = {
	-- 		pos = UDim2.new(0.495, 0, 0, 0);
	-- 		direction = Enum.EasingDirection.Out;
	-- 		easing = Enum.EasingStyle.Sine;
	-- 		time = openTime;
	-- 	};
	-- 	close = {
	-- 		pos = UDim2.new(0.495, 0, 1.1, 0);
	-- 		direction = Enum.EasingDirection.Out;
	-- 		easing = Enum.EasingStyle.Sine;
	-- 		time = closeTime;
	-- 	};
	-- };
	-- ["EditFishUi"] = {
	-- 	obj = player.PlayerGui.Edit.Frame.Fish;
	-- 	open = {
	-- 		pos = UDim2.new(0.505, 0, 0, 0);
	-- 		direction = Enum.EasingDirection.Out;
	-- 		easing = Enum.EasingStyle.Sine;
	-- 		time = openTime;
	-- 	};
	-- 	close = {
	-- 		pos = UDim2.new(0.505, 0, 1.1, 0);
	-- 		direction = Enum.EasingDirection.Out;
	-- 		easing = Enum.EasingStyle.Sine;
	-- 		time = closeTime;
	-- 	};
	-- };
	-- ["EditPeopleUi"] = {
	-- 	obj = player.PlayerGui.Edit.Frame.People;
	-- 	open = {
	-- 		pos = UDim2.new(0.615, 0, 0, 0);
	-- 		direction = Enum.EasingDirection.Out;
	-- 		easing = Enum.EasingStyle.Sine;
	-- 		time = openTime;
	-- 	};
	-- 	close = {
	-- 		pos = UDim2.new(0.615, 0, 1.1, 0);
	-- 		direction = Enum.EasingDirection.Out;
	-- 		easing = Enum.EasingStyle.Sine;
	-- 		time = closeTime;
	-- 	};
	-- };
	-- ["EditShopUi"] = {
	-- 	obj = player.PlayerGui.Edit.Frame.Shop;
	-- 	open = {
	-- 		pos = UDim2.new(0.61, 0, 0, 0);
	-- 		direction = Enum.EasingDirection.Out;
	-- 		easing = Enum.EasingStyle.Sine;
	-- 		time = openTime;
	-- 	};
	-- 	close = {
	-- 		pos = UDim2.new(0.61, 0, 1, 0);
	-- 		direction = Enum.EasingDirection.Out;
	-- 		easing = Enum.EasingStyle.Sine;
	-- 		time = closeTime;
	-- 	};
	-- };
	["InterfaceRight"] = {
		obj = player.PlayerGui.InGameRight.Frame;
		open = {
			pos = UDim2.new(0.99, 0, 0.5, 0);
			direction = Enum.EasingDirection.Out;
			easing = Enum.EasingStyle.Sine;
			time = openTime;
		};
		close = {
			pos = UDim2.new(1.25, 0, 0.5, 0);
			direction = Enum.EasingDirection.Out;
			easing = Enum.EasingStyle.Sine;
			time = closeTime;
		};
	};
	-- ["InGameRightRadioUi"] = {
	-- 	obj = player.PlayerGui.InGameRight.Frame.Radio;
	-- 	open = {
	-- 		pos = UDim2.new(0.5, 0, 0.43, 0);
	-- 		direction = Enum.EasingDirection.Out;
	-- 		easing = Enum.EasingStyle.Sine;
	-- 		time = openTime;
	-- 	};
	-- 	close = {
	-- 		pos = UDim2.new(1.5, 0, 0.43, 0);
	-- 		direction = Enum.EasingDirection.Out;
	-- 		easing = Enum.EasingStyle.Sine;
	-- 		time = closeTime;
	-- 	};
	-- };
	-- ["InGameRightShopUi"] = {
	-- 	obj = player.PlayerGui.InGameRight.Frame.Shop;
	-- 	open = {
	-- 		pos = UDim2.new(0.5, 0, 0.52, 0);
	-- 		direction = Enum.EasingDirection.Out;
	-- 		easing = Enum.EasingStyle.Sine;
	-- 		time = openTime;
	-- 	};
	-- 	close = {
	-- 		pos = UDim2.new(1.5, 0, 0.52, 0);
	-- 		direction = Enum.EasingDirection.Out;
	-- 		easing = Enum.EasingStyle.Sine;
	-- 		time = closeTime;
	-- 	};
	-- };
	-- ["InGameRightCodeUi"] = {
	-- 	obj = player.PlayerGui.InGameRight.Frame.Codes;
	-- 	open = {
	-- 		pos = UDim2.new(0.5, 0, 0.61, 0);
	-- 		direction = Enum.EasingDirection.Out;
	-- 		easing = Enum.EasingStyle.Sine;
	-- 		time = openTime;
	-- 	};
	-- 	close = {
	-- 		pos = UDim2.new(1.5, 0, 0.61, 0);
	-- 		direction = Enum.EasingDirection.Out;
	-- 		easing = Enum.EasingStyle.Sine;
	-- 		time = closeTime;
	-- 	};
	-- };
	["TutorialDialogueUi"] = {
		obj = player.PlayerGui.Tutorial.Dialogue;
		open = {
			pos = UDim2.new(0.5, 0, 0, 0);
			direction = Enum.EasingDirection.Out;
			easing = Enum.EasingStyle.Sine;
			time = openTime;
		};
		close = {
			pos = UDim2.new(0.5, 0, -0.5, 0);
			direction = Enum.EasingDirection.Out;
			easing = Enum.EasingStyle.Sine;
			time = closeTime;
		};
	};
	["TutorialSkipRequestUi"] = {
		obj = player.PlayerGui.Tutorial.SkipRequest;
		open = {
			pos = UDim2.new(0.5, 0, 0.4, 0);
			direction = Enum.EasingDirection.Out;
			easing = Enum.EasingStyle.Sine;
			time = openTime;
		};
		close = {
			pos = UDim2.new(0.5, 0, -0.4, 0);
			direction = Enum.EasingDirection.Out;
			easing = Enum.EasingStyle.Sine;
			time = closeTime;
		};
	};
	["TasksListUi"] = {
		obj = player.PlayerGui.TasksGui.Frame;
		open = {
			pos = UDim2.new(1, 0, 0.7, 0);
			direction = Enum.EasingDirection.Out;
			easing = Enum.EasingStyle.Sine;
			time = openTime;
		};
		close = {
			pos = UDim2.new(1.3, 0, 0.7, 0);
			direction = Enum.EasingDirection.Out;
			easing = Enum.EasingStyle.Sine;
			time = closeTime;
		};
	};
}

return module
