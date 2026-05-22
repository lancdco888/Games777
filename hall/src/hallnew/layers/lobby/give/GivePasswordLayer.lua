local GivePasswordLayer = class('GivePasswordLayer', function()
    return Tools.CreateLayer('csb/Give/GivePasswordLayer.csb')
end)

function GivePasswordLayer:onEnter()
    self:InitUI()
end

function GivePasswordLayer:InitUI()
    local ui_btn_close = self:findChild("btn_close")
    Tools.AddClickEvent(ui_btn_close, function()
        self:Close()
    end, true)
    local _lang_btn_ok = self:findChild("_lang_btn_ok")
    Tools.AddClickEvent(_lang_btn_ok, function()
        self:OnBtnConfirm()
    end, true)
    local _lang_btn_cancel = self:findChild("_lang_btn_cancel")
    Tools.AddClickEvent(_lang_btn_cancel, function()
        self:Close()
    end, true)
    --处理密码输入框
    local ui_passwd_1 = self:findChild("inputPWD")
    self.ui_passwd_1 = self:InitEdit(ui_passwd_1)
    local ui_passwd_2 = self:findChild("inputPWD1")
    self.ui_passwd_2 = self:InitEdit(ui_passwd_2)

end

function GivePasswordLayer:OnBtnConfirm()
    local passwd1 = self.ui_passwd_1:getString()
    local passwd2 = self.ui_passwd_2:getString()
    if passwd1 == "" then
        UIManager.ShowMsgBox(TR("请输入密码"))
        return
    end
    if #passwd1 < 8 then
        UIManager.ShowMsgBox(TR("密码至少需要8位"))
        return
    end
    if passwd1 ~= passwd2 then
        UIManager.ShowMsgBox(TR("请确认两次密码输入一致"))
        return
    end
    self:HandleResetPassword(passwd1)
end

function GivePasswordLayer:OnSetPasswdDone(cbk)
    self.onSetCallBack = cbk
end

function GivePasswordLayer:HandleResetPassword(passwd)

    go(
		function()
			local data_ = PKG_Client_Lobby_ClientGiftPassword.Create()
			data_.content  = passwd
			UIManager.ShowWaiting()
			local rlt_ =  gNet_SendRequest(data_)
			UIManager.HideWaiting()
            if rlt_ == nil then return end
				--收到返回数据
            if getmetatable(rlt_) == PKG_Generic_Success then
                UserData.is_gift_money_password = 1
                if tolua.isnull(self) then return end
                if self.onSetCallBack then
                    self.onSetCallBack()
                end
                self:Close()
            elseif(getmetatable(rlt_) == PKG_Generic_Error) then
                local num = rlt_.number
                if (num == Def.Net_Login_PasswordWorng) then
                    UIManager.ShowMsgBox(TR("验证码已过期，请重新发送"))
                else
                    UIManager.ShowMsgBox(TR("密码设置失败"))
                end
            end
        end
	)
end

function GivePasswordLayer:InitEdit(edit)
	local new_edit = Tools.ReplaceEdit(edit,TR("8到12位之间"))
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

return GivePasswordLayer
