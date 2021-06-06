local module = {}

local Resources = require(game.ReplicatedStorage.Resources)
local GetCustomerSatisfaction = Resources:LoadLibrary("GetCustomerSatisfaction")
local ItemTypes = Resources:LoadLibrary("ItemTypes")
local Round = Resources:LoadLibrary("Round")
local DataStore2 = Resources:LoadLibrary("DataStore2")
local DefaultDS = Resources:LoadLibrary("DefaultDS")

local NeedsList = {
    "drink";
    "food";
    "toilet";
    "fun";
    "seat";
    "fish";
}

function module:playerProfileAssign(playerProfile)
    local returner = {}

    local gui = playerProfile.landPlots.obj.PlotModels.PlotStat.Board.SurfaceGui

	for _, itemType in pairs(NeedsList) do
		local itemTypeStat = ItemTypes[string.lower(itemType)]
		local frame = gui.Body[itemType]
		frame.ImageLabel.Image = itemTypeStat.image
		frame.ImageLabel.ImageColor3 = itemTypeStat.colour
		frame.BarBase.Bar.Base.BackgroundColor3 = itemTypeStat.colour
	end

    function returner:update()
        local build1Store = DataStore2("build1", playerProfile.obj)
        local build1Cache = build1Store:Get(DefaultDS.build1)
        local fishHoldStore = DataStore2("fishHold", playerProfile.obj)
        local fishHoldCache = fishHoldStore:Get(DefaultDS.fishHold)
        local satisfaction, recommendation = GetCustomerSatisfaction(build1Cache, fishHoldCache, true)
        for _, itemType in pairs(NeedsList) do
            local frame = gui.Body[itemType]

            local amount
            for _, need in pairs(recommendation) do
                if need.name == itemType then
                    amount = need.satisfaction
                    break
                end
            end

            frame.BarBase.Bar.Size = UDim2.fromScale(amount, 1)
            frame.BarBase.TextLabel.Text = Round(amount * 100) .. "%"

            gui.Satisfaction.Text = Round(satisfaction * 100) .. "%"
        end
    end
    returner:update()

    playerProfile.leave:Connect(function()
        for _, itemType in pairs(NeedsList) do
            local frame = gui.Body[itemType]

            frame.BarBase.Bar.Size = UDim2.fromScale(1, 1)
            frame.BarBase.TextLabel.Text = "..."

            gui.Satisfaction.Text = "..."
        end
    end)

    return returner
end

return module