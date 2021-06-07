local module = {}

module._resources = require(game.ReplicatedStorage.Resources)
module._textLoader = module._resources:LoadLibrary("TextLoader")

module._dataStore2 = module._resources:LoadLibrary("DataStore2")
module._defaultDS = module._resources:LoadLibrary("DefaultDS")

local GetCustomerAmount = module._resources:LoadLibrary("GetCustomerAmount")

function module:playerProfileAssign(playerProfile)
	local leaderstat = {}

	function leaderstat:update()
		--local coinsStore = module._dataStore2("coins", playerStat.obj)
		--local levelStore = module._dataStore2("level", playerProfile.obj)
		--local gemsStore = module._dataStore2("gems", playerProfile.obj)
		local moneyStore = module._dataStore2("money", playerProfile.obj)
		local build1Store = module._dataStore2("build1", playerProfile.obj)
		--leaderstat._coinVal.Value = module._textLoader:ConvertShort(coinsStore:Get(module._defaultDS.coins) or 0)
		--leaderstat._levelVal.Value = module._textLoader:ConvertShort(levelStore:Get(module._defaultDS.level) or 0)
		--leaderstat._gemVal.Value = module._textLoader:ConvertShort(gemsStore:Get(module._defaultDS.gems) or 0)
		leaderstat._moneyVal.Value = module._textLoader:ConvertShort(moneyStore:Get(module._defaultDS.money) or 0)
		leaderstat._build1Val.Value = module._textLoader:ConvertShort(GetCustomerAmount(build1Store:Get(module._defaultDS.build1)) or 0)
	end

	function leaderstat:setup()
		if playerProfile.obj:FindFirstChild("leaderstat") then
			playerProfile.obj.leaderstat:Destroy()
		end

		local leaderstatsFolder = Instance.new("Folder", playerProfile.obj)
		leaderstatsFolder.Name = "leaderstats"

		--local coinVal = Instance.new("StringValue", leaderstatsFolder)
		--coinVal.Name = "Coins"
		--leaderstat._coinVal = coinVal

		--local levelVal = Instance.new("StringValue", leaderstatsFolder)
		--levelVal.Name = "Level"
		--leaderstat._levelVal = levelVal

		--local gemVal = Instance.new("StringValue", leaderstatsFolder)
		--gemVal.Name = "Gems"
		--leaderstat._gemVal = gemVal

		local moneyVal = Instance.new("StringValue", leaderstatsFolder)
		moneyVal.Name = "Money"
		leaderstat._moneyVal = moneyVal

		local build1Val = Instance.new("StringValue", leaderstatsFolder)
		build1Val.Name = "Customers"
		leaderstat._build1Val = build1Val

		leaderstat:update()
	end
	leaderstat:setup()

	return leaderstat
end

return module