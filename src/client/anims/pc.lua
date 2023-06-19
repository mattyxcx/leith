local xdir = script.Parent.Parent.Parent.etc
local main = script.Parent.Parent.pc.Main
local sv = require(xdir.sv)
local cc = require(xdir.cc)
local cr = require(xdir.cr)
local sortTweens = require(xdir.tweens)
local notify = require(xdir.notify)(main)

local cache = {
    pre_loaded_anim_ids = {
        -- add anim ids here
    },
    tweens = { },
    selected = { },
    visible = true,
}

local transition = function(t,e)
    local func = function(f)
        if not cache.tweens[f] then return end
        if e == "show" then
            for _,v in ipairs(cache.tweens[f].show) do v:Play() end
        elseif e == "hide" then
            for _,v in ipairs(cache.tweens[f].hide) do v:Play() end
        elseif e == "pulse" then
            for _,v in ipairs(cache.tweens[f].pulse) do v:Play() end
        end
    end
    if typeof(t) == "table" then for _,f in ipairs(t) do func(f) end else func(t) end
end

local plrSelect = function(clone,force)
    local isSelected = clone.tick.tick.Visible
    if (force == nil and not isSelected) or (force ~= nil and force == true) then
        clone.username.TextTransparency = 0.25
        clone.tick.UIStroke.Color = Color3.fromRGB(255,255,255)
        clone.tick.tick.Visible = true
        table.insert(cache.selected,clone)
    elseif (force == nil and isSelected) or (force ~= nil and force == false) then
        clone.username.TextTransparency = 0.5
        clone.tick.UIStroke.Color = Color3.fromRGB(0,0,0)
        clone.tick.tick.Visible = false
        for i,v in ipairs(cache.selected) do if v == clone then table.remove(cache.selected,i) end end
    end
end

local playAnim = function(clone)
    if #cache.selected == 0 then return notify("err","No players selected") end
    clone.tick.Visible = false
    clone.ring.Visible = true
    clone.BackgroundTransparency = 0.5
    clone.title.TextTransparency = 0.5
    local sel = {}; for i,v in ipairs(cache.selected) do sel[i] = v.Name end
    local resp = sv.anims.server:InvokeServer("play anim",{sel,clone.Name})
    handleServerCallback("play",resp,clone)
    clone.tick.Visible = true
    clone.ring.Visible = false
    clone.BackgroundTransparency = 0
    clone.title.TextTransparency = 0.25
end

handleServerCallback = function(event,r,...)
    local ex = {...}
    if event == "create" then
        if r[1] == 1 then
            local clone = sv.anims.pc_temp.anim:Clone()
            clone.Parent = main.Main.Animation.scroll
            clone.Name = r[2].name
            clone.title.Text = r[2].name.." <font color=\"#b3b3b3\">"..r[2].assetId.."</font>"
            clone.Visible = true
            clone.Activated:Connect(function() playAnim(clone) end)
            cc(clone)
            return notify("suc","Created animation presave")
        elseif r[1] == 2 then
            return notify("err",r[2])
        end
    elseif event == "play" then
        if r[1] == 1 then
            ex[1].tick.Visible = false
            ex[1].ring.Visible = true
            ex[1].BackgroundTransparency = 0.5
            ex[1].title.TextTransparency = 0.5
            return notify("suc","Playing "..ex[1].Name)
        end
    elseif event == "cancel" then
        if r[1] == 1 then
            return notify("suc","Cancelled animations for selected")
        elseif r[1] == 2 then
            return notify("err",r[2])
        end
    end
end

local createAnim = function()
    local tb = main.Main.Animation.tb.TextBox
    if tb.Text == "" or tonumber(tb.Text) == nil then return notify("err","Invalid animation ID") end
    local resp = sv.anims.server:InvokeServer("create anim",tonumber(tb.Text))
    handleServerCallback("create",resp)
end

local handleButton = function(btns)
    for _,btn in ipairs(btns) do
        if btn:IsA("TextButton") then
            if btn.ClipsDescendants ~= true then
                local f = Instance.new("Frame"); f.Name = "btncircleclip"; f.BackgroundTransparency = 1; f.Size = UDim2.new(1,0,1,0); f.ClipsDescendants = true; f.Parent = btn
            end
            cc(btn)
            btn.Activated:Connect(function()
                local par,func = unpack(string.split(btn.Name,"_"))
                if par == "plr" then
                    if func == "selectall" then
                        local f = function(x)
                            for _,v in ipairs(main.Main.Players.scroll:GetChildren()) do
                                if v:IsA("TextButton") then
                                    plrSelect(v,x)
                                end
                            end
                        end
                        local isSelected = btn.tick.tick.Visible
                        if not isSelected then
                            btn.title.TextTransparency = 0.25
                            btn.tick.UIStroke.Color = Color3.fromRGB(255,255,255)
                            btn.tick.tick.Visible = true
                            f(true)
                        else
                            btn.title.TextTransparency = 0.5
                            btn.tick.UIStroke.Color = Color3.fromRGB(0,0,0)
                            btn.tick.tick.Visible = false
                            f(false)
                        end
                    elseif func == "cancelall" then
                        btn.tick.Visible = false
                        btn.title.Visible = false
                        btn.ring.Visible = true
                        local sel = {}; for i,v in ipairs(cache.selected) do sel[i] = v.Name end
                        local resp = sv.anims.server:InvokeServer("cancel anims",sel)
                        handleServerCallback("cancel",resp)
                        btn.tick.Visible = true
                        btn.title.Visible = true
                        btn.ring.Visible = false
                    end
                elseif par == "anim" then
                    if func == "create" then
                        createAnim()
                    end
                end
            end)
        end
    end
end

local playerAdded = function(plr)
    local clone = sv.anims.pc_temp.plr:Clone()
    clone.Name = plr.Name
    clone.username.Text = plr.Name
    clone.Headshot.Image = "rbxthumb://type=AvatarHeadShot&id="..plr.UserId.."&w=48&h=48"
    clone.Activated:Connect(function() plrSelect(clone) end)
    clone.Parent = main.Main.Players.scroll
    clone.Visible = true
    cc(clone)
end

local createIcon = function()
    local toggle = function()
        local dir = main:GetDescendants(); table.insert(dir,main)
        if cache.visible then
            transition(dir,"hide")
            main:TweenPosition(UDim2.new(0.5,0,0.3,0),"Out","Quart",0.3,true)
            task.delay(0.3, function() main.Visible = false end)
        else
            transition(dir,"show")
            main:TweenPosition(UDim2.new(0.5,0,0.5,0),"Out","Quart",0.3,true)
            main.Visible = true
        end
        cache.visible = not cache.visible
    end
    toggle()
    local icon = require(xdir.icon).new()
    icon:setImage(12742985612)
    icon:setLabel("Animations")
    icon:setRight()
    icon:setTheme(require(xdir.icon.Themes).Blue)
    icon.selected:Connect(function() toggle() end)
    icon.deselected:Connect(function() toggle() end)
end

local setup = function()
    local dir = main:GetDescendants(); table.insert(dir,main)
    cache.tweens = sortTweens(main)
    createIcon()
    handleButton(dir)
    transition(dir,"hide")
    sv.players.PlayerAdded:Connect(playerAdded)
    playerAdded(sv.players.LocalPlayer)
end

setup ( )
return { }