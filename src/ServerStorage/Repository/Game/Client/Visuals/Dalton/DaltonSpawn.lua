local Resources = require(game.ReplicatedStorage.Resources)
local DaltonExpress = game.ReplicatedStorage:WaitForChild("DaltonExpress")
local Object = require(DaltonExpress:WaitForChild("Daltons"))
local LoadCharacter = Resources:LoadLibrary("LoadCharacter")
local Players = game:GetService("Players")
local Janitor = Resources:LoadLibrary("Janitor")
local Camera = workspace.CurrentCamera
local Signal = Resources:LoadLibrary("Signal")
local Status = Resources:LoadLibrary("Status")

local module = {}

local rand = 0

--module.NPCs = {}

local KillAll = Signal.new()
local Collected = {}

module.ON = false
module.collected = Collected

module.DaltonControl = nil
module.DaltonPlots = {}

function module:loadDalton(rig, spawn, roamingFolder, seatsFolder, itemFolder)
	--if true then return end
	local modPos = Vector3.new(spawn.Position.X, spawn.Position.Y - spawn.Size.Y/2, spawn.Position.Z)
	local Dir = spawn.CFrame.LookVector
	spawn = CFrame.new(modPos, modPos + Dir)

	local Dalton = Object.new(rig, spawn, roamingFolder, seatsFolder, itemFolder)
	--Dalton.Pathfinding.DebugDrawing = true

	--table.insert(module.NPCs, #module.NPCs, Dalton)

	Collected[Dalton.Rig] = {dalton = Dalton, lastCF = Dalton.Rig.HumanoidRootPart.CFrame}
	--spawn(function()
		if module.ON then
			module:loadLogicLoop(Dalton)
		else
			Dalton:Store()
		end
	--end)

	Dalton.Rig.AncestryChanged:Connect(function()
		if not Dalton.Rig:IsDescendantOf(game) then
			--print("removed")
			Collected[Dalton.Rig] = nil
		end
	end)

	return Dalton
end

function module:loadLogicLoop(Dalton)
	local exit = false

	local listen
	listen = KillAll:Connect(function()
		exit = true
		--Collected[Dalton.Rig].lastCF = Dalton.Rig.HumanoidRootPart.CFrame

		Dalton:Store()
		-- Dalton.Rig:SetPrimaryPartCFrame(CFrame.new(0, 0, -10000))
		-- listen:Disconnect()
	end)

	local function trash()
		local finalI
		for i, tempDalton in pairs(module.DaltonPlots[Dalton.plotNo]) do
			if tempDalton == Dalton then
				finalI = i
			end
		end
		--print("trashing dalton for idle", finalI)
		local plotNo = Dalton.plotNo
		module.DaltonControl:storeDalton(plotNo, #module.DaltonPlots[plotNo], #module.DaltonPlots[plotNo] - finalI + 1)
		module.DaltonControl:retrieveDalton(plotNo, Dalton.player)
	end

	local LogicLoop = coroutine.create(function()
		--print("logic awake", Dalton.plotNo)
		-- local debugGui = Resources:GetDebugItem("BillboardGui"):Clone()
		-- debugGui.Parent = Dalton.Rig.Head
		-- Dalton.debugGui = debugGui
		local lastPos = Vector3.new(0, 0, 0)
		local countdown = 10
		while true do
			if exit then break end
			if not Dalton.Visible then listen:Disconnect() break end
			if (Camera.CFrame.p - Dalton.Rig.PrimaryPart.CFrame.p).magnitude > 600 then wait(10) continue end

			local newPos = Dalton.Rig.PrimaryPart.Position
			if (newPos - lastPos).magnitude < 0.1 then
				countdown -= 1
				if countdown < 0 then
					trash()
					return
				end
			else
				countdown = 10
				lastPos = Dalton.Rig.PrimaryPart.Position
			end

			-- local finished = Signal.new()
			-- spawn(function()
			-- 	wait(20)
			-- 	if finished then
			-- 		trash()
			-- 		finished:Fire()
			-- 		finished = nil
			-- 	end
			-- end)
			-- spawn(function()
			-- 	Dalton:Logic()
			-- 	finished:Fire()
			-- end)
			-- finished:Wait()
			-- finished:Destroy()
			-- finished = nil

			-- debugGui.TextLabel.TextColor3 = Color3.fromRGB(math.random(1, 255), math.random(1, 255), math.random(1, 255))
			-- debugGui.TextLabel.Text = "INIT:" .. tick()
			local success, error = pcall(function() Dalton:Logic() end)
			if not success then warn(error) end
			-- debugGui.TextLabel.Text = "END:" .. tick()
			wait(.5)
		end
		--print("logic escaped", Dalton.plotNo)
		-- debugGui:Destroy()
	end)

	coroutine.resume(LogicLoop)
end

function module:toggleDaltons(on)
    if on == module.ON then return end
    module.ON = on
    if module.ON then
        for _, daltonInfo in pairs(Collected) do
			local function spawn()
				--daltonInfo.dalton.Rig:SetPrimaryPartCFrame(daltonInfo.lastCF)

				--print(daltonInfo.lastCF.p, daltonInfo.dalton)
				daltonInfo.dalton:Retrive()
				module:loadLogicLoop(daltonInfo.dalton)
			end
			local plotNo = daltonInfo.dalton.plotNo
			if plotNo then
				if plotNo == Status.game.visiting then
					spawn()
				elseif not Status.game.visiting and plotNo == Status.game.plotNo then
					spawn()
				else
					
				end
			else
				spawn()
			end
        end
    else
        KillAll:Fire()
    end
end

local PlayersFriendList = {}
local initCalled = false
function module:spawnCustomerDalton(player, plotNo)
	--print("called for", player)
	if not player:IsDescendantOf(game) then return end
	--print(PlayersFriendList[player], "foo")
	if not PlayersFriendList[player] then
		PlayersFriendList[player] = {}
		PlayersFriendList[player].janitor = Janitor.new()
		PlayersFriendList[player].searching = true
		PlayersFriendList[player].searchDone = Signal.new()
		PlayersFriendList[player].janitor:Add(PlayersFriendList[player].searchDone, "Destroy")
		local function refresh()
			--print("refreshed")
			PlayersFriendList[player].list = {}
			local friendPages
			local success = pcall(function()
				friendPages = Players:GetFriendsAsync(player.UserId)
			end)
			if not success then return end
			while true do
				for _, item in pairs(friendPages:GetCurrentPage()) do
					table.insert(PlayersFriendList[player].list, 1, item)
				end
				if friendPages.isFinished then break end
				friendPages:AdvanceToNextPageAsync()
			end
			PlayersFriendList[player].savedAvatars = {}
		end
		if not initCalled then
			initCalled = true
			for i = 1, 5 do --while true do
				wait(5)
				refresh()
				print("searching response")
				if #PlayersFriendList[player].list > 0 then break end
			end
		else
			for i = 1, 3 do
				wait(5)
				print("Refresh attempt", i)
				refresh()
				--print(#PlayersFriendList[player].list)
				if #PlayersFriendList[player].list > 0 then break end
			end
		end
		--PlayersFriendList[player].list = {} --REMOVE ME
		--PlayersFriendList[player].savedAvatars = {} --REMOVE ME
		PlayersFriendList[player].searching = false
		PlayersFriendList[player].searchDone:Fire()
		if #PlayersFriendList[player].list <= 0 then
			PlayersFriendList[player].list = {
				{
					Id = "Grandpa";
					Obj = Resources:GetNPC("Visitors").Grandpa;
				};
				{
					Id = "Boy";
					Obj = Resources:GetNPC("Visitors").Boy;
				};
				{
					Id = "Girl";
					Obj = Resources:GetNPC("Visitors").Girl;
				};
			}
			PlayersFriendList[player].savedAvatars = {}
		end
	elseif PlayersFriendList[player] then
		if PlayersFriendList[player].searching then
			PlayersFriendList[player].searchDone:Wait()
		end
	end
	rand += 1
	math.randomseed(tick() + rand)
	local chosenFriend = PlayersFriendList[player].list[math.random(1, #PlayersFriendList[player].list)]
	if not PlayersFriendList[player].savedAvatars[chosenFriend.Id] then
		local rig = chosenFriend.Obj or LoadCharacter(chosenFriend.Id)
		PlayersFriendList[player].savedAvatars[chosenFriend.Id] = rig
		rig.Humanoid.BreakJointsOnDeath = false
		rig.Humanoid:SetStateEnabled(Enum.HumanoidStateType.Dead, true)
		rig.Humanoid:SetStateEnabled(Enum.HumanoidStateType.FallingDown, false)
		rig.Humanoid:SetStateEnabled(Enum.HumanoidStateType.Climbing, false)
		rig.Humanoid:SetStateEnabled(Enum.HumanoidStateType.GettingUp, false)
		rig.Humanoid:SetStateEnabled(Enum.HumanoidStateType.Ragdoll, false)
		rig.Humanoid:SetStateEnabled(Enum.HumanoidStateType.Landed, false)
		rig.Humanoid:SetStateEnabled(Enum.HumanoidStateType.Freefall, false)
		rig.Humanoid:SetStateEnabled(Enum.HumanoidStateType.Seated, false)
		rig.Humanoid:SetStateEnabled(Enum.HumanoidStateType.Swimming, false)
		PlayersFriendList[player].janitor:Add(rig, "Destroy")
		--local animationController = Instance.new("AnimationController", rig)
	end

	local rig = chosenFriend.Obj or PlayersFriendList[player].savedAvatars[chosenFriend.Id]
	local plot = workspace.Game.PlayerPlots[plotNo]
	local spawn = plot.PlotModels.DaltonSpawn
	local roamingFolder = plot:WaitForChild("DaltonRoam")
	local seatsFolder = plot:WaitForChild("DaltonSeats")
	local itemFolder = plot:WaitForChild("Items")
	local Dalton = module:loadDalton(rig, spawn, roamingFolder, seatsFolder, itemFolder)
	Dalton.plotNo = plotNo
	Dalton.player = player

	if module.DaltonPlots[plotNo].rich then
		local particles = Resources:GetParticle("MoneyParticle"):Clone()
		particles.Parent = Dalton.Rig.PrimaryPart
	end

	return Dalton, chosenFriend.Id
end
Players.PlayerRemoving:Connect(function(player)
	if PlayersFriendList[player] then PlayersFriendList[player].janitor:Cleanup() PlayersFriendList[player] = nil end
end)

return module