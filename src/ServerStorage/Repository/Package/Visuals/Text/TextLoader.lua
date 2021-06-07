local module = {}

local runService = game:GetService("RunService")

local function round(n)
	return math.floor(n + 0.5)
end

local function numbToString(n)
	--	local tempNumb = tostring(n)
	--	if tempNumb:sub(4, 4) == "e" then
	--		local amount = tonumber(tempNumb:sub(6))
	--		local finalString = tempNumb:sub(0, 1)..tempNumb:sub(3, 3)
	--		for i = 1, amount do
	--			finalString = finalString.."0"
	--		end
	--		return finalString
	--	elseif tempNumb:sub(2, 2) == "e" then
	--		local amount = tonumber(tempNumb:sub(4))
	--		local finalString = tempNumb:sub(0, 1)
	--		for i = 1, amount do
	--			finalString = finalString.."0"
	--		end
	--		return finalString
	--	else
	--		return tempNumb
	--	end
	return ("%.0f"):format(n)
end

local identifierList = {
	"K";
	"M";
	"B";
	"T";
	"Qd";
	"Qt";
	"Sx";
	"Sp";
	"Oc";
	"No";
	"D";
	"Ud";
	"Dd";
	"Td";
	"Qtd";
	"Qdd";
	"Sd";
	"Spd";
	"Od";
	"Nd";
	"Vt";
	"Ct";
};

function toSuffixString(n)
	for i = #identifierList, 1, -1 do
		local v = math.pow(10, i * 3)
		--print(("%.0f"):format(v))
		if n >= v then
			return ("%.0f"):format(n / v) .. identifierList[i]
		end
	end
	return tostring(n)
end

function module:ConvertComma(num)
	-- local R_Num = round(num)
	-- local x = tostring(R_Num)
	-- if #x>= 13 then
	-- 	local important = (#x-12)
	-- 	return x:sub(0,(important))..","..x:sub(important+1,important+3)..","..x:sub(important+4,important+6)..","..x:sub(important+7,important+9)..","..x:sub(important+10)
	-- elseif #x>= 10 then
	-- 	local important = (#x-9)
	-- 	return x:sub(0,(important))..","..x:sub(important+1,important+3)..","..x:sub(important+4,important+6)..","..x:sub(important+7)
	-- elseif #x>=7 then
	-- 	local important = (#x-6)
	-- 	return x:sub(0,(important))..","..x:sub(important+1,important+3)..","..x:sub(important+4)
	-- elseif #x>=4 then
	-- 	return x:sub(0,(#x-3))..","..x:sub((#x-3)+1)
	-- else
	-- 	return tostring(x)
	-- end

	local R_Num = round(num)
	local text = string.reverse(tostring(R_Num))
	local finalText = ""
	for i = 1, #text do
		finalText = finalText .. string.sub(text, i, i) -- text[i] -- string.sub(text, 1, i)
		if i % 3 == 0 and string.sub(text, i + 1, i + 1) ~= "" then
			finalText = finalText .. ","
		end
	end
	finalText = string.reverse(finalText)
	return finalText
end

function module:ConvertShort(Filter_Num)
	local R_Num = round(Filter_Num)
	local x = numbToString(R_Num)
	if #x<=3 then
		return x
	else
		local numberOfIdentifiers = #identifierList
		for i = 1, numberOfIdentifiers do
			local o = (numberOfIdentifiers - i) * 3 
			if #x >= o + 1 then
				--				local important = (#x - o + 1)
				--				print(important)
				--				print(x:sub(0,(important - 1)))
				--				print(x:sub(#x-important,(#x-important)))
				--				return x:sub(0,(important - 1)).."."..x:sub(#x-important,(#x-important))..identifierList[numberOfIdentifiers - i]
				local important = #x - o + 1
				local importantString = x:sub(0, important)
				if importantString:sub(#importantString, #importantString) == "0" then
					return importantString:sub(0, #importantString - 1)..identifierList[numberOfIdentifiers - i]
				else
					return importantString:sub(0, #importantString - 1).."."..importantString:sub(#importantString, #importantString)..identifierList[numberOfIdentifiers - i]
				end
			end
		end
	end
end

module.numTicks = {}

function module:numTick(oldNum, newNum, caller, id)
	if not id then id = "1" end
	local mainTick = tick()
	module.numTicks[id] = mainTick
	local timeToTake = 0.05
	local amount = 6
	
	local incrAmount
	local direction = 1
	
	incrAmount = (newNum - oldNum)/amount
	
	if (newNum - oldNum) == 1 then caller(newNum) return end
	
	for i = 1, 6 do
		if module.numTicks[id] > mainTick then break end
		caller(oldNum + (incrAmount * i * direction))
		wait(timeToTake/amount)
		--[[if runService:IsClient() then
			runService.RenderStepped:Wait()
		end]]--
	end
end

return module
