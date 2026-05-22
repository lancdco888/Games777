local InputGivePasswdLayer = class('InputGivePasswdLayer', function()
    return Tools.CreateLayer('csb/Give/InputGivePasswdLayer.csb')
end)

function InputGivePasswdLayer:onEnter()
    self:InitUI()
end

function InputGivePasswdLayer:InitUI()
    local ui_btn_close = self:findChild("btn_close")
    Tools.AddClickEvent(ui_btn_close, function()
        self:Close()
    end, true)

    local confirm_btn = self:findChild("_lang_btn_ok")
    Tools.AddClickEvent(confirm_btn, function()
        self:OnBtnConfirm()
    end, true)

    local cancel_btn = self:findChild("_lang_btn_cancel")
    Tools.AddClickEvent(cancel_btn, function()
        self:Close()
    end, true)

    --处理密码输入框
    local ui_passwd = self:getChild("input_bg/input_mode")
    self.ui_passwd = self:InitEdit(ui_passwd)

    self.tips = self:findChild("text_tips")
    self.tips:setString("")

    self.text_fee_tips = self:findChild("text_fee_tips")
    self.text_fee_tips:setString("")
end

function InputGivePasswdLayer:OnBtnConfirm()
    local passwd = self.ui_passwd:getString()
    if passwd == "" then
        UIManager.ShowMsgBox(TR("请输入赠送密码"))
        return
    end

    if #passwd < 8 then
        UIManager.ShowMsgBox(TR("密码至少需要8位"))
        return
    end
    
    if self.onInputCallBack then
        self.onInputCallBack(passwd)
    end

    self:Close()
end

function InputGivePasswdLayer:OnInputPasswdDone(cbk)
    self.onInputCallBack = cbk
end

function InputGivePasswdLayer:SetGiveTips(user_id, money, money_fee)
    self.tips:setString(Tools.Fmt(TR("确认赠送给玩家{0}金币{1}吗?"), user_id, money))
    self.text_fee_tips:setString(Tools.Fmt(TR("手续费{0}金币"), money_fee))
end

function InputGivePasswdLayer:InitEdit(edit)
	local new_edit = Tools.ReplaceEdit(edit,"请输入赠送密码")
    new_edit:setFontSize(36)
    new_edit:setMaxLength(12)
    new_edit:setPlaceholderFontSize(24)
	new_edit:setInputFlag(cc.EDITBOX_INPUT_FLAG_PASSWORD)
    new_edit:setInputMode(cc.EDITBOX_INPUT_MODE_SINGLELINE)
    new_edit:setTextHorizontalAlignment(cc.TEXT_ALIGNMENT_CENTER)
    new_edit:setFontColor(cc.c3b(255,255,255))
	new_edit:setPlaceholderFontColor(cc.c3b(118, 118, 118))
    return new_edit
end

return InputGivePasswdLayer
