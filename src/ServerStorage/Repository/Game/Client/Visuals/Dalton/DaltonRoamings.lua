local Resources = require(game.ReplicatedStorage.Resources)
local Janitor = Resources:LoadLibrary("Janitor")

local module = {}

function module:setupItemRoamings(itemObj, roamFolder)
    local function setup()
        local janitor = Janitor.new()
        janitor:LinkToInstance(itemObj)
        wait(2)
        local part = Instance.new("Part", roamFolder)
        janitor:Add(part, "Destroy")
        part.Anchored = true
        part.Transparency = 1
        part.CanCollide = false
        --for i = 1, 100 do if itemObj.PrimaryPart then break end wait() end
        if not itemObj.PrimaryPart then itemObj:GetPropertyChangedSignal("PrimaryPart"):Wait() end
        part.CFrame = itemObj.PrimaryPart.CFrame
        part.Size = Vector3.new(14, 1, 14)
    end
    if not itemObj:FindFirstChild("FishHold") then
        spawn(setup)
    end
end

function module:setupItemSeats(itemObj, seatsFolder)
    spawn(function()
        wait(2)
        for _, seat in pairs(itemObj:GetDescendants()) do
            if seat:IsA("Seat") then
                local janitor = Janitor.new()
                janitor:LinkToInstance(seat)
                local seatPart = Instance.new("Part", seatsFolder)
                seatPart.Name = "Seat"
                seatPart.Anchored = true
                seatPart.CanCollide = false
                seatPart.Transparency = 1
                seatPart.CFrame = seat.CFrame
                janitor:Add(seatPart, "Destroy")
                -- janitor:Add(function()
                --     print("seat gone")
                -- end)

                seat.AncestryChanged:Connect(function()
                    if not seat:IsDescendantOf(game) then
                        janitor:Cleanup()
                    end
                end)

                local objValue = Instance.new("ObjectValue", seatPart)
                objValue.Name = "Owner"
            end
        end
    end)
end

function module:setupPlot(plot)
    local function objSetup(obj)
        if obj.Name == "Floors" then
            local janitor = Janitor.new()
            janitor:LinkToInstance(obj)
            local DaltonRoamFolder = Instance.new("Folder", plot)
            DaltonRoamFolder.Name = "DaltonRoam"
            janitor:Add(DaltonRoamFolder, "Destroy")
            plot.PlotModels.DaltonSpawn:Clone().Parent = DaltonRoamFolder

            obj.ChildAdded:Connect(function(itemObj)
                module:setupItemRoamings(itemObj, DaltonRoamFolder)
            end)
            for _, itemObj in pairs(obj:GetChildren()) do
                module:setupItemRoamings(itemObj, DaltonRoamFolder)
            end
        elseif obj.Name == "Items" then
            local janitor = Janitor.new()
            janitor:LinkToInstance(obj)
            local DaltonSeatsFolder = Instance.new("Folder", plot)
            DaltonSeatsFolder.Name = "DaltonSeats"
            janitor:Add(DaltonSeatsFolder, "Destroy")

            obj.ChildAdded:Connect(function(itemObj)
                module:setupItemSeats(itemObj, DaltonSeatsFolder)
            end)
            for _, itemObj in pairs(obj:GetChildren()) do
                spawn(function()
                    module:setupItemSeats(itemObj, DaltonSeatsFolder)
                end)
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