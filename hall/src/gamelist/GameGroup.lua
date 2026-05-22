local AniCfg = import(".AniCfg")
local GameGroup = class("GameGroup")

---------------------------------------------------------------------

local groups_cfg = {
    {
        group_id = 1001,
        name = "FISHES",
        games = {
            101, 102, 103, 104, 105, 106, 107, 108, 109,
            110, 111, 112, 113, 114, 115, 116, 117, 118, 119,
            120, 121, 122, 123, 124,
            140, 141, 142, 143, 144, 145, 146
        },
        icon = 1001,
        ani = {
            -- spine : 普通 spine,  card_spine : 与普通游戏卡片共用 spine
            type = "spine", -- 
            path = "hall/res/effect/lobby/haiwang/skeleton_fenting",
            name = "animation"
        }
    },
    {
        group_id = 1002,
        name = "OXES",
        games = {
            221,
            235, 236, 237, 238, 239,
            240, 241, 242, 243, 244, 245, 246, 247, 248, 249,
            332
        },
        icon = 221,
        ani = {
            type = "card_spine",
            game_id = 221
        }
    }
}

-- 确定游戏的 group_id, 没找到 group_id 则为 0
local function getCfgGroupId(game_id)
    for group_id, cfg in ipairs(groups_cfg) do
        local games = cfg.games or {}
        for __, cfg_game_id in ipairs(games) do
            if cfg_game_id == GameData:GetGameID(game_id) then
                return cfg.group_id
            end
        end
    end

    return 0
end

local function getAllCfgGroupIds()
    local group_ids = {}
    for _, cfg in pairs(groups_cfg) do
        table.insert(group_ids, cfg.group_id)
    end
    return group_ids
end

local function getCfgIcon(group_id)
    for _,cfg in ipairs(groups_cfg) do
        if cfg.group_id == group_id then
            return cfg.icon
        end
    end
    return 101
end

-- 直接返回一个包含该动画的节点
local function makeAnimNode(icon, group_id)
    print("makeAnimNode: " .. group_id)
    local aniNode = cc.Node:create()
    icon:addChild(aniNode)

    local cfg = nil
    for _, groupcfg in pairs(groups_cfg) do
        if groupcfg.group_id == group_id then
            cfg = groupcfg
            break
        end
    end

    if not cfg then return aniNode end
    local ani = cfg.ani
    if not ani then return aniNode end
    local type = ani.type
    if not type then return aniNode end

    if type == "spine" then
        local spine_path = ani.path
        if not spine_path then return aniNode end

        local atlas = spine_path .. ".atlas"
        local fu = cc.FileUtils:getInstance()
        if not fu:fullPathForFilename(atlas) then return aniNode end

        local json = spine_path .. ".json"
        local skel = spine_path .. ".skel"
        local eft = nil
        if fu:fullPathForFilename(json) ~= "" then
            eft = sp.SkeletonAnimation:createWithJsonFile(json,  atlas)
        elseif fu:fullPathForFilename(skel) ~= "" then
            eft = sp.SkeletonAnimation:createWithBinaryFile(skel,  atlas)
        else
            return aniNode
        end

        eft:setAnchorPoint(cc.p(0.5, 0.5))
        eft:setOpacityModifyRGB(false)
        eft:setAnimation(0, ani.name or "", true)
        aniNode:addChild(eft)

        local size = icon:getContentSize()
        aniNode:setPosition(cc.p(size.width/2, size.height/2))
        return aniNode

    elseif type == "card_spine" then
        local gameId = ani.game_id
        local res = GameData:GetGameID(gameId)
        local anicfg = AniCfg:getCfg(res) or {}

        aniNode:setPosition(cc.p(anicfg.x or 0, anicfg.y or 0))
        aniNode:setScaleX(anicfg.scale_x or 1.0)
        aniNode:setScaleY(anicfg.scale_y or 1.0)

        local prefix = string.format("hall/res/lobby/game_list_spine/jjj_slot_%d/jjj_slot_%d", res, res)
        local json = prefix .. ".json"
        local atlas = prefix .. ".atlas"
        local fu = cc.FileUtils:getInstance()
        if fu:fullPathForFilename(json) ~= "" and fu:fullPathForFilename(atlas) ~= "" then
            if sp38 then
                local anim = sp38.SkeletonAnimation:createWithJsonFile(json, atlas, 1)
                anim:setAnimation(0, tostring(res), true)
                aniNode:addChild(anim)
            end
        end
        return aniNode

    else
        return aniNode
    end
end

--------------------------------------------------------------------

function GameGroup:ctor(game_ids)
    -- [ group_id ] = { 104, 105 },
    self.groups = { }
end

-- 将游戏列表 id 整理到 groups
function GameGroup:setGameIds(game_ids)
    local groups = {}
    groups[0] = {}

    for _, game_id in ipairs(game_ids) do
        local group_id = getCfgGroupId(game_id)
        local games = groups[group_id]
        if games == nil then
            games = {}
            groups[group_id] = games
        end
        table.insert(games, game_id)
    end

    -- 将所有 group_id 插入到 group[0]
    local group_ids = getAllCfgGroupIds()
    local index = 1
    for _, group_id in ipairs(group_ids) do
        if groups[group_id] ~= nil then
            table.insert(groups[0], index, group_id)
            index = index + 1
        end
    end

    self.groups = groups
end

--------------------------------------------------------------------

function GameGroup:getGamesByGroupId(group_id)
    return self.groups[group_id] or {}
end

function GameGroup:getIcon(group_id)
    return getCfgIcon(group_id)
end

function GameGroup:makeAnimNode(icon, group_id)
    return makeAnimNode(icon, group_id)
end

function GameGroup:setGameList(game_ids)
    return self:setGameIds(game_ids)
end

function GameGroup:isGroupId(game_id)
    return self.groups[game_id] ~= nil
end

return GameGroup.new()
