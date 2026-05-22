local RechargePopup_rechargeCard = class("RechargePopup_rechargeCard", function()
    return Tools.CreateLayer("csb/RechargePopup_rechargeCard.csb")
end)

function RechargePopup_rechargeCard:onEnter()
    self:InitUI()
end

function RechargePopup_rechargeCard:OnBtnClose()
	self:Close()
end

function RechargePopup_rechargeCard:InitUI()
    local popup = self:getChildByName("bg")
	--关闭按钮
	local btn_close = popup:getChildByName("btn_close")
    Tools.AddClickEvent(btn_close, function()
        self:OnBtnClose()
    end, true)
    
    --收款号码
    self.card_number = popup:getChildByName("bank_card")
    --复制收款号码
    local _lang_copy_acc = popup:getChildByName("_lang_copy_acc")
    Tools.AddClickEvent(_lang_copy_acc, function()
        if self.card_number:getString() ~= "" then
			Device:CopyString(self.card_number:getString())
			UIManager.ShowToast(TR("复制成功"))
		end
    end, true)

    --充值金额
    self.money = popup:getChildByName("money")

    --充值卡编码
    local input = popup:getChildByName("payer_name")
	input = Tools.ReplaceEdit(input)
	input:setInputMode(cc.EDITBOX_INPUT_MODE_SINGLELINE)
	input:setFontSize(24)
	input:setMaxLength(1000)
	input:setPlaceholderFontSize(26)
	input:setReturnType(cc.KEYBOARD_RETURNTYPE_DONE)
	input:setTextHorizontalAlignment(cc.TEXT_ALIGNMENT_CENTER)
	self.input = input

    --提示信息
    self.tips = popup:getChildByName("tips")

    --已支付按钮
    local btn_confirm = popup:getChildByName("_lang_btn_cg")
    Tools.AddClickEvent(btn_confirm, function()
        if self.input:getText() == "" or exutils.strIsBlank(self.input:getText()) then
            UIManager.ShowToast(TR("请输入充值卡编码"))
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

function RechargePopup_rechargeCard:setInfo(typeid,datelist,money)
    if not datelist or not money or not typeid then
        UIManager.ShowToast("RechargePopup_rechargeCard vip infos error")
        self:Close()
        return
    end
    if self ~= nil then
        self.typeid = typeid
        self.datelist = datelist
        self.card_number:setString(self.datelist.account)
        if self.datelist.description ~= nil then
            self.tips:setString(self.datelist.description)
        end
        self.money:setString(money)
    end
end

function RechargePopup_rechargeCard:sendRechargeInfo(rlt_)
    go(function()
        local data_ = PKG_Client_Lobby_ClientRechargeRequest.Create()
		data_.money = self.money:getString()
		data_.pay_type = self.typeid
		data_.ip_info = ""
		data_.is_create_order = 1
		data_.pay_name = "nil"
		data_.pay_card_number = ""
		data_.upstream_order_num = self.input:getText()
		data_.payment_key = ""
		UIManager.ShowWaiting()
		local rlt_ = gNet_SendRequest(data_)
		UIManager.HideWaiting()
        local PKG_name = getmetatable(rlt_)
		if PKG_name == PKG_Lobby_Client_ClientRechargeRequestSuccess then
            UIManager.ShowMsgBox(TR("请等待审核，3分钟内审核通过后系统会自动帮您冲入金币。如有疑问请联络客服查询!"))

            if not tolua.isnull(self) then
                self:Close()
            end
		elseif PKG_name == PKG_Generic_Error then
			local num = Int64ToNumber(rlt_.number)
			if (num == -120) then
				UIManager.ShowMsgBox(TR("您的上一笔支付订单我们正在审核操作中，请及时关注金币到账情况耐心等待！如有疑问请咨询客服。"))
			else
				UIManager.ShowMsgBox(TR("请求充值失败，请联系客服后重试"))
			end
		end
	end)
end

return RechargePopup_rechargeCard