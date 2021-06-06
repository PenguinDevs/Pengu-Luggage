local module = {}

local Resources = require(game.ReplicatedStorage.Resources)
local Status = Resources:LoadLibrary("Status")
local VectorTable = Resources:LoadLibrary("VectorTable")
local Janitor = Resources:LoadLibrary("Janitor")
local ItemStats = Resources:LoadLibrary("ItemStats")
local RoundDown = Resources:LoadLibrary("RoundDown")

module.maps = {}
module.mapParts = {}
module.build1Collected = {}

local debug = true
local debugJanitor

function getOffsetFromRotation(size, rotation)
	local x = size.X
	local y = size.Y
	if rotation == 1 then
		x *= -1
		x += 4
		y -= 4
	elseif rotation == 2 then
		local tempX = x
		local tempY = y
		x = -tempY + 4
		y = -tempX + 4
	elseif rotation == 3 then
		y *= -1
		y += 4
		x -= 4
	elseif rotation == 4 then
		local tempX = x
		local tempY = y
		x = tempY - 4
		y = tempX - 4
	end
	return -Vector3.new(x, 0, y)/2 --+ Vector3.new(2, 0, -2)
end

function module:updateMap(plotNo)
    if plotNo == false then plotNo = Status.game.plotNo end
    --print("calculating map", plotNo)
    local plot = workspace.Game.PlayerPlots:FindFirstChild(tostring(plotNo)).Plot
    local build1 = Status.game[string.format("p%sbuild1", plotNo)]
    if not build1 then return warn("Cannot calculate", plotNo, "map because build1 has not been received for this plot") end
    module.build1Collected[plotNo] = build1
    
    local function loadMap()
        local available = {}

        if debugJanitor then
            debugJanitor:Cleanup()
        end
        if debug then
            debugJanitor = Janitor.new()
        end
        local function v3FromV2(v2)
            local origin = Vector3.new(2, 0, 30)
            local v3 = -Vector3.new(v2.X * 4, 0, v2.Y * 4) + origin
            return plot["0:0"].Mid.CFrame * v3
        end
        local function debugPart(iPos, color)
            local v2 = VectorTable.rconvert(iPos)
            local targetCF = CFrame.new(v3FromV2(v2))
            local part = Instance.new("Part", workspace)
            debugJanitor:Add(part, "Destroy")
            part.Size = Vector3.new(4, 1, 4)
            part.Anchored = true
            part.CanCollide = false
            part.Transparency = 0.5
            part.CFrame = targetCF
            part.Color = color
        end

        for floorIPos, _ in pairs(build1.floors) do
            local v2 = VectorTable.rconvert(floorIPos)
            local minPos = v2 * 4 + Vector2.new(-3, 0)
            local maxPos = minPos + Vector2.new(4, 4)
            for x = 1, maxPos.X - minPos.X do
                x += minPos.X - 1
                for y = 1, maxPos.Y - minPos.Y do
                    y += minPos.Y - 1
                    available[VectorTable.convert(Vector2.new(x, y))] = true
                end
            end
        end

        for itemPos, itemDet in pairs(build1.items) do
            local itemStat = ItemStats[itemDet.item]
            local pos0 = VectorTable.rconvert(itemPos)
            local offset = getOffsetFromRotation(itemStat.size, itemDet.rot)
            local pos1 = pos0-- + Vector2.new(offset.X, offset.Z)
            local pos2 = pos0 - Vector2.new(offset.X, offset.Z)/2
            
            local startX = (pos1.X < pos2.X) and pos1.X or pos2.X
            local endX = (startX == pos2.X) and pos1.X or pos2.X
            local startY = (pos1.Y < pos2.Y) and pos1.Y or pos2.Y
            local endY = (startY == pos2.Y) and pos1.Y or pos2.Y
            for x = startX, endX do
                for y = startY, endY do
                    available[VectorTable.convert(Vector2.new(x, y))] = nil
                end
            end
        end

        local collectedMapParts = {}
        -- local map = {}
        -- local length = (5 * 4 * 4)
        -- for y = 1, length do
        --     local origY = y
        --     y -= 1
        --     for x = 1, length do
        --         local origX = x
        --         x -= 5 * 4 * 2
        --         local v2 = Vector2.new(x, y)
        --         local iPos = VectorTable.convert(v2)
        --         if not map[origY] then map[origY] = {} end
        --         if available[iPos] then
        --             debugPart(iPos, Color3.fromRGB(255, 255, 0))
        --             map[origY][x] = 0

        --             local partV2 = v2/4
        --             local partIPos = VectorTable.convert(Vector2.new(RoundDown(partV2.X), RoundDown(partV2.Y)))
        --             local part = collectedMapParts[partIPos] or {}
        --             table.insert(part, 1, v3FromV2(v2))
        --             collectedMapParts[partIPos] = part
        --         else
        --             map[origY][x] = 1
        --         end
        --     end
        -- end
        -- module.maps[plotNo] = map

        for iPos in pairs(available) do
            local v2 = VectorTable.rconvert(iPos)
            local partV2 = v2/4
            local partIPos = VectorTable.convert(Vector2.new(RoundDown(partV2.X), RoundDown(partV2.Y)))
            local part = collectedMapParts[partIPos] or {}
            table.insert(part, 1, v3FromV2(v2))
            collectedMapParts[partIPos] = part
        end

        module.mapParts[plotNo] = {}
        for _, part in pairs(collectedMapParts) do
            table.insert(module.mapParts[plotNo], 1, part)
        end

        -- if debug then
        --     for iPos in pairs(available) do
        --         debugPart(iPos, Color3.fromRGB(0, 255, 0))
        --     end
        -- end
    end

    if plotNo == Status.game.visiting then
        --print("loading visiting map", plotNo)
        loadMap()
    elseif not Status.game.visiting and plotNo == Status.game.plotNo then
        --print("loading home map", plotNo)
        loadMap()
    else
        --print("hiding other map", plotNo)
    end
end

function module:getRandomPart(plotNo)
    local none = {Vector3.new(10000, 10000, 10000), Vector3.new(10000, 10000, 10000)}
    if not plotNo then print("received a nil plotno") return none end
    local tab = module.mapParts[plotNo]
    if not tab then return none end
    local randChosen
    if #tab <= 1 then
        randChosen = {Vector3.new(0, 0, 0)}
    else
        randChosen = tab[math.random(1, #tab)]
    end
    return randChosen
end

return module