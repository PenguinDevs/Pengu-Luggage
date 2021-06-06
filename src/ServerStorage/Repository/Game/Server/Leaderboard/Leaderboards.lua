local module = {}

local datastoreService = game:GetService("DataStoreService")
local Resources = require(game.ReplicatedStorage.Resources)
local GameLoop = Resources:LoadLibrary("GameLoop")

module._dataTypesDefVal = Resources:LoadLibrary("LData")._dataTypesDefVal

module._defaultDS = Resources:LoadLibrary("DefaultDS")

module._dataStores = {}

module._playerAmount = 50

module._resources = require(game.ReplicatedStorage.Resources)
module._textLoader = module._resources:LoadLibrary("TextLoader")

module._refreshRate = 60 * 1.5
module._lastUpdated = tick() - module._refreshRate

local runService = game:GetService("RunService")

local playerService = game:GetService("Players")

for dataType, _ in pairs(module._dataTypesDefVal) do
	module._dataStores[dataType] = datastoreService:GetOrderedDataStore("leaderboard" .. module._defaultDS.LEADERBOARD_NO .. dataType .. module._defaultDS.DATA_NO)
end

local function roundDown(n)
	return n - (n) % 1
end

local function roundUp(n)
	return (n - (n) % 1) + 1
end

module.excludePlayers = {
	
}

local function checkAllowed(idToCheck)
	if not runService:IsStudio() and module.excludePlayers[tostring(idToCheck)] then return false end
	return true
end

module.update = GameLoop.new(function()
    if tick() - module._lastUpdated < module._refreshRate then
        for _, obj in pairs(workspace.Leaderboards:GetChildren()) do
            local text = "Leaderboards refreshing in " .. roundDown(module._refreshRate - (tick() - module._lastUpdated)) .. " seconds"
            if obj.Name == "UpdateTimer" then
                obj.TitlePart.SurfaceGui.Frame.TextLabel.Text = text
            else
                local timerLabel = obj.Board.SurfaceGui:FindFirstChild("TimerLabel")
                if timerLabel then
                    timerLabel.Text = text
                end
            end
        end
		return
	else
        for _, obj in pairs(workspace.Leaderboards:GetChildren()) do
            local text = "Updating leaderboards..."
            if obj.Name == "UpdateTimer" then
                obj.TitlePart.SurfaceGui.Frame.TextLabel.Text = text
            else
                local timerLabel = obj.Board.SurfaceGui:FindFirstChild("TimerLabel")
                if timerLabel then
                    timerLabel.Text = text
                end
            end
        end
	end
	module._lastUpdated = tick()
	for dataType, dataStore in pairs(module._dataStores) do
		if not workspace.Leaderboards:FindFirstChild(dataType) then continue end
        local leaderboards = {}
        for _, obj in pairs(workspace.Leaderboards:GetChildren()) do
            if obj.Name == dataType then
                table.insert(leaderboards, 1, obj)
            end
        end
		spawn(function()
			local page = dataStore:GetSortedAsync(false, module._playerAmount)
			
			local accumulatedAmount = 0
			
            for _, leaderboard in pairs(leaderboards) do
			    for _, obj in pairs(leaderboard.Board.SurfaceGui.List.ScrollingFrame:GetChildren()) do if obj:IsA("ImageLabel") then obj:Destroy() end end
			end

			local lowest = 0
			
			while true do
				local data = page:GetCurrentPage()
				for _, entry in pairs(data) do
					if entry["value"] ~= nil and entry["key"] ~= nil then
						if checkAllowed(entry.key) then
							accumulatedAmount += 1
							local name = ""
                            local score = entry.value
							local id = entry.key
							pcall(function()
								name = playerService:GetNameFromUserIdAsync(id) or ""
							end)
                            local pic = ""
                            pcall(function()
                                pic = playerService:GetUserThumbnailAsync(id, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size420x420) or ""
                            end)
							
							if (lowest > 0 and lowest or math.huge) > score then lowest = score end
							
                            for _, leaderboard in pairs(leaderboards) do
                                local ui = accumulatedAmount == 1 and leaderboard.Board.SurfaceGui.List.Top or leaderboard.Board.LeadStat:Clone()
                                ui.Pos.Text = "#" .. accumulatedAmount
                                ui.Amount.Text = module._textLoader:ConvertShort(score)
                                ui.PlrPic.Image = pic
                                name = name or "ERROR - Unable to fetch"
                                ui.PlrName.Text = name
                                
                                if accumulatedAmount ~= 1 then ui.Name = string.rep(".", accumulatedAmount, "") end
                                
                                if dataType == "timeplayed" then
                                    local seconds = score
                                    local minutes = roundDown(score / 60)
                                    local hours = roundDown(score / 3600)
                                    local days = roundDown(score / 86400)
                                    
                                    if days ~= 0 then
                                        ui.Amount.Text = days .. " days"
                                    elseif hours ~= 0 then
                                        ui.Amount.Text = hours .. " hrs"
                                    elseif minutes ~= 0 then
                                        ui.Amount.Text = minutes .. " mins"
                                    elseif seconds ~= 0 then
                                        ui.Amount.Text = seconds .. "s"
                                    end
                                end
                                 
                                if accumulatedAmount == 1 then
                                    --ui.ImageColor3 = Color3.fromRGB(255, 255, 0)
                                elseif accumulatedAmount == 2 then
                                    ui.ImageColor3 = Color3.fromRGB(188, 188, 188)
                                elseif accumulatedAmount == 3 then
                                    ui.ImageColor3 = Color3.fromRGB(163, 99, 10)
                                end
                                
                                if accumulatedAmount ~= 1 then ui.Parent = leaderboard.Board.SurfaceGui.List.ScrollingFrame end
                            end
						end
					end
				end
				if page.IsFinished then
					break
				else
					if accumulatedAmount < module._playerAmount then
						page:AdvanceToNextPageAsync()
					else
						break
					end
				end
			end

			require(script.Parent.LData).lowestVals[dataType] = lowest
		end)
	end
end, 1)

return module
