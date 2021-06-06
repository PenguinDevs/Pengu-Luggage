local Resources = require(game.ReplicatedStorage.Resources)

local module = {
	{
		module = "UiHandler";
		priority = 50;
	};
	{
		module = "Status";
		priority = 51;
	};
	{
		module = "STweenC";
		priority = 101;
	};
	{
		module = "CreateChatMessage";
		priority = 102;
	};
	{
		module = "FishBuy";
		priority = 300;
	};
	{
		module = "FishSpawn";
		priority = 301;
	};
	{
		module = "DaltonRoamings";
		priority = 302;
	};
	{
		module = "NotifyHandler";
		priority = 303;
	};
	{
		module = "PlayersMenuUi";
		priority = 304;
	};
	{
		module = "ShopUi";
		priority = 305;
	};
	{
		module = "GamepassBoards";
		priority = 306;
	};
	{
		module = "SettingsHandler";
		priority = 307;
	};
	{
		module = "AudioHandler";
		priority = 308;
	};
	{
		module = "BackgroundAudio";
		priority = 309;
	};
	{
		module = "CodesUi";
		priority = 310;
	};
	{
		module = "PlayerProxParent";
		priority = 311;
	};
	{
		module = "BuildItem";
		priority = 400;
	};
	{
		module = "BuildFloor";
		priority = 401;
	};
	{
		module = "BuildWall";
		priority = 402;
	};
	{
		module = "BuildLand";
		priority = 403;
	};
	{
		module = "MoneyBuyUi";
		priority = 450;
	};
	-- {
	-- 	module = "GamepassBoards";
	-- 	priority = 451;
	-- };
	{
		module = "RadioUi";
		priority = 452;
	};
	{
		module = "TasksUi";
		priority = 453;
	};
	{
		module = "DailyReward";
		priority = 454;
	};
	{
		module = "RopeAnimations";
		priority = 500;
	};
	{
		module = "BoatAnimations";
		priority = 501;
	};
	{
		module = "DaltonControl";
		priority = 502;
	};
	{
		module = "WaterWavesMovement";
		priority = 503;
	};
	{
		module = "OrbsVisualiser";
		priority = 504;
	};
	{
		module = "AnimationsVisualiser";
		priority = 505;
	};
	-- {
	-- 	module = "BackgroundUi";
	-- 	priority = 506;
	-- };
	{
		module = "PathfindingMaps";
		priority = 507;
	};
	{
		module = "FloorCast";
		priority = 508;
	};
	{
		module = "DoorTrigger";
		priority = 508;
	};
	-- {
	-- 	module = "TutorialHandler";
	-- 	priority = 800;
	-- };
}

return module
