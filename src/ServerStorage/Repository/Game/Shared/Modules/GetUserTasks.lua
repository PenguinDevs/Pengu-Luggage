local module = {}

function module.getPlacing(level)
    return level * 2 - 1, level * 50
end

function module.getFill(level)
    return level * 3 - 2, level * 50
end

return module