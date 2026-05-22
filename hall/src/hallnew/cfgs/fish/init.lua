local fishs = nil
local games = nil

function get_fish_preload_res(game_id)
    if games == nil then
        local path = "hall/res/cfgs/fish/game_fishs.json"
        local games_data_ = cc.FileUtils:getInstance():getStringFromFile(path)
        local json = require("json")
        -- 每个游戏 id 对应的鱼
        games = json.decode(games_data_)
    end

    local fish_ids = games[tostring(game_id)] or {}
    if fishs == nil then
        -- 自动生成的鱼对应资源
        local fish_path = "hall/res/cfgs/fish/fish_assets.json"
        local fish_data_ = cc.FileUtils:getInstance():getStringFromFile(fish_path)
        fishs = json.decode(fish_data_)

        -- 手动配置的鱼对应资源
        local manual_path = "hall/res/cfgs/fish/fish_assets_manual.json"
        local manual_fish_data_ = cc.FileUtils:getInstance():getStringFromFile(manual_path)
        manual_fishs = json.decode(manual_fish_data_)
        for fishid, assets in pairs(manual_fishs) do
            fishs[fishid] = fishs[fishid] or {}
            for _,a in pairs(assets) do
                table.insert(fishs[fishid], a)
            end
        end
    end

    local ret = {}
    for __,fish_id in ipairs(fish_ids) do
        local assets = fishs[tostring(fish_id)]
        if not assets then
            print("fish_id not found:" .. tostring(fish_id) .. ", for game_id:" .. tostring(game_id))
        else
            for __,asset in ipairs(assets) do
                table.insert(ret, asset)
            end
        end
    end

    return ret
end
