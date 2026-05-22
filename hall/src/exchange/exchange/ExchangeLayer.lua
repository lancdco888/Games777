local ExchangeLayer = class("ExchangeLayer", function()
	return Tools.CreateLayer("csb/ExchangeLayer.csb")
end)

--此处TR只为标记, 以便工具提取翻译
-- local TR = function (str_)
--     return str_
-- end

local Img = {
	ExchangeLayer_BankBtn_1 = "language/exchange/yhkdhan_1.png",
	ExchangeLayer_BankBtn_2 = "language/exchange/yhkdhan_2.png",
	ExchangeLayer_TMBtn_1   = "exchange/truemoney_1.png",
	ExchangeLayer_TMBtn_2   = "exchange/truemoney_2.png",
	ExchangeLayer_MOMOBtn_1 = "exchange/momo_1.png",
	ExchangeLayer_MOMOBtn_2 = "exchange/momo_2.png",
	ExchangeLayer_ZALOBtn_1 = "exchange/zalo_1.png",
	ExchangeLayer_ZALOBtn_2 = "exchange/zalo_2.png",
	ExchangeLayer_QRCDBtn_1 = "language/exchange/ewmdh_1.png",
	ExchangeLayer_QRCDBtn_2 = "language/exchange/ewmdh_2.png",
}

function ExchangeLayer:ctor()
	self.money = 0								--用户金币总额
	self.select = 0								--用户当前选中额度
	self.bank_card = 0							--银行卡号
	self.margin = UserData.refund_margin	--最小增幅
	self.isSelect = false						--百分比是否显示
	self.show_select = 0
	self.picdata = ""							--二维码对应数据
	self.qr_bankname = ""						--二维码对应银行数据
	self.listisshow = true
	--资源数据
	self.ExchangeBtn_List = {
		[1] = {
			name = TR("支付宝"),
			channelname = TR("支付宝账号:"),
			name_info = TR("实名制姓名:"),
			state_info = TR("状态:"),},
		[2] = {
			name = TR("银行卡"),
			channelname = TR("银行卡账号:"),
			name_info = TR("持卡人姓名:"),
			state_info = TR("状态:"),},
		[801] = {
			name = "true money",
			channelname = "PHONE:",
			name_info = "PHONE:",
			state_info = TR("状态:"),},
		[7]	= {
			name = "MOMO",
			channelname = "MOMO:",
			name_info = TR("姓名:"),
			state_info = TR("状态:"),},
		[8]	= {
			name = "ZALO",
			channelname = "ZALO:",
			name_info = TR("姓名:"),
			state_info = TR("状态:"),},
		[4]	= {
			name = TR("二维码"),
			channelname = "nil",
			name_info = "nil",
			state_info = TR("状态:"),},

		[2001]	= {
			name = TR("TRC20"),
			channelname = "nil",
			name_info = "nil",
			state_info = TR("状态:"),},

		[2002]	= {
			name = TR("ERC20"),
			channelname = "nil",
			name_info = "nil",
			state_info = TR("状态:"),},
	}
end

function ExchangeLayer:onEnter()
	self:InitUI()

	self.money = UserData.money + UserData.money_safe
	--设置界面初始状态
	self.state = sGameManager.exchange_payChannels[1].id
	self.select = 0
	self.bank_card = ""
	self:SetState()
	self:SetCardNumber()
	self:UpdateUI()
	--二维码退款特殊显示
	self:InitBankNameList()
	self:ChangeBindQR()
	self:runAction(cc.RepeatForever:create(
            cc.Sequence:create(
                cc.DelayTime:create(0.12),
                cc.CallFunc:create(function()
                    self:UploadQR_Update()
                end)
            )
        )
    )
end

function ExchangeLayer:onExit()
	Dispatcher:Remove(self)
	self.btnList:removeAllItems()
	self.item:release()
end

function ExchangeLayer:InitUI()
	self:InitPublicUI()
	self:InitPanel()
	self:InitCommonDetail()
	self:InitVCDetail()
	self:InitPixDetail()

	--初始化左侧按钮
	self:InitBtnList()
	Dispatcher:Register("UPDATE_CARD", function()
		self.bank_card = ""
		self:SetCardNumber(true)
	end, self)
	Dispatcher:Register("BIND_VC", function()
		self:SetCardNumber(true)
	end, self)
end

function ExchangeLayer:InitPublicUI()
	--提现记录按钮
	local _lang_record = self:getChild("_lang_record")
	Tools.AddClickEvent(_lang_record, function()
		local layer = PopLayer:Pop(RecordExchangeLayer)
		layer:SetInfoList(self.ExchangeBtn_List)
	end, true)

	--余额
	self.ui_money = self:getChild("money")

	--提现金额输入
	local input = self:getChild("amount_select/input")
	input = Tools.ReplaceEdit(input)
	input:setFontSize(26)
	input:setPlaceholderFontSize(30)
	input:setReturnType(cc.KEYBOARD_RETURNTYPE_DONE)
	input:setInputMode(cc.EDITBOX_INPUT_MODE_SINGLELINE)
	input:setTextHorizontalAlignment(cc.TEXT_ALIGNMENT_CENTER)
	self.ui_input = input
	self.ui_input:onEvent(function(eventname, sender)
		if eventname ~= "return" then
			return
		end
		--检查输入值的合法性
		local input_txt = self.ui_input:getString()
		local num = tonumber(input_txt)
		if not num or num < 0 then
			num = 0
		end
		if (self.money/sGameManager.exchangerate) > (UserData.refund_min_remain_money/sGameManager.exchangerate) then
			if num * self:GetExchange() > (self.money/sGameManager.exchangerate) - (UserData.refund_min_remain_money/sGameManager.exchangerate) then
				num = (self.money - UserData.refund_min_remain_money) / self:GetExchange() 
			else
				--换算过后的值
				num = num * sGameManager.exchangerate
			end
		else
			num = 0
		end
		--
		self.show_select = math.floor(num/self.margin) * self.margin
		self.select = self.show_select
		self:SetMinSelect()
		self:UpdateSlider()
		self:ShowPercent()
		self:UpdateUI()
	end)
	--清除按钮
	local ui_clear_btn = self:getChild("amount_select/clear_btn")
	Tools.AddClickEvent(ui_clear_btn, function()
		--改变当前选择额度
		self.select = 0
		self:UpdateSlider()
		self:UpdateUI()
		self:ShowPercent()
	end, true)
	--进度条背景
	local jb_bg1 = self:getChild("amount_select/TextField_3")
	--进度条
	self.ui_slider = self:getChild("amount_select/slider")
	self.ui_slider:setPercent(0)
	self.ui_slider:onEvent(function()
		local percent = self.ui_slider:getPercent()
		if self.money > 0 and self.show_select == 0 and self.money > UserData.refund_min_remain_money then
			local amount = (self.money - UserData.refund_min_remain_money) * percent / 100.0
			amount = math.floor(amount/self:GetExchange())
			local select = math.floor(amount/self.margin)*self.margin
			self.select = select
			self:SetMinSelect()
			self:UpdateUI()
			self:ShowPercent()
		end
	end)
	--滑动时 百分比标签
	self:setSlider(self.ui_slider)

	--提现按钮
	local ui_exchange_btn = self:findChild("_lang_exchange_btn")
	Tools.AddClickEvent(ui_exchange_btn, function() self:OnExchangeClick() end, true) 
	
	local btn_max = self:findChild("_lang_btn_max")
	Tools.AddClickEvent(btn_max, function()
		if self.money <= UserData.refund_min_remain_money then
			return
		end

		local amount = self.money - UserData.refund_min_remain_money
		amount = math.floor(amount/self:GetExchange())
		local select = math.floor(amount/self.margin)*self.margin
		self.select = select
		self.show_select = self.select
		-- self:UpdateUI()

		-- self.show_select = self.money - UserData.refund_min_remain_money
		-- self.show_select = math.floor(self.show_select / self:GetExchange())
		-- self.show_select = math.floor(self.show_select/self.margin) * self.margin
		-- self.select = self.show_select
		self:SetMinSelect()
		self:UpdateSlider()
		self:UpdateUI()
		self:ShowPercent()
	end,true) 
end

--设置余额和输入金额 来的时候select必须是显示的现金
function ExchangeLayer:UpdateUI()
	self.show_select = 0
	local select = self.select * self:GetExchange()
	local strTem = Tools.CoinToShowString(self.money - select)
	local strTem2 = self.select/sGameManager.exchangerate
	self.ui_money:setString(strTem)
	self.ui_input:setString(strTem2)
end

--设置面板状态
function ExchangeLayer:SetState()
	--设置左边按钮显示
	for key, value in pairs(self.list_btn) do
		if key == self.state then
			value:setEnabled(false)
			value:setTitleColor(cc.c3b(43, 20, 7))
		else
			value:setEnabled(true)
			value:setTitleColor(cc.c3b(216, 182, 103))
		end
	end
	local lua_exchange_detail = self:findChild("lua_exchange_detail")
	local lua_exchange_vc = self:findChild("lua_exchange_vc")
	local lua_exchange_pix = self:findChild("lua_exchange_pix")

	lua_exchange_detail:setVisible(false)
	lua_exchange_pix:setVisible(false)
	lua_exchange_vc:setVisible(false)

	if self.state >2000 then -- VC
		lua_exchange_vc:setVisible(true)
	else
		lua_exchange_detail:setVisible(true)
	end
	self:SetTips()
end

function ExchangeLayer:SetTips()
	--退款限额提示
	local ui_tips = self:getChild("tips")
	local str_ui_tips = ""
	if ConfigParam.Region == "tha" then
		str_ui_tips = TR("兑换NNN金币起，账户余额至少保留SSS金币，兑换费扣除1%")
	else
		str_ui_tips = TR("兑换NNN金币起，账户余额至少保留SSS金币")
	end
	local ex = self:GetExchange()
	if self.state > 2000 then -- vc充值
		local vc_str = string.format(TR(" 1USDT- %s≈%d"),self.ExchangeBtn_List[self.state].name ,ex)..TR("金币")
		str_ui_tips = str_ui_tips .. vc_str
	end
	local str_ = string.gsub(TR_(str_ui_tips),"NNN",UserData.refund_min_money/sGameManager.exchangerate)
	str_ = string.gsub(str_,"SSS",UserData.refund_min_remain_money/sGameManager.exchangerate)
	ui_tips:setString(str_)
	Tools.CcuiTextIgnoreContentAdaptByFontSize(ui_tips)
end

--设置卡号
function ExchangeLayer:SetCardNumber(bool_)
	local list = self:GetAccInfo(self.state)
	if #list == 0 then
		self.bank_card = ""
	else
		for idx_key, value in pairs(list) do
			if self.bank_card == "" then
				self.bank_card = value.card_number
			end
		end
	end
	self:SetBankCardNum(self.bank_card,bool_)
end

--设置拖动条
function ExchangeLayer:UpdateSlider()
	local percent = 0
	if self.money ~= 0 then
		local select = self.select 
		if self.state > 2000 then
			select = select * self:GetExchange()
		end
		percent = select / (self.money - UserData.refund_min_remain_money)  * 100.0
	end
	self.ui_slider:setPercent(percent)
end

--根据退款方式获取基本信息
function ExchangeLayer:GetAccInfo(idx)
	local list = {}
	for key, value in ipairs(UserData.pay_channel_accounts) do
		if value.pay_channel_id == idx then
			table.insert(list,value)
		end
	end
	return list
end

--初始化左侧按钮表
function ExchangeLayer:InitBtnList()
	self.btnList = self:getChild("btnlist")
	self.item = self.btnList:getChild("_lang_bank")
    self.item:retain()
	self.btnList:removeAllItems()
	self.list_btn = {}

	for key, value in ipairs(sGameManager.exchange_payChannels) do
		if not self.ExchangeBtn_List[value.id] then
			UIManager.ShowToast(string.format("Unknown Exchange Channel: %d", value.id))
		else
			local new_item = self.item:clone()
			new_item:setTitleText(self.ExchangeBtn_List[value.id].name)
			AdaptButton(new_item)
			--注意需要先设置 再调用addChild否者不会触发子节点 onEnter 事件
			Tools.AddClickEvent(new_item, function()
				if not self:CheckIsBindCard(value.id) then
					return
				end
				self.state = value.id
				self.select = 0
				self.bank_card = ""
				self:SetState()
				self:SetCardNumber()
				self:UpdateUI()
				self:UpdateSlider()
				self:ChangeBindQR()
			end,true)
			self.btnList:pushBackCustomItem(new_item)
			self.list_btn[value.id] = new_item
		end
	end
end

--检查该充值方式是否绑定
function ExchangeLayer:CheckIsBindCard(idx)
	idx = idx or self.state
	if idx ~= 4 then
		if sGameManager.is_open_realname_mode == 1 then
			--如果没有绑定银行卡或者手机号，弹出绑定界面
			local isBind = false --是否填过银行卡
			local bindInfo = nil
			local name_ = ""
			for i = 1, #UserData.pay_channel_accounts do
				local infos = UserData.pay_channel_accounts[i]
				if infos.pay_channel_id == idx then
					isBind = true
					bindInfo = infos
				end
				if name_ == "" then
					if infos.name ~= nil then
						name_ = infos.name
					end
				end
			end
			if (not isBind) then
				local layer = PopLayer:Pop(BindCardOrPhoneLayer)
				local tab = {}
				tab.state = idx
				tab.name = name_
				layer:SetDefInfo(tab)
				return false
			end
		end
	end
	return true
end

function ExchangeLayer:InitPanel()
	local close_btn = self:findChild("lua_close_btn")
	Tools.AddClickEvent(close_btn, function()
		self:Close()
	end, true)
end

function ExchangeLayer:InitCommonDetail()
	local root = self:findChild("lua_exchange_detail")
	--银行卡号
	self.ui_bank_card_num = root:getChild("bank_card_num")
	--添加银行卡按钮
	self.ui_add_bank_card_btn = root:getChild("_lang_add_bank_card_btn")
	Tools.AddClickEvent(self.ui_add_bank_card_btn, 
		function() 
			self:OnBankCardClick()
		end, true)
	--上传图片按钮
	local uploadqr_btn = root:getChild("uploadqr_btn")
	uploadqr_btn:addTouchEventListener(function(ref,type)
		if(type == ccui.TouchEventType.ended) then
			if Tools_Base.PreventContinuousClick(uploadqr_btn,0.5) then
				if sGameManager.exchange_QRpath ~= "" then
					UIManager.ShowToast(TR_("请联系客服修改"))
					return
				end
				ref:runAction(cc.Sequence:create(cc.CallFunc:create(function() gSound.clickSound(); end),
				cc.DelayTime:create(0.2),
				cc.CallFunc:create(function() Device.OpenAlbum() end)))
			end
		end
	end)
end

function ExchangeLayer:InitVCDetail()
	local root = self:findChild("lua_exchange_vc")
	--钱包地址
	self.ui_vc_addr = root:getChild("addr")
	--添加钱包地址
	self.ui_bind_vc = root:getChild("_lang_bind")
	Tools.AddClickEvent(self.ui_bind_vc, 
		function() 
			local layer = PopLayer:Pop(BindVirtualCoinLayer)
			layer:setInfo(self.state)
		end, true)
	
end

function ExchangeLayer:InitPixDetail()
	local root = self:findChild("lua_exchange_pix")
	-- pix 账号
	self.ui_pixnumber = root:getChild("pixnumber")
	-- 绑定 & 修改
	self.ui_bind_pix = root:getChild("_lang_bind")
	Tools.AddClickEvent(self.ui_bind_pix, 
		function()
			local layer = PopLayer:Pop(PixBindLayer)
			layer:SetChannel(self.state)
		end, true)
	
end

--切换二维码退款显示所需修改
function ExchangeLayer:ChangeBindQR()
	if self.state > 2000 then
		return
	end
	if self.state == 4 then
		local dzzh = self:getChild("lua_exchange_detail/_lang_yh")
		dzzh:setVisible(false)
		local dzyh = self:getChild("lua_exchange_detail/_lang_dzyh")
		dzyh:setVisible(true)
		self.list_show_btn:setVisible(true)
		local uploadqr_btn = self:getChild("lua_exchange_detail/uploadqr_btn")
		if sGameManager.exchange_QRpath ~= "" then
			uploadqr_btn:setVisible(false)
		else
			uploadqr_btn:setVisible(true)
			self.picdata = ""
			self.qr_bankname = ""
			local icon = self.list_show_btn:getChildByName("dzyh_icon")
			icon:setVisible(false)
		end
	else
		local dzzh = self:getChild("lua_exchange_detail/_lang_yh")
		dzzh:setVisible(true)
		local dzyh = self:getChild("lua_exchange_detail/_lang_dzyh")
		dzyh:setVisible(false)
		local uploadqr_btn = self:getChild("lua_exchange_detail/uploadqr_btn")
		uploadqr_btn:setVisible(false)
		self.list_show_btn:setVisible(false)
		self.listisshow = true
		self.banknamelist_bg:setVisible(false)
		self:getChild("amount_select/input"):setEnabled(true)
	end
end

--绑定 & 添加 银行卡
function ExchangeLayer:OnBankCardClick()
	local list = self:GetAccInfo(self.state)
	if #list >= UserData.bankcardcount then
		local str_bankcardcount = TR("最多只能绑定NNN个账号")
		local str_ = string.gsub(TR_(str_bankcardcount),"NNN",UserData.bankcardcount)
		UIManager.ShowToast(str_)
		return
	end
	print("sGameManager.is_open_realname_mode	", sGameManager.is_open_realname_mode)
	if sGameManager.is_open_realname_mode == 1 then
		if #list >= 1 then
			UIManager.ShowToast(TR_("请联系客服修改"))
			return
		end
		if not self:CheckIsBindCard() then
			return
		end
	end

	local layer = PopLayer:Pop(ExchangePopUpLayer)
	if self.state == 801 or self.state == 7 or self.state == 8 then
		local defname = ""
		for key,value in ipairs(UserData.pay_channel_accounts) do
			if value.name ~= "" then
				defname = value.name
				break
			end
		end
		if self.state == 801 then
			layer:NextPopNoShow(true)
			layer:SetDefInfo(defname,"")
		else
			local _,max_ = exutils.GetPhoneLenth()
			layer:NextPopNoShow(true,max_)
			layer:SetPayId(self.state)
		end
	end
	layer:SetAccNumberID(0)
	if #list ~= 0 then
		layer:SetDefInfo(list[1].name,"")
	end
end

--点击 提现 按钮
function ExchangeLayer:OnExchangeClick()
	if UserData.is_open_email_bind == 1 and UserData.email == "" then
		PopLayer:Pop(user.EmailBindingLayer)
		return
	end
	local num = self.select * self:GetExchange()
	if num <= 0 then
		local str_ = TR("金额不能为空，请输入正确的金额")
		UIManager.ShowToast(TR_(str_))
		return
	end
	if num < UserData.refund_min_money then
		local str_ = TR("兑换最小额度NNN金币，至少保留SSS金币")
		local str = string.gsub(TR_(str_),
			-- "NNN", UserData.refund_min_money/sGameManager.exchangerate
			"NNN", Tools.CoinToShowString(UserData.refund_min_money)
		)
		local info = string.gsub(str, "SSS",
			-- UserData.refund_min_remain_money/sGameManager.exchangerate
			Tools.CoinToShowString(UserData.refund_min_remain_money)
		)
		UIManager.ShowMsgBox(info)
		return
	end
	if self.state ~= 4 then
		if self.state > 2000 then
			self:HandleExchange(num)
			return
		end

		if (#self:GetAccInfo(self.state) == 0) then
			local str_ = ""
			if ConfigParam.Region == "vn" then
				str_ = TR("请绑定银行账户")
			else
				str_ = TR("未绑定账号")
			end
			UIManager.ShowToast(TR_(str_))
			return
		end
		
		local layer = PopLayer:Pop(BankCardChoicePopUpLayer)
		layer:SetExchangeMoney(num)
		layer:SetInfoList(self:GetAccInfo(self.state),self.ExchangeBtn_List[self.state])
	else
		--判断是否选择对应银行，未选择需提示
		if self.qr_bankname == "" then
			local str_ = TR("请选择银行")
			UIManager.ShowToast(TR_(str_))
			return
		end
		--判断是否上传二维码
		if self.picdata == "" then
			local str_ = TR("请上传二维码")
			UIManager.ShowToast(TR_(str_))
			return
		end
		--先告诉服务器已上传二维码
		if sGameManager.exchange_QRpath ~= "" and sGameManager.exchange_QRBank ~= "" then
			self:HandleExchange(num)
		else
			self:SendBindQRCode()
		end
	end
end

--设置卡号
function ExchangeLayer:SetBankCardNum(num,bool_)
	self.bank_card = num
	if self.state == 4 then
		if not bool_ then
			self.qr_bankname = sGameManager.exchange_QRBank
			self.ui_bank_card_num:setString(self.qr_bankname)
		end
		self.ui_add_bank_card_btn:setVisible(false)
	elseif self.state > 2000 then
		if num == 0 or num == "" then
			local str_ = TR("未绑定钱包地址")
			self.ui_vc_addr:setString(TR_(str_))
		else
			self.ui_vc_addr:setString(self.bank_card)
		end

		local list = self:GetAccInfo(self.state)
		if #list > 0 then
			self.ui_bind_vc:setVisible(false)
		else
			self.ui_bind_vc:setVisible(true)
		end
	else
		if num == 0 or num == "" then
			local str_ = TR("未绑定账号")
			self.ui_bank_card_num:setString(TR_(str_))
			self.ui_pixnumber:setString(TR_(str_))
			self.ui_bind_pix:setTitleText(TR("绑定"))
		else
			self.ui_bank_card_num:setString(self.bank_card)
			self.ui_pixnumber:setString(self.bank_card)
			self.ui_bind_pix:setTitleText(TR("修改"))
		end
	
		local list = self:GetAccInfo(self.state)
		if #list < UserData.bankcardcount then
			self.ui_add_bank_card_btn:setVisible(true)
		else
			self.ui_add_bank_card_btn:setVisible(false)
		end
	end
end

--进度条动画
function ExchangeLayer:setSlider(slider)
	--进度条进度
	self.percent = self:getChild("amount_select/percent")

	--开始时设置透明
	self.percent:setOpacity(0)
	--初始化进度条数字
	self:InitPercent(self.percent)
	self.fadeIn = cc.FadeIn:create(0.05)
    self.fadeOut = cc.FadeOut:create(0.5)
    local tag = 100
    self.fadeIn:setTag(tag)
    self.fadeOut:setTag(tag)
    self.fadeIn:retain()
    self.fadeOut:retain()
	slider:addTouchEventListener(function(ref,type)	
		if type == ccui.TouchEventType.began then
			self.percent:stopActionByTag(tag)
			self.percent:runAction(self.fadeIn)
		else
			self.percent:stopActionByTag(tag)
			self.percent:runAction(self.fadeOut)
		end
	end)
	
	--循环更新进度条数据
	self.percent:runAction(
        cc.RepeatForever:create(
            cc.Sequence:create(
				cc.DelayTime:create(0.01),
				cc.CallFunc:create(function()
					self:UpdatePosition(self.ui_slider,self.percent)
					self:setPercent(self.ui_slider)
				end)
			)
		)
	)
end

--显示百分比动画
function ExchangeLayer:ShowPercent()
	if Tools_Base.PreventContinuousClick(self.percent,0.5) then
		self.percent:runAction(
			cc.Sequence:create(
				cc.CallFunc:create(function()
					self.percent:stopActionByTag(100)
					self.percent:runAction(self.fadeIn)
				end),
				cc.DelayTime:create(0.3),
				cc.CallFunc:create(function()
					self.percent:stopActionByTag(100)
					self.percent:runAction(self.fadeOut)
				end)
			)
		)
	end
end

--初始化进度条数字
function ExchangeLayer:InitPercent(_percent)
	self.ui_num = _percent:getChild("num")
    self.ui_num:setString("0%")
end

--设置百分比数值
function ExchangeLayer:setPercent(slider)
	local percent = slider:getPercent()
    if percent < 0 then percent = 0 end
    if percent > 100 then percent = 100 end
    if self.ui_num then
        self.ui_num:setString(tostring(percent) .. "%")
    end
end

--slider 百分比调整位置
function ExchangeLayer:UpdatePosition(slider,_percent)
	local size = slider:getContentSize()
	local percent = slider:getPercent()
	local posx = size.width / 100.0 * percent
	local pos = cc.p(posx, 0)
	pos = slider:convertToWorldSpace(pos)
	pos = slider:getParent():convertToNodeSpace(pos)
	_percent:setPositionX(pos.x)
end

--初始化二维码，对应银行表(暂时只有缅甸使用)
function ExchangeLayer:InitBankNameList()
	self.banknamelist_bg = self:findChild("yhlist_bg")
	self.banknamelist_bg:setLocalZOrder(1)
	self.list_show_btn = self:getChild("lua_exchange_detail/list_show_btn")
	Tools.AddClickEvent(self.list_show_btn,
            function()
                if self.listisshow then
                    self:ShowBankNameList()
                else
                    self:HideBankNameList()
                end
            end)
    self.banknamelist_bg:setVisible(false)
    if not Recharge.Exchange_Banklist then
        self.list_show_btn:setVisible(false)
        return
	end
	if sGameManager.exchange_QRpath ~= "" then
		self.picdata = sGameManager.exchange_QRpath
		self.list_show_btn:setEnabled(false)
		self.list_show_btn:getChildByName("btn_up"):setVisible(false)
		self.list_show_btn:getChildByName("btn_down"):setVisible(false)
		local icon = self.list_show_btn:getChildByName("dzyh_icon")
		for key, value in pairs(Recharge.Exchange_Banklist) do
			if value == sGameManager.exchange_QRBank then
				self.qr_bankname = sGameManager.exchange_QRBank
				icon:loadTexture(string.format(Recharge.Path_ExchangeBank,key))
				break
			end
		end
		icon:setVisible(true)
		return
	end
    --更换朝向
    local btn_up = self.list_show_btn:getChildByName("btn_up")
    btn_up:setVisible(true)
    local btn_down = self.list_show_btn:getChildByName("btn_down")
    btn_down:setVisible(false)
	local icon = self.list_show_btn:getChildByName("dzyh_icon")
	icon:setVisible(false)
	self.banknamelist = self.banknamelist_bg:getChildByName("yh_list")
    local item = self.banknamelist:getChildByName("item")
    item:retain()
    self.banknamelist:removeAllItems()
    for key, value in pairs(Recharge.Exchange_Banklist) do
		local new_item = item:clone()
		self.banknamelist:pushBackCustomItem(new_item)
		Tools.AddClickEvent(new_item,
			function()
				self:HideBankNameList(key,value)
			end)
        local bank_name = new_item:getChildByName("text")
        bank_name:setString(value)
        local icon = new_item:getChildByName("icon")
		icon:loadTexture(string.format(Recharge.Path_ExchangeBank,key))
	end
	item:release()
end

--显示二维码，对应银行表
function ExchangeLayer:ShowBankNameList()
    self.banknamelist_bg:setVisible(true)
    self.listisshow = false
    --更换朝向
    local btn_up = self.list_show_btn:getChildByName("btn_up")
    btn_up:setVisible(false)
    local btn_down = self.list_show_btn:getChildByName("btn_down")
    btn_down:setVisible(true)
    self:getChild("lua_exchange_detail/amount_select/input"):setEnabled(false)
end

--隐藏二维码，对应银行表
function ExchangeLayer:HideBankNameList(icon_idx,bankname)
    self.listisshow = true
	if bankname then
		self.qr_bankname = bankname
		self.ui_bank_card_num:setString(bankname)
		local icon = self.list_show_btn:getChildByName("dzyh_icon")
		icon:loadTexture(string.format(Recharge.Path_ExchangeBank,icon_idx))
		icon:setVisible(true)
    end
    self.banknamelist_bg:setVisible(false)
    --更换朝向
    local btn_up = self.list_show_btn:getChildByName("btn_up")
    btn_up:setVisible(true)
    local btn_down = self.list_show_btn:getChildByName("btn_down")
    btn_down:setVisible(false)
	self:getChild("lua_exchange_detail/amount_select/input"):setEnabled(true)
end

-- 如果 sGameManager.Image == "null" 说明用户取消选择照片 提示 用户取消选择
-- 如果 sGameManager.ImageSize and sGameManager.ImageSize ~= "false" and sGameManager.Image ~= nil 说明 图片ok
-- 每次得到Image之后记得重置Image = nil 和 ImageSize = nil
--上传循环
function ExchangeLayer:UploadQR_Update()
	if gStates_Exists("Panel_ServiceMail") then
		return
	end
	if sGameManager.Image == "null" then
		UIManager.ShowToast(TR("用户取消选择系统照片"))
		sGameManager.Image = nil
		sGameManager.ImageSize = nil
	elseif sGameManager.ImageSize and sGameManager.ImageSize ~= "false" and sGameManager.Image ~= nil then
		local Image = sGameManager.Image
		local ImageSize = sGameManager.ImageSize
		sGameManager.Image = nil
		sGameManager.ImageSize = nil
		go(function()
				local timer = 0 -- Activity 切换后等待3帧渲染GL再去处理上传逻辑，防止黑屏
				while true do
					timer = timer+1
					if timer < 3 then
						yield()
					else
						break
					end
				end
				print("ExchangeLayer : start upload picture")
				local newfileBase64 = Tools.getSmilePicture(Image)
				if not newfileBase64 then
					print("ExchangeLayer : change picture error")
					go(
						function()
						local ErrorUpload = require("hall.src.hallnew.common.DEBUG.ErrorUpload"):create()
						--ErrorUpload:uploadLog("change picture error".."||"..(tostring(sGameManager.userInfo.id or 1)))
						ErrorUpload:uploadLog("ExchangeLayer : change picture error")
						end
					)
					UIManager.ShowToast("change picture error")
					return
				end
				self.imgdata = {
					["base64"] = newfileBase64,
					["size"]	= #newfileBase64
				}
				sGameManager.Image = nil
				sGameManager.ImageSize = nil
				UIManager.ShowToast(TR("图片已选择"))
				local xhr = cc.XMLHttpRequest:new()
				xhr.responseType = cc.XMLHTTPREQUEST_RESPONSE_JSON
				local url_ = string.gsub(sGameManager.uploadimageUrl,"/upload/","/upload2/")
				xhr:open("POST",url_)
				UIManager.ShowWaiting()
				local function onReadyStateChanged()
						if xhr.readyState == 4 and (xhr.status >= 200 and xhr.status < 207) then -- 成功
							if xhr.response == "1" or xhr.response == "2" then
								UIManager.ShowToast(TR("网络异常，图片上传失败"))
								UIManager.HideWaiting()
							else
								if tonumber(ImageSize) > 3 * 1024 * 1024 then
									-- 大于三兆的图片，上传下日志
									go(
										function()
											local ErrorUpload = require("hall.src.hallnew.common.DEBUG.ErrorUpload"):create()
											ErrorUpload:uploadLog("大于三兆的图片")
										end
									)
								end
								self.picdata = xhr.response
								UIManager.HideWaiting()
							end
						else
							UIManager.ShowToast(TR("网络异常，正在努力上传图片~"))
							UIManager.HideWaiting()
						end
					xhr:unregisterScriptHandler()
				end
				xhr:registerScriptHandler(onReadyStateChanged)
				xhr:send(json.encode(self.imgdata))
			end)
	end
end

--告诉服务器已经上传二维码
function ExchangeLayer:SendBindQRCode()
	go(function()
		local data_ = PKG_Client_Lobby_UpQRCodeImage.Create()
		data_.qr_image = self.picdata
		data_.bank_name = self.qr_bankname
		UIManager.ShowWaiting()
		local rlt_ = gNet_SendRequest(data_)
		UIManager.HideWaiting()
		if rlt_ ~= nil then
			if getmetatable(rlt_) == PKG_Generic_Success then
				sGameManager.exchange_QRpath = self.picdata
				sGameManager.exchange_QRBank = self.qr_bankname
				local str_ = TR("二维码绑定成功")
				UIManager.ShowMsgBox(TR_(str_),function ()
					--隐藏列表
					self.list_show_btn:setEnabled(false)
					self.listisshow = true
					self.banknamelist_bg:setVisible(false)
					self:getChild("lua_exchange_detail/amount_select/input"):setEnabled(true)
					local btn_up = self.list_show_btn:getChildByName("btn_up")
					btn_up:setVisible(false)
					local btn_down = self.list_show_btn:getChildByName("btn_down")
					btn_down:setVisible(false)
					local uploadqr_btn = self:getChild("lua_exchange_detail/uploadqr_btn")
					uploadqr_btn:setVisible(false)
					--发送退款包
					self:HandleExchange(self.select)
				end)
			elseif getmetatable(rlt_) == PKG_Generic_Error then
				local num = Int64ToNumber(rlt_.number)
				UIManager.ShowMsgBox(TR_("绑定失败"))
			end
		else
			UIManager.ShowMsgBox(TR_("网络连接失败，请重试"))
			return
		end
	end)
end

function ExchangeLayer:GetExchange()
	if self.state < 2000 then
		return 1
	end
	for _, value in ipairs(sGameManager.exchange_payChannels) do
		if value.id == self.state then
            return value.exchange
		end
	end
	return 1
end

--申请退款
function ExchangeLayer:HandleExchange(exchange_money)
    if UserData:IsExperienceUser() then
        UIManager.ShowMsgBox(TR("试玩账号不能兑换"))
        return
    end

	go(function()
		local data_ = PKG_Client_Lobby_Refund.Create()
		if self.state > 2000 then
			local info = self:GetAccInfo(self.state)[1]
			data_.id = info.id
			data_.requirement = info.card_number
			data_.pay_channel_id = info.pay_channel_id
		else
			data_.id = 0
			data_.requirement = ""
			data_.pay_channel_id = self.state	
		end
		data_.money = exchange_money
		UIManager.ShowWaiting()
		local rlt_ = gNet_SendRequest(data_)
		UIManager.HideWaiting()
		dump(rlt_,"申请退款ExchangeLayer")
		if rlt_ ~= nil then
			if getmetatable(rlt_) == PKG_Lobby_Client_RefundResultMoneyChanged then
				local value = rlt_.refund_money / sGameManager.exchangerate
				local str = string.gsub(TR_("您已成功申请兑换NNN金币！请耐心等待3-5分钟即可在您的SSS查看哟！"),"NNN", value)
				UserData.money_safe = rlt_.money_safe
				UserData.money = rlt_.money
				Dispatcher:Dispatch(UserData)
				local info = string.gsub(str, "SSS",self.qr_bankname)
				UIManager.ShowMsgBox(info)
				self:Close()
			elseif(getmetatable(rlt_) == PKG_Generic_Error)then
				local num = Int64ToNumber(rlt_.number)
				if -120 == num then
					UIManager.ShowMsgBox(TR("上一笔订单正在处理中"))
				elseif (num == Def.Net_Login_PhoneWorng) then
					UIManager.ShowMsgBox(TR_("兑换失败，请联系客服"))
				elseif (num == Def.Net_Insufficient_Redemption)then
					UIManager.ShowMsgBox(TR_("兑换次数不足，请联系客服"))
				else
					UIManager.ShowMsgBox(TR_("兑换失败，请联系客服"))
				end
			end
		else
			UIManager.ShowMsgBox(TR_("网络连接失败，请重试"))
			return
		end
	end)
end

function ExchangeLayer:SetMinSelect()
	local num = self.select * self:GetExchange()
	if num < UserData.refund_min_money then
		local moneyNum = UserData.refund_min_money / self:GetExchange() -- 最低钱
		local marginNum = math.floor(moneyNum/self.margin)
		if marginNum == 0 then
			marginNum = 1
		end
		self.select = marginNum * self.margin
		if self.select * self:GetExchange() > self.money then
			self.select = 0
		end
	end
end
return ExchangeLayer
