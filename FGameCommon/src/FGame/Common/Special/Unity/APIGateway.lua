-- 游戏内部引用大厅相关接口的都使用 APIGateway 统一中转

APIGateway = {}

local currentModuleName

local ResourcesManager = require("FGame.Common.Special.Unity.ResourcesManager")
local GetPath = ResourcesManager.GetPath

-- @brief 播放音效
-- @param path 音效资源地址
-- @param loop 是否循环播放
-- @return 该接口必须返回一个可供操作当前音效的句柄
function APIGateway.PlaySound(path, loop)
    local path1 = GetPath(path)
    if path1 == nil then return end
    return SoundMgr:playSound(path1, loop)
end

-- @brief 停止播放音效
-- @param handle 音效句柄
function APIGateway.StopSound(handle)
    if handle == nil then return end
    return SoundMgr:stopSound(handle)
end

-- @brief 设置音效音量大小 取值范围[0,1]
-- @param handle APIGateway.PlaySound返回的对象
function APIGateway.SetSoundVolume(handle, volume)
    if handle == nil then return end
    handle:SetVolumePercent( math.min(volume*100,100) )
end

function APIGateway.PlayBGM(path)
    local path1 = GetPath(path)
    if path1 == nil then return end
    return SoundMgr:playBGM(path1, true)
end

function APIGateway.StopBGM()
    SoundMgr:stopBGM()
end

-- @brief 是否开启音效
function APIGateway.IsSoundEnable()
    return SoundMgr:isEffectON()
end

-- @brief 设置是否开启音效
function APIGateway.SetSoundEnable(value)
    SoundMgr:SetEffectEnable(value)
end

-- @brief 获取大厅中的数据集合
-- @return table
function APIGateway.GetLobbyData()
    return {
        -- 是否开启绑定金
        bindGoldCoinEnabled = GameMgr:isBindModeWeb(),
        -- 当前玩家是否是VIP
        playerIsVIP = GameMgr.player:getVipLv() > 0,
        -- 大厅汇率
        lobbyExchangeRate = GameMgr.moneyExchangeCoin,
        -- 游戏汇率
        gameExchangeRate = GameMgr.moneySLotsExchangeCoin,
        --彩金显示模式 根据押注
        isLotteryBetMode = GameMgr:IsLotteryBetMode(),
        -- 大厅界面选择的押注(C位)信息
        curSlotsLevel = GameMgr.curSlotsEntryCondition,
        -- 选C限制是否开启（如果关闭则所有C都可以选）
        isCasinoLevelOpen = GameMgr.player:IsCasinoLevelOpen(),
        -- 洗码模式 0=常规洗码 1=必须有压住的金币才能洗码
        washCodeMode = GameMgr.loginData.washcode_mode,
        -- 游戏原始id
        rawGameId = GameMgr.lastSlotsEnterData.ClientData.cfgSlots.IDBenZun,
    }
end

local ReconnectData
-- @brief 获取游戏重连数据
function APIGateway.GetGameReconnectData()
    local data = ReconnectData
    ReconnectData = nil
    if data then
        return data.msg
    end
    return nil
end

-- @brief 显示一个消息弹窗
-- @param content 内容文本
-- @param onOkCallback 确认回调
-- @param onCancelCallback 取消回调
function APIGateway.ShowMessageBox(content, onOkCallback, onCancelCallback)
    local hasOkButton = onOkCallback ~= nil
    local hasCancelButton = onCancelCallback ~= nil
    UIMgr:showAlert(content, function(idx)
        if idx == 1 and hasCancelButton then
            onCancelCallback()
        end
        if idx == 2 and hasOkButton then
            onOkCallback()
        end
    end, onCancelCallback and {"", ""} or nil)
end

-- @brief 打开设置界面
function APIGateway.OpenSettingPanel()
    UIMgr:showUISLotsSetting()
end

-- @brief 打开客服界面
function APIGateway.OpenServicePanel()
    UIMgr:showCustomerInSlots()
end

-- @brief 获取当前文本的多语言翻译文本
function APIGateway.GetLangText(key)
    local defaultText = FConfig.Lang[key]
    return L10N:getText(key, defaultText)
end

-- @brief 从游戏返回大厅
function APIGateway.EnterLobby()
    print("enter lobby.")
    GameMgr:exitSlotsGame()
    UIMgr:showUICanvasCover(true)
end

local msgHelper = require("FGame.Common.Special.Unity.MsgHelper")

-- @brief 向游戏服发送一个消息
-- @callback: (isOk: bool, msg: table)
function APIGateway.SendRequest(msg, callback)
    --断线重连中直接忽略发包
    if GameMgr.isReconnecting == true then
        if callback then
            callback(false)
        end
        if APIGateway then
            APIGateway.Disconnect()
        end
        return
    end

    msgHelper.Send(msg._msgName_, msg, callback)
    FSysEventEmitter:Emit(FSysEvent.ON_SEND_REQUEST)
end


-- @brief 向游戏服发送一个消息
function APIGateway.SendPush(msg)
    msgHelper.Send(msg._msgName_, msg)
end

-- @brief 向游戏服发送一个消息,如果请求失败或请求结果不是期望值，直接断线
function APIGateway.SendExactRequest(msg, resultMsgName, callback)
    APIGateway.SendRequest(msg, function(ok, resMsg)
        if ok and resMsg._msgName_ == resultMsgName then
            callback(true, resMsg)
        else
            callback(false)
            if APIGateway then
                APIGateway.Disconnect()
            end
        end
    end)
end

-- @callback: (msg: table)
function APIGateway.AddSubscriber(msgName, callback, target)
    local msgId = msgHelper.GetMsgId(msgName)
    msgHelper.AddSubscriber(msgId, callback, target)
end

function APIGateway.RemoveSubscriber(msgName, callback)
    local msgId = msgHelper.GetMsgId(msgName)
    msgHelper.RemoveSubscriber(msgId, callback)
end

function APIGateway.RemoveAllSubscribers(target)
    msgHelper.RemoveAllSubscribers(target)
end

local updateTween

local StopUpdateTween = function()
    if updateTween ~= nil then
        updateTween:Kill(false)
        updateTween = nil
    end
end

local inFSlot = false
function APIGateway.InFSlot()
    return inFSlot
end

function APIGateway.OnEnter()
    inFSlot = true
    Event:registerEvt(APIGateway, EventDefine.SlotsReconnect, function(data)
        ReconnectData = data
    end)
    Event:registerEvt(APIGateway, EventDefine.GameRestart, function()
        DestroyCasino()
    end)
    Event:registerEvt(APIGateway, EventDefine.EnterLobby, function()
        DestroyCasino()
    end)

    StopUpdateTween()
    updateTween = FairyGUI.GTween.To(0, 0, 1000000000)
                          :OnUpdate(function()
        local ctx = FCasinoCtx
        if ctx ~= nil then
            local dt = CS.UnityEngine.Time.deltaTime
            ctx:Update(dt)
        end
    end)
end

local CleanFSlotsLuaCache = function()
    ---@type string[]
    local fSlotLua = {}
    
    ---@param k string
    for k, _ in pairs(package.loaded) do
        print("loaded:", k)
        local isGamePrivateRes = string.find(k, "FGame[.]Game") == 1
        local isGameCommonRes = string.find(k, "FGame[.]Common") == 1
        local isFSlotsLauncher = string.find(k, "common[.]FSlotsLauncher") == 1
        local isSlotsLauncher = string.find(k, "slots%d+[.]SlotsLaunch") == 1
        
        if isGameCommonRes or isGamePrivateRes or isFSlotsLauncher or isSlotsLauncher then
            table.insert(fSlotLua, k)
        end
    end
    for _, v in ipairs(fSlotLua) do
        package.loaded[v] = nil
    end
end

function APIGateway.OnDestroy(fairyRoot)
    inFSlot = false
    --fairyRoot:Dispose()
    fairyRoot:Clear()
    fairyRoot:RemoveChildren()

    Event:unregisterEvt(APIGateway, EventDefine.SlotsReconnect)
    Event:unregisterEvt(APIGateway, EventDefine.GameRestart)
    Event:unregisterEvt(APIGateway, EventDefine.EnterLobby)
end

function APIGateway.Clear()
    StopUpdateTween()

    -- clean fslots lua cache.
    CleanFSlotsLuaCache()

    -- clean fslots global values.
    FTween = nil
    FConfig = nil
    FToolSet = nil
    APIGateway = nil

    msgHelper.Clear()
    msgHelper = nil
    ResourcesManager = nil
end

function APIGateway.ParticleEffectFadeOut(peRoot, duration, delayTime)
    local pes = peRoot:GetComponentsInChildren(typeof(CS.UnityEngine.ParticleSystem))
    for i = 0, pes.Length - 1 do
        local ps = pes[i]
        CSUtils.DOTween.Sequence():AppendInterval(delayTime):OnComplete(function()
            --print("OnComplete1", ps:IsNull())
            if not ps:IsNull() then
                --print("OnComplete2")
                ps:Stop()
            end
        end)
    end
end

-- @brief 播放粒子特效
function APIGateway.PlayParticleEffect(path, loader3D)
    --print("ps path 1:", path)
    local prefabPath = path .. ".prefab";
    local psPath = GetPath(prefabPath)
    if psPath == nil then
        -- 搜索当前游戏Res目录资源.
        psPath = GetPath("../Res/" .. prefabPath)
    end
    if psPath == nil then
        -- 如果当前游戏中没有就去公共资源中搜索.
        local idx = string.find(prefabPath, "/")
        local trimPath = string.sub(prefabPath, idx + 1)
        psPath = GetPath("Res/" .. trimPath)
    end
    --local psPath = currentModuleName .. "/" .. path .. ".prefab"
    -- printW("ps path 2:", psPath)
    if psPath == nil or psPath == "" then
        printE("缺少粒子:"..path)
        return nil
    end
    if loader3D.wrapTarget then
        printE("当前loader3D已经存在一个粒子,不能再设置了 path:"..path)
        return nil
    end
    local prefab = CS.AssetBundleUtils.AssetBundlesManager.GetInstance()
                     :LoadAssetWithoutAbName(psPath, typeof(CS.UnityEngine.Object))
    local gameObj = CSUtils.GameObject.Instantiate(prefab)
    loader3D:SetWrapTarget(gameObj, false, 0, 0)
    return gameObj
end

-- @brief 停止播放粒子特效
function APIGateway.StopParticleEffect(gameObj)
    if not Tool:isUnityObj(gameObj) then
        printE("缺少粒子 APIGateway.StopParticleEffect gameObj=nil")
        return
    end
    local psObj = gameObj.transform:Find("ps")
    if psObj and psObj:GetComponent("ParticleSystem") then
        psObj:GetComponent("ParticleSystem"):Stop( true )
    else
        printE("APIGateway.StopParticleEffect: gameObj 可能不符合设计规划")
    end
end

-- @brief 重播粒子特效
function APIGateway.ReplayParticleEffect(gameObj)
    if not Tool:isUnityObj(gameObj) then
        printE("缺少粒子 APIGateway.ReplayParticleEffect gameObj=nil")
        return
    end
    local psObj = gameObj.transform:Find("ps")
    if psObj and psObj:GetComponent("ParticleSystem") then
        psObj:GetComponent("ParticleSystem"):Play( true )
    else
        printE("APIGateway.ReplayParticleEffect: gameObj 可能不符合设计规划")
    end
end

-- @brief 判断对象是否是无效对象
function APIGateway.IsInvalidObject(obj)
    if obj == nil then
        return true
    end
    if obj.IsNull then
        return obj:IsNull()
    end
    return obj.isDisposed
end

function APIGateway.OnUpdate()
    local ret = UIMgr:hasOtherUIinFGame()
    CS.FairyGUI.Stage.DisableTouchEvent = ret
end

-- @brief 断开游戏连接
function APIGateway.Disconnect()
    FSysEventEmitter:Emit(FSysEvent.ON_NET_DISCONNECT)
    GameMgr:netReconnect()
end

function APIGateway.SetModuleName(moduleName)
    currentModuleName = moduleName
end

-- @brief 判断设备是否处于竖屏状态
function APIGateway.IsDeviceOrientationPortrai()
    return UIMgr:getOrientation() == UIMgr.Orientation.Portrait
end

-- @brief VIP升级
function APIGateway.ShowVipUpInSlots(spinData)
    UIMgr:showVipUpInSlots(spinData)
end

-- webm 相关
local WebmHelper = require("FGame.Common.Special.Unity.Webm.WebmHelper")
APIGateway.CreateWebmAndBindToGImage = WebmHelper.CreateWebmAndBindToGImage
APIGateway.CreateAllWebmWithRObject = WebmHelper.CreateAllWebmWithRObject

-- 0-255 
function APIGateway.color4(color)
    return {r = color.r/255, g = color.g/255, b = color.b/255, a = color.a/255}
end

-- @brief 获取当前国家(导航服返回的地区字段)
function APIGateway.GetCurRegion()
    return GameMgr.region
end

---GObject对象 添加事件
---@param gObj userdata 需要添加事件的组件
---@param eventType string 事件类型(FGUIEventKey枚举值)
---@param callback function 回调函数
---@param override boolean 如果已经存在一个同名事件,是否覆盖
---@return void
function APIGateway.AddEventListener(gObj, eventType, callback, override)
    assert(gObj ~= nil, "gObj need not null.")
    assert(eventType ~= nil, "event type need not null.")
    assert(callback ~= nil, "callback need not null.")
    
    if override == true then
        gObj:RemoveEventListeners(eventType)
    end
    gObj:AddEventListener(eventType, callback)
end

---GObject对象 删除事件
---@param gObj userdata 需要删除事件的组件
---@param eventType string 事件类型(FGUIEventKey枚举值)
---@return void
function APIGateway.RemoveEventListeners(gObj, eventType)
    assert(gObj ~= nil, "gObj need not null.")
    assert(eventType ~= nil, "event type need not null.")

    gObj:RemoveEventListeners(eventType)
end
