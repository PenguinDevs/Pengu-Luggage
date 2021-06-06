local Resources = require(game.ReplicatedStorage.Resources)

local module = {
	{
		module = Resources:LoadLibrary("FetchData");
		priority = 50;
	};
	{
		module = Resources:LoadLibrary("DataChange");
		priority = 51;
	};
	{
		module = Resources:LoadLibrary("PlayerProfiles");
		priority = 52;
	};
	{
		module = Resources:LoadLibrary("MarketProducts");
		priority = 53;
	};
	{
		module = Resources:LoadLibrary("STweenS");
		priority = 100;
	};
	{
		module = Resources:LoadLibrary("ChatTags");
		priority = 101;
	};
	{
		module = Resources:LoadLibrary("SettingsHandler");
		priority = 102;
	};
	{
		module = Resources:LoadLibrary("CodesHandler");
		priority = 103;
	};
	{
		module = Resources:LoadLibrary("BuildUpdates");
		priority = 104;
	};
	{
		module = Resources:LoadLibrary("LandPlots");
		priority = 150;
	};
	{
		module = Resources:LoadLibrary("FloorBuilds");
		priority = 151;
	};
	{
		module = Resources:LoadLibrary("WallBuilds");
		priority = 152;
	};
	{
		module = Resources:LoadLibrary("ItemBuilds");
		priority = 153;
	};
	{
		module = Resources:LoadLibrary("DragItem");
		priority = 154;
	};
	{
		module = Resources:LoadLibrary("BuyLand");
		priority = 200;
	};
	{
		module = Resources:LoadLibrary("BuyFloor");
		priority = 201;
	};
	{
		module = Resources:LoadLibrary("DestroyFloor");
		priority = 202;
	};
	{
		module = Resources:LoadLibrary("BuyWall");
		priority = 203;
	};
	{
		module = Resources:LoadLibrary("DestroyWall");
		priority = 204;
	};
	{
		module = Resources:LoadLibrary("BuyItem");
		priority = 205;
	};
	{
		module = Resources:LoadLibrary("DestroyItem");
		priority = 206;
	};
	{
		module = Resources:LoadLibrary("BuyFish");
		priority = 207;
	};
	{
		module = Resources:LoadLibrary("FillFish");
		priority = 207;
	};
	{
		module = Resources:LoadLibrary("RequestPlayer");
		priority = 208;
	};
	{
		module = Resources:LoadLibrary("PlotTeleport");
		priority = 209;
	};
	{
		module = Resources:LoadLibrary("TutorialSet");
		priority = 210;
	};
	{
		module = Resources:LoadLibrary("Leaderboards");
		priority = 211;
	};
	{
		module = Resources:LoadLibrary("ChatTips");
		priority = 212;
	};
	{
		module = Resources:LoadLibrary("DailyRewardCollect");
		priority = 213;
	};
}

return module
