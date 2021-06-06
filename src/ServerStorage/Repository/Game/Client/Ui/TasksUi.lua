local module = {}

local Resources = require(game.ReplicatedStorage.Resources)
local Player = game.Players.LocalPlayer
local Status = Resources:LoadLibrary("Status")
local GetUserTasks = Resources:LoadLibrary("GetUserTasks")
local ItemStats = Resources:LoadLibrary("ItemStats")
local FloorStats = Resources:LoadLibrary("FloorStats")
local TextLoader = Resources:LoadLibrary("TextLoader")

local List = {
    ["Place tanks"] = {
        title = "More fish tanks";
        desc = function(goal)
            return string.format("<font color='rgb(0, 127, 255)'>Place %s</font> fish tanks!", goal)
        end;
        get = GetUserTasks.getPlacing;
        getProg = function()
            local count = 0
            for _, floorOwned in pairs(Status.data.build1.floors) do
                local floorStat = FloorStats[floorOwned.floor]
                if floorStat.fishHold then
                    count += 1
                end
            end
            for _, itemOwned in pairs(Status.data.build1.items) do
                local itemStat = ItemStats[itemOwned.item]
                if not itemStat then warn("Cannot get", itemOwned.item, "'s item stat for .fishHold in GetCustomerAmount.lua", ItemStats) continue end
                if itemStat.fishHold then
                    count += 1
                end
            end
            return count
        end;
        short = "tanks";
    };
    ["Fill Fish"] = {
        title = "Adding fish";
        desc = function(goal)
            return string.format("<font color='rgb(0, 127, 255)'>Fill %s</font> fish in tanks!", goal)
        end;
        get = GetUserTasks.getFill;
        getProg = function()
            local count = 0
            for fishHoldIndex, fishHold in pairs(Status.data.fishHold) do
                for fishName, fishAmount in pairs(fishHold) do
                    count += fishAmount
                end
            end
            return count
        end;
        short = "fill";
    };
}

function module:init()
    for uiType, info in pairs(List) do
        local ui = Player.PlayerGui.TasksGui.Frame.Frame.TEMP:Clone()
        ui.Name = uiType
        ui.Parent = Player.PlayerGui.TasksGui.Frame.Frame
        ui.Base.TitleLabel.Text = info.title
        List[uiType].ui = ui
        ui.Visible = true
    end

    module:updateTasks()
end

function module:updateTasks()
    if not List["Place tanks"].ui then return end
    for uiType, info in pairs(List) do
        local level = Status.data.tasks[info.short]

        spawn(function()
            if info.lastLevel ~= level then
                local orig
                if Status.data.settings.dark then
                    orig = Color3.fromRGB(60, 60, 60)
                else
                    orig = Color3.fromRGB(255, 255, 255)
                end
                for i = 1, 4 do
                    info.ui.Base.BackgroundColor3 = Color3.fromRGB(127, 255, 0)
                    wait(0.3)
                    info.ui.Base.BackgroundColor3 = orig
                    wait(0.3)
                end
            end
    
            local endGoal, reward = info.get(level)
            info.ui.Base.TaskLabel.Text = info.desc(endGoal)
            info.ui.Base.RewardLabel.Text = "$" .. TextLoader:ConvertShort(reward)
            info.ui.Base.ProgressLabel.Text = info.getProg() .. "/" .. endGoal
    
            info.lastLevel = level
        end)
    end
end

return module