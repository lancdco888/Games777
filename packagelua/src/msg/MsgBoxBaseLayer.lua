local MsgBoxBaseLayer = class("MsgBoxBaseLayer")

function MsgBoxBaseLayer:ctor()
    self:InitUI()
    self:AdjustUI()
end

function MsgBoxBaseLayer:InitUI()
    self.root = Tools_Base.CreateLayer("packagelua/res/studio/csb/MsgBoxBaseLayer.csb")
    self.Panel = self.root:getChildByName("Panel")
    self.bg = self.root:getChildByName("bg")
    self.ui_text =  self.bg:getChildByName("text")
    self.ui_btn_ok = self.bg:getChildByName("_lang_btn_ok")
    self.ui_btn_confirm = self.bg:getChildByName("_lang_btn_confirm")
    self.ui_btn_cancel = self.bg:getChildByName("_lang_btn_cancel")

    Tools_Base.AddClickEvent(self.ui_btn_ok, function()
        self:OnBtnOKClick()
    end, true)
    Tools_Base.AddClickEvent(self.ui_btn_confirm, function()
        self:OnBtnConfirmClick()
    end, true)
    Tools_Base.AddClickEvent(self.ui_btn_cancel, function()
        self:OnBtnCancelClick()
    end, true)
    self.ui_btn_ok:setVisible(false)
    self.ui_btn_confirm:setVisible(false)
    self.ui_btn_cancel:setVisible(false)
end

function MsgBoxBaseLayer:OnBtnOKClick()
    if self.on_confirm then
        self.on_confirm()
    end
    self:close()
end

function MsgBoxBaseLayer:OnBtnConfirmClick()
    if self.on_confirm then
        self.on_confirm()
    end
    self:close()
end

function MsgBoxBaseLayer:OnBtnCancelClick()
    if self.on_cancel then
        self.on_cancel()
    end
    self:close()
end
function MsgBoxBaseLayer:close()
    self.root:removeFromParent()
end

-----------------------------------------------------------------

function MsgBoxBaseLayer:ShowMsgBox(msg, on_confirm, on_cancel)
    self.ui_text:setString(tostring(msg))
    if on_confirm and on_cancel then
        self.ui_btn_confirm:setVisible(true)
        self.ui_btn_cancel:setVisible(true)
        self.ui_btn_ok:setVisible(false)
    else
        self.ui_btn_confirm:setVisible(false)
        self.ui_btn_cancel:setVisible(false)
        self.ui_btn_ok:setVisible(true)
    end
    self.on_confirm = on_confirm
    self.on_cancel = on_cancel

    cc.Director:getInstance():getRunningScene():addChild(self.root,10000)
    self.bg:setScale(0)
    local scale = Tools_Base.ScaleMin
    --弹出框显示时的动画时间
    local open_time = 0.15
    local shrink_time = 0.05
    self.bg:runAction(cc.Sequence:create(cc.ScaleTo:create(open_time, scale*1.1),
        cc.ScaleTo:create(shrink_time, scale)))
end

function MsgBoxBaseLayer:AdjustUI()
    --背景 铺满
    self.Panel:setScale(Tools_Base.ScaleMax)
    local center = cc.p(Tools_Base.visibleSize.width/2.0, Tools_Base.visibleSize.height/2.0)
    self.Panel:setPosition(center)
    --面板尽量放大居中
    self.bg:setScale(Tools_Base.ScaleMin)
    self.bg:setPosition(center)
end

return MsgBoxBaseLayer
