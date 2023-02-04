local dir,sv = unpack(require(script.Parent["shared"]))
local data = {
    base_url = "https://harsh-factual-seal.glitch.me/api/catalog/",
    url_extenders = {
        hats = "Category=11&Subcategory=19",
        hair = "Category=4&Subcategory=20",
        faces = "Category=4&Subcategory=10",
        shirts = "Category=3&Subcategory=56",
        pants = "Category=3&Subcategory=57",
        layered = "Category=3&Subcategory=3",
        anims = "Category=12&Subcategory=38"
    },
    user_allowances = { },
    requests = { }
}

local setup_allowance = function(plr:Player)
    data.user_allowances[plr] = {
        lastCall = 0,
        remaining = 500,
        maximum = 500
    }
end

local update_allowances = function()
    local max = 500/#sv.players:GetPlayers()
    for _,tbl in pairs(data.user_allowances) do
        tbl.maximum = max
        if tbl.remaining < max then
            tbl.remaining = max
        end
    end
end

local get = function(url) -- full URL
    if url == nil then return "params left bank" end
    local success,msg,ret
    success,msg = pcall(function()
        ret = sv.httpService:GetAsync(url)
    end)
    if success then
        return sv.httpService:JSONDecode(ret)
    else
        warn("Error sending GET request to ["..url.."]: "..(msg or "Unknown error"))
        return msg
    end
end

local handler = function()
    local ttw = 0
    for _,tbl in pairs(data.user_allowances) do
        task.spawn(function()
            if tbl.remaining == tbl.maximum then return end
            if (tick()-tbl.lastCall) >= (60/tbl.maximum) then
                tbl.remaining += 1
            end
        end)
    end
    task.wait(ttw)
end

local queue = function(plr:Player,cat,sq,np) -- player, category, search query, cursor
    if plr ~= "server" then
        local ua = data.user_allowances[plr]
        if ua.remaining == 0 then return { 2, "Rate limit", math.ceil(60/ua.maximum) } end
        ua.lastCall = tick(); ua.remaining -= 1
    end
    if data.url_extenders[cat] == nil then return { 2, "Unexpected error" } end
    local resp = get(data.base_url..data.url_extenders[cat].."&Limit=30&IncludeNotForSale&Keyword="..sv.httpService:UrlEncode(sq).."&Cursor="..np)
    if typeof(resp) == "table" then
        return { 1, resp }
    else
        return { 2, "Rate limit", 10 }
    end
end

local plrAdded = function(plr)
    setup_allowance(plr)
    update_allowances()
end

local setup = function()
    sv.players.PlayerAdded:Connect(plrAdded)
    sv.players.PlayerRemoving:Connect(update_allowances)
    task.spawn(function() while true do handler() end end)
end

setup()

return { queue = queue }