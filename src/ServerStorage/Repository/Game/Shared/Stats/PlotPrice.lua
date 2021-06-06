local module = {}

function module:getPriceFromPlotNo(n)
	return n ^ 2 * 500 + 3000
end

return module
