-- 鱼种表

module("fish_layer", package.seeall)

local layer = nil               -- 根节点
local fishes = {}               -- 所有鱼配置
local list = {}
local item_general = nil
local item_golden = nil
local item_special = nil
local current_group = 0           -- 当前选中
local btn_general = nil
local btn_golden = nil
local btn_special = nil

function pop()
    layer = cc.CSLoader:createNode("csb/FishLayer.csb")
    pop_layer(layer)
    if not init() then
        print("init fish layer failed.")
    end
end

function init()
    if not layer then return false end
    init_layer()
    fishes = init_config()
    update_list(current_group)
    check_title()
    return true
end

function check_title()
    -- 根据情况显示标题按钮
    local buttons = {
        [ 1 ] = btn_general,
        [ 2 ] = btn_golden,
        [ 3 ] = btn_special
    }
    for group, button in pairs(buttons) do
        local group_fishes = get_fishes_by_group(group)
        -- dump(group_fishes, "group:" .. group)
        if #group_fishes == 0 then
            button:setVisible(false)
        else
            button:setVisible(true)
        end
    end
end

function init_layer()
    if not layer then return end
    
    -- 关闭按钮
    local btn_close = layer:findChild("btn_close")
    add_click_event(btn_close, on_close_clicked)

    -- 设置背景铺满
    local bg = layer:findChild("bg")
    adjust_bg(bg)
    
    -- 列表
    init_list()
    
    -- 标题 [一般鱼 | 彩金鱼 | 特殊鱼] 处理
    init_title_buttons()
end

function on_close_clicked()
    print("on close clicked")
    close_layer(layer)
    layer = nil
end

local function translate_buttons()
    local lang = GetLang()
    btn_general:loadTextures(
        lang .. "/anniu_yibanyu_lanse.png",
        lang .. "/anniu_yibanyu_huangse.png",
        lang .. "/anniu_yibanyu_huangse.png",
        1
    )
    
    btn_golden:loadTextures(
        lang .. "/anniu_caijingyu_lanse.png",
        lang .. "/anniu_caijingyu_huangse.png",
        lang .. "/anniu_caijingyu_huangse.png",
        1
    )

    btn_special:loadTextures(
        lang .. "/anniu_teshuyu_lanse.png",
        lang .. "/anniu_teshuyu_huangse.png",
        lang .. "/anniu_teshuyu_huangse.png",
        1
    )
end

-- 标题栏按钮
function init_title_buttons()
    btn_general = layer:findChild("btn_general")
    btn_golden = layer:findChild("btn_golden")
    btn_special = layer:findChild("btn_special")
    local buttons = {btn_general, btn_special, btn_golden}

    local on_button_clicked = function(btn, group)
        for _, btn_ in ipairs(buttons) do
            if btn_ == btn then
                btn_:setEnabled(false)
            else
                btn_:setEnabled(true)
            end
        end
        on_title_clicked(group)
    end
    add_click_event(btn_general, function()
        return on_button_clicked(btn_general, 1)
    end)
    add_click_event(btn_golden, function()
        return on_button_clicked(btn_golden, 2)
    end)
    add_click_event(btn_special, function()
        return on_button_clicked(btn_special, 3)
    end)
    on_button_clicked(btn_general, 1)
    
    translate_buttons()
end

-- 点击标题栏切换
function on_title_clicked(group)
    current_group = group
    update_list(group)
end

-- 刷新列表
function update_list(group)
    list:removeAllItems()
    local fishes = get_fishes_by_group(group)
    -- dump(fishes, "********** fishes *************")
    local items = make_items(group, #fishes)
    set_fishes(items, fishes)      --  重新显示
end

-- 获取指定类型的鱼
function get_fishes_by_group(group)
    local fish_ret = {}
    for __,fish in ipairs(fishes) do
        if fish.group == group then
            table.insert(fish_ret, fish)
        end
    end

    return fish_ret
end

-- 生成 count 个 group 类型 item
function make_items(group, count)
    local sub_items = {
        [ 1 ] = item_general,
        [ 2 ] = item_golden,
        [ 3 ] = item_special
    }
    local sub_item = sub_items[group]
    local item_p = nil
    local next_index = 1
    function get_next_item()
        if item_p == nil then
            item_p = sub_item:clone()
            for __,c in ipairs(item_p:getChildren()) do
                c:setVisible(false)
            end
            list:pushBackCustomItem(item_p)
            next_index = 1
        end
        local item = item_p:findChild("item_" .. next_index)
        if not item then
            item_p = nil
            return get_next_item()
        end
        next_index = next_index + 1
        item:setVisible(true)
        return item
    end

    local items = {}
    for i=1,count do
        table.insert(items, get_next_item())
    end
    return items
end

function set_fishes(items, fishes)
    for i=1,#items do
        local item = items[i]
        local fish = fishes[i]
        if not item or not fish then
            print("item'count not match with fish'count!!")
            return
        end
        set_item_fish(item, fish)
    end
end

-- 设置一个 item 的详细信息
function set_item_fish(item, fish)
    -- "名字"
    local name = fish.name
    item:findChild("name"):setString(name)

    -- "描述"
    local desc = fish.desc
    local desc_txt = item:findChild("desc")
    if desc_txt then
        desc_txt:setString(desc)
    end

    -- "鱼图片"
    local fish_icon_Path = "game/" .. fish.icon
    local icon = item:findChild("icon")
    icon:loadTexture(fish_icon_Path, ccui.TextureResType.plistType)
    local size = icon:getVirtualRendererSize()
    local scalex = 140 / size.width
    local scaley = 140 / size.height
    local scale
    if scalex > scaley then
        scale = scaley
    else
        scale = scalex
    end
    if scale > 1 then scale = 1 end
    icon:setContentSize(size)
    icon:setScale(scale)

    -- "倍率"
    local low = fish.coins[1]
    local high = fish.coins[2]
    if low == high then
        if low < 0 then
            item:findChild("rate"):setString("")
        else
            item:findChild("rate"):setString(tostring(low))
        end
    else
        item:findChild("rate"):setString(tostring(low) .. "-" .. tostring(high))
    end
    
    -- "底框"
    local backgrouds = {
        [1] = "game/yibanyu_diban.png",
        [2] = "game/caijinyu_diban_02.png",
        [3] = "game/caijinyu_diban.png",
        [4] = "game/teshuyudiban.png"
    }
    local background_file = backgrouds[fish.background]
    assert(background_file)
    item:findChild("frame"):loadTexture(background_file, ccui.TextureResType.plistType)

    -- "tag"
    local tag1 = item:findChild("tag_1"):hide()
    local tag2 = item:findChild("tag_2"):hide()
    if fish.tag == 1 then
        tag1:setVisible(true)
    end
    if fish.tag == 2 then
        tag2:setVisible(true)
    end

    local lang = GetLang()
    tag1:loadTexture(lang .. "/boss.png", 1)
    tag2:loadTexture(lang .. "/hw.png", 1)
end

-- 列表
function init_list()
    list = layer:findChild("list")
    if list == nil then
        print("list is nil")
    end
    assert(list ~= nil)
    item_general = list:findChild("general")
    item_golden = item_general:clone()
    item_special = list:findChild("special")
    
    item_general:retain()
    item_golden:retain()
    item_special:retain()

    list:removeAllItems()
end

-- 初始化配置
function init_config()
    local ret = require("script.ui.fish_cfg")
    -- 根据 gameId 进行一次过滤
    ret = filter_with_game_id(ret)
    return ret
end

function filter_with_game_id(list)
    local gameId = 0
    if FF_G and FF_G.uiInfo and FF_G.uiInfo.gameId then
        gameId = FF_G.uiInfo.gameId
    else
    end
    print("game id:" .. gameId)
    ret = filter_table(list,
        function(item)
            local games = item.games
            -- 无 games 字段，显示该游戏
            if not games then
                return true
            end
            -- 有 games 字段，非 table
            if type(games) ~= type({}) then
                if tostring(games) == tostring(gameId) then
                    return true
                else
                    return false
                end
            end
            if #games == 0 then return true end
            -- 有 gameid 但是不包含当前
            for _,g in ipairs(games) do
                if tostring(g) == tostring(gameId) then
                    return true
                end
            end
            return false
        end)
    return ret
end


function filter_table(tbl, filter)
    local ret = {}
    for _,v in ipairs(tbl) do
        if filter(v) then
            table.insert(ret, v)
        end
    end
    return ret
end
