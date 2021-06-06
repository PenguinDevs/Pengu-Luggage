local handler = {}

local contentProvider = game:GetService("ContentProvider")

handler.collectedAudio = {}

function handler:preloadAudio(assetArray)
	local audioAssets = {}

	-- Add new "Sound" assets to "audioAssets" array
	for name, audioID in pairs(assetArray) do
		spawn(function()
			local audioInstance = Instance.new("Sound")
			audioInstance.SoundId = "rbxassetid://" .. audioID
			audioInstance.Name = name
			audioInstance.Parent = game.Workspace
			table.insert(audioAssets, audioInstance)
			table.insert(handler.collectedAudio, 1, audioInstance)
		end)
	end
 
	local success, assets = pcall(function()
		contentProvider:PreloadAsync(audioAssets)
	end)
end

spawn(function()
	handler:preloadAudio({
		-- ["Music - Tropical 1"] = 6462734661; -- FracturedDev
        ["Music - Tropical 2"] = 5283149752; -- ROBLOX
        ["Music - Tropical Breeze"] = 1836861073; -- ROBLOX
		["Music - Tropical Island"] = 1837464887; -- ???

		--["Pop"] = 1551224982; -- Invecy
		["Pop"] = 1289263994; -- superlaser60
        ["Click"] = 4658309128; -- DangerBarrel
        ["Hover"] = 5940560840; -- ROBLOX
		["Cha Ching"] = 6789474076; -- PenguinDevs
		["Error"] = 1388726556; -- IggyTheBonker
	})
end)

function handler:getAudio(assetName)
	local audio = workspace:FindFirstChild(assetName) or workspace:WaitForChild(assetName)
	if not audio then
		warn("Could not find audio asset: " .. assetName)
		return
	end
	return audio
end

function handler:playAudio(assetName)
	local audio = handler:getAudio(assetName)
	if not audio then return end
	if not audio.IsLoaded then
		audio.Loaded:wait()
	end
	audio:Play()
	return audio
end

function handler:stopAudio(assetName)
	local audio = handler:getAudio(assetName)
	audio:Stop()
	return audio
end

return handler
