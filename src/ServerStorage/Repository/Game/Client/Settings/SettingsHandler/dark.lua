local module = {}

local Resources = require(game.ReplicatedStorage.Resources)
local Status = Resources:LoadLibrary("Status")
local Player = game.Players.LocalPlayer
local DaltonSpawn = Resources:LoadLibrary("DaltonSpawn")
local Notify = Resources:LoadLibrary("NotifyHandler")
local Round = Resources:LoadLibrary("Round")
local Janitor = Resources:LoadLibrary("Janitor")

local lastThemeJanitor

local ui = Player.PlayerGui.SettingsMenu.Frame.ScrollingFrame.Visuals.Frame.Body.Dark
local setting = "dark"

module.mainHandler = nil

local deb = tick()

function module:init()
    ui.Body.Button.MouseButton1Click:Connect(function()
        if tick() - deb < 5 then
            Notify:addItem("Issue", 3, nil, string.format("You must wait %s seconds before changing this setting again", Round(5 - tick() + deb)))
            return
        end
        deb = tick()
        Status.data.settings[setting] = not Status.data.settings[setting]
        
        if Status.data.settings[setting] then
            ui.Body.Button.ImageTransparency = 0
        else
            ui.Body.Button.ImageTransparency = 1
        end

        Resources:GetRemote("Settings"):FireServer(Status.data.settings)
        module.mainHandler:updateSettings(Status.data.settings, setting)
    end)
end

function module:update(val)
    if val == nil then return end
    if val then
        ui.Body.Button.ImageTransparency = 0
    else
        ui.Body.Button.ImageTransparency = 1
    end
    spawn(function()
        local needsWhiteDefault = lastThemeJanitor and val
        if lastThemeJanitor then lastThemeJanitor:Cleanup() lastThemeJanitor = nil end
        if val then
            lastThemeJanitor = Janitor.new()
            local function setupObj(obj)
                if obj:IsA("Frame") and obj.Name == "Base" then
                    if obj.BackgroundColor3 == Color3.fromRGB(255, 255, 255) then
                        local origBaseCol = obj.BackgroundColor3
                        obj.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
                        lastThemeJanitor:Add(function()
                            obj.BackgroundColor3 = origBaseCol
                        end)
            
                        -- local a = obj:GetPropertyChangedSignal("BackgroundColor3"):Connect(function()
                        --     local new = obj.BackgroundColor3
                        --     obj.BackgroundColor3 = Color3.fromRGB(255 - new.R, 255 - new.G, 255 - new.B)
                        -- end)
                        -- print(a)
                    end
            
                    local background = obj.Parent:FindFirstChild("Background")
                    if background then
                        local origBGCol = background.BackgroundColor3
                        background.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
                        lastThemeJanitor:Add(function()
                            background.BackgroundColor3 = origBGCol
                        end)
                    end
                elseif obj:IsA("ScrollingFrame") then
                    local origScrollCol = obj.ScrollBarImageColor3
                    obj.ScrollBarImageColor3 = Color3.fromRGB(255, 255, 255)
                    lastThemeJanitor:Add(function()
                        obj.BackgroundColor3 = origScrollCol
                    end)
                end
            end
            for _, obj in pairs(Player.PlayerGui:GetDescendants()) do
                setupObj(obj)
            end
            lastThemeJanitor:Add(Player.PlayerGui.DescendantAdded:Connect(function(obj)
                setupObj(obj)
            end), "Disconnect")
            
            if not game.ReplicatedStorage.ServerLoaded.Value then game.ReplicatedStorage.ServerLoaded.Changed:Wait() end
            for _, obj in pairs(workspace.GamepassBoards:GetDescendants()) do
                setupObj(obj)
            end
            workspace.GamepassBoards.DescendantAdded:Connect(function(obj)
                print(obj)
                setupObj(obj)
            end)

            local forced = {
                [Player.PlayerGui.InGame.Frame.Currency.Base.Add.Base.Frame.TextLabel] = "TextColor3";
                [Player.PlayerGui.FishFillMenu.Frame.Body.Head] = "BackgroundColor3";
                [Player.PlayerGui.FishFillMenu.Frame.Body.Head.AmountFrame] = "BackgroundColor3";
                [Player.PlayerGui.FishFillMenu.Frame.Body.Head.ContentFrame] = "BackgroundColor3";
                [Player.PlayerGui.FishFillMenu.Frame.Body.Head.NameFrame] = "BackgroundColor3";
            }

            for obj, colProp in pairs(forced) do
                local origCol = obj[colProp]
                obj[colProp] = Color3.fromRGB(60, 60, 60)
                lastThemeJanitor:Add(function()
                    obj[colProp] = origCol
                end)
            end
        -- elseif needsWhiteDefault then

        end
    end)
end

return module