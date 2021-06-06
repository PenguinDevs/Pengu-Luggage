-- Callable Instance.new wrapper
-- @author Validark

local Instance_new = Instance.new

local function Make(InstanceType)
	local function ClosureFunction(Table, ...)
		local Object = Instance_new(InstanceType)
		local Parent = Table.Parent
	
		if Parent then
			Table.Parent = nil
		end
	
		for Property, Value in next, Table do
			if type(Property) == "number" then
				Value.Parent = Object
			else
				Object[Property] = Value
			end
		end
	
		if Parent then
			Object.Parent = Parent
		end
	
		if ... then
			local Objects = {...}
			for a = 1, #Objects do
				local Object = Object:Clone()
				for Property, Value in next, Objects[a] do
					if type(Property) == "number" then
						Value.Parent = Object
					else
						Object[Property] = Value
					end
				end
				Object.Parent = not Object.Parent and Parent
				Objects[a] = Object
			end
			return Object, unpack(Objects)
		else
			return Object
		end
	end
	
	return ClosureFunction
end

return Make