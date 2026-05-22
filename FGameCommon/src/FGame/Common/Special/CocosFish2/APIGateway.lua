-- 游戏内部引用大厅相关接口的都使用 APIGateway 统一中转

-- Debug 设置
if device then
    FConfig.Debug = device.platform == "windows" or device.platform == "mac"
else
    FConfig.Debug = false
end

APIGateway = {}

-- @brief 播放音效
-- @param path 音效资源地址
-- @param loop 是否循环播放
-- @return 该接口必须返回一个可供操作当前音效的句柄
function APIGateway.PlaySound(path, loop)
    return gSound.playEffect(path, loop)
end

-- @brief 停止播放音效
-- @param handle 音效句柄
function APIGateway.StopSound(handle)
    if handle == nil then return end
    gSound.stopEffect(handle)
end

-- @brief 设置音效音量大小 取值范围[0,1]
-- @param handle APIGateway.PlaySound返回的对象
function APIGateway.SetSoundVolume(handle, volume)
    if handle == nil then return end

    -- 如果背景音乐是关闭状态，则不允许修改背景音乐音量
    if gSound.getBgmSoundID() == handle and not gSound.isMusicOn() then
        return
    end

    -- 如果音效是关闭状态，也不允许修改音量
    if not APIGateway.IsSoundEnable() then
        return
    end

    ccexp.AudioEngine:setVolume(handle, volume)
end

function APIGateway.PlayBGM(path)
    return gSound.playBgm(path)
end

function APIGateway.StopBGM()
    gSound.stopBgm()
end

-- @brief 是否开启音效
function APIGateway.IsSoundEnable()
    return gSound.isEffectOn()
end

-- @brief 设置是否开启音效
function APIGateway.SetSoundEnable(value)
    return gSound.setEffectOn(value)
end

-- @brief 获取大厅中的数据集合
-- @return table
function APIGateway.GetLobbyData()
    local casinoExchangeRate = 1
    if GameData.exchangeCoinRatio then
        casinoExchangeRate = GameData.exchangeCoinRatio
    else
        if sGameManager.curLevel and sGameManager.curLevel.c_value then
            casinoExchangeRate = sGameManager.curLevel.c_value
        end
    end

    local c_levelOpen = sGameManager.CheckNeedPopCasinoLevel()

    return {
        -- 是否开启绑定金
        bindGoldCoinEnabled = sGameManager.IsBindCodeOpen(),
        -- 当前玩家是否是VIP
        playerIsVIP = sGameManager.GetMyVipLevel() >= 0,
        -- 大厅汇率
        lobbyExchangeRate = sGameManager.exchangerate,
        -- 游戏汇率
        gameExchangeRate = casinoExchangeRate,
        -- 彩金显示模式 根据押注
        isLotteryBetMode = sGameManager.GetBetLotteryMode(),
        -- 大厅界面选择的押注(C位)信息
        curSlotsLevel = sGameManager.curLevel,
        -- 选C限制是否开启（如果关闭则所有C都可以选）
        isCasinoLevelOpen = c_levelOpen,
        -- 洗码模式 0=常规洗码 1=必须有压住的金币才能洗码
        washCodeMode = sGameManager._washcode_mode,
        -- 游戏原始id
        rawGameId = GameData.game_id
    }
end

-- @brief 获取游戏重连数据
function APIGateway.GetGameReconnectData()
    if sGameManager.NetRestoreCasino then
        sGameManager.NetRestoreCasino = false
        return FGamePkgHubIns:Pkg2Pb(sGameManager.NetRestoreCasinoRlt)
    end
end

-- @brief 显示一个消息弹窗
-- @param content 内容文本
-- @param onOkCallback 确认回调
-- @param onCancelCallback 取消回调
function APIGateway.ShowMessageBox(content, onOkCallback, onCancelCallback)
    local msgbox = UIManager.ShowMsgBox(content, onOkCallback, onCancelCallback)
    if APIGateway.IsDeviceOrientationPortrai() then
        msgbox:setScale(1.4)
    end
end

-- @brief 打开设置界面
function APIGateway.OpenSettingPanel()
    local layer = PopLayer:Pop(SetUpLayer)
    layer:ShowLangSelect(false)
    if APIGateway.IsDeviceOrientationPortrai() then
        layer:setScale(1.4)
    end
end

-- @brief 打开客服界面
function APIGateway.OpenServicePanel()
    local Panel_ServiceMail = require("hall.src.hallnew.layers.lobby.service.Panel_ServiceMail")
    Panel_ServiceMail.default_ui_type = ServiceMailLogic.SERVICE
    gStates_SetAsync(Panel_ServiceMail)
end

-- @brief 获取当前文本的多语言翻译文本
function APIGateway.GetLangText(key)
    local defaultText = FConfig.Lang[key]
    local value = TR(key)
    if value == key then
        return defaultText
    end
    return value
end

-- @brief 从游戏返回大厅
function APIGateway.EnterLobby()
    go(function()
        sGameManager.isCasinoLoaded = false
        sGameManager.gameState = const_game.Lobby_State

        PopLayer:CloseAll()

        local waitRotate = false
        --竖屏游戏需要转换屏幕
        if APIGateway.IsDeviceOrientationPortrai() then
            Device:setScreenType(const_game.H_Screen_Type)
            Tools.ResetWidthHeight()
            waitRotate = true
        end

        if waitRotate then
            SleepSecs(0.30)
        else
            SleepSecs(0.05)
        end

        local loading_layer = LoadingLayer.new()
        local scene = cc.Director:getInstance():getRunningScene()
        scene:addChild(loading_layer)

        if waitRotate then
            SleepSecs(0.1)
        end

        EnterLobbyPanel()

        loading_layer:removeFromParent()
    end)
end

function APIGateway.SendPush(msg)
    local pkg = FGamePkgHubIns:Pb2Pkg(msg)
    gNet_SendPush(pkg)
end

-- @brief 向游戏服发送一个消息
function APIGateway.SendRequest(msg, callback)
    local pkg = FGamePkgHubIns:Pb2Pkg(msg)
    
    go(function()
        local result = gNet_SendRequest(pkg)
        if result then
            result = FGamePkgHubIns:Pkg2Pb(result)
        end

        if FCasinoCtx and callback then
            callback(result ~= nil, result)
        end
    end)
    FSysEventEmitter:Emit(FSysEvent.ON_SEND_REQUEST)
end

-- @brief 向游戏服发送一个消息,如果请求失败或请求结果不是期望值，直接断线
function APIGateway.SendExactRequest(msg, resultMsgName, callback)
    APIGateway.SendRequest(msg, function(ok, pkg)
        if ok and pkg._msgName_ == resultMsgName then
            callback(true, pkg)
        else
            callback(false)
            APIGateway.Disconnect()
        end
    end)
end

local function wholeCloneNoRef(orig)
    local function _copy(orig)
        if type(orig) ~= "table" then
            return orig
        end
        local newObject = {}
        for key, value in pairs(orig) do
            if key ~= "__proto" then
                newObject[_copy(key)] = _copy(value)
            end
        end
        return newObject
    end
    return _copy(orig)
end

-- @callback: (msg: table)
local msgs = {
    [ "PB.Support_Other.OneGameLotteryRet" ] = PKG_Support_Other_OneGameLotteryRet,
    [ "PB.Slots_Client.OfflineCheck" ] = PKG_Slots_Client_OfflineCheck,
    [ "PB.Slots_Client.Leave_Success" ] = PKG_Slots_Client_Leave_Success,
    [ "PB.Lobby_Client.ReturnLobby" ] = PKG_Lobby_Client_ReturnLobby
}
function APIGateway.AddSubscriber(msgName, callback, target)
    local pkg = msgs[msgName]
    if not pkg then
        local msg = "Dont Support this msg:" .. msgName
        UIManager.ShowToast(msg)
        print(msg)
        return
    end

	gNetHandlers_Register(pkg, target, function(data)
        if callback then 
            local msg = wholeCloneNoRef(data)
            if msg then
                msg._msgName_ = msgName
            end
            callback(msg)
        end
    end)
end

function APIGateway.RemoveSubscriber(msgName, callback)
    assert(false, "cocos 暂不支持")
end

function APIGateway.RemoveAllSubscribers(target)
    gNetHandlers_UnregisterKey(target)
end

-- @brief 断开游戏连接
function APIGateway.Disconnect()
    FSysEventEmitter:Emit(FSysEvent.ON_NET_DISCONNECT)
    -- gNet_Reset()
    gNet:Disconnect()
end


function APIGateway.ParticleEffectFadeOut(particle, duration, delayTime)
    particle:setCascadeOpacityEnabled(true)
    particle:runAction(cc.Sequence:create(cc.DelayTime:create(delayTime), cc.FadeOut:create(duration)))
end

-- @brief 播放粒子特效
-- @return 装载器  原始粒子指针
function APIGateway.PlayParticleEffect(path, loader3D)
    path = string.gsub(path, "\\", "/")
    local particle = cc.ParticleSystemQuad:create(path .. ".plist")
    if particle == nil then
        print("Particle effects creation failed:", path)
        return
    end

    particle:setPosition(loader3D.width * 0.5, -loader3D.height * 0.5)
    -- 更新url，让底层调用clearContent函数清理之前的节点
    loader3D.url = tostring(particle)
    loader3D.content = particle
    
    return particle
end

-- @brief 停止播放粒子特效
function APIGateway.StopParticleEffect(particle)
    if tolua.isnull(particle) then return end
    particle:stop()
end

-- @brief 重播粒子特效
function APIGateway.ReplayParticleEffect(particle)
    if tolua.isnull(particle) then return end
    particle:start()
end

-- @brief 判断对象是否是无效对象
function APIGateway.IsInvalidObject(obj)
    return tolua.isnull(obj)
end

local inFSlot = false
function APIGateway.InFSlot()
    return inFSlot
end

function APIGateway.OnEnter()
    inFSlot = true
end

function APIGateway.OnDestroy(fairyRoot)
    inFSlot = false
    
    local fSlotLua = {}
    for k, _ in pairs(package.loaded) do
        local isGamePrivateRes = string.find(k, "FGame[.]Game") == 1
        local isGameCommonRes = string.find(k, "FGame[.]Common") == 1
        local isWebmPreloadRes = string.find(k, "%.Webm%.preload") ~= nil
        
        if isGameCommonRes or isGamePrivateRes or isWebmPreloadRes then
            table.insert(fSlotLua, k)
        end
    end
    for _, v in ipairs(fSlotLua) do
        package.loaded[v] = nil
    end
end

function APIGateway.OnUpdate()
end

function APIGateway.SetModuleName(moduleName)
end 

-- @brief 判断设备是否处于竖屏状态
function APIGateway.IsDeviceOrientationPortrai()
    return Device.currentScreenType == const_game.V_Screen_Type
end

-- @brief VIP升级
function APIGateway.ShowVipUpInSlots(spinData)
    -- TODO
end

-- webm 相关
local WebmHelper = require("FGame.Common.Special.Cocos.Webm.WebmHelper")
APIGateway.CreateWebmAndBindToGImage = WebmHelper.CreateWebmAndBindToGImage
APIGateway.CreateAllWebmWithRObject = WebmHelper.CreateAllWebmWithRObject

-- 0-255 
function APIGateway.color4(color)
    return {r = color.r, g = color.g, b = color.b, a = color.a}
end

-- @brief 获取当前国家(导航服返回的地区字段)
function APIGateway.GetCurRegion()
    return ConfigParam.Region
end

---GObject对象 添加事件
---@param aType string 事件名
---@param aCallback function 回调函数
---@param aOverride boolean 如果已经存在一个同名事件,是否覆盖
---@return void
function APIGateway.AddEventListener(aObj, aType, aCallback, aOverride)
    if aObj == nil or aType == nil or aCallback == nil then return end
    if aOverride then
        APIGateway.RemoveEventListeners(aObj, aType)
    end

    aObj:AddEventListener(aType, aCallback)
end

---GObject对象 删除事件
---@param aObj table GObject对象
---@param aType string 事件名
---@return void
function APIGateway.RemoveEventListeners(aObj, aType)
    if aObj == nil or aType == nil then return end
    aObj:RemoveEventListener(aType)
end
