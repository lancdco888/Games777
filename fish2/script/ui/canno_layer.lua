-- 换炮台

module("canno_layer", package.seeall)

local layer = nil               -- 根节点
local curr_index = 1            -- 当前选中炮台编号
local icon = nil
local name = nil
local btn_left = nil            -- 向左 按钮
local btn_right = nil           -- 向右 按钮
local btn_equip = nil           -- 装备 按钮

function pop()
    layer = cc.CSLoader:createNode("csb/CannoLayer.csb")
    pop_layer(layer)
    if not init() then return end
end

local function translate_ui()
    local lang = GetLang()
    local fname = lang .. "/genghuanpaotai_zhuangbei.png"
    btn_equip:loadTextures(fname, fname, fname, 1)
end

function init()
    if not layer then return false end
    init_layer()
    translate_ui()

    curr_index = get_current_cannon_index()
    update_canno(curr_index)
    update_buttons()
    return true
end

function init_layer()
    if not layer then return end

    -- 设置背景铺满
    local bg = layer:findChild("bg")
    -- 设置背景铺满
    adjust_bg(bg)

    -- 关闭按钮
    local btn_close = layer:findChild("btn_close")
    add_click_event(btn_close, on_close_clicked)

    -- 左移
    btn_left = layer:findChild("btn_left")
    add_click_event(btn_left, on_left_clicked)
    
    -- 右移
    btn_right = layer:findChild("btn_right")
    add_click_event(btn_right, on_right_clicked)
    
    -- 装备
    btn_equip = layer:findChild("btn_equip")
    add_click_event(btn_equip, on_equip_clicked)

    -- 图标
    icon = layer:findChild("icon")

    -- 名字
    name = layer:findChild("name")
end

function on_close_clicked()
    print("on close clicked")
    close_layer(layer)
    layer = nil
end

function on_left_clicked()
    print("btn left clicked")
    if not update_canno(curr_index - 1) then
        print("界面切换到炮台失败")
        return
    end
    curr_index = curr_index - 1
    update_buttons()
end

function update_canno(index)
    local succ, icon_file, title_file = check_index(index)
    if not succ then
        return false
    end
    icon:loadTexture(icon_file, 1)
    name:loadTexture(title_file, 1)
    return true
end

function check_index(index)
    local frameCache = cc.SpriteFrameCache:getInstance()
    local langName = GetLang()

    local icon_file = string.format("pao_%02d.png", index)
    local title_file = string.format(langName .. "/genghuanpaotai_%02d.png", index)
    if not frameCache:getSpriteFrame(title_file) then  -- or not frameCache:getSpriteFrame(title_file) then
        return false
    end
    return true, icon_file, title_file
end

function update_buttons()
    if check_index(curr_index - 1) then
        btn_left:setVisible(true)
    else
        btn_left:setVisible(false)
    end
    if check_index(curr_index + 1) then
        btn_right:setVisible(true)
    else
        btn_right:setVisible(false)
    end
    -- 当前炮台 不显示装备按钮
    if get_current_cannon_index() == curr_index then
        btn_equip:setVisible(false)
    else
        btn_equip:setVisible(true)
    end
end

function on_right_clicked()
    print("btn right clicked")
    if not update_canno(curr_index + 1) then
        print("界面切换到炮台失败")
        return
    end
    curr_index = curr_index + 1
    update_buttons()
end

function on_equip_clicked()
    print("btn equio clicked")
    local index = curr_index
    print("equip cannon with index:" .. index)
    if FF_G and FF_G.uiInfo and FF_G.uiInfo.onCannonChanged then
        FF_G.uiInfo.onCannonChanged(index)
        update_buttons()
    else
        print("********************* FF_G.uiInfo not found *********************")
    end
end

function get_current_cannon_index()
    if FF_G and FF_G.uiInfo and FF_G.uiInfo.cannonIndex then
        return FF_G.uiInfo.cannonIndex
    else
        print("********************* FF_G.uiInfo not found *********************")
        return 1
    end
end
