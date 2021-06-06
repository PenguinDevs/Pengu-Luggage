local Resources = require(game.ReplicatedStorage.Resources)
local Player = game.Players.LocalPlayer
local RunService = game:GetService("RunService")
local GameLoop = Resources:LoadLibrary("GameLoop")
local Janitor = Resources:LoadLibrary("Janitor")
local GetAmountFromTick = Resources:LoadLibrary("GetAmountFromTick")
local Tweenings = Resources:LoadLibrary("Tweenings")

local module = {}

local List = {}

local EndIndexPos = 0

function module:organiseIndex()
    for i, details in pairs(List) do
        details.i = i
    end
end

function module:addItem(itemType, dur, ...)
    local args = table.pack(...)
    if not dur then dur = 5 end
    local ui
    if itemType == "Warning" then
        itemType = "ImageText"
        args[3] = Color3.fromRGB(255, 40, 40)
        args[2] = '<font size="25"><u><b>WARNING!</b></u></font><font color="rgb(182, 182, 182)"><br/>' .. args[2] .. "</font>"
        args[1] = "rbxassetid://6578574315"
    elseif itemType == "Issue" then
        itemType = "ImageText"
        args[3] = Color3.fromRGB(255, 40, 40)
        args[2] = '<font size="25"><u><b>Uh oh...</b></u></font><font color="rgb(182, 182, 182)"><br/>' .. args[2] .. "</font>"
        args[1] = "rbxassetid://6578574315"
    elseif itemType == "Yellow" then
        itemType = "ImageText"
        args[3] = Color3.fromRGB(255, 208, 0)
        args[1] = "rbxassetid://6385756973"
    elseif itemType == "Green" then
        itemType = "ImageText"
        args[3] = Color3.fromRGB(95, 235, 132)
        args[1] = "rbxassetid://6385757126"
    elseif itemType == "Red" then
        itemType = "ImageText"
        args[3] = Color3.fromRGB(255, 40, 40)
        args[1] = "rbxassetid://6385757245"
    end
    if itemType == "ImageText" then
        local image, text, colour = table.unpack(args)
        ui = Player.PlayerGui.Notifs.Frame.TEMPImageText:Clone()
        ui.Base.ImageLabel.Image = image
        ui.Base.TextLabel.Text = text
        ui.Base.ImageLabel.ImageColor3 = colour
        ui.Base.TextLabel.TextColor3 = colour
    end
    ui.Parent = Player.PlayerGui.Notifs.Frame.List
    ui.Visible = true

    local details = {
        ui = ui;
        posX = 0.02;
        posY = 0;
        i = 1;
        state = "open";
        janitor = Janitor.new()
    }
    details.janitor:Add(details.ui, "Destroy")
    -- details.janitor:Add(function()
    --     table.remove(List, details.i)
    --     module:organiseIndex()
    -- end)
    table.insert(List, 1, details)
    module:organiseIndex()
    module:setupMoveBehaviour(details)

    spawn(function()
        wait(dur)
        details.state = "closeReq";
        --details.janitor:Cleanup()
    end)
end

function module:setupMoveBehaviour(details)
    local ui = details.ui
    local janitor = details.janitor
    local summonedTick = tick()
    local closedTick
    local TickForTweenY
    local LastIndex = 0
    janitor:Add(RunService.RenderStepped:Connect(function()
        if summonedTick then
            local t = GetAmountFromTick(1, summonedTick)
            if t > 0.5 then
                summonedTick = nil
                t = 0.5
            end
            t *= 2
            local amount = Tweenings.inCubic(t, 0, 1, 1)
            details.posX = amount - 0.98
        end

        if details.state == "closeReq" then
            details.state = "close"
            closedTick = tick()
            spawn(function()
                wait(1)
                table.remove(List, details.i)
                module:organiseIndex()
                janitor:Cleanup()
            end)
        end
        if closedTick then
            local t = GetAmountFromTick(1, closedTick)
            if t > 0.5 then
                closedTick = nil
                t = 0.5
            end
            t *= 2
            local amount = Tweenings.inCubic(t, 0, 1, 1)
            details.posX = 0.02 - amount * 1.02
        end

        --details.posY = (EndIndexPos - (#List - details.i) * 0.1)
        if LastIndex ~= details.i then
            LastIndex = details.i
            TickForTweenY = tick()
        end
        if TickForTweenY then
            local t = GetAmountFromTick(2, TickForTweenY)
            if t > 0.5 then
                TickForTweenY = nil
                t = 0.5
            end
            t *= 2
            local amount = Tweenings.inOutCubic(t, 0, 1, 1)
            details.posY = details.i * 0.1 - 0.2 + amount * 0.1
        end
        if details.posY < 0 then details.posY = 0 end
        ui.Position = UDim2.fromScale(details.posX, -details.posY + 0.9)
        --print(details.posX, details.posY)
        --ui.Base.TextLabel.Text = details.i .. ":" .. details.posY
    end), "Disconnect")
end

-- spawn(function()
--     while wait(2) do
--         module:addItem("ImageText", math.random(5, 15), "rbxassetid://" .. math.random(1, 100000000), "Hi", Color3.fromRGB(math.random(1, 255), math.random(1, 255), math.random(1, 255)))
--     end
-- end)

-- local LastFinalIndex = 0
-- local TickForTween
-- module.update = GameLoop.new(function()
--     if LastFinalIndex ~= #List then
--         LastFinalIndex = #List
--         TickForTween = tick()
--     end
--     if TickForTween then
--         local t = GetAmountFromTick(2, TickForTween)
--         if t > 0.5 then
--             TickForTween = nil
--             t = 0.5
--         end
--         t *= 2
--         local amount = Tweenings.outCubic(t, 0, 1, 1)
--         EndIndexPos = #List * 0.1 - 0.2 + amount * 0.1
--         if EndIndexPos < 0 then EndIndexPos = 0 end
--     end
-- end, 0, "notifs updater")

Resources:GetRemote("Notify").OnClientEvent:Connect(function(...)
    module:addItem(...)
end)

return module