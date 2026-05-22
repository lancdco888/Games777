-- root.lua
local this, lua, isServer, isStandalone = ...

--print("start lua root:", isServer, ",", isStandalone)

-- 捕鱼global
FF_G = FF_G or {}
-- 是否Server端
FF_G.IsServer = isServer == true
FF_G.IsStandalone = isStandalone == true
FF_G.root = this
FF_G.players = FF_G.players or {}

--if not FF_G.IsServer then
--    if not FF_G.IsStandalone then
--        -- 显示金币转换倍率
--        FF_G.ExchangeRate = sGameManager.exchangerate or 1
--        --FF_G.ExchangeRate = 1000
--    end
--end
--
--FF_G.ExchangeRate = FF_G.ExchangeRate or 1
FF_G.ExchangeRate = 1

local gameId = this:GetGameId()
do
    this:LoadLua("script/utils/utils1.lua")
    FF_G.IsCSGaming = FF_G.IsCSGame(gameId)
    print("gameId:" .. gameId .. ", is cs:" .. tostring(FF_G.IsCSGaming))
    if FF_G.IsStandalone then
        if FF_G.IsCSGaming then
            cc.SpriteFrameCache:getInstance():addSpriteFrames("ui/studio/fish_ui_cs.plist")
            cc.SpriteFrameCache:getInstance():addSpriteFrames("fish/cs/cs_other.plist")
        end
    end
end

FF_G.Assert = function (v, m)
    if v ~= true then
        print (debug.traceback())
        assert(v, m)
    end
end

if not FF_G.IsServer then
    if FF_G.IsStandalone then
        FF_G.IsGuest = false
    end
    if not FF_G.IsStandalone then
        FF_G.IsGuest = UserData.account_name == ""
    end
    FF_G.MaskBindCoin = not sGameManager.IsBindCodeOpen()
    FF_G.MaskVipLv = not VipLogic:IsVipOpen()
end

table.copyArray = table.copyArray or function(array)
    local dest = {}
    for k, v in ipairs(array) do
        dest[k] = v
    end
    return dest
end

local t = {
    sceneTime = 0,      -- 当前场景时间
    sceneIndex = 1,     -- 场景Index
    timeLineIndex = 1,  -- 当前场景时间线index
    currentBgName = "", -- 当前背景音乐
    --lvFileMd5 = "",
}

-- 时间线数据
local timeLines = {}
FF_G.timeLines = timeLines
FF_G.rootTable = t

local GetLevelFileMd5 = function()
    --local gameId = this:GetGameId()
    local fn = string.format("script/level/game%d.lua", gameId)
    local md5 = this:GetFileMd5(fn)
    return md5
end

-- 初始化关卡数据
local InitLevelData = function()
    --local gameId = this:GetGameId()
    --print("gameId:" .. gameId)
    --if gameId == 108 then gameId = 10001 end
    --if gameId == 107 then gameId = 10002 end
    --if gameId == 107 then gameId = 10003 end
    --if gameId == 107 then gameId = 10010 end
    --if gameId == 107 then gameId = 10008 end
    --if gameId == 106 then gameId = 10006 end
    local fn = string.format("script/level/game%d.lua", gameId)
    this:LoadLua(fn)
end

local SwitchScene = function()
    local timeLine = timeLines[t.sceneIndex]
    t.timeLineIndex = 1
    t.sceneTime = 0
    timeLine.Enable()
    return timeLine
end

--------------单机版相关属性----------------
local currentSceneIndexText
local currentSceneTimeText
local playRatioText
local playRatio = 1
-- 必死
FF_G_MustDeath = false
local InitDebugUi = function()
    if not FF_G.IsStandalone then return end
    do
        local offY = 320
        local text = FF_G_Client.CreateNumText("lieyanfengbao_daojishi_%s.png", 25, 35)
        text.node:setPosition(0, offY)
        FF_G_Client.AddNodeTo(text.node, FF_G.kNodeIndex_UiTop)
        currentSceneIndexText = text

        local minusRatio = ccui.Button:create("anniu_jianhao.png", "", "", ccui.TextureResType.plistType)
        local plusRatio = ccui.Button:create("anniu_jiahao.png", "", "", ccui.TextureResType.plistType)
        minusRatio:setScale(0.6)
        plusRatio:setScale(0.6)
        minusRatio:addTouchEventListener(function(_, type)
            if type ~= ccui.TouchEventType.ended then return end
            if t.sceneIndex <= 1 then
                t.sceneIndex = #timeLines
            else
                t.sceneIndex = t.sceneIndex - 1
            end
            t.sceneTime = 0
            this:RemoveAllFish()
            timeLines[t.sceneIndex].Disable()
            SwitchScene()
        end)
        plusRatio:addTouchEventListener(function(_, type)
            if type ~= ccui.TouchEventType.ended then return end
            if t.sceneIndex >= #timeLines then
                t.sceneIndex = 1
            else
                t.sceneIndex = t.sceneIndex + 1
            end
            t.sceneTime = 0
            this:RemoveAllFish()
            timeLines[t.sceneIndex].Disable()
            SwitchScene()
        end)

        minusRatio:setPosition(-150, offY)
        plusRatio:setPosition(150, offY)
        FF_G_Client.AddNodeTo(minusRatio, FF_G.kNodeIndex_UiTop)
        FF_G_Client.AddNodeTo(plusRatio, FF_G.kNodeIndex_UiTop)
    end
    do
        local offY = 290
        local text = FF_G_Client.CreateNumText("lieyanfengbao_daojishi_%s.png", 25, 35)
        text.node:setPosition(0, offY)
        FF_G_Client.AddNodeTo(text.node, FF_G.kNodeIndex_UiTop)
        currentSceneTimeText = text
    end
    do
        local offY = 260
        local text = FF_G_Client.CreateNumText("lieyanfengbao_daojishi_%s.png", 25, 35)
        text.node:setPosition(0, offY)
        FF_G_Client.AddNodeTo(text.node, FF_G.kNodeIndex_UiTop)
        playRatioText = text

        local minusRatio = ccui.Button:create("anniu_jianhao.png", "", "", ccui.TextureResType.plistType)
        local plusRatio = ccui.Button:create("anniu_jiahao.png", "", "", ccui.TextureResType.plistType)

        minusRatio:setScale(0.6)
        plusRatio:setScale(0.6)
        minusRatio:addTouchEventListener(function(_, type)
            if type ~= ccui.TouchEventType.ended then return end
            playRatio = playRatio / 2
            if playRatio >= 1 then
                playRatio = math.floor(playRatio)
            end
            this:SetGlobalRatio(playRatio)
        end)
        plusRatio:addTouchEventListener(function(_, type)
            if type ~= ccui.TouchEventType.ended then return end
            playRatio = playRatio * 2
            if playRatio >= 1 then
                playRatio = math.floor(playRatio)
            end
            this:SetGlobalRatio(playRatio)
        end)

        minusRatio:setPosition(-150, offY)
        plusRatio:setPosition(150, offY)
        FF_G_Client.AddNodeTo(minusRatio, FF_G.kNodeIndex_UiTop)
        FF_G_Client.AddNodeTo(plusRatio, FF_G.kNodeIndex_UiTop)
    end
    do
        local txt = ccui.Text:create()
        txt:addTouchEventListener(function(_, type)
            if type ~= ccui.TouchEventType.ended then return end
            FF_G_MustDeath = not FF_G_MustDeath
            txt:setText('必死:' .. tostring(FF_G_MustDeath))
        end)
        txt:setTouchEnabled(true)
        txt:setText('必死:' .. tostring(FF_G_MustDeath))
        txt:setPosition(0, 200)
        FF_G_Client.AddNodeTo(txt, FF_G.kNodeIndex_UiTop)
    end
end

local UpdateDebugUi = function()
    if not FF_G.IsStandalone then return end
    currentSceneIndexText.SetString(string.format("%d", t.sceneIndex))
    currentSceneTimeText.SetString(string.format("%.1f", t.sceneTime))
    playRatioText.SetString(string.format("%.2f", playRatio))
end

lua:Set_onCreate(function()
    this:LoadLua("script/config/game_config.lua")
    this:LoadLua("script/config/fish_info.lua")
    this:LoadLua("script/utils/utils.lua")
    if not FF_G.IsServer then
        this:LoadLua("script/utils/client.lua")
        this:LoadLua("script/utils/phoenix_effect.lua")
        this:LoadLua("script/utils/mermaid_effect.lua")
        this:LoadLua("script/utils/dragon_red_effect.lua")
        this:LoadLua("script/utils/cannon.lua")
    end
    --this:LoadLua("script/scene/scene.lua")
    this:LoadLua("script/scene/scene_cache.lua")
    this:LoadLua("script/utils/timer.lua")
    this:LoadLua("script/utils/broadcast.lua")
    this:LoadLua("script/utils/fish_maker.lua")
    this:LoadLua("script/config/json.lua")
    this:LoadLua("script/config/pathway.lua")
    InitLevelData()
    if not FF_G.IsServer then
        if not FF_G.IsStandalone then
            local scene = cc.Director:getInstance():getRunningScene()
            local loading = scene:getChildByName("loadingLayer")
            if loading then
                loading:removeFromParent()
            end
	    if PopLayer then
            	PopLayer:CloseAll()
	    end
        end
    end
end)

local PlayCurrentBgMusic = function()
    if t.currentBgName:len() > 0 then
        FF_G.PlayBgMusic(t.currentBgName)
    end
end

local waitTips = {}

local InitUi = function()
    for i = 0, 3 do
        local pos = FF_G.GetPosBySit(i)
        local x, y = FF_G_Client.ConvertToUiPos(pos.x, pos.y)
        local bg = cc.Sprite:createWithSpriteFrameName("dengdaiwanjia.png")
        local tip = cc.Sprite:createWithSpriteFrameName("dengdaiwanjia_ziti.png")

        local size = bg:getContentSize()
        tip:setPosition(size.width / 2, size.height / 2 + 5)

        bg:addChild(tip)
        bg:setZOrder(-1)
        bg:setPosition(x, y)

        bg:setCascadeOpacityEnabled(true)
        bg:runAction(cc.RepeatForever:create(cc.Sequence:create(
                cc.FadeOut:create(2),
                cc.FadeIn:create(2)
        )))

        if y < 0 then
            bg:setScaleY(-1)
            tip:setScaleY(-1)
        end
        FF_G_Client.AddNodeTo(bg, FF_G.kNodeIndex_Ui)
        waitTips[i] = bg
    end
end

local observerPlayerEnterOrExit = {
    onReceive = function(_, data)
        local sit = data.sitId
        local isShow = not data.isEnter
        --print("sit:", sit, ", isShow:", isShow)
        local node = waitTips[sit]
        if node then
            node:setVisible(isShow)
        end
    end
}

lua:Set_onInit(function()
    --print("root game2:", t.sceneIndex, ", len:", #timeLines)
    timeLines[t.sceneIndex].Enable()
    PlayCurrentBgMusic()
    if FF_G.IsServer then
        local md5 = GetLevelFileMd5()
        t.lvFileMd5 = md5
    end
    if not FF_G.IsServer then
        if not FF_G.IsStandalone then
            local md5 = GetLevelFileMd5()
            if md5 ~= t.lvFileMd5 then
                --local gameId = this:GetGameId()
                print("lv file md5 check fail:", gameId, ", ", md5, ", ", t.lvFileMd5)
                local node = UIManager.ShowMsgBox(
                        "Level data check fail, click button to back.",
                        function()
                            this:RequestExit()
                        end
                )
                FF_G_Client.SwitchParentToNodeIndex(node, FF_G.kNodeIndex_Dialog)
            end
        end
        InitUi()
        FF_G.Broadcast.register(FF_G.kBroadcastKey_PlayerEnterOrExit, observerPlayerEnterOrExit)
    end
    return
end)

if not FF_G.IsServer then
    lua:Set_onInitEnd(function()
        InitDebugUi()
        local selfPlayer = this:GetSelfPlayer()
        assert(selfPlayer)
        local cannon = selfPlayer:GetNormalCannon()
        assert(cannon)
        -- 界面信息
        FF_G.uiInfo = {
            GetCoin = function()
                return selfPlayer:GetCoin()
            end,
            RequestExit = function()
                this:RequestExit()
            end,
            gameId = gameId,                               -- 当前游戏 ID
            cannonIndex = cannon:GetTypeId(),                        -- 当前炮台，可选数值为: 1-7
            onCannonChanged = function(newIndex)      -- 炮台修改
                print("switch cannon skin type:" .. newIndex)
                FF_G.uiInfo.cannonIndex = newIndex
                cannon:SetTypeId(newIndex)
            end,
            fishShadow = this:GetShowShadow(),                          -- [显示(true) | 隐藏(false)] 鱼影
            onFishShadowChanged = function(show)        -- 修改鱼影显示设置
                print("FF_G.uiInfo set shadow:" .. tostring(show))
                FF_G.uiInfo.fishShadow = show
                this:SetShowShadow(show)
            end,
            showJoy = false,
            onJoyVisibleChanged = function(show)
                FF_G.uiInfo.showJoy = show
                this:SetShowJoy(show)
            end,
            PlayCurrentBgMusic = PlayCurrentBgMusic,
        }
        require("script.ui.init")
        init_fish_ui(root)
    end)
end

lua:Set_onUnInit(function()
    print("root UnInit.")
    if not FF_G.IsServer then
        gSound.stopbgm()
        destroy_fish_ui()
        FF_G.Broadcast.unRegister(FF_G.kBroadcastKey_PlayerEnterOrExit, observerPlayerEnterOrExit)
        this:GetTimelineCache():Clear()
    end
    FF_G = nil
    FF_G_Client = nil
    GT = nil
    -- 参数
    FF_PRAMS = nil
    FF_G_MustDeath = nil
end)

lua:Set_onUpdateFrame(function(frameNumber)
    local timeLine = timeLines[t.sceneIndex]
    -- 切换场景
    if t.sceneTime > timeLine.totalSeconds then
        t.sceneIndex = t.sceneIndex + 1
        if t.sceneIndex > #timeLines then
            t.sceneIndex = 1
        end
        timeLine.Disable()
        timeLine = SwitchScene()
        --print("switch scene:", t.sceneIndex)
    end

    --local time1 = this:NowSteadyEpochSeconds()
    timeLine.Update(t, timeLine.eventCount)
    --local time2 = this:NowSteadyEpochSeconds()
    --print("time line update use time:", (time2 - time1))
    FF_G.UpdateTimer(0.1)

    t.sceneTime = t.sceneTime + 0.1
    --collectgarbage("collect")
    if FF_G.IsStandalone then
        UpdateDebugUi()
    end
    if FF_G.IsServer then
        if frameNumber % 256 == 0 then
            collectgarbage("collect")
            --local count = collectgarbage("count")
            --print(string.format("count:%fKb", count))
        end
    end
end)

if not FF_G.IsServer then
    lua:Set_onGetValue(function(key)
        if key == "ScreenScaleX" then
            return FF_G_Client.GetScreenScaleX()
        elseif key == "ScreenScaleY" then
            return 1
        end
    end)

    lua:Set_onJsonMsg(function(str)
        print("json msg:", str)
        local msg = FF_G.Json.decode(str)
        if msg and msg.type == "setFishCoin" then
            local fishId = msg.id
            local coin = msg.coin
--             print(fishId, coin)
            local fish = this:FindFish(fishId)
            if not fish:IsNull() then
--                 print(fishId, " ", coin)
                fish:SetCoin(coin)
            end
        end
    end)
end

lua:Set_onSerialize(function()
    GT = t
end)

lua:Set_onDeserialize(function()
    local t_ = GT
    for k, v in pairs(t_) do
        t[k] = v
    end
end)
