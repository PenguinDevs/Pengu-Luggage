-- Responsible for initialising modules listed for server
-- @author PenguinDevs

local Resources = require(game.ReplicatedStorage.Resources)
local ServerInitMods = Resources:LoadLibrary("ServerInitMods")
local LoadPriorities = Resources:LoadLibrary("LoadPriorities")

LoadPriorities(ServerInitMods)