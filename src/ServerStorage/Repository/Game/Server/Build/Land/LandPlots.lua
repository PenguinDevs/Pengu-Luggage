local module = {}

local Resources = require(game.ReplicatedStorage.Resources)
local GameSettings = Resources:LoadLibrary("GameSettings")
local DataStore2 = Resources:LoadLibrary("DataStore2")
local DefaultDS = Resources:LoadLibrary("DefaultDS")
--local TweenModel = Resources:LoadLibrary("TweenModel")
local ServerTween = Resources:LoadLibrary("STweenS")
local RunService = game:GetService("RunService")

local SetGameRemote = Resources:GetRemote("Game")

local Plots = {}

function module:init()
	for _, plotObj in pairs(workspace.Game.Plot:GetChildren()) do
		plotObj.Base.Transparency = 1
	end
	workspace.Models:Destroy()
	local origCollected = {
		[workspace.GamepassBoards.Gamepassboard] = workspace.GamepassBoards;
		[workspace.Boundary] = "ignore";
		--[workspace.Leaderboards.UpdateTimer] = workspace.Leaderboards;
		[workspace.Leaderboards.money] = workspace.Leaderboards;
		[workspace.Leaderboards.timeplayed] = workspace.Leaderboards;
	}
	for i = 1, GameSettings.maxPlayers do
		local grouped = Instance.new("Model", workspace.Game.PlayerPlots)
		local refPart = Instance.new("Part", grouped)
		refPart.Anchored = true
		refPart.Position = Vector3.new(0, 0, 0)
		refPart.Transparency = 1
		refPart.CanCollide = false
		grouped.Name = i
		grouped.PrimaryPart = refPart
		workspace.Game.PlotIsland:Clone().Parent = grouped
		workspace.Game.Visuals:Clone().Parent = grouped
		workspace.Game.Plot:Clone().Parent = grouped
		workspace.Game.Grid:Clone().Parent = grouped
		workspace.Game.Grids:Clone().Parent = grouped
		workspace.Game.PlotModels:Clone().Parent = grouped

		local new = {}
		for obj, toParent in pairs(origCollected) do
			local newObj = obj:Clone()
			newObj.Parent = grouped
			if toParent ~= "ignore" then
				new[newObj] = toParent
			end
		end
		--print(string.format("<b>%s</b>", i))
		grouped.PlotModels.PlotNo.SurfaceGui.TextLabel.Text = string.format("<b>%s</b>", i)
		grouped:SetPrimaryPartCFrame(CFrame.new((i - 1) * 3000, 0, 0))
		
		for obj, toParent in pairs(new) do
			obj.Parent = toParent
		end

		module:abandonPlot(i)
	end
	workspace.Game.PlotIsland:Destroy()
	workspace.Game.Visuals:Destroy()
	workspace.Game.Plot:Destroy()
	workspace.Game.Grid:Destroy()
	workspace.Game.Grids:Destroy()
	workspace.Game.PlotModels:Destroy()
	for obj, _ in pairs(origCollected) do obj:Destroy() end
	workspace.Game.PlayerPlotsLoaded.Value = true

	local grouped = Instance.new("Model", workspace)
	grouped.Name = "TEMPMOVEGROUP"
	workspace.HangoutModels.Parent = grouped
	workspace.Visuals.Parent = grouped
	grouped.PrimaryPart = workspace.TEMPMOVEGROUP.HangoutModels.SPAWNREF
	grouped:SetPrimaryPartCFrame(CFrame.new(0, 0, 10000))
	workspace.TEMPMOVEGROUP.HangoutModels.Parent = workspace
	workspace.TEMPMOVEGROUP.Visuals.Parent = workspace
	grouped:Destroy()
end

function module:updatePlots(plotI, plots)
	for _, plotObj in pairs(workspace.Game.PlayerPlots:FindFirstChild(tostring(plotI)).Plot:GetChildren()) do
		if plots[plotObj.Name] then
			local natureObj = plotObj:FindFirstChild("Nature")
			if natureObj then
				local _, size = natureObj:GetBoundingBox()
				local height = size.Y
				--TweenModel:tweenModel(natureObj, plotObj.PrimaryPart.CFrame * CFrame.new(0, -height, 0), TweenInfo.new(height/30, Enum.EasingStyle.Cubic, Enum.EasingDirection.In)):Play()
				ServerTween:tweenAllClients(natureObj, "modelCF", plotObj.PrimaryPart.CFrame * CFrame.new(0, -height, 0), height/30, Enum.EasingStyle.Cubic, Enum.EasingDirection.In)
				spawn(function()
					wait(height/30 + 1)
					natureObj:SetPrimaryPartCFrame(plotObj.PrimaryPart.CFrame * CFrame.new(0, -height, 0))
				end)
				--natureObj:SetPrimaryPartCFrame(plotObj.PrimaryPart.CFrame * CFrame.new(0, -100, 0))
			end
			if plotObj.Base.Transparency == 0.8 then
				plotObj.Base.Transparency = 1 --0
			end
		else
			local natureObj = plotObj:FindFirstChild("Nature")
			if natureObj then
				--TweenModel:tweenModel(natureObj, plotObj.PrimaryPart.CFrame, TweenInfo.new(1, Enum.EasingStyle.Cubic, Enum.EasingDirection.Out)):Play()
				ServerTween:tweenAllClients(natureObj, "modelCF", plotObj.PrimaryPart.CFrame, 1, Enum.EasingStyle.Cubic, Enum.EasingDirection.Out)
				spawn(function()
					wait(2)
					natureObj:SetPrimaryPartCFrame(plotObj.PrimaryPart.CFrame * CFrame.new(0, 0, 0))
				end)
				--natureObj:SetPrimaryPartCFrame(plotObj.PrimaryPart.CFrame)
			end
			if plotObj.Base.Transparency == 0.8 then
				plotObj.Base.Transparency = 1
			end
		end
	end
end

function module:playerProfileAssign(playerProfile)
	local plotI = 0
	for i = 1, GameSettings.maxPlayers do
		if not Plots[i] then Plots[i] = true plotI = i break end
	end
	local plotProfile = {}
	plotProfile.plotI = plotI
	plotProfile.player = playerProfile
	plotProfile.obj = workspace.Game.PlayerPlots:FindFirstChild(tostring(plotI))
	-- plotProfile.visitors = {}
	-- plotProfile.visiting = nil
	plotProfile.visitingLeaveEvent = nil

	if not RunService:IsStudio() then
		playerProfile.obj.RespawnLocation = plotProfile.obj.PlotModels.PlayerSpawn
	end
	SetGameRemote:FireClient(playerProfile.obj, "plotNo", plotI)
	local build1Store = DataStore2("build1", playerProfile.obj)
	function plotProfile:updatePlots()
		local build1Cache = build1Store:Get(DefaultDS.build1)
		module:updatePlots(plotProfile.plotI, build1Cache.plots)
	end
	function plotProfile:update()
		plotProfile:updatePlots()
	end
	local function updateBuild1(plotNo, data)
		Resources:GetRemote("Game"):FireAllClients(string.format("p%sbuild1", plotNo), data)
	end
	updateBuild1(plotProfile.plotI, build1Store:Get(DefaultDS.build1))
	function plotProfile:disown()
		updateBuild1(plotProfile.plotI, {})
		module:abandonPlot(plotI)
		Plots[plotI] = nil
	end
	playerProfile.leave:Connect(plotProfile.disown)
	
	plotProfile:updatePlots()
	
	return plotProfile
end

function module:abandonPlot(plotI)
	module:updatePlots(plotI, DefaultDS.build1.plots)
end

return module
