local RechargePopup_VirtualCoin = class("RechargePopup_VirtualCoin", function()
    return Tools.CreateLayer("csb/RechargePopup_VirtualCoin.csb")
end)

function RechargePopup_VirtualCoin:onEnter()
    Dispatcher:Register("BIND_VC", function()
        local info = self:GetAccInfo(self.cur_recharge_options_ID)
        if #info > 0 then
			self.my_acc:setString(info[1].card_number)
			self._lang_bind_acc:setVisible(false)
		else
			self._lang_bind_acc:setVisible(true)
		end
	end, self)
    self:InitUI()
end

function RechargePopup_VirtualCoin:onExit()
    Dispatcher:Remove(self)
end

function RechargePopup_VirtualCoin:GetAccInfo(idx)
	local list = {}
	for key, value in ipairs(UserData.pay_channel_accounts) do
		if value.pay_channel_id == idx then
			table.insert(list,value)
		end
	end
	return list
end

function RechargePopup_VirtualCoin:GetExchange()
    if self.exchange then
        return self.exchange
    end
	for _, value in ipairs(sGameManager.payChannels) do
		if value.id == self.cur_recharge_options_ID then
            self.exchange = value.exchange
            return self.exchange
		end
	end
	return 1
end

function RechargePopup_VirtualCoin:InitUI()
    local popup = self:getChildByName("bg")
	--关闭按钮
	local btn_close = popup:getChildByName("btn_close")
    Tools.AddClickEvent(btn_close, function()
        self:Close()
    end, true)
    --收款钱包地址
    self.busy_acc = popup:getChildByName("busy_acc")
    --自己的钱包地址
    self.my_acc = popup:getChildByName("my_acc")
    --充值金额
    self.money = popup:getChildByName("money")
    --到账金额
    self.reveive_money = popup:getChildByName("reveive_money")
    --复制收款钱包地址
    local _lang_copy_busy = popup:getChildByName("_lang_copy_busy")

    Tools.AddClickEvent(_lang_copy_busy, function()
        local account = ""
        for index, value in ipairs(sGameManager.vipChannels) do
            if value.pay_channel_id == self.cur_recharge_options_ID then
                account = value.account
            end
        end
        Device:CopyString(account)
        UIManager.ShowToast(TR("复制成功"))
    end, true)


    -- 绑定钱包
    self._lang_bind_acc = popup:getChildByName("_lang_bind_acc")
    Tools.AddClickEvent(self._lang_bind_acc, function()
        local layer = PopLayer:Pop(BindVirtualCoinLayer)
        layer:setInfo(self.cur_recharge_options_ID)
    end, true)

    --提示信息
    self.tips = popup:getChildByName("tips")

    --已支付按钮
    local _lang_btn_cg = popup:getChildByName("_lang_btn_cg")
    Tools.AddClickEvent(_lang_btn_cg, function()
        if self.my_acc:getString() == "" then
            UIManager.ShowToast(TR("请先绑定钱包地址！"))
            local layer = PopLayer:Pop(BindVirtualCoinLayer)
            layer:setInfo(self.cur_recharge_options_ID)
            return
        end
        self:sendRechargeInfo()
    end, true)

    --放弃支付
    local _lang_btn_sb = popup:getChildByName("_lang_btn_sb")
    Tools.AddClickEvent(_lang_btn_sb, function()
		self:Close()
    end, true)
end

function RechargePopup_VirtualCoin:setInfo(pay_type_id,vip_infos,money,acc_infos)
    if not pay_type_id or not vip_infos or not money or not acc_infos then
        UIManager.ShowToast("RechargePopup_VirtualCoin vip infos error")
        self:Close()
        return
    end
    if self ~= nil then
        self.cur_recharge_options_ID = pay_type_id
        self.busy_acc:setString(vip_infos.account)
        self.money:setString(money)
        self.reveive_money:setString(money*self:GetExchange())
        self.tips:setString(vip_infos.description)
		if #acc_infos > 0 then
			self.my_acc:setString(acc_infos[1].card_number) -- 自己的虚拟钱包地址
			self._lang_bind_acc:setVisible(false)
		else
			self._lang_bind_acc:setVisible(true)
		end
    end
end

function RechargePopup_VirtualCoin:sendRechargeInfo(rlt_)
	go(function()
		local data_ = PKG_Client_Lobby_ClientRechargeRequest.Create()
		data_.money = tonumber(self.reveive_money:getString()) *sGameManager.exchangerate
		data_.pay_type = self.cur_recharge_options_ID
		data_.ip_info = ""
		data_.is_create_order = 1
		data_.pay_name = "nil"
		data_.pay_card_number = ""
		data_.upstream_order_num = ""
		UIManager.ShowWaiting()
		local rlt_ = gNet_SendRequest(data_)
		UIManager.HideWaiting()

		if rlt_ == nil then
			UIManager.ShowMsgBox(TR("网络连接失败，请重试"))
			return
		end

        local PKG_name = getmetatable(rlt_)
		if PKG_name == PKG_Lobby_Client_ClientRechargeRequestSuccess then
            UIManager.ShowMsgBox(TR("请等待审核，3分钟内审核通过后系统会自动帮您冲入金币。如有疑问请联络客服查询!"))

            PopLayer:Close(LobbyRechargeLayer)
            if not tolua.isnull(self) then
                self:Close()
            end
		elseif PKG_name == PKG_Generic_Error then
			if rlt_.message == "you cannot use this recharge method at present" then
				local tips = string.format(TR("金币不足%d时才能切换充值方式"),UserData.virtual_coin_status_switch_money) 
				UIManager.ShowMsgBox(tips)
				return
			elseif rlt_.message == "you have submitted a different type of order" then
				UIManager.ShowMsgBox(TR("您的上一笔支付订单我们正在审核操作中，请及时关注金币到账情况耐心等待！如有疑问请咨询客服。"))
				return
			end
			local num = Int64ToNumber(rlt_.number)
			if (num == -120) then
				UIManager.ShowMsgBox(TR("您的上一笔支付订单我们正在审核操作中，请及时关注金币到账情况耐心等待！如有疑问请咨询客服。"))
			else
				UIManager.ShowMsgBox(TR("请求充值失败，请联系客服后重试"))
			end
		end
	end)
end

return RechargePopup_VirtualCoin