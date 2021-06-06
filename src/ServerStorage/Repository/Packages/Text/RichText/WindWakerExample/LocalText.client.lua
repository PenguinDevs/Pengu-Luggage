-- Rich text Wind Waker example: -- https://youtu.be/CY3ghdwL9W4?t=4m34s	https://twitter.com/Defaultio/status/903138250054709248

-- Make sure the RichText module is parented to this ScreenGui

local richText = require(script.Parent:FindFirstChild("RichText") or script.Parent.Parent)
script.Parent.Enabled = true
local tweenService = game:GetService("TweenService")
local dialogueFrame = script.Parent.Dialogue
local textFrame = dialogueFrame.TextFrame
local buttonA = dialogueFrame.Button
dialogueFrame.Visible = false
buttonA.Visible = false

local buttonFadeIn = tweenService:Create(buttonA, TweenInfo.new(0.1), {ImageTransparency = 0})
local buttonFadeOut = tweenService:Create(buttonA, TweenInfo.new(0.1), {ImageTransparency = 1})
local buttonClickTween = tweenService:Create(buttonA, TweenInfo.new(0.05, Enum.EasingStyle.Quart, Enum.EasingDirection.InOut), {Size = UDim2.new(0.25, 0, 0.25, 0)})
local frameFadeIn = tweenService:Create(dialogueFrame, TweenInfo.new(0.4), {Size = dialogueFrame.Size, ImageTransparency = 0})
local frameFadeOut = tweenService:Create(dialogueFrame, TweenInfo.new(0.4), {ImageTransparency = 1})


local function showButton()
	buttonA.Size = UDim2.new(0.3, 0, 0.3, 0)
	buttonA.Visible = true
	buttonFadeIn:Play()
	wait(buttonFadeIn.TweenInfo.Time)
end

local function clickButton()
	buttonClickTween:Play()
	wait(buttonClickTween.TweenInfo.Time)
	buttonFadeOut:Play()
	wait(buttonFadeOut.TweenInfo.Time)
	buttonA.Visible = false
end

local function showFrame()
	dialogueFrame.Size = UDim2.new(0.4, 0, 0.1, 0)
	dialogueFrame.ImageTransparency = 1
	dialogueFrame.Visible = true
	frameFadeIn:Play()
	wait(frameFadeIn.TweenInfo.Time)
end

local function hideFrame()
	frameFadeOut:Play()
	wait(frameFadeOut.TweenInfo.Time)
	dialogueFrame.Visible = false
end

local function showDialogue(text, delayTime)
	local textObject = richText:New(textFrame, text, {Font = "Cartoon"})--, AnimateStyle = "Wiggle", AnimateStepFrequency = 1, AnimateStyleTime = 7, AnimateStyleNumPeriods = 10})
	textObject:Animate(true)
	showButton()
	wait(delayTime)
	clickButton()
	textObject:Hide()
end




local textSequence = {{Text = "I just saw a <Color=Red>wild<Color=/>...a <AnimateStyle=Wiggle><Color=Red>wild pig🐷<Color=/>!<AnimateYield=1><AnimateStyle=/>\nOoh! See? Look! That black one there...<AnimateYield=1>\nDon't you see him?", Delay = 1.5},
					{Text = "<AnimateYield=0.3>This is perfect! My wife was just telling me how she really wanted a pet...", Delay = 2.7},
					{Text = "You ready to go grab it, Link?<AnimateYield=0.3>\n Now, you can't just run up on it!\nPigs are too alert to their surroundings for you to just jog up and capture one.", Delay = 3.5},
					{Text = "If you want to get close to one, you have to hold <Img=1014975764> to crouch and tilt <Img=1014975761> to crawl slowly up behind it. <AnimateYield=1.5>Slow<AnimateYield=1>ly...", Delay = 3},
					{Text = "You could also distract it with bait, I guess.", Delay = 1.5},
}


--This is the animation example:
--local textSequence = {{Text = "This text is about to be <Color=Green><AnimateStyle=Wiggle><AnimateStepFrequency=1><AnimateStyleTime=2>wiggly<AnimateStyle=/><AnimateStepFrequency=/><AnimateStyleTime=/><Color=/>!<AnimateYield=1.5>\nIt can also be <Color=Red><AnimateStyle=Fade><AnimateStepFrequency=1><AnimateStyleTime=0.5>fadey <Img=Eggplant>fadey<AnimateStyle=/><AnimateStepFrequency=/><AnimateStyleTime=/><Color=/>!<AnimateYield=1>\n<AnimateStyle=Rainbow><AnimateStyleTime=2>Or rainbow!!! :O<Img=Thinking><AnimateStyle=/><AnimateStyleTime=/><AnimateYield=1>\n<AnimateStyle=Swing><AnimateStyleTime=3>Make custom animations! <Img=Eggplant>", Delay = 10}}

--This is a text justification example:
--local textSequence = {{Text = "Have you ever <Color=Red>thought<Color=/><AnimateStepFrequency=1><AnimateStepTime=0.4> . . .<AnimateStepFrequency=/><AnimateStepTime=/><AnimateYield=1><ContainerHorizontalAlignment=Center>\n<TextScale=0.5><AnimateStyle=Rainbow><AnimateStyleTime=2.5><Img=Thinking><AnimateStyle=/><TextScale=/><AnimateYield=3><ContainerHorizontalAlignment=Right>\n<Color=Green><AnimateStyle=Spin><AnimateStyleTime=1.5>Wow<AnimateStyle=/><Color=/>!", Delay = 10}}

wait(2)

showFrame()
for _, v in pairs(textSequence) do
	showDialogue(v.Text, v.Delay)
end
hideFrame()

