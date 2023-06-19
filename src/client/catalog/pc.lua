local xdir = script.Parent.Parent.Parent.etc
local main = script.Parent.Parent.pc.Main
local sv = require(xdir.sv)
local cc = require(xdir.cc)
local cr = require(xdir.cr)
local sortTweens = require(xdir.tweens)
local notify = require(xdir.notify)(main)

local cache = {
    tweens = { },
    cell_data = { },
    presets = { },
    cursors = { },
    default_buttons = { },
    current_page = nil,
    selected = nil,
    lastSearch = 0,
    waiting = false,
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

local showBottom = function(cell)
    local hide = function()
        transition(main.Bottom:GetDescendants(),"hide")
        task.delay(0.35, function() if cache.selected == nil then main.Bottom.Visible = false end end)
        cache.selected = nil
        return
    end
    if cache.selected == nil then
        transition(main.Bottom:GetDescendants(),"show")
    else
        cache.selected.UIStroke.Color = Color3.fromRGB(246, 246, 255)
        cache.selected.Inner.ImageColor3 = Color3.fromRGB(150, 150, 150)
        cache.selected.Glow.ImageTransparency = 0.8
        if cache.selected == cell or cell == nil then
            return hide()
        end
    end
    if cell == nil then return hide() end
    main.Bottom.Visible = true
    cell.UIStroke.Color = Color3.fromRGB(92, 190, 255)
    cell.Inner.ImageColor3 = Color3.fromRGB(92, 190, 255)
    cell.Glow.ImageTransparency = 0.2
    main.Bottom.title.Text = cache.cell_data[cell].name
    main.Bottom.body.Text = "@"..cache.cell_data[cell].creatorName
    main.Bottom.Icon.Icon.Image = cell.Icon.Image
    cache.selected = cell
end

local handleCell = function(cell)
    cr(cell,cell.Name)
    cc(cell)
    cell.MouseEnter:Connect(function() cell.Glow.ImageTransparency = 0 end)
    cell.MouseLeave:Connect(function() cell.Glow.ImageTransparency = 0.8 end)
    cell.Activated:Connect(function() showBottom(cell) end)
end

local handleInv = function(cell,acc)
    --cr(cell,cell.Name)
    cc(cell)
    cell.MouseEnter:Connect(function()
        if cell.Active == false then return end
        cell.Glow.ImageTransparency = 0
        cell.Inner.ImageColor3 = Color3.fromRGB(172, 30, 49)
        cell.UIStroke.Color = Color3.fromRGB(236, 40, 67)
        cell.title.Visible = true
    end)
    cell.MouseLeave:Connect(function()
        if cell.Active == false then return end
        cell.Glow.ImageTransparency = 0.8
        cell.Inner.ImageColor3 = Color3.fromRGB(150, 150, 150)
        cell.UIStroke.Color = Color3.fromRGB(246, 246, 255)
        cell.title.Visible = false
    end)
    cell.Activated:Connect(function()
        cell.Active = false
        cell.Inner.ImageColor3 = Color3.fromRGB(77, 11, 20)
        cell.UIStroke.Color = Color3.fromRGB(131, 58, 68)
        cell.Icon.ImageTransparency = 0.75
        cell.title.Visible = false
        cell.load.Visible = true
        local resp = sv.cat.server:InvokeServer("delete",acc)
        if resp[1] == 1 then
            notify("suc","Deleted successfully")
            cell:Destroy()
        else
            cell.Active = true
            cell.Glow.ImageTransparency = 0.8
            cell.Inner.ImageColor3 = Color3.fromRGB(150, 150, 150)
            cell.UIStroke.Color = Color3.fromRGB(246, 246, 255)
            cell.Icon.ImageTransparency = 0
            cell.load.Visible = false
            notify("err","Could not delete accessory")
        end
    end)
end

local createCell = function(tbl)
    local cell = sv.cat.pc_temp.cell:Clone()
    cache.cell_data[cell] = tbl
    cell.Name = tbl.name
    cell.Icon.Image = "rbxthumb://type=Asset&id="..tbl.id.."&w=150&h=150"
    if tbl.itemType == "Bundle" then cell.Icon.Image = "rbxthumb://type=BundleThumbnail&id="..tbl.id.."&w=150&h=150" end
    cell.Visible = true
    handleCell(cell)
    return cell
end

local fixInv = function()
    local createVpf = function(acc)
        local vpf = Instance.new("ViewportFrame")
        local cam = Instance.new("Camera")
        local clone = acc:Clone()
        clone.Parent = vpf
        clone.Handle.CFrame = CFrame.new(0,0,0)
        clone.Handle:ClearAllChildren()
        vpf.Name = "Icon"
        vpf.Size = UDim2.new(1,0,1,0)
        vpf.ZIndex = 5
        vpf.CurrentCamera = cam
        vpf.BackgroundTransparency = 1
        cam.CFrame = acc.ThumbnailConfiguration.ThumbnailCameraValue.Value
        cam.Parent = vpf
        return vpf
    end
    cache.default_buttons.worn = { }
    for _,v in ipairs(sv.players.LocalPlayer.Character.Humanoid:GetAccessories()) do
        local cell = sv.cat.pc_temp.inv:Clone()
        local n = string.split(v.Name,"_")
        if n[1] ~= "catalog" then
            cell.Icon:Destroy()
            local vpf = createVpf(v)
            vpf.Parent = cell
        else
            cell.Icon.Image = "rbxthumb://type=Asset&id="..n[2].."&w=150&h=150"
        end
        cell.Name = v.Name
        cell.Visible = true
        handleInv(cell,v)
        table.insert(cache.default_buttons.worn,cell)
    end
    if cache.current_page.Name == "worn" then
        for _,v in ipairs(cache.default_buttons.worn) do task.spawn(function() if v:IsA("TextButton") then v.Parent = cache.current_page end end) end
    end
end

local switchPage = function(newPage)
    if cache.current_page ~= nil then
        cache.current_page.Visible = false
        cache.current_page.load.Visible = false
        for _,v in ipairs(cache.current_page:GetChildren()) do task.spawn(function() if v:IsA("TextButton") then v.Parent = nil end end) end
    end
    if newPage.Name == "worn" then fixInv(); end
    if cache.default_buttons[newPage.Name] ~= nil then
        for _,v in ipairs(cache.default_buttons[newPage.Name]) do task.spawn(function() if v:IsA("TextButton") then v.Parent = newPage end end) end
    end
    transition({main.results_hint},"pulse"); task.delay(0.25,function() main.results_hint.Text = (newPage.Name ~= "worn" and "Showing presets") or "Showing worn items" end)
    task.spawn(showBottom,nil)
    newPage.Visible = true
    newPage.load.Visible = true
    main.Search.TextBox.Text = ""
    main.Top.tab.Text = "Viewing "..string.upper(string.sub(newPage.Name,1,1))..string.sub(newPage.Name,2,#newPage.Name)
    if newPage.Name == "worn" or #cache.default_buttons[newPage.Name] < 30 then newPage.load.Visible = false end
    for _,v in ipairs(main.Options:GetChildren()) do
        if v:IsA("TextButton") then
            if string.split(v.Name,"_")[2] ~= newPage.Name then
                v.Icon.ImageTransparency = 0.4
                v.title.TextTransparency = 0.4
                v.UIStroke.Transparency = 0.675
            else
                v.Icon.ImageTransparency = 0.05
                v.title.TextTransparency = 0.125
                v.UIStroke.Transparency = 0.25
            end
        end
    end
    cache.current_page = newPage
end

local handleServerCallback = function(event,r)
    if event == "equip" then
        if r[1] == 1 then
            fixInv()
            return notify("suc","Equipped successfully")
        elseif r[1] == 2 then
            return notify("err",r[2])
        end
    elseif event == "search" or event == "extend" then
        if r[1] == 1 then
            main.Search.TextBox.Text = (r[2].keyword ~= nil and r[2].keyword) or ""; if r[2].data == nil then return end
            for i,tbl in ipairs(r[2].data) do createCell(tbl).Parent = cache.current_page end
            transition(main.results_hint,"pulse"); task.delay(0.25,function() main.results_hint.Text = "Loaded "..(#cache.current_page:GetChildren()-3).." items, took "..string.sub(tostring(tick()-cache.lastSearch),1,4).."s" end)
            if r[2].nextPageCursor == nil then cache.current_page.load.Visible = false return end
            cache.cursors[cache.current_page] = r[2]["nextPageCursor"]
        elseif r[1] == 2 then
            if r[2] == "Rate limit" then
                if event == "extend" then
                    return notify("warn","Slow down.")
                else
                    cache.current_page.Visible = false
                    main.Error.Visible = true
                    cache.waiting = true
                    transition(main.Error:GetDescendants(),"show")
                    main.Load.Visible = false
                    main.Search.search_action.Active = false
                    main.Search.TextBox.TextEditable = false
                    main.Search.TextBox.Text = ""
                    main.Search.TextBox.PlaceholderText = "Search disabled..."
                    for i=0,r[3] do
                        main.Error.title.Text = "You're being ratelimited to prevent abuse. Try searching again in "..r[3]-i.." seconds."
                        task.wait(1)
                    end
                    transition(main.Error:GetDescendants(),"hide")
                    task.wait(0.35)
                    cache.waiting = false
                    main.Load.Visible = false
                    main.Search.search_action.Active = true
                    main.Search.TextBox.TextEditable = true
                    main.Search.TextBox.PlaceholderText = "Enter a search term..."
                    cache.current_page.Visible = true
                end
            end
        end
    elseif event == "presets" then
        cache.presets = r
    end
end

local handlePageTurning = function(page)
    page:GetPropertyChangedSignal("CanvasPosition"):Connect(function()
        if page.CanvasPosition.Y+page.AbsoluteSize.Y >= page.CanvasSize.Y.Offset-25 and page.ScrollingEnabled and cache.cursors[cache.current_page] ~= nil then
            page.ScrollingEnabled = false
            cache.lastSearch = tick()
            local resp = sv.cat.server:InvokeServer("search",{cache.current_page.Name,main.Search.TextBox.Text,cache.cursors[cache.current_page]})
            handleServerCallback("extend",resp)
            page.ScrollingEnabled = true
        end
    end)
end

local createPage = function(name)
    local page = sv.cat.pc_temp.scroll:Clone()
    page.Name = name
    page.Visible = true
    page.Parent = main.Main
    page.UIGridLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function() page.CanvasSize = UDim2.new(0,0,0,page.UIGridLayout.AbsoluteContentSize.Y+25) end)
    if name == "worn" then return end
    local dir = { }
    for _,tbl in ipairs(cache.presets[name][2].data) do
        local cell = createCell(tbl)
        cell.Parent = page
        table.insert(dir,cell)
    end
    cache.default_buttons[name] = dir
    cache.cursors[page] = cache.presets[name][2].nextPageCursor
    handlePageTurning(page)
end

local createSearch = function()
    if main.Search.TextBox.Text == "" then return end
    if cache.current_page.Name == "opt_worn" then return end
    cache.waiting = true
    cache.lastSearch = tick()
    for _,v in ipairs(cache.current_page:GetChildren()) do if v:IsA("TextButton") then v.Parent = nil end end
    cache.current_page.load.Visible = false
    transition(main.Load:GetDescendants(),"show")
    local resp = sv.cat.server:InvokeServer("search",{cache.current_page.Name,main.Search.TextBox.Text,""})
    handleServerCallback("search",resp)
    transition(main.Load:GetDescendants(),"hide")
    cache.current_page.load.Visible = true
    cache.waiting = false
end

local handleTextBox = function(tb)
    tb.FocusLost:Connect(function(t)
        if t then
            createSearch()
        end
    end)
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
                if par == "btm" then
                    if func == "discard" then
                        showBottom(nil)
                        return
                    elseif func == "equip" then
                        if cache.selected == nil then return end
                        transition({btn.title},"hide"); transition({btn.ring},"show"); btn.ring.Visible = true
                        local resp = sv.cat.server:InvokeServer("apply",{cache.current_page.Name,cache.cell_data[cache.selected].id})
                        handleServerCallback("equip",resp)
                        transition({btn.title},"show"); transition({btn.ring},"hide"); task.wait(0.35); btn.ring.Visible = false
                    elseif func == "buy" then
                        if cache.selected == nil then return end
                        sv.marketplaceService:PromptPurchase(sv.players.LocalPlayer,cache.cell_data[cache.selected].id)
                    end
                elseif par == "opt" then
                    if main.Main:FindFirstChild(func) ~= nil then switchPage(main.Main[func]) return end
                    if cache.current_page ~= nil then cache.current_page.Visible = false end
                    if cache.waiting == true then return end
                    transition(main.Load:GetDescendants(),"show")
                    createPage(func)
                    switchPage(main.Main[func])
                    transition(main.Load:GetDescendants(),"hide")
                elseif par == "search" then
                    if func == "action" then
                        createSearch()
                    end
                end
            end)
        end
    end
end

local createIcon = function()
    local toggle = function()
        if cache.visible then
            transition(main.UIScale,"hide")
            main:TweenPosition(UDim2.new(1.3,0,0.5,0),"Out","Quart",0.3,true)
        else
            transition(main.UIScale,"show")
            main:TweenPosition(UDim2.new(0.925,0,0.5,0),"Out","Quart",0.3,true)
        end
        cache.visible = not cache.visible
    end
    toggle()
    local icon = require(xdir.icon).new()
    icon:setImage(12469028780)
    icon:setLabel("Catalog")
    icon:setTip("View catalog")
    icon:setRight()
    icon:setTheme(require(xdir.icon.Themes).Blue)
    icon.selected:Connect(function() toggle() end)
    icon.deselected:Connect(function() toggle() end)
end

local setup = function()
    cache.tweens = sortTweens(main)
    createIcon()
    local resp = sv.cat.server:InvokeServer("presets")
    handleServerCallback("presets",resp)
    handleButton(main:GetDescendants())
    handleTextBox(main.Search.TextBox)
    createPage("hats")
    switchPage(main.Main.hats)
    transition(main.Load:GetDescendants(),"hide")
end

setup ( )
return { }