local module = {	
	["Wooden Table"] = {
		price = 15;
		size = Vector2.new(4, 4);
	};
	
	["Table 1"] = {
		price = 60;
		size = Vector2.new(8, 8);
	};
	["Table 2"] = {
		price = 500;
		size = Vector2.new(8, 8);
	};
	["Table 3"] = {
		price = 4000;
		size = Vector2.new(8, 8);
	};
	
	["Chair 1"] = {
		price = 40;
		size = Vector2.new(4, 4);
		itemType = "seat";
	};
	["Chair 2"] = {
		price = 800;
		size = Vector2.new(4, 4);
		itemType = "seat";
	};
	["Chair 3"] = {
		price = 3000;
		size = Vector2.new(4, 4);
		itemType = "seat";
	};
	["Chair 4"] = {
		price = 15000;
		size = Vector2.new(4, 4);
		itemType = "seat";
	};
	["Chair 5"] = {
		price = 75000;
		size = Vector2.new(4, 4);
		itemType = "seat";
	};
	["Beanbag"] = {
		price = 8000;
		size = Vector2.new(4, 4);
		itemType = "seat";
	};
	["Couch 1"] = {
		price = 4000;
		size = Vector2.new(8, 4);
		itemType = "seat";
	};
	["Couch 2"] = {
		price = 28000;
		size = Vector2.new(8, 4);
		itemType = "seat";
	};
	
	["Ceiling Lamp 1"] = {
		price = 150;
		size = Vector2.new(4, 4);
		offset = 0.1;
	};
	["Ceiling Lamp 2"] = {
		price = 2000;
		size = Vector2.new(4, 4);
		offset = 0.1;
	};
	["Bin 1"] = {
		price = 40;
		size = Vector2.new(4, 4);
		itemType = "fun";
	};
	["Bin 2"] = {
		price = 1000;
		size = Vector2.new(4, 4);
		itemType = "fun";
	};
	["Ceiling Lanterns"] = {
		price = 30000;
		size = Vector2.new(4, 4);
		itemType = "fun";
		offset = 0.1;
	};
	["Potted Tree 1"] = {
		price = 600;
		size = Vector2.new(4, 4);
		itemType = "fun";
	};
	["Potted Tree 2"] = {
		price = 2000;
		size = Vector2.new(4, 4);
		itemType = "fun";
	};
	["Potted Tree 3"] = {
		price = 2000;
		size = Vector2.new(4, 4);
		itemType = "fun";
	};
	["Potted Tree 4"] = {
		price = 2000;
		size = Vector2.new(4, 4);
		itemType = "fun";
	};
	["Potted Tree 5"] = {
		price = 2000;
		size = Vector2.new(4, 4);
		itemType = "fun";
	};
	["Potted Sakura 1"] = {
		price = 8000;
		size = Vector2.new(4, 4);
		itemType = "fun";
	};
	["Potted Sakura 2"] = {
		price = 12000;
		size = Vector2.new(4, 4);
		itemType = "fun";
	};
	["Potted Sakura 3"] = {
		price = 16000;
		size = Vector2.new(4, 4);
		itemType = "fun";
	};
	["Potted Grass"] = {
		price = 300;
		size = Vector2.new(4, 4);
		itemType = "fun";
	};
	["Stanchion"] = {
		price = 800;
		size = Vector2.new(4, 4);
	};
	["Supply"] = {
		price = 1200;
		size = Vector2.new(12, 8);
	};
	["Dartboard"] = {
		price = 300;
		size = Vector2.new(4, 4);
		itemType = "fun";
	};


	["Water Dispenser"] = {
		price = 100;
		size = Vector2.new(4, 4);
		itemType = "drink";
		itemResult = "Water";
	};
	["Vending Machine"] = {
		price = 100;
		size = Vector2.new(4, 4);
		itemType = "food";
		itemResult = "Chocolate Bar";
	};

	["Bloxy Cola Stall"] = {
		price = 1000;
		size = Vector2.new(12, 12);
		itemType = "drink";
		itemResult = "Bloxy Cola";
	};
	["Carp Hat Stall"] = {
		price = 700;
		size = Vector2.new(12, 12);
		itemType = "fun";
		itemResult = "Carp";
	};
	["Hotdog Stall"] = {
		price = 700;
		size = Vector2.new(12, 12);
		itemType = "food";
		itemResult = "Hotdog";
	};
	["Icecream Stall"] = {
		price = 1500;
		size = Vector2.new(12, 12);
		itemType = "food";
		itemResult = "Ice Cream";
	};
	["Lays Chips Stall"] = {
		price = 8000;
		size = Vector2.new(12, 12);
		itemType = "food";
		itemResult = "Lays Chips";
	};
	["Ice Pop Stall"] = {
		price = 30000;
		size = Vector2.new(12, 12);
		itemType = "food";
		itemResult = "Ice Pop";
	};
	["Icecream Sandwich Stall"] = {
		price = 90000;
		size = Vector2.new(12, 12);
		itemType = "food";
		itemResult = "Icecream Sandwich";
	};
	["Pizza Stall"] = {
		price = 120000;
		size = Vector2.new(12, 12);
		itemType = "food";
		itemResult = "Pizza";
	};
	["Slushee Stall"] = {
		price = 70000;
		size = Vector2.new(12, 12);
		itemType = "drink";
		itemResult = "Slushee";
	};
	["Burger Stall"] = {
		price = 240000;
		size = Vector2.new(12, 12);
		itemType = "food";
		itemResult = "Burger";
	};

	["Portable Toilet"] = {
		price = 400;
		size = Vector2.new(8, 8);
		itemType = "toilet";
	};

	["Fishbowl"] = {
		price = 50;
		size = Vector2.new(4, 4);
		fishHold = 1;
		itemType = "fish";
	};
	["Clear Tank"] = {
		price = 400;
		size = Vector2.new(8, 8);
		fishHold = 2;
		scaleDecor = 0.5;
		itemType = "fish";
	};
	["Concave Tank"] = {
		price = 600;
		size = Vector2.new(16, 8);
		fishHold = 3;
		scaleDecor = 0.5;
		itemType = "fish";
	};
	["Armoured Tank"] = {
		price = 800;
		size = Vector2.new(8, 12);
		fishHold = 4;
		itemType = "fish";
	};
	["Curve Tank"] = {
		price = 1100;
		size = Vector2.new(12, 8);
		fishHold = 5;
		scaleDecor = 0.2;
		itemType = "fish";
	};
	["Compact Tank"] = {
		price = 1500;
		size = Vector2.new(12, 8);
		fishHold = 6;
		scaleDecor = 0.5;
		itemType = "fish";
	};
	["Elevated Tank"] = {
		price = 3000;
		size = Vector2.new(8, 16);
		fishHold = 7;
		scaleDecor = 0.5;
		itemType = "fish";
	};
	["Round Tank"] = {
		price = 5000;
		size = Vector2.new(8, 8);
		fishHold = 8;
		scaleDecor = 0.5;
		itemType = "fish";
	};
	["Convex Tank"] = {
		price = 8000;
		size = Vector2.new(16, 16);
		fishHold = 9;
		scaleDecor = 0.5;
		itemType = "fish";
	};
	["Clear Top Tank"] = {
		price = 12000;
		size = Vector2.new(12, 12);
		fishHold = 10;
		scaleDecor = 0.5;
		itemType = "fish";
	};
	["Thin Tank"] = {
		price = 20000;
		size = Vector2.new(8, 32);
		fishHold = 11;
		scaleDecor = 0.5;
		itemType = "fish";
	};
	["Large Clear Tank"] = {
		price = 50000;
		size = Vector2.new(16, 20);
		fishHold = 12;
		scaleDecor = 0.7;
		itemType = "fish";
	};
	["Luxurious Tank"] = {
		price = 80000;
		size = Vector2.new(12, 20);
		fishHold = 13;
		itemType = "fish";
	};
	["Semicircular Tank"] = {
		price = 3200000;
		size = Vector2.new(40, 24);
		fishHold = 14;
		scaleDecor = 1;
		itemType = "fish";
	};
	["Long Tank"] = {
		price = 6000000;
		size = Vector2.new(24, 40);
		fishHold = 15;
		scaleDecor = 1;
		itemType = "fish";
	};
	["Circular Tank"] = {
		price = 12000000;
		size = Vector2.new(40, 40);
		fishHold = 20;
		scaleDecor = 1;
		itemType = "fish";
	};

	["VIP Chair"] = {
		price = 25;
		size = Vector2.new(4, 4);
		itemType = "seat";
		reqPass = "VIP";
	};

	["Money Fountain"] = {
		price = 50000;
		size = Vector2.new(12, 12);
		itemType = "fun";
		reqPass = "OP Money Fountain";
	};
}

return module
