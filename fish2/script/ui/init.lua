-------------------------------------------------------------------------------------------
--         初始化游戏 ui 模块，添加 ui 根节点，搜索路径等
-------------------------------------------------------------------------------------------

local catch_fish = nil

if not GetLang then
    function GetLang()
        return "en"
    end
end

function init_fish_ui(cf)
    print("init_fish_ui ...")

    catch_fish = cf
    add_fish_ui_search_path()

    require("script.ui.menu")
    require("script.ui.fish_layer")
    require("script.ui.option_layer")
    require("script.ui.canno_layer")
    require("script.ui.effect.dragon_turntable")

    local lang = GetLang()
    cc.SpriteFrameCache:getInstance():addSpriteFrames("ui/studio/fish2_ui_" .. lang .. ".plist")

    check_ui_root()
    menu.init()
end

-------------------------------------------------------------------------------------------
--         销毁 ui 模块
-------------------------------------------------------------------------------------------

function destroy_fish_ui()
    -- 卸载相关模块
    for k,v in pairs(package.loaded) do
        if string.find(k, "script.ui.") then
            package.loaded[k] = nil
        end
    end

    local node = check_ui_root()
    if node then
        node:removeFromParent()
    end

    remove_fish_ui_search_path()
end

function get_catch_fish()
    return catch_fish
end

-------------------------------------------------------------------------------------------
--         获取 ui 的根节点，若不存在就构造一个，并将其附加到 当前场景
-------------------------------------------------------------------------------------------

function check_ui_root()
    print("check ui root")
    local ui_root = nil
    if FF_G_Client then
        -- 进入捕鱼走该代码，便于统一生命周期管理
        -- ui_root = FF_G_Client.GetNodeByNodeIndex(FF_G.kNodeIndex_UiTop)
        ui_root = FF_G_Client.GetNodeByNodeIndex(FF_G.kNodeIndex_SubUi)
    else
        -- 在大厅测试是走下面的代码
        ui_root = cc.Node:create()
        local size = cc.Director:getInstance():getVisibleSize()
        ui_root:setScale(Def.ScaleMin)
        ui_root:setPosition(size.width/2, size.height/2)
        cc.Director:getInstance():getRunningScene():addChild(ui_root)
    end

    local node = ui_root:findChild("fish_ui_root")
    if not node then
        node = cc.Node:create()
        ui_root:addChild(node)
        node:setName("fish_ui_root")
    end
    return node
end

-------------------------------------------------------------------------------------------
--         搜索路径管理
-------------------------------------------------------------------------------------------

function add_fish_ui_search_path()
    local basicPath = cc.FileUtils:getInstance():getWritablePath() .. "download/src/"
    cc.FileUtils:getInstance():addSearchPath(basicPath .. "fish2/res/ui/studio/", true)

    local defp = cc.FileUtils:getInstance():getDefaultResourceRootPath()
    cc.FileUtils:getInstance():addSearchPath(defp .. "fish2/res/ui/studio/", true)
end

function remove_fish_ui_search_path()
    local basicPath = cc.FileUtils:getInstance():getWritablePath() .. "download/src/"
    cc.FileUtils:getInstance():removeSearchPath(basicPath .. "fish2/res/ui/studio/")

    local defp = cc.FileUtils:getInstance():getDefaultResourceRootPath()
    cc.FileUtils:getInstance():removeSearchPath(defp .. "fish2/res/ui/studio/")
end

-------------------------------------------------------------------------------------------
--         按钮控件点击事件
-------------------------------------------------------------------------------------------

function add_click_event(btn, handler)
    btn:addTouchEventListener(function(ref, type)
        if type == ccui.TouchEventType.ended then
            -- 按键音效
            gSound.clickSound()
            handler()
        end
    end)
end

-------------------------------------------------------------------------------------------
--         弹出节点, 根节点是 ui 根节点
-------------------------------------------------------------------------------------------

function pop_layer(layer, parent)
    local open_time = 0.15
    local shrink_time = 0.05
    layer:runAction(cc.Sequence:create(
        cc.ScaleTo:create(open_time, 1.1),
        cc.ScaleTo:create(shrink_time, 1)))
        
    local root = parent or check_ui_root()
    root:addChild(layer)
    --layer:setAnchorPoint(cc.p(0.5, 0.5))
    --layer:setContentSize(cc.size(1280, 720))
    --local size = cc.Director:getInstance():getVisibleSize()
    --layer:setPosition(size.width/2, size.height/2)
end

function adjust_bg(bg_node)
    local size = cc.Director:getInstance():getVisibleSize()
    local left_b = bg_node:convertToNodeSpace(cc.p(0, 0))
    local right_t = bg_node:convertToNodeSpace(cc.p(size.width, size.height))
    local bg_size = cc.size(right_t.x - left_b.x, right_t.y - left_b.y)
    bg_node:setContentSize(bg_size)
end

-------------------------------------------------------------------------------------------
--         关闭节点
-------------------------------------------------------------------------------------------

function close_layer(layer)
    layer:runAction(
        cc.Sequence:create(
            cc.ScaleTo:create(
                0.2,
                0),
            cc.RemoveSelf:create()))
end

-------------------------------------------------------------------------------------------
--         通过名字递归查找子节点，与 src/hall/src/hallnew/cocos_ext/NodeExt.lua 保持一致
-------------------------------------------------------------------------------------------

function cc.Node:findChild(name)
    local children = self:getChildren()
    for idx, child in ipairs(children) do
        if child:getName() == name then
            return child
        end
        local node = child:findChild(name)
        if node then
            return node
        end
    end
    return nil
end
