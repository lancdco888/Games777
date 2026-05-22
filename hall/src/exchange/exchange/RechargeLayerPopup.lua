--TODO : 需要处理 通知信息
local RechargeLayerPopup = class("RechargeLayerPopup", function()
    return Tools.CreateLayer("csb/RechargeLayerPopup.csb")
end)

--此处TR只为标记, 以便工具提取翻译
local TR = function (str_)
    return str_
end

function RechargeLayerPopup:onEnter()
    self:InitUI()
end

function RechargeLayerPopup:OnBtnClose()
	self:Close()
end

function RechargeLayerPopup:InitUI()
    self.RechargeWayName = {
        [1]	=	TR("ATM转账"),
		[2]	=	TR("网银转账"),
		[3]	=	TR("手机银行转账"),
		[4]	=	TR("现金柜台汇款"),
		[5]	=	TR("现金ATM存款"),
		[6]	=	TR("短信汇款")
    }
    self.RechargeNameList = {
		[1] = "ATM TRANSFER",
		[2]	= "IB TRANSFER",
		[3] = "MOBILE BANKING TRANSFER",
		[4]	= "CASH DEPOSIT",
		[5] = "CDM TRANSFER",
		[6] = "SMS TRANSFER"
	}
    self.rechargenameid = 0
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

    --付款人姓名输入框
    local input = popup:getChildByName("payer_name")
	input = Tools.ReplaceEdit(input)
	input:setInputMode(cc.EDITBOX_INPUT_MODE_SINGLELINE)
	input:setFontSize(24)
	input:setMaxLength(100)
	input:setPlaceholderFontSize(26)
	input:setReturnType(cc.KEYBOARD_RETURNTYPE_DONE)
	input:setTextHorizontalAlignment(cc.TEXT_ALIGNMENT_CENTER)
	self.input = input

    --提示信息
    self.tips = popup:getChildByName("tips")

    --支付方式
    self.pay_type_name = popup:getChildByName("pay_type_name")
    --支付方式表
    self:PayListInit()

    --已支付按钮
    local btn_confirm = popup:getChildByName("_lang_btn_cg")
    Tools.AddClickEvent(btn_confirm, function()
        if self.pay_type_name:getString() == "" then
            local a = TR("请选择支付方式")
			UIManager.ShowToast(TR_("请选择支付方式"))
            return
		end
        if self.input:getText() == "" then
            UIManager.ShowToast(TR_("姓名不能为空，请输入正确的姓名"))
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

--支付方式表初始化
function RechargeLayerPopup:PayListInit()
    local popup = self:getChildByName("bg")
    local list_bg_visible = false
    --表
    self.list_bg = popup:getChildByName("listvew_bg")
    self.list_bg:setVisible(list_bg_visible)
    --下拉按钮
    self.list_show_btn = popup:getChildByName("Button_look")
    Tools.AddClickEvent(self.list_show_btn, function()
        list_bg_visible = not list_bg_visible
        self.list_show_btn:getChildByName("btn"):setEnabled(not list_bg_visible)
        self.input:setVisible(not list_bg_visible)
        self.list_bg:setVisible(list_bg_visible)
    end, true)
    self.list = self.list_bg:getChildByName("listvew")
    self.item = self.list:getChildByName("item")
    self.item:retain()
    self.list:removeAllItems()
    for key, value in pairs(self.RechargeWayName) do
        local new_item = self.item:clone()
        self.list:pushBackCustomItem(new_item)
        local pay_name = new_item:getChildByName("text")
        pay_name:setString(TR_(value))
		Tools.AddClickEvent(new_item,function()
			self.list_show_btn:setEnabled(true)
            self.list_show_btn:getChildByName("btn"):setEnabled(true)
            self.input:setVisible(true)
            self.list_bg:setVisible(false)
            self.pay_type_name:setString(TR_(value))
            self.rechargenameid = key
            list_bg_visible = not list_bg_visible
		end)
    end
end

function RechargeLayerPopup:setInfo(ordernum,datelist)
    if self ~= nil then
        self.ordernum = ordernum
        self.datelist = datelist
        self.bank_name:setString(self.datelist.bank_name)
        self.card_number:setString(self.datelist.account)
        self.tips:setString(self.datelist.description)
    end
end

function RechargeLayerPopup:sendRechargeInfo(rlt_)
    go(function()
		local data_ = PKG_Client_Lobby_ClientRechargeRequestPayerInfo.Create()
		data_.order_num = self.ordernum
        data_.payer_name = self.input:getText()
        data_.payer_type = self.RechargeNameList[self.rechargenameid]
        data_.upstream_order_num = ""
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

return RechargeLayerPopup