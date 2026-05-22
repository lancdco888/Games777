local RoomList = class("RoomList", function(node)
    node:enableNodeEvents()
    return node
end)

function RoomList:ctor()
    self.ui_bg = nil        --列表背景
    self.ui_btn_up = nil    --向上按钮
    self.ui_btn_down = nil  --向下按钮
    self.ui_list = nil      --列表
    self.ui_item = nil      --节点

    self.onSelect = nil     --选中回调
end

---------------------------------------------------

function RoomList:onEnter()
    self:InitUI()
end

function RoomList:InitUI()
    self.ui_bg = self:getChild("bg")
    self.ui_btn_up = self:findChild("btn_up")
    Tools.AddClickEvent(self.ui_btn_up, function()
        self:ShowList(false)
    end)
    self.ui_btn_down = self:findChild("btn_down")
    Tools.AddClickEvent(self.ui_btn_down, function()
        self:ShowList(true)
    end)
    self.ui_list = self:findChild("list")
    self.ui_item = self.ui_list:findChild("item")
    self.ui_item:retain()
    self.ui_list:removeAllItems()
end

----------------------------------------------------
-- 下拉列表处理
--显示 & 隐藏列表
function RoomList:ShowList(bShow)
	if bShow then
		self.ui_btn_up:setVisible(true)
		self.ui_btn_down:setVisible(false)
		self.ui_list:setVisible(true)
		self.ui_bg:setVisible(true)
	else
		self.ui_btn_up:setVisible(false)
		self.ui_btn_down:setVisible(true)
		self.ui_list:setVisible(false)
		self.ui_bg:setVisible(false)
	end
end

--设置单个节点的数据 info : {roomId, count<当前几个人>}
function RoomList:SetItemInfo(item, info)
	--节点命名
	item.roomId = info.roomId
	--按钮
	local ui_btn = item:findChild("btn_select")
	Tools.AddClickEvent(ui_btn, function()
		self:OnBtnRoomClick(info.roomId)
    end)
    --房号
    local ui_room_id = item:findChild("room_id")
    ui_room_id:setString(info.roomId)
    --当前总人数
    local ui_total = item:findChild("count")
    ui_total:setString(info.count)
	--选中处理
	local ui_select_bg = item:findChild("sel_bg")
	ui_select_bg:setVisible(false)	--默认未选中
    --背景, 选中时需处理
    item.ui_select_bg = ui_select_bg
    item.ui_bg = item:findChild("bg")
end

function RoomList:SetSelect(roomId)
    local items = self.ui_list:getItems()
    local idx_ = 1
    for idx,item in ipairs(items) do
        if roomId == item.roomId then
            -- 选中
            item.ui_select_bg:setVisible(true)
            item.ui_bg:setScale(1.1)
            idx_ = idx
        end
        item.ui_select_bg:setVisible(false)
        item.ui_bg:setScale(0.92)
    end
    if idx_ ~= 1 then
        self.ui_list:scrollToItem(idx_-1, cc.p(0, 0.6), cc.p(0, 0))        --减1
    end
    items[idx_].ui_select_bg:setVisible(true)
    items[idx_].ui_bg:setScale(1.1)
end

function RoomList:GetSelect()
    local items = self.ui_list:getItems()
    for _, item in ipairs(items) do
        if item.ui_select_bg:isVisible() then
            return item.roomId
        end
    end
    return -1
end

function RoomList:OnBtnRoomClick(roomId)
    self:SetSelect(roomId)
    if self.onSelect then
        self.onSelect(roomId)
    end
end

function RoomList:SetRoomList(roomInfos)
	self.ui_list:removeAllItems()
	for _,room in ipairs(roomInfos) do
		local info = {}
        info.roomId = room.roomId
        --计算人数
        local cnt = 0
        for _,p in ipairs(room.players) do
            if p ~= null then cnt = cnt + 1 end
        end
		info.count = cnt
        local new_item = self.ui_item:clone()
		self:SetItemInfo(new_item, info)
		self.ui_list:pushBackCustomItem(new_item)
    end
    self:SetSelect(-1)
    self:ShowList(false)
end

function RoomList:Update()
	self:SetRoomList(GameData.rooms)
end

return RoomList
