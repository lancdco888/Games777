function merge_cfg(t1, t2)
    for k,v in pairs(t2) do
        t1[k] = v
    end
    return t1
end

function merge()
    local all = {}

    -- 海王游戏卡片
    local cfg = require("hall.src.gamelist.AnimCfg.hw")
    all = merge_cfg(all, cfg)

    -- 昌盛游戏卡片
    cfg = require("hall.src.gamelist.AnimCfg.cs")
    all = merge_cfg(all, cfg)
    
    -- 老虎机外框
    cfg = require("hall.src.gamelist.AnimCfg.casino")
    all = merge_cfg(all, cfg)

    return all
end

return merge()
