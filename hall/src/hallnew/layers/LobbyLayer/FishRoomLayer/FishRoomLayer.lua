--等级选择面板
local FishRoomLayer = class("FishRoomLayer", function()
	return Tools.CreateLayer("csb/LobbyLayer/RoomCatchFish.csb")
end)

function FishRoomLayer:onEnter()
	self:InitUI()
	self:AdjustUI()
	self:InitEvent()
end

function FishRoomLayer:InitUI()
	sGameManager.gameroom = {}
	self:InitPanel()
	self:InitPage()
	self:InitList()
end

--适配界面
function FishRoomLayer:AdjustUI()
	local scale = Def.ScaleMin
	local size = Def.visibleSize
	self:setAnchorPoint(cc.p(0.5, 0.5))
	self:setPosition(size.width/2.0, size.height/2.0)
	self:setScale(scale)
end

function FishRoomLayer:SetTop(top)
	local size = Def.visibleSize
	--返回按钮
	local ret_size = self.ui_btn_return:getContentSize()
	local pos = cc.p((ret_size.width * Def.ScaleMin)/2 + 10 * Def.ScaleX, top-(ret_size.height * Def.ScaleMin)/2 - 15 * Def.ScaleX)
	pos = self:convertToNodeSpace(pos)
	self.ui_btn_return:setPosition(pos)
    self.pos_ui_btn_return = pos

	--选座列表
	local list_size = self.ui_list:getContentSize()
	local list_pos = cc.p(size.width - list_size.width * Def.ScaleMin / 2 - 20 * Def.ScaleX, top - (list_size.height * Def.ScaleMin)/2.0)
	list_pos = self:convertToNodeSpace(list_pos)
	self.ui_list:setPosition(list_pos)
    self.pos_ui_list = list_pos

	--标题
	local title_size = self.ui_title:getContentSize()
	local title_pos = cc.p(size.width - title_size.width * Def.ScaleMin / 2, top + (title_size.height * Def.ScaleMin)/2)
	title_pos = self:convertToNodeSpace(title_pos)
	self.ui_title:setPosition(title_pos)
    self.pos_ui_title = title_pos
end

-----------------------------------------------------------------------------

function FishRoomLayer:InitPanel()
	self.ui_title = self:findChild("title")
	self.ui_title:setVisible(false)
	self.ui_btn_return = self:findChild("btn_return")
	Tools.AddClickEvent(self.ui_btn_return, function()
		if Tools_Base.PreventContinuousClick(sGameManager.gameroom,1) then
			self:HandleReturn()
		end
	end, true)
	
end

function FishRoomLayer:InitPage()
	local page = self:findChild("room_page")
	local RoomPage = require("hall.src.hallnew.layers.LobbyLayer.FishRoomLayer.RoomPage")
	self.ui_page = RoomPage.new(page)
	self.ui_page.parent_ = self
	self.ui_page:onEnter()
	self.ui_page.onPageChanged = function(...)
		self:OnPageChanged(...)
	end
end

function FishRoomLayer:OnPageChanged(roomId)
	self.ui_list:SetSelect(roomId)
end

function FishRoomLayer:InitList()
	local list = self:findChild("room_list")
	local RoomList = require("hall.src.hallnew.layers.LobbyLayer.FishRoomLayer.RoomList")
	self.ui_list = RoomList.new(list)
	self.ui_list:setVisible(false)
	self.ui_list:onEnter()
	self.ui_list.onSelect = function(...)
		self:OnListSelect(...)
	end
end

function FishRoomLayer:OnListSelect(roomId)
	self.ui_page:ScrollToRoomId(roomId)
end

function FishRoomLayer:Update()
	--标题
	local level = GameData.level_id
	self.ui_title:loadTexture("language/room/" .. level .. ".png")
	self.ui_title:setVisible(true)
	self.ui_page:Update()
	self.ui_list:Update()
end

----------------------------------------------------

function FishRoomLayer:InitEvent()
	gNetHandlers_Register(PKG_Lobby_Client_Events_PlayerSitdown, "GNET_HALL_RoomPlayerSitdown", 
		function(data_)
			self:HandlePlayerSitDown(data_)
		end)
	gNetHandlers_Register(PKG_Lobby_Client_Events_PlayerStandup, "GNET_HALL_RoomPlayerStandup", 
		function(data_)
			self:HandlePlayerStandUp(data_)
		end)
end

function FishRoomLayer:CloseEvent()
	gNetHandlers_Unregister(PKG_Lobby_Client_Events_PlayerSitdown, "GNET_HALL_RoomPlayerSitdown")
	gNetHandlers_Unregister(PKG_Lobby_Client_Events_PlayerStandup, "GNET_HALL_RoomPlayerStandup")
end

function FishRoomLayer:UpdatePlayer(roomId, sitIndex, player_)
	for idx,room in ipairs(GameData.rooms) do
		if room.roomId == roomId then
			--更新数据信息 sGameManager 数据
			room.players[sitIndex+1] = player_
			self.ui_page:UpdateRoom(room)
			return
		end
	end
end

function FishRoomLayer:HandlePlayerSitDown(data_)
	self:UpdatePlayer(data_.roomId, data_.sitIndex, data_.player)
end

function FishRoomLayer:HandlePlayerStandUp(data_)
	self:UpdatePlayer(data_.roomId, data_.sitIndex, null)
end

----------------------------------------------------

local time = 0.22
--进场动画
function FishRoomLayer:RunEnterAni()
    self:RestorePos()

	Tools.MoveInAni(self.ui_title, time, 300)
	self.ui_list:setVisible(true)
	Tools.MoveInAni(self.ui_list, time, 600)
	self.ui_page:RunEnterAni()
	Tools.MoveInAni(self.ui_btn_return, time, -300)
end

--出场动画
function FishRoomLayer:RunExitAni()
    self:RestorePos()

	Tools.MoveOutAni(self.ui_title, time, 300)
	self.ui_list:setVisible(false)
	Tools.MoveOutAni(self.ui_list, time, 600)
	self.ui_page:RunExitAni()
	Tools.MoveOutAni(self.ui_btn_return, time, -300)
end

function FishRoomLayer:RestorePos()
	self.ui_title:setPosition(self.pos_ui_title)
	self.ui_list:setPosition(self.pos_ui_list)
	self.ui_btn_return:setPosition(self.pos_ui_btn_return)
end

----------------------------------------------------

function FishRoomLayer:HandleReturn()
	go(function()
		local data_ = PKG_Client_Lobby_ReturnUp.Create()
		local rlt_ = gNet_SendRequest(data_)
		if(getmetatable(rlt_) == PKG_Lobby_Client_EnterGameCatchFish_Success)then
			GameData.levels = rlt_.levels
			local lobby = self:getParent()
			lobby:ReturnFishLevel()
		elseif(getmetatable(rlt_) == PKG_Generic_Error)then
			UIManager.ShowMsgBox(TR("进入等级房失败"))
		end
	end)
end

return FishRoomLayer
