-- Responsible for initialising modules listed for server
-- @PenguinDevs

local Resources = require(game.ReplicatedStorage.Resources)
local ClientInitMods = Resources:LoadLibrary("ClientInitMods")
local LoadPriorities = Resources:LoadLibrary("LoadPriorities")

LoadPriorities(ClientInitMods)