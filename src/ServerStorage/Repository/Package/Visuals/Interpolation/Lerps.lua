-- Lerp functions for most data types, featuring CIELUV Color Lerping
-- @author Validark
-- @author Fraktality
-- @author Sharksie (NumberSequence Lerp)

local Resources = require(game:GetService("ReplicatedStorage"):WaitForChild("Resources"))
local Table = Resources:LoadLibrary("Table")

local function Lerp(Start, Finish, Alpha)
	return Start + Alpha * (Finish - Start)
end

local Color3Lerp do
	-- Combines two colors in CIELUV space.
	-- Color3 LerpCIELUV(Color3 fromColor, Color3 toColor, float t)
	-- @author Fraktality

	-- https://www.w3.org/Graphics/Color/srgb

	local Black = Color3.fromRGB(0, 0, 0)

	function Color3Lerp(c0, c1, t)
		local u0, v0, u1, v1

		-- Convert from linear RGB to scaled CIELUV (RgbToLuv13)
		local r, g, b = c0.r, c0.g, c0.b
		-- Apply inverse gamma correction
		r = r < 0.0404482362771076 and r/12.92 or 0.87941546140213*(r + 0.055)^2.4
		g = g < 0.0404482362771076 and g/12.92 or 0.87941546140213*(g + 0.055)^2.4
		b = b < 0.0404482362771076 and b/12.92 or 0.87941546140213*(b + 0.055)^2.4
		-- sRGB->XYZ->CIELUV
		local y = 0.2125862307855956*r + 0.71517030370341085*g + 0.0722004986433362*b
		local z = 3.6590806972265883*r + 11.4426895800574232*g + 4.1149915024264843*b
		local l0 = y > 0.008856451679035631 and 116*y^(1/3) - 16 or 903.296296296296*y
		if z > 1e-15 then
			u0, v0 = l0*(0.9257063972951867*r - 0.8333736323779866*g - 0.09209820666085898*b)/z, l0*(9*y/z - 0.46832)
		else
			u0, v0 = -0.19783*l0, -0.46832*l0
		end

		-- Convert from linear RGB to scaled CIELUV (RgbToLuv13)
		r, g, b = c1.r, c1.g, c1.b
		-- Apply inverse gamma correction
		r = r < 0.0404482362771076 and r/12.92 or 0.87941546140213*(r + 0.055)^2.4
		g = g < 0.0404482362771076 and g/12.92 or 0.87941546140213*(g + 0.055)^2.4
		b = b < 0.0404482362771076 and b/12.92 or 0.87941546140213*(b + 0.055)^2.4
		-- sRGB->XYZ->CIELUV
		y = 0.2125862307855956*r + 0.71517030370341085*g + 0.0722004986433362*b
		z = 3.6590806972265883*r + 11.4426895800574232*g + 4.1149915024264843*b
		local l1 = y > 0.008856451679035631 and 116*y^(1/3) - 16 or 903.296296296296*y
		if z > 1e-15 then
			u1, v1 = l1*(0.9257063972951867*r - 0.8333736323779866*g - 0.09209820666085898*b)/z, l1*(9*y/z - 0.46832)
		else
			u1, v1 = -0.19783*l1, -0.46832*l1
		end

		-- The inputs aren't needed anymore, so don't drag out their lifetimes
		-- c0, c1 = nil, nil

		-- return function(t)
		-- Interpolate
		local l = (1 - t)*l0 + t*l1
		if l < 0.0197955 then
			return Black
		end
		local u = ((1 - t)*u0 + t*u1)/l + 0.19783
		local v = ((1 - t)*v0 + t*v1)/l + 0.46832

		-- CIELUV->XYZ
		y = (l + 16)/116
		y = y > 0.206896551724137931 and y*y*y or 0.12841854934601665*y - 0.01771290335807126
		local x = y*u/v
		z = y*((3 - 0.75*u)/v - 5)

		-- XYZ->linear sRGB
		r =  7.2914074*x - 1.5372080*y - 0.4986286*z
		g = -2.1800940*x + 1.8757561*y + 0.0415175*z
		b =  0.1253477*x - 0.2040211*y + 1.0569959*z

		-- Adjust for the lowest out-of-bounds component
		if r < 0 and r < g and r < b then
			r, g, b = 0, g - r, b - r
		elseif g < 0 and g < b then
			r, g, b = r - g, 0, b - g
		elseif b < 0 then
			r, g, b = r - b, g - b, 0
		end

		-- Apply gamma correction
		r = r < 3.1306684425e-3 and 12.92*r or 1.055*r^(1/2.4) - 0.055
		g = g < 3.1306684425e-3 and 12.92*g or 1.055*g^(1/2.4) - 0.055
		b = b < 3.1306684425e-3 and 12.92*b or 1.055*b^(1/2.4) - 0.055

		return Color3.new(
			-- Clamp the result
			r > 1 and 1 or r < 0 and 0 or r,
			g > 1 and 1 or g < 0 and 0 or g,
			b > 1 and 1 or b < 0 and 0 or b
		)
		-- end
	end
end

local function sortByTime(a, b)
	return a.Time < b.Time
end

return Table.Lock {
	number = Lerp;
	Color3 = Color3Lerp;
	UDim2 = UDim2.new().Lerp;
	CFrame = CFrame.new().Lerp;
	Vector2 = Vector2.new().Lerp;
	Vector3 = Vector3.new().Lerp;

	string = function(start, finish, alpha)
		-- Very simple, doesn't yet take into account previous string
		local count = #finish
		local a = 1 + count*alpha
		return finish:sub(1, a < count and a or count)
	end;

	UDim = function(start, finish, alpha)
		return UDim.new(Lerp(start.Scale, finish.Scale, alpha), Lerp(start.Offset, finish.Offset, alpha))
	end;

	Rect = function(start, finish, alpha)
		return Rect.new(
			Lerp(start.Min.X, finish.Min.X, alpha), Lerp(start.Min.Y, finish.Min.Y, alpha),
			Lerp(start.Max.X, finish.Max.X, alpha), Lerp(start.Max.Y, finish.Max.Y, alpha)
		)
	end;

	PhysicalProperties = function(start, finish, alpha)
		return PhysicalProperties.new(
			Lerp(start.Density, finish.Density, alpha),
			Lerp(start.Friction, finish.Friction, alpha),
			Lerp(start.Elasticity, finish.Elasticity, alpha),
			Lerp(start.FrictionWeight, finish.FrictionWeight, alpha),
			Lerp(start.ElasticityWeight, finish.ElasticityWeight, alpha)
		)
	end;

	NumberRange = function(start, finish, alpha)
		return NumberRange.new(Lerp(start.Min, finish.Min, alpha), Lerp(start.Max, finish.Max, alpha))
	end;

	ColorSequence = function(start, finish, alpha)
		return ColorSequence.new(Color3Lerp(start[1], finish[1], alpha), Color3Lerp(start[2], finish[2], alpha))
	end;

	Region3 = function(start, finish, alpha) -- @author Sharksie
		local imin = Lerp(start.CFrame * (-start.Size*0.5), finish.CFrame * (-finish.Size*0.5), alpha)
		local imax = Lerp(start.CFrame * ( start.Size*0.5), finish.CFrame * ( finish.Size*0.5), alpha)

		local iminx = imin.x
		local imaxx = imax.x
		local iminy = imin.y
		local imaxy = imax.y
		local iminz = imin.z
		local imaxz = imax.z

		return Region3.new(
			Vector3.new(iminx < imaxx and iminx or imaxx, iminy < imaxy and iminy or imaxy, iminz < imaxz and iminz or imaxz),
			Vector3.new(iminx > imaxx and iminx or imaxx, iminy > imaxy and iminy or imaxy, iminz > imaxz and iminz or imaxz)
		)
	end;

	NumberSequence = function(start, finish, alpha)
		-- @author Sharksie

		-- For each point on each line, find the values of the other sequence at that point in time through interpolation
		-- 	then interpolate between the known value and the learned value
		-- 	then use that value to create a new keypoint at the time
		-- 	then build a new sequence using all the keypoints generated

		local keypoints = {}
		local addedTimes = {}

		for i, ap in next, start.Keypoints do
			local closestAbove, closestBelow

			for i, bp in next, finish.Keypoints do
				if bp.Time == ap.Time then
					closestAbove, closestBelow = bp, bp
					break
				elseif bp.Time < ap.Time and (closestBelow == nil or bp.Time > closestBelow.Time) then
					closestBelow = bp
				elseif bp.Time > ap.Time and (closestAbove == nil or bp.Time < closestAbove.Time) then
					closestAbove = bp
				end
			end

			local bValue, bEnvelope
			if closestAbove == closestBelow then
				bValue, bEnvelope = closestAbove.Value, closestAbove.Envelope
			else
				local p = (ap.Time - closestBelow.Time)/(closestAbove.Time - closestBelow.Time)
				bValue = (closestAbove.Value - closestBelow.Value)*p + closestBelow.Value
				bEnvelope = (closestAbove.Envelope - closestBelow.Envelope)*p + closestBelow.Envelope
			end
			local interValue = (bValue - ap.Value)*alpha + ap.Value
			local interEnvelope = (bEnvelope - ap.Envelope)*alpha + ap.Envelope
			local interp = NumberSequenceKeypoint.new(ap.Time, interValue, interEnvelope)

			table.insert(keypoints, interp)

			addedTimes[ap.Time] = true
		end

		for i, bp in next, finish.Keypoints do
			if not addedTimes[bp.Time] then
				local closestAbove, closestBelow

				for i, ap in next, start.Keypoints do
					if ap.Time == bp.Time then
						closestAbove, closestBelow = ap, ap
						break
					elseif ap.Time < bp.Time and (closestBelow == nil or ap.Time > closestBelow.Time) then
						closestBelow = ap
					elseif ap.Time > bp.Time and (closestAbove == nil or ap.Time < closestAbove.Time) then
						closestAbove = ap
					end
				end

				local aValue, aEnvelope
				if closestAbove == closestBelow then
					aValue, aEnvelope = closestAbove.Value, closestAbove.Envelope
				else
					local p = (bp.Time - closestBelow.Time)/(closestAbove.Time - closestBelow.Time)
					aValue = (closestAbove.Value - closestBelow.Value)*p + closestBelow.Value
					aEnvelope = (closestAbove.Envelope - closestBelow.Envelope)*p + closestBelow.Envelope
				end
				local interValue = (bp.Value - aValue)*alpha + aValue
				local interEnvelope = (bp.Envelope - aEnvelope)*alpha + aEnvelope
				local interp = NumberSequenceKeypoint.new(bp.Time, interValue, interEnvelope)

				table.insert(keypoints, interp)
			end
		end

		table.sort(keypoints, sortByTime)

		return NumberSequence.new(keypoints)
	end;
}
