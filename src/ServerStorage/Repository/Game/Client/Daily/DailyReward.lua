local module = {}

local Resources = require(game.ReplicatedStorage.Resources)
local DailyRewardList = Resources:LoadLibrary("DailyRewardList")
local Status = Resources:LoadLibrary("Status")
local GameLoop = Resources:LoadLibrary("GameLoop")
local GetSecMinHrFromSec = Resources:LoadLibrary("GetSecMinHrFromSec")
local Player = game.Players.LocalPlayer

local MaxTime = 60 ^ 2 * 12

function module:setup()
    local plot = workspace.Game.PlayerPlots:FindFirstChild(tostring(Status.game.plotNo))
    local gui = Player.PlayerGui.DailyReward -- plot.PlotModels.DailyBoard.Board.SurfaceGui
    gui.Adornee = plot.PlotModels.DailyBoard.Board
    local uiArray = {}
    for _, obj in pairs(gui.Frame:GetChildren()) do
        if not obj:IsA("Frame") then continue end
        uiArray[tonumber(obj.Name)] = obj
    end
    for i = 1, 5 do
        local ui = uiArray[i]
        local reward = DailyRewardList[i]
        ui.Base.Frame.ImageLabel.Image = reward.icon
        ui.Base.Frame.TextLabel.Text = reward.name
    end

    gui.Claim.Base.Frame.MouseButton1Click:Connect(function()
        Resources:GetRemote("ClaimDaily"):FireServer()
    end)
end

function module:updateCollected()
    local uiArray = {}
    local gui = Player.PlayerGui.DailyReward
    for _, obj in pairs(gui.Frame:GetChildren()) do
        if not obj:IsA("Frame") then continue end
        uiArray[tonumber(obj.Name)] = obj
    end
    for i = 1, Status.data.dailyStreak do
        local ui = uiArray[i]
        ui.Base.BackgroundColor3 = Color3.fromRGB(95, 235, 132)
    end
    local timeElap = MaxTime - (os.time() - Status.data.dailyCollected)
    print(timeElap)
    if timeElap <= 0 then
        local ui = uiArray[Status.data.dailyStreak + 1]
        if ui then
            ui.Base.BackgroundColor3 = Color3.fromRGB(255, 255, 127)
        end
    end

    gui.StreakLabel.Text = string.format("Streak:", Status.data.dailyStreak)
end

module.update = GameLoop.new(function()
    if not Status.game.plotNo then return end
    if typeof(Status.data.dailyCollected) ~= "number" then print(Status.data.dailyCollected) return end
	local timeElap = MaxTime - (os.time() - Status.data.dailyCollected)
    -- local plot = workspace.Game.PlayerPlots:FindFirstChild(tostring(Status.game.plotNo))
    local gui = Player.PlayerGui.DailyReward -- plot.PlotModels.DailyBoard.Board.SurfaceGui

	if timeElap > 0 then
		local sec, min, hr = GetSecMinHrFromSec(timeElap)
		gui.TimerLabel.Text = hr .. ":" .. min .. ":" .. sec
	else
		gui.TimerLabel.Text = "READY"
	end
end, 1)

return module