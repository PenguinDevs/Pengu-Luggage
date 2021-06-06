local module = {}

local RunService = game:GetService("RunService")

local STUDIO_STORE = "4" -- ONLY THIS

if RunService:IsStudio() then
	module.DATA_NO = STUDIO_STORE
else
	module.DATA_NO = "4" -- MUSt REMAIN CONSISTENT
end
module.LEADERBOARD_NO = "1"

module.build1 = {
	floors = {
		["-1:0"] = {
			floor = "Wood";
			colour = {127, 95, 68};
		};
		["0:0"] = {
			floor = "Wood";
			colour = {127, 95, 68};
		};
		["1:0"] = {
			floor = "Wood";
			colour = {127, 95, 68};
		};
		["2:0"] = {
			floor = "Wood";
			colour = {127, 95, 68};
		};
		["-1:1"] = {
			floor = "Wood";
			colour = {127, 95, 68};
		};
		["0:1"] = {
			floor = "Wood";
			colour = {127, 95, 68};
		};
		["1:1"] = {
			floor = "Wood";
			colour = {127, 95, 68};
		};
		["2:1"] = {
			floor = "Wood";
			colour = {127, 95, 68};
		};
		["-1:2"] = {
			floor = "Wood";
			colour = {127, 95, 68};
		};
		["0:2"] = {
			floor = "Wood";
			colour = {127, 95, 68};
		};
		["1:2"] = {
			floor = "Wood";
			colour = {127, 95, 68};
		};
		["2:2"] = {
			floor = "Wood";
			colour = {127, 95, 68};
		};
		["-1:3"] = {
			floor = "Wood";
			colour = {127, 95, 68};
		};
		["0:3"] = {
			floor = "Wood";
			colour = {127, 95, 68};
		};
		["1:3"] = {
			floor = "Wood";
			colour = {127, 95, 68};
		};
		["2:3"] = {
			floor = "Wood";
			colour = {127, 95, 68};
		};
	};
	walls = {
		h = {
			["-1:0"] = {
				wall = "Plaster Long Windows";
				rot = 1;
				colour = {99, 95, 98};
			};
			["0:0"] = {
				wall = "Plaster Side Door";
				rot = 1;
				colour = {99, 95, 98};
			};
			["1:0"] = {
				wall = "Plaster Side Door";
				rot = 2;
				colour = {99, 95, 98};
			};
			["2:0"] = {
				wall = "Plaster Long Windows";
				rot = 2;
				colour = {99, 95, 98};
			};
			["-1:4"] = {
				wall = "Plaster";
				rot = 2;
				colour = {99, 95, 98};
			};
			["0:4"] = {
				wall = "Plaster";
				rot = 2;
				colour = {99, 95, 98};
			};
			["1:4"] = {
				wall = "Plaster";
				rot = 2;
				colour = {99, 95, 98};
			};
			["2:4"] = {
				wall = "Plaster";
				rot = 2;
				colour = {99, 95, 98};
			};
		};
		v = {
			["-2:0"] = {
				wall = "Plaster";
				rot = 1;
				colour = {99, 95, 98};
			};
			["-2:1"] = {
				wall = "Plaster";
				rot = 1;
				colour = {99, 95, 98};
			};
			["-2:2"] = {
				wall = "Plaster";
				rot = 1;
				colour = {99, 95, 98};
			};
			["-2:3"] = {
				wall = "Plaster";
				rot = 1;
				colour = {99, 95, 98};
			};
			["2:0"] = {
				wall = "Plaster";
				rot = 2;
				colour = {99, 95, 98};
			};
			["2:1"] = {
				wall = "Plaster";
				rot = 2;
				colour = {99, 95, 98};
			};
			["2:2"] = {
				wall = "Plaster";
				rot = 2;
				colour = {99, 95, 98};
			};
			["2:3"] = {
				wall = "Plaster";
				rot = 2;
				colour = {99, 95, 98};
			};
		};
	};
	items = {
		-- ["2:9"] = {
		-- 	item = "Fishbowl";
		-- 	rot = 1;
		-- 	colour = {102, 101, 103};
		-- };
		-- ["2:6"] = {
		-- 	item = "Fishbowl";
		-- 	rot = 1;
		-- 	colour = {102, 101, 103};
		-- };
		-- ["-1:9"] = {
		-- 	item = "Fishbowl";
		-- 	rot = 1;
		-- 	colour = {102, 101, 103};
		-- };
		-- ["-1:6"] = {
		-- 	item = "Fishbowl";
		-- 	rot = 1;
		-- 	colour = {102, 101, 103};
		-- };

		["4.1:4.1"] = {
			item = "Ceiling Lamp 1";
			rot = 1;
			colour = {0, 0, 0};
		};
		["4.1:11.1"] = {
			item = "Ceiling Lamp 1";
			rot = 1;
			colour = {0, 0, 0};
		};
		["-3.1:11.1"] = {
			item = "Ceiling Lamp 1";
			rot = 1;
			colour = {0, 0, 0};
		};
		["-3.1:4.1"] = {
			item = "Ceiling Lamp 1";
			rot = 1;
			colour = {0, 0, 0};
		};
	};
	plots = {
		["0:0"] = true;
	};
}
module.money = 99
module.fish = {
	["Carp"] = 3;
}
module.fishHold = {
	-- ["item:2:6"] = {
	-- 	["Carp"] = 1;
	-- };
	-- ["item:2:9"] = {
	-- 	["Carp"] = 1;
	-- };
	-- -- ["item:-1:6"] = {
	-- -- 	["Carp"] = 1;
	-- -- };
	-- ["item:-1:9"] = {
	-- 	["Carp"] = 1;
	-- };
}
module.settings = {}
module.codes = {}
module.hadTutorial = 0
module.rewarded = {}
module.tasks = {
	["tanks"] = 1;
	["fill"] = 1;
}

module.tTime = 0
module.tMoney = 0

module.alpha = 0

module.dailyCollected = os.time() - 60 ^ 2 * 12
module.dailyStreak = 0

return module
