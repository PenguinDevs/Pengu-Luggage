local heirachyParent = script

return function(DEBUG)
	local paths = {
		FishBuy = require(heirachyParent.FishBuy).new(DEBUG);
		FishFill = require(heirachyParent.FishFill).new(DEBUG);
		Players = require(heirachyParent.Players).new(DEBUG);
		Codes = require(heirachyParent.Codes).new(DEBUG);
		Shop = require(heirachyParent.Shop).new(DEBUG);
		Settings = require(heirachyParent.Settings).new(DEBUG);
		Radio = require(heirachyParent.Radio).new(DEBUG);
		Stats = require(heirachyParent.Stats).new(DEBUG);
		FrostyDory = require(heirachyParent.FrostyDory).new(DEBUG);
	}
		
	return paths
end