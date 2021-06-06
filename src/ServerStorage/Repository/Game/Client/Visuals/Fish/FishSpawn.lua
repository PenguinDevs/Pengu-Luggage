local Resources = require(game.ReplicatedStorage.Resources)
local FishAgent = Resources:LoadLibrary("FishAgent")
local BindUiOpenClose = Resources:LoadLibrary("BindUiOpenClose")
local Janitor = Resources:LoadLibrary("Janitor")
local Player = game.Players.LocalPlayer
local FishFill = Resources:LoadLibrary("FishFill")
local Status = Resources:LoadLibrary("Status")

local module = {}

function module:programFish(fishObj, itemObj)
    FishAgent.new(fishObj, itemObj)
end

function module:setupItemFish(itemObj)
    local function setup()
        local function destroyFillEmpty()
            local fillEmpty = itemObj:FindFirstChild("FillEmpty")
            if fillEmpty then
                fillEmpty:Destroy()
            end
        end

        local function createFishFillEmpty()
            if itemObj.Parent.Parent.Name ~= tostring(Status.game.plotNo) then return end

            local val = Instance.new("ObjectValue")
            val.Name = "FillEmpty"
            val.Parent = itemObj

            local gui = Resources:GetVisual("FillEmpty"):Clone()
            gui.Parent = Player.PlayerGui
            gui.Adornee = itemObj.PrimaryPart
            val.Value = gui

            local janitor = Janitor.new()
            janitor:Add(gui, "Destroy")
            janitor:LinkToInstance(val)

            -- gui.Frame.Body.Fill.Base.Frame.MouseButton1Click:Connect(function()
            --     FishFill:changeLastTargetClicked(itemObj)
            --     BindUiOpenClose.binds.FishFill.sigs.open:Fire()
            -- end)
        end

        local function createPromptUi()
            if itemObj.Parent.Parent.Name ~= tostring(Status.game.plotNo) then return end
            
            local prompt = Instance.new("ProximityPrompt")
            prompt.ActionText = "Add fish for money!"
            prompt.ObjectText = "Fill"
            prompt.UIOffset = Vector2.new(150, 175)
            prompt.RequiresLineOfSight = false
            prompt.Triggered:Connect(function()
                FishFill:changeLastTargetClicked(itemObj)
                BindUiOpenClose.binds.FishFill.sigs.open:Fire()
            end)
            prompt.Parent = itemObj.PrimaryPart
        end

        local added = false
        itemObj.FishObjs.ChildAdded:Connect(function(fishObj)
            added = true
            module:programFish(fishObj, itemObj)
            
            destroyFillEmpty()
        end)
        itemObj.FishObjs.ChildRemoved:Connect(function()
            if #itemObj.FishObjs:GetChildren() == 0 then
                added = false
                createFishFillEmpty()
            end
        end)
        for _, fishObj in pairs(itemObj.FishObjs:GetChildren()) do
            added = true
            module:programFish(fishObj, itemObj)
            
            destroyFillEmpty()
        end
        if not added then
            createFishFillEmpty()
        end

        createPromptUi()
    end
    if itemObj:FindFirstChild("FishObjs") then
        setup()
    else
        local listen
        listen = itemObj.ChildAdded:Connect(function(objAdded)
            if objAdded.Name == "FishObjs" then
                setup()
                listen:Disconnect()
            end
        end)
    end
end

function module:setupPlot(plot)
    local function objSetup(obj)
        if obj.Name == "Floors" or obj.Name == "Items" then
            obj.ChildAdded:Connect(function(itemObj)
                module:setupItemFish(itemObj)
            end)
            for _, itemObj in pairs(obj:GetChildren()) do
                module:setupItemFish(itemObj)
            end
        end
    end
    plot.ChildAdded:Connect(function(obj)
        objSetup(obj)
    end)
    for _, obj in pairs(plot:GetChildren()) do
        objSetup(obj)
    end
end

function module:init()
    if not workspace.Game.PlayerPlotsLoaded.Value then
        workspace.Game.PlayerPlotsLoaded.Changed:Wait()
    end
    for _, plotObj in pairs(workspace.Game.PlayerPlots:GetChildren()) do
        module:setupPlot(plotObj)
    end 
end

return module