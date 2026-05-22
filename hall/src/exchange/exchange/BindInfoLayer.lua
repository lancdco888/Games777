local BindInfoLayer = class("BindInfoLayer", function()
    return Tools.CreateLayer("csb/BindInfoLayer.csb")
end)

function BindInfoLayer:onEnter()
    self.name = ""
    self.bankCard_ = ""
    self.bankname = ""
    self.phone_ = ""
    self:InitUI()
end

function BindInfoLayer:InitUI()
    local callback = function ()
        local layer = PopLayer:Pop(BindCardAndPhoneLayer)
        local tab = {}
        tab.name = self.xm_text:getString()
        tab.bankname = self.bankname
        tab.bankCard = self.yhkh_text:getString()
        tab.phone = self.sjhm_text:getString()
        layer:SetDefInfo(tab,"bind")
        self:Close()
    end
    self.xm_text = self:getChildByName("xm_text")
    local xm_btn = self:getChildByName("xm_btn")
    Tools.AddClickEvent(xm_btn,callback)

    self.yhkh_text = self:getChildByName("yhkh_text")
    local yhkh_btn = self:getChildByName("yhkh_btn")
    Tools.AddClickEvent(yhkh_btn,callback)

    self.sjhm_text = self:getChildByName("sjhm_text")
    local sjhm_btn = self:getChildByName("sjhm_btn")
    Tools.AddClickEvent(sjhm_btn,callback)

    --关闭按钮
    local close = self:getChildByName("close")
    Tools.AddClickEvent(close, function()
        PopLayer:Close(LobbyRechargeLayer)
		self:Close()
    end, true)
    
    --绑定按钮
    local bind_1 = self:getChildByName("_lang_bind_1")
    Tools.AddClickEvent(bind_1,callback, true)
    local bind_2 = self:getChildByName("_lang_bind_2")
    Tools.AddClickEvent(bind_2, callback, true)

    --修改按钮
    local modify = self:getChildByName("_lang_modify")
    Tools.AddClickEvent(modify,function ()
        if sGameManager.max_fix_realname_money < UserData.money + UserData.money_safe then
            local str_ = string.gsub(TR("金币超过XXX,不允许修改!"),"XXX",tostring(sGameManager.max_fix_realname_money / sGameManager.exchangerate))
            UIManager.ShowMsgBox(str_)
            return
        end
        local layer = PopLayer:Pop(BindCardAndPhoneLayer)
        local tab = {}
        tab.name = self.xm_text:getString()
        tab.bankname = self.bankname
        tab.bankCard = self.yhkh_text:getString()
        tab.phone = self.sjhm_text:getString()
        layer:SetDefInfo(tab,"modify")
        self:Close()
    end)
    if sGameManager.max_fix_realname_money == 0 then
        modify:setVisible(false)
    end

    --获取绑定信息，刷新界面
    for i = 1, #UserData.pay_channel_accounts do
        local infos = UserData.pay_channel_accounts[i]
        if infos.pay_channel_id == 2 then
            self.name = infos.name
            self.bankCard_ = infos.card_number
            self.bankname = infos.bank_name
        elseif infos.pay_channel_id == 801 then
            self.name = infos.name
            self.phone_ = infos.card_number
        end
    end
    if self.phone_ ~= "" then
        bind_2:setVisible(false)
    end
    if self.bankCard_ ~= "" then
        bind_1:setVisible(false)
    end
    if self.phone_ == "" and self.bankCard_ == "" then
        modify:setVisible(false)
    end
    if self.phone_ ~= "" and self.bankCard_ ~= "" then
        xm_btn:setVisible(false)
        yhkh_btn:setVisible(false)
        sjhm_btn:setVisible(false)
    end
    self.xm_text:setString(self.name)
    self.yhkh_text:setString(self.bankCard_)
    self.sjhm_text:setString(self.phone_)
    if ConfigParam.Region == "tha" then
        self:getChildByName("_lang_sjhm"):setVisible(false)
    elseif ConfigParam.Region == "ind" or ConfigParam.Region == "ms" then
        self:getChildByName("_lang_truemoney_sjhm"):setVisible(false)
    end

    --提示信息添加
    local tips = self:getChildByName("tips")
    if ConfigParam.Region == "ms" then
        tips:setString(TR("此信息是您唯一的存款和提款凭证，请绑定真实信息"))
    else
        tips:setString(" ")
    end
end

return BindInfoLayer