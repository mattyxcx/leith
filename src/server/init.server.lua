local dir,sv = unpack(require(script.shared))
local search = require(script.search)
local cache = {
    presets = nil,
    anims = { }
}

local onInvoke = function(plr,header,args)
    if header == "presets" then
        if cache.presets == nil then repeat task.wait() until cache.presets ~= nil end
        return cache.presets
    elseif header == "search" then
        return search.queue(plr,unpack(args))
    elseif header == "apply" then
        local loc,id = unpack(args)
        if dir.ct_fld.Items:FindFirstChild(loc) then
            if dir.ct_fld.Items[loc]:FindFirstChild(id) == nil then
                if loc == "anims" then
                    local fld = dir.ct_fld.Items.anims.Folder:Clone()
                    local d = game:GetService("AssetService"):GetBundleDetailsAsync(id)
                    fld.ClimbAnimation.Value = d.Items[1].Id
                    fld.FallAnimation.Value = d.Items[2].Id
                    fld.IdleAnimation.Value = d.Items[3].Id
                    fld.JumpAnimation.Value = d.Items[4].Id
                    fld.RunAnimation.Value = d.Items[5].Id
                    fld.SwimAnimation.Value = d.Items[6].Id
                    fld.WalkAnimation.Value = d.Items[7].Id
                    fld.Name = "catalog_"..id; fld.Parent = dir.ct_fld.Items.anims
                else
                    local item = unpack(sv.insertService:LoadAsset(id):GetChildren())
                    item.Name = "catalog_"..id
                    item.Parent = dir.ct_fld.Items[loc]
                end
            end
            local item = dir.ct_fld.Items[loc]["catalog_"..id]
            if plr.Character:FindFirstChild(item.Name) then return { 2, "I already equipped this" } end
            if loc == "hair" or loc == "hats" or loc == "layered" then
                item:Clone().Parent = plr.Character
            else
                if loc == "faces" then
                    if plr.Character.Head:FindFirstChild("face") then
                        plr.Character.Head.face.Texture = item.Texture
                    else
                        item:Clone().Parent = plr.Character.Head
                    end
                elseif loc == "shirts" then
                    if plr.Character:FindFirstChildOfClass("Shirt") then
                        plr.Character:FindFirstChildOfClass("Shirt").ShirtTemplate = item.ShirtTemplate
                    else
                        item:Clone().Parent = plr.Character
                    end
                elseif loc == "pants" then
                    if plr.Character:FindFirstChildOfClass("Pants") then
                        plr.Character:FindFirstChildOfClass("Pants").PantsTemplate = item.PantsTemplate
                    else
                        item:Clone().Parent = plr.Character
                    end
                elseif loc == "anims" then
                    local hdd = plr.Character.Humanoid:GetAppliedDescription()
                    for _,v in ipairs(item:GetChildren()) do
                        hdd[v.Name] = v.Value
                    end
                    plr.Character.Humanoid:ApplyDescription(hdd)
                    task.wait(0.5)
                end
            end
            return { 1 }
        else return { 2, "Unknown category" } end
    elseif header == "delete" then
        if args and args.Parent == plr.Character then
            args:Destroy()
            return { 1 }
        else return { 2, "Unauthorised" } end
    elseif header == "create anim" then
        if args then
            local info = sv.marketplaceService:GetProductInfo(args)
            if info.AssetTypeId == 24 then
                local anim = Instance.new("Animation")
                anim.Name = info.Name
                anim.AnimationId = "rbxassetid://"..args
                cache.anims[info.Name] = anim
                return { 1, { name = info.Name, assetId = args} }
            else
                return { 2, "AssetId provided is not an animation" }
            end
        else
            return { 2, "Invalid argument" }
        end
    elseif header == "play anim" then
        if args then
            if #args[1] >= 0 then
                if cache.anims[args[2]] ~= nil then
                    for _,pn in ipairs(args[1]) do
                        task.spawn(function()
                            local h:Animator = sv.players[pn].Character.Humanoid.Animator
                            for _,v in ipairs(h:GetPlayingAnimationTracks()) do v:Stop() end; task.wait(0.1)
                            h:LoadAnimation(cache.anims[args[2]]):Play()
                        end)
                    end
                    return { 1 }
                else
                    return { 2, "Invalid animation" }
                end
            else
                return { 2, "No players selected" }
            end
        else
            return { 2, "Invalid arguments" }
        end
    elseif header == "cancel anims" then
        if args then
            if #args >= 0 then
                for _,pn in ipairs(args) do
                    task.spawn(function()
                        local h:Animator = sv.players[pn].Character.Humanoid.Animator
                        for _,v in ipairs(h:GetPlayingAnimationTracks()) do v:Stop() end
                    end)
                end
                return { 1 }
            else
                return { 2, "No players selected" }
            end
        else
            return { 2, "Invalid arguments" }
        end
    end
end

local setup = function()
    dir.an_func.OnServerInvoke = onInvoke
    dir.ct_func.OnServerInvoke = onInvoke
    local all = { }
    for _,v in ipairs({"hats","hair","faces","shirts","pants","layered","anims"}) do
        local succ
        repeat local resp = search.queue("server",v,"","")
            if resp[1] == 1 then
                all[v] = resp
                succ = true
                task.wait(0.2)
            else
                task.wait(5)
                resp = search.queue("server",v,"","")
            end
        until succ
    end
    cache.presets = all
end

setup()