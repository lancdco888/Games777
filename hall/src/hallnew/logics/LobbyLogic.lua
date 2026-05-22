local LobbyLogic = class("LobbyLogic")

function LobbyLogic:ctor()
	Dispatcher:Remove(self)
    self:Init()
end

function LobbyLogic:Init()
    gNetHandlers_Register(
        PKG_Lobby_Client_ReceivedMoneyResult,
        "GNET_HALL_LevelGetGivedMoney",
        function(...)
            self:HandleGetGivedMoney(...)
        end
        )
	gNetHandlers_Register(
        PKG_Lobby_Client_MoneyChanged,
        "GNET_HALL_LevelGetRechargeMoney",
        function(...)
			local rlt_ = ...
			Dispatcher:Dispatch("GNET_HALL_LevelGetRechargeMoney", rlt_)
            -- self:HandleGteRechargeMoney(...)
        end
        )
	Dispatcher:Register(
		"GNET_HALL_LevelGetRechargeMoney",
		LobbyLogic.HandleGteRechargeMoney,
		self
	)

	gNetHandlers_Register(
        PKG_Lobby_Client_OtherDeviceLogin,
        "GNET_HALL_LevelOtherDeviceLogin",
        function(...)
            self:HandleGteOtherDeviceLogin(...)
        end
		)
	gNetHandlers_Register(
		PKG_Lobby_Client_UpdateRealName,
		"GNET_HALL_HallGetBindCardInfo",
		function(...)
			self:HandleGetBindCardInfo(...)
		end
	)

	gNetHandlers_Register(
		PKG_Generic_Error,
		"GNET_HALL_Generic_Error",
		function(...)
			self:HandleGenericError(...)
		end
	)

	gNetHandlers_Register(
		PKG_Lobby_Client_UpdateExperienceStatus,
		"GNET_HALL_UpdateExperienceStatus",
		function(...)
			self:HandleUpdateExperienceStatus(...)
		end
	)

	--注册应用内客服主动推送的消息
	Dispatcher:Register("OnReceiveCustomerServiceMsg",self.OnReceiveCustomerServiceMsg,self,true)
	gNetHandlers_Register(PKG_Lobby_Client_Message, "GNET_HALL_OnReceiveCustomerServiceMsg",
		function (rlt_)
			Dispatcher:Dispatch("OnReceiveCustomerServiceMsg",rlt_,nil,true)
		end
	)
end

--退款失败退款
function LobbyLogic:HandleGetReturnMoney(rlt_)
	local value = rlt_.money_safe - UserData.money_safe
	local info = string.gsub(TR("兑换失败，收到退款NNN金币"), "NNN", tostring(value / sGameManager.exchangerate))
	UserData.money_safe = rlt_.money_safe
	UserData.money = rlt_.money
    sGameManager.ShowMsgBox(info)
	Dispatcher:Dispatch(UserData)
end

--获得赠送金额
function LobbyLogic:HandleGetGivedMoney(rlt_)
	UserData.money_safe = rlt_.money_safe
	UserData.money = rlt_.money
	UserData.total_recharge = rlt_.total_recharge
	local info = string.gsub(TR("获得来自SSS赠送的NNN枚金币"), "NNN", tostring(rlt_.gift_money / sGameManager.exchangerate))
	info = string.gsub(info,"SSS",string.format("%d",rlt_.gift_account_id))
	UIManager.ShowMsgBox(info)
	Dispatcher:Dispatch(UserData)
end

function LobbyLogic:HandleGteOtherDeviceLogin(rlt_)
	--
	print("-------------HandleGteOtherDeviceLogin------------")
	LogoutLobby()
	EnterLoginPanel()
	UIManager.ShowMsgBox(TR("该账号已在其他设备登陆，您已被强制登出！！！"))
end

function LobbyLogic:HandleGteRechargeMoney(rlt_)
	UserData.money = rlt_.money
    UserData.money_safe = rlt_.money_safe
    UserData.money_gift = rlt_.money_gift
    UserData.money_gift_safe = rlt_.money_gift_safe
	local isChangeStatus = UserData.virtual_coin_status ~= rlt_.virtual_coin_status
	UserData.virtual_coin_status = rlt_.virtual_coin_status
	UserData.is_experience = rlt_.is_experience
	local old_vip_level = sGameManager.GetMyVipLevel()
	sGameManager.SetMyVipLevel(rlt_.vip_level)
	Dispatcher:Dispatch(UserData)
	if old_vip_level < rlt_.vip_level and old_vip_level == -1 then
		user.VIPLevelUpLayer.PlayVIPLevelUpEffect()
	end

	local total_recharge = rlt_.total_recharge
	if total_recharge > UserData.total_recharge then
		local WebLayer = require("hall.src.exchange.exchange.WebLayer")
		PopLayer:Close(WebLayer)

		local money = total_recharge - UserData.total_recharge
		local bFirst = ( UserData.total_recharge <= 0 )

		if Sdk then
			if bFirst then
				Sdk:firstPurchase(money)
			else
				Sdk:purchase(money)
			end
		end
		UserData.total_recharge = total_recharge
	end

	go(
		function ()
			if isChangeStatus then
				local data_ = PKG_Client_Lobby_GetPlayerInfo.Create()
				data_.token = GameData.lobbyToken
				UIManager.ShowWaiting()
				local rlt_ = gNet_SendRequest(data_)
				UIManager.HideWaiting()
				if not rlt_ then
					return
				end
				if getmetatable(rlt_) == PKG_Lobby_Client_ReqPlayerInfo then
					sGameManager.SetUserInfo(rlt_.info)
				end
			end
		end
	)
end

--审批修改绑定卡号成功，刷新卡号
function LobbyLogic:HandleGetBindCardInfo(rlt_)
	UserData.pay_channel_accounts = rlt_.pay_channel_accounts
	Dispatcher:Dispatch(UserData)
end

function LobbyLogic:HandleGenericError(rlt_)
	dump(rlt_, " ** rlt_ ** ")
	if rlt.number == -99999 then
		-- 这个是服务端踢人的协议 XD
		self:OnKicked()
	end
end

function LobbyLogic:OnKicked()
	go(function()
		if GameInst then
			GameInst:Destroy()
		end

		if gStates_Exists("CasinoLoading") then
			-- 老虎机加载页面直接杀掉会有异常情况，所以保留其界面，不退回登录界面
			sGameManager.gameState = -1
			sGameManager.pingStoped = false
			gNet:Disconnect()
			LoginData:SetAutoLogin(false)
		else
			LogoutLobby()
			EnterLoginPanel()
		end

		UIManager.ShowMsgBox(TR("你账号已经被封号，请在一分钟后重新登陆，重登不了请联系客服"),
		function()
			cc.Director:getInstance():endToLua()
		end)
	end)
end

function LobbyLogic:HandleUpdateExperienceStatus(rlt_)
	UIManager.ShowMsgBox(TR("你已充值成功，试玩金币将被系统回收"))
end

--客服主动推送聊天消息处理
function LobbyLogic:OnReceiveCustomerServiceMsg(rlt_)
	cc.UserDefault:getInstance():setBoolForKey("ServiceTips", true)
	UserData.ServiceTips = true

	if not service.ServiceLogic:IsOpenService() then
		return
	end

	local isShowContent = string.sub(rlt_.content,1,5) == "show:"
	local isShowImage_url = string.sub(rlt_.image_url,1,5) == "show:"
	local isShow = isShowContent or isShowImage_url

    local layer = PopLayer:Get(service.ServiceMailLayer)
    if not layer and isShow then        --  需要弹出
        layer = PopLayer:Pop(service.ServiceMailLayer)
    end

    if layer then
        layer:receMsg(rlt_)
    end

	if sGameManager.gameState == const_game.Lobby_State then
		local layer = BottomLayer:Get(LobbyLayer)
		if layer then
			layer:ShowMailTip(true)
			return
		end
	else
		print("Dispatch OnCustomerServiceTips")
		Dispatcher:Dispatch("OnCustomerServiceTips")
	end
end

return LobbyLogic
