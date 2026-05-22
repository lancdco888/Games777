local BankCardChoicePopUpLayer = class("BankCardChoicePopUpLayer", function()
	return Tools.CreateLayer("csb/BankCardChoicePopUp.csb")
end)

function BankCardChoicePopUpLayer:onEnter()
	self.listinfo = {}
	self:InitUI()
	self:UpdateBankInfoList()

	Dispatcher:Register("BANK_INFO", function()
		self:UpdateBankInfoList()
	end, self)
end

function BankCardChoicePopUpLayer:InitUI()
	self:InitPanel()
	self:InitBankCardList()
end

function BankCardChoicePopUpLayer:InitPanel()
	local ui_btn_close = self:findChild("lua_close_btn")
	Tools.AddClickEvent(ui_btn_close, function()
		self:Close()
	end, true)
	local ui_btn_confirm = self:findChild("_lang_btn_confirm")
	Tools.AddClickEvent(ui_btn_confirm, function()
		self:OnBtnConfirmClick()
	end, true)
end

function BankCardChoicePopUpLayer:OnBtnConfirmClick()
	if self.selected_card_info then
		self:HandleExchange(self.selected_card_info, self.exchange_money)
	else
		UIManager.ShowMsgBox(TR("请选择一个账号"))
	end
end

function BankCardChoicePopUpLayer:HandleExchange(info, exchange_money)
    if UserData:IsExperienceUser() then
        UIManager.ShowMsgBox(TR("试玩账号不能兑换"))
        return
    end

	go(function()
		local data_ = PKG_Client_Lobby_Refund.Create()
		data_.id = info.id
		data_.money = exchange_money
		data_.requirement = info.card_number
		data_.pay_channel_id = info.pay_channel_id
		UIManager.ShowWaiting()
		local rlt_ = gNet_SendRequest(data_)
		UIManager.HideWaiting()
		dump(rlt_,"申请退款BankCardChoicePopUpLayer")
		if rlt_ ~= nil then
			if getmetatable(rlt_) == PKG_Lobby_Client_RefundResultMoneyChanged then
				local value = rlt_.refund_money / sGameManager.exchangerate
				local str = string.gsub(
					TR("您已成功申请兑换NNN金币！请耐心等待3-5分钟即可在您的SSS查看哟！"),
					"NNN", value)
				UserData.money_safe = rlt_.money_safe
				UserData.money = rlt_.money
				Dispatcher:Dispatch(UserData)
				local info = string.gsub(str, "SSS", TR(self.info_.name))
				UIManager.ShowMsgBox(info)
				PopLayer:Close(ExchangeLayer)
				self:Close()

				if Sdk then
					Sdk:refund(value)
				end
			elseif(getmetatable(rlt_) == PKG_Generic_Error)then
				local num = Int64ToNumber(rlt_.number)
				if -120 == num then
					UIManager.ShowMsgBox(TR("上一笔订单正在处理中"))
				elseif (num == Def.Net_Login_PhoneWorng) then
					UIManager.ShowMsgBox(TR("兑换失败，请联系客服"))
				elseif (num == Def.Net_Insufficient_Redemption)then
					UIManager.ShowMsgBox(TR("兑换次数不足，请联系客服"))
                elseif (num == -9999) then
                    -- "您操作太频繁，请稍后再试"
                    UIManager.ShowMsgBox("ဆက်တိုက်လုပ်ဆောင်မှုများနေသဖြင့် ခဏစောင့်ဆိုင်းပြီးမှ လုပ်‌ဆောင်ပေးပါရှင့်(E9999)")
                else
					UIManager.ShowMsgBox(TR("兑换失败，请联系客服"))
				end
			end
		else
			UIManager.ShowMsgBox(TR("网络连接失败，请重试"))
			return
		end
	end)
end

function BankCardChoicePopUpLayer:InitBankCardList()
	self.ui_selected_check = nil			--当前选中的单选框
	self.selected_card_info = nil			--当前选中的账号

	self.ui_list_cards = self:findChild("list_cards")
	self.ui_item = self.ui_list_cards:findChild("item")
	self.ui_item:retain()
	self.ui_list_cards:removeAllItems()
end

--更新列表
function BankCardChoicePopUpLayer:UpdateBankInfoList()
	self.ui_list_cards:removeAllItems()
	for _,info in ipairs(self.listinfo) do
		local new_item = self.ui_item:clone()
		self.ui_list_cards:pushBackCustomItem(new_item)
		self:SetItemInfo(new_item, info)
	end
end

--银行卡信息 card_number
function BankCardChoicePopUpLayer:SetItemInfo(item, info)
	--使用深拷贝
	info = table.deepcopy(info)

	local ui_check = item:findChild("check")
	local ui_account = item:findChild("text_account")
	local ui_btn_modify = item:findChild("_lang_btn_modify")
	ui_account:setString(info.card_number)
	Tools.AddClickEvent(ui_btn_modify, function()
		self:OnBtnModifyClick(info)
	end)
	if info.pay_channel_id == 7 or info.pay_channel_id == 8 then
		ui_btn_modify:setVisible(false)
	end
    ui_btn_modify:setVisible(false)

	ui_check:onEvent(function(event)
		if event.name == "selected" then
			if self.ui_selected_check then
				self.ui_selected_check:setSelected(false)
			end
			ui_check:setSelected(true)
			self.ui_selected_check = ui_check
			self.selected_card_info = info
		elseif event.name == "unselected" then
			self.ui_selected_check = nil
			self.selected_card_info = nil
		end
	end)
	--默认不选中
	ui_check:setSelected(false)
end

function BankCardChoicePopUpLayer:OnBtnModifyClick(info)
	if sGameManager.is_open_realname_mode == 1 then
		UIManager.ShowMsgBox(TR("请联系客服修改"))
		return
	end

	local layer = PopLayer:Pop(ExchangePopUpLayer)
	layer:SetBankInfo(info)
end

------------------------------------------------------------------

function BankCardChoicePopUpLayer:SetExchangeMoney(money)
	if self then
		self.exchange_money = money
	end
end

--设置绑定的卡的信息,不同弹窗需要数据
function BankCardChoicePopUpLayer:SetInfoList(list,list_)
	if self then
		self.listinfo = list
		self.info_ = list_
		self:UpdateBankInfoList()
	end
end

return BankCardChoicePopUpLayer
