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

-- 点击加减押注是否可以改变选C
if CasinoOpt_BetStepChangeCLevel ~= nil then
    FConfig.Common.BetStepChangeCLevel = CasinoOpt_BetStepChangeCLevel
end

-- 显示选C菜单
if CasinoOpt_ShowBetCLevelMenu ~= nil then
    FConfig.Common.ShowBetCLevelMenu = CasinoOpt_ShowBetCLevelMenu
end

APIGateway = {}

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
    gSound:setEffectSwitch(value)
    gSound:saveCfg()
end

-- @brief 获取大厅中的数据集合
-- @return table
function APIGateway.GetLobbyData()
    return {
        -- 是否开启绑定金
        bindGoldCoinEnabled = gUserData:IsBindCodeOpen(),
        -- 当前玩家是否是VIP
        playerIsVIP = gGameData:IsVIP(),
        -- 大厅汇率
        lobbyExchangeRate = gLobbyData.exchangerate or 10000,
        -- 游戏汇率
        gameExchangeRate = gGameData.CasinoExchangeRate or 10000,
        -- 彩金显示模式 根据押注
        isLotteryBetMode = gLobbyData.IsLotteryBetMode(),
        -- 大厅界面选择的押注(C位)信息
        curSlotsLevel = gGameData.curLevel,
        -- 选C限制是否开启（如果关闭则所有C都可以选）
        isCasinoLevelOpen = cc.UserDefault:getInstance():getBoolForKey("key_game_casino_level_open", false),
        -- 洗码模式 0=常规洗码 1=必须有压住的金币才能洗码
        washCodeMode = gLobbyData.washcode_mode,
        -- 游戏原始id
        rawGameId = gGameData:GetRealNormalID(gGameData.real_game_id),
    }
end

-- @brief 获取游戏重连数据
function APIGateway.GetGameReconnectData()
    if gGameData.NetRestoreCasino then
        gGameData.NetRestoreCasino = false
        return gGameData.NetRestoreCasinoRlt
    end
end

-- @brief 显示一个消息弹窗
-- @param content 内容文本
-- @param onOkCallback 确认回调
-- @param onCancelCallback 取消回调
function APIGateway.ShowMessageBox(content, onOkCallback, onCancelCallback)
    gTipLayer:ShowMsgBox(content, onOkCallback, onCancelCallback)
end

-- @brief 打开设置界面
function APIGateway.OpenSettingPanel()
    local layer = gPopLayer:Pop(require("lobby.setup.SetUpLayer"))
    layer:setLangSwitchVisible(false)
    if APIGateway.IsDeviceOrientationPortrai() then
        layer:setScale(0.75)
    else
        layer:setScale(1)
    end
end

-- @brief 打开客服界面
function APIGateway.OpenServicePanel()
    gLobbyData.bService_pop = true
    local root_node = gPopLayer:Pop(require("lobby.serviceMail.ServiceMailLayer"))
    --在线客服竖屏缩放节点
    if root_node then
        if APIGateway.IsDeviceOrientationPortrai() then
            root_node:setScale(0.5)
        else
            root_node:setScale(1)
        end
    end
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
    gLobbyData.isCasinoLoaded = false
    gLobbyData.gameState = const_game.Lobby_State
    EnterLobbyPanel()
    GlobalUpdate()
end

function APIGateway.SendPush(msg)
    gNet_SendPush(gServerId_Game, msg)
end

-- @brief 向游戏服发送一个消息
function APIGateway.SendRequest(msg, callback)
    go(function()
        -- 正在断线重连中
        if Client_Slots_Enter_Requesting then
            if FCasinoCtx and callback then
                callback()
            end
            return
        end
        local result = gNet_SendRequestToGame(msg)
        
        if FCasinoCtx and callback then
            callback(result ~= nil, result)
        end
    end)
    FSysEventEmitter:Emit(FSysEvent.ON_SEND_REQUEST)
end

-- @brief 向游戏服发送一个消息,如果请求失败或请求结果不是期望值，直接断线
function APIGateway.SendExactRequest(msg, resultMsgName, callback)

    --调试 模拟回包
    if DebugSlots and DebugSlots:SimulateNetRequest( msg, resultMsgName, callback ) then
        return
    end

    APIGateway.SendRequest(msg, function(ok, response)
        if ok and response._msgName_ == resultMsgName then

            --调试 模拟记录
            if DebugSlots then
                DebugSlots:SimulateNetWrite( msg, response )
            end

            callback(true, response)
        else
            -- 已退出游戏即将返回大厅
            if gNet:Alive() and gNet:IsOpened(0) and not gNet:IsOpened(gServerId_Game) then
                if msg._msgName_ == "PB.Client_Slots.Leave" then
                    callback(true, {_msgName_ = "PB.Slots_Client.Leave_Success"})
                    return
                end
            end

            callback(false)
            APIGateway.Disconnect()
        end
    end)
end

-- @callback: (msg: table)
function APIGateway.AddSubscriber(msgName, callback, target)
	gNetHandlers_Register(msgName, target, callback)
end

function APIGateway.RemoveSubscriber(msgName, callback)
    assert(false, "cocos 暂不支持")
end

function APIGateway.RemoveAllSubscribers(target)
    gNetHandlers_UnregisterByTarget(target)
end

-- @brief 断开游戏连接
function APIGateway.Disconnect()
    FSysEventEmitter:Emit(FSysEvent.ON_NET_DISCONNECT)
    gNet_Reset()
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
    return gDeviceData.currentScreenType == const_game.V_Screen_Type
end

local lastVIPLevel = nil
-- @brief VIP升级
function APIGateway.ShowVipUpInSlots(spinData)
    if spinData.slotMoneyGift and spinData.slotMoneyGift.amount_of_gift then
        -- 锁定金币生产总值
        local amount_of_gift = spinData.slotMoneyGift.amount_of_gift
        local vipLv = gGameData:GetVipLevel(amount_of_gift)

        if lastVIPLevel == nil then
            lastVIPLevel = vipLv
            return
        end

        if vipLv > lastVIPLevel then
            lastVIPLevel = vipLv
        else
            return
        end

        local curVipInfo = gGameData:GetVipLevelInfo(vipLv)
        if curVipInfo == nil or curVipInfo.id == nil then return end
        -- dump(curVipInfo,"升级信息")

        -- 创建动画根节点
        local actionNode = cc.Node:create()
        actionNode:setPosition(gAdaptive.Cx, gAdaptive.Cy)
        actionNode:setScale(gAdaptive.ScaleMin)
        actionNode.showActionTag = true
        cc.Director:getInstance():getRunningScene():addChild(actionNode, 11)

        -- 根节点关闭回调
        local function onClickClose()
            if not actionNode.showActionTag then return end

            actionNode.showActionTag = false
            actionNode:stopAllActions()
            actionNode:runAction(cc.Sequence:create(
                cc.ScaleTo:create(0.3,1.2),
                cc.ScaleTo:create(0.3,0),
                cc.RemoveSelf:create(true)
            ))
        end

        -- 创建对应动画
        local jsonFile = "lobby/spine/hall2022_jjj_levelup/hall2022_jjj_levelup.json"
        local atlasFile = "lobby/spine/hall2022_jjj_levelup/hall2022_jjj_levelup.atlas"

        local bg    = sp.SkeletonAnimation:createWithJsonFile(jsonFile, atlasFile, 1)
        local anim  = sp.SkeletonAnimation:createWithJsonFile(jsonFile, atlasFile, 1)
        local money = sp.SkeletonAnimation:createWithJsonFile(jsonFile, atlasFile, 1)
        actionNode:addChild(bg)
        actionNode:addChild(anim)
        actionNode:addChild(money)

        money:setAnimation(0, "hall2022_jjj_levelup_stand_money", true)
        money:setVisible(false)

        -- 最新等级
        local vip = ccui.TextBMFont:create("0", "lobby/vip/res/vip_level.fnt")
        vip:setPosition(60,120)
        vip:setScale(1.4)
        vip:setString(tostring(vipLv))
        vip:setVisible(false)
        vip:runAction(cc.Sequence:create(cc.DelayTime:create(0.45), cc.Show:create()))
        actionNode:addChild(vip)

        -- 确认按钮
        local path = "global/res/but_lv.png"
        local btn = ccui.Button:create(path, path, path, 0)
        btn:setPositionY(-250)
        btn:setTitleFontSize(30)
        btn:setTitleColor(cc.c3b(0x41,0x41,0x46))
        btn:setTitleText(TR("确定"))
        btn:addClickEventListener(onClickClose)
        actionNode:addChild(btn)


        --"捕  鱼：%s%%"
        local tips = tostring(curVipInfo.fish_per_millage_value / 10)
        --"老虎机：%s%%"
        local tips1=  tostring(curVipInfo.slots_per_millage_value / 10)
        --达成此等级，获赠钻石
        local tips2 = tostring(gStringUtils.CoinToString(curVipInfo.levelup_gift))
        local strtips = string.format("%s   %s   %s",tips, tips1, tips2)
        -- print("显示升级信息",strtips)

        --下方捕鱼速率提升 老虎机速率提升 字体创建
        if curVipInfo.levelup_gift > 0 then
            local ok, str = pcall(string.format, TR("获得奖励  %s"), tips2)
            if ok then
                local text = cc.Label:createWithSystemFont(str, "Arial", 40)
                text:setScale(0.7)
                text:setPositionY(-160)
                actionNode:addChild(text)
                money:setVisible(true)
                money:setPositionY(-160)
            end
        end

        bg:setVisible(false)
        anim:setAnimation(0, "hall2022_jjj_levelup_appear", false)
        actionNode:runAction(cc.Sequence:create(
            cc.DelayTime:create(2),
            cc.CallFunc:create(function ()
                bg:setVisible(true)
                bg:setAnimation(0,"hall2022_jjj_levelup_stand_back",true)
                anim:setAnimation(0,"hall2022_jjj_levelup_stand",true)
            end),
            cc.DelayTime:create(3),
            cc.CallFunc:create(onClickClose)
        ))
    end
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

-- @brief 绑定骨骼跟随目标
-- @param spine 骨骼对象(GLoader3D)
-- @param boneName 骨骼名称
-- @param callback 回调函数
function APIGateway.SpineFollowBone(loader3d, boneName, target)
    if target == nil then return end
    
    local rawScaleX = target.scaleX
    local rawScaleY = target.scaleY
    local rawX = target.x
    local rawY = target.y

    local function callback(bone)
        target.scaleX = rawScaleX * bone.scaleX
        target.scaleY = rawScaleY * bone.scaleY
        target.x = rawX + bone.x
        target.y = rawY - bone.y
        target.rotation = bone.rotation
    end

    local bone = APIGateway.SpineFollowBoneWithCallback(loader3d, boneName, callback)
    if bone then
        callback(bone)
    end
end

-- @brief 绑定骨骼跟随目标
-- @param spine 骨骼对象(GLoader3D)
-- @param boneName 骨骼名称
-- @param callback 回调函数
-- @return bone 骨骼对象(结构类型 {x = 0, y = 0, scaleX = 1, scaleY = 1, rotation = 0, worldX = 0, worldY = 0})
function APIGateway.SpineFollowBoneWithCallback(loader3d, boneName, callback)
    if loader3d == nil or boneName == nil or callback == nil then return end

    local skeletonAnimation = loader3d.content
    if skeletonAnimation == nil then return end

    local nodeKey = tostring(boneName) .. "_schedule_node"
    local bone = skeletonAnimation:findBone(boneName)
    if bone.x == nil then
        print("骨骼不存在:", boneName)
        return
    end

    local scheduleNode = skeletonAnimation:getChildByName(nodeKey)
    if scheduleNode then
        scheduleNode:removeFromParent()
        print("骨骼跟随目标已经存在:", boneName)
    end

    scheduleNode = cc.Node:create()
    scheduleNode:setName(nodeKey)
    scheduleNode:onUpdate(function()
        callback(skeletonAnimation:findBone(boneName))
    end)
    skeletonAnimation:addChild(scheduleNode)

    return bone
end

-- @brief 取消绑定骨骼跟随目标
-- @param spine 骨骼对象(GLoader3D)
-- @param boneName 骨骼名称
function APIGateway.SpineUnfollowBone(loader3d, boneName)
    if loader3d == nil or boneName == nil then return end

    local skeletonAnimation = loader3d.content
    if skeletonAnimation == nil then return end

    local nodeKey = tostring(boneName) .. "_schedule_node"
    local scheduleNode = skeletonAnimation:getChildByName(nodeKey)
    if scheduleNode then
        scheduleNode:removeFromParent()
    end
end

function APIGateway.OpenFeature(name)
end