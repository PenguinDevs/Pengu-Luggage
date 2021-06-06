local Resources = require(game.ReplicatedStorage.Resources)
local Player = game.Players.LocalPlayer
local Status = Resources:LoadLibrary("Status")
local Notify = Resources:LoadLibrary("NotifyHandler")
local TutorialHandler = Resources:LoadLibrary("TutorialHandler")

function getTutorialCheck(name)
	return function()
		if TutorialHandler.doingTutorial then
			local allow = TutorialHandler.allowedUi[name] or false
			if not allow then
				Notify:addItem("Issue", 3, nil, "Please follow the tutorial! Don't try and mess around 😒")
			end
			return allow
		else
			return true
		end
	end
end

function isTutorial()
	local allow = not TutorialHandler.doingTutorial
	if not allow then
		Notify:addItem("Issue", 3, nil, "Please follow the tutorial! Don't try and mess around 😒")
	end
	return allow
end

local ExpandDeb = tick()
local function expandLandCheck()
	local allow = getTutorialCheck("openLandUi")
	if not allow then return false end
	if tick() - ExpandDeb < 2 then return false end
    ExpandDeb = tick()
	return true
end

local module = {
	-- {
	-- 	event = Player.PlayerGui.InGame.Frame.Currency.People.HoverButton.MouseEnter;
	-- 	actions = {
	-- 		{
	-- 			action = "open";
	-- 			ui = "InterfaceNeedsUi";
	-- 		};
	-- 	};
	-- };
	-- {
	-- 	event = Player.PlayerGui.InGame.Frame.Currency.People.HoverButton.MouseLeave;
	-- 	actions = {
	-- 		{
	-- 			action = "close";
	-- 			ui = "InterfaceNeedsUi";
	-- 		};
	-- 	};
	-- };
	{
		event = Player.PlayerGui.InGame.Frame.Currency.People.Exit.Frame.MouseButton1Click;
		actions = {
			{
				action = "close";
				ui = "InterfaceNeedsUi";
			};
		};
	};
	{
		event = Player.PlayerGui.InGame.Frame.Build.Base.Frame.MouseButton1Click;
		check = function()
			if Status.game.visiting then
				Notify:addItem("Issue", 3, nil, "You must return back to your plot to access this!")
			end
			return not Status.game.visiting
		end;
		actions = {
			{
				action = "close";
				ui = "Interface";
			};
			{
				action = "open";
				ui = "BuildUi";
			};
		};
	};
	{
		event = Player.PlayerGui.Build.Frame.Exit.Base.Frame.MouseButton1Click;
		check = isTutorial;
		actions = {
			{
				action = "close";
				ui = "BuildUi";
			};
			{
				action = "open";
				ui = "Interface";
			};
		};
	};
	{
		event = Player.PlayerGui.Build.Frame.Land.Base.Frame.MouseButton1Click;
		check = expandLandCheck;
		actions = {
			{
				action = "close";
				ui = "BuildUi";
			};
			{
				action = "open";
				ui = "LandUi";
			};
			function()
				local BuildLand = Resources:LoadLibrary("BuildLand")
				BuildLand:on()
			end;
		};
	};
	{
		event = Player.PlayerGui.BuildLand.Frame.Exit.Base.Frame.MouseButton1Click;
		check = expandLandCheck;
		actions = {
			{
				action = "close";
				ui = "LandUi";
			};
			{
				action = "open";
				ui = "BuildUi";
			};
			-- function()
			-- 	local BuildLand = Resources:LoadLibrary("BuildLand")
			-- 	BuildLand:off()
			-- end;
		};
	};
	{
		event = Player.PlayerGui.Build.Frame.Floor.Base.Frame.MouseButton1Click;
		check = getTutorialCheck("openFloorUi");
		actions = {
			{
				action = "close";
				ui = "BuildUi";
			};
			{
				action = "open";
				ui = "EditorUiWPicker";
			};
			function()
				local BuildFloor = Resources:LoadLibrary("BuildFloor")
				BuildFloor:on()
			end;
		};
	};
	{
		event = Player.PlayerGui.Editor.Frame.List.Exit.Base.Frame.MouseButton1Click;
		check = isTutorial;
		actions = {
			{
				action = "close";
				ui = "EditorUiWPicker";
			};
			{
				action = "open";
				ui = "BuildUi";
			};
			-- function()
			-- 	local BuildFloor = Resources:LoadLibrary("BuildFloor")
			-- 	BuildFloor:off()
			-- end;
		};
	};
	{
		event = Player.PlayerGui.Editor.Close.Event;
		check = getTutorialCheck("");
		actions = {
			{
				action = "close";
				ui = "EditorUiWPicker";
			};
			{
				action = "open";
				ui = "BuildUi";
			};
			-- function()
			-- 	local BuildFloor = Resources:LoadLibrary("BuildFloor")
			-- 	BuildFloor:off()
			-- end;
		};
	};
	{
		event = Player.PlayerGui.Build.Frame.Wall.Base.Frame.MouseButton1Click;
		check = getTutorialCheck("openWallUi");
		actions = {
			{
				action = "close";
				ui = "BuildUi";
			};
			{
				action = "open";
				ui = "EditorUiWPicker";
			};
			function()
				local BuildWall = Resources:LoadLibrary("BuildWall")
				BuildWall:on()
			end;
		};
	};
	-- {
	-- 	event = Player.PlayerGui.Editor.Frame.List.Exit.Base.Frame.MouseButton1Click;
	-- 	actions = {
	-- 		{
	-- 			action = "close";
	-- 			ui = "EditorUiWPicker";
	-- 		};
	-- 		{
	-- 			action = "open";
	-- 			ui = "BuildUi";
	-- 		};
	-- 		-- function()
	-- 		-- 	local BuildWall = Resources:LoadLibrary("BuildWall")
	-- 		-- 	BuildWall:off()
	-- 		-- end;
	-- 	};
	-- };
	{
		event = Player.PlayerGui.Build.Frame.Items.Base.Frame.MouseButton1Click;
		check = getTutorialCheck("openItemsUi");
		actions = {
			{
				action = "close";
				ui = "BuildUi";
			};
			{
				action = "open";
				ui = "EditorUiWPicker";
			};
			function()
				local BuildItem = Resources:LoadLibrary("BuildItem")
				BuildItem:on()
			end;
		};
	};
	{
		event = Player.PlayerGui.FishFillMenu.Frame.Footer.Tanks.Base.Frame.MouseButton1Click;
		check = getTutorialCheck("openItemsUi");
		actions = {
			{
				action = "close";
				ui = "BuildUi";
			};
			{
				action = "close";
				ui = "Interface";
			};
			{
				action = "open";
				ui = "EditorUiWPicker";
			};
			function()
				local BuildItem = Resources:LoadLibrary("BuildItem")
				BuildItem:on()
			end;
		};
	};
	-- {
	-- 	event = Player.PlayerGui.Editor.Frame.List.Exit.Base.Frame.MouseButton1Click;
	-- 	actions = {
	-- 		{
	-- 			action = "close";
	-- 			ui = "EditorUiWPicker";
	-- 		};
	-- 		{
	-- 			action = "open";
	-- 			ui = "BuildUi";
	-- 		};
	-- 		-- function()
	-- 		-- 	local BuildItem = Resources:LoadLibrary("BuildItem")
	-- 		-- 	BuildItem:off()
	-- 		-- end;
	-- 	};
	-- };
	-- {
	-- 	event = Player.PlayerGui.InGame.Frame.Edit.Base.Frame.MouseButton1Click;
	-- 	actions = {
	-- 		{
	-- 			action = "close";
	-- 			ui = "Interface";
	-- 		};
	-- 		{
	-- 			action = "open";
	-- 			ui = "EditUi";
	-- 		};
	-- 	};
	-- };
	-- {
	-- 	event = Player.PlayerGui.Edit.Frame.Exit.Base.Frame.MouseButton1Click;
	-- 	actions = {
	-- 		{
	-- 			action = "close";
	-- 			ui = "EditUi";
	-- 		};
	-- 		{
	-- 			action = "open";
	-- 			ui = "Interface";
	-- 		};
	-- 	};
	-- };
	{
		event = Player.PlayerGui.Editor.MoneyBuy.Header.Exit.Base.Frame.MouseButton1Click;
		actions = {
			{
				action = "close";
				ui = "MoneyBuyUi";
			};
		};
	};
}

return module
