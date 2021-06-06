local bindEvents = require(script.Binds)

local ocBind = {}
ocBind.__call = function(t, ...)
	local OCs = ...
	
--	table.foreachi(OCs, print)
	
	for uiName, OCBinds in pairs(bindEvents) do
		if OCs.paths[uiName] then
			local uiObj = OCs.paths[uiName]
			for _, openEvent in pairs(OCBinds.open) do openEvent:Connect(function()
				if OCBinds.check then if not OCBinds.check() then return end end
				uiObj:open()
			end) end
			for _, closeEvent in pairs(OCBinds.close) do closeEvent:Connect(function() uiObj:close() end) end
			for _, toggleEvent in pairs(OCBinds.toggle) do toggleEvent:Connect(function() uiObj:toggle() end) end
		end
	end
	
	return
end
local t1 = {}
t1.binds = bindEvents

local meta = setmetatable(t1, ocBind)

return meta
