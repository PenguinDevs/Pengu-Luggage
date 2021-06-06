local module = {}

module.cached = {}

module.parentStore = {}

module.props = {}

module._count = 0

function module:addItem(obj, amount, parent, type, propsList)
	module.parentStore[type] = parent
	if not module.cached[type] then module.cached[type] = {} end
	for i = 1, amount do
		local clonedObj = obj:Clone()
		module.cached[type][clonedObj] = {obj = clonedObj, available = true}
		clonedObj.Visible = false
		clonedObj.Parent = module.parentStore[type]
		module._count += 1
	end
	module.props[type] = {}
	for _, prop in pairs(propsList) do
		module.props[type][prop] = obj[prop]
	end
end

function module:getItem(type)
	local randObj = nil
	for _, cachedStat in pairs(module.cached[type]) do
		randObj = cachedStat.obj
		if cachedStat.available then
			cachedStat.available = false
			return cachedStat.obj
		end
	end
	local leftObj = randObj:Clone()
	module.cached[type][leftObj] = {obj = leftObj, available = true}
	leftObj.Visible = true
	leftObj.Parent = module.parentStore[type]
	module._count += 1
	warn("created new", type, "current cache amount:", module._count)
	return leftObj
end

function module:returnProps(obj, type)
	for prop, val in pairs(module.props[type]) do
		obj[prop] = val
	end
	obj.Visible = true
end

function module:returnItem(obj, type)
	obj.Visible = false
	module.cached[type][obj].available = true
	for prop, val in pairs(module.props[type]) do
		obj[prop] = val
		--print(prop, val, obj[prop])
	end
end

return module
