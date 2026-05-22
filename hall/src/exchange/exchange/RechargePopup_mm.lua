--TODO : 需要处理 通知信息
local RechargePopup_mm = class("RechargePopup_mm", function()
    return Tools.CreateLayer("csb/RechargePopup_mm.csb")
end)

function RechargePopup_mm:onEnter()
    self:InitUI()
end

function RechargePopup_mm:OnBtnClose()
	self:Close()
end

function RechargePopup_mm:getLatOrderNumber()
    if ConfigParam.Region == "bd" then
        return 13
    else
        return 5
    end
end

function RechargePopup_mm:InitUI()
    local popup = self:getChildByName("bg")
	--关闭按钮
	local btn_close = popup:getChildByName("btn_close")
    Tools.AddClickEvent(btn_close, function()
        self:OnBtnClose()
    end, true)
    
    --账号名
    self.bank_name = popup:getChildByName("bank_name")
    --复制账号名
    local _lang_copy_name = popup:getChildByName("_lang_copy_name")
    Tools.AddClickEvent(_lang_copy_name, function()
        if self.bank_name:getString() ~= "" then
			Device:CopyString(self.bank_name:getString())
			UIManager.ShowToast(TR("复制成功"))
		end
    end, true)
    
    --卡号
    self.card_number = popup:getChildByName("bank_card")
    --复制卡号
    local _lang_copy_acc = popup:getChildByName("_lang_copy_acc")
    Tools.AddClickEvent(_lang_copy_acc, function()
        if self.card_number:getString() ~= "" then
			Device:CopyString(self.card_number:getString())
			UIManager.ShowToast(TR("复制成功"))
		end
    end, true)

    --支付金额
    self.money = popup:getChildByName("pay_num")
    --复制支付金额
    local _lang_copy_num = popup:getChildByName("_lang_copy_num")
    Tools.AddClickEvent(_lang_copy_num, function()
        if self.money:getString() ~= "" then
			Device:CopyString(self.money:getString())
			UIManager.ShowToast(TR("复制成功"))
		end
    end, true)

    --付款人姓名输入框
    local input_name = popup:getChildByName("payer_name")
	input_name = Tools.ReplaceEdit(input_name)
	input_name:setInputMode(cc.EDITBOX_INPUT_MODE_SINGLELINE)
	input_name:setFontSize(24)
	input_name:setMaxLength(100)
	input_name:setPlaceholderFontSize(26)
	input_name:setReturnType(cc.KEYBOARD_RETURNTYPE_DONE)
	input_name:setTextHorizontalAlignment(cc.TEXT_ALIGNMENT_CENTER)
	self.input_name = input_name

    local _lang_order_last5 = self:getChildByName("_lang_order_last5")
    local lastOrderNum = self:getLatOrderNumber()
    if ConfigParam.Region == "bd" then
        _lang_order_last5:setString(TR("订单号"))
    else
        _lang_order_last5:setString(string.format(TR_("订单号最后%d位"), lastOrderNum))
    end

    --订单号后五位输入框
    local input = popup:getChildByName("order_last5")
	input = Tools.ReplaceEdit(input)
    if ConfigParam.Region == "ph" or ConfigParam.Region == "bd" then
	    input:setInputMode(cc.EDITBOX_INPUT_MODE_ANY)
    else
	    input:setInputMode(cc.EDITBOX_INPUT_MODE_PHONENUMBER)
    end
	input:setFontSize(24)
	input:setMaxLength(lastOrderNum)
	input:setPlaceholderFontSize(26)
	input:setReturnType(cc.KEYBOARD_RETURNTYPE_DONE)
	input:setTextHorizontalAlignment(cc.TEXT_ALIGNMENT_CENTER)
	self.input = input

    --提示信息
    self.tips = popup:getChildByName("tips")

    --已支付按钮
    local btn_confirm = popup:getChildByName("_lang_btn_cg")
    local lastOrderNum = self:getLatOrderNumber()
    Tools.AddClickEvent(btn_confirm, function()
        local order = self.input:getText()
        if ConfigParam.Region == "bd" and ( #order < 7 or #order > 13 ) then
            UIManager.ShowToast(TR("请输入正确的单号"))
            return
        end
        if ConfigParam.Region ~= "bd" and #order ~= lastOrderNum  then
            UIManager.ShowToast(TR("请输入正确的单号"))
            return
        end
        if self.input_name:getText() == "" then
            UIManager.ShowToast(TR("姓名不能为空，请输入正确的姓名"))
            return
        elseif exutils.strIsBlank(self.input_name:getText()) then
            UIManager.ShowToast(TR("姓名不能全是空格，请输入正确的姓名"))
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

function RechargePopup_mm:setChannelID(channel_id)
    if channel_id and channel_id >= 310 and channel_id <= 313 then
        self:MakeLang_KAB()
    end
end

function RechargePopup_mm:MakeLang_KAB()
    -- 银行用户名
    local _lang_account = self:findChild("_lang_account")
    _lang_account:setString(TR("收款账号"))

    -- 银行卡号
    local _lang_yhkh = self:findChild("_lang_yhkh")
    _lang_yhkh:setString(TR("收款卡号"))
    
    -- 付款人姓名
    local _lang_fkrxm = self:findChild("_lang_fkrxm")
    _lang_fkrxm:setString(TR("付款用户名"))
end

function RechargePopup_mm:setInfo(ordernum,datelist,money)
    if not datelist or not money or not ordernum then
        UIManager.ShowToast("RechargePopup_mm vip infos error")
        self:Close()
        return
    end
    if self ~= nil then
        self.ordernum = ordernum
        self.datelist = datelist
        self.bank_name:setString(self.datelist.bank_name)
        self.card_number:setString(self.datelist.account)
        if self.datelist.description ~= nil then
            self.tips:setString(self.datelist.description)
        end
        self.money:setString(money)
    end
end

function RechargePopup_mm:sendRechargeInfo(rlt_)
    go(function()
		local data_ = PKG_Client_Lobby_ClientRechargeRequestPayerInfo.Create()
		data_.order_num = self.ordernum
        data_.payer_name = self.input_name:getText()
        data_.payer_type = ""
        data_.upstream_order_num = self.input:getText()
        data_.payer_cardnumber = ""
		UIManager.ShowWaiting()
		local rlt_ = gNet_SendRequest(data_)
		UIManager.HideWaiting()

		if rlt_ == nil then
			UIManager.ShowMsgBox(TR("网络连接失败，请重试"))
			return
		end

        local PKG_name = getmetatable(rlt_)
        if (PKG_name == PKG_Generic_Success) then
            UIManager.ShowMsgBox(TR("请等待审核，3分钟内审核通过后系统会自动帮您冲入金币。如有疑问请联络客服查询!"))

            PopLayer:Close(LobbyRechargeLayer)
            if not tolua.isnull(self) then
                self:Close()
            end
        elseif(PKG_name == PKG_Generic_Error) then
            local num = Int64ToNumber(rlt_.number)
            if num == -120 then
                UIManager.ShowMsgBox(TR("您的上一笔支付订单我们正在审核操作中，请及时关注金币到账情况耐心等待！如有疑问请咨询客服。"))
            else
                UIManager.ShowMsgBox(TR("请求充值失败，请联系客服后重试"))
            end
        end
	end)
end

return RechargePopup_mm