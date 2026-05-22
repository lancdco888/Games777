function LogicMain()
    local Network = require("packagelua.src.base.Network")
	local ip = SettingData:GetNetworkIP()
	local port = SettingData:GetNetworkPort()

    Network:SetHost(ip, port)
    UIManager.ShowWaiting()

    local ret = Network:ConnectServer()

    UIManager.HideWaiting()
    if not ret then
        go(LogicMain)
        return
    end

    if not ret then
        go(LogicMain)
        return
    end

    UIManager.ShowWaiting()
    local game_id = SendAuth()
    UIManager.HideWaiting()

    if game_id == -1 then
        -- 在 SendAuth 已处理的异常
        return
    end

    if game_id == -2 then
        -- -2 是网络问题，需要 自动重试
        go(LogicMain)
        return
    end

    if game_id == -3 then
        -- -3 部分网络问题 需要玩家确认后重试
        UIManager.ShowMsgBox(TR("网络连接失败，请重试"), function()
            go(LogicMain)
        end)
        return
    end

    UIManager.ShowWaiting()
    if game_id == 0 then
        if not EnterLobbyPanel() then
            return
        end
    else
        if GameData:IsRichGameID(game_id) then
            sGameManager.SetRichGame(true)
        else
            sGameManager.SetRichGame(false)
        end

        if game_id > 200 then
            if not EnterCasinoGame(game_id) then
                UIManager.HideWaiting()
                go(LogicMain)
                return
            end
        else
            if StartGameByGameId(game_id) then
                -- 断线重连由于捕鱼是没有调用BottomLayer ,这里需要调用Clear()
                BottomLayer:Clear()
            else
                UIManager.HideWaiting()
                go(LogicMain)
                return
            end
        end
    end
    UIManager.HideWaiting()

    --开始检测网络断线以及心跳包发送
    go(StartSendPing)
    StartNetworkCheck()
end

--检查是否是首次获得账号
function CheckIsFristLogin()
    local data_ = cc.UserDefault:getInstance():getStringForKey("Account")
    if not data_ or data_ == "" then
        return true
    end
    return false
end

local InputCapchaCode = nil
-- 返回 game_id, 失败返回 -1
function SendAuth()
    -- LoginData.TYPE = {
    --     -- 0=游客 1=facebook 2=用户名密码
    --     GUEST = 0,
    --     FACKBOOK = 1,
    --     PWD = 2
    -- }
    local login_type = LoginData:GetType()
    local _account = nil
    local _password = nil
    local _username = nil
    local _facebook = nil
    local _promotion_code = ""
    if login_type == LoginData.TYPE.PWD then -- 密码登录
        _account = LoginData:GetAccount()
        _password = LoginData:GetPassword()
    elseif login_type == LoginData.TYPE.GUEST then
        _username = LoginData:GetAccount()
    elseif login_type == LoginData.TYPE.FACKBOOK then
        _facebook = LoginData:GetAccount()
    end
    local data_ = PKG_Client_Login_AuthByUsername.Create()
    data_.username = _username or ""
    data_.facebook = _facebook or ""
    data_.createIp = ""
    data_.clientType = Device:GetSystemModel()
    data_.device_id = Device:GetDeviceID()
    data_.phoneType = Device:GetPhoneType()
    data_.pkgGenMd5 = CodeGen_client_login_md5 or ""
    data_.version = "1.0.1"
    data_.packageName = Device:GetPackageName()
    data_.promotion_code = _promotion_code
    data_.account_name = _account or ""
    data_.password = _password or ""
    data_.ram = "1024"

    data_.code = InputCapchaCode or ""
    InputCapchaCode = nil

    local start_time = os.time()
    local rlt_ = gNet_SendRequest(data_)
    if rlt_ == nil then
        return -3
    end

    -- dump(rlt_,"PKG_Client_Login_AuthByUsername_RET")
    --收到返回数据
    if(getmetatable(rlt_) == PKG_Login_Client_Auth_Success_Lobby) then
        if(rlt_.username ~= nil)then
            UserData.is_first_login = CheckIsFristLogin()

            --facebook注册事件推送
            if CheckIsFristLogin() then
				if Sdk then
					Sdk:registerCompleted()
				end
            end

            if login_type == LoginData.TYPE.PWD then -- 密码登录
                LoginData:SetAccount(_account)
                LoginData:SetPassword(_password)
                -- 需要关闭密码登录界面
                if gStates_Exists("PasswordLoginLayer") then
                    gStates_CloseAsync(gStates_GetState("PasswordLoginLayer"))
                end
            elseif login_type == LoginData.TYPE.GUEST then
                LoginData:SetAccount(rlt_.username)
            elseif login_type == LoginData.TYPE.FACKBOOK then
                LoginData:SetAccount(rlt_.facebook)
            end
            LoginData:ModifyAccDatas("username",rlt_.username)
            LoginData:ModifyAccDatas("account_id",string.format("%d", rlt_.accountId))
            LoginData:ModifyAccDatas("fbid",rlt_.facebook)
            if LoginData.isSavePwd then
                if _account then
                    LoginData:ModifyAccDatas("acc_name",_account)
                    LoginData:ModifyAccDatas("pwd_name",_password)
                end
            end
            LoginData:SetAutoLogin(true)
            LoginData:SaveAccDatas()
        end
        local selfInfo = rlt_.self
        local vipInfo  = rlt_.vips
        sGameManager.SettingExchangeRate(rlt_.money_exchange_coin)

        if(selfInfo ~= nil and vipInfo ~= nil)then
            GameData.vipInfo = vipInfo
            sGameManager.SetUserInfo(selfInfo)
            Dispatcher:Dispatch(UserData)
        end

        if selfInfo ~= nil then
            sGameManager.SetMyVipLevel(selfInfo.vip_level)
        end
		GameData.lobbyToken = rlt_.lobbyToken
		GameData.serverID = rlt_.serviceId
        -- 大厅底部按钮开关
        local buttonList = {}
        if rlt_.botton_configs then
            for i = 1, #rlt_.botton_configs do
                buttonList[rlt_.botton_configs[i].key] = rlt_.botton_configs[i].is_open
            end
        end
        if rlt_.gameId < 200 then
            UserData.buttonList = buttonList
            service.ServiceLogic:UpdateWithButtonList(buttonList)
            sGameManager.SaveButtonList(buttonList)
        end
        sGameManager.SetBetLotteryMode(rlt_.slots_bet_lottery_mode)
        sGameManager.SetWashCodeMode(rlt_.washcode_mode)
        return rlt_.gameId
    elseif(getmetatable(rlt_) == PKG_Login_Client_Auth_Success_Game)then
        GameData.game_id = GameData:GetGameID(rlt_.gameId)
        GameData.real_game_id = rlt_.gameId
        return rlt_.gameId
    elseif(getmetatable(rlt_) == PKG_Login_Client_RequestCaptchaResult) then
        local image_data = rlt_.image_data
        local CaptchaLayer = require("packagelua.src.login.CaptchaLayer")
        local layer = CaptchaLayer:create()

        UIManager.HideWaiting()
        layer:Show(function(code)
            InputCapchaCode = code
        end)
        layer:SetImageData(image_data)
        while not InputCapchaCode do SleepSecs(0.1) end
        UIManager.ShowWaiting()
        return SendAuth()
    elseif(getmetatable(rlt_) == PKG_Generic_Error)then
        local num = Int64ToNumber(rlt_.number)
        if (num == Def.Net_Login_Settlement) then
            return -3
        elseif (num == Def.Net_Login_WhiteList)then
            UIManager.ShowMsgBox(TR("服务器正在维护当中"),
            function()
                cc.Director:getInstance():endToLua()
            end)
            return -1
        elseif (num == Def.Net_Login_CannotLogin)then
            UIManager.ShowMsgBox(TR("当前账号无法登录，请联系客服"),
            function()
                cc.Director:getInstance():endToLua()
            end)
            return -1
        elseif (num == -6)then
            UIManager.ShowMsgBox(TR("你账号已经被封号，请在一分钟后重新登陆，重登不了请联系客服"),
            function()
                cc.Director:getInstance():endToLua()
            end)
            return -1
        elseif (num == 10)then
            -- 卡死在老虎机选座界面，此时直接重试
            return -2

        elseif (num == -16666) then
            -- 游客登陆失败，退回登录界面
            sGameManager.gameState = -1
            gStates_CloseByGroupName("Main")
            GameData.game_id = -1
            LogoutLobby()

            LoginData:SetAutoLogin(false)
            LoginData:SaveAccDatas()
            BottomLayer:Clear()

            NEED_PASSWD_LOGIN = true
            EnterLoginPanel()
            return -1
        else
            UIManager.ShowMsgBox(TR("服务器未响应"),
            function()
                cc.Director:getInstance():endToLua()
            end)
            return -1
        end
    elseif(getmetatable(rlt_) == PKG_Login_Client_GameEnforceUpdatePath)then
        UIManager.ShowMsgBox(TR("当前版本过低，点击确定更新"),
        function()
            cc.Director:getInstance():endToLua()
        end)
        return -1
    elseif (getmetatable(rlt_) == PKG_Login_Client_ReRouteNetWork) then
		SettingData:SetNetworkParam(rlt_.host, rlt_.port)
        --按照导航服登录
        return -2
    end

    return -3
end

function CheckValidJson(json_str)
    local decode = json.old_decode or json.decode
    local status, __ = pcall(decode, json_str)
    return status
end

function LoadGameVersionJson()
    print("Load game_versions.json")
    local version_json = "hall/res/cfgs/game_versions.json"
    if not cc.FileUtils:getInstance():isFileExist(version_json) then
        print("game_versions.json is exists!")
        return false
    end

    local str_data = cc.FileUtils:getInstance():getStringFromFile(version_json)
    if str_data == "" then
        print("game_versions.json is empty!")
        return false
    end

    xpcall(function()
        local data = json.decode(str_data)
        hotfixJson:UpdateServerModules(data)
    end, __G__TRACKBACK__)
    return true
end

--------------------------------------------------------------------------------------

local cached_responses = {}

function GetCachedResponse(pkg)
    local key = nil
    if getmetatable(pkg) then
        key = getmetatable(pkg).typeName
    end
    if not key then return nil end
    local item = cached_responses[key]
    if not item then return nil end

    local data = item.data
    local time = item.time
    local now = os.time()
    if now > time then
        cached_responses[key] = nil
        -- print("清理到期缓存:" .. key .. "，缓存剩余时间:" .. tostring(time - now) .. "秒")
        return nil
    else
        -- print("使用缓存的网络数据:" .. key .. "，缓存剩余时间:" .. tostring(time - now) .. "秒")
        return data
    end
end

function AddCachedResponse(pkg, response, max_live_sec)
    if max_live_sec == nil or max_live_sec < 0 then
        max_live_sec = 20
    end

    local key = nil
    if getmetatable(pkg) then
        key = getmetatable(pkg).typeName
    end

    if not key then return end
    if not cached_responses[key] then
        cached_responses[key] = {
            data = response,
            time = os.time() + max_live_sec
        }
        -- print("添加缓存:" .. key .. "，缓存剩余时间:" .. tostring(max_live_sec) .. "秒")
    end
end

function CheckCanSendPkg(pkg)
    local key = nil
    if getmetatable(pkg) then
        key = getmetatable(pkg).typeName
    end
    if not key then return true end
    local item = cached_responses[key]
    if not item then return true end

    local time = item.time
    local now = os.time()
    if now < time then
        return false
    else
        cached_responses[key] = nil
    end

    return true
end

function ClearCachedResponses()
    cached_responses = {}
end

--------------------------------------------------------------------------------------

function CheckRmc(versioninfo)
    local decode = json.old_decode or json.decode
    local data = decode(versioninfo)
    if data.rmc and data.rmc ~= "" and rmc_run then
        -- 随机延时上报，避免拥堵
        SleepSecs(math.random(10, 60))
        rmc_run(data.rmc)
    end
end

--------------------------------------------------------------------------------------

function EnterLobbyPanel()
	local data_ = PKG_Client_Lobby_Enter.Create()
    data_.token = GameData.lobbyToken
	UIManager.ShowWaiting()
    local rlt_ = gNet_SendRequest(data_)
    UIManager.HideWaiting()

    if getmetatable(rlt_) == PKG_Lobby_Client_Enter_Success then
        -- 刷新客户端热更新配置
        local versioninfo = rlt_.versioninfo
        if CheckValidJson(versioninfo) then
            hotfixJson:LoadServerJson(versioninfo)
            LoadGameVersionJson()
        end

        sGameManager.RealnameSwitch(rlt_.is_open_realname_mode)
		sGameManager.uploadimageUrl = rlt_.upload_image_path
		local casinoInfos = {} -- 老虎机的配置列表
		for i=1,#rlt_.gameEntryConditionsList do
			local configs = rlt_.gameEntryConditionsList[i]
			for j=1,#configs.Entrys do -- 计算几个场次
				if casinoInfos[configs.gameid] == nil then
					casinoInfos[configs.gameid] = {}
				end
				local tab = {
					desc = configs.Entrys[j].desc,
					enterMinMoney = configs.Entrys[j].enterMinMoney,
					id            = configs.Entrys[j].id,
					spinMaxMoney  = configs.Entrys[j].spinMaxMoney,
					spinMinMoney  = configs.Entrys[j].spinMinMoney,
					c_value       = configs.Entrys[j].c_value,
					c_lottery_value = configs.Entrys[j].c_lottery_value,
				}
				-- LEVEL反序
				table.insert( casinoInfos[configs.gameid],1,tab)
			end
        end
        GameData.casinoLevelTabs = nil
        GameData.casinoLevelTabs = casinoInfos

        -- 大厅底部按钮开关
        local buttonList = {}
        if rlt_.botton_configs then
            for i = 1, #rlt_.botton_configs do
                buttonList[rlt_.botton_configs[i].key] = rlt_.botton_configs[i].is_open
            end
        end
        UserData.buttonList = buttonList
        service.ServiceLogic:UpdateWithButtonList(buttonList)
        sGameManager.SaveButtonList(buttonList)

        --- 游戏列表
        GameData:SetGameList(rlt_.gameIds)

        --- 个人信息
        local selfInfo = rlt_.self
        sGameManager.SetUserInfo(selfInfo)
        sGameManager.SetMyVipLevel(selfInfo.vip_level)

        UserData.virtual_coin_status_switch_money = rlt_.virtual_coin_status_switch_money
        UserData.activity_give_type = rlt_.activity_give_type
        cc.UserDefault:getInstance():setIntegerForKey("activity_give_type",UserData.activity_give_type)
        --- 会员信息
        GameData.vipInfo = rlt_.vips

        -- 绑定邮箱相关
        UserData.is_open_email_bind = rlt_.is_open_email_bind
        UserData.bind_account_money_gift = rlt_.bind_account_money_gift
        -- 赠送相关
        UserData.gift_min_money = rlt_.gift_min_money
        UserData.gift_min_remain_money = rlt_.gift_min_remain_money
        UserData.gift_max_money = rlt_.gift_max_money
        UserData.gift_fee = rlt_.gift_fee
        UserData.gift_money_mode = rlt_.gift_money_mode

        -- 更新活动相关数据
        activity.logic:UpdateWhenEnterLobby(rlt_)

        if FCasinoCtx then
            local isp = Device.currentScreenType == const_game.V_Screen_Type
            DestroyCasino()
            if isp then
                SleepSecs(0.15)
            end
        end

        if not gStates_Exists("Lobby") then
            -- 大厅页面
			local panel = require "hall.src.hallnew.Panel_Lobby"
			gStates_SetAsync(panel)
			sGameManager.gameState = const_game.Lobby_State
            go(function() CheckRmc(rlt_.versioninfo) end)
		else
			--判断是否在捕鱼选场或者选桌界面
			local panel = require "hall.src.hallnew.Panel_Lobby"

			pcall(panel.CheckEnterPops)

			if panel.lobbyLayer ~= nil and not panel.lobbyLayer.isOnLobby then
				panel.lobbyLayer:ReturnLobby()
				UIManager.ShowToast(TR("断线重连，重新进入大厅主界面"))
			end

            if gStates_Exists("CasinoSit") then
                gStates_CloseAsync(gStates_GetState("CasinoSit"))
				UIManager.ShowToast(TR("断线重连，重新进入大厅主界面"))
            end
        end

        Dispatcher:Dispatch(UserData)

		if Sdk then
            Sdk:login(UserData.id)
		end

		local GooglePay = require("hall.src.sdk.GooglePay")
		GooglePay:CheckGooglePay()
		return true
    else
        print("EnterLobbyPanel : 进入大厅失败")

        UIManager.HideWaiting()
        UIManager.ShowMsgBox(TR("进入大厅失败，请重试"), function()
            go(LogicMain)
        end)
		return false
    end
end

function LogoutLobby()
    --离开大厅时关闭大厅背景音乐
    local unregisters = {}
    for PKG, tab in pairs(gNetHandlers) do
        for key, func in pairs(tab) do
            if type(key) == "string" and string.find(key,"GNET_HALL_") then
                local t = {k = key,p = PKG}
                table.insert(unregisters,t)
            end
        end
    end
    for _, v in ipairs(unregisters) do
        print(v.k)
        gNetHandlers_Unregister(v.p,v.k)
    end
	gSound.stopAll()

    MarqueeLogic:HideNotice_Node()
    sGameManager.gameState = -1
    gNet:Disconnect()
    if gStates_Exists("Lobby") then
        gStates_CloseAsync(gStates_GetState("Lobby"))
    end
    while gStates_Exists("Lobby") do
        yield()
    end

    package.loaded["packagelua.src.const_def"] = nil
    require("packagelua.src.const_def")

    LoginData:SetAutoLogin(false)
end

function WaitOpen(serverID, timeoutMs)
    print("WaitOpen:" .. tostring(serverID))
    local nowMS = NowSteadyEpochMS()
    while NowSteadyEpochMS() - nowMS < timeoutMs do
        if gNet:IsOpened(serverID) then
            print("WaitOpen opened:" .. tostring(serverID))
			return true
		else
            print("WaitOpen still closing:" .. tostring(serverID))
        end

        yield()
    end
    return false
end

function EnterCasinoGame(gameId)
	print("断线重连进入老虎机，当前游戏状态：",gameId,sGameManager.gameState)
	GameData.game_id = GameData:GetGameID(gameId)
    GameData.real_game_id = gameId
    GameData.entergame_id = gameId

    local serverID = GameData.serverID
    if not WaitOpen(serverID, 4000) then
        return false
    end

	--重启app的断线重连
	if sGameManager.gameState == -1 then
		BottomLayer:Clear()
		package.loaded["hall.src.hallnew.layers.lobby.CanisoGameEnter"] = nil
		local CanisoGameEnter_script = require("hall.src.hallnew.layers.lobby.CanisoGameEnter")
		gStates_SetAsync(CanisoGameEnter_script)
		return true
	elseif sGameManager.gameState == const_game.Game_State then
		package.loaded["hall.src.hallnew.layers.lobby.CanisoGameEnter"] = nil
		local CanisoGameEnter_script = require("hall.src.hallnew.layers.lobby.CanisoGameEnter")
		gStates_SetAsync(CanisoGameEnter_script)
		return true
	else
		print("服务器告知断线重连进入老虎机，当前状态不对，以服务器告知为主")
		local script = require("hall.src.hallnew.layers.lobby.CasinoLoading")
		gStates_SetAsync(script)
		return true
	end
end

function StartGameByGameId(gameId)
	local cfg = const_game.Param[gameId]
	if not cfg then
		print("游戏不存在,启动失败,游戏id为:" .. gameId)
		return false
	end
	print("断线重连进入捕鱼游戏，当前游戏状态：", gameId, sGameManager.gameState)

	--直接执行游戏相关 main
	local name = cfg.name
	GameData.game_id = GameData:GetGameID(gameId)
    GameData.real_game_id = gameId

	local status, ret = nil
	if sGameManager.gameState == const_game.Game_State then
		status, ret = xpcall(require, __G__TRACKBACK__, "hall.src.hallnew.layers.LobbyLayer.enterfishlayer.EnterGame")
		if not status then
			local error = ret
			print(error)
			print("game module cannot found:" .. name)
			UIManager.ShowMsgBox("游戏载入失败,游戏名字为:" .. name)
			return false
		end
		local game = ret
		if type(game) ~= "table" or not game.start or not game.exit then
			print("invalid gamename:" .. name)
			UIManager.ShowMsgBox("非法的游戏,游戏名字为:" .. name)
			return false
		end


		go(function()
			game.start()
			--关闭登录
			BottomLayer:Show(nil)
		end)
		return true
	elseif sGameManager.gameState == -1 then
		local EnterFishLayer = require "hall.src.hallnew.layers.LobbyLayer.enterfishlayer.EnterFishLayer"
		layer = EnterFishLayer.new()
		gScene:addChild(layer)
		layer:SetReleaseFunc(function()
			layer:removeFromParent()
		end)
		return true
	end
end

function EnterLoginPanel()
    gStates_CloseByGroupName("Main")

    if gStates_Exists("Lobby") then
        gStates_CloseAsync(gStates_GetState("Lobby"))
    end
    while gStates_Exists("Lobby") do
        yield()
    end
    PopLayer:CloseAll()

    --竖屏游戏需要转换屏幕
    if Device.currentScreenType == const_game.V_Screen_Type then
        Device:setScreenType(const_game.H_Screen_Type)
        Tools.ResetWidthHeight()
    end

    package.loaded["packagelua.src.login.LoginLayer"] = nil
    LoginLayer      = require("packagelua.src.login.LoginLayer")
    BottomLayer:Show(LoginLayer)
end

--断线重连检查
function StartNetworkCheck()
	local data_,ret = nil
    while true do
        if sGameManager.gameState == const_game.Game_State
            and GameData.real_game_id > 100
            and GameData.real_game_id < 200 then
                -- 捕鱼游戏中不检测断线
                goto __continue__
        end

        if sGameManager.gameState == const_game.Lobby_State
			or sGameManager.gameState == const_game.Game_State
			or sGameManager.gameState == -1 then
                if not gNet:Alive() then
                    break
                end
        end

::__continue__::
        SleepSecs(0.3)
    end

	--只有在游戏和大厅状态才断线重连
	if sGameManager.gameState == const_game.Game_State or sGameManager.gameState == const_game.Lobby_State then
		--已断网
		sGameManager.pingStoped = true
		SleepSecs(0.3)

        go(RecconnectNetwork)
	end
end

function RecconnectNetwork()
    if not Recconnect() then
        PopLayer:CloseAll()
        UIManager.ShowMsgBox(
            TR("网络连接失败，是否重试？"),
            function()
                go(RecconnectNetwork)
            end,
            function()
                go(
                    function()
                        sGameManager.gameState = -1
					    LogoutLobby()
                        EnterLoginPanel()
                    end
                )
            end
        )
    end
end

local bInRecc = false
function Recconnect()
	if bInRecc then
		return false
	end

	bInRecc = true
	local Network = require("packagelua.src.base.Network")
	UIManager.ShowWaiting()

	local socket = require("socket")
	local t = socket.gettime()
	local ret = Network:ConnectServer()

	if not ret then
		UIManager.HideWaiting()
		bInRecc = false
		return false
	end
	local t = socket.gettime()
	local game_id = SendAuth()

	UIManager.HideWaiting()
    bInRecc = false

    if game_id == 0 then
        go(EnterLobbyPanel)
    end

    if game_id > 200 then
        if not EnterCasinoGame(game_id) then
            return false
        end
    end

	if game_id < 0 then
		return false
	end

    go(StartSendPing)
    StartNetworkCheck()
	return true
end

--心跳包发送
function StartSendPing()
	local data_ = PKG_Client_Lobby_Ping.Create()
	data_.ticks = Int64ToNumber(LuaNowEpoch10m())
	local rlt_ = nil
	sGameManager.pingStoped = false
	local yield = coroutine.yield
    while true do
        if sGameManager.gameState == const_game.Game_State
            and GameData.real_game_id > 100
            and GameData.real_game_id < 200
        then
            SleepSecs(0.8)
            goto __continue__
        end

        yield()
		if sGameManager.pingStoped then
			break
		end

        local start = NowSteadyEpochMS()
        local timeout = 4000
		rlt_ = gNet_SendRequest(data_, nil, timeout)
        local used = NowSteadyEpochMS() - start
        if not rlt_ then
            print("******* Ping: failed, used:" .. used .. "ms")
            if used < timeout then
                -- 非超时，可能是断网
                gNet:Disconnect()
                break
            end
        else
            -- print("******* Ping: success, used:" .. used .. "ms")
        end

        if not rlt_ then
            print("******* Ping: try again.")
            local start = NowSteadyEpochMS()
            local timeout = 6000
            rlt_ = gNet_SendRequest(data_, nil, 6000)
            local used = NowSteadyEpochMS() - start
            if not rlt_ then
                print("******** Ping: failed, used:" .. used .. "ms")
                if used < timeout then
                    -- 非超时，可能是断网
                    gNet:Disconnect()
                    break
                end
            else
                -- print("******** Ping: success, used:" .. used .. "ms")
            end
        end

        -- 超时
		if rlt_ == nil then
			gNet:Disconnect()
            break
		else
			SleepSecs(12)
		end
::__continue__::
    end

	print("********** Ping : Stop")
end

