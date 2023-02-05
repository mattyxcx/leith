local dir,sv = unpack(require(script.shared))
local search = require(script.search)
local cache = {
    presets = nil
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
                local item = unpack(sv.insertService:LoadAsset(id):GetChildren())
                item.Name = id
                item.Parent = dir.ct_fld.Items[loc]
            end
            local item = dir.ct_fld.Items[loc][id]
            if plr.Character:FindFirstChild(item.Name) then return { 2, "I already equipped this" } end
            item:Clone().Parent = plr.Character
            return { 1 }
        else return { 2, "Unknown category" } end
    end
end

local setup = function()
    dir.func.OnServerInvoke = onInvoke
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