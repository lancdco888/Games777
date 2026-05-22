-- 捕鱼游戏最外层 ui
module("menu", package.seeall)

local node = nil        -- 根节点
local btn_menu = nil

function init()
    node = cc.CSLoader:createNode("csb/Menu.csb")
    if node == nil then return end

    local p = check_ui_root()
    p:addChild(node)
    
    -- 显示到左中
    local size = cc.Director:getInstance():getVisibleSize()
    local pos = cc.p(0, size.height/2)
    pos = p:convertToNodeSpace(pos)
    node:setPosition(pos)

    btn_menu = node:findChild("btn_menu")
    add_click_event(btn_menu, on_menu_clicked)
end

function on_menu_clicked()
    print("btn menu clicked.")
    local layer = option_layer.pop()
    layer.onExit = function()
        btn_menu:setVisible(true)
    end
    btn_menu:setVisible(false)
end
