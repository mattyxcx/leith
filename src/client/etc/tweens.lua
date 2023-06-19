return function(frame)
    local children,master = frame:GetDescendants(),{}
    table.insert(children,frame)
    for _,v in ipairs(children) do
        local results = {}
        local tweens = {hide={},show={},pulse={}}
        if v:IsA("Frame") then results[1] = {BackgroundTransparency = 1} results[2] = {BackgroundTransparency = v.BackgroundTransparency}
        elseif v:IsA("ScrollingFrame") then results[1] = {BackgroundTransparency = 1, ScrollBarImageTransparency = 1} results[2] = {BackgroundTransparency = v.BackgroundTransparency, ScrollBarImageTransparency = v.ScrollBarImageTransparency}
        elseif v:IsA("ImageLabel") then results[1] = {BackgroundTransparency = 1, ImageTransparency = 1} results[2] = {BackgroundTransparency = v.BackgroundTransparency, ImageTransparency = v.ImageTransparency}
        elseif v:IsA("TextLabel") then results[1] = {TextTransparency = 1} results[2] = {TextTransparency = v.TextTransparency}
        elseif v:IsA("TextButton") then results[1] = {BackgroundTransparency = 1} results[2] = {BackgroundTransparency = v.BackgroundTransparency}
        elseif v:IsA("TextBox") then results[1] = {BackgroundTransparency = 1, TextTransparency = 1} results[2] = {BackgroundTransparency = v.BackgroundTransparency, TextTransparency = v.TextTransparency}
        elseif v:IsA("UIStroke") then results[1] = {Transparency = 1} results[2] = {Transparency = v.Transparency}
        elseif v:IsA("UIScale") then results[1] = {Scale = 0.75} results[2] = {Scale = 1} end
        if results[1] ~= nil then
            table.insert(tweens.hide, game:GetService("TweenService"):Create(v,TweenInfo.new(0.35,Enum.EasingStyle.Quart,Enum.EasingDirection.Out),results[1]))
            table.insert(tweens.show, game:GetService("TweenService"):Create(v,TweenInfo.new(0.35,Enum.EasingStyle.Quart,Enum.EasingDirection.Out),results[2]))
            table.insert(tweens.pulse, game:GetService("TweenService"):Create(v,TweenInfo.new(0.25,Enum.EasingStyle.Quart,Enum.EasingDirection.Out,0,true),results[1]))
        end
        master[v] = tweens
    end
    return master
end