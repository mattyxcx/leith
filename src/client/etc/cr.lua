local c = script.Parent.Parent.Parent.pc.Cursor
local t = require(script.Parent.tweens)(c)
local m = game.Players.LocalPlayer:GetMouse()
task.spawn(function() while true do task.wait() c.Position = UDim2.new(0,m.X,0,m.Y) end end)
local tr = function(a) for _,v in ipairs(c:GetDescendants()) do for _,x in ipairs(t[v][a]) do x:Play() end end for _,x in ipairs(t[c][a]) do x:Play() end end
tr("hide")
return function(a,b)
    local s = game:GetService("TextService"):GetTextSize(b,13,Enum.Font.GothamMedium,Vector2.new(400,math.huge))
    a.MouseEnter:Connect(function() c.Size = UDim2.new(0,s.X+36,0,s.Y+21) c.title.Text = b; tr("show") end)
    a.MouseLeave:Connect(function() tr("hide") end)
end