local module = {}
module.__index = module

local Resources = require(game.ReplicatedStorage.Resources)
local Janitor = Resources:LoadLibrary("Janitor")
local RunService = game:GetService("RunService")
local Player = game.Players.LocalPlayer
local Tween = Resources:LoadLibrary("Tween")
local Enumeration = Resources:LoadLibrary("Enumeration")
local StarterGui = game:GetService("StarterGui")
local ContentProvider = game:GetService("ContentProvider")
local TeleportService = game:GetService("TeleportService")

local InOutSine = Enumeration.EasingFunction.InOutSine.Value

local teleportGui = game.ReplicatedFirst.Loading:Clone()
teleportGui.Frame.LoadingLabel.Text = "TELEPORTING . . ."
teleportGui.Frame.TextLabel.Text = "We are currently resetting our servers for a new update! Please be patient, this won't take long! (If the waiting period does exceed two minutes, please rejoin through the website or app!)"
teleportGui.Frame.BarFrame.Visible = false
TeleportService:SetTeleportGui(teleportGui)

Resources:GetRemote("Shutdown").OnClientEvent:Connect(function()
    teleportGui.Parent = Player.PlayerGui
    StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.All, false)
end)

function module.new()
    local self = setmetatable({}, module)

    StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.All, false)

    self.on = true

    self.janitor = Janitor.new()
    self.janitor:Add(function()
        self.on = false
    end)
    self.janitor:Add(function()
        StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.EmotesMenu, true)
        StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.Chat, true)
        StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.PlayerList, true)
    end)

    self.gui = game.ReplicatedFirst:WaitForChild("Loading"):Clone()
    self.gui.Frame.BarFrame.Visible = true
    self.gui.Parent = Player.PlayerGui
    self.janitor:Add(function()
        local i = 0
        -- spawn(function()
        --     for _, uiStrip in pairs(self.gui.Frame.Transition:GetChildren()) do
        --         if uiStrip:IsA("Frame") then
        --             uiStrip:TweenPosition(UDim2.new(0, 0, 0.09 * (i - 0), 0), Enum.EasingDirection.InOut, Enum.EasingStyle.Quint, 1.5, true)
        --             i += 1
        --             wait(0.1)
        --         end
        --     end
        -- end)
        -- wait(3)

        -- self.gui.Frame.BarFrame.Visible = false
        -- self.gui.Frame.TextLabel.Visible = false
        -- self.gui.Frame.ImageLabel.Visible = false
        -- self.gui.Frame.LoadingLabel.Visible = false
        -- self.gui.Frame.ImageLabel.ZIndex = -1
        -- self.gui.Frame.BackgroundTransparency = 1

        -- spawn(function()
        --     i = 0
        --     for _, uiStrip in pairs(self.gui.Frame.Transition:GetChildren()) do
        --         if uiStrip:IsA("Frame") then
        --             uiStrip:TweenPosition(UDim2.new(-1, 0, 0.09 * (i - 0), 0), Enum.EasingDirection.InOut, Enum.EasingStyle.Quint, 1.5, true)
        --             i += 1
        --             wait(0.1)
        --         end
        --     end
        -- end)
        -- wait(2.5)
        -- -- self.gui.Frame.Transition.Visible = false
        -- -- self.gui.Frame.White.Visible = true
        -- -- self.gui.Frame:TweenPosition(UDim2.new(0, 0, -0.2, 0), Enum.EasingDirection.InOut, Enum.EasingStyle.Quint, 0.5, true)
        -- -- wait(0.5)

        self.gui.Frame:TweenPosition(UDim2.new(0, 0, 0, 0), Enum.EasingDirection.InOut, Enum.EasingStyle.Quint, 1.5, true)
        wait(1.5)

        self.gui:Destroy()
    end)
    self:_errorText("<b>[REJOIN REQUIRED]</b> Something has gone wrong! Please press F9 on your keyboard to open the developer console and screenshot your whole screen to @PenguinDevs on Twitter!")

    spawn(function()
        local bar = self.gui.Frame.BarFrame.Bar

        local barAnchorTweenRight = Tween(bar, "AnchorPoint", Vector2.new(1, 0), InOutSine, 1, true)
        local barPositionTweenRight = Tween(bar, "Position", UDim2.new(1, 0, 0, 0), InOutSine, 1, true)
        --barPositionTweenRight:Wait()

        local barSizeTweenBig = Tween(bar, "Size", UDim2.new(0.5, 0, 1, 0), InOutSine, 1/2, true)
        barSizeTweenBig:Wait()
        local barSizeTweenSmall = Tween(bar, "Size", UDim2.new(0.08, 0, 1, 0), InOutSine, 1/2, true)
        barSizeTweenSmall:Wait()


        local barAnchorTweenLeft = Tween(bar, "AnchorPoint", Vector2.new(0, 0), InOutSine, 1, true)
        local barPositionTweenLeft = Tween(bar, "Position", UDim2.new(0, 0, 0, 0), InOutSine, 1, true)
        --barPositionTweenLeft:Wait()

        barSizeTweenBig:Restart()
        barSizeTweenBig:Wait()
        barSizeTweenSmall:Restart()
        barSizeTweenSmall:Wait()

        while self.on do
            RunService.RenderStepped:Wait()
            barAnchorTweenRight:Restart()
            barPositionTweenRight:Restart()
            --barPositionTweenRight:Wait()
            
            barSizeTweenBig:Restart()
            barSizeTweenBig:Wait()
            barSizeTweenSmall:Restart()
            barSizeTweenSmall:Wait()

            barAnchorTweenLeft:Restart()
            barPositionTweenLeft:Restart()
            --barPositionTweenLeft:Wait()
            
            barSizeTweenBig:Restart()
            barSizeTweenBig:Wait()
            barSizeTweenSmall:Restart()
            barSizeTweenSmall:Wait()
        end
    end)

    return self
end

function module:Destroy()
    self.janitor:Cleanup()
end

function module:Update(message)
    self.gui.Frame.TextLabel.Text = message
    spawn(function()
        self.gui.Frame.TextLabel:TweenPosition(UDim2.new(0.6, 0, self.gui.Frame.TextLabel.Position.Y.Scale, 0), Enum.EasingDirection.Out, Enum.EasingStyle.Back, 0.5, true)
        wait(0.1)
        self.gui.Frame.TextLabel:TweenPosition(UDim2.new(0.5, 0, self.gui.Frame.TextLabel.Position.Y.Scale, 0), Enum.EasingDirection.Out, Enum.EasingStyle.Back, 0.5, true)
    end)
end

function module:_errorText(message)
    self.gui.Frame.TextLabel.TextColor3 = Color3.fromRGB(255, 78, 78)
    self:Update(message)
end

function module:Error(message)
    local text = string.format("<b>[REJOIN REQUIRED]</b> Something has gone wrong! Please press F9 on your keyboard to open the developer console or this red message and screenshot your whole screen to @PenguinDevs on Twitter!\n\n[TERMINATING CLIENT INITIALISATION WITH ERROR]: %s\n\nIf these issue continues to persist, you may contact PenguinDevs via Twitter (@PenguinDevs) to resolve this issue.", message)
    self:Update(text)
    spawn(function()
        ContentProvider:PreloadAsync({self.gui.Frame.ImageLabel})
    end)
    self.gui.Frame.TextLabel.TextColor3 = Color3.fromRGB(255, 78, 78)
    self.gui.Frame.TextLabel.Position = UDim2.new(0.5, 0, 0.8, 0)
    self.gui.Frame.TextLabel.Size = UDim2.new(0.6, 0, 0.2, 0)
    self.gui.Frame.ImageLabel.Image = "rbxassetid://6578574315"
    self.gui.Frame.ImageLabel.ImageColor3 = Color3.fromRGB(255, 0, 0)
    self.gui.Frame.LoadingLabel.Text = "[REJOIN REQUIRED]"
    self.gui.Frame.LoadingLabel.TextColor3 = Color3.fromRGB(255, 0, 0)
    self.gui.Frame.BarFrame.Visible = false
    error(text)
end

function module:Print(message)
    self.gui.Frame.TextLabel.TextColor3 = Color3.fromRGB(220, 220, 220)
    self:Update(message)
end

return module