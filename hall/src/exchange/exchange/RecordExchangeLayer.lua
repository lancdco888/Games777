local RecordExchangeLayer = class("RecordExchangeLayer", function()
	return Tools.CreateLayer("csb/RecordExchangeLayer.csb")
end)

function RecordExchangeLayer:onEnter()
	self.TYPE = {
		[-1] 	=  TR("全部"),
		[0] 	=  TR("银行卡"),
		[2001] 	=  "TRC20",
		[2002] 	=  "ERC20",
	}
	local state,func = self:HideList()
	self.state = self.TYPE[state]
	self:InitUI()
	func()
	self:RequestRecordList()
	self:GoToPage(0)
end

function RecordExchangeLayer:onExit()
	if self.ui_item then
		self.ui_item:release()
	end
    if self.type_item then
		self.type_item:release()
	end
end

function RecordExchangeLayer:InitUI()
	self:InitPanel()
	self:InitRecordList()
	self:InitPage()
	self:InitStateList()
end

function RecordExchangeLayer:InitPanel()
	local ui_btn_close = self:findChild("lua_close_btn")
	Tools.AddClickEvent(ui_btn_close, function()
		self:Close()
	end, true)
	--上一页按钮
	self.btn_pre = self:findChild("_lang_btn_pre")
	Tools.AddClickEvent(self.btn_pre, function()
		if not self:GoToPage(self.page - 1) then
			UIManager.ShowMsgBox(TR("已经是第一页了"))
		end
	end)
	--下一页按钮
	self.btn_next = self:findChild("_lang_btn_next")
	Tools.AddClickEvent(self.btn_next, function()
		if not self:GoToPage(self.page + 1) then
			UIManager.ShowMsgBox(TR("已经是最后一页了"))
		end
	end)
end

function RecordExchangeLayer:InitRecordList()
	self.ui_list_record = self:findChild("list_record")
	self.ui_item = self.ui_list_record:findChild("item")
	self.ui_item:retain()
	self.ui_list_record:removeAllItems()
end

--------------------------------------------------------------
--翻页处理逻辑

function RecordExchangeLayer:InitPage()
	self.page = 0			--当前页码
	self.record_info_list = {}
end

function RecordExchangeLayer:InitStateList()
	self.type_list = self:findChild("type_list")
	self.type_item = self.type_list:findChild("type_item")
	self.type_item:retain()
	self.type_list:removeAllItems()
	local isVisible = false
	self.type_list:setVisible(isVisible)
	local type_list_bg = self:findChild("type_list_bg")
	local change_down_btn = self:findChild("change_down_btn")
	local change_up_btn = self:findChild("change_up_btn")

	Tools.AddClickEvent(change_down_btn, function()
		isVisible = true
		self.type_list:setVisible(isVisible)
		type_list_bg:setVisible(isVisible)
		change_down_btn:setVisible(false)
		change_up_btn:setVisible(true)
	end, true)
	
	Tools.AddClickEvent(change_up_btn, function()
		isVisible = false
		self.type_list:setVisible(isVisible)
		type_list_bg:setVisible(isVisible)
		change_down_btn:setVisible(true)
		change_up_btn:setVisible(false)
	end, true)
	type_list_bg:setVisible(false)
	change_down_btn:setVisible(true)
	change_up_btn:setVisible(false)
	for key, name in pairs(self.TYPE) do
		local cell = self.type_item:clone()
		self.type_list:pushBackCustomItem(cell)
		cell:setTitleText(name)
		Tools.AddClickEvent(cell, function()
			isVisible = not isVisible
			self.type_list:setVisible(isVisible)
			type_list_bg:setVisible(isVisible)
			change_down_btn:setVisible(true)
			change_up_btn:setVisible(false)
			self:getChild("header/lbl_2/_lang_txt"):setString(name)
			self:SetState(name)
		end, true)
	end


end

--前往指定页,失败返回 false
function RecordExchangeLayer:GoToPage(page)
	local record_info_list = self:GetListByType(self.state) 
	local COUNT = 6	--每页个数
	local pages = math.ceil(#record_info_list / COUNT)
	if page < 0 or page > pages-1 then
		return false
	end
	local start_idx = 1 + COUNT * page
	local end_idx = start_idx + COUNT - 1
	local infos = {}
	for index = start_idx, end_idx do
		local info = record_info_list[index]
		if not info then break end
		table.insert(infos, info)
	end
	self:SetRecordList(infos)
	self.page = page
	return true
end

--设置列表数据
function RecordExchangeLayer:SetRecordList(record_info_list)
	self.ui_list_record:removeAllItems()
	for idx, info in ipairs(record_info_list) do
		local new_item = self.ui_item:clone()
		self.ui_list_record:pushBackCustomItem(new_item)
		self:SetItemInfo(new_item, info)
	end
end

function RecordExchangeLayer:SetItemInfo(item, info)
	--订单号
	local withdraw_id = string.format("%d", Int64ToNumber(info.refund_id))
	--退款渠道
	local str_type = ""
	str_type = TR(self.infolist[info.pay_channel_id].name)
	--金额显示
	local money = info.money
	--日期显示
	local time = self:FormatTime(info.create_time)
	--订单处理状态
	local state = ""
	if info.state == 0 then
		state = TR("申请中")
	elseif info.state == 1 then
		state = TR("提现成功")
	else
		state = TR("提现失败")
	end
	local infos = {withdraw_id, str_type, money, time, state}
	for index, info in ipairs(infos) do
		local text = item:findChild("text_" .. index)
		if text then
			--金额需要转换
			if index == 3 then
				text:setString(Tools.CoinToShowString(info))
			else
				text:setString(info)
			end
			Tools.CcuiTextIgnoreContentAdaptOneLineByFontSize(text)
		end
	end
	--详情按钮
	local ui_detail_btn = item:findChild("btn_detail")
	Tools.AddClickEvent(ui_detail_btn, function()
		local layer = PopLayer:Pop(RecordDatailsLayer)
		layer:SetDetail(info,self.infolist[info.pay_channel_id])
	end, true)
end

function RecordExchangeLayer:FormatTime(time)
	local year, month, day, hour, min, second, _, _  = Int64ToDateTime(time)
	local fmt = "%d-%02d-%02d %02d:%02d:%02d"
	local time = fmt:format(year, month, day, hour, min, second)
	return time
end

function RecordExchangeLayer:RequestRecordList()
	go(function()
		local data_ = PKG_Client_Lobby_GetRefundList.Create()
		UIManager.ShowWaiting()
		local rlt_ = gNet_SendRequest(data_)
		UIManager.HideWaiting()
		if(getmetatable(rlt_) == PKG_Lobby_Client_GetRefundList)then
			self.record_info_list = rlt_.refund_List
			self:GoToPage(0)
		elseif(getmetatable(rlt_) == PKG_Generic_Error)then
			local num = Int64ToNumber(rlt_.number)
			UIManager.ShowMsgBox(num..rlt_.message)
			self:Close()
			return
		end
	end)
end

function RecordExchangeLayer:SetState(type)
	if self.state ~= type then
		self.ui_list_record:removeAllItems()
	end
	self.state = type
	self.page = 0
	self:GoToPage(0)
end

function RecordExchangeLayer:GetListByType(type)
	if type == self.TYPE[-1] then
		return self.record_info_list 
	elseif type == self.TYPE[0] then
		local ret = {}
		for _, infos in ipairs(self.record_info_list) do
			if infos.pay_channel_id < 2000 then
				table.insert(ret,infos)
			end
		end
		return ret

	elseif type == self.TYPE[2001] then
		local ret = {}
		for _, infos in ipairs(self.record_info_list) do
			if infos.pay_channel_id == 2001 then
				table.insert(ret,infos)
			end
		end
		return ret

	elseif type == self.TYPE[2002] then
		local ret = {}
		for _, infos in ipairs(self.record_info_list) do
			if infos.pay_channel_id == 2002 then
				table.insert(ret,infos)
			end
		end
		return ret
	end
	return {}
end

--------------------------------------------------------------
---设置一些资源信息
function RecordExchangeLayer:SetInfoList(list)
	if self then
		self.infolist = list
	end
end

-- 隐藏提现记录的选项卡
function RecordExchangeLayer:HideList()
	local isExistBankCard = false
	local isExistTRC20 = false
	local isExistERC20 = false
	if sGameManager.exchange_payChannels then
		for key, value in ipairs(sGameManager.exchange_payChannels) do
			if value.id == 2 then
				isExistBankCard = true
			elseif value.id == 2001 then
				isExistTRC20 = true
			elseif value.id == 2002 then
				isExistERC20 = true
			end
		end
	end
	local element = 4
	if not isExistBankCard then
		self.TYPE[0] = nil
		element = element - 1
	end
	if not isExistTRC20 then
		self.TYPE[2001] = nil
		element = element - 1
	end
	if not isExistTRC20 then
		self.TYPE[2002] = nil
		element = element - 1
	end
	if element<3 then
		self.TYPE[-1] = nil
		element = element - 1
	end
	local func = function() end
	if element == 1 then
		func = function()
			local pos = cc.p(88,28.57)
			self:findChild("change_down_btn"):setVisible(false)
			self:findChild("change_up_btn"):setVisible(false)
			local _lang_txt = self:getChild("header/lbl_2/_lang_txt")
			local size = _lang_txt:getContentSize()
			if sGameManager.Uicfg.skin == "purple" then
				pos = cc.p(72.50,27.00)
				size = cc.size(130,46.45)
			end
			_lang_txt:setPosition(pos)
			_lang_txt:setContentSize(size)
			_lang_txt:setString(self.state)
		end
	end
	if self.TYPE[-1] then
		return -1,func
	elseif self.TYPE[0] then
		return 0,func
	elseif self.TYPE[2001] then
		return 2001,func
	elseif self.TYPE[2002] then
		return 2002,func
	else
		print("未配置渠道")
	end
end
return RecordExchangeLayer
