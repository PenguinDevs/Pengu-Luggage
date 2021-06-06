local Resources = require(game.ReplicatedStorage.Resources)

local module = {
	{
		module = Resources:LoadLibrary("D2BeforeGet");
		priority = 50;
		name = "beforeGet";
	};
	{
		module = Resources:LoadLibrary("LeaderStats");
		priority = 51;
		name = "leaderstats";
	};
	{
		module = Resources:LoadLibrary("DataChange");
		priority = 52;
		name = "data";
	};
	{
		module = Resources:LoadLibrary("PlayerGamepass");
		priority = 53;
		name = "passes";
	};
	{
		module = Resources:LoadLibrary("LData");
		priority = 54;
		name = "lData";
	};
	{
		module = Resources:LoadLibrary("PlayerInGroup");
		priority = 55;
		name = "inGroup";
	};
	{
		module = Resources:LoadLibrary("TutorialSet");
		priority = 60;
		name = "tutorial";
	};
	{
		module = Resources:LoadLibrary("LandPlots");
		priority = 100;
		name = "landPlots";
	};
	{
		module = Resources:LoadLibrary("CeilingBuilds");
		priority = 101;
		name = "ceilingBuild";
	};
	{
		module = Resources:LoadLibrary("FloorBuilds");
		priority = 102;
		name = "floorBuild";
	};
	{
		module = Resources:LoadLibrary("WallBuilds");
		priority = 103;
		name = "wallBuild";
	};
	{
		module = Resources:LoadLibrary("ItemBuilds");
		priority = 104;
		name = "itemBuild";
	};
	{
		module = Resources:LoadLibrary("PlayerDrags");
		priority = 105;
		name = "drag";
	};
	{
		module = Resources:LoadLibrary("FishObjects");
		priority = 125;
		name = "fishObjects";
	};
	{
		module = Resources:LoadLibrary("PlayerIncome");
		priority = 126;
		name = "income";
	};
	{
		module = Resources:LoadLibrary("SatisfactionBoard");
		priority = 127;
		name = "satisBoard";
	};
	{
		module = Resources:LoadLibrary("CharacterAdded");
		priority = 128;
		name = "character";
	};
	{
		module = Resources:LoadLibrary("WalletSpawn");
		priority = 129;
		name = "walletSpawn";
	};
	{
		module = Resources:LoadLibrary("Rewards");
		priority = 130;
		name = "rewards";
	};
	{
		module = Resources:LoadLibrary("PlayerTasks");
		priority = 131;
		name = "tasks";
	};
	{
		module = Resources:LoadLibrary("DaltonControlUpdate");
		priority = 150;
		name = "daltons";
	};
	{
		module = Resources:LoadLibrary("ChatTags");
		priority = 151;
		name = "chatTags";
	};
}

return module
