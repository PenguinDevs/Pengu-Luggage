local module = {}

module._player = game.Players.LocalPlayer

module._resources = require(game.ReplicatedStorage.Resources)
module._enumeration = module._resources:LoadLibrary("Enumeration")
module._tween = module._resources:LoadLibrary("Tween")
local TutorialHandler = module._resources:LoadLibrary("TutorialHandler")
local Notify = module._resources:LoadLibrary("NotifyHandler")
local Signal = module._resources:LoadLibrary("Signal")
local DeviceType = module._resources:LoadLibrary("DeviceType")

module._resources:LoadLibrary("TutorialHandler").uiShowHide = module
module._resources:LoadLibrary("EditorMenuUi").uiShowHide = module
module._resources:LoadLibrary("FishFill").uiShowHide = module

module.SETTINGS = {}
module.SETTINGS.OPEN_TIME = 0.3
module.SETTINGS.CLOSE_TIME = 0.3

module.tweened = Signal.new()

module.states = {}

module.statesCollected = {}
for _, moduleObj in pairs(script:GetChildren()) do
	module.statesCollected[moduleObj.Name] = require(moduleObj)
end

module.links = {
	["Interface"] = {
		function(state, parentUi)
			if state == "close" then
				(function()
					module:tweenMenu("InterfacePeopleUi", "close", parentUi)
					wait(0.02)
					module:tweenMenu("InterfaceCurrencyUi", "close", parentUi)
					wait(0.02)
					module:tweenMenu("InterfaceBuildUi", "close", parentUi)
					wait(0.02)
					module:tweenMenu("InterfaceFishUi", "close", parentUi)
					wait(0.02)
					module:tweenMenu("InterfaceRight", "close", parentUi)
				end)()
			else 
				(function()
					module:tweenMenu("InterfaceCurrencyUi", "open", parentUi)
					wait(0.02)
					module:tweenMenu("InterfacePeopleUi", "open", parentUi)
					wait(0.02)
					module:tweenMenu("InterfaceBuildUi", "open", parentUi)
					wait(0.02)
					module:tweenMenu("InterfaceFishUi", "open", parentUi)
					wait(0.02)
					module:tweenMenu("InterfaceRight", "open", parentUi)
					wait(0.02)
					module:tweenMenu("TasksListUi", "open", parentUi)
				end)()
			end
		end;
	};
	-- ["InterfaceRight"] = {
	-- 	function(state, parentUi)
	-- 		if state == "close" then
	-- 			(function()
	-- 				module:tweenMenu("InGameRightRadioUi", "close", parentUi)
	-- 				wait(0.02)
	-- 				module:tweenMenu("InGameRightShopUi", "close", parentUi)
	-- 				wait(0.02)
	-- 				module:tweenMenu("InGameRightCodeUi", "close", parentUi)
	-- 				-- wait(0.02)
	-- 				-- module:tweenMenu("InGameRightSettingUi", "close", parentUi)
	-- 			end)()
	-- 		else 
	-- 			(function()
	-- 				module:tweenMenu("InGameRightRadioUi", "open", parentUi)
	-- 				wait(0.02)
	-- 				module:tweenMenu("InGameRightShopUi", "open", parentUi)
	-- 				wait(0.02)
	-- 				module:tweenMenu("InGameRightCodeUi", "open", parentUi)
	-- 				-- wait(0.02)
	-- 				-- module:tweenMenu("InGameRightSettingUi", "open", parentUi)
	-- 			end)()
	-- 		end
	-- 	end;
	-- };
	["BuildUi"] = {
		function(state, parentUi)
			if state == "close" then
				(function()
					module:tweenMenu("BuildExitUi", "close", parentUi)
					wait(0.02)
					module:tweenMenu("BuildItemsUi", "close", parentUi)
					wait(0.02)
					module:tweenMenu("BuildFloorUi", "close", parentUi)
					wait(0.02)
					module:tweenMenu("BuildWallUi", "close", parentUi)
					wait(0.02)
					module:tweenMenu("BuildLandUi", "close", parentUi)
				end)()
			else 
				(function()
					module:tweenMenu("BuildExitUi", "open", parentUi)
					wait(0.02)
					module:tweenMenu("BuildItemsUi", "open", parentUi)
					wait(0.02)
					module:tweenMenu("BuildFloorUi", "open", parentUi)
					wait(0.02)
					module:tweenMenu("BuildWallUi", "open", parentUi)
					wait(0.02)
					module:tweenMenu("BuildLandUi", "open", parentUi)
				end)()
			end
		end;
	};
	["LandUi"] = {
		function(state, parentUi)
			if state == "close" then
				(function()
					module:tweenMenu("LandExitUi", "close", parentUi)
					wait(0.02)
					module:tweenMenu("SharedCurrencyUi", "close", parentUi)
					wait(0.02)
					module:tweenMenu("LandInfoUi", "close", parentUi)
				end)()
			else 
				(function()
					module:tweenMenu("LandExitUi", "open", parentUi)
					wait(0.02)
					module:tweenMenu("SharedCurrencyUi", "open", parentUi)
					wait(0.02)
					module:tweenMenu("LandInfoUi", "open", parentUi)
				end)()
			end
		end;
	};
	-- ["EditorUi"] = {
	-- 	function(state, parentUi)
	-- 		if state == "close" then
	-- 			(function()
	-- 				module:tweenMenu("EditorExitUi", "close", parentUi)
	-- 				wait(0.02)
	-- 				module:tweenMenu("EditorCurrencyUi", "close", parentUi)
	-- 				wait(0.02)
	-- 				module:tweenMenu("EditorSelectingUi", "close", parentUi)
	-- 				wait(0.02)
	-- 				module:tweenMenu("EditorDeleteUi", "close", parentUi)
	-- 				wait(0.02)
	-- 				module:tweenMenu("EditorBaseUi", "close", parentUi)
	-- 				wait(0.02)
	-- 				module:tweenMenu("EditorFilterUi", "close", parentUi)
	-- 			end)()
	-- 		else 
	-- 			(function()
	-- 				module:tweenMenu("EditorBaseUi", "open", parentUi)
	-- 				wait(0.02)
	-- 				module:tweenMenu("EditorExitUi", "open", parentUi)
	-- 				wait(0.02)
	-- 				module:tweenMenu("EditorDeleteUi", "open", parentUi)
	-- 				wait(0.02)
	-- 				module:tweenMenu("EditorCurrencyUi", "open", parentUi)
	-- 				wait(0.02)
	-- 				module:tweenMenu("EditorSelectingUi", "open", parentUi)
	-- 				wait(0.02)
	-- 				module:tweenMenu("EditorFilterUi", "open", parentUi)
	-- 			end)()
	-- 		end
	-- 	end;
	-- };
	["EditorUiWPicker"] = {
		function(state, parentUi)
			if state == "close" then
				(function()
					module:tweenMenu("EditorExitUi", "close", parentUi)
					wait(0.02)
					module:tweenMenu("EditorDeleteUi", "close", parentUi)
					wait(0.02)
					module:tweenMenu("EditorSelectingUi", "close", parentUi)
					wait(0.02)
					module:tweenMenu("EditorCurrencyUi", "close", parentUi)
					-- wait(0.02)
					-- module:tweenMenu("EditorPickerUi", "close", parentUi)
					wait(0.02)
					module:tweenMenu("EditorFilterUi", "close", parentUi)
					wait(0.02)
					module:tweenMenu("EditorBaseUi", "close", parentUi)
				end)()
			else 
				(function()
					module:tweenMenu("EditorBaseUi", "open", parentUi)
					wait(0.02)
					module:tweenMenu("EditorExitUi", "open", parentUi)
					wait(0.02)
					module:tweenMenu("EditorDeleteUi", "open", parentUi)
					wait(0.02)
					module:tweenMenu("EditorSelectingUi", "open", parentUi)
					wait(0.02)
					module:tweenMenu("EditorCurrencyUi", "open", parentUi)
					-- wait(0.02)
					-- module:tweenMenu("EditorPickerUi", "open", parentUi)
					wait(0.02)
					module:tweenMenu("EditorFilterUi", "open", parentUi)
				end)()
			end
		end;
	};
	-- ["EditUi"] = {
	-- 	function(state, parentUi)
	-- 		if state == "close" then
	-- 			(function()
	-- 				module:tweenMenu("EditExitUi", "close", parentUi)
	-- 				wait(0.02)
	-- 				module:tweenMenu("EditSettingsUi", "close", parentUi)
	-- 				wait(0.02)
	-- 				module:tweenMenu("EditFishUi", "close", parentUi)
	-- 				wait(0.02)
	-- 				module:tweenMenu("EditPeopleUi", "close", parentUi)
	-- 				-- wait(0.02)
	-- 				-- module:tweenMenu("EditShopUi", "close", parentUi)
	-- 			end)()
	-- 		else 
	-- 			(function()
	-- 				module:tweenMenu("EditExitUi", "open", parentUi)
	-- 				wait(0.02)
	-- 				module:tweenMenu("EditSettingsUi", "open", parentUi)
	-- 				wait(0.02)
	-- 				module:tweenMenu("EditFishUi", "open", parentUi)
	-- 				wait(0.02)
	-- 				module:tweenMenu("EditPeopleUi", "open", parentUi)
	-- 				-- wait(0.02)
	-- 				-- module:tweenMenu("EditShopUi", "open", parentUi)
	-- 			end)()
	-- 		end
	-- 	end;
	-- };
}

function module:tweenMenu(ui, state, parentUi)
	--if module.states[ui] == state then return end
	if TutorialHandler.doingTutorial and (ui == "Interface" or ui == "TutorialDialogueUi" or ui == "TasksListUi") and not TutorialHandler.allowedUi[state..ui] then
		return
	end
	if not TutorialHandler.allowedUi[state..ui] and TutorialHandler.doingTutorial and not parentUi and ui ~= "TutorialSkipRequestUi" then
		--print(ui, state)
		Notify:addItem("Issue", 3, nil, "Please follow the tutorial! Don't try and mess around 😒")
		print(state .. ui)
		return
	end
	local uiStats
	local deviceType = DeviceType()
	if script:FindFirstChild(deviceType) then
		local stat = require(script[deviceType])[ui]
		uiStats = stat or uiStats
	end
	uiStats = uiStats or require(script["shared"])[ui]
	if not uiStats then
		local link = module.links[ui]
		if not link then
			warn("cannot find", ui, state)
			return
		end
		module.tweened:Fire(parentUi or ui, state)
		module.states[ui] = state
		for _, type in pairs(link) do
			if typeof(type) == "string" then
				module:tweenMenu(type, state, parentUi or ui)
			elseif typeof(type) == "function" then
				--spawn(function()
					type(state, parentUi or ui)
				--end)
			end
		end
		return
	end
	if not uiStats[state] then warn(ui, state, "???", debug.traceback()) return end
	uiStats.obj:TweenPosition(uiStats[state].pos, uiStats[state].direction, uiStats[state].easing, uiStats[state].time, true)
	if not parentUi then
		module.states[ui] = state
	end
end

function module:tweenEverything(state, ignore)
	for ui, uiState in pairs(module.states) do
		if ignore[ui] then continue end
		if state ~= uiState then
			module.tweened:Fire(ui, state)
			module:tweenMenu(ui, state)
			module.states[ui] = state
		end
	end
end

function module:refresh()
	for ui, state in pairs(module.states) do
		module:tweenMenu(ui, state)
	end
end

return module
