-- A player class, stores user's data, gamepasses owned as well as modules
-- @author PenguinDevs

local module = {}

local player = {}
player.__index = player

local Resources = require(game.ReplicatedStorage.Resources)
local Janitor = Resources:LoadLibrary("Janitor")
local PlayerService = game:GetService("Players")
local LoadPriorities = Resources:LoadLibrary("LoadPriorities")
local PlayerInitMods = require(script.InitMods)
local Signal = Resources:LoadLibrary("Signal")
local Promise = Resources:LoadLibrary("Promise")

local RetPlayerSig = Signal.new()

local collectedPlayers = {}

function player.new(playerObj)
    local self = setmetatable({}, player)

    self.janitor = Janitor.new()

    self.player = playerObj
    self.id = self.player.UserId
    self.name = self.player.Name

    collectedPlayers[self.player] = self

    self.joinedTime = os.time()
    self.joinedTick = os.clock()

    self.leaveEvent = Signal.new()
    self.player.AncestryChanged:Connect(function()
        if self.player:IsDescendantOf(game) then return end
        self.leaveEvent:Fire()
    end)

    self.leaveEvent:Connect(function()
        -- print(self, getmetatable(self))
        self:Destroy()
    end)

    self.janitor:Add(function()
        collectedPlayers[self.player] = nil
    end)

    Promise.new(function(...)
        self:retrieveMods(...)
    end):andThen(function()
        -- DEBUGGING PLAYER MODS GOES HERE
        -- print("passes", self.passes)
    end):catch(function(err)
        self.playerObj:Kick(string.format("FATAL ERROR || SERVER PLAYER INIT || RETRIEVE MODS || %s", err))
    end)

    RetPlayerSig:Fire()
    
    return self
end

function player:retrieveMods(resolve, reject)
    local s, err = LoadPriorities(PlayerInitMods, self)
    if s then
        resolve()
    else
        reject(err)
    end
end

function player:Destroy()
    -- print("destroying", self, self.janitor, Janitor.new(), getmetatable(self.janitor), getmetatable(Janitor.new()))
    self.janitor:Cleanup()
end

function module:init()
    PlayerService.PlayerAdded:Connect(player.new)
    for _, playerObj in pairs(PlayerService:GetPlayers()) do player.new(playerObj) end
end

function module:get(player)
    local PlayerProfile

    local MAX_RETRIES = 10
    local DELAY = 2

    Promise.retry(function()
        return Promise.new(function(resolve, reject)
            PlayerProfile = collectedPlayers[player]
            if PlayerProfile then
                resolve(PlayerProfile)
            else
                wait(DELAY)
                reject()
            end
        end)
    end, MAX_RETRIES)
    :catch(function(err)
        warn(string.format("ERROR WHEN RETRIEVING PLAYER CLASS || %s", err))
    end):andThen(function(retPlayerProfile)
        PlayerProfile = retPlayerProfile
    end)

    return PlayerProfile
end

return module