local sv = require(script.Parent.sv)

local setupTweens = function(frame)
	local children = frame:GetChildren(); table.insert(children,frame)
	local toReturn = { ["open"] = {}, ["close"] = {} }
	for _,v in ipairs(children) do
		local results = {}
		if v:IsA("TextButton") then results[1] = {BackgroundTransparency = 0, TextTransparency = 0}; results[2] = {BackgroundTransparency = 1, TextTransparency = 1}
		elseif v:IsA("ImageLabel") then results[1] = {ImageTransparency = v.ImageTransparency}; results[2] = {ImageTransparency = 1}
		elseif v:IsA("UIStroke") then results[1] = {Transparency = 0}; results[2] = {Transparency = 1}
		elseif v:IsA("UIScale") then results[1] = {Scale = 1}; results[2] = {Scale = 0.5} end
		if results[1] ~= nil then table.insert(toReturn["open"],sv.tweenService:Create(v,TweenInfo.new(0.25),results[1])); table.insert(toReturn["close"],sv.tweenService:Create(v,TweenInfo.new(0.25),results[2])) end
	end
	return toReturn
end

local display = function(x,...)
	local ntype,txt,persistent,callback = ...
	local clone = x:FindFirstChild(ntype):Clone()
	local textSize = sv.textService:GetTextSize(txt,12,Enum.Font.GothamSemibold,Vector2.new(x.AbsoluteSize.X,96))
	local tweens = setupTweens(clone); local cleared = false
	clone.Name = tick(); clone.Text = txt; clone.UIScale.Scale = 0
	clone.Visible = true
	clone.Parent = x
	clone.Size = UDim2.new(0,textSize.X+22,0,textSize.Y+11)
	for _,v in ipairs(tweens["open"]) do v:Play() end
	local function cleanup()
		if callback ~= nil then callback() end
		if cleared or clone.Visible == false then return end
		for _,v in ipairs(tweens["close"]) do v:Play() end
		clone:TweenSize(UDim2.new(0,0,0,0),"Out","Quad",0.25)
		cleared = true; task.wait(0.25); clone:Destroy()
	end
	if persistent == nil then sv.debris:AddItem(clone,(#txt*0.05)+3) end
	clone.Activated:Connect(cleanup)
	return cleanup
end

local setup = function(frame)
	return function(...) display(frame.Notifications,...) end
end

return setup