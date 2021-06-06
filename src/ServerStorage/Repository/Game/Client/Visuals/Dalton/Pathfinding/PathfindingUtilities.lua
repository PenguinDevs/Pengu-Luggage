local PathfindingService = game:GetService("PathfindingService")

local require = require(script:FindFirstAncestor("DaltonExpress"):WaitForChild("Loader"))

local PathfindingPromise = require("PathfindingPromises")
local Maid = require("Maid")
local Promise = require("Promise")
local Signal = require("Signal")
local FastSpawn = require("FastSpawn")

local PathfindingUtilities = {}
PathfindingUtilities.__index = PathfindingUtilities
PathfindingUtilities.ClassName = "PathfindingUtilities"
PathfindingUtilities.DebugDrawing = true
PathfindingUtilities.AgentParameters = {
	AgentCanJump = false;
	AgentRadius = 2;
	AgentHeight = 5;
}

local States = {
	RunningState = {
		Running = "Running";
		Completed = "Completed";
	};
	PathState = {
		None = "None";
		Success = "Success";
		Failure = "Failure";
	};
}

local function DrawWaypoint(Waypoint)
	local Part = Instance.new("Part")
	Part.Material = Enum.Material.Neon
	Part.Anchored = true
	Part.CanCollide = false
	Part.Size = Vector3.new(1, 1, 1)
	Part.Position = Waypoint.Position
	Part.Shape = Enum.PartType.Ball
	Part.Name = "PathWaypoint"
	Part.Parent = workspace.CurrentCamera
	return Part
end

function PathfindingUtilities.new()
	local self = setmetatable({}, PathfindingUtilities)

	self.Maid = Maid.new()
	self._PathFinished = Signal.new() -- internal signal not meant to be waited on to return our states
	self.PathCompletion = Signal.new() -- top level signal meant to be used in scripts to wait on

	self.RunningState = States.RunningState.Completed
	self.PathState = States.PathState.None
	self.Path = PathfindingService:CreatePath(self.AgentParameters)

	self._CurrentPath = nil

	self._PathFinished:Connect(function(PathState)
		self.PathState = PathState
		self.RunningState = States.RunningState.Completed

		self._CurrentPath = nil
		self.Maid:DoCleaning()
		
		self.PathCompletion:Fire()
	end)

	return self
end

function PathfindingUtilities:IsRunStatus(Status)
	return self.RunningState == Status
end

function PathfindingUtilities:IsPathStatus(Status)
	return self.PathState == Status
end

function PathfindingUtilities:DidPathComplete()
	return self.PathState == States.PathState.Success
end

function PathfindingUtilities:FindPathTo(Start, Finish, Blocked)
	if Blocked then
		assert(type(Blocked) == "function")
	end

	self.RunningState = States.RunningState.Running
	self.PathState = States.PathState.None

	self._CurrentPath = PathfindingPromise:PromisePathAsync(self.Path, Start, Finish):Then(function(ComputedPath)

		self.Maid.Blocked = ComputedPath.Blocked:Connect(function(WaypointIndex)
			self.PathState = States.PathState.Failure
			self.RunningState = States.RunningState.Completed

			if Blocked then
				FastSpawn(Blocked, WaypointIndex)
			end

			self._CurrentPath = nil
			self.Maid.Blocked = nil
		end)

		return ComputedPath:GetWaypoints()
	end, function(Err)
		self:_ResetStates(States.PathState.None)
		return Promise.Rejected()
	end)

	return self._CurrentPath
end

function PathfindingUtilities:WalkToPoints(Object)
	if not self._CurrentPath then
		return States.PathState.None
	end

	return self._CurrentPath:Then(function(Waypoints)

		assert(type(Waypoints) == "table", self.ClassName .. " - Waypoints must be a table")
		assert(Object.MoveTo and type(Object.MoveTo) == "function", "Object must contain a MoveTo function")
		assert(Object.MoveToFinished, "Object must contain a MoveToFinished signal")

		-- avoid the first waypoint at origin(dividing by zero returns NaN in custom move to functions)
		for i = 2, #Waypoints do
			local Waypoint = Waypoints[i]

			if self:IsPathStatus("Failure") then
				return self.PathState
			end
			if self.DebugDrawing then
				self.Maid:GiveTask(DrawWaypoint(Waypoint))
			end

			Object:MoveTo(Waypoint.Position, true) -- remove this true in any other case
			Object.MoveToFinished:Wait()
		end
		-- if we had no path, it wouldve returned none already
		-- resolve to success

		return States.PathState.Success
	end)
end

function PathfindingUtilities:_ResetStates(PathState)
	self.RunningState = States.RunningState.Completed
	self.PathState = PathState
end

function PathfindingUtilities:Destroy()
	self._PathFinished:Destroy()
	self.PathCompletion:Destroy()

	self.Maid:DoCleaning()
end

return PathfindingUtilities