local RoomPage = class("RoomPage", function(node)
    node:enableNodeEvents()
    return node
end)

function RoomPage:onEnter()
    self:InitUI()
end

function RoomPage:InitUI()
    self.ui_room_page = self:findChild("page")
	self.ui_item = self.ui_room_page:getChild("item")
	self.ui_item:retain()
	self.ui_room_page:removeAllItems()

	self.ui_btn_pre = self:findChild("btn_pre")
	self.ui_btn_pre:setVisible(false)
	self.ui_btn_next = self:findChild("btn_next")
	self.ui_btn_next:setVisible(false)
	Tools.AddClickEvent(self.ui_btn_pre, function()
		self:OnBtnPreClick()
	end, true)
	Tools.AddClickEvent(self.ui_btn_next, function()
		self:OnBtnNextClick()
	end, true)
	self.ui_room_page:addScrollViewEventListener(
		function(sender, eventType)
			if 12 == eventType then -- API过时了卧槽
				local index = sender:getCurrentPageIndex()
				self:OnChangeTable(index)
			end
        end
    )
end

function RoomPage:OnChangeTable(index)
    local item = self.ui_room_page:getItem(index)
    if item and item.roomId ~= self.roomId then
        self.roomId = item.roomId
        self:CheckPageBtn()
        if self.onPageChanged then
            self.onPageChanged(item.roomId)
        end
    end
end

function RoomPage:OnBtnPreClick()
	local index = self.ui_room_page:getCurrentPageIndex()
	if index > 0 then
		self.ui_room_page:scrollToItem(index - 1)
	end
	-- self:OnChangeTable(index - 1)
end

function RoomPage:OnBtnNextClick()
	local index = self.ui_room_page:getCurrentPageIndex()
	local cnt = #self.ui_room_page:getItems()
	if index < cnt - 1 then
		self.ui_room_page:scrollToItem(index + 1)
	end
	-- self:OnChangeTable(index + 1)
end

--检查 下一个 和 上一个 按钮
function RoomPage:CheckPageBtn()
	local index = self.ui_room_page:getCurrentPageIndex()
	self.ui_btn_pre:setVisible(index > 0)
	local cnt = #self.ui_room_page:getItems()
	self.ui_btn_next:setVisible(index < cnt-1)
end

----------------------------------------------------

--设置一个房间信息
function RoomPage:SetItemInfo(item, info)
    --节点命名
    item.roomId = info.roomId
	--桌子编号
	local ui_table_num = item:findChild("table_num")
	ui_table_num:setString(info.roomId)
	--玩家列表
	local players = info.players
	for idx=1,4 do
		local ui_chair = item:findChild("chair_" .. idx)
		local ui_person = ui_chair:findChild("person")
		local ui_arrow = ui_chair:findChild("arrow")
		if ui_arrow.pos == nil then	--保存初始位置
			ui_arrow.pos = cc.p(ui_arrow:getPosition())
		end
		ui_arrow:stopAllActions()
		local player = players[idx]
		if player == null then	--无人座位
			ui_person:setVisible(false)
			ui_arrow:setVisible(true)
			local chairId = idx
			Tools.AddClickEvent(ui_chair, function()
				-- 处理非滚动状态的点击
                if self.ui_room_page:isScrolling() then
					print("click on scrolling !")
				else
					if Tools_Base.PreventContinuousClick(sGameManager.gameroom, 1) then
						self:SendEnterCatchfish(info.roomId, chairId - 1)
					else
						print("点慢一点好啵")
					end
				end
			end, true)
			ui_arrow:runAction(cc.RepeatForever:create(
				cc.Sequence:create(
					cc.MoveTo:create(0.8, cc.p(ui_arrow.pos.x, ui_arrow.pos.y+40)),
					cc.MoveTo:create(0.8, cc.p(ui_arrow.pos.x, ui_arrow.pos.y-40))
				)
			))
		else
			ui_person:setVisible(true)
			ui_arrow:setVisible(false)
			Tools.AddClickEvent(ui_chair, function()
			end, false)
		end
	end
end

function RoomPage:SetRoomList(room_list_)
	self.ui_room_page:removeAllPages()
	for _,room in ipairs(room_list_) do
		local new_page = self.ui_item:clone()
		self:SetItemInfo(new_page, room)
		self.ui_room_page:addPage(new_page)
	end
	self.ui_room_page:scrollToItem(0)
	self:CheckPageBtn()
end

--更新单个房间
function RoomPage:UpdateRoom(room)
    local items = self.ui_room_page:getItems()
    for _,item in ipairs(items) do
        if item.roomId == room.roomId then
            self:SetItemInfo(item, room)
            return
        end
    end
end

function RoomPage:Update()
	self:SetRoomList(GameData.rooms)
end

function RoomPage:ScrollToRoomId(roomId)
    local items = self.ui_room_page:getItems()
    for idx,item in ipairs(items) do
        if item.roomId == roomId then
            self.ui_room_page:scrollToItem(idx - 1)
            return
        end
    end 
end

--------------------------------------------------------------

local time = 0.22
--进场动画
function RoomPage:RunEnterAni()
	Tools.MoveInAni(self.ui_btn_next, time, 300)
	Tools.MoveInAni(self.ui_room_page, time, 1400)
	self.ui_btn_pre:setVisible(false)
end

--出场动画
function RoomPage:RunExitAni()
	Tools.MoveOutAni(self.ui_btn_next, time, 300)
	Tools.MoveOutAni(self.ui_room_page, time, 1400)
	Tools.MoveOutAni(self.ui_btn_pre, time, -300,
		function()
			self.ui_btn_pre:setVisible(false)
		end
	)
end

--------------------------------------------------------------

function RoomPage:SendEnterCatchfish(roomId, sitIndex)
	print("TEST :" .. tostring(self) .. ", roomId:" .. tostring(roomId) .. ",sitIndex:" .. tostring(sitIndex))

	if self.blocking then
		dump({
			roomId = roomId,
			sitIndex = sitIndex
		}, " ****** blocked click ****** ")
		
		print("TEST : blocked ")
		return
	end

	self.blocking = true
	go(function()
		local data_ = PKG_Client_Lobby_EnterGameCatchFishLevelRoomSit.Create()
		data_.levelId = GameData.level_id
		data_.roomId = roomId
		data_.sitIndex = sitIndex
		UIManager.ShowWaiting()
		local rlt_ = gNet_SendRequest(data_)
		UIManager.HideWaiting()

		if not rlt_ then
			self.blocking = false
			UIManager.ShowMsgBox(TR("网络连接失败，请重试"))
			return
		end

		if getmetatable(rlt_) == PKG_Lobby_Client_EnterGameCatchFishLevelRoomSit_Success then
            GameData.game_id = rlt_.GameId

			GameData.serverID = rlt_.serviceId
			PopLayer:CloseAll()

			local cfg = const_game.Param[GameData:GetGameID(GameData.game_id)]
            if not cfg then
                UIManager.ShowMsgBox(TR("本地未找到相关游戏"))
                return
            end
			local panel = require "hall.src.hallnew.Panel_Lobby"
			panel.lobbyLayer:EnterFishLoading()
		elseif getmetatable(rlt_) == PKG_Generic_Error then
			self.blocking = false
			local num = Int64ToNumber(rlt_.number)
			if (num == Def.Net_EnterCatch_NoService or num == Def.Net_EnterCatch_NoService_2) then
				UIManager.ShowMsgBox(TR("没有空闲的游戏服"))
			elseif ((num == Def.Net_EntetCatch_NoSit or num == Def.Net_EntetCatch_NoSit - 1) or num == Def.Net_EntetCatch_NoSit - 2) then
				UIManager.ShowMsgBox(TR("当前座位已有人或房间已满"))
			else
                UIManager.ShowMsgBox(TR("网络连接失败，请重试"))
			end
		end
	end)
end

----------------------------------------------------

return RoomPage
