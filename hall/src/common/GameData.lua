local GameData = {}

--游戏相关数据
GameData.game_id = -1                    --当前游戏id
GameData.real_game_id = -1                    --当前游戏id

GameData.level_id = -1                   --当前关卡id
GameData.game_ids = {}                   --当前游戏列表
GameData.levels = {}                    --关卡列表
GameData.rooms = {}                     --房间列表
GameData.vipInfo = {}                   -- vip表
GameData.casinoLevelTabs = {}           -- 老虎机等级
GameData.entergame_id = -1              --进入老虎机id( >2000 富豪场 >3000 富贵场  or 普通场)

local map_game = {
    -- 野蛮狂牛
    [235] = 221,
    [236] = 221,
    [237] = 221,
    [238] = 221,
    [239] = 221,

    [240] = 221,
    [241] = 221,
    [242] = 221,
    [243] = 221,
    [244] = 221,
    [245] = 221,
    [246] = 221,
    [247] = 221,
    [248] = 221,
    [249] = 221,

    [420] = 320,
    [701] = 320,
    [702] = 320,
    [703] = 320,
    [704] = 320,

    [421] = 321,
    [711] = 321,
    [712] = 321,
    [713] = 321,
    [714] = 321,
    
    [422] = 322,
    [721] = 322,
    [722] = 322,
    [723] = 322,
    [724] = 322,

    [448] = 348,
    [449] = 349
}

-- 是否存在游戏类型
-- type:haiwang,changsheng,casino
function GameData:IsExistGameType(type)
    for _,id in ipairs(self.game_ids) do
        if id >= 3000 then
            id = id -3000
        elseif id >= 2000 then
            id = id -2000
        end
        local cfg = const_game.Param[id]
        if cfg and cfg.Game_type == type then
            return true
        end
    end
    return false
end

function GameData:GetGameID(game_id)
    if game_id > 3000 then
        game_id = game_id - 3000
    elseif game_id > 2000 then
        game_id = game_id - 2000
    end

    if map_game[game_id] then
        return map_game[game_id]
    else
        return game_id
    end
end

function GameData:IsRichGameID(game_id)
    return game_id >= 2000 and game_id < 3000
end

-- 2000-3000富豪场
function GameData:HasRichGame()
   for _, id in ipairs(self.game_ids) do
       if id >= 2000 and id < 3000 then
           return true
       end
   end
   return false
end

function GameData:IsRichThreeThousandsGameID(game_id)
    return game_id >= 3000
end
-- 3000 -4000富豪场
function GameData:HasRichGameThreeThousands()
    for _, id in ipairs(self.game_ids) do
        if id >= 3000 then
            return true
        end
    end
    return false
end

-- 是否是老虎机
function GameData:IsCasino(game_id)
    local res_game_id = self:GetGameID(game_id)
    local cfg = const_game.Param[res_game_id]
    if cfg and cfg[const_game.Game_type] == "casino" then
        return true
    else
        return false
    end
end

-- 是否是捕鱼
function GameData:IsFish(game_id)
    local res_game_id = self:GetGameID(game_id)
    local cfg = const_game.Param[res_game_id]
    local type_
    if cfg then
        type_ = cfg[const_game.Game_type]
        if type_ == "haiwang" or type_ == "changsheng" then
            return true
        end
    end
    return false
end

-- 是否是老的老虎机
function GameData:IsCocosSupportGame(game_id)
    local res_game_id = self:GetGameID(game_id)
    local cfg = const_game.Param[res_game_id]
    if cfg and cfg[const_game.Cocos_Support] then
        return true
    else
        return false
    end
end

-- 是否是 FGUI 版本的游戏
function GameData:IsFGUISupportGame(game_id)
    local res_game_id = self:GetGameID(game_id)
    local cfg = const_game.Param[res_game_id]
    if cfg and cfg[const_game.FGUI_Support] then
        return true
    else
        return false
    end
end

-- 是否是 FGUI 发布版本
function GameData:IsFGUIReleaseGame(game_id)
    local res_game_id = self:GetGameID(game_id)
    local cfg = const_game.Param[res_game_id]
    if cfg and cfg[const_game.FGUI_Support] and cfg[const_game.FGUI_Release] then
        return true
    else
        return false
    end
end

function GameData:SetGameList(game_ids)
    local list = {}
    local fguiRunTimeSupport = Tools.IsFGUIRuntimeSupport()
    for _,id in ipairs(game_ids) do
        if self:IsCasino(id) then
            if fguiRunTimeSupport and self:IsFGUIReleaseGame(id) then
                table.insert(list, id)
            elseif self:IsCocosSupportGame(id) then
                table.insert(list, id)
            else
                release_print("UnSupportted game found:" .. id)
                local res_game_id = self:GetGameID(id)
                local cfg = const_game.Param[res_game_id]
            end
        else
            -- 过滤掉捕鱼
            if NewCatchFishEnv or Fish2Env then
                table.insert(list, id)
            end 
        end
    end

    self.game_ids = list
end

return GameData
