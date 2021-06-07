local Resources = require(game.ReplicatedStorage.Resources)

local module = {
	["build1"] = function()
		Resources:LoadLibrary("BuildLand").updatePlots()
		Resources:LoadLibrary("StatusUi").updateCustomers()
		Resources:LoadLibrary("StatusUi").updateIncome()
		Resources:LoadLibrary("StatusUi").updateSatisfaction()
		Resources:LoadLibrary("TasksUi").updateTasks()
		wait(0.9)
		Resources:LoadLibrary("Status").game.placedDeb = false
		-- print("gone")
	end;
	["money"] = function()
		Resources:LoadLibrary("StatusUi").updateMoney()
		Resources:LoadLibrary("EditorMenuUi").updateSlots()
		Resources:LoadLibrary("FishBuy").updateList()
	end;
	["fish"] = Resources:LoadLibrary("FishBuy").updateList;
	["fishHold"] = function ()
		Resources:LoadLibrary("FishFill").updateList()
		Resources:LoadLibrary("StatusUi").updateIncome()
		Resources:LoadLibrary("StatusUi").updateSatisfaction()
		Resources:LoadLibrary("TasksUi").updateTasks()
	end;
	["hadTutorial"] = Resources:LoadLibrary("TutorialHandler").checkAvailability;
	["tasks"] = Resources:LoadLibrary("TasksUi").updateTasks;
	["dailyStreak"] = Resources:LoadLibrary("DailyReward").updateCollected;
}

function module.__call(_, ...)
	local dataType, val, diff = ...
	if val == nil then return end
	if module[dataType] then module[dataType](nil, val, diff) end
end

return setmetatable({}, module)
