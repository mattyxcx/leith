return function(args)
    local function setup(Button)
        Button.MouseButton1Down:Connect(function(x,y)
            local pos = UDim2.new(0,x-Button.AbsolutePosition.X,0,y-Button.AbsolutePosition.Y-36)
            local circle = Instance.new("Frame")
            local corner = Instance.new("UICorner")
            local parent = Button
            local hasClip = Button:FindFirstChild("btncircleclip"); if hasClip ~= nil then parent = hasClip end
            corner.CornerRadius = UDim.new(0.5,0)
            corner.Parent = circle
            circle.BorderSizePixel = 0
            circle.BackgroundColor3 = Color3.fromRGB(255,255,255)
            circle.AnchorPoint = Vector2.new(0.5,0.5)
            circle.Parent = parent
            circle.Position = pos
            circle.Size = UDim2.new(0,1,0,1)
            circle.BackgroundTransparency = .65
            circle.ZIndex = 999

            local goal = {}
            goal.Size = UDim2.new(0,500,0,500)
            goal.BackgroundTransparency = 1

            local tween = game:GetService("TweenService"):Create(circle, TweenInfo.new(0.75,Enum.EasingStyle.Sine,Enum.EasingDirection.Out), goal)
            tween:Play()
        end)
    end
    if type(args) == "table" then for i,v in ipairs(args) do setup(v) end else setup(args) end
end