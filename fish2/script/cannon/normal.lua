-- cannon/normal.lua
local this, lua, root = ...
-- 普通炮台逻辑

local t = {
    speedUp = false
}
local funcs = {}

local player = this:GetPlayer()
local isSelf = false
local fireX, fireY = FF_G.GetCannonBasePos(this)
-- 炮台图片
local cannonSprite

local function GetCsSkinType()
    return this:GetRatioIndex() < 5 and 1 or 2
end

local function FireBullet(isTrace, bulletId, dt, waitTime)
    if not FF_G.IsServer then
        if this:GetBulletCount() >= 30 then return end
    end
    if FF_G.IsServer then
        if this:GetBulletCount() >= 50 then return end
    end

    dt = math.min(dt, 0.15)
    --local x, y = this:GetBulletStartPos()
    local skinId
    local filename
    if FF_G.IsCSGaming then
        skinId = GetCsSkinType()
        filename = "actions/cs/bullet/bullet" .. skinId .. ".anims"
    else
        skinId = this:GetTypeId()
        filename = "actions/bullet/bullet" .. skinId .. ".anims"
    end

    local anim = root:CreateAnimNode(filename)
    anim:SetAngle(this:GetAngle())
    anim:SetPos(fireX, fireY)
    local ratio = this:GetRatio()
    local moneyType = player:GetMoneyType()
    --local bullet = (isTrace and this:CreateTrackBullet()) or this:CreateSimpleBullet()
    local bullet
    if isTrace then
        bullet = this:CreateTrackBullet()
        bullet:SetSpeed(FF_G.GameConfig.TrackBulletSpeed)
    else
        bullet = this:CreateSimpleBullet()
        bullet:SetSpeed(FF_G.GameConfig.SimpleBulletSpeed)
    end
    if isSelf then waitTime = FF_G.GameConfig.SimpleBulletWaitTime end
    bullet:SetWaitTime(waitTime)
    bullet:SetId(bulletId)
    bullet:SetTypeId(skinId)
    bullet:SetRatio(ratio)
    if moneyType == 0 then
        bullet:SetLockValue(ratio)
    else
        bullet:SetLockBindCoin(ratio)
    end
    bullet:SetAnim(anim)
    bullet:SetPower(150)
    bullet:SetMoneyType(moneyType)
    bullet:SetHandledMultiple(false)
    bullet:SetFireTime(root:CurrentTimePoint())
    if isTrace then
        this:SendTrackBullet(bullet, dt)
    else
        this:SendSimpleBullet(bullet, dt)
    end
    if not FF_G.IsServer then
        FF_G.playEffect("bullet")
        FF_G_Client.RunFireAction(cannonSprite)
    end
    return bullet
end

lua:Set_onFireSimpleBulletWithoutReturn(function(bulletId, waitTime, dt)
    FireBullet(false, bulletId, dt, waitTime)
end)

lua:Set_onFireTrackBulletWithoutReturn(function(bulletId, waitTime, dt)
    FireBullet(true, bulletId, dt, waitTime)
end)

lua:Set_onFireSimpleBullet(function(bulletId, waitTime, dt)
    local bullet = FireBullet(false, bulletId, dt, waitTime)
    if bullet == nil then return root:CreateNullSimpleBullet() end
    return bullet
end)

lua:Set_onFireTrackBullet(function(bulletId, waitTime, dt)
    local bullet = FireBullet(true, bulletId, dt, waitTime)
    if bullet == nil then return root:CreateNullTrackBullet() end
    return bullet
end)

funcs.FireBullet = FireBullet

if not FF_G.IsServer then
    -- 客户端专有逻辑
    isSelf = player:IsSelf()
    local sitId = player:GetSitId()
    local isInBottomSit = FF_G.IsInBottomSit(sitId)
    local isRotate = root:IsRotate()
    local anim = this:GetAnim()

    local director = cc.Director:getInstance()

    local scene = FF_G_Client.GetRootNode()
    local nodeRoot = scene:getChildByName("root")
    local nodeEffectTop = nodeRoot:getChildByName("nodeEffectTop")

    local nodeUiRoot = scene:getChildByName("uiRoot")
    local nodeUi = nodeUiRoot:getChildByName("nodeUi")

    local srcX, srcY = this:GetPos()
    local gx, gy = root:GetGSize()

    local uiRoot = cc.Node:create()
    -- ui下层
    local uiRootBottom = cc.Node:create()

    -- 自动锁定按钮特效
    local effectLock
    -- 自动发射按钮特效
    local effectFire
    -- 激光按钮特效
    local effectLaser
    -- 加速按钮特效
    local effectSpeed

    -- 自动发射(炮台下)特效
    local effectLockCannon
    -- 自动激光(炮台下)特效
    local effectLaserCannon
    -- 锁定鱼特效(加在nodeLock上)
    local effectLockFish

    -- 是否有上次锁定的鱼(判断锁定状态是第一次出现还是切换不同的鱼)
    local hasPrevLockFish = false
    -- 倍率
    local ratioText

    -- 激光
    local laserNode
    -- 激光特效(炮口)
    local laserMuzzleEffect
    -- 激光特效(目标)
    local laserTargetEffect

    local action = cc.RepeatForever:create(cc.RotateBy:create(3.0, 360))

    local isEnable = false

    -- 炮台相关
    local prevCannonType
    -- 炮台底座
    local cannonPedestal

    -- 位置提示(自己)
    local yourSitTipsNode

    local function GetSitId()
        local sitId = sitId
        if isRotate then sitId = 3 - sitId end
        return sitId
    end

    local function AddEffect(node, name1, name2)
        local effect = cc.Sprite:createWithSpriteFrameName(name2)
        local effect1 = cc.Sprite:createWithSpriteFrameName(name1);

        local size = effect:getContentSize()
        effect1:setPosition(size.width / 2, size.height / 2)
        effect1:runAction(action:clone())

        size = node:getContentSize()
        effect:addChild(effect1)
        effect:setPosition(size.width / 2, size.height / 2)
        effect:setVisible(false)

        node:addChild(effect)
        return effect
    end

    local function UpdateCSCannonSkin()
        if not FF_G.IsCSGaming then return end
        local type = GetCsSkinType()
        if type == prevCannonType then return end
        cannonSprite:setSpriteFrame(string.format("cs_cannon_%d.png", type))
        cannonSprite:setAnchorPoint(cc.p(0.175, 0.5))
        prevCannonType = type
    end

    local function SwitchCannonType(type)
        if FF_G.IsCSGaming then return false end
        if type == prevCannonType then return false end
        cannonSprite:setSpriteFrame(string.format("pao_%02d.png", type))
        cannonSprite:setAnchorPoint(cc.p(0.175, 0.495))
        prevCannonType = type
        --print("switch cannon type:" .. type)
        return true
    end

    local function InitCannon()
        local cannonBaseName = FF_G.IsCSGaming and "cs_cannon_background.png" or "paotaijizuo.png"
        cannonPedestal = cc.Sprite:createWithSpriteFrameName(cannonBaseName)
        cannonPedestal:setPosition(fireX, fireY)
        local size = cannonPedestal:getContentSize()
        cannonSprite = cc.Sprite:create()
        cannonSprite:setPosition(size.width / 2, size.height / 2)
        cannonSprite:setRotation(-90)
        local node = FF_G_Client.GetNodeByNodeIndex(FF_G.kNodeIndex_Top)
        cannonPedestal:addChild(cannonSprite)
        node:addChild(cannonPedestal)
        SwitchCannonType(this:GetTypeId())
        UpdateCSCannonSkin()
    end

    local function InitYourSitTipsNode()
        if not isSelf then return end
        local root = FF_G_Client.GetNodeByNodeIndex(FF_G.kNodeIndex_Top)
        local node = cc.Node:create()
        node:setPosition(fireX, fireY)
        local circle = cc.Sprite:createWithSpriteFrameName("nideweiziguangquan.png")
        --circle:setPosition(0, -30)
        circle:setScale(0.85)
        circle:runAction(cc.RepeatForever:create(cc.Sequence:create(
                cc.ScaleTo:create(1.0, 1.15),
                cc.ScaleTo:create(1.0, 0.85)
        )))
        circle:runAction(cc.RepeatForever:create(cc.Sequence:create(
                cc.FadeIn:create(1.0),
                cc.FadeOut:create(1.0)
        )))

        local sign = fireY > 0 and -1 or 1
        local tips = cc.Sprite:createWithSpriteFrameName("nideweizi.png")
        tips:setScale(sign, sign)
        tips:setPosition(0, 310 * sign)
        tips:runAction(cc.RepeatForever:create(cc.Sequence:create(
                cc.MoveTo:create(0.5, cc.p(0, 280 * sign)),
                cc.MoveTo:create(0.5, cc.p(0, 310 * sign))
        )))

        node:addChild(circle)
        node:addChild(tips)
        root:addChild(node, -1)
        yourSitTipsNode = node
    end

    local function RemoveYourSitTips()
        if not yourSitTipsNode then return end
        yourSitTipsNode:removeFromParent()
        yourSitTipsNode = nil
    end

    -- 自动开发、锁定、激光按钮
    local function InitButtons()
        if not isSelf then return end
        local lockBtn = ccui.Button:create("anniu_suoding.png", "", "", ccui.TextureResType.plistType)
        local autoFireBtn = ccui.Button:create("anniu_zidong.png", "", "", ccui.TextureResType.plistType)
        -- 激光
        local laserBtn = ccui.Button:create("anniu_jiguang.png", "", "", ccui.TextureResType.plistType)
        local speedBtn = ccui.Button:create("anniu_jisu.png", "", "", ccui.TextureResType.plistType)

        local offY = -gy / 2 + 50

        lockBtn:setPosition(0, offY + 10)
        autoFireBtn:setPosition(-80, offY + 10)
        laserBtn:setPosition(80, offY + 10)
        speedBtn:setPosition(80, offY + 10)

        if FF_G.IsCSGaming then
            laserBtn:setVisible(false)
        else
            speedBtn:setVisible(false)
        end

        lockBtn:addTouchEventListener(function(_, type)
            if type ~= ccui.TouchEventType.ended then return end
            player:SwitchLockState()
            player:SyncLockStateMsg()
            if player:IsLockState() then
                local x, y = FF_G_Client.ConvertToUiPos(srcX, srcY)
                local ret, action = root:ShowEffect("actions/effect/lock/fish_suoding.actions", "fish_suoding",
                        "", FF_G.kNodeIndex_Ui, x, y + 150, false)
                assert(ret)
                action:SetLoop(1)
                local anim = action:GetAnim()
                local node = FF_G_Client.GetAnimRootNode(anim)

                local tips = cc.Sprite:createWithSpriteFrameName("suodingziti.png")
                node:addChild(tips)
                FF_G_Client.PushNode(tips)
                anim:BindSlot("", "suoding")
            end
        end)
        autoFireBtn:addTouchEventListener(function(_, type)
            if type ~= ccui.TouchEventType.ended then return end
            player:SwitchAutoFireState()
            player:SyncAutoFireStateMsg()
        end)
        laserBtn:addTouchEventListener(function(_, type)
            if type ~= ccui.TouchEventType.ended then return end
            player:SwitchLaserState()
            player:SyncLaserStateMsg()
        end)
        speedBtn:addTouchEventListener(function(_, type)
            if type ~= ccui.TouchEventType.ended then return end
            t.speedUp = not t.speedUp
        end)

        --local actionRotate = cc.RepeatForever:create(cc.RotateBy:create(3.0, 360))

        effectLock = AddEffect(lockBtn, "zidongtexiaoquan_01.png", "zidongtexiaoquan_02.png")
        effectFire = AddEffect(autoFireBtn, "zidongtexiaoquan_01.png", "zidongtexiaoquan_02.png")
        effectSpeed = AddEffect(speedBtn, "zidongtexiaoquan_01.png", "zidongtexiaoquan_02.png")
        effectLaser = AddEffect(laserBtn, "anniu_jiguang_texiao_01.png", "anniu_jiguang_texiao_02.png")

        uiRoot:addChild(lockBtn)
        uiRoot:addChild(autoFireBtn)
        uiRoot:addChild(laserBtn)
        uiRoot:addChild(speedBtn)
    end

    -- 玩家炮台下方特效
    local function InitPlayerEffect()
        -- 自动发射特效
        local effect = cc.Sprite:createWithSpriteFrameName("zidongkaipao.png")
        effect:runAction(action:clone())
        effect:setVisible(player:IsLockState())
        effect:setLocalZOrder(-1)
        effect:setPosition(fireX, fireY)

        -- 激光特效
        local laser = FF_G_Client.CreateFrameAnim("lightning_background (%d).png", 1, 8)
        laser:setVisible(player:IsLaserState())
        laser:setPosition(fireX, fireY)

        uiRootBottom:addChild(effect)
        uiRootBottom:addChild(laser)

        effectLockCannon = effect
        effectLaserCannon = laser
    end

    -- 鱼锁定特效
    local function InitLockFishEffect()
        if not isSelf then return end
        local containerLock = nodeRoot:getChildByName("nodeLock")
        local effect = cc.Sprite:createWithSpriteFrameName("suodingquan_01.png")
        local effect1 = cc.Sprite:createWithSpriteFrameName("suodingquan_02.png")

        local size = effect:getContentSize()
        effect1:setPosition(size.width / 2, size.height / 2)
        effect1:setScale(0.8)
        effect1:runAction(cc.RepeatForever:create(cc.Sequence:create(
                cc.ScaleTo:create(0.25, 1.2),
                cc.ScaleTo:create(0.25, 0.8),
                nil
        )))

        local aimFish = player:GetAimFish()
        local hasAimFish = not aimFish:IsNull()
        effect:runAction(action:clone())
        effect:setVisible(hasAimFish)
        effect:addChild(effect1)
        --containerLock:removeAllChildren()
        containerLock:addChild(effect)

        if hasAimFish then
            local lX, lY = aimFish:GetCurrentLockPoint()
            effect:setPosition(lX, lY)
            hasPrevLockFish = true
        end

        effectLockFish = effect
    end

    local ratioCount = root:GetRatioCount()
    --print("ratio count:" .. ratioCount)
    local UpdateRatio = function()
        local ratio = this:GetRatio() / FF_G.ExchangeRate
        ratioText.SetString("" .. ratio)
    end

    -- 倍率相关
    local function InitRatio()
        local srcX, srcY = srcX, srcY
        if isRotate then
            srcX, srcY = -srcX, -srcY
        end
        local sitId = GetSitId()
        local bgName = "paotaixianshijinbihese.png"
        if isSelf then
            local minusRatio = ccui.Button:create("anniu_jianhao.png", "", "", ccui.TextureResType.plistType)
            local plusRatio = ccui.Button:create("anniu_jiahao.png", "", "", ccui.TextureResType.plistType)

            minusRatio:addTouchEventListener(function(_, type)
                if type ~= ccui.TouchEventType.ended then return end
                if not isEnable then return end
                local index = this:GetRatioIndex() - 1
                if index < 0 then
                    index = ratioCount - 1
                end
                this:SetRatioByIndex(index, true)
                --this:SetRatio(math.max(this:GetRatio() - root:GetRatioChangeValue(),
                --        root:GetRatioMin()))
            end)
            plusRatio:addTouchEventListener(function(_, type)
                if type ~= ccui.TouchEventType.ended then return end
                if not isEnable then return end
                local index = this:GetRatioIndex() + 1
                if index >= ratioCount then
                    index = 0
                end
                this:SetRatioByIndex(index, true)
                --this:SetRatio(math.min(this:GetRatio() + root:GetRatioChangeValue(),
                --        root:GetRatioMax()))
            end)

            minusRatio:setPosition(srcX - 100, srcY + 10)
            plusRatio:setPosition(srcX + 100, srcY + 10)

            uiRoot:addChild(minusRatio)
            uiRoot:addChild(plusRatio)
            bgName = "paotaixianshijinbilanse.png"
        end
        local ratioBg = cc.Sprite:createWithSpriteFrameName(bgName)
        local size = ratioBg:getContentSize()
        --local ratio = ccui.Text:create()
        local ratio = FF_G_Client.CreateNumText("no1_%s.png", 21, 28)
        if sitId > 1 then
            -- top
            ratioBg:setAnchorPoint(0.5, 0)
            ratioBg:setPosition(srcX, gy / 2 + 8)
            ratioBg:setScale(1.0, -1.0)
            ratio.node:setScale(1.0, -1.0)
        else
            ratioBg:setAnchorPoint(0.5, 0)
            ratioBg:setPosition(srcX, -gy / 2 - 8)
        end
        --ratio.SetString("" .. this:GetRatio())
        --ratio:setFontSize(24)
        ratio.node:setPosition(size.width / 2, size.height / 2)
        ratioBg:addChild(ratio.node)

        uiRoot:addChild(ratioBg);
        ratioText = ratio
        UpdateRatio()
    end

    -- 激光
    local function InitLaser()
        local laser = FF_G_Client.CreateFrameAnim("LightningPillar (%d).png", 1, 16, 0.025)
        laser:setAnchorPoint(0.5, 0)
        laser:setPosition(fireX, fireY)
        laser:setVisible(false)

        local laserMuzzle = FF_G_Client.CreateFrameAnim("lightning_root (%d).png", 1, 4, 0.035)
        laserMuzzle:setAnchorPoint(0.5, 0)
        laserMuzzle:setScale(2.25)
        laserMuzzle:setVisible(false)

        local laserTarget = FF_G_Client.CreateFrameAnim("TargetEffect (%d).png", 1, 24, 0.025)
        laserTarget:setScale(2)
        laserTarget:setVisible(false)

        uiRootBottom:addChild(laser)
        uiRootBottom:addChild(laserMuzzle)
        uiRootBottom:addChild(laserTarget)

        laserNode = laser
        laserMuzzleEffect = laserMuzzle
        laserTargetEffect = laserTarget
    end

    -- key: fish id
    -- value: time
    local lastAimTime = {}
    local lastClearAimTime = root:CurrentTimePoint()

    -- clear old data
    local function ClearLastAimData(tp)
        --local tp = root:CurrentTimePoint()
        local ids = {}
        for id, tp1 in pairs(lastAimTime) do
            if tp1 > tp or tp - tp1 > 10 then
                table.insert(ids, id)
            end
        end
        for _, id in ipairs(ids) do
            lastAimTime[id] = nil
        end
        --print("clear aim data.", #ids)
        lastClearAimTime = tp
    end

    local function GetLastAimTime(fishId)
        return lastAimTime[fishId] or 0
    end

    local function InitTouchEvent()
        if not isSelf then return end

        local onTouch = function(touch)
            local destPos = nodeRoot:convertTouchToNodeSpace(touch)
            if player:IsLockState() then
                local aimFish = player:GetAimFish()
                local tp = root:CurrentTimePoint()
                local allFish = player:GetAllFishByCondition(destPos.x, destPos.y, 5)
                local touchedFish = #allFish > 0
                if not aimFish:IsNull() and aimFish:Attackable() and
                        (aimFish:IsIntersect(destPos.x, destPos.y, 5) and
                                tp - GetLastAimTime(aimFish:GetId()) > 0.5 or not touchedFish) then
                else
                    if not touchedFish then
                        player:ClearAimFish()
                    else
                        --print(fish:GetId())
                        table.sort(allFish, function(fish1, fish2)
                            local time1 = GetLastAimTime(fish1:GetId())
                            local time2 = GetLastAimTime(fish2:GetId())
                            if time1 == time2 then
                                return fish1:GetPriority() > fish2:GetPriority()
                            end
                            return time1 < time2
                        end)
                        local fish = allFish[1]
                        if not fish:IsSame(aimFish) then
                            local fishId = fish:GetId()
                            --print("switch aim fish:", fishId)
                            player:SetLastFireTimePointToNow()
                            player:SetAimFishById(fishId)
                            player:SyncAimStateMsg()
                            lastAimTime[fishId] = tp
                        end
                    end
                end
            else
                local angle = root:GetAngle(fireX, fireY, destPos.x, destPos.y)
                angle = FF_G.fixedCannonAngle(isInBottomSit, angle)
                this:SetAngle(angle)
            end
        end

        local listener = cc.EventListenerTouchOneByOne:create()
        listener:setSwallowTouches(true)
        listener:registerScriptHandler(function(touch)
            if not isEnable then return false end
            onTouch(touch)
            player:SetFire(true)
            return true
        end, cc.Handler.EVENT_TOUCH_BEGAN)
        listener:registerScriptHandler(function(touch)
            if not player:IsLockState() then
                onTouch(touch)
            end
        end, cc.Handler.EVENT_TOUCH_MOVED)
        listener:registerScriptHandler(function(touch)
            if not player:IsLockState() then
                onTouch(touch)
            end
            player:SetFire(false)
        end, cc.Handler.EVENT_TOUCH_ENDED)
        listener:registerScriptHandler(function()
            player:SetFire(false)
        end, cc.Handler.EVENT_TOUCH_CANCELLED)
        director:getEventDispatcher():addEventListenerWithSceneGraphPriority(listener, uiRoot)

    end

    local function FireAble()
        local ratio = this:GetRatio()
        local moneyType = player:GetMoneyType()
        if moneyType == 0 then
            return player:GetShowCoin() >= ratio, 0
        end
        local bindCoin = player:GetShowBindCoin()
        --print("bind:" .. bindCoin .. "," .. ratio)
        return bindCoin >= ratio, 1
    end

    local laserMusicEffectId
    local function updateLaserMusicEffect(showLaser)
        if cc.UserDefault:getInstance():getBoolForKey("effect", true) == false then
            showLaser = false
        end
        if showLaser and laserMusicEffectId == nil then
        laserMusicEffectId = FF_G.playEffect("ThunderDragonElectricity", true)
        elseif not showLaser and laserMusicEffectId ~= nil then
        FF_G.stopEffect(laserMusicEffectId)
        laserMusicEffectId = nil
        end
        end

    lua:Set_onInit(function()
        --print("Cannon Init.")

        InitTouchEvent()

        InitButtons()
        InitPlayerEffect()
        InitLockFishEffect()
        InitRatio()
        InitLaser()
        InitCannon()
        InitYourSitTipsNode()

        anim:EnableSmoothRotation()

        uiRoot:setLocalZOrder(-1)
        nodeUi:addChild(uiRoot)
        uiRootBottom:setLocalZOrder(-1)
        nodeEffectTop:addChild(uiRootBottom)
        return 0
    end)

    lua:Set_onUnInit(function()
        --print("Cannon UnInit.")
        if uiRoot ~= nil then
            uiRoot:removeFromParent()
            uiRoot = nil
        end
        if uiRootBottom ~= nil then
            uiRootBottom:removeFromParent()
            uiRootBottom = nil
        end
        if effectLockFish ~= nil then
            effectLockFish:removeFromParent()
            effectLockFish = nil
        end
        if cannonPedestal ~= nil then
            cannonPedestal:removeFromParent()
            cannonPedestal = nil
        end
        RemoveYourSitTips()
        updateLaserMusicEffect(false)
    end)

    local lastCoinNotEnoughTipsTp = 0
    lua:Set_onUpdate(function(dt)
        local enable = this:IsEnable()
        isEnable = enable
        if not enable then
            hasPrevLockFish = false
            return 0
        end

        if SwitchCannonType(this:GetTypeId()) then
            if isSelf then
                this:SyncTypeId()
            end
        end
        UpdateCSCannonSkin()

        local tp = root:CurrentTimePoint()
        if tp < lastClearAimTime or tp - lastClearAimTime > 10 then
            ClearLastAimData(tp)
        end

        if cannonSprite then
            local rotation = 360 - this:GetAngle() / math.pi * 180
            if FF_G.IsCSGaming then
                cannonSprite:setRotation(rotation)
            else
                cannonPedestal:setRotation(rotation + 90)
            end
        end

        -- 这里需要等player update完之后再调用
        --FF_G.AddTimerTask(0, function()
            local aimFish = player:GetAimFish()
            local hasAimFish = not aimFish:IsNull()
            if isSelf then
                -- 当前玩家逻辑
                local isLock = player:IsLockState()
                local isLaser = player:IsLaserState()
                local autoFire = player:IsAutoFireState() or (isLaser and isLock)
                local nextLockFish = aimFish
                if player:IsFire() or autoFire then
                    local fireAble, moneyType = FireAble()
                    if not fireAble then
                        if tp - lastCoinNotEnoughTipsTp >= 3 then
                            -- show tips
                            local fn = moneyType == 0 and "ndjbbz.png" or "ndbdjbbz.png"
                            local sprite = cc.Sprite:createWithSpriteFrameName(fn)
                            sprite:setScale(0)
                            sprite:runAction(cc.Sequence:create(
                                    cc.ScaleTo:create(0.25, 1, 1.5),
                                    cc.ScaleTo:create(0.15, 1, 1),
                                    cc.DelayTime:create(2.5),
                                    cc.ScaleTo:create(0.15, 1, 1.5),
                                    cc.ScaleTo:create(0.25, 1, 0),
                                    cc.RemoveSelf:create()
                            ))
                            FF_G_Client.AddNodeTo(sprite, FF_G.kNodeIndex_UiTop)
                            lastCoinNotEnoughTipsTp = tp
                            FF_G.Broadcast.sendBroadcast(FF_G.kBroadcastKey_CoinNotEnough, {
                                playerId = player:GetId(),
                                moneyType = moneyType,
                            })
                        end
                        if isLaser then
                            player:SetLaserState(false)
                            player:SyncLaserStateMsg()
                        end
                        if autoFire then
                            player:SetAutoFireState(false)
                            player:SyncAutoFireStateMsg()
                        end
                        return 0
                    end
                    player:Fire()
                    FF_G.Broadcast.sendBroadcast(FF_G.kBroadcastKey_Fire, {
                        playerId = player:GetId(),
                    })
                    RemoveYourSitTips()
                end
                if isLock then
                    if hasAimFish then
                        if not aimFish:Attackable() then
                            if autoFire then
                                nextLockFish = player:GetNextSelectedFish()
                            else
                                nextLockFish = root:CreatNullFish()
                            end
                        end
                    elseif autoFire then
                        nextLockFish = player:GetNextSelectedFish()
                    end
                else
                    --player:ClearAimFish()
                    nextLockFish = root:CreatNullFish()
                end

                if not aimFish:IsSame(nextLockFish) then
                    if nextLockFish:IsNull() then
                        player:ClearAimFish()
                    else
                        --player:SetAimFish(nextLockFish)
                        player:SetAimFishById(nextLockFish:GetId())
                    end
                    player:SyncAimStateMsg()
                end
            else
                if not FireAble() then
                    if player:IsLaserState() then
                        player:SetLaserState(false)
                    end
                    if  player:IsAutoFireState() then
                        player:SetAutoFireState(false)
                    end
                    return 0
                end
            end
        --end)
        return 0
    end)

    --local prevCoin
    lua:Set_onDraw(function()
        uiRoot:setVisible(isEnable)
        uiRootBottom:setVisible(isEnable)
        cannonPedestal:setVisible(isEnable)
        if effectLockFish and not isEnable then effectLockFish:setVisible(false) end
        if not isEnable then
            updateLaserMusicEffect(false)
            return
        end

        -- 锁定鱼相关
        local aimFish = player:GetAimFish()
        local hasAimFish = not aimFish:IsNull() and aimFish:Attackable()
        local lockState = player:IsLockState()
        local laserState = player:IsLaserState()

        -- 是否显示激光
        local showLaser = hasAimFish and lockState and laserState and player:GetShowCoin() > 0

        -- 调整炮台角度
        if hasAimFish then
            local dx, dy = aimFish:GetCurrentLockPoint()
            local angle = root:GetAngle(fireX, fireY, dx, dy)
            angle = FF_G.fixedCannonAngle(isInBottomSit, angle)
            this:SetAngle(angle)
        end

        if isSelf then
            updateLaserMusicEffect(showLaser)
            effectLock:setVisible(lockState)
            effectFire:setVisible(player:IsAutoFireState())
            effectLaser:setVisible(laserState)
            effectSpeed:setVisible(t.speedUp)
            if FF_G.IsCSGaming then
                player:SetBulletCd(t.speedUp and FF_G.GameConfig.CS.SpeedUpFireCd
                        or FF_G.GameConfig.CS.NormalFireCd)
            end

            local showLockFish = hasAimFish and not showLaser
            effectLockFish:setVisible(showLockFish)
            if showLockFish then
                local dx, dy = aimFish:GetCurrentLockPoint()
                --effectLockFish:setPosition(lX, lY)
                if hasPrevLockFish then
                    local sx, sy = effectLockFish:getPosition()
                    local angle = root:GetAngle(sx, sy, dx, dy)
                    local dis = math.min(root:GetDistance(sx, sy, dx, dy), 25.0)
                    dx = sx + dis * math.cos(angle)
                    dy = sy + dis * math.sin(angle)
                    effectLockFish:setPosition(dx, dy)
                else
                    effectLockFish:setScale(10)
                    effectLockFish:setPosition(dx, dy)
                    effectLockFish:runAction(cc.ScaleTo:create(0.15, 1.0))
                end
                hasPrevLockFish = true
            else
                hasPrevLockFish = false
            end
        end

        if showLaser then
            local dx, dy = aimFish:GetCurrentLockPoint()
            local arc = this:GetAngle()

            local offX, offY = root:Rotate(90, 0, arc)
            local offX1, offY1 = root:Rotate(125, 0, arc)
            local x, y = fireX + offX, fireY + offY
            local x1, y1 = fireX + offX1, fireY + offY1

            local dis = root:GetDistance(x1, y1, dx, dy)

            local angle = 90 - arc * (180 / math.pi)
            local angle1 = 90 - root:GetAngle(x1, y1, dx, dy) * (180 / math.pi)

            laserNode:setScaleY(dis / laserNode:getContentSize().height)
            laserNode:setRotation(angle1)
            laserNode:setPosition(x1, y1)

            laserMuzzleEffect:setRotation(angle)
            laserMuzzleEffect:setPosition(x, y)
            laserTargetEffect:setPosition(dx, dy)
        end

        laserNode:setVisible(showLaser)
        laserMuzzleEffect:setVisible(showLaser)
        laserTargetEffect:setVisible(showLaser)

        effectLockCannon:setVisible(player:IsLockState())
        effectLaserCannon:setVisible(player:IsLaserState())

        UpdateRatio()
    end)
end

return t, funcs