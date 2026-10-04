-- 游戏内部引用大厅相关接口的都使用 APIGateway 统一中转

-- Debug 设置
if device then
    if type(isShowDebugInfo) == "function" and isShowDebugInfo() then
        FConfig.Debug = true
    else
        FConfig.Debug = device.platform == "windows" or device.platform == "mac"
    end
else
    FConfig.Debug = false
end


local GameProtocolHub = require("FGame.Common.Special.Creator.DataHub.GameProtocolHub")

APIGateway = {}

---@type boolean 游戏金币显示是否强制取整
-- FConfig.Common.GameScoreForceToInt = false

---@type boolean 点击加减押注是否可以改变选C
FConfig.Common.BetStepChangeCLevel = true

---@type boolean 显示选C菜单
FConfig.Common.ShowBetCLevelMenu = false

local GameHelper = nil

-- @brief 播放音效
-- @param path 音效资源地址
-- @param loop 是否循环播放
-- @return 该接口必须返回一个可供操作当前音效的句柄
function APIGateway.PlaySound(path, loop)
    return gSound:playEffect(path, loop)
end

-- @brief 停止播放音效
-- @param handle 音效句柄
function APIGateway.StopSound(handle)
    if handle == nil then return end
    gSound:stopEffect(handle)
end

-- @brief 设置音效音量大小 取值范围[0,1]
-- @param handle APIGateway.PlaySound返回的对象
function APIGateway.SetSoundVolume(handle, volume)
    if handle == nil then return end

    -- 如果背景音乐是关闭状态，则不允许修改背景音乐音量
    if gSound:getBgmSoundID() == handle and not gSound.bMusic then
        return
    end

    -- 如果音效是关闭状态，也不允许修改音量
    if not APIGateway.IsSoundEnable() then
        return
    end

    cc.AudioEngine:setVolume(handle, volume)
end

function APIGateway.PlayBGM(path)
    return gSound:playBgm(path)
end

function APIGateway.StopBGM()
    gSound:stopBgm()
end

-- @brief 是否开启音效
function APIGateway.IsSoundEnable()
    return gSound.bEffect
end

-- @brief 设置是否开启音效
function APIGateway.SetSoundEnable(value)
    gSound:setSoundSwitch(value)
    gSound:saveCfg()
end

-- @brief 获取大厅中的数据集合
-- @return table
function APIGateway.GetLobbyData()
    return {
        -- 是否开启绑定金
        bindGoldCoinEnabled = GameHelper:bindGoldCoinEnabled(),
        -- 当前玩家是否是VIP
        playerIsVIP = GameHelper:isVIP(),
        -- 大厅汇率
        lobbyExchangeRate = GameHelper:getExchangerate(),
        -- 游戏汇率
        gameExchangeRate = GameHelper:getGameExchangerate(),
        -- 彩金显示模式 根据押注
        isLotteryBetMode = GameHelper:isLotteryBetMode(),
        -- 大厅界面选择的押注(C位)信息
        curSlotsLevel = GameHelper:getCurSlotsLevel(),
        -- 选C限制是否开启（如果关闭则所有C都可以选）
        isCasinoLevelOpen = cc.UserDefault:getInstance():getBoolForKey("key_game_casino_level_open", false),
        -- 洗码模式 0=常规洗码 1=必须有压住的金币才能洗码
        washCodeMode = GameHelper:getWashCodeMode(),
        -- 游戏原始id
        rawGameId = gViewManager:getCurView().gameRealId,
    }
end

-- @brief 获取游戏重连数据
function APIGateway.GetGameReconnectData()
    if GameHelper == nil then return end
    return GameHelper:getGameReconnectData()
end

-- @brief 显示一个消息弹窗
-- @param content 内容文本
-- @param onOkCallback 确认回调
-- @param onCancelCallback 取消回调
function APIGateway.ShowMessageBox(content, onOkCallback, onCancelCallback)
    return Utils:showMsgBox(content, onOkCallback, onCancelCallback)
end

-- @brief 打开设置界面
function APIGateway.OpenSettingPanel()
    FeatureManager:open(FeatureManager.Setting)
end

-- @brief 打开客服界面
function APIGateway.OpenServicePanel()
    FeatureManager:open(FeatureManager.Service)
end

-- @brief 打开充值界面
function APIGateway.OpenRechargePanel()
    FeatureManager:open(FeatureManager.Recharge)
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
	cc.SpriteFrameCache:getInstance():removeUnusedSpriteSheetFile()

    local textureCache = cc.Director:getInstance():getTextureCache()
    textureCache:removeUnusedTextures()

    for k, v in pairs(textureCache:getTextures()) do
        if string.find(v, "res/FGame/") then
            textureCache:removeTextureForKey(v)
        end
    end
    
    cc.FileUtils:getInstance():restoreOriginalSearchPaths()
    cc.FileUtils:getInstance():purgeCachedEntries()

    gDeviceData:resetLobbyScreenType()
    gViewManager:runView(require("logic.views.LobbyView").new())
end

function APIGateway.SendPush(msg)
    APIGateway.SendRequest(msg)
end

-- @brief 向游戏服发送一个消息
function APIGateway.SendRequest(msg, callback)
    if GameHelper == nil then return end
    GameHelper:sendRequest(msg, callback)
    FSysEventEmitter:Emit(FSysEvent.ON_SEND_REQUEST)
end

-- @brief 向游戏服发送一个消息,如果请求失败或请求结果不是期望值，直接断线
function APIGateway.SendExactRequest(msg, resultMsgName, callback)
    -- 退出游戏消息无论是否请求成功都返回成功
    if msg._msgName_ == "PB.Client_Slots.Leave" then
        APIGateway.SendRequest(msg, function()
            callback(true, {_msgName_ = "PB.Slots_Client.Leave_Success"})
        end)
        return
    end

    APIGateway.SendRequest(msg, function(ok, response)
        if ok and response._msgName_ == resultMsgName then
            callback(true, response)
        else
            callback(false)
            APIGateway.Disconnect()
        end
    end)
end

-- @callback: (msg: table)
function APIGateway.AddSubscriber(msgName, callback, target)
    if GameHelper == nil then return end
    GameHelper:AddListener(msgName, callback, target)
end

function APIGateway.RemoveSubscriber(msgName, callback)
    assert(false, "cocos 暂不支持")
end

function APIGateway.RemoveAllSubscribers(target)
    if GameHelper == nil then return end
    GameHelper:RemoveListenersByTag(target)
end

-- @brief 断开游戏连接
function APIGateway.Disconnect()
    if GameHelper == nil then return end
    GameHelper:doReconnect()
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
    GameHelper = require("FGame.Common.Special.CocosH5.GameHelper").New()
end

function APIGateway.OnDestroy(fairyRoot)
    GameHelper:Delete()
    GameHelper = nil
    inFSlot = false
    
    local fSlotLua = {}
    for k, _ in pairs(package.loaded) do
        if string.find(k, "^FGame[.]") == 1 then
            table.insert(fSlotLua, k)
        end
    end
    for _, v in ipairs(fSlotLua) do
        package.loaded[v] = nil
    end
    
    local fSlotLua = {}
    for k, _ in pairs(package.loaded) do
        if string.find(k, "%.Webm%.preload") ~= nil then
            table.insert(fSlotLua, k)
        end
    end
    for _, v in ipairs(fSlotLua) do
        package.loaded[v] = nil
    end

    fSlotLua = {}
    for k, _ in pairs(package.preload) do
        if string.find(k, "^FGame[.]") == 1 then
            table.insert(fSlotLua, k)
        end
    end
    for _, v in ipairs(fSlotLua) do
        package.preload[v] = nil
    end
end

local _freshMoneyDelay = 2;
local _totalFreshMoneyDelay = _freshMoneyDelay;
function APIGateway.OnUpdate(aTime)
    local this = FCasinoCtx
    ---没有在转动中,没有在特殊模式下
    if APIGateway.StateIsIdle() then
        _totalFreshMoneyDelay = _totalFreshMoneyDelay - aTime
        if _totalFreshMoneyDelay < 0 then
            --同步金币
            local lastData = GameProtocolHub.LAST_MONEY_CHANGE_DATA
            if lastData then
                this:SetPlayerMoneyInfo(lastData)
                --动画可能导致金币转动出问题.
                this:SyncPlayerMoneyDisplay(0)
                GameProtocolHub.LAST_MONEY_CHANGE_DATA = nil
            end
        end
    else
        _totalFreshMoneyDelay = _freshMoneyDelay;
    end
end

function APIGateway.SetModuleName(moduleName)
end

-- @brief 判断设备是否处于竖屏状态
function APIGateway.IsDeviceOrientationPortrai()
    return gAdaptive:isOrientationPortrai()
end

local lastVIPLevel = nil
-- @brief VIP升级
function APIGateway.ShowVipUpInSlots(spinData)
    local vipLv = 0
    if gLobbyData and gLobbyData.userData and gLobbyData.userData.vip_level then
        vipLv = gLobbyData.userData.vip_level
    end

    if lastVIPLevel == nil then
        lastVIPLevel = vipLv
        return
    end

    if vipLv > lastVIPLevel then
        lastVIPLevel = vipLv
        require("logic.ui.vip.VipLevelup").new(vipLv):show()
    end
end

-- webm 相关
local WebmHelper = require("FGame.Common.Special.CocosH5.Webm.WebmHelper")
APIGateway.CreateWebmAndBindToGImage = WebmHelper.CreateWebmAndBindToGImage
APIGateway.CreateAllWebmWithRObject = WebmHelper.CreateAllWebmWithRObject

-- 0-255 
function APIGateway.color4(color)
    return {r = color.r, g = color.g, b = color.b, a = color.a}
end

-- @brief 获取当前国家(导航服返回的地区字段)
function APIGateway.GetCurRegion()
    return gConfigData.Region
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

function APIGateway.StateIsIdle()
    return FCasinoCtx and FCasinoCtx.curGameMode == FGameMode.NORMAL and FCasinoCtx.curSpinStatus == FSpinStatus.SPIN
end
