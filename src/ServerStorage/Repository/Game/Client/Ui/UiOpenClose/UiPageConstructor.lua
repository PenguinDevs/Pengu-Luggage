local OCTweener = require(script.Parent.OpenCloseTweener)

--local blur = require(script:FindFirstAncestor("Client").Effects.Blur)

local pageConstructor = {}
pageConstructor.__index = pageConstructor

local Resources = require(game.ReplicatedStorage.Resources)
local TutorialHandler = Resources:LoadLibrary("TutorialHandler")
local RunService = game:GetService("RunService")
local Notify = Resources:LoadLibrary("NotifyHandler")

pageConstructor._uiShowHide = Resources:LoadLibrary("UiShowHide")

function pageConstructor.new(ui)
	local functions = {}
	
	ui._shown = false
	
	function functions:open(ignoreBlur, DcloseOthers)
		--print(TutorialHandler.allowedUi, "open"..ui.uiName)
		if ui.uiName == "FrostyDory" and TutorialHandler.doingTutorial then return end
		if not TutorialHandler.allowedUi["open"..ui.uiName] and not ui.uiName == "FrostyDory" and TutorialHandler.doingTutorial then
			--print(ui.uiName)
			Notify:addItem("Issue", 3, nil, "Please follow the tutorial! Don't try and mess around 😒")
			print("open" .. ui.uiName)
			return
		end
		DcloseOthers = ui.ignoreRest or DcloseOthers
		script.Parent.OC:Fire("open", ui.uiName, DcloseOthers)
		OCTweener:open(ui.obj, ui)
		if not ui.ignoreUi then
			RunService.RenderStepped:Wait()
			wait(0.25)
			pageConstructor._uiShowHide:tweenEverything("close", {["InterfaceHomeUi"] = true})
		end
		ignoreBlur = ignoreBlur or ui.ignoreBlur
		--if not ignoreBlur then blur:blurDefault() end
		ui._shown = true
		if ui.openCall then ui.openCall() end
	end
	
	function functions:close(ignoreBlur, closingOthers)
		--if ui.uiName == "FrostyDory" and TutorialHandler.doingTutorial then return end
		if not TutorialHandler.allowedUi["close"..ui.uiName] and not ui.uiName == "FrostyDory" and TutorialHandler.doingTutorial then
			Notify:addItem("Issue", 3, nil, "Please follow the tutorial! Don't try and mess around 😒")
			print("close" .. ui.uiName)
			return
		end
		--if not dataHandler.settings["UiBlur"] then ignoreBlur = true end
		script.Parent.OC:Fire("close", ui.uiName, ui.ignoreRest)
		if ui.ignoreRest and closingOthers then return end
		OCTweener:close(ui.obj, ui)
		pageConstructor._uiShowHide:tweenMenu("Interface", "open")
		ignoreBlur = ui.ignoreRest or ignoreBlur
		--if not ignoreBlur then blur:returnBlur() end
		ui._shown = false
		if ui.closeCall then ui.closeCall() end
	end
	
	function functions:toggle()
		if not ui._shown then
			self:open(false)
		elseif ui._shown then
			self:close(false)
		end
	end
	
	return functions
end

return pageConstructor
