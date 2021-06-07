local module = {}

local Player = game.Players.LocalPlayer
local UserMouse = Player:GetMouse()

local Resources = require(game.ReplicatedStorage.Resources)
local UiShowHide = Resources:LoadLibrary("UiShowHide")

return setmetatable(module, {
    __call = function(_, ...)
        -- local fishFillScroll = Player.PlayerGui.FishFillMenu.Frame.Body.ScrollingFrame
        -- fishFillScroll.UIGridLayout.CellSize = UDim2.new(1, -12, 0.05, 0)
        -- fishFillScroll.CanvasSize = UDim2.new(0, 0, 4, 0)

        Player.PlayerGui.ItemTankGui.Size = UDim2.new(12, 0, 7.5, 0)

        Player.PlayerGui.PlayersMenu.Frame.Size = UDim2.new(0.5, 0, 0.8, 0)

        Player.PlayerGui.FishMenu.Frame.ScrollingFrame.CanvasSize = UDim2.new(0, 0, Player.PlayerGui.FishMenu.Frame.ScrollingFrame.CanvasSize.Y.Scale * 1.5) --.UIGridLayout.CellSize = UDim2.new(1, -12, 0.07, 0)
    
        Player.PlayerGui.InGameRight.Frame.Size = UDim2.new(0.162, 0, 0.424, 0)

        -- Player.PlayerGui.Editor.Frame.List.Size = UDim2.new(0.55, 0, 1.2, 0)
        -- Player.PlayerGui.Editor.Frame.List.Selecting.Size = UDim2.new(0.3, 0, 0.9, 0)
        -- Player.PlayerGui.Editor.Frame.List.Filter.Size = UDim2.new(0.4, 0, 0.95, 0)
        -- Player.PlayerGui.Editor.Frame.List.Filter.UIGridLayout.CellSize = UDim2.new(0.25, 0, 0.5, 0)
        -- Player.PlayerGui.Editor.Frame.List.Exit.Size = UDim2.new(0.15, 0, 0.6, 0)
        -- Player.PlayerGui.Editor.Frame.List.Delete.Size = UDim2.new(0.15, 0, 0.6, 0)
        -- Player.PlayerGui.Editor.Frame.List.Currency.Size = UDim2.new(0.15, 0, 0.6, 0)

        for _, obj in pairs(Player.PlayerGui:GetDescendants()) do
            if obj:IsA("Frame") and obj.Name == "Base" then
                if obj.Size.X.Offset == -4 and obj.Size.Y.Offset == -7 then
                    local origSize = obj.Size
                    obj.Size = UDim2.new(origSize.X.Scale, -3, origSize.Y.Scale, -4)
                end
            end
        end

        local x = UserMouse.ViewSizeX
        local y = UserMouse.ViewSizeY
        if x/y < 1.5 then
            Player.PlayerGui.InGame.Frame.Currency.People.Size = UDim2.new(0.9, 0, 2.8, 0)
            Player.PlayerGui.InGame.Frame.Fish.Size = UDim2.new(0.15, 0, 1.2, 0)
            Player.PlayerGui.InGame.Frame.Build.Size = UDim2.new(0.15, 0, 1.2, 0)

            Player.PlayerGui.FishMenu.Frame.Size = UDim2.new(0.65, 0, 0.8, 0)
            UiShowHide.statesCollected.touch["InterfacePeopleUi"].open.pos = UDim2.new(0.05, 0, -0.6, 0)
            UiShowHide.statesCollected.touch["InterfacePeopleUi"].close.pos = UDim2.new(0.05, 0, 0, 0)
            UiShowHide.statesCollected.touch["InterfaceNeedsUi"].open.pos = UDim2.new(0.05, 0, -2.2, 0)
            UiShowHide.statesCollected.touch["InterfaceNeedsUi"].close.pos = UDim2.new(0.05, 0, -0.6, 0)

            Player.PlayerGui.Editor.Place.Base.Frame.TextLabel.Size = UDim2.new(0.5, 0, 0.8, 0)
            Player.PlayerGui.Editor.Rotate.Base.Frame.TextLabel.Size = UDim2.new(0.5, 0, 0.8, 0)
            Player.PlayerGui.Editor.Cancel.Base.Frame.TextLabel.Size = UDim2.new(0.5, 0, 0.8, 0)
            Player.PlayerGui.Editor.Delete.Base.Frame.TextLabel.Size = UDim2.new(0.5, 0, 0.8, 0)

            Player.PlayerGui.Build.Frame.Floor.Base.Frame.TextLabel.Size = UDim2.new(0.45, 0, 0.45, 0)
            Player.PlayerGui.Build.Frame.Exit.Base.Frame.TextLabel.Size = UDim2.new(0.45, 0, 0.45, 0)
            Player.PlayerGui.Build.Frame.Items.Base.Frame.TextLabel.Size = UDim2.new(0.45, 0, 0.45, 0)
            Player.PlayerGui.Build.Frame.Land.Base.Frame.TextLabel.Size = UDim2.new(0.45, 0, 0.45, 0)
            Player.PlayerGui.Build.Frame.Wall.Base.Frame.TextLabel.Size = UDim2.new(0.45, 0, 0.45, 0)

            Player.PlayerGui.Editor.Frame.List.Delete.Base.Frame.Yes.TextLabel.Size = UDim2.new(0.45, 0, 0.45, 0)
            Player.PlayerGui.Editor.Frame.List.Delete.Base.Frame.No.TextLabel.Size = UDim2.new(0.45, 0, 0.45, 0)
            Player.PlayerGui.Editor.Frame.List.Exit.Base.Frame.TextLabel.Size = UDim2.new(0.45, 0, 0.45, 0)
            Player.PlayerGui.Editor.Frame.List.Currency.Base.Frame.TextLabel.Size = UDim2.new(0.45, 0, 0.45, 0)

            Player.PlayerGui.Tutorial.Dialogue.Cancel.Base.Frame.TextLabel.Size = UDim2.new(0.5, 0, 0.45, 0)

            Player.PlayerGui.InGameRight.Frame.Size = UDim2.new(0.2, 0, 0.424, 0)
        else
            Player.PlayerGui.Build.Frame.Exit.Size = UDim2.new(0.1, 0, 1.9, 0)
            Player.PlayerGui.Build.Frame.Floor.Size = UDim2.new(0.1, 0, 1.9, 0)
            Player.PlayerGui.Build.Frame.Items.Size = UDim2.new(0.1, 0, 1.9, 0)
            Player.PlayerGui.Build.Frame.Land.Size = UDim2.new(0.1, 0, 1.9, 0)
            Player.PlayerGui.Build.Frame.Wall.Size = UDim2.new(0.1, 0, 1.9, 0)
            UiShowHide.statesCollected.shared["BuildExitUi"].open.pos = UDim2.new(0.28, 0, -0.45, 0)
            UiShowHide.statesCollected.shared["BuildFloorUi"].open.pos = UDim2.new(0.5, 0, -0.45, 0)
            UiShowHide.statesCollected.shared["BuildLandUi"].open.pos = UDim2.new(0.39, 0, -0.45, 0)
            UiShowHide.statesCollected.shared["BuildWallUi"].open.pos = UDim2.new(0.61, 0, -0.45, 0)
            UiShowHide.statesCollected.shared["BuildItemsUi"].open.pos = UDim2.new(0.72, 0, -0.45, 0)
            Player.PlayerGui.Build.Frame.Floor.Base.Frame.TextLabel.Size = UDim2.new(0.45, 0, 0.45, 0)
            Player.PlayerGui.Build.Frame.Exit.Base.Frame.TextLabel.Size = UDim2.new(0.45, 0, 0.45, 0)
            Player.PlayerGui.Build.Frame.Items.Base.Frame.TextLabel.Size = UDim2.new(0.45, 0, 0.45, 0)
            Player.PlayerGui.Build.Frame.Land.Base.Frame.TextLabel.Size = UDim2.new(0.45, 0, 0.45, 0)
            Player.PlayerGui.Build.Frame.Wall.Base.Frame.TextLabel.Size = UDim2.new(0.45, 0, 0.45, 0)

            Player.PlayerGui.InGame.Frame.Build.Size = UDim2.new(0.1, 0, 1.9, 0)
            Player.PlayerGui.InGame.Frame.Fish.Size = UDim2.new(0.1, 0, 1.9, 0)
            UiShowHide.statesCollected.touch["InterfaceFishUi"].open.pos = UDim2.new(0.635, 0, -0.45, 0)
            UiShowHide.statesCollected.touch["InterfaceBuildUi"].open.pos = UDim2.new(0.365, 0, -0.45, 0)
            Player.PlayerGui.InGame.Frame.Build.Base.Frame.TextLabel.Size = UDim2.new(0.45, 0, 0.45, 0)
            Player.PlayerGui.InGame.Frame.Fish.Base.Frame.TextLabel.Size = UDim2.new(0.45, 0, 0.45, 0)
        end
    end
})