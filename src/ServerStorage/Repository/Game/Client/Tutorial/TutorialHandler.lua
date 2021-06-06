local module = {}

local Resources = require(game.ReplicatedStorage.Resources)
local Signal = Resources:LoadLibrary("Signal")
local Status = Resources:LoadLibrary("Status")
local Player = game.Players.LocalPlayer
local UserInputService = game:GetService("UserInputService")
local Janitor = Resources:LoadLibrary("Janitor")
local RunService = game:GetService("RunService")
local Tween = Resources:LoadLibrary("Tween")
local Enumeration = Resources:LoadLibrary("Enumeration")
local GoToArrows = Resources:LoadLibrary("GoToArrows")
local BindUiOpenClose = Resources:LoadLibrary("BindUiOpenClose")

local InOutSine = Enumeration.EasingFunction.InOutSine.Value

local nextSignal = Signal.new()
-- local userClicked = Signal.new()
local tutJanitor

module.doingTutorial = false
module.allowedUi = {
    ["openInterface"] = true;
    ["openTutorialDialogueUi"] = true;
}

module.uiShowHide = nil

local currentStep = 0

local currentFloor

local topArrow = Player.PlayerGui.Tutorial.TopArrow
local sideArrow = Player.PlayerGui.Tutorial.SideArrow
local arrowObj = Resources:GetVisual("Arrow"):Clone()
arrowObj.Parent = workspace

local texts = {
    click = "<font color='rgb(255, 85, 127)'>PRESS HERE</font> TO CONTINUE!";
    green = "<font color='rgb(255, 85, 127)'>FOLLOW THE GREEN ARROWS</font> TO CONTINUE!";
    ui = "<font color='rgb(255, 85, 127)'>PRESS THE BUTTON HIGHLIGHTED</font> TO CONTINUE!"
}

local fishbowlPlaced

local function loadArrowObj(arrowObj, initCF)
    arrowObj:SetPrimaryPartCFrame(initCF)
    local offset = Vector3.new(0, 1, 0)
    local returner = {}
    returner.on = true
    spawn(function()
        local origPos = arrowObj.PrimaryPart.CFrame
        local tween1 = Tween.new(2, InOutSine, function(amount)
            arrowObj:SetPrimaryPartCFrame(CFrame.new(origPos * (offset * amount)))
        end) --Tween(arrowObj, "Position", origPos * offset, InOutSine, 1, true)
        tween1:Wait()
        local tween2 = Tween.new(2, InOutSine, function(amount)
            arrowObj:SetPrimaryPartCFrame(CFrame.new(origPos * offset - (offset * amount)))
        end)--Tween(arrowObj, "Position", origPos, InOutSine, 1, true)
        tween2:Wait()
        while true do
            if not module.doingTutorial or not returner.on then arrowObj:Destroy() break end
            tween1:Restart()
            tween1:Wait()
            tween2:Restart()
            tween2:Wait()
            wait()
        end
    end)
    return returner
end

module.steps = {
    {
        dialogue = "Hi, I'm <font color='rgb(0, 170, 255)'>PenguinDevs</font> and welcome to <font color='rgb(0, 170, 255)'>Aquarium Tycoon</font>!";
        doText = texts.click;
        func = "click";
    };
    {
        dialogue = "Let's begin by following the <font color='rgb(95, 235, 132)'>green arrows</font> to your aquarium!";
        doText = texts.green;
        func = function()
            local plot = workspace.Game.PlayerPlots:FindFirstChild(tostring(Status.game.plotNo)).Plot
            Player.Character:SetPrimaryPartCFrame(plot.Parent.PlotModels.PlayerSpawn.CFrame * CFrame.new(0, 4, 0))
            spawn(function()
                local arrows = GoToArrows(plot.Parent.PlotModels.Tutorial.GoToPlot.Position)
                while true do
                    wait(1)
                    if currentFloor or not module.doingTutorial then
                        nextSignal:Fire()
                        arrows:Destroy()
                        break
                    end
                end
            end)
        end;
    };
    -- {
    --     dialogue = "Go to the edit menu by clicking the <font color='rgb(95, 235, 132)'>edit button</font> below to see what you can do!";
    --     doText = texts.ui;
    --     func = function()
    --         local ui = Player.PlayerGui.InGame.Frame.Edit.Base.Frame
    --         loadArrow(ui, topArrow)
    --         module.allowedUi = {["openEditUi"] = true; ["closeInterface"] = true;}
    --         ui.MouseButton1Click:Wait()
    --         loadArrow()
    --         nextSignal:Fire()
    --     end;
    -- };
    {
        dialogue = "Click the <font color='rgb(95, 235, 132)'>build button</font> below!";
        doText = texts.ui;
        func = function()
            local ui = Player.PlayerGui.InGame.Frame.Build.Base.Frame
            loadArrow(ui, topArrow)
            module.allowedUi = {["openBuildUi"] = true; ["closeInterface"] = true;}
            ui.MouseButton1Click:Wait()
            loadArrow()
            nextSignal:Fire()
        end;
    };
    {
        dialogue = "Click the <font color='rgb(95, 235, 132)'>items button</font> below!";
        doText = texts.ui;
        func = function()
            local ui = Player.PlayerGui.Build.Frame.Items.Base.Frame
            loadArrow(ui, topArrow)
            module.allowedUi = {["openBuildUi"] = true; ["openItemsUi"] = true; ["openEditorUiWPicker"] = true; ["closeBuildUi"] = true; ["closeEditorBaseHideUi"] = true; ["closeEditorFilterUi"] = true; ["openEditorRotateUi"] = true; ["openEditorPlaceUi"] = true; ["openEditorAmountLabelUi"] = true; ["openEditorCancelUi"] = true; ["openEditorControlsUi"] = true;}
            ui.MouseButton1Click:Wait()
            loadArrow()
            nextSignal:Fire()
        end;
    };
    {
        dialogue = "Click the <font color='rgb(95, 235, 132)'>fishbowl item</font> below highlighted in green!";
        doText = texts.ui;
        func = function()
            local ui
            while true do
                if ui then break end
                wait(1)
                for _, uiObj in pairs(Player.PlayerGui.Editor.Frame.List.Menu:GetChildren()) do
                    if not uiObj:IsA("GuiObject") then continue end
                    if uiObj.Base.View:FindFirstChildOfClass("Model").Name == "Fishbowl" then
                        ui = uiObj
                        break
                    end
                end
            end
            loadArrow(ui, topArrow)
            module.allowedUi = {["closeDeleteNotifyUi"] = true; ["closeEditorBaseHideUi"] = true; ["closeEditorFilterUi"] = true; ["openEditorRotateUi"] = true; ["openEditorPlaceUi"] = true; ["openEditorMoneyAmountUi"] = true; ["openEditorCancelUi"] = true;}
            ui.MouseButton1Click:Wait()
            loadArrow()
            nextSignal:Fire()
        end;
    };
    {
        dialogue = "<font color='rgb(95, 235, 132)'>Place</font> the fishbowl anywhere you want to!";
        doText = "<font color='rgb(255, 85, 127)'>PLACE FISHBOWL</font> TO CONTINUE";
        func = function()
            module.allowedUi = {["closeDeleteNotifyUi"] = true; ["closeEditorBaseHideUi"] = true; ["closeEditorFilterUi"] = true; ["openEditorRotateUi"] = true; ["openEditorPlaceUi"] = true; ["openEditorMoneyAmountUi"] = true; ["openEditorCancelUi"] = true;}

            loadArrow(Player.PlayerGui.Editor.Place.Base , topArrow)

            local plot = workspace.Game.PlayerPlots:FindFirstChild(tostring(Status.game.plotNo)).Plot
            for _, obj in pairs(plot.Parent.Items:GetChildren()) do
                if obj:FindFirstChild("FishHold") then
                    fishbowlPlaced = obj
                    nextSignal:Fire()
                    return
                end
            end
            local event
            event = plot.Parent.Items.ChildAdded:Connect(function(itemObj)
                if itemObj:WaitForChild("FishHold") then
                    event:Disconnect()
                    fishbowlPlaced = itemObj
                    nextSignal:Fire()
                end
            end)
        end;
    };
    -- {
    --     dialogue = "Excellent! The <font color='rgb(0, 170, 255)'>more fishbowls</font> <font color='rgb(255, 170, 127)'>=</font> <font color='rgb(0, 170, 255)'>attracts more customers</font>.";
    --     doText = texts.click;
    --     func = "click";
    -- };
    {
        dialogue = "Now let's add a <font color='rgb(0, 170, 255)'>fish</font> in the fishbowl.";
        doText = texts.click;
        func = "click";
    };
    {
        dialogue = "On your <font color='rgb(95, 235, 132)'>new fishbowl</font> and click the <font color='rgb(95, 235, 132)'>Fill button</font> to begin adding fish!";
        doText = "<font color='rgb(255, 85, 127)'>HOVER OVER YOUR NEW FISHBOWL AND CLICK FILL</font> TO CONTINUE";
        func = function()
            local arrows = GoToArrows(fishbowlPlaced.PrimaryPart.Position)

            local ui = Player.PlayerGui.ItemTankGui.Frame.Body.Fill.Base.Frame
            -- local ui2 = fishbowlPlaced:WaitForChild("FillEmpty").Value.Frame.Body.Fill.Base.Frame
            ui.TextLabel.Text = "FILL"
            local arrowObjLoaded = loadArrowObj(arrowObj, fishbowlPlaced.PrimaryPart.CFrame * CFrame.new(0, 8, 0))
            loadArrow(ui, sideArrow)
            -- spawn(function()
            --     loadArrow(ui2, topArrow)
            -- end)
            module.allowedUi = {["closeEditorFilterUi"] = true, ["openEditorMoneyAmountUi"] = true, ["closeEditorUiWPicker"] = true, ["openFishFill"] = true, ["closeEditorRotateUi"] = true, ["closeEditorPlaceUi"] = true, ["closeEditorMoneyAmountUi"] = true, ["closeEditorCancelUi"] = true; ["closeEditorDeleteUi"] = true; ["closeEditorControlsUi"] = true; ["closeDeleteNotifyUi"] = true;  ["closeEditorBaseHideUi"] = true; ["closeEditorDeleteUi2"] = true; ["openEditorRotateUi"] = true; ["openEditorPlaceUi"] = true; ["openEditorCancelUi"] = true;}
            local waitEvent = Signal.new()
            
            local ev1
            local ev2
            ev1 = ui.MouseButton1Click:Connect(function()
                waitEvent:Fire()
                waitEvent:Destroy()
                ev1:Disconnect()
            end)
            -- ev2 = ui2.MouseButton1Click:Connect(function()
            --     waitEvent:Fire()
            --     waitEvent:Destroy()
            --     ev2:Disconnect()
            -- end)

            waitEvent:Wait()
            ui.TextLabel.Text = "FILL (E)"
            --module.uiShowHide.tweened:Wait()
            loadArrow()
            arrowObjLoaded.on = false
            arrows:Destroy()
            nextSignal:Fire()
        end;
    };
    {
        dialogue = "Click the <font color='rgb(95, 235, 132)'>add button</font> to add a carp to the tank!";
        doText = texts.ui;
        func = function()
            local ui
            while true do
                wait(0.5)
                if ui then break end
                for _, uiObj in pairs(Player.PlayerGui.FishFillMenu.Frame.Body.ScrollingFrame:GetChildren()) do
                    print("Tutorial search, fill fish:", uiObj)
                    if uiObj:IsA("Frame") and uiObj.Name ~= "TEMP" and uiObj.Name == "Carp" then
                        ui = uiObj:WaitForChild("Base"):WaitForChild("Add"):WaitForChild("Base"):WaitForChild("Frame")
                        break
                    end
                end
            end
            Player.PlayerGui.Tutorial.Circle.Visible = true
            local stepped
            stepped = RunService.RenderStepped:Connect(function()
                Player.PlayerGui.Tutorial.Circle.Position = UDim2.fromOffset(ui.AbsolutePosition.X, ui.AbsolutePosition.Y)
            end)

            loadArrow(ui, sideArrow)
            module.allowedUi = {}
            ui.MouseButton1Click:Wait()
            loadArrow()
            nextSignal:Fire()
            Player.PlayerGui.Tutorial.Circle.Visible = false
            stepped:Disconnect()
        end;
    };
    {
        dialogue = "You can also remove fish later by clicking the remove button with a better fish.";
        doText = texts.click;
        func = "click";
    };
    {
        dialogue = "Let's see the fishes that we can buy by clicking on the <font color='rgb(95, 235, 132)'>Fish button</font> below!";
        doText = texts.ui;
        func = function()
            local ui = Player.PlayerGui.FishFillMenu.Frame.Footer.Fish.Base.Frame
            loadArrow(ui, topArrow)
            module.allowedUi = {["closeFishFill"] = true, ["openFishBuy"] = true}
            ui.MouseButton1Click:Wait()
            loadArrow()
            nextSignal:Fire()
        end;
    };
    {
        dialogue = "Here, we can buy fish anytime!";
        doText = texts.click;
        func = "click";
    };
    -- {
    --     dialogue = "Just remember to put them in your tanks when you do otherwise there's no use!";
    --     doText = texts.click;
    --     func = "click";
    -- };
    -- {
    --     dialogue = "<font color='rgb(0, 170, 255)'>Remember, more fish means more money earnt every minute</font>";
    --     doText = texts.click;
    --     func = "click";
    -- };
    {
        dialogue = "Let's close out of this by clicking the <font color='rgb(95, 235, 132)'>Exit button</font>!";
        doText = texts.ui;
        func = function()
            local ui = Player.PlayerGui.FishMenu.Frame.Header.Exit.Frame
            loadArrow(ui, sideArrow)
            module.allowedUi = {["closeFishBuy"] = true, ["openInterface"] = true}
            ui.MouseButton1Click:Wait()
            loadArrow()
            nextSignal:Fire()
        end;
    };
    -- {
    --     dialogue = "Oh yes and also, one more thing!";
    --     doText = texts.click;
    --     func = "click";
    -- };
    {
        dialogue = "Hover over the customers tab that is <font color='rgb(95, 235, 132)'>below, highlighted in red</font>!";
        doText = texts.ui;
        func = function()
            local ui = Player.PlayerGui.InGame.Frame.Currency.People.HoverButton
            loadArrow(ui, sideArrow)
            module.allowedUi = {["openInterface"] = true, ["openInterfaceNeedsUi"] = true, ["closeInterfaceNeedsUi"] = true}
            ui.MouseEnter:Wait()
            loadArrow()
            nextSignal:Fire()
        end;
    };
    {
        dialogue = "It shows how <font color='rgb(95, 235, 132)'>happy your customers are</font>!";
        doText = texts.click;
        func = "click";
    };
    {
        dialogue = "<font color='rgb(95, 235, 132)'>Keep your customers happy</font> by doing the tasks in that tab!";
        doText = texts.click;
        func = "click";
    };
    -- {
    --     dialogue = "Keep in mind, <font color='rgb(0, 170, 255)'>Happy customers</font> <font color='rgb(255, 170, 127)'>=</font> <font color='rgb(0, 170, 255)'>More tip</font> from customers every one minute and a half!";
    --     doText = texts.click;
    --     func = "click";
    -- };
    {
        dialogue = "That's it for now! Cya!";
        doText = texts.click;
        func = "click";
    };
}

module.basicSteps = {
    {
        -- dialogue = "Click the <font color='rgb(95, 235, 132)'>build button</font> below!";
        -- doText = texts.ui;
        func = function()
            local ui = Player.PlayerGui.InGame.Frame.Build.Base.Frame
            loadArrow(ui, topArrow)
            module.allowedUi = {["openBuildUi"] = true; ["closeInterface"] = true;}
            ui.MouseButton1Click:Wait()
            loadArrow()
            print("fire")
            nextSignal:Fire()
        end;
    };
    {
        -- dialogue = "Click the <font color='rgb(95, 235, 132)'>items button</font> below!";
        -- doText = texts.ui;
        func = function()
            local ui = Player.PlayerGui.Build.Frame.Items.Base.Frame
            loadArrow(ui, topArrow)
            module.allowedUi = {["openBuildUi"] = true; ["openItemsUi"] = true; ["openEditorUiWPicker"] = true; ["closeBuildUi"] = true; ["closeEditorBaseHideUi"] = true; ["closeEditorFilterUi"] = true; ["openEditorRotateUi"] = true; ["openEditorPlaceUi"] = true; ["openEditorAmountLabelUi"] = true; ["openEditorCancelUi"] = true; ["openEditorControlsUi"] = true;}
            ui.MouseButton1Click:Wait()
            loadArrow()
            nextSignal:Fire()
        end;
    };
    {
        -- dialogue = "Click the <font color='rgb(95, 235, 132)'>fishbowl item</font> below highlighted in green!";
        -- doText = texts.ui;
        func = function()
            local ui
            while true do
                if ui then break end
                wait(1)
                for _, uiObj in pairs(Player.PlayerGui.Editor.Frame.List.Menu:GetChildren()) do
                    if not uiObj:IsA("GuiObject") then continue end
                    if uiObj.Base.View:FindFirstChildOfClass("Model").Name == "Fishbowl" then
                        ui = uiObj
                        break
                    end
                end
            end
            loadArrow(ui, topArrow)
            module.allowedUi = {["closeDeleteNotifyUi"] = true; ["closeEditorBaseHideUi"] = true; ["closeEditorFilterUi"] = true; ["openEditorRotateUi"] = true; ["openEditorPlaceUi"] = true; ["openEditorMoneyAmountUi"] = true; ["openEditorCancelUi"] = true;}
            ui.MouseButton1Click:Wait()
            loadArrow()
            nextSignal:Fire()
        end;
    };
    {
        -- dialogue = "<font color='rgb(95, 235, 132)'>Place</font> the fishbowl anywhere you want to!";
        -- doText = "<font color='rgb(255, 85, 127)'>PLACE FISHBOWL</font> TO CONTINUE";
        func = function()
            module.allowedUi = {["closeDeleteNotifyUi"] = true; ["closeEditorBaseHideUi"] = true; ["closeEditorFilterUi"] = true; ["openEditorRotateUi"] = true; ["openEditorPlaceUi"] = true; ["openEditorMoneyAmountUi"] = true; ["openEditorCancelUi"] = true;}

            loadArrow(Player.PlayerGui.Editor.Place.Base , topArrow)

            local plot = workspace.Game.PlayerPlots:FindFirstChild(tostring(Status.game.plotNo)).Plot
            for _, obj in pairs(plot.Parent.Items:GetChildren()) do
                if obj:FindFirstChild("FishHold") then
                    fishbowlPlaced = obj
                    nextSignal:Fire()
                    return
                end
            end
            local event
            event = plot.Parent.Items.ChildAdded:Connect(function(itemObj)
                if itemObj:WaitForChild("FishHold") then
                    event:Disconnect()
                    fishbowlPlaced = itemObj
                    nextSignal:Fire()
                end
            end)
        end;
    };
}

function loadArrow(ui, arrowObj, ignoreGreen)
    if not ui or not arrowObj then
        topArrow.Visible = false
        topArrow.Parent = Player.PlayerGui.Tutorial
        sideArrow.Visible = false
        sideArrow.Parent = Player.PlayerGui.Tutorial
        return
    end
    if ignoreGreen then
        arrowObj.Flash.Value = false
    else
        arrowObj.Flash.Value = true
    end
    arrowObj.Parent = ui
    arrowObj.Visible = true
end

function loadStep(step, stepList)
    local returner = {}

    stepList = stepList or module.steps
    local stepDetails = stepList[step]
    if stepDetails.dialogue then
        Player.PlayerGui.Tutorial.Dialogue.Frame.MessageLabel.Text = stepDetails.dialogue
    end
    if stepDetails.doText then
        Player.PlayerGui.Tutorial.Dialogue.Frame.DoLabel.Text = stepDetails.doText
    end

    function returner:init()
        spawn(function()
            sideArrow.ArrowImage.Size = UDim2.new(0.4, 0, 1.5, 0)
            loadArrow()
            if type(stepDetails.func) == "function" then
                stepDetails.func()
            elseif stepDetails.func == "click" then
                -- userClicked:Wait()
                loadArrow(Player.PlayerGui.Tutorial.Dialogue, sideArrow, true)
                sideArrow.ArrowImage.Size = UDim2.new(0.2, 0, 0.8, 0)
                Player.PlayerGui.Tutorial.Dialogue.Frame.Button.MouseButton1Click:Wait()
                nextSignal:Fire()
            end
        end)
    end

    return returner
end

function module:basic()
    if not Status.game.plotNo then
        while wait(0.5) do if Status.game.plotNo then break end end
    end
    local plot = workspace.Game.PlayerPlots:FindFirstChild(tostring(Status.game.plotNo)).Plot

    local running = true
    local function setupArrow(arrowObj, offset)
        spawn(function()
            while running do
                wait(0.3)
                if not arrowObj.Parent.Flash.Value then arrowObj.Parent.BackgroundTransparency = 0.5 continue end
                arrowObj.Parent.BackgroundTransparency = 0.5
                wait(0.3)
                if not arrowObj.Parent.Flash.Value then arrowObj.Parent.BackgroundTransparency = 0.5 continue end
                arrowObj.Parent.BackgroundTransparency = 1
            end
        end)
        spawn(function()
            local origPos = arrowObj.Position
            local tween1 = Tween(arrowObj, "Position", origPos + offset, InOutSine, 1, true)
            tween1:Wait()
            local tween2 = Tween(arrowObj, "Position", origPos, InOutSine, 1, true)
            tween2:Wait()
            while true do
                if not running then break end
                tween1:Restart()
                tween1:Wait()
                tween2:Restart()
                tween2:Wait()
                wait()
            end
        end)
    end
    setupArrow(topArrow.ArrowImage, UDim2.fromOffset(0, -10))
    setupArrow(sideArrow.ArrowImage, UDim2.fromOffset(-10, 0))

    while currentStep < #module.basicSteps do
        currentStep += 1
        local stepHandling = loadStep(currentStep, module.basicSteps)
        --Player.PlayerGui.Tutorial.Dialogue.Frame.DoLabel.Visible = false
        wait(0.2)
        --Player.PlayerGui.Tutorial.Dialogue.Frame.DoLabel.Visible = true
        stepHandling:init()
        nextSignal:Wait()
        -- if not module.doingTutorial then break end
        if not running then break end
    end
    running = false
    Resources:GetRemote("Tutorial"):FireServer(1)
end

function module:beginTutorial()
    module.doingTutorial = true
    tutJanitor = Janitor.new()

    if not Status.game.plotNo then
        while wait(0.5) do if Status.game.plotNo then break end end
    end
    local plot = workspace.Game.PlayerPlots:FindFirstChild(tostring(Status.game.plotNo)).Plot

    module.uiShowHide:tweenMenu("TutorialDialogueUi", "open")

    tutJanitor:Add(RunService.Heartbeat:Connect(function()
        if not Player.Character then return end
        if not Player.Character:FindFirstChild("HumanoidRootPart") then return end
        local raycastParams = RaycastParams.new()
        raycastParams.FilterType = Enum.RaycastFilterType.Whitelist
        raycastParams.FilterDescendantsInstances = {plot.Parent.Floors}
        raycastParams.IgnoreWater = true

        local floorCastResult = workspace:Raycast(Player.Character.HumanoidRootPart.Position, Vector3.new(0, -5, 0), raycastParams)
        if floorCastResult then
            local target = floorCastResult.Instance
            local floorObj = target:FindFirstAncestorWhichIsA("Model")
            if floorObj then
                if floorObj.Parent == plot.Parent.Floors then
                    currentFloor = floorObj
                    return
                end
            end
        end
        currentFloor = nil
    end), "Disconnect")

    local function setupArrow(arrowObj, offset)
        spawn(function()
            while module.doingTutorial do
                wait(0.3)
                if not arrowObj.Parent.Flash.Value then arrowObj.Parent.BackgroundTransparency = 0.5 continue end
                arrowObj.Parent.BackgroundTransparency = 0.5
                wait(0.3)
                if not arrowObj.Parent.Flash.Value then arrowObj.Parent.BackgroundTransparency = 0.5 continue end
                arrowObj.Parent.BackgroundTransparency = 1
            end
        end)
        spawn(function()
            local origPos = arrowObj.Position
            local tween1 = Tween(arrowObj, "Position", origPos + offset, InOutSine, 1, true)
            tween1:Wait()
            local tween2 = Tween(arrowObj, "Position", origPos, InOutSine, 1, true)
            tween2:Wait()
            while true do
                if not module.doingTutorial then break end
                tween1:Restart()
                tween1:Wait()
                tween2:Restart()
                tween2:Wait()
                wait()
            end
        end)
    end
    setupArrow(topArrow.ArrowImage, UDim2.fromOffset(0, -10))
    setupArrow(sideArrow.ArrowImage, UDim2.fromOffset(-10, 0))

    -- tutJanitor:Add(UserInputService.InputBegan:Connect(function(input, proc)
    --     if proc then return end
    --     if input.UserInputType == Enum.UserInputType.MouseButton1 then
    --         userClicked:Fire()
    --     end
    -- end), "Disconnect")

    tutJanitor:Add(Player.PlayerGui.Tutorial.Dialogue.Cancel.Base.Frame.MouseButton1Click:Connect(function()
        module.uiShowHide:tweenMenu("TutorialSkipRequestUi", "open")
    end))

    BindUiOpenClose.binds.FrostyDory.sigs.close:Fire()

    while currentStep < #module.steps do
        currentStep += 1
        local stepHandling = loadStep(currentStep)
        --Player.PlayerGui.Tutorial.Dialogue.Frame.DoLabel.Visible = false
        wait(0.2)
        --Player.PlayerGui.Tutorial.Dialogue.Frame.DoLabel.Visible = true
        stepHandling:init()
        nextSignal:Wait()
        if not module.doingTutorial then break end
    end

    tutJanitor:Cleanup()
    module.doingTutorial = false
    module.allowedUi = {["openTutorialDialogueUi"] = true; ["closeTutorialDialogueUi"] = true;}
    module.uiShowHide:tweenMenu("TutorialDialogueUi", "close")
    Resources:GetRemote("Tutorial"):FireServer(1)
    -- BindUiOpenClose.binds.FrostyDory.sigs.open:Fire()
end

function module:checkAvailability()
    if Status.data.hadTutorial == 0 and not module.doingTutorial then
        spawn(function()
            -- module:beginTutorial()
            module:basic()
        end)
    end
end

Player.PlayerGui.Tutorial.SkipRequest.Base.Cancel.Base.Frame.MouseButton1Click:Connect(function()
    module.uiShowHide:tweenMenu("TutorialSkipRequestUi", "close")
end)
Player.PlayerGui.Tutorial.SkipRequest.Base.Skip.Base.Frame.MouseButton1Click:Connect(function()
    module.uiShowHide:tweenMenu("TutorialSkipRequestUi", "close")
    module.doingTutorial = false
    nextSignal:Fire()
end)

return module