--TODO : 需要处理 通知信息
local RechargePopup_VN = class("RechargePopup_VN", function()
    return Tools.CreateLayer("csb/RechargePopup_VN.csb")
end)

--此处TR只为标记, 以便工具提取翻译
local TR = function (str_)
    return str_
end

function RechargePopup_VN:onEnter()
    self:InitUI()
end

function RechargePopup_VN:OnBtnClose()
	self:Close()
end

function RechargePopup_VN:InitUI()
    local popup = self:getChildByName("bg")
	--关闭按钮
	local btn_close = popup:getChildByName("btn_close")
    Tools.AddClickEvent(btn_close, function()
        self:OnBtnClose()
    end, true)
    
    --账号名
    self.bank_name = popup:getChildByName("bank_name")
    --复制账号名
    local copy_name = popup:getChildByName("_lang_copy_name")
    Tools.AddClickEvent(copy_name, function()
        if self.bank_name:getString() ~= "" then
			Device:CopyString(self.bank_name:getString())
			UIManager.ShowToast(TR_("复制成功"))
		end
    end, true)
    
    --卡号
    self.card_number = popup:getChildByName("bank_card")
    --复制卡号
    local copy_acc = popup:getChildByName("_lang_copy_acc")
    Tools.AddClickEvent(copy_acc, function()
        if self.card_number:getString() ~= "" then
			Device:CopyString(self.card_number:getString())
			UIManager.ShowToast(TR_("复制成功"))
		end
    end, true)

    local _lang_dddh = self:getChildByName("_lang_dddh")
    _lang_dddh:setString(string.format(TR_("订单号最后%d位"),5))

    --订单号后五位输入框
    local input = popup:getChildByName("ordernum_5")
	input = Tools.ReplaceEdit(input)
	input:setInputMode(cc.EDITBOX_INPUT_MODE_PHONENUMBER)
	input:setFontSize(24)
	input:setMaxLength(5)
	input:setPlaceholderFontSize(26)
	input:setReturnType(cc.KEYBOARD_RETURNTYPE_DONE)
	input:setTextHorizontalAlignment(cc.TEXT_ALIGNMENT_CENTER)
	self.input = input

    --提示信息
    self.tips = popup:getChildByName("tips")

    --已支付按钮
    local btn_confirm = popup:getChildByName("_lang_btn_cg")
    Tools.AddClickEvent(btn_confirm, function()
        if self.input:getText() == "" then
            UIManager.ShowToast(TR_(""))
            return
        elseif exutils.strIsBlank(self.input:getText()) then
            UIManager.ShowToast(TR_("姓名不能全是空格，请输入正确的姓名"))
            return
        end
        self:sendRechargeInfo()
    end, true)

    --放弃支付
    local btn_confirm = popup:getChildByName("_lang_btn_sb")
    Tools.AddClickEvent(btn_confirm, function()
		self:Close()
    end, true)
end

function RechargePopup_VN:setInfo(ordernum,datelist)
    if not datelist or not ordernum then
        UIManager.ShowToast("RechargePopup_VN vip infos error")
        self:Close()
        return
    end
    if self ~= nil then
        self.ordernum = ordernum
        self.datelist = datelist
        self.bank_name:setString(self.datelist.bank_name)
        self.card_number:setString(self.datelist.account)
        self.tips:setString(self.datelist.description)
    end
end

function RechargePopup_VN:sendRechargeInfo(rlt_)
    go(function()
		local data_ = PKG_Client_Lobby_ClientRechargeRequestPayerInfo.Create()
		data_.order_num = self.ordernum
        data_.payer_name = ""
        data_.payer_type = ""
        data_.upstream_order_num = self.input:getText()
        data_.payer_cardnumber = ""
		UIManager.ShowWaiting()
		local rlt_ = gNet_SendRequest(data_)
		UIManager.HideWaiting()
        if (getmetatable(rlt_) == PKG_Generic_Success) then
            local a = TR("请等待审核，3分钟内审核通过后系统会自动帮您冲入金币。如有疑问请联络客服查询!")
            UIManager.ShowMsgBox(TR_(a))

            PopLayer:Close(LobbyRechargeLayer)
            if not tolua.isnull(self) then
                self:Close()
            end
        elseif(getmetatable(rlt_) == PKG_Generic_Error) then
            local num = Int64ToNumber(rlt_.number)
            if num == -120 then
                UIManager.ShowMsgBox(TR_("您的上一笔支付订单我们正在审核操作中，请及时关注金币到账情况耐心等待！如有疑问请咨询客服。"))
            else
                UIManager.ShowMsgBox(TR_("请求充值失败，请联系客服后重试"))
            end
        end
	end)
end

return RechargePopup_VN