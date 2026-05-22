local AccountBindAdLayer = class("AccountBindAdLayer", function()
    return Tools.CreateLayer("csb/lobby/AccountBindAdLayer.csb")
end)

function AccountBindAdLayer:onEnter()
	self:InitUI()

end

function AccountBindAdLayer:SetCloseFunc(isClose,closefunc)
    local btn_close = self:findChild("btn_close")
    btn_close:setVisible(closefunc == nil)

    if closefunc then
        local func = self.Close
        self.Close = function ()
            if func then
                func()
            end 
            closefunc()
        end
    end
end

function AccountBindAdLayer:InitUI()
    local _lang_btn_confirm = self:findChild("_lang_btn_confirm")
    if _lang_btn_confirm then
        Tools.AddClickEvent(_lang_btn_confirm, function()
            self:OnConfirm()
        end, true)
    end

    local btn_close = self:findChild("btn_close")
    Tools.AddClickEvent(btn_close, function()
        self:Close()
    end, true)
    local num = self:findChild("num")
    num:setString(Tools.CoinToShowString(UserData.bind_account_money_gift))
end

function AccountBindAdLayer:OnConfirm()
    if UserData.is_open_email_bind and
        UserData.is_open_email_bind == 1 then
        
        PopLayer:Pop(user.AccountEmailBindingLayer)
    else
        PopLayer:Pop(user.AccountBindingLayer)
    end
    self:Close()
end

return AccountBindAdLayer
