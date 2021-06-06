local module = {}

local Resources = require(game.ReplicatedStorage.Resources)
local GameLoop = Resources:LoadLibrary("GameLoop")

module._audioHandler = Resources:LoadLibrary("AudioHandler")

module._status = Resources:LoadLibrary("Status")

module._musicList = {
	-- "Music - Tropical 1";
    "Music - Tropical 2";
    "Music - Tropical Breeze";
	"Music - Tropical Island"
}
module._musicLastPlayedNo = 1

module._allowRepMusic = true

module._resources = require(game.ReplicatedStorage.Resources)
module._enumeration = module._resources:LoadLibrary("Enumeration")
module._tween = module._resources:LoadLibrary("Tween")

module._lastCustom = nil

function module:init()
	spawn(function()
		module:playNextMusic()
	end)
end

module.update = GameLoop.new(function()
	module:playNextMusic()
end, 4) --, "background audio loop")

function module:playNextMusic()
	if not module._allowRepMusic then return end
	
	local tempAudio
	while wait(1) do if module._audioHandler:getAudio(module._musicList[module._musicLastPlayedNo]) then break end end
	tempAudio = module._audioHandler:getAudio(module._musicList[module._musicLastPlayedNo])
	if tempAudio.IsPlaying then return end
	
	module._musicLastPlayedNo += 1
	if module._musicLastPlayedNo > #module._musicList then
		module._musicLastPlayedNo = 1
	end
	
	local audio = module._audioHandler:playAudio(module._musicList[module._musicLastPlayedNo])
	audio.Volume = 1
	audio.SoundGroup = workspace.Music
end

function module:transitionMusic(newAudio)
	if module._lastCustom then module._lastCustom:Stop() end
	module._allowRepMusic = false
	local prevAudio = module._audioHandler:getAudio(module._musicList[module._musicLastPlayedNo])
	
	local inOutSine = module._enumeration.EasingFunction.InOutSine.Value
	newAudio.SoundGroup = workspace.Music
	module._tween(prevAudio, "Volume", 0, inOutSine, 0.3, true)
	wait(0.3)
	newAudio:Play()
	module._tween(newAudio, "Volume", 1, inOutSine, 0.3, true)
	module._lastCustom = newAudio
end

function module:returnMusic()
	local prevAudio = module._audioHandler:getAudio(module._musicList[module._musicLastPlayedNo])
	
	if module._lastCustom then
		local inOutSine = module._enumeration.EasingFunction.InOutSine.Value
		module._tween(module._lastCustom, "Volume", 0, inOutSine, 0.3, true)
		wait(0.3)
	end
	prevAudio:Play()
	local inOutSine = module._enumeration.EasingFunction.InOutSine.Value
	prevAudio.SoundGroup = workspace.Music
	module._tween(prevAudio, "Volume", 1, inOutSine, 0.3, true)
	module._lastCustom = nil
	module._allowRepMusic = true
end

return module
