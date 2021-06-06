local Resources = require(game.ReplicatedStorage.Resources)
local Player = game.Players.LocalPlayer
local Round = Resources:LoadLibrary("Round")
local UiShowHide = Resources:LoadLibrary("UiShowHide")
local Status = Resources:LoadLibrary("Status")
local GameSettings = Resources:LoadLibrary("GameSettings")
local LoadingPage = Resources:LoadLibrary("LoadingPage")
local Janitor = Resources:LoadLibrary("Janitor")

local module = {}

local PlayerList = {}

local Deb = false

local function findEmptyUi() --BUG LIES HERE WHERE MULTIPLE INDEX
    local taken = {}
    for _, det in pairs(PlayerList) do
        --table.insert(taken, 1, tonumber(det.ui.Name))
        taken[tonumber(det.ui.Name)] = true
    end
    for i = 1, GameSettings.maxPlayers do
        if not taken[i] then
            return Player.PlayerGui.PlayersMenu.Frame.Body:FindFirstChild(tostring(i))
        end
    end
    return
end

function module:init()
    for i = 1, GameSettings.maxPlayers do
        local ui = Player.PlayerGui.PlayersMenu.Frame.Body.TEMP:Clone()
        ui.Parent = Player.PlayerGui.PlayersMenu.Frame.Body
        ui.Visible = false
        ui.Name = i
    end
    Player.PlayerGui.PlayersMenu.Frame.Body.TEMP:Destroy()
end

local buttonJanitor

local function updateItem(player, ui)
    if not player:IsDescendantOf(game) then
        local det = PlayerList[player]
        det.ui.Visible = false
        PlayerList[player] = nil
    end
    spawn(function()
        local data = Resources:GetRemote("RequestPlayer"):InvokeServer(player)
        ui.Base.PlayerImage.Image = game.Players:GetUserThumbnailAsync(player.UserId, Enum.ThumbnailType.AvatarBust, Enum.ThumbnailSize.Size352x352)
        ui.Base.NameLabel.Text = player.DisplayName
        ui.Base.PlotNo.Text = "Plot" .. data.plot
        ui.Base.CustomerLabel.Text = data.customers
        ui.Base.SatisfactionLabel.Text = Round(data.satisfaction * 100) .. "%"
        if data.satisfaction > 0.8 then
            ui.Base.SatisfactionImage.Image = "rbxassetid://6385757126"
            ui.Base.SatisfactionImage.ImageColor3 = Color3.fromRGB(75, 255, 105)
            ui.Base.SatisfactionLabel.TextColor3 = Color3.fromRGB(75, 255, 105)
        elseif data.satisfaction > 0.4 then
            ui.Base.SatisfactionImage.Image = "rbxassetid://6385756973"
            ui.Base.SatisfactionImage.ImageColor3 = Color3.fromRGB(248, 225, 93)
            ui.Base.SatisfactionLabel.TextColor3 = Color3.fromRGB(248, 225, 93)
        else
            ui.Base.SatisfactionImage.Image = "rbxassetid://6385757245"
            ui.Base.SatisfactionImage.ImageColor3 = Color3.fromRGB(255, 75, 75)
            ui.Base.SatisfactionLabel.TextColor3 = Color3.fromRGB(255, 75, 75)
        end
        ui.Visible = true

        buttonJanitor:Add(ui.Base.Visit.Base.Frame.MouseButton1Click:Connect(function()
            if Deb then return end
            Deb = true
            Resources:GetRemote("PlotTeleport"):FireServer(player)
            module:refreshPage()
            wait(1)
            Deb = false
        end), "Disconnect")

        local loadingUi = Player.PlayerGui.PlayersMenu.Frame.Base:FindFirstChild("Loading")
        if loadingUi then loadingUi:Destroy() end
    end)
end

function module:refreshPage()
    if buttonJanitor then
        buttonJanitor:Cleanup()
    end
    buttonJanitor = Janitor.new()
    local loadingUi = LoadingPage(Player.PlayerGui.PlayersMenu.Frame.Base)
    warn("VISITING MENU PLAYER CONTENTS:")
    for player, _ in pairs(PlayerList) do
        print(player, "DESCENDANT:", player:IsDescendantOf(game), PlayerList[player].ui)
        if not player:IsDescendantOf(game) then
            local det = PlayerList[player]
            det.ui.Visible = false
            PlayerList[player] = nil
        end
    end
    warn("------")
    for _, player in pairs(game.Players:GetPlayers()) do
        local ui
        if not PlayerList[player] then
            ui = findEmptyUi()
            PlayerList[player] = {ui = ui}
        else
            ui = PlayerList[player].ui
        end
        updateItem(player, ui)
    end
    -- loadingUi:Destroy()
end

Player.PlayerGui.PlayersMenu.Frame.Footer.Base.Visit.Base.Frame.MouseButton1Click:Connect(function()
    if Deb then return end
    Deb = true
    Resources:GetRemote("PlotTeleport"):FireServer("H")
    wait(1)
    Deb = false
end)

function module:updateVisiting()
    if not Status.game.visiting then
        if Status.data.settings.dark then
            Player.PlayerGui.InGame.Frame.Build.Base.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
            Player.PlayerGui.InGame.Frame.Fish.Base.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
        else
            Player.PlayerGui.InGame.Frame.Build.Base.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
            Player.PlayerGui.InGame.Frame.Fish.Base.BackgroundColor3 = Color3.fromRGB(255, 255, 255) 
        end
        UiShowHide:tweenMenu("InterfaceHomeUi", "close")
    else
        Player.PlayerGui.InGame.Frame.Build.Base.BackgroundColor3 = Color3.fromRGB(255, 87, 87)
        Player.PlayerGui.InGame.Frame.Fish.Base.BackgroundColor3 = Color3.fromRGB(255, 87, 87)
        UiShowHide:tweenMenu("InterfaceHomeUi", "open")
    end
end

Player.PlayerGui.InGame.Home.Base.Frame.MouseButton1Click:Connect(function()
    Resources:GetRemote("PlotTeleport"):FireServer(Player)
end)

return module