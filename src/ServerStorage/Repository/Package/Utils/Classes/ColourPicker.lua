local module = {}

local Resources = require(game.ReplicatedStorage.Resources)
local Janitor = Resources:LoadLibrary("Janitor")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local GuiService = game:GetService("GuiService")
local Color = Resources:LoadLibrary("Color")
local Signal = Resources:LoadLibrary("Signal")

function module.new()
    local handler = {}

    handler.janitor = Janitor.new()

    function handler:Destroy()
        handler.janitor:Cleanup()
        handler = nil
    end

    handler.colourDecidedSignal = Signal.new()
    handler.janitor:Add(handler.colourDecidedSignal, "Destroy")

    handler.cp = {}
    handler.cp.sat = 1
    handler.cp.hue = 1
    handler.cp.val = 1
    handler.cp.c3 = Color3.fromRGB(134, 134, 134)

    function handler:updateColour(c3)
        handler.uiColour.BackgroundColor3 = c3
        handler.cp.c3 = c3
        local mousePosition = UserInputService:GetMouseLocation() - GuiService:GetGuiInset()
        handler.cp.hue, handler.cp.sat, handler.cp.val = c3:ToHSV()
        local function renderVal()
            handler.ui.ColourCircle.Val.Chosen.Position = UDim2.fromScale(0.5, 1 - handler.cp.val)
        end
        local function renderSatHue()
            local uiAbsoluteSize = handler.ui.ColourCircle.AbsoluteSize
            local maxRadius = uiAbsoluteSize.x/2
            local uiAbsoluteSizeCent = handler.ui.ColourCircle.AbsolutePosition + uiAbsoluteSize/2
            local angle = handler.cp.hue * 360
            local offsetMag = handler.cp.sat
            local unitPos = Vector2.new(math.cos(math.rad(angle)), math.sin(math.rad(angle)))
            local offset = unitPos/2 * offsetMag
            handler.ui.ColourCircle.Chosen.Position = UDim2.fromScale(offset.X + 0.5, offset.Y + 0.5)
        end
        renderVal()
        renderSatHue()
        handler.ui.HexBox.Text = "#" .. Color.toHex(c3)
    end

    handler.ui = nil
    handler.uiColour = nil

    function handler:init(ui, uiColour)
        handler.ui = ui
        handler.uiColour = uiColour
        local function isButton1Up()
            local buttons = UserInputService:GetMouseButtonsPressed()
            local isUp = true
            for _, button in pairs(buttons) do
                if button.UserInputType.Name == "MouseButton1" then
                    isUp = false
                    break
                end
            end
            return isUp
        end
        handler.janitor:Add(ui.ColourCircle.Val.Hold.MouseButton1Down:Connect(function()
            local pickerBind
            pickerBind = RunService.RenderStepped:Connect(function()
                local mousePosition = UserInputService:GetMouseLocation() - GuiService:GetGuiInset()
                local function calculateVal()
                    local uiAbsoluteSize = ui.ColourCircle.Val.AbsoluteSize
                    local uiAbsolutePos = ui.ColourCircle.AbsolutePosition
                    local offset = ui.ColourCircle.AbsolutePosition - mousePosition
                    local amount = 1 - (offset.Y/-uiAbsoluteSize.Y)
                    handler.cp.val = math.clamp(amount, 0, 1)
                end
                calculateVal()
                handler:updateColour(Color3.fromHSV(handler.cp.hue, handler.cp.sat, handler.cp.val))

                if isButton1Up() then pickerBind:Disconnect() handler.colourDecidedSignal:Fire(handler.cp.c3) return end
            end)
            --local releaseBind = ui.ColourCircle.Val.Hold.MouseButton1Up:Connect(function()
            --    pickerBind:Disconnect()
            --    if releaseBind then releaseBind:Disconnect() end
           -- end)
        end), "Disconnect")
        handler.janitor:Add(ui.ColourCircle.Hold.MouseButton1Down:Connect(function()
            local pickerBind
            pickerBind = RunService.RenderStepped:Connect(function()
                local mousePosition = UserInputService:GetMouseLocation() - GuiService:GetGuiInset()
                local function calculateSatHue()
                    local uiAbsoluteSize = ui.ColourCircle.AbsoluteSize
                    local maxRadius = uiAbsoluteSize.x/2
                    local uiAbsoluteSizeCent = ui.ColourCircle.AbsolutePosition + uiAbsoluteSize/2
                    local offset = mousePosition - uiAbsoluteSizeCent
                    local angleForCalc = CFrame.new(Vector3.new(0, 0, 0), Vector3.new(offset.x, 0, offset.y)).lookVector
                    local angle = math.deg(math.atan2(angleForCalc.x, angleForCalc.z))
                    if offset.magnitude <= maxRadius then 
                        if angle < 0 then
                            angle = 360 + angle
                        end
                        angle = 360 - angle + 90
                        if angle > 360 then
                            angle = 90 - (450 - angle)
                        end

                        handler.cp.sat = math.clamp(offset.magnitude/maxRadius, 0, 1)
                        handler.cp.hue = math.clamp(angle/360, 0, 1)
                    end
                end
                calculateSatHue()
                handler:updateColour(Color3.fromHSV(handler.cp.hue, handler.cp.sat, handler.cp.val))

                if isButton1Up() then pickerBind:Disconnect() handler.colourDecidedSignal:Fire(handler.cp.c3) return end
            end)
            --local releaseBind = ui.ColourCircle.Val.Hold.MouseButton1Up:Connect(function()
            --    pickerBind:Disconnect()
            --    if releaseBind then releaseBind:Disconnect() end
            --end)
        end), "Disconnect")
        handler.janitor:Add(ui.HexBox.FocusLost:Connect(function(enterPressed, inputThatCausedFocusLost)
            --if enterPressed then
            local hex = ui.HexBox.Text
            --if #hex == 6 then 
            --    
            --elseif #hex == 7 then
            --    if string.sub(hex, 1, 1) == "#" then
            --       hex = string.sub(hex, 2)
            --    end
            --else
            --    return
            --end
            local c3 = Color.fromHex(hex)
            if not c3 then return end
            handler:updateColour(c3)
            handler.colourDecidedSignal:Fire(handler.cp.c3)
            --end
        end), "Disconnect")
        handler:updateColour(Color3.fromRGB(134, 134, 134))
    end

    return handler
end

return module