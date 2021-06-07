wait(0.2)


local richText = require(script.Parent:FindFirstChild("RichText") or script.Parent.Parent)
script.Parent.Enabled = true

local text = "He thinks about walking at night to avoid the heat and sun, but based upon how dark it actually was the night before, and given that he has no flashlight, he's afraid that he'll break a leg or step on a rattlesnake. <Color=Yellow>So, he puts on some sun block, puts the rest in his pocket for reapplication later, <Color=/>brings an umbrella he'd had in the back of the SUV with him to give him a little shade, pours the windshield wiper fluid into his water bottle in case he gets that desperate, brings his pocket knife in case he finds a cactus that looks like it might have water in it, and heads out in the direction he thinks is right."
local textFrames = {script.Parent.Frame.TextBox1, script.Parent.Frame.TextBox2, script.Parent.Frame.TextBox3}

local initialTextObject = richText:New(textFrames[1], text, {ContainerVerticalAlignment = "Top"}, false)
local latestTextObject = initialTextObject

for i = 2, #textFrames do
	if latestTextObject.Overflown then
		latestTextObject = richText:ContinueOverflow(textFrames[i], latestTextObject)
	end
end

initialTextObject:Animate(true)
