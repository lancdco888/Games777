-- player/player.lua
local this, lua, root = ...

local t = {
    nextLuaBulletId = 0,
}

lua:Set_onSerialize(function()
    GT = t
end)

lua:Set_onDeserialize(function()
    local t_ = GT
    for k, v in pairs(t_) do
        t[k] = v
    end
end)

if FF_G.IsServer then
    lua:Set_onInit(function()
        local playerId = this:GetId()
        FF_G.players[playerId] = {
            GetNextLuaBulletId = function()
                t.nextLuaBulletId = t.nextLuaBulletId - 1
                return t.nextLuaBulletId
            end
        }
        return 0
    end)

    lua:Set_onUnInit(function()
        local playerId = this:GetId()
        FF_G.players[playerId] = nil
    end)
end

if not FF_G.IsServer then
    local infoPanel = FF_G.LoadLuaFunc("script/panel/player_info_self.lua")(this, lua, root)

    local playerId = this:GetId()
    local isSelf = this:IsSelf()
    local sitId = this:GetSitId()
    local gx, gy = root:GetGSize()
    local infoSize = { width = 220, height = 90}
    local GetInfoCenterPos = function()
        local x, y
        if sitId == 0 then
            x, y = -gx / 2 + infoSize.width / 2, -gy / 2 + infoSize.height / 2
        elseif sitId == 1 then
            x, y = gx / 2 - infoSize.width / 2, -gy / 2 + infoSize.height / 2
        elseif sitId == 2 then
            x, y = -gx / 2 + infoSize.width / 2, gy / 2 - infoSize.height / 2
        elseif sitId == 3 then
            x, y = gx / 2 - infoSize.width / 2, gy / 2 - infoSize.height / 2
        end
        return FF_G_Client.ConvertToUiPos(x, y)
    end
    local GetCoinPos = function(x, y)
        local offset = infoSize.height / 2 + 20
        if isSelf then
            offset = offset + 20
        end
        if y > 0 then
            return x, y - offset
        end
        return x, y + offset
    end
    local infoX, infoY = GetInfoCenterPos()
    local coinX, coinY = GetCoinPos(infoX, infoY)
    local isInBottomSit = FF_G.IsInBottomSit(sitId)
    local uiX, uiY = FF_G_Client.GetPlayerUiPos(this)
    local srcX, srcY = this:GetPos()
    -- 特效显示位置
    local effectX, effectY = srcX, srcY
    --if FF_G.IsInBottomSit(this:GetSitId()) then
    if isInBottomSit then
        effectY = effectY + 200
    else
        effectY = effectY - 200
    end

    local fishDeathEffectQueue = {}
    local showFishDeathEffect = false

    local function ShowNextFishDeathEffect()
        if #fishDeathEffectQueue == 0 then return end
        if showFishDeathEffect then return end

        local data = table.remove(fishDeathEffectQueue, 1)
        --print("data.isCsStyle", tostring(data.isCsStyle))
        --print("data.banner", tostring(data.banner))
        --print("data.avatar", tostring(data.avatar))
        if data.isCsStyle then
            if not FF_G.IsServer then
                local x, y = FF_G_Client.ConvertToUiPos(effectX, effectY)
                local node = cc.Node:create();
                local coin = FF_G_Client.CreateNumText("texiao_suzi_%s.png", 67, 113)
                local bg = FF_G_Client.CreateCsBonusBanner()

                local coinNum = data.value / FF_G.ExchangeRate
                coin.SetString("" .. coinNum)
                node:setPosition(x, y)
                coin.node:setScale(0.75)

                node:setScale(0)
                node:runAction(cc.Sequence:create(
                        cc.ScaleTo:create(0.15, 1),
                        cc.DelayTime:create(1.75),
                        cc.ScaleTo:create(0.15, 0),
                        cc.RemoveSelf:create()
                ))

                node:addChild(bg)
                node:addChild(coin.node, 1)
                FF_G_Client.AddNodeTo(node, FF_G.kNodeIndex_UiTop)
            end
        else
            local ret, action = FF_G_Client.ShowFishDeathCoinEffect(data.banner, data.avatar,
                    data.value, {x = effectX, y = effectY})
            if ret then
                action:Set_onUnInit(function()
                    showFishDeathEffect = false
                    ShowNextFishDeathEffect()
                end)
                showFishDeathEffect = true
            end
        end
    end

    local joySlider
    -- 摇杆
    local function InitJoy()
        local slider = ccui.Slider:create("yaogan_dikuang.png", "yaogan_guangquang.png", ccui.TextureResType.plistType)
        slider:setScale9Enabled(true)
        slider:setContentSize(240, 32)
        slider:setPosition(-490, -100)
        slider:setPercent(50)
        slider:setTouchEnabled(true)
        slider:addEventListener(function(ref, touchType)
            print("touch type:", touchType, ",", ref.missNext)
            local cannon = this:GetCurrentCannon()
            if this:IsLockState() and cannon:IsNormalCannon() then return end
            if ref.missNext then
                ref.missNext = nil
                return
            end
            if touchType == ccui.SliderEventType.slideBallUp or
                    touchType == ccui.SliderEventType.slideBallCancel then
                this:SetFire(false)
                ref.missNext = true
                ref:setPercent(50)
                return
            elseif touchType == ccui.SliderEventType.slideBallDown then
                this:SetFire(true)
            end
            local angle = (100.0 - ref:getPercent()) / 100.0 * math.pi
            if not isInBottomSit then
                angle = angle + math.pi
            end
            cannon:GetAnim():SetAngle(angle)
        end)
        local node = FF_G_Client.GetNodeByNodeIndex(FF_G.kNodeIndex_Ui)
        node:addChild(slider)
        joySlider = slider
    end

    -- ping值显示
    local wifiSprite
    local pingNode

    local coinRoot = cc.Node:create()
    local pingMillsText = FF_G_Client.CreateNumText("xiaohao_%s.png", 11, 15)
    local pingMsSprite = cc.Sprite:createWithSpriteFrameName("xiaohao_ms.png")
    local pingMsSpriteWidth = pingMsSprite:getContentSize().width
    local pingTimeDelay = 0
    -- 最近发射时间
    local lastFireTime = root:CurrentTimePoint()

    -- 倒计时
    local countdownExitNode
    local countdownExitText

    -- 鱼死亡特效
    local observer = {
        onReceive = function(_, data)
            if data.playerId == playerId then
                table.insert(fishDeathEffectQueue, data)
                ShowNextFishDeathEffect()
            end
        end
    }

    -- 金币飘到炮台
    local observerGainCoin = {
        onReceive = function(_, data)
            if not FF_G.IsServer then
                local coin = data.coin / FF_G.ExchangeRate
                if data.playerId == playerId and coin > 0 then
                    local src = FF_G_Client.ConvertToUiPos(data.src)

                    local src1 = {x = src.x, y = src.y + 50}
                    local dest = {x = uiX, y = uiY}
                    local moveSec = root:GetDistance(src.x, src.y, dest.x, dest.y) / 1000

                    local src2 = {x = src.x, y = src.y + 10}
                    if src2.x > uiX then src2.x = src2.x + 10 else src2.x = src2.x - 10 end

                    --if dest.y < 0 then src1.y = src1.y + 30 else src1.y = src1.y - 30 end
                    local fn = isSelf and "jinbi_donghua_000%02d.png" or "jinbi_donghua_01_000%02d.png"

                    local func = function(delayTime, offsetX, callfunc)
                        local src = {x = src.x + offsetX, y = src.y}
                        local src1 = {x = src1.x + offsetX, y = src1.y}
                        local src2 = {x = src2.x + offsetX, y = src2.y}
                        local sprite = FF_G_Client.CreateFrameAnim(fn, 0, 60)
                        sprite:setPosition(src)
                        sprite:setVisible(false)
                        sprite:runAction(cc.Sequence:create(
                                cc.DelayTime:create(delayTime),
                                cc.Show:create(),
                                cc.EaseElasticInOut:create(cc.MoveTo:create(0.5, src1), 1.15),
                                cc.EaseElasticInOut:create(cc.MoveTo:create(0.5, src), 1.15),
                                cc.EaseElasticInOut:create(cc.MoveTo:create(0.3, src2), 1.15),
                                cc.MoveTo:create(moveSec, dest),
                                cc.CallFunc:create(callfunc),
                                cc.FadeOut:create(1),
                                cc.RemoveSelf:create()
                        ))
                        coinRoot:addChild(sprite)
                    end

                    func(0, 0, function()
                        local dest = {x = coinX, y = coinY}
                        if dest.y > 0 then dest.y = dest.y - 20 else dest.y = dest.y + 20 end
                        local fn = isSelf and "no2_%s.png" or "no7_%s.png"
                        local txt = FF_G_Client.CreateNumText(fn, 29, 40)
                        --txt.SetString(string.format("+%2f", coin), true)
                        txt.SetString("+" .. coin, true)
                        txt.node:setPosition(coinX, coinY)
                        txt.node:setScale(0.15)
                        txt.node:runAction(cc.Sequence:create(
                                cc.ScaleTo:create(0.25, 0.75),
                                cc.MoveTo:create(0.5, dest),
                                cc.RemoveSelf:create()
                        ))
                        coinRoot:addChild(txt.node)

                        infoPanel.AddCoinEffect()
                    end)
                    func(0.1, 45,function() end)
                end
            end
        end
    }

    -- 发射子弹
    local observerFire = {
        onReceive = function(_, data)
            if data.playerId == playerId then
                lastFireTime = root:CurrentTimePoint()
            end
        end
    }

    local observerCoinNotEnough = {
        onReceive = function(_, data)
            if data.playerId == playerId then
                infoPanel.SplashBgLightBound(3)
            end
        end
    }

    --local observerLockShowCoin = {
    --    onReceive = function(_, data)
    --        if data.playerId == playerId then
    --            if data.lock then
    --
    --            elseif data.unlock then
    --
    --            end
    --        end
    --    end
    --}

    local lastVipLv
    --local frame = 0
    local function UpdateVipLevelup(vipLv)
        if vipLv ~= lastVipLv and vipLv > 0 then
            -- show vip levelup animation.
            if lastVipLv then
                local info = sGameManager.GetVipLevelInfo(vipLv)
                local prev = math.max(0, info.id - 1)
                local cur = math.min(9, info.id)
                root:SpAttachmentAddNameReplace("num/0", string.format("num/%d", prev))
                root:SpAttachmentAddNameReplace("num/1", string.format("num/%d", cur))

                --sp.SkeletonAnimation:attachmentAddNameReplace("num/0", string.format("num/%d", prev))
                --sp.SkeletonAnimation:attachmentAddNameReplace("num/1", string.format("num/%d", cur))

                local ret, action = root:ShowEffect("actions/effect/vipLevelup/vip_levelup.actions", "show",
                        "action/boss_warning.lua", FF_G.kNodeIndex_SubUi, 0, 60, false)
                assert(ret)

                root:SpAttachmentClearNameMap()
                --sp.SkeletonAnimation:attachmentClearNameMap()

                local root1 = FF_G_Client.GetActionRootNode(action)
                local root = FF_G_Client.GetActionDrawNode(action)
                local anim = action:GetAnim()

                --print("fish_permillage_value:", info.fish_permillage_value)
                --print("slots_permillage_value:", info.slots_permillage_value)
                print("levelup_gift:", info.levelup_gift)

                --do
                --    --local txt = FF_G_Client.CreateNumText("xiaohao_%s.png", 11, 15)
                --    local txt = ccui.Text:create()
                --    txt:setTextColor(cc.c3b(0, 0, 0))
                --    --txt:enableGlow(cc.c4b(0xff, 0xff, 0xff, 0xff))
                --    txt:setFontSize(24)
                --    txt:setAnchorPoint(0.5, 0.5)
                --    txt:setText(string.format("Fish wash speed increased to %d‰", info.fish_permillage_value))
                --    root:addChild(txt, 1)
                --    FF_G_Client.PushNode(txt)
                --    anim:BindSlot("", "by_v")
                --end
                --
                --do
                --    local txt = ccui.Text:create()
                --    --local txt = FF_G_Client.CreateNumText("xiaohao_%s.png", 11, 15)
                --    txt:setTextColor(cc.c3b(0, 0, 0))
                --    --txt:enableGlow(cc.c4b(0xff, 0xff, 0xff, 0xff))
                --    txt:setFontSize(24)
                --    txt:setAnchorPoint(0.5, 0.5)
                --    txt:setText(string.format("Slots wash speed increased to %d‰", info.slots_permillage_value))
                --    root:addChild(txt)
                --    FF_G_Client.PushNode(txt, 1)
                --    anim:BindSlot("", "lhj_v")
                --end
                --
                --do
                --    local txt = ccui.Text:create()
                --    txt:setTextColor(cc.c3b(0, 0, 0))
                --    --txt:enableGlow(cc.c4b(0xff, 0xff, 0xff, 0xff))
                --    txt:setFontSize(24)
                --    txt:setAnchorPoint(0.5, 0.5)
                --    --local txt = FF_G_Client.CreateNumText("xiaohao_%s.png", 11, 15)
                --    local showCoin = info.levelup_gift / FF_G.ExchangeRate
                --    txt:setText(string.format("The binding of gold %s", FF_G_Client.FormatPlayerCoin(showCoin)))
                --    root:addChild(txt)
                --    FF_G_Client.PushNode(txt, 1)
                --    anim:BindSlot("", "bj_v")
                --end
                local giftType = info.gift_type or "none"
                --giftType = "none"
                if giftType ~= "none" and info.levelup_gift > 0 then
                    local node = cc.Sprite:createWithSpriteFrameName("bj_1.png")
                    node:setCascadeOpacityEnabled(true)
                    root:addChild(node)
                    FF_G_Client.PushNode(node, 1)
                    anim:BindSlot("", "bj")

                    local coinName = giftType == "bind_coin" and "bj_3.png" or "bj_4.png"
                    local size = node:getContentSize()
                    local node1 = cc.Sprite:createWithSpriteFrameName(coinName)
                    node1:setCascadeOpacityEnabled(true)
                    node1:setPosition(30, size.height / 2)
                    node:addChild(node1)

                    do
                        local txt = FF_G_Client.CreateNumText("no10_%s.png", 22, 31)
                        local showCoin = info.levelup_gift / FF_G.ExchangeRate
                        txt.node:setCascadeOpacityEnabled(true)
                        txt.SetString(string.format("%s", FF_G_Client.FormatPlayerCoin(showCoin)))
                        root:addChild(txt.node)
                        FF_G_Client.PushNode(txt.node, 1)
                        anim:BindSlot("", "bj_v")
                    end
                end

                --local bg = cc.LayerColor:create(cc.c4b(0, 0, 0, 150), 4000, 3000)
                local bg = ccui.Layout:create()
                bg:setBackGroundColor(cc.c3b(0, 0, 0))
                bg:setContentSize(cc.size(4000, 3000))
                bg:setBackGroundColorOpacity(150)
                bg:setBackGroundColorType(ccui.LayoutBackGroundColorType.solid)
                bg:setPosition(-2000, -1500)
                bg:setTouchEnabled(true)
                root1:addChild(bg, -1)

                local button = ccui.Button:create("determine.png", "", "", ccui.TextureResType.plistType)
                button:addTouchEventListener(function(_, type)
                    if type ~= ccui.TouchEventType.ended then return end
                    action:SetClean(true)
                end)
                button:setPosition(0, -350)
                button:setVisible(false)
                button:runAction(cc.Sequence:create(
                        cc.DelayTime:create(1.5),
                        cc.Show:create(),
                        cc.FadeIn:create(2.0)
                ))
                root1:addChild(button, 1)
            end
            lastVipLv = vipLv
        end
        --frame = frame + 1
    end

    local function UpdateCoin()
        if not FF_G.IsStandalone then
            --local washCode = this:GetTotalWashcode()
            local vipLv = 0
            --if washCode >= 0 then
            --    vipLv = sGameManager.GetVipLevel(washCode)
            --end
            if isSelf then
                --vipLv = sGameManager.GetMyVipLevel()
                if sGameManager.GetMyVipLevel() >= 0 then
                    local washCode = this:GetTotalWashcode()
                    vipLv = sGameManager.GetVipLevel(washCode)
                end
                --if vipLv == -1 then
                --    vipLv = 0
                --end
            end
            --print("washCode:", washCode, ",vip:", vipLv)
            infoPanel.SetCoin(this:GetShowCoin())
            infoPanel.SetBindCoin(this:GetShowBindCoin())
            if isSelf then
                local moneyType = this:GetMoneyType()
                infoPanel.SetMoneyType(moneyType)
                UpdateVipLevelup(vipLv)
            end
            if not isSelf then
                vipLv = 0
            end
            infoPanel.SetVipLevel(vipLv)
        end
    end

    local bankrupt
    local function UpdateBankrupt()
        if not this:IsReady() then
            return
        end
        local coin = this:GetCoin()
        local bindCoin = this:GetBindCoin()
        if coin <= 0 and bindCoin <= 0 then
            if not bankrupt then
                local ret, action = root:ShowEffect("actions/effect/bankrupt/fish_pochan.actions", "show",
                        "action/bankrupt.lua", FF_G.kNodeIndex_Ui, uiX, uiY, false)
                assert(ret)
                bankrupt = action
            end
        elseif bankrupt then
            bankrupt:SetClean(true)
            bankrupt = nil
        end
    end

    -- 退出倒计时
    local function InitCountdownExitUi()
        if not isSelf then return end
        local node = cc.Node:create()
        local txt = FF_G_Client.CreateNumText("no2_%s.png", 29, 40)

        local offsetXConfig = FF_G.GameConfig.CountdownNumOffsetX
        local lang = GetLang()
        local offsetX = offsetXConfig[lang] or offsetXConfig.default

        local bg = cc.Sprite:createWithSpriteFrameName("countdown_exit_bg.png")

        bg:setPosition(0, 150)
        txt.node:setPosition(offsetX, 42)

        bg:addChild(txt.node)
        node:addChild(bg)
        node:setVisible(false)
        node:setLocalZOrder(10)
        FF_G_Client.AddNodeTo(node, FF_G.kNodeIndex_UiTop)

        countdownExitNode = node
        countdownExitText = txt
    end

    local function InitUi()
        if isSelf then
            wifiSprite = cc.Sprite:create()
            pingNode = cc.Node:create()

            wifiSprite:setPosition(600, -100)
            pingNode:setPosition(600, -150)

            pingNode:setAnchorPoint(0.5, 0.5)
            pingMillsText.node:setAnchorPoint(0, 0.5)
            pingMsSprite:setAnchorPoint(0, 0.5)

            pingNode:addChild(pingMillsText.node)
            pingNode:addChild(pingMsSprite)
            --pingMillsText.node:setPosition(592, -150)
            --pingMsSprite:setPosition(608, -150)

            FF_G_Client.AddNodeTo(wifiSprite, FF_G.kNodeIndex_Ui)
            FF_G_Client.AddNodeTo(pingNode, FF_G.kNodeIndex_Ui)
        end
        FF_G_Client.AddNodeTo(coinRoot, FF_G.kNodeIndex_Ui)

        -- init infoPanel
        do
            local inBottomWithR = FF_G_Client.IsPlayerInBottomWithRotate(this)
            infoPanel.Init(isSelf, inBottomWithR, this:GetAvatarId(), this:GetNickname())
            infoPanel.SetMoneyType(this:GetMoneyType())
            infoPanel.OnSwitchMoneyType = function(moneyType)
                this:SetMoneyType(moneyType)
                this:SyncMoneyTypeMsg()
            end
            infoPanel.SetPosition(isSelf, inBottomWithR, infoX, infoY)
            UpdateCoin()
        end

        InitJoy()
        InitCountdownExitUi()
    end

    local function UnInitUi()
        if wifiSprite then
            wifiSprite:removeFromParent()
            wifiSprite = nil
        end
        if pingNode then
            pingNode:removeFromParent()
            pingNode = nil
        end
        if joySlider then
            joySlider:removeFromParent()
            joySlider = nil
        end
        if coinRoot then
            coinRoot:removeFromParent()
            coinRoot = nil
        end
        if bankrupt then
            bankrupt:SetClean(true)
            bankrupt = nil
        end
        infoPanel.UnInit()
    end

    lua:Set_onInit(function()
        print("player Init:", playerId)
        FF_G.Broadcast.register(FF_G.kBroadcastKey_ShowFishDeathEffect, observer)
        FF_G.Broadcast.register(FF_G.kBroadcastKey_CoinMoveToPlayer, observerGainCoin)
        FF_G.Broadcast.register(FF_G.kBroadcastKey_Fire, observerFire)
        FF_G.Broadcast.register(FF_G.kBroadcastKey_CoinNotEnough, observerCoinNotEnough)
        --FF_G.Broadcast.register(FF_G.kBroadcastKey_LockShowCoin, observerLockShowCoin)
        InitUi()
        FF_G.Broadcast.sendBroadcast(FF_G.kBroadcastKey_PlayerEnterOrExit, {
            sitId = sitId,
            isEnter = true,
        })
        FF_G.players[playerId] = {
            GetNextLuaBulletId = function()
                t.nextLuaBulletId = t.nextLuaBulletId - 1
                return t.nextLuaBulletId
            end
        }
        return 0
    end)

    lua:Set_onUnInit(function()
        print("player UnInit.")
        FF_G.players[playerId] = nil
        FF_G.Broadcast.unRegister(FF_G.kBroadcastKey_ShowFishDeathEffect, observer)
        FF_G.Broadcast.unRegister(FF_G.kBroadcastKey_CoinMoveToPlayer, observerGainCoin)
        FF_G.Broadcast.unRegister(FF_G.kBroadcastKey_Fire, observerFire)
        FF_G.Broadcast.unRegister(FF_G.kBroadcastKey_CoinNotEnough, observerCoinNotEnough)
        --FF_G.Broadcast.unRegister(FF_G.kBroadcastKey_LockShowCoin, observerLockShowCoin)
        UnInitUi()
        FF_G.Broadcast.sendBroadcast(FF_G.kBroadcastKey_PlayerEnterOrExit, {
            sitId = sitId,
            isEnter = false,
        })
    end)

    local hasDisconnect = false
    --local msgLayer
    --local lastAutoFireState = false
    local function UpdatePingUi(dt)
        if not isSelf then
            return
        end
        if not FF_G.IsStandalone then
            pingTimeDelay = pingTimeDelay - dt
            if pingTimeDelay <= 0 then
                root:SendPingMsg()
                --print("ping")
                pingTimeDelay = 5.0
            end
        end
        local pingMills = root:GetLastPingMills()
        local isPingTimeout = root:IsPingTimeout()
        --isPingTimeout = true
        pingMillsText.SetString(pingMills)
        if isPingTimeout then
            if not hasDisconnect then
                --msgLayer = UIManager.ShowMsgBox(
                --        "Loss connection, click button to back.",
                --        function()
                --            hasPopMsg = false
                --            root:Destroy()
                --        end
                --)
                --FF_G_Client.SwitchParentToNodeIndex(msgLayer, FF_G.kNodeIndex_Dialog)
                --hasPopMsg = true
                --lastAutoFireState = this:IsAutoFireState()
                --root:SetPingTimeout(false)
                --this:SetAutoFireState(false)
                wifiSprite:runAction(
                        cc.CallFunc:create(function()
                            gNet:Disconnect()
                            root:Destroy()
                        end)
                )
                hasDisconnect = true
            end
            wifiSprite:setSpriteFrame("wifi_wuxinhao.png")
        else
            hasDisconnect = false
            --if msgLayer then
            --    msgLayer:Close()
            --    msgLayer = nil
            --    this:SetAutoFireState(lastAutoFireState or false)
            --end
            if pingMills <= 20 then
                wifiSprite:setSpriteFrame("wifi1.png")
            elseif pingMills <= 50 then
                wifiSprite:setSpriteFrame("wifi2.png")
            elseif pingMills <= 100 then
                wifiSprite:setSpriteFrame("wifi3.png")
            else
                wifiSprite:setSpriteFrame("wifi0.png")
            end
        end

        local size = pingMillsText.node:getContentSize()
        pingMsSprite:setPosition(size.width + 6, 0)
        pingNode:setContentSize(size.width + pingMsSpriteWidth + 6, size.height)
        pingNode:setVisible(not isPingTimeout)
    end

    local hasSendExitMsg = false
    lua:Set_onUpdate(function(dt)
        UpdatePingUi(dt)
        UpdateBankrupt()

        local showJoy = isSelf and root:GetShowJoy()
        joySlider:setVisible(showJoy)

        if not FF_G.IsStandalone then
            if isSelf then
                local time = math.floor(math.max(0, 120 - (root:CurrentTimePoint() - lastFireTime)))
                local isShow = time <= 60
                countdownExitNode:setVisible(isShow)
                if isShow then
                    countdownExitText.SetString(string.format("%d", time))
                end
                if time <= 0 and not hasSendExitMsg then
                    root:RequestExit()
                    hasSendExitMsg = true
                end
            end
        end
        return 0
    end)

    lua:Set_onDraw(function()
        UpdateCoin()
    end)
end
