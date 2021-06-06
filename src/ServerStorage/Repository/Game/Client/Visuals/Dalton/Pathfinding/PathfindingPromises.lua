local require = require(script:FindFirstAncestor("DaltonExpress"):WaitForChild("Loader"))

local Promise = require("Promise")

local PathfindingPromises = {}
PathfindingPromises.ClassName = "PathfindingPromises"

function PathfindingPromises:PromisePathAsync(Path, Start, Finish)
	assert(typeof(Path) == "Instance" and Path:IsA("Path"))
	assert(typeof(Start) == "Vector3" and typeof(Finish) == "Vector3")

	return Promise.new(function(Resolve, Reject)
		Path:ComputeAsync(Start, Finish)

		if Path.Status == Enum.PathStatus.Success then
			return Resolve(Path)
		else
			return Reject("PathfindingPromises - Path Unsuccessful")
		end
	end)
end

return PathfindingPromises