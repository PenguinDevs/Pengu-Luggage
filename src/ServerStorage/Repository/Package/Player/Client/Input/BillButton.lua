local module = {}

module._resources = require(game.ReplicatedStorage.Resources)
module._signal = module._resources:LoadLibrary("Signal")

module._player = game.Players.LocalPlayer
module._bills = module._player.PlayerGui:WaitForChild("Bills", math.huge)

local userInputService = game:GetService("UserInputService")

local runService = game:GetService("RunService")

function module.new(adornee, distance, inputs)
	local billButton = {}
	
	billButton.inputBegan = module._signal.new()
	billButton.inputEnd = module._signal.new()
	
	billButton._inputs = {}
	
	billButton._inputDown = false
	
	billButton.ui = game.ReplicatedStorage.Assets.Particles.ButtonGui:Clone()
	billButton.ui.Parent = module._bills
	billButton.ui.Adornee = adornee
	
	function billButton:destruct()
		billButton.inputBegan:Destroy()
		billButton.inputEnd:Destroy()
		billButton._inputBeganListener:Disconnect()
		billButton._inputEndedListener:Disconnect()
		billButton._visibilityCheck:Disconnect()
		billButton.ui:Destroy()
		billButton = nil
	end
	
	function billButton:bindInputs(inputs)
		for _, input in pairs(inputs) do
			if input == "touch" then
				billButton.ui.Button.MouseButton1Down:Connect(function()
					billButton.inputBegan:Fire()
				end)
				billButton.ui.Button.MouseButton1Up:Connect(function()
					billButton.inputEnd:Fire()
				end)
			else
				billButton._inputs[Enum.KeyCode[input]] = Enum.KeyCode[input]
				billButton.ui.Button.Key.Text = input
			end
		end
	end
	
	billButton:bindInputs(inputs)
	
	local function inputFind(input, callback)
		local temp = billButton._inputs[input.UserInputType]
		if temp then
			callback() return
		elseif input.UserInputType == Enum.UserInputType.Keyboard then
			temp = billButton._inputs[input.KeyCode]
			if temp then callback() return end
		end
	end
	
	billButton._inputBeganListener = userInputService.InputBegan:Connect(function(input, proc)
		if (module._player.Character.HumanoidRootPart.Position - adornee.Position).magnitude > distance then return end
		billButton._inputDown = true
		if not proc then
			local function callback() billButton.inputBegan:Fire() end
			inputFind(input, callback)
		end
	end)
	
	billButton._inputEndedListener = userInputService.InputEnded:Connect(function(input, proc)
		if (module._player.Character.HumanoidRootPart.Position - adornee.Position).magnitude > distance then return end
		local function callback() billButton.inputEnd:Fire() end
		inputFind(input, callback)
	end)
	
	billButton._visibilityCheck = runService.RenderStepped:Connect(function()
		if not module._player.Character then return end
		if not module._player.Character:FindFirstChild("HumanoidRootPart") then return end
		if (module._player.Character.HumanoidRootPart.Position - adornee.Position).magnitude > distance then
			billButton.ui.Enabled = false
			if billButton._inputDown then
				billButton._inputDown = false
				billButton.inputEnd:Fire()
			end
		else
			billButton.ui.Enabled = true
		end
	end)
	
	return billButton
end

return module
