local this = {}
this.stateGroupName = "Main"
this.stateName = "Lobby"
this.opened = false

this.Open = function()
	local layer = BottomLayer:Get(LobbyLayer)
	if not layer then
		layer = BottomLayer:Show(LobbyLayer)
	end
	this.lobbyLayer = layer
	layer:EnterLobby()

	--音乐相关
	this.Sound()

	this.CheckEnterPops()

	--游戏退回大厅后取消PKG_Extral_注册，大厅也要请求彩金
	gNet_UnegisterServiceMappings("PKG_Extral_")
	this.opened = true
end

this.Close = function()
	if this.lobbyLayer then
		BottomLayer:Show(nil)
	end

	Dispatcher:Remove(this)

	--消息在老虎机中修改的bug
	this.lobbyLayer = nil

	this.opened = false
end

--音乐相关
this.Sound = function()
	--播放大厅音乐
	local res = cc.UserDefault:getInstance():getBoolForKey("Once",false)
	if(not res)then
		cc.UserDefault:getInstance():setBoolForKey("music",true)
        cc.UserDefault:getInstance():setBoolForKey("effect",true)
        cc.UserDefault:getInstance():setBoolForKey("rocker",false)
		cc.UserDefault:getInstance():setBoolForKey("Once",true)
	end

	--判断音乐开关是否开启或关闭
	gSound.playBgm("hallsound/bg_lobby.mp3")
end

--进入游戏
this.SendEnterRoomLevel = function(gameID,callback)
	print("进入游戏",gameID)
	if sGameManager.CheckIsCasino(gameID) then -- 老虎机不发包直接切
		GameData.game_id = gameID
		GameData.entergame_id = gameID

		local resGameId = GameData:GetGameID(gameID)
		local cfg = const_game.Param[resGameId]
		if not cfg then
			UIManager.ShowToast(string.format("no const_game.Param[ %d ]", resGameId))
			return
		end

		package.loaded["g_net"] = {}
		local ok, _ = pcall(require, string.format("hall.src.pkgs.slot_%d", tostring(resGameId)))
		if not ok then
			UIManager.ShowToast(string.format("pkgs/%d.lua not found.", resGameId))
			return
		end

		local temparr = GameData.casinoLevelTabs[gameID]
		if temparr == nil then
			UIManager.ShowToast(string.format('GameData.casinoLevelTabs[ %d ] : ', gameID))
			return
		end

		package.loaded["hall.src.hallnew.layers.lobby.CasinoSitEnter"] = nil
		local CanisoEnter_script = require("hall.src.hallnew.layers.lobby.CasinoSitEnter")
		gStates_SetAsync(CanisoEnter_script)
	else
		go(function()
			local data_ = PKG_Client_Lobby_EnterGame.Create()
			data_.gameId = gameID
			UIManager.ShowWaiting()
			local rlt_ = gNet_SendRequest(data_)
			UIManager.HideWaiting()
			dump(rlt_,"rlt_")
			if rlt_ ~=nil then
				if(getmetatable(rlt_) == PKG_Lobby_Client_EnterGameCatchFish_Success)then
					if callback then
						callback()
					end
					GameData.levels = rlt_.levels
					this.lobbyLayer:EnterFishLevel()
				elseif(getmetatable(rlt_) == PKG_Generic_Error)then
					sGameManager.GameIsPlay = false
					UIManager.ShowMsgBox(TR("网络连接失败，请重试"))
				elseif(getmetatable(rlt_) == PKG_Lobby_Client_EnterGameSlots_Success)then
					sGameManager.GameIsPlay = false
				end
			end
		end)
	end
end
--判断是不是富豪场
function this.JudgeC_or_rech(id)
    return (id > 2000 and id < 3000)
end
--------------------------------------------------------------------------------
--进入成功后弹窗
this.CheckEnterPops = function()
	go(function()
		-- 检查邮件
		Dispatcher:Register(
			service.ServiceLogic,
			function()
				local layer = BottomLayer:Get(LobbyLayer)
				if layer then
					layer:ShowMailTip(service.ServiceLogic:CheckUnRead() or UserData.ServiceTips)
				else
					service.ServiceLogic:CheckUnRead()
				end
			end,
			this
		)

        SleepSecs(0.5)
		service.ServiceLogic:RequestMails()

        SleepSecs(0.7)
		this.CheckActives()

        SleepSecs(0.7)
		this.CheckSpread()

        SleepSecs(0.7)
		this.CheckEmailBindAd()
	end)
end

-- 控制每次进 App 弹出一次
SpreadPopped = false
this.CheckSpread = function()
	if SpreadPopped then
		return
	end
	SpreadPopped = true

	if not activity.logic:IsScreenshotOpen() then
		return
	end
	if not activity.logic:IsScreenshotPopUp() then
		return
	end
	if not activity.SpreadLogic:SupportSaveToPhoto() then
		print("photo: no support !")
		return
	end
	if activity.SpreadLogic:IsSavePhoto() then
		print("photo: saved !")
		return
	end
	if not activity.SpreadLogic:HasSpreadInfo() and not activity.SpreadLogic:FetchSpreadInfo() then
		return
	end
	PopLayer:Pop(activity.SpreadLayer)
end

this.CheckActives = function()
	-- 功能栏 活动按钮红点，需要活动数据支持，无论是否
	-- 弹框，都需要请求活动数据
	local result = activity.logic:ReqActivityStatus()
	if not result then
		print("获取活动信息失败")
		return
	end

    SleepSecs(0.7)
    activity.logic:ReqRebateCanGives()

	local poplayers = {}
	-- 第一次进入大厅
	if GameData.game_id <= 0 then
		-- 转盘
		if activity.logic:IsOpenTurntable() and activity.logic:IsTurntablePopUp() then
			table.insert(poplayers, {
				LayerClass = activity.TurntableLayer,
				Init = nil
			})
		end

		-- 首充 弹出条件
		if activity.logic:IsOpenFirstRecharge() then
			table.insert(poplayers, {
				LayerClass = activity.RechargeFirstLayer,
				Init = nil
			})
		end

		local rebate_ids = activity.logic:GetRebateIds()
		for __, rebate_id in ipairs(rebate_ids) do
			if activity.logic:IsRebateOpen(rebate_id)
				and activity.logic:IsRebatePopUp(rebate_id)
				and activity.logic:CanGiveByID(rebate_id)
                and PopLayer:Get(activity.ActivityCenterLayer) == nil
			then
				table.insert(poplayers, {
					LayerClass = activity.RebateLayer,
					Init = function(layer)
						layer:setRebateId(rebate_id)
					end
				})
			end
		end
	end

	for _,cfg in ipairs(poplayers) do
		local LayerClass = cfg.LayerClass
		local Init = cfg.Init

		local layer = PopLayer:Pop(LayerClass)
		if layer then
			if not layer.AdjustUI then
				layer:setScale(0.95)
			end
			layer:SetCloseFunc(true, nil)

			if Init then
				Init(layer)
			end
		end

		-- 一直等到该界面和该界面的下级界面关闭
		while true do
			local _layer = PopLayer:Get(LayerClass)
			if _layer or not sGameManager.lowerlevelisclose then
				coroutine.yield()
			else
				break
			end
		end
	end
end

this.CheckEmailBindAd = function()
	if GameData.game_id > 0 then
		return
	end
	local poplayers = {}
	if UserData.is_open_email_bind and
	UserData.is_open_email_bind == 1 and
	UserData.bind_account_money_gift and
	UserData.bind_account_money_gift > 0 and
	UserData.account_name == "" then
		table.insert(poplayers, activity.AccountBindAdLayer)
	end

	for _,layerClass in ipairs(poplayers) do
		local layer = PopLayer:Pop(layerClass)
		-- 一直等到该界面关闭
		while true do
			local _layer = PopLayer:Get(layerClass)
			if _layer then
				coroutine.yield()
			else
				break
			end
		end
	end
end
--------------------------------------------------------------------------------

return this
