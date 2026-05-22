local ExchangePopUpLayer = class("ExchangePopUpLayer", function()
	return Tools.CreateLayer("csb/ExchangePopUpLayer.csb")
end)

function ExchangePopUpLayer:onEnter()
	self.shownextpop = true 		--是否需要弹出下一级界面:true:需要，false:不需要
	self.defname = ""				--默认显示姓名
	self.defcard = ""				--默认显示卡号
	self.shouldShowBindBtn = false  --默认显示绑定成功
	self.pay_channel_id = nil		--momo,zalo绑定用传入绑定渠道
	self:InitUI()
end

function ExchangePopUpLayer:InitUI()
	--关闭按钮
	local ui_close_btn = self:findChild("lua_close_btn")
	Tools.AddClickEvent(ui_close_btn, function()
		self:Close()
	end, true)

	--绑定按钮
	self.btn_bind = self:findChild("_lang_btn_bind")
	self.btn_bind:setVisible(true)
	Tools.AddClickEvent(self.btn_bind, function()
		self:OnBtnClick()
	end)

	--更换按钮
	self.btn_change = self:findChild("_lang_btn_change")
	self.btn_change:setVisible(false)
	Tools.AddClickEvent(self.btn_change, function()
		self:OnBtnClick()
	end)

	--姓名
	local edit = self:findChild("edit_nickname")
	self.ui_edit_name = Tools.ReplaceEdit(edit)
	self.ui_edit_name:setPlaceholderFontSize(30)
	self.ui_edit_name:setFontSize(28)
	self.ui_edit_name:setReturnType(cc.KEYBOARD_RETURNTYPE_DONE)
	self.ui_edit_name:setInputMode(cc.EDITBOX_INPUT_MODE_SINGLELINE)

	--账号
	local edit = self:findChild("edit_card_num")
	self.ui_card_num = Tools.ReplaceEdit(edit)
	self.ui_card_num:setPlaceholderFontSize(25)
	self.ui_card_num:setFontSize(25)
	self.ui_card_num:setMaxLength(20)
	self.ui_card_num:setReturnType(cc.KEYBOARD_RETURNTYPE_DONE)
	self.ui_card_num:setInputMode(cc.EDITBOX_INPUT_MODE_NUMERIC)
	self.ui_card_num:onEvent(
		function()
			local str = self.ui_card_num:getText()
			if str ~= "" then
				local len = #str
				local num = string.sub(str, len, len)
				if self:CheckNum(num) then
					self.numText = str
				else
					if str == "" then
						self.numText = str
						self.ui_card_num:setText(self.numText)
					end
					self.ui_card_num:setText(self.numText)
				end
			end
		end)
	
	self.ui_card_num:setPlaceHolder(TR("请输入账号"))
	self.ui_edit_name:setPlaceHolder(TR("请输入姓名"))
end

function ExchangePopUpLayer:CheckNum(num)
	if num <= "9" and num >= "0" then
		return true
	end
	return false
end

--绑定或更换点击事件
function ExchangePopUpLayer:OnBtnClick()
	local name = self.ui_edit_name:getText()
	if name == "" then
		UIManager.ShowToast(TR("姓名不能为空，请输入正确的姓名"))
		return
	elseif exutils.strIsBlank(name) then
		UIManager.ShowToast(TR("姓名不能全是空格，请输入正确的姓名"))
		return
	end
	local acc = self.ui_card_num:getText()
	if acc == "" then
		UIManager.ShowToast(TR("账号不能为空，请输入正确的账号"))
		return
	end

	if self.shownextpop then
		self:PopConfirmBindPanel()
	else
		if exutils.CheckPhone(#acc)then
			local str_1 = 0
			if ConfigParam.Region == "ms" or ConfigParam.Region == "vn" or ConfigParam.Region == "tha" then
				local min,max = exutils.GetPhoneLenth()
				str_1 = tostring(min) .. "-" .. tostring(max)
			else
				str_1 = exutils.GetPhoneLenth()
			end
			local str_ = ""
			if ConfigParam.Region == "vn" then
				str_ = string.gsub(TR("请输入AAA位数的账号"),"AAA",str_1)
			else
				str_ = string.gsub(TR("请输入AAA位数的手机号"),"AAA",str_1)
			end
            UIManager.ShowToast(str_)
			return
		end
		if ConfigParam.Region == "vn" then
			self:HandleBindBankCard(name,acc,"")
		else
			self:HandleBindPhone(name,acc)
		end
	end
end

--绑定手机号
function ExchangePopUpLayer:HandleBindPhone(name,acc)
	go(function()
		local data_ = PKG_Client_Lobby_BandingRealNamePhoneInfo.Create()
		data_.payer_name = name
		data_.phone = acc
		UIManager.ShowWaiting()
		local rlt_ = gNet_SendRequest(data_)
		UIManager.HideWaiting()

		if(rlt_ ~= nil) then
            local PKG_name = getmetatable(rlt_)
			if PKG_name == PKG_Lobby_Client_BandingRealNameResult then
				UserData.pay_channel_accounts = rlt_.pay_channel_accounts
				Dispatcher:Dispatch(UserData)
				Dispatcher:Dispatch("UPDATE_CARD")
				UIManager.ShowToast(TR("账号绑定成功"))
				self:Close()
			elseif PKG_name == PKG_Generic_Error then
				local num = Int64ToNumber(rlt_.number)
				if num == -1 then
					UIManager.ShowMsgBox(TR("重复绑定"))
				elseif num == -2 then -- 姓名不匹配
					UIManager.ShowMsgBox(TR("手机号姓名和银行卡姓名不一致"))
				else
					UIManager.ShowMsgBox(num..rlt_.message)
				end
			end
		else
			UIManager.ShowMsgBox(TR("网络连接失败，请重试"))
			return
		end
	end)
end

--绑定银行卡
function ExchangePopUpLayer:PopConfirmBindPanel()
	local layer = PopLayer:Pop(ConfirmBindLayer)
	layer:AddBindHandler(function()
		local bank_name = layer:GetInputName()
		local ifsc = ""
		if ConfigParam.Region == "ina" then
			ifsc = layer:GetInputIFSC()
		end
		if bank_name == "" then	--输入无效
			UIManager.ShowToast(TR("请输入开户行"))
		elseif ConfigParam.Region == "ina" and not layer:CheckIsIFSC(ifsc) then
			UIManager.ShowToast(TR("IFSC格式不正确"))
		else
			local acc_name = self.ui_edit_name:getText()
			local card_number = self.ui_card_num:getText()
			self:HandleBindBankCard(acc_name, card_number, bank_name, ifsc)
		end
	end)
end

--执行该函数时 参数检查等工作应该已经完成
function ExchangePopUpLayer:HandleBindBankCard(acc_name, card_number, bank_name, ifsc)
	go(function()
		local data_ = PKG_Client_Lobby_ChangePayChannelBank.Create()
		data_.name = acc_name
		data_.card_number = card_number
		data_.bank_name = bank_name
		data_.ifsc = ifsc
		data_.id = 0
		if self.bank_info then
			data_.id = self.bank_info.id
		end
		if self.pay_channel_id then
			data_.pay_channel_id = self.pay_channel_id
		end
		UIManager.ShowWaiting()
		local rlt_ = gNet_SendRequest(data_)
		UIManager.HideWaiting()
		if rlt_ ~= nil then
            local PKG_name = getmetatable(rlt_)
			if PKG_name == PKG_Lobby_Client_ChangePayChannelBank_Success then
				UserData.pay_channel_accounts = rlt_.pay_channel_accounts
				Dispatcher:Dispatch(UserData)
				Dispatcher:Dispatch("BANK_INFO")
				Dispatcher:Dispatch("UPDATE_CARD")
				if self.shouldShowBindBtn then
					UIManager.ShowToast(TR("账号修改成功"))
				else
					UIManager.ShowToast(TR("账号绑定成功"))
				end

                PopLayer:Close(ConfirmBindLayer)
                if not tolua.isnull(self) then
                    self:Close()
                end
			elseif PKG_name == PKG_Generic_Error then
				local num = Int64ToNumber(rlt_.number)
				if num == -19 then
					local str_ = string.gsub(TR("最多只能绑定NNN个账号"),"NNN",UserData.bankcardcount)
					UIManager.ShowMsgBox(str_)
				else
					UIManager.ShowMsgBox(TR("绑定失败"))
				end
			end
		else
			UIManager.ShowMsgBox(TR("网络连接失败，请重试"))
			return
		end
	end)
end

function ExchangePopUpLayer:SetBankInfo(bank_info)
	self.bank_info = bank_info
	if self then
		self:SetDefInfo(bank_info.name,bank_info.card_number)
		self.shouldShowBindBtn = true
		self.btn_change:setVisible(true)
		self.btn_bind:setVisible(false)
	end
end

--设置默认显示信息
function ExchangePopUpLayer:SetDefInfo(name,card)
	if self then
		self.ui_card_num:setText(card)
		if name ~= "" then
			self.ui_edit_name:setEnabled(false)
		end
		self.ui_edit_name:setText(name)
	end
end

--具体哪一张银行卡
function ExchangePopUpLayer:SetAccNumberID(idx)
	if self then
		self.idx = idx
	end
end

---------------------------------------------------------
function ExchangePopUpLayer:NextPopNoShow(isphone,maxlenth_)
	if self then
		self.shownextpop = false
		if isphone then
			local len = 0
			if maxlenth_ then
				len = maxlenth_
			else
				len = 10
			end
			self.ui_card_num:setMaxLength(len)
		end
	end
end

function ExchangePopUpLayer:SetPayId(id_)
	if self then
		self.pay_channel_id = id_
		local title = self:findChild("title")
		title:setVisible(false)
		local title_1 = self:findChild("title_1")
		title_1:setVisible(true)
		local account_lbl = self:findChild("account_lbl")
		account_lbl:setVisible(false)
		local account_lbl_1 = self:findChild("account_lbl_1")
		account_lbl_1:setVisible(true)
		local tips = self:findChild("_lang_tips")
		tips:setVisible(false)
	end
end
return ExchangePopUpLayer
