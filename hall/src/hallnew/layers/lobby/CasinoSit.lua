local this = {}
this.stateGroupName = "CasinoSit"
this.stateName = "CasinoSit"
this.opened = false

function this.Open()
	if (this.opened) then
		return
	end
	
	MarqueeLogic:SetNoticePos()
	
	--彩金监听
	--gNetHandlers_Register(PKG_Support_Other_OneGameLotteryRet, "OneGameLotteryRet", this.W_Handle_Bonuses_Datas)
	gNetHandlers_Register(PKG_Slots_Client_SyncPlayerStates, "SyncPlayerStates", this.HandleSyncPlayerStates)
	gNetHandlers_Register(PKG_Lobby_Client_ReturnLobby, "ReturnLobby", this.HandleServerLeave)
	gUpdates_Set("CasinoSitUpdate", this.CasinoSitUpdate)
	
	this.root = cc.Layer:create()
	gScene:addChild(this.root)
	this.root:setPosition(cc.p(Def.visibleSize.width/2,Def.visibleSize.height/2))
	
	this.layer = Tools.CreateLayer("csb/casino/SeatSelectionLayer.csb")
	this.layer:setAnchorPoint(cc.p(0.5,0.5))
	this.root:addChild(this.layer)
	
	this.Init()
	this.Adjust()
	this.InitSeatInfo()
	this.InitSeat()
	
	this.opened = true
end

function this.Close()
	if (not this.opened) then
		return
	end
	--
	this.seat_LV_item:release()
	this.PageView_item:release()
	this.PageView_item_2:release()
	
	--gNetHandlers_Unregister(PKG_Support_Other_OneGameLotteryRet, "OneGameLotteryRet")
	gNetHandlers_Unregister(PKG_Slots_Client_SyncPlayerStates, "SyncPlayerStates")
	gNetHandlers_Unregister(PKG_Lobby_Client_ReturnLobby, "ReturnLobby")
	gUpdates_Close("CasinoSitUpdate")
	
	this.root:removeFromParent()
	this.opened = false
end

function this.CasinoSitUpdate()
	if this.bonus_data and this.bonus_data.cur_setp > 0 then
		this.bonus_data.cur_frameRate = this.bonus_data.cur_frameRate - 1
		if this.bonus_data.cur_frameRate <= 0 then
			this.bonus_data.cur_frameRate = this.bonus_data.frameRate
			local gd_value = this.bonus_data.setp / math.random(90,100)
			if gd_value > this.bonus_data.cur_setp then
				gd_value = this.bonus_data.cur_setp
			end
			this.bonus_data.cur_setp = this.bonus_data.cur_setp - gd_value
			this.bonus_data.showValue = this.bonus_data.showValue + gd_value
			for i = 1, sGameManager.numTables do
				this.UpdateCaiJinValue(i,this.bonus_data.showValue)
			end
		end
	end
end

function this.SendCasinoSitDown(tableId,chairId)
	local data_ = PKG_Client_Slots_PlayerSit.Create()
	data_.tableId = tableId
	data_.chairId = chairId
	UIManager.ShowWaiting()
	local rlt_ = gNet_SendRequest(data_)
	UIManager.HideWaiting()
	if rlt_ ~=nil then
		if(rlt_.typeId == PKG_Generic_Success.typeId)then
			--直接切换到loading界面
			local script = require("hall.src.hallnew.layers.lobby.CasinoLoading")
			gStates_SetAsync(script)
            gStates_CloseAsync(this)
		elseif(rlt_.typeId == PKG_Generic_Error.typeId)then
			local errorCode = Int64ToNumber(rlt_.number)
			print("老虎机选座错误码：", errorCode)
			--客户端发送的位置信息无效
			if errorCode == 1 then
				UIManager.ShowToast(TR("该座位无效，请选择其它位置"))
			--该座位已被抢
			elseif errorCode == 2 then
				UIManager.ShowToast(TR("该座位已经有人"))
			--玩家不在游戏服、玩家已经在座位上
			elseif errorCode == 4 or errorCode == 3 then
				UIManager.ShowToast(TR("状态不一致，自动回大厅"))
			end
		end
	end
end

function this.HandleSyncPlayerStates(rlt_)
	--
	if((rlt_.player == nil) or 
		(rlt_.player.tableId > #(this.seat_table) or rlt_.player.tableId <= 0) or
		(rlt_.player.chairId > #(this.seat_table[rlt_.player.tableId].seat_info) or rlt_.player.chairId <= 0))then
		print("[异常][玩家离去或进入]Func HandleSyncPlayerStates")
		print(type(rlt_.player))
		if rlt_.player then
			print("桌号:" .. rlt_.player.tableId)
			print("椅号:" .. rlt_.player.chairId)
		end
		return
	end
	local tableId = rlt_.player.tableId
	local chairId = rlt_.player.chairId
	--玩家 1坐下 2离开 
	if rlt_.operate == 1 then
		this.SetSeatShow(tableId,chairId,true)
		this.seat_panel[tableId].cur_z_Size = this.seat_panel[tableId].cur_z_Size + 1
		this.UpdateSeatInfo(tableId)
	elseif rlt_.operate == 2 then
		this.SetSeatShow(tableId,chairId,false)
		this.seat_panel[tableId].cur_z_Size = this.seat_panel[tableId].cur_z_Size - 1
		this.UpdateSeatInfo(tableId)
	end
end

function this.Init()
	--
	this.send_package_btn_set = {}
	this.left_right_btn_set = {}
	this.base_btn_set = {}
	--
	--当前显示的桌位号
	this.cur_seat_index = 1
	
	this.seat_panel = {}
	this.seat_table = {}
	
	this.bonus_data = nil
	
	this.seat_str = "L%dZ%dR"
	
	local panel 		= this.layer:getChildByName("panel")
	local return_btn 	= panel:getChildByName("return")
	this.left_btn 		= panel:getChildByName("left")
	this.left_btn:setVisible(false)
	this.right_btn 	= panel:getChildByName("right")
	local panel_seat	= panel:getChildByName("panel_seat")
	local panel_2		= panel_seat:getChildByName("panel_2")
	this.panel_seat_bg 	= panel_2:getChildByName("bg")
	this.seat_ListView	= this.panel_seat_bg:getChildByName("ListView")
	this.seat_LV_item 	= this.seat_ListView:getChildByName("item")
	local title_Image	= panel_seat:getChildByName("Image")
	this.S_btn			= title_Image:getChildByName("btn_s")
	this.X_btn			= title_Image:getChildByName("btn_x")
	
	this.S_btn:setVisible(true)
	this.X_btn:setVisible(false)
	--
	this.seat_LV_item:retain()
	this.seat_ListView:removeAllItems()
	
	this.PageView		= panel:getChildByName("PageView")
	this.PageView_item	= this.PageView:getChildByName("item")
	this.PageView_item_2	= this.PageView:getChildByName("item_2")
	this.PageView_item:retain()
	this.PageView_item_2:retain()
	--
	this.PageView:removeAllPages()
	--
	this.seat_bg_PosX = this.panel_seat_bg:getPositionX()
	this.seat_bg_Pos_S_Y = this.panel_seat_bg:getPositionY()+232
	this.seat_bg_Pos_X_Y = this.panel_seat_bg:getPositionY()
	
	this.panel_seat_bg:setPosition(cc.p(this.seat_bg_PosX,this.seat_bg_Pos_S_Y))
	
	--
	Tools.AddClickEvent(return_btn, function()
		if Tools_Base.PreventContinuousClick(this.send_package_btn_set,0.3) then
			gorun(function ()
                local success = this.LeaveSlots(true)
                this.BackLobby(not success)
			end)
		end
    end, true)
	
	Tools.AddClickEvent(this.S_btn, function()
		if Tools_Base.PreventContinuousClick(this.base_btn_set,0.3) then
			this.S_btn:setVisible(false)
			this.X_btn:setVisible(true)
			local action = cc.Sequence:create(cc.MoveTo:create(0.1,cc.p(this.seat_bg_PosX,this.seat_bg_Pos_X_Y)))
			this.panel_seat_bg:runAction(action)
		end
    end, true)
	
	Tools.AddClickEvent(this.X_btn, function()
		if Tools_Base.PreventContinuousClick(this.base_btn_set,0.3) then
			this.S_btn:setVisible(true)
			this.X_btn:setVisible(false)
			local action = cc.Sequence:create(cc.MoveTo:create(0.1,cc.p(this.seat_bg_PosX,this.seat_bg_Pos_S_Y)))
			this.panel_seat_bg:runAction(action)
		end
    end, true)
	
	Tools.AddClickEvent(this.left_btn,this.OnBtnPreClick, true)
	Tools.AddClickEvent(this.right_btn,this.OnBtnNextClick, true)

end

function this.Adjust()
	local bg = this.layer:getChildByName("bg")
	local panel = this.layer:getChildByName("panel")
    bg:setScale(Def.ScaleMax)
    panel:setScale(Def.ScaleMin)
end

function this.InitSeatInfo()
	this.seat_ListView:removeAllItems()
	for i = 1, sGameManager.numTables do
		this.AddSeatInfoItem(i)
	end
	
	for i = 1, #sGameManager.playersInfo do
		local data = sGameManager.playersInfo[i]
		if data then
			this.seat_panel[data.tableId].cur_z_Size = this.seat_panel[data.tableId].cur_z_Size + 1
			this.UpdateSeatInfo(data.tableId)
		end
	end
	
	local btn = this.seat_panel[this.cur_seat_index].item:getChildByName("btn")
	btn:setOpacity(255)
end

function this.InitSeat()
	this.PageView:removeAllPages()
	for i = 1, sGameManager.numTables do
		this.AddSeat(i,nil)
	end
	for i = 1, #sGameManager.playersInfo do
		local data = sGameManager.playersInfo[i]
		if data then
			this.SetSeatShow(data.tableId,data.chairId,true)
		end
	end
	this.PageView:scrollToItem(0)
	this.PageView:addScrollViewEventListener(
		function(sender, eventType)
			if 12 == eventType then -- API过时了卧槽
				release_print("Scroll 12 ... ")
				local index = sender:getCurrentPageIndex()
				this.UpdateSeatInfoShow(index + 1)
				local cnt = #this.PageView:getItems()
				if this.cur_seat_index == 1 then
					this.left_btn:setVisible(false)
				else
					this.left_btn:setVisible(true)
				end
				if this.cur_seat_index == cnt then
					this.right_btn:setVisible(false)
				else
					this.right_btn:setVisible(true)
				end
				
			end
        end
    )
end

function this.UpdateSeatInfoShow(seat_number)
	if this.seat_panel[seat_number] == nil then
		print("[异常] UpdateSeatInfoShow [seat_number]:" .. tostring(seat_number))
		return
	end

	local btn = this.seat_panel[this.cur_seat_index].item:getChildByName("btn")
	btn:setOpacity(0)
	this.cur_seat_index = seat_number
	btn = this.seat_panel[this.cur_seat_index].item:getChildByName("btn")
	btn:setOpacity(255)
end

function this.UpdateSeatInfo(seat_number)
	if(seat_number <= 0 or #this.seat_panel < seat_number)then
		print("[异常]func UpdateSeatInfo [seat_number]:" .. seat_number)
		return
	end
	local msg = this.seat_panel[seat_number].item:getChildByName("msg")
	local hao_num = msg:getChildByName("hao_num")
	hao_num:setString(tostring(seat_number))
	local seat = msg:getChildByName("seat")
	local max_digit = this.seat_panel[seat_number].chairSize
	local cur_digit = this.seat_panel[seat_number].cur_z_Size
	seat:setString(string.format(this.seat_str,cur_digit,max_digit))
end

function this.AddSeatInfoItem(seat_number)
	local new_item = this.seat_LV_item:clone()
	--
	local btn = new_item:getChildByName("btn")
	
	this.seat_panel[seat_number] = {}
	this.seat_panel[seat_number].seat_number = seat_number
	this.seat_panel[seat_number].item = new_item
	this.seat_panel[seat_number].cur_z_Size = 0
	this.seat_panel[seat_number].chairSize = sGameManager.chairSize
	
	this.UpdateSeatInfo(seat_number)
	
	Tools.AddClickEvent(btn, function()
		if Tools_Base.PreventContinuousClick(this.base_btn_set,0.3) then
			this.PageView:scrollToItem(seat_number-1)
			this.UpdateSeatInfoShow(seat_number)
		end
    end, false)
	btn:setOpacity(0)
	
    this.seat_ListView:pushBackCustomItem(new_item)
end

function this.AddSeat(seat_number,info)
	--
	local new_page = nil
	-- if GameData.game_id >= 250 and GameData.game_id <= 260 then
	if GameData.game_id >= 250 and  GameData.game_id < 331 and
	GameData.game_id > 333  then
		new_page = this.PageView_item_2:clone()
	else
		new_page = this.PageView_item:clone()
	end
	--
	this.seat_table[seat_number] = {}
	this.seat_table[seat_number].seat_number = seat_number
	this.seat_table[seat_number].item = new_page
	this.seat_table[seat_number].seat_info = {}
	local jt_move_action = cc.Sequence:create(cc.MoveBy:create(0.5,cc.p(0,30)),cc.MoveBy:create(0.5,cc.p(0,-30)))
	local jt_action = cc.RepeatForever:create(jt_move_action)
	for i = 1, 4 do
		local str = string.format("seat_%d",i)
		local item = new_page:getChildByName(str)
		this.seat_table[seat_number].seat_info[i] = item
		local casino = item:getChildByName("casino")
	
		local casino_path = string.format("lobby/icon/%d.png",GameData.game_id)
		Tools.LoadTexture(casino,casino_path)
		local caijin_Bg = casino:getChildByName("caijin_Bg")
		caijin_Bg:setVisible(false)
		local seat = this.seat_table[seat_number].seat_info[i]:getChildByName("seat")
		local jt = seat:getChildByName("jt")
		jt:runAction(jt_action:clone())
		Tools.AddClickEvent(seat, function()
			if Tools_Base.PreventContinuousClick(this.send_package_btn_set,0.3) then
				go(function()
					this.SendCasinoSitDown(seat_number,i)
				end)
			end
		end, false)

		local casino = this.seat_table[seat_number].seat_info[i]:getChildByName("casino")
		Tools.AddClickEvent(casino, function()
			if Tools_Base.PreventContinuousClick(this.send_package_btn_set,0.3) then
				go(function()
					this.SendCasinoSitDown(seat_number,i)
				end)
			end
		end, false)
		this.SetSeatShow(seat_number,i,false)
	end
	
	this.PageView:addPage(new_page)
end

function this.SetSeatShow(seat_number,index,isPeople)
	if (seat_number > #(this.seat_table)) or (0 >= seat_number) then
		print("[异常]func SetSeatShow[seat_number]" .. seat_number)
		return
	end
	if (index > #(this.seat_table[seat_number].seat_info)) or (0 >= index) then
		print("[异常]func SetSeatShow[index]" .. index)
		return
	end
	local seat = this.seat_table[seat_number].seat_info[index]:getChildByName("seat")
	local jt = seat:getChildByName("jt")
	local people = seat:getChildByName("people")
	seat:setEnabled(not isPeople)
	seat:setTouchEnabled(not isPeople)
	jt:setVisible(not isPeople)
	people:setVisible(isPeople)
end

--刷新彩金
function this.UpdateCaiJinValue(seat_number,value)
	local new_page = this.seat_table[seat_number].item
	local seat_info = this.seat_table[seat_number].seat_info
	for i = 1, 4 do
		local str = string.format("seat_%d",i)
		local item = new_page:getChildByName(str)
		local casino = item:getChildByName("casino")
		local caijin_Bg = casino:getChildByName("caijin_Bg")
		caijin_Bg:setVisible(true)
		local caijin = caijin_Bg:getChildByName("caijin")
		caijin:setString(Tools.GetLotteryMoneyStr(value))
	end
end

function this.OnBtnPreClick()
	if Tools_Base.PreventContinuousClick(this.left_right_btn_set,0.3) then
		local index = this.PageView:getCurrentPageIndex()
		if index > 0 then
			this.UpdateSeatInfoShow(index)
			this.PageView:scrollToItem(index - 1)
		end
	end
end

function this.OnBtnNextClick()
	if Tools_Base.PreventContinuousClick(this.left_right_btn_set,0.3) then
		local index = this.PageView:getCurrentPageIndex()
		local cnt = #this.PageView:getItems()
		if index < cnt - 1 then
			this.UpdateSeatInfoShow(index + 2)
			this.PageView:scrollToItem(index + 1)
		end
	end
end

function this.Update_Bonuses_Datas(datas)
	local max_index = 5
	if (nil ~= datas[max_index]) then
		for i = 1, sGameManager.numTables do
			this.UpdateCaiJinValue(i,datas[max_index].showDigit)
		end
	end
end

--服务器将客户端踢回大厅
function this.HandleServerLeave()
	print("服务器通知客户端退出老虎机选座")
	this.BackLobby(false)
end

--------------------------------------------------------------------------

function this.LeaveSlots(bRetry)
    local data_ = PKG_Client_Slots_Leave.Create()
    local rlt_ = gNet_SendRequest(data_)
    dump(rlt_, "LeaveSlots: rlt_ ")

    if rlt_ and rlt_.typeId == PKG_Slots_Client_Leave_Success.typeId then
        print("LeaveSlots: success.")
        return true
    end

    -- retry
    if bRetry then
        SleepSecs(0.2)
        print("LeaveSlots: false, try again.")
        return this.LeaveSlots(false)
    end
    return false
end

function this.BackLobby(bForceReEnter)
	sGameManager.isCasinoLoaded = false
	sGameManager.gameState = const_game.Lobby_State

    if bForceReEnter then
        Recconnect()
    end

    local layer = BottomLayer:Get(LobbyLayer)
    if layer then
        layer:EnterLobby()
    else
        EnterLobbyPanel()
    end

    gStates_CloseAsync(this)
end

return this
