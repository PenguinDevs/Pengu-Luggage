local Resources = require(game.ReplicatedStorage.Resources)
local Status = Resources:LoadLibrary("Status")
local Janitor = Resources:LoadLibrary("Janitor")

local module = {}

module.showing = true

local currentPlot
local currentJanitor

local collectedTrans = {}

function module:setupCeiling(ceilingObj, override)
    -- ceilingObj.Parent:WaitForChild(ceilingObj.Name)
    if ceilingObj.Name == "REF" then return end
    -- for i = 1, 100 do if ceilingObj.PrimaryPart then break end wait() end
    -- local hidePart = ceilingObj:FindFirstChild("HidePart")
    -- ceilingObj:SetPrimaryPartCFrame(CFrame.new(ceilingObj.PrimaryPart.Position.X, currentPlot.Grid.Position.Y + 15.5, ceilingObj.PrimaryPart.Position.X))
    -- if not hidePart then
    --     hidePart = Instance.new("Part", ceilingObj)
    --     hidePart.Size = Vector3.new(16, 1, 16)
    --     hidePart.Transparency = 0.4
    --     hidePart.CanCollide = false
    --     hidePart.Anchored = true
    --     hidePart.CFrame = ceilingObj.PrimaryPart.CFrame * CFrame.new(0, 50, 0)
    --     hidePart.Name = "HidePart"
    -- end
    -- if module.showing then
    --     hidePart.Transparency = 1
    -- else
    --     hidePart.Transparency = 0.4
    -- end
    for _, obj in pairs(ceilingObj:GetDescendants()) do
        if obj:IsA("BasePart") or obj:IsA("Texture") or obj:IsA("Decal") then
            if override then collectedTrans[obj] = obj.Transparency end
            if module.showing then
                obj.Transparency = collectedTrans[obj]
            else
                if obj.Parent.Name == "Base" then
                    obj.Transparency = 0.5
                else
                    obj.Transparency = 1
                end
            end
        end
    end
end

function module:setupObj(obj)
    if obj:IsA("BasePart") or obj:IsA("Texture") or obj:IsA("Decal") then
        collectedTrans[obj] = obj.Transparency
        if module.showing then
            obj.Transparency = collectedTrans[obj]
        else
            if obj.Parent.Name == "Base" then
                obj.Transparency = 0.5
            else
                obj.Transparency = 1
            end
        end

        obj.AncestryChanged:Connect(function()
            if not obj:IsDescendantOf(game) then
                collectedTrans[obj] = nil
            end
        end)
    end
end

function module:setupPlot(plot)
    if currentPlot == plot then
        module:updateCeilings()
        return
    end
    if currentPlot then currentJanitor:Cleanup() end
    currentPlot = plot
    currentJanitor = Janitor.new()
    currentJanitor:Add(plot.Ceiling.ChildAdded:Connect(function(ceilingObj)
        module:setupCeiling(ceilingObj)
    end), "Disconnect")
    currentJanitor:Add(plot.Ceiling.DescendantAdded:Connect(function(obj)
        module:setupObj(obj)
    end))
    for _, ceilingObj in pairs(plot.Ceiling:GetChildren()) do
        module:setupCeiling(ceilingObj, true)
    end
end

function module:updateCeilings()
    for _, ceilingObj in pairs(currentPlot.Ceiling:GetChildren()) do
        module:setupCeiling(ceilingObj)
    end
end

function module:show()
    if module.showing then return end
    module.showing = true
    local plot = workspace.Game.PlayerPlots:FindFirstChild(tostring(Status.game.plotNo))
    -- plot.Ceiling:SetPrimaryPartCFrame(plot.Grid.CFrame)
    module:updateCeilings()
end

function module:hide()
    if not module.showing then return end
    module.showing = false
    local plot = workspace.Game.PlayerPlots:FindFirstChild(tostring(Status.game.plotNo))
    module:setupPlot(plot)
    -- plot.Ceiling:SetPrimaryPartCFrame(plot.Grid.CFrame * CFrame.new(0, -50, 0))
end

return module
