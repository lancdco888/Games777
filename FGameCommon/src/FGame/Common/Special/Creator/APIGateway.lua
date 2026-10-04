-- 游戏内部引用大厅相关接口的都使用 APIGateway 统一中转

FConfig.Debug = false

---@class APIGateway 描述
APIGateway = APIGateway or {}

local _reloadData = nil
local MUSIC_ID = -999

require("FGame.Common.Special.Creator.NetWorkHelp")
local GameProtocolHub = require("FGame.Common.Special.Creator.DataHub.GameProtocolHub")

local audioUtils = CREATOR.audioUtils

---@type boolean 游戏金币显示是否强制取整
FConfig.Common.GameScoreForceToInt = not CREATOR.gGameData:bottomUseLobbyRate()
-- FConfig.Common.GameScoreForceToInt = false

---@type boolean 点击加减押注是否可以改变选C
FConfig.Common.BetStepChangeCLevel = true

---@type boolean 显示选C菜单
FConfig.Common.ShowBetCLevelMenu = false

---播放音效
---@param path string 音效资源地址
---@param loop boolean 是否循环播放
---@return number 该接口必须返回一个可供操作当前音效的句柄
function APIGateway.PlaySound(path, loop)
    return audioUtils:playEffect(path, loop)
end

--- 停止播放音效
---@param handle number 音效句柄
function APIGateway.StopSound(handle)
    if handle == nil then return end
    if handle == MUSIC_ID then
        APIGateway.StopBGM()
    else
        audioUtils:stopEffect(handle)
    end
end

--- 设置音效音量大小
---@param handle number APIGateway.PlaySound返回的对象
---@param volume number 音量大小[0-1]之间
function APIGateway.SetSoundVolume(handle, volume)
    if handle == nil or volume == nil or audioUtils == nil then return end
    if handle == MUSIC_ID then
        audioUtils:changeMusicVolume(volume)
    else
        audioUtils:changeSplitVolume(handle, volume)
    end
end

function APIGateway.PlayBGM(path)
    audioUtils:playMusic(path)
    return MUSIC_ID
end

function APIGateway.StopBGM()
    audioUtils:stopMusic()
end

--- 是否开启音效 todo
function APIGateway.IsSoundEnable()
    return audioUtils:getEffectState()
end

--- 设置是否开启音效 todo
function APIGateway.SetSoundEnable(value)
    audioUtils:changeEffectState(value)
end

--- 获取大厅中的数据集合
-- @return table
function APIGateway.GetLobbyData()
    return {
        -- 是否开启绑定金
        bindGoldCoinEnabled = CREATOR.gGameData:IsBindCodeOpen(),
        -- 当前玩家是否是VIP
        playerIsVIP = CREATOR.gGameData:IsVIP(),
        -- 大厅汇率
        lobbyExchangeRate = CREATOR.gGameData.exchangerate,
        -- 游戏汇率
        gameExchangeRate = CREATOR.gGameData.CasinoExchangeRate,
        -- 大厅界面选择的押注(C位)信息
        -- curSlotsLevel = CREATOR.gGameData.curLevel,
        --
        isLotteryBetMode = CREATOR.gGameData.IsLotteryBetMode(),

        -- 洗码模式 0=常规洗码 1=必须有压住的金币才能洗码
        washCodeMode = CREATOR.gGameData.washCodeMode,
        -- 游戏原始id
        rawGameId = CREATOR.gGameData.real_game_id,        
    }
end

--- 获取游戏重连数据
function APIGateway.GetGameReconnectData()
    if CREATOR.gGameData.willReConnect then
        CREATOR.gGameData.willReConnect = false

        local enterstr = CREATOR.gGameData.gameStatusString;
        local resumeStr = CREATOR.gGameData.gameResumeString;

        local enterJson = cjson.decode(enterstr)
        local resumeJson = cjson.decode(resumeStr)
        local enterData, resumeData = GameHub:ConvertEnterData(enterJson, resumeJson)



        return resumeData
    end
end

--- 显示一个消息弹窗
-- @param content 内容文本
-- @param onOkCallback 确认回调
-- @param onCancelCallback 取消回调
function APIGateway.ShowMessageBox(content, onOkCallback, onCancelCallback)
    -- print("需要弹出提示消息:        "..content)
    content = content or ""
    CREATOR.PopUtils.showMsgBox(content, onOkCallback, onCancelCallback);
end

--- 打开设置界面
function APIGateway.OpenSettingPanel()
    CREATOR.PopUtils.showSettingView()
    -- local layer = gPopLayer:PopFixed(require("lobby.setup.SetUpLayer"),true)
    -- layer:setLangSwitchVisible(false)
    -- if APIGateway.IsDeviceOrientationPortrai() then
    --     layer:setScale(0.75)
    -- else
    --     layer:setScale(1)
    -- end
end

--- 打开客服界面
function APIGateway.OpenServicePanel()
    CREATOR.PopUtils.showServiceView()
    -- CREATOR.gLobbyData.bService_pop = true
    -- local root_node = gPopLayer:PopFixed(require("lobby.serviceMail.ServiceMailLayer"), true)
    -- --在线客服竖屏缩放节点
    -- if root_node then
    --     if APIGateway.IsDeviceOrientationPortrai() then
    --         root_node:setScale(0.5)
    --     else
    --         root_node:setScale(1)
    --     end
    -- end
end

--- 打开充值界面
function APIGateway.OpenRechargePanel()
    CREATOR.showRecharge()
end

--- 获取当前文本的多语言翻译文本
function APIGateway.GetLangText(key)
    local value = CREATOR.Language.getTextWithKey(key) or key
    if value == key then
        value = FConfig.Lang[key] or key
    end
    return value
end

--- 从游戏返回大厅
function APIGateway.EnterLobby()
    -- CREATOR.gLobbyData.isCasinoLoaded = false
    -- CREATOR.gLobbyData.gameState = const_game.Lobby_State
    -- EnterLobbyPanel()
    CREATOR.enterLobby()
end

function APIGateway.SendPush(msg)
    CreatorNetworkHelp.SendRequest(msg)
    --gNet_SendPush(gServerId_Game, msg)
end

--- 向游戏服发送一个消息
function APIGateway.SendRequest(msg, callback)
    CreatorNetworkHelp.SendRequest(msg, callback)
    FSysEventEmitter:Emit(FSysEvent.ON_SEND_REQUEST)
end

--- 向游戏服发送一个消息,如果请求失败或请求结果不是期望值，直接断线
function APIGateway.SendExactRequest(msg, resultMsgName, callback)
    CreatorNetworkHelp.SendRequest(msg, function(ok, msg)
        print("APIGateway on get spin result :" ..
            tostring(ok) .. " msgName:" .. tostring(msg._msgName_) .. " needMsgName:" .. resultMsgName)
        if ok and msg._msgName_ == resultMsgName then
            callback(true, msg)
        else
            callback(false)
            APIGateway.Disconnect()
        end
    end)
end

-- @callback: (msg: table)
function APIGateway.AddSubscriber(msgIdOrName, callback, target)
    print("APIGateway.AddSubscriber :" .. msgIdOrName)
    CreatorNetworkHelp.AddSubscriber(msgIdOrName, callback, target);
end

function APIGateway.RemoveSubscriber(msgIdOrName, target)
    -- assert(false, "cocos 暂不支持")
    CreatorNetworkHelp.RemoveSubscriber(msgIdOrName, target)
end

function APIGateway.RemoveAllSubscribers(target)
    CreatorNetworkHelp.RemoveAllSubscribers(target)
    -- gNetHandlers_UnregisterByTarget(target)
end

--- 断开游戏连接
function APIGateway.Disconnect()
    --TODO 这里需要通知客户端重连成功,我们没有重连操作
    FSysEventEmitter:Emit(FSysEvent.ON_NET_DISCONNECT)
    --gNet_Reset()
end

function APIGateway.ParticleEffectFadeOut(particle, duration, delayTime)
    particle:setScale(3, 3, 3)
    local content = particle.content;
    local opcity = content.getComponent("cc.UIOpacity")
    if not opcity then
        opcity = content.addComponent("cc.UIOpacity")
    end

    CREATOR.cc.tween(opcity).delay(delayTime).to(duration, { opcity = 0 }).call(function() opcity.node:destory() end)
    -- particle:runAction(cc.Sequence:create(cc.DelayTime:create(delayTime), cc.FadeOut:create(duration)))
end

--- 播放粒子特效
-- @return 装载器  原始粒子指针
function APIGateway.PlayParticleEffect(path, loader3D)
    local particle = CREATOR.createParticle(path)
    loader3D:setParcitle(particle, { x = 0, x = 1 })
    local node = loader3D.content.node
    node:setPosition(loader3D.width * 0.5, 0)

    return loader3D
end

--- 停止播放粒子特效
function APIGateway.StopParticleEffect(particle)
    particle._content:stopSystem()
end

--- 重播粒子特效
function APIGateway.ReplayParticleEffect(particle)
    particle._content:resetSystem()
end

--- 判断对象是否是无效对象
function APIGateway.IsInvalidObject(t)
    return t == nil or t == cjson.null or (type(t) == "userdata" and CREATOR.IsInvalidObject(t))
end

function APIGateway.InFSlot()
    return true
end

function APIGateway.OnEnter()
end

function APIGateway.OnDestroy(fairyRoot)
end

function APIGateway.OnUpdate(dt)
    APIGateway.checkGameStatus(dt)
end

function APIGateway.SetModuleName(moduleName)
end

--- 判断设备是否处于竖屏状态
function APIGateway.IsDeviceOrientationPortrai()
    return CREATOR.screenType == 1;
end

--- VIP升级
function APIGateway.ShowVipUpInSlots(spinData)
end

--- 老虎机等级信息
function APIGateway.SlotsEntryCondition()
end

local _freshMoneyDelay = 2;
local _totalFreshMoneyDelay = _freshMoneyDelay;
function APIGateway.checkGameStatus(aTime)
    local this = FCasinoCtx
    ---没有在转动中,没有在特殊模式下
    if APIGateway.StateIsIdle() then
        if _reloadData then
            CREATOR.printR("idle状态,重新检查自动旋转")
            APIGateway.OnReload(_reloadData)
        end

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

-- webm 相关
local WebmHelper = require("FGame.Common.Special.Creator.Webm.WebmHelper")
APIGateway.CreateWebmAndBindToGImage = WebmHelper.CreateWebmAndBindToGImage
APIGateway.CreateAllWebmWithRObject = WebmHelper.CreateAllWebmWithRObject


-- 0-255
---@param color color 描述
function APIGateway.color4(color)
    return { r = color.r, g = color.g, b = color.b, a = color.a }
end

local region = nil
--- 获取当前国家(导航服返回的地区字段)
function APIGateway.GetCurRegion()
    if not region then
        region = CREATOR.gGameData:region() 
    end
    return region;
end

---GObject对象 添加事件
---@param aType string 事件名
---@param aCallback function 回调函数
---@param aOverride boolean 如果已经存在一个同名事件,是否覆盖
---@return void
function APIGateway.AddEventListener(aObj, aType, aCallback, aOverride)
    if aObj == nil or aType == nil or aCallback == nil then return end;
    if aOverride then
        APIGateway.RemoveEventListeners(aObj, aType);
    end
    aObj:on(aType, aCallback)
end

---GObject对象 删除事件
---@param aObj table GObject对象
---@param aType string 事件名
---@return void
function APIGateway.RemoveEventListeners(aObj, aType)
    if aObj == nil or aType == nil then return end;
    aObj:off(aType);
end

function APIGateway.OnGameStarted()
    APIGateway.ResiterEvent()
end

function APIGateway.ResiterEvent()

end

--[[
    local SlotsAutoModes = {
    { mode = "inf", desc = "i"},
    { mode = "inf_fast", desc = "i+f"},
    { mode = "num", desc = "500", num = 500 },
    { mode = "num", desc = "100", num = 100 },
    { mode = "num", desc = "50" , num = 50  },
    { mode = "num", desc = "20" , num = 20  },
    }


    local AutoNums = { 10, 30, 50, 80, 1000 }
]]

function APIGateway.OnReload(aReload)
    CREATOR.printR("查询有reload. 查询reload条件:" .. aReload)

    if not APIGateway.StateIsIdle() then
        CREATOR.printR("非idle状态,存储等待idle:")
        _reloadData = aReload;
        return;
    end

    local list = string.split(aReload, "_")

    if list[1] == "true" then
        local config = { mode = "inf", desc = "i" }
        local num = tonumber(list[2])
        if num then
            config = { mode = "num", num = num }
        elseif list[3] == "true" then
            config = { mode = "inf_fast", desc = "i+f" }
        end
        dump({ reolad = aReload, config = config }, "reload config data")
        FCasinoCtx.commonPanel:SetAutoMode(config)
    end

    _reloadData = nil
end

function APIGateway.StateIsIdle()
    return FCasinoCtx and FCasinoCtx.curGameMode == FGameMode.NORMAL and FCasinoCtx.curSpinStatus == FSpinStatus.SPIN
end

function APIGateway.SaveAutoSpinInfo()
    local bottomPanel = FCasinoCtx.commonPanel.bottomPanel
    local isAuto = FCasinoCtx.commonPanel:IsAutoMode()

    local str = tostring(isAuto) ..
        "_" .. bottomPanel.auto_spin_num.text
    if isAuto then
        str = str .. "_" .. tostring(bottomPanel:IsAccelerationMode())
    end
    CREATOR.printR("存储自动旋转信息:" .. str)
    CREATOR._reload = str;
end

local _timerHander = nil
function APIGateway.StartCollectGarbage()
    if not _timerHander then
        _timerHander = StartTimer(function()
            collectgarbage("collect")
        end, 60 * 5)
    end
end
