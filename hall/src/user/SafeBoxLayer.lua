local SafeBoxLayer = class("SafeBoxLayer", function()
	return Tools.CreateLayer("csb/lobby/SafeBoxLayer.csb")
end)

function SafeBoxLayer:ctor()
	self.money = 0				-- 当前 余额
	self.safe_money = 0			-- 当前 保险箱金额
	self.money_gift = 0       	-- 洗码金额
	self.money_gift_safe = 0  	-- 洗码保险箱金额
	self.mode = 0				-- 0 存钱模式, 1 取钱模式
	self.type = 0				-- 0 金币类型, 1 绑定金币类型
	self.select_money = 0		-- 当前选中数量
end

function SafeBoxLayer:onEnter()
	self:InitUI()
	self.type = 0
	self.mode = 0
	self.money = UserData.money
	self.safe_money = UserData.money_safe
	self.money_gift = math.floor(UserData.money_gift)
	self.money_gift_safe = UserData.money_gift_safe
	self.select_money = 0		-- 当前选中数量
	
	Dispatcher:Register(UserData, function()
		self.money = UserData.money
		self.safe_money = UserData.money_safe
		self.money_gift = math.floor(UserData.money_gift)
		self.money_gift_safe = UserData.money_gift_safe
		self.select_money = 0		-- 当前选中数量
		self:UpdateUI()
	end, self)
	self:UpdateUI()
end

function SafeBoxLayer:InitUI()
	--关闭按钮
	local close_btn = self:findChild("lua_close_btn")
	Tools.AddClickEvent(close_btn, function()
		self:Close()
	end, true)

	self:InitTab()		--Tab区域
	self:InitCoin()		--金额显示区域
	self:InitAmount()	--数量显示区域
	self:InitBottomBtn()--底部存取款按钮

	--默认选择存款模式
	self:OnClickLeftButton(0,0)
end

function SafeBoxLayer:InitTab()
	self.deposit_tab_btn = self:findChild("btn_coin_deposit")
	self.deposit_tab_btn.text = self.deposit_tab_btn:getChildByName("_lang_text")

	self.withdraw_tab_btn = self:findChild("btn_coin_withdraw")
	self.withdraw_tab_btn.text = self.withdraw_tab_btn:getChildByName("_lang_text")

	self.deposit_bind_tab_btn = self:findChild("btn_bind_deposit")
	self.deposit_bind_tab_btn.text = self.deposit_bind_tab_btn:getChildByName("_lang_text")

	self.withdraw_bind_tab_btn = self:findChild("btn_bind_withdraw")
	self.withdraw_bind_tab_btn.text = self.withdraw_bind_tab_btn:getChildByName("_lang_text")

	Tools.AddClickEvent(self.deposit_tab_btn, function()
		self:OnClickLeftButton(0,0)
	end, true)
	Tools.AddClickEvent(self.withdraw_tab_btn, function()
		self:OnClickLeftButton(1,0)
	end, true)
	Tools.AddClickEvent(self.deposit_bind_tab_btn, function()
		self:OnClickLeftButton(0,1)
	end, true)
	Tools.AddClickEvent(self.withdraw_bind_tab_btn, function()
		self:OnClickLeftButton(1,1)
	end, true)

	if sGameManager.IsBindCodeOpen() then
		self.deposit_bind_tab_btn:setVisible(true)
		self.withdraw_bind_tab_btn:setVisible(true)
	else
		self.deposit_bind_tab_btn:setVisible(false)
		self.withdraw_bind_tab_btn:setVisible(false)
	end
end

--点击左边某个按钮
function SafeBoxLayer:OnClickLeftButton(mode,type)
	local isDesposit = mode == 0 -- 是否是存
	local isBind = type == 1 -- 是否是绑定金币
	local enabledColor = cc.c3b(216, 182, 103)
	local disenabledColor = cc.c3b(43, 20, 7)

	local showDespositTab = not (isDesposit and not isBind)
	self.deposit_tab_btn:setEnabled(showDespositTab)
	self.deposit_tab_btn:setBright(showDespositTab)
	self.deposit_tab_btn.text:setColor(showDespositTab and enabledColor or disenabledColor)

	local showWithdrawTab = not (not isDesposit and not isBind)
	self.withdraw_tab_btn:setEnabled(showWithdrawTab)
	self.withdraw_tab_btn:setBright(showWithdrawTab)
	self.withdraw_tab_btn.text:setColor(showWithdrawTab and enabledColor or disenabledColor)

	local showDepositBindTab = not (isDesposit and isBind)
	self.deposit_bind_tab_btn:setEnabled(showDepositBindTab)
	self.deposit_bind_tab_btn:setBright(showDepositBindTab)
	self.deposit_bind_tab_btn.text:setColor(showDepositBindTab and enabledColor or disenabledColor)

	local showWithdrawBindTab = not (not isDesposit and isBind)
	self.withdraw_bind_tab_btn:setEnabled(showWithdrawBindTab)
	self.withdraw_bind_tab_btn:setBright(showWithdrawBindTab)
	self.withdraw_bind_tab_btn.text:setColor(showWithdrawBindTab and enabledColor or disenabledColor)

	local _lang_dqje = self:findChild("_lang_dqje")
	_lang_dqje:setString(isBind and TR("当前绑定金额") or TR("当前金额"))

	local _lang_bxxje = self:findChild("_lang_bxxje")
	_lang_bxxje:setString(isBind and TR("绑定保险箱金额") or TR("保险箱金额"))
	self:ShowBottomDeposit(isDesposit)

	self.mode = mode
	self.type = type
	self.select_money = 0
	self:UpdateUI()
end

function SafeBoxLayer:ShowBottomDeposit(show)
	self.deposit_btn:setVisible(show)
	self.withdraw_btn:setVisible(not show)
end

--------------------------------------------------------
--	金额显示区域
function SafeBoxLayer:InitCoin()
	self.coin_num = self:findChild("lua_coin_num")
	self.safe_num = self:findChild("lua_safe_num")
end

function SafeBoxLayer:DumpData()
	print("select_money:" .. self.select_money)
	if self.mode == 0 then
		print("mode: 存钱")
	else
		print("mode: 取钱")
	end
	print("money:" .. self.money)
	print("safe_money:" .. self.safe_money)
end

--根据数据更新界面显示
function SafeBoxLayer:UpdateUI(bSlider)
	if bSlider == nil then
		bSlider = true
	end
	local select = self.select_money		--保存针对余额的修改
	local percent = 0
	local strTem_1 
	local strTem_2 
	if self.type == 0 then
		if self.mode == 0 then	--存钱模式
			if self.money > 0 then
				percent = math.floor(100.0 * select / self.money)
			end
			select = -select
		else					--取钱
			if self.safe_money > 0 then
				percent = math.floor(100.0 * select / self.safe_money)
			end
		end
		strTem_1 = Tools.CoinToShowString(self.money + select)
		strTem_2 = Tools.CoinToShowString(self.safe_money - select)
	else
		if self.mode == 0 then	--存钱模式
			if self.money_gift > 0 then
				percent = math.floor(100.0 * select / self.money_gift)
			end
			select = -select
		else					--取钱
			if self.money_gift_safe > 0 then
				percent = math.floor(100.0 * select / self.money_gift_safe)
			end
		end
		strTem_1 = Tools.CoinToShowString(self.money_gift + select)
		strTem_2 = Tools.CoinToShowString(self.money_gift_safe - select)
	end
	self.coin_num:setString(strTem_1)
	self.safe_num:setString(strTem_2)
	if bSlider then
		self.slider:setPercent(percent)
	end
	self.input:setString(Tools.CoinToShowString(math.abs(select)))
end

--------------------------------------------------------
-- 数量
function SafeBoxLayer:InitAmount()
	--数量选择区域
	local input = self:findChild("lua_input")
	input = Tools.ReplaceEdit(input)
	input:setInputMode(cc.EDITBOX_INPUT_MODE_SINGLELINE)
	input:setFontSize(30)
	input:setMaxLength(200)
	input:setPlaceholderFontSize(30)
	input:setReturnType(cc.KEYBOARD_RETURNTYPE_DONE)
	input:setTextHorizontalAlignment(cc.TEXT_ALIGNMENT_CENTER)
	self.input = input
	self.input:onEvent(function(eventname, sender)
		if eventname ~= "return" then
			return
		end
		--检查输入值的合法性
		local input_txt = Tools.string_Exchangerate(self.input:getString())
		local num = tonumber(input_txt) 
		if not num or num < 0 then
			num = 0
		end
		if math.floor(num) < num then
			num = math.floor(num)
		end
		if self.type == 0 then
			if self.mode == 0 then
				if num >= self.money then
					num = self.money
				end
			else
				if num >= self.safe_money then
					num = self.safe_money
				end
			end
		else
			if self.mode == 0 then
				if num >= self.money_gift then
					num = self.money_gift
				end
			else
				if num >= self.money_gift_safe then
					num = self.money_gift_safe
				end
			end
		end

		--修正输入值
		self.input:setString(num * sGameManager.exchangerate)
		self.select_money = num
		self:UpdateUI()
	end)
	self.clear_btn = self:findChild("lua_clear_btn")
	Tools.AddClickEvent(self.clear_btn, function()
		self.select_money = 0
		self:UpdateUI()
	end, true)
	self.slider = self:findChild("lua_slider")
	self.slider:onEvent(function()
		self:OnSliderChanged()
	end)
	--滑动时 百分比标签
	self:setSlider(self.slider)

	self.max_btn = self:findChild("_lang_lua_max_btn")
	Tools.AddClickEvent(self.max_btn, function()
		self:OnMaxBtnClick()
	end, true)
end

function SafeBoxLayer:GetMoneyForPercent(money, percent)
	if percent == 100 then
		return money
	else
		return math.floor(money*percent/100.0)
	end
end

function SafeBoxLayer:OnSliderChanged()
	local percent = self.slider:getPercent()
	local select = 0
	if self.type == 0 then
		if self.mode == 0 then			--存钱
			select = self:GetMoneyForPercent(self.money, percent)
		else
			select = self:GetMoneyForPercent(self.safe_money, percent)
		end
	else
		if self.mode == 0 then			--存钱
			select = self:GetMoneyForPercent(self.money_gift, percent)
		else
			select = self:GetMoneyForPercent(self.money_gift_safe, percent)
		end
	end

	self.select_money = select

	-- self:DumpData()
	self:UpdateUI(false)
	-- self:DumpData()
end

function SafeBoxLayer:OnMaxBtnClick()
	if self.type == 0 then
		if self.mode == 0 then			--存钱
			self.select_money = self.money
		else
			self.select_money = self.safe_money
		end
	else
		if self.mode == 0 then			--存钱
			self.select_money = self.money_gift
		else
			self.select_money = self.money_gift_safe
		end
	end
	self:UpdateUI()
end

------------------------------------------------------
-- 底部存取款按钮
function SafeBoxLayer:InitBottomBtn()
	self.deposit_btn = self:findChild("_lang_lua_deposit_btn")
	Tools.AddClickEvent(self.deposit_btn, function()
		self:OnDeposit()
	end, true)
	self.withdraw_btn = self:findChild("_lang_lua_withdraw_btn")
	Tools.AddClickEvent(self.withdraw_btn, function()
		self:OnWithdraw()
	end, true)
end

--存款
function SafeBoxLayer:OnDeposit()
	local num = tonumber(Tools.string_Exchangerate(self.input:getString())) or 0
	self:HandleSafeBox(num)
end

--取款
function SafeBoxLayer:OnWithdraw()
	local num = tonumber(Tools.string_Exchangerate(self.input:getString())) or 0
	self:HandleSafeBox(-num)
end

-- >0存, <0取
function SafeBoxLayer:HandleSafeBox(num)
	if num == 0 then
		UIManager.ShowMsgBox(TR("请输入金额！！！"))
		return
	end

	if num <= 0 then
		num = math.floor(num)
	else
		num = math.ceil(num)
	end

	go(function()
			local data_ 
			if self.type == 0 then
				data_ = PKG_Client_Lobby_ChangeMoneySafe.Create()
			else
				data_ = PKG_Client_Lobby_ChangeMoneyGiftSafe.Create()
			end
			data_.accountId = UserData.id
			data_.money = num
			UIManager.ShowWaiting()
			local rlt_ = gNet_SendRequest(data_)
			UIManager.HideWaiting()

			if rlt_ == nil then
				UIManager.ShowMsgBox(TR("网络连接失败，请重试"))
				return
			end

			if rlt_.typeId == PKG_Lobby_Client_ChangeMoneySafe_Success.typeId then
				local lastMoney = UserData.money
				UserData.money_safe = rlt_.money_safe
				UserData.money = rlt_.money
				UserData.money_gift = rlt_.money_gift
				UserData.money_gift_safe = rlt_.money_gift_safe
				Dispatcher:Dispatch(UserData)
				UIManager.ShowMsgBox(TR("操作成功"))

				if Sdk and self.type == 0 then
					local amount = ( UserData.money - lastMoney )
					if amount > 0 then
						Sdk:safeWithdraw(amount)
					else
						Sdk:safeDeposit( -amount )
					end
				end
			end
		end
	)
end

--进度条动画
function SafeBoxLayer:setSlider(slider)
	--进度条进度
	local _percent = self:getChild("lua_amount/percent")

    local fadeIn = cc.FadeIn:create(0.05)
    local fadeOut = cc.FadeOut:create(0.5)
    local tag = 100
    fadeIn:setTag(tag)
    fadeOut:setTag(tag)
    fadeIn:retain()
    fadeOut:retain()
    slider:addTouchEventListener(function(ref,type)
        if type == ccui.TouchEventType.began then
            _percent:stopActionByTag(tag)
            _percent:runAction(fadeIn)
        else
            _percent:stopActionByTag(tag)
            _percent:runAction(fadeOut)
        end
	end)
	--开始时设置透明
	_percent:setOpacity(0)
	--初始化进度条数字
	self:InitPercent(_percent)
	--循环更新进度条数据
	_percent:runAction(
        cc.RepeatForever:create(
            cc.Sequence:create(
                cc.DelayTime:create(0.01),
                cc.CallFunc:create(
					function()
						self:UpdatePosition(slider,_percent)
						self:setPercent(slider)
                    end
                )
            )
    ))

end
--初始化进度条数字
function SafeBoxLayer:InitPercent(_percent)
	self.ui_num = _percent:getChild("num")
    self.ui_num:setString("0%")
    self:setLocalZOrder(1000)
end

--设置百分比数值
function SafeBoxLayer:setPercent(slider)
	local percent = slider:getPercent()
    if percent < 0 then percent = 0 end
    if percent > 100 then percent = 100 end
    if self.ui_num then
        self.ui_num:setString(tostring(percent) .. "%")
    end
end

--slider 百分比调整位置
function SafeBoxLayer:UpdatePosition(slider,_percent)
	local size = slider:getContentSize()
	local percent = slider:getPercent()
	local posx = size.width / 100.0 * percent
	local pos = cc.p(posx, 0)
	pos = slider:convertToWorldSpace(pos)
	pos = slider:getParent():convertToNodeSpace(pos)
	_percent:setPositionX(pos.x)
end

------------------------------------------------------

return SafeBoxLayer
