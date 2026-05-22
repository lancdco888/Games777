local UIManager = {}

----------------------------------------------------------------
-- Waiting 界面处理

UIManager.waiting_cnt = 0
UIManager.waiting_layer = nil

function UIManager.ShowWaiting()
    local layer = UIManager.waiting_layer
    if layer == nil then
        local WaitingLayer = require("packagelua.src.msg.WaitingLayer")
        layer = WaitingLayer:create()
        gScene:addChild(layer)
        UIManager.waiting_layer = layer
        UIManager.waiting_cnt = 0
    end
    layer:setVisible(true)
    UIManager.waiting_cnt = UIManager.waiting_cnt + 1
end

function UIManager.HideWaiting()
    UIManager.waiting_cnt = UIManager.waiting_cnt - 1
    if UIManager.waiting_cnt <= 0 then
        if UIManager.waiting_layer ~= nil then
            UIManager.waiting_layer:removeFromParent()
            UIManager.waiting_layer = nil
        end
        UIManager.waiting_cnt = 0
    end
end

UIManager.DEFAULT_DISABLE_TOUCH_TIME = 1.2
function UIManager.DisableTouch(time)
    local bg = cc.Node:create()
    cc.Director:getInstance():getRunningScene():addChild(bg)

    bg:runAction(cc.Sequence:create(
        cc.DelayTime:create(time or UIManager.DEFAULT_DISABLE_TOUCH_TIME),
        cc.RemoveSelf:create()
    ))

    local listener = cc.EventListenerTouchOneByOne:create()
    listener:setSwallowTouches(true)
    listener:registerScriptHandler(function(touch,event)
        return true
    end, cc.Handler.EVENT_TOUCH_BEGAN)
    cc.Director:getInstance():getEventDispatcher():addEventListenerWithSceneGraphPriority(listener, bg)
end

----------------------------------------------------------------

UIManager.toast_layer = nil
function UIManager.ShowToast(msg)
    local layer = UIManager.toast_layer
    if layer == nil then
        layer = PopLayer:PopToastNode(ToastLayer)
        UIManager.toast_layer = layer
    end
    layer:ShowToast(msg)
end

----------------------------------------------------------------

function UIManager.ShowMsgBox(msg, on_ok, on_cancel)
    local layer = PopLayer:Pop(MsgBoxLayer)
    layer:InitUI()
    layer:ShowMsgBox(msg, on_ok, on_cancel)
    return layer
end

----------------------------------------------------------------

return UIManager
