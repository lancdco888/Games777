local RecordDatailsLayer = class("RecordDatailsLayer", function()
	return Tools.CreateLayer("csb/RecordDatailsLayer.csb")
end) 

function RecordDatailsLayer:onEnter()
	self:InitUI()
	
	if self.detail then
		self.SetDetail(self.detail)
	end
end

function RecordDatailsLayer:InitUI()
	local ui_btn_close = self:findChild("lua_close_btn")
	Tools.AddClickEvent(ui_btn_close, function()
		self:Close()
	end, true)

	local ui_items = {}
	for i=1,10 do
		local ui_item = self:findChild("item_" .. i)
		if ui_item then
			local item = {}
			item.label = ui_item:findChild("label"):hide()
			item.value = ui_item:findChild("value"):hide()
			table.insert(ui_items, item)
		end 
	end
	self.ui_items = ui_items

	--详细信息
	self.ui_detail_info = self:findChild("detail_info")
end

function RecordDatailsLayer:SetDetail(detail,infolist)
	self.detail = detail
	self.infolist = infolist
	if self then
		local infos = self:ConvertDetailToInfo(detail)
		self:SetInfos(infos)
		self:SetDetaiInfo(detail.description)
	end
end

function RecordDatailsLayer:ConvertDetailToInfo(detail)
	local infos = {}
	--提现时间文字
	local time = {}
	time[1] = TR("提现时间:")
	time[2] = self:FormatTime(detail.create_time)
	--退款金额
	local money = {}
	money[1] = TR("提现金额:")
	money[2] = tostring(detail.money / sGameManager.exchangerate)
	--渠道名字
	local channel = {}
	channel[1] = TR(self.infolist.channelname)
	channel[2] = detail.cash_account
	--状态
	local state = {}
	state[1] = TR(self.infolist.state_info)
	if (detail.state == 0) then
		state[2] = TR("申请中")
	elseif(detail.state == 1)then
		state[2] = TR("提现成功")
	else
		state[2] = TR("提现失败")
	end
	--持卡人信息
	local owner = {}
	owner[1] = TR(self.infolist.name_info)
	owner[2] = detail.cash_name

	if self.infolist.channelname ~= "nil" then
		return {
			time,
			channel,
			state,
			money,
			owner
		}
	else
		return {
			time,
			state,
			money,
		}
	end
	
end

function RecordDatailsLayer:FormatTime(time)
	local year, month, day, hour, min, second, _, _  = Int64ToDateTime(time)
	local fmt = "%d-%02d-%02d %02d:%02d:%02d"
	local time = fmt:format(year, month, day, hour, min, second)
	return time
end

-- infos = {Item, ...}, Item = {"提现时间", "2019-12-18 16:40:40"} 
function RecordDatailsLayer:SetInfos(infos)
	for idx,info in ipairs(infos) do
		local ui_item = self.ui_items[idx]
		if not ui_item then break end
		ui_item.label:setVisible(true)
		ui_item.label:setString(info[1])
		ui_item.value:setVisible(true)
		ui_item.value:setString(info[2])
	end
end

function RecordDatailsLayer:SetDetaiInfo(info)
	self.ui_detail_info:setString(info)
end

return RecordDatailsLayer