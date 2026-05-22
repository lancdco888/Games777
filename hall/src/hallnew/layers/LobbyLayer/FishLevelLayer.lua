--等级选择面板
local FishLevelLayer = class("FishLevelLayer", function()
	return Tools.CreateLayer("csb/LobbyLayer/LevelCatchFish.csb")
end)

function FishLevelLayer:onEnter()
    self.pos_btn_return = cc.p(0, 0)
    self.pos_ui_title = cc.p(0, 0)
    self.pos_ui_level_list = cc.p(0, 0)

	self:InitUI()

	self:AdjustUI()
end

function FishLevelLayer:InitUI()
	self:InitPanel()
	self:InitList()
end

--适配界面
function FishLevelLayer:AdjustUI()
	local scale = Def.ScaleMin
	local size = Def.visibleSize
	self:setAnchorPoint(cc.p(0.5, 0.5))
	self:setPosition(size.width/2.0, size.height/2.0)
	self:setScale(scale)

    self.pos_ui_level_list = cc.p(self.ui_level_list:getPosition())
end

--返回按钮
function FishLevelLayer:SetTop(top)
	self.top = top
	self:AdjustTop()
end

function FishLevelLayer:AdjustTop()
	local top = self.top
	local size = Def.visibleSize
	local ret_size = self.ui_btn_return:getContentSize()
	local pos = cc.p((ret_size.width * Def.ScaleMin)/2 + 10 * Def.ScaleX, top-(ret_size.height * Def.ScaleMin)/2 - 15 * Def.ScaleX)
	pos = self:convertToNodeSpace(pos)
	self.ui_btn_return:setPosition(pos)
    self.pos_btn_return = pos

    local top_height = size.height - top
	local title_size = self.ui_title:getContentSize()
    local scale = top_height / title_size.height
    self.ui_title:setScale(scale)

	local title_pos = cc.p(size.width, size.height)
	title_pos = self:convertToNodeSpace(title_pos)
	self.ui_title:setPosition(title_pos)
    Tools.CcuiTextIgnoreContentAdaptOneLineByFontSize(self.ui_title)
    self.pos_ui_title = title_pos
end

-----------------------------------------------------------------------------

function FishLevelLayer:InitPanel()
	self.ui_title = self:findChild("title")
	self.ui_title:setVisible(false) -- 隐藏标题，因为在切换语言的时候表现很奇怪
	self.ui_btn_return = self:findChild("btn_return")
	Tools.AddClickEvent(self.ui_btn_return, function()
		if Tools_Base.PreventContinuousClick(self.ui_title,0.5) then
			print("btn_return btn_return")
			self:HandleReturn()
		end
	end, true)
end

function FishLevelLayer:UpdateGameName()
	local cfg = const_game.Param[GameData.game_id]
	if cfg then
		local name = cfg.Game_Name
		self.ui_title:setString(TR(name))
		-- 排版
		self:AdjustTop()
	end
end

function FishLevelLayer:HandleReturn()
	go(function()
		local data_ = PKG_Client_Lobby_ReturnUp.Create()
		UIManager.ShowWaiting()
		local rlt_ = gNet_SendRequest(data_)
		UIManager.HideWaiting()
		if rlt_ ~= nil then
			if getmetatable(rlt_) == PKG_Lobby_Client_Enter_Success then
				sGameManager.RealnameSwitch(rlt_.is_open_realname_mode)
				-- 刷新客户端热更新配置
				GameData.game_ids = nil
				GameData.game_ids = rlt_.gameIds
				sGameManager.SetUserInfo(rlt_.self)
				-- 大厅底部按钮开关
				local buttonList = {}
				if rlt_.botton_configs then
					for i = 1, #rlt_.botton_configs do
						buttonList[rlt_.botton_configs[i].key] = rlt_.botton_configs[i].is_open
					end
				end
				UserData.buttonList = nil
				UserData.buttonList = buttonList
				service.ServiceLogic:UpdateWithButtonList(buttonList)
				-- 更新活动相关数据
				activity.logic:UpdateWhenEnterLobby(rlt_)

				local lobbyLayer = self:getParent()
				lobbyLayer:ReturnLobby()
			elseif getmetatable(rlt_) == PKG_Generic_Error then
				if rlt_.number == -1 then	--无需返回,此时服务端认为客户端已经在大厅
					local lobbyLayer = self:getParent()
					lobbyLayer:ReturnLobby()
				end
			end
		end
	end)
end

-----------------------------------------------------------------------------
-- 游戏列表处理
function FishLevelLayer:InitList()
	self.ui_level_list = self:findChild("level_list")
	self.ui_item = self.ui_level_list:findChild("item")
	self.ui_item:retain()
	self.ui_level_list:removeAllItems()
end

-- info : icon="xx.png", pao_min, pao_max, join, level
function FishLevelLayer:SetItemInfo(item, info)
	--多语言刷新
	local pao = item:findChild("pao")
	Tools.LoadTexture(pao,Def.FishLevelLayer_Pao)
	local join = item:findChild("join")
	Tools.LoadTexture(join,Def.FishLevelLayer_Entry)
	--
	local ui_btn_icon = item:findChild("btn_icon")
	ui_btn_icon:loadTextures(info.icon, info.icon)
	local ui_pao_value = item:findChild("pao_value")
	local num_str_1 = tonumber(Int64ToString(info.pao_min))
	local num_str_2 = tonumber(Int64ToString(info.pao_max))
	ui_pao_value:setString(
		Tools.CoinToShowString(num_str_1)
		.. "-"
		.. Tools.CoinToShowString(num_str_2)
	)

	local ui_join_value = item:findChild("join_value")
	local strTem = Tools.CoinToShowString(info.join)
	ui_join_value:setString(strTem)

	--重新绘制位置--居中
	local bg_width = item:getContentSize().width

	--炮值范围重新绘制
	local pao_width = pao:getContentSize().width + ui_pao_value:getContentSize().width
	local scale = 1.0
	if pao_width > bg_width then
		scale = bg_width / (pao_width + 16)
	end
	pao_width = pao_width * scale
	local pao_posx = (bg_width - pao_width)/2
	pao:setPosition(pao:getContentSize().width*scale / 2 + pao_posx, pao:getPositionY())
	ui_pao_value:setPosition(pao_posx + pao:getContentSize().width*scale + ui_pao_value:getContentSize().width*scale / 2,ui_pao_value:getPositionY())
	pao:setScale(scale)
	ui_pao_value:setScale(scale)

	--入场金额重新绘制
	local join_width = join:getContentSize().width + ui_join_value:getContentSize().width
	local join_posx = (bg_width - join_width)/2
	join:setPosition(join:getContentSize().width / 2 + join_posx,join:getPositionY())
	ui_join_value:setPosition(join_posx + join:getContentSize().width + ui_join_value:getContentSize().width / 2,ui_join_value:getPositionY())

	-- 进入值 小于0隐藏 "准入" 栏，炮值栏 居中
	if info.join < 0 then
		local y_mid = ( ui_pao_value:getPositionY() + ui_join_value:getPositionY()) / 2.0
		ui_pao_value:setPositionY(y_mid)
		pao:setPositionY(y_mid)
		ui_join_value:setVisible(false)
		join:setVisible(false)
	else
		ui_join_value:setVisible(true)
		join:setVisible(true)
	end

	Tools.AddClickEvent(ui_btn_icon,
		function()
			if Tools_Base.PreventContinuousClick(self.ui_title,0.5) then
				self:OnClickLevel(info)
			end
		end, true)
end

function FishLevelLayer:OnClickLevel(info)
	GameData.level_id = info.level_id
	self:HandleEnterRoomCoro(info)
end

function FishLevelLayer:CanEnterRoom(idx)
	local min = GameData.levels[idx].minMoney
	if UserData.money >= min then
		return true
	else
		return false
	end
end

function FishLevelLayer:HandleEnterRoomCoro(info)
	go(function()
		if self:CanEnterRoom(info.idx) then
			local data_ = PKG_Client_Lobby_EnterGameCatchFishLevel.Create()
			data_.levelId = info.level_id
			UIManager.ShowWaiting()
			local rlt_ = gNet_SendRequest(data_)
			UIManager.HideWaiting()
			if rlt_ ~= nil then
				if getmetatable(rlt_) == PKG_Lobby_Client_EnterGameCatchFishLevel_Success then
					GameData.rooms = rlt_.rooms
					-- dump(rlt_.rooms, "rlt_.rooms:")
					local lobby = self:getParent()
					lobby:EnterFishRoom()
				elseif getmetatable(rlt_) == PKG_Generic_Error then
				end
			end
		else
			local str = string.gsub(TR("当前房间需要NNN金币才可进入，前往保险箱取钱或进行充值?"), "NNN", tostring(info.join / sGameManager.exchangerate))
			UIManager.ShowMsgBox(str,
				function()		--on ok
					sGameManager.PopSafeBoxLayer()
				end,
				function()		--on cancel
					sGameManager.PopRecharge()
				end,true)
		end
	end)
end

function FishLevelLayer:SetLevelList(level_list_)
	self.ui_level_list:removeAllItems()
	if #level_list_ == 3 then
		self.ui_level_list:setItemsMargin(160)
	else
		self.ui_level_list:setItemsMargin(30)
	end
	for _,info in ipairs(level_list_) do
		local new_item = self.ui_item:clone()
		self.ui_level_list:pushBackCustomItem(new_item)
		self:SetItemInfo(new_item, info)
	end
end

function FishLevelLayer:UpdateLevelList()
	local cfg = const_game.Param[GameData.game_id]
	if not cfg then
		print("Error UpdateLevelList:", GameData.game_id)
		return
	end
	local game_idx = cfg.Icon
	local level_list_ = {}
	for level,lvl_cfg in pairs(GameData.levels) do
		if (type(level) == "number") then
			local info = {}
			table.insert(level_list_, info)
			info.idx = level
			info.level_id = lvl_cfg.levelId
			local icon = "level/%d/%d.png"
			info.icon = icon:format(game_idx, info.level_id)
			--配置
			info.pao_min = lvl_cfg.minBet
			info.pao_max = lvl_cfg.maxBet
			info.join = lvl_cfg.minMoney
		end
	end
	self:SetLevelList(level_list_)
end

-----------------------------------------------------------------------------

--进场动画
local time = 0.22
function FishLevelLayer:RunEnterAni()
    self:RestorePos()

	self.ui_title:setVisible(true)
	Tools.MoveInAni(self.ui_title, time, 300)
	Tools.MoveInAni(self.ui_level_list, time, 1400)
	Tools.MoveInAni(self.ui_btn_return, time, -300)
end

--出场动画
function FishLevelLayer:RunExitAni()
    self:RestorePos()

	Tools.MoveOutAni(self.ui_title, time, 300)
	Tools.MoveOutAni(self.ui_level_list, time, 1400)
	Tools.MoveOutAni(self.ui_btn_return, time, -300)
end

function FishLevelLayer:RestorePos()
	self.ui_btn_return:setPosition(self.pos_btn_return)
	self.ui_title:setPosition(self.pos_ui_title)
    self.ui_level_list:setPosition(self.pos_ui_level_list)
end

return FishLevelLayer
