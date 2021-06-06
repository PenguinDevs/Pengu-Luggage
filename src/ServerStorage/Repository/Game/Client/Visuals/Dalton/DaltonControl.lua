local Resources = require(game.ReplicatedStorage.Resources)
local DaltonSpawn = Resources:LoadLibrary("DaltonSpawn")
local Player = game.Players.LocalPlayer
local UserInputService = game:GetService("UserInputService")
local WorkspaceMouse = Resources:LoadLibrary("WorkspaceMouse")
local Status = Resources:LoadLibrary("Status")
local RunService = game:GetService("RunService")

local module = {}

local DaltonPlots = {}

DaltonSpawn.DaltonControl = module
DaltonSpawn.DaltonPlots = DaltonPlots

function module:retrieveDalton(plotNo, player)
    local Dalton, friendId = DaltonSpawn:spawnCustomerDalton(player, plotNo)
    table.insert(DaltonPlots[plotNo], 1, Dalton)
    local trials = 10
    Dalton.Pathfinding.PathCompletion:Connect(function()
        --print(Dalton.Pathfinding.PathState)
        if Dalton.Pathfinding.PathState == "Failure" then
            trials -= 1
            if trials <= 0 then
                local finalI
                for i, tempDalton in pairs(DaltonPlots[plotNo]) do
                    if tempDalton == Dalton then
                        finalI = i
                    end
                end
                --print("trashing dalton", finalI)
                module:storeDalton(plotNo, #DaltonPlots[plotNo], #DaltonPlots[plotNo] - finalI + 1)
                module:retrieveDalton(plotNo, player)
            end
            --print(trials)
        else
            trials = 10
        end
    end)

    if plotNo == Status.game.visiting then
        
    elseif not Status.game.visiting and plotNo == Status.game.plotNo then

    else
        Dalton:Store()
    end
end

function module:storeDalton(plotNo, oldAmount, i)
    i -= 1
    local Dalton = DaltonPlots[plotNo][oldAmount - i]
    --print("DELETING", Dalton)
    --Dalton:SetActive(false)
    --print(DaltonPlots[plotNo], oldAmount - i)
    if Dalton.StoredSeat then
        print("was sitting", Dalton.StoredSeat)
        Dalton.StoredSeat.Owner.Value = nil
    end
    Dalton.Visible = false
    Dalton:Destroy()
    --Dalton:Store()
    table.remove(DaltonPlots[plotNo], oldAmount - i)
end

function module:updateDaltons(newAmount, plotNo, player)
    newAmount = math.clamp(newAmount, 0, 20)
    --if true then return end
    if not DaltonPlots[plotNo] then DaltonPlots[plotNo] = {} end
    if DaltonPlots[plotNo].updating then return end
    DaltonPlots[plotNo].updating = true
    local oldAmount = #DaltonPlots[plotNo]

    if oldAmount > newAmount then
        for i = 1, oldAmount - newAmount do
            module:storeDalton(plotNo, oldAmount, i)
        end
    elseif oldAmount < newAmount then
        for i = 1, newAmount - oldAmount do
            module:retrieveDalton(plotNo, player)
        end
    end
    DaltonPlots[plotNo].updating = false
end

Resources:GetRemote("UpdateDaltons").OnClientEvent:Connect(function(Player, plotNo, customerAmount)
    module:updateDaltons(customerAmount, plotNo, Player)
    --module:updateDaltons(1, plotNo, Player)
end)

function module:init()
    local getDaltonInfos = Resources:GetRemote("GetDaltons")
    local list = getDaltonInfos:InvokeServer()
    for _, info in pairs(list) do
        spawn(function()
            module:updateDaltons(info.amount, info.plotNo, info.player)
            if info.rich then
                DaltonPlots[info.plotNo].rich = true
            else
                DaltonPlots[info.plotNo].rich = nil
            end
            --module:updateDaltons(1, info.plotNo, info.player)
        end)
    end
end

function module:refreshDaltons()
    for plotNo, daltons in pairs(DaltonPlots) do
        if plotNo == Status.game.visiting then
            --print("loading visiting daltons", plotNo)
            for _, Dalton in pairs(daltons) do
                if type(Dalton) == "table" then
                    if Dalton.Retrive then
                        if Status.data.settings["npc"] then
                            Dalton:Retrive()
                            DaltonSpawn:loadLogicLoop(Dalton)
                        end
                    end
                end
            end
        elseif not Status.game.visiting and plotNo == Status.game.plotNo then
            --print("loading home daltons", plotNo)
            for _, Dalton in pairs(daltons) do
                if type(Dalton) == "table" then
                    if Dalton.Retrive then
                        if Status.data.settings["npc"] then
                            Dalton:Retrive()
                            DaltonSpawn:loadLogicLoop(Dalton)
                        end
                    end
                end
            end
        else
            --print("hiding other daltons", plotNo)
            for _, Dalton in pairs(daltons) do
                if type(Dalton) == "table" then
                    if Dalton.Store then
                        Dalton:Store()
                    end
                end 
            end
        end
    end
end
module:refreshDaltons()





local SelectSelectionObj = Instance.new("SelectionBox", workspace)
SelectSelectionObj.SurfaceTransparency = 0.5
SelectSelectionObj.Transparency = 0.5
SelectSelectionObj.Color3 = Color3.fromRGB(253, 202, 36)
SelectSelectionObj.SurfaceColor3 = Color3.fromRGB(253, 202, 36)

local lastSelect
local lastStepped
UserInputService.InputChanged:Connect(function()
    local raycastP = RaycastParams.new()
	raycastP.FilterType = Enum.RaycastFilterType.Whitelist
	raycastP.FilterDescendantsInstances = {workspace.DaltonExpress}
	local target = WorkspaceMouse:getTarget(300, raycastP)
    local function removeLastSelect()
        if lastSelect then
            local billboard = lastSelect:FindFirstChild("OverheadDialogue")
            if billboard then
                billboard.Stats.Visible = false
            end
            SelectSelectionObj.Adornee = nil
        end
        lastSelect = nil
        if lastStepped then
            lastStepped:Disconnect()
            lastStepped = nil
        end
    end
    if not target then removeLastSelect() return end
    local character = target:FindFirstAncestorWhichIsA("Model")
    if not character:FindFirstChild("Humanoid") then removeLastSelect() return end
    if character ~= lastSelect then
        removeLastSelect()
        lastSelect = character
        SelectSelectionObj.Adornee = character
        local billboard = lastSelect:FindFirstChild("OverheadDialogue")
        if billboard then
            billboard.Stats.Visible = true
        end
        lastStepped = RunService.RenderStepped:Connect(function()
            local daltonInfo = DaltonSpawn.collected[character]
            if daltonInfo then
                daltonInfo.dalton:UpdateNeedDisplay()
            else
                lastStepped:Disconnect()
                lastStepped = nil
                return
            end
        end)
    end
end)

return module