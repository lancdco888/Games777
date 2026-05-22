local MsgBoxLayer = class("MsgBoxLayer", function()
    return Tools.CreateLayer("csb/common/MsgBox.csb")
end)

function MsgBoxLayer:onEnter()
    self:InitUI()
end

function MsgBoxLayer:onExit()
    if self.callback then
        self.callback()
        self.callback = nil
    end
end

function MsgBoxLayer:InitUI()
    print("is init ??" .. tostring(self.__inited))
    if self.__inited then
        return
    end
    self.__inited = true
    self.callback = nil

    self.ui_text = self:findChild("text")
    self.ui_btn_ok = self:findChild("_lang_btn_ok")
    self.ui_btn_confirm = self:findChild("_lang_btn_confirm")
    self.ui_btn_cancel = self:findChild("_lang_btn_cancel")

    local ui_btn_safebox = self:findChild("_lang_btn_safebox")
    if ui_btn_safebox then ui_btn_safebox:setVisible(false) end
    local ui_btn_recharge = self:findChild("_lang_btn_recharge")
    if ui_btn_recharge then ui_btn_recharge:setVisible(false) end

    self.btn_close = self:findChild("btn_close")

    Tools.AddClickEvent(self.ui_btn_ok, function()
        self:OnBtnOKClick()
    end, true)
    Tools.AddClickEvent(self.ui_btn_confirm, function()
        self:OnBtnConfirmClick()
    end, true)
    Tools.AddClickEvent(self.ui_btn_cancel, function()
        self:OnBtnCancelClick()
    end, true)
    Tools.AddClickEvent(self.btn_close, function()
        self:Close()
    end, true)
    self.ui_btn_ok:setVisible(false)
    self.ui_btn_confirm:setVisible(false)
    self.ui_btn_cancel:setVisible(false)
    self.btn_close:setVisible(false)
end

function MsgBoxLayer:OnBtnOKClick()
    self.callback = self.on_confirm
    self:Close()
end

function MsgBoxLayer:OnBtnConfirmClick()
    self.callback = self.on_confirm
    self:Close()
end

function MsgBoxLayer:OnBtnCancelClick()
    self.callback = self.on_cancel
    self:Close()
end

-----------------------------------------------------------------

function MsgBoxLayer:ShowMsgBox(msg, on_confirm, on_cancel)
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
end

function MsgBoxLayer:ShowTaskTips(msg, on_confirm, on_cancel)
	self.ui_text:setTextHorizontalAlignment(cc.TEXT_ALIGNMENT_LEFT)
    self:ShowMsgBox(msg, on_confirm, on_cancel)
end

return MsgBoxLayer
