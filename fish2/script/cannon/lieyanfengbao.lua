-- cannon/lieyanfengbao.lua
local this, lua, root = ...

local isEnable = false
local lastSyncAngleTime = root:CurrentTimePoint()
local srcX, srcY = this:GetPos()
local player = this:GetPlayer()
local isAI = player:IsAI()
local playerId = player:GetId()
local cannonId = this:GetId()
local isSelf = false

-- 发射cd
--local fireCdFrame = 4
--local fireWaitFrames = 0
--local lastFireTime = 0
local frameCd = 0.15
local fireStartTp = 0
-- 最多同时发射的子弹数量
local bulletsLimit = 50

-- animNode cocos::Node
local node
-- 炮台底座图片
local cannonBg
local uiRoot

-- 背景火焰
local bgFireAction
-- 背景圈
local bgCircleAction

local kState_Wait = 0
local kState_Fire = 1
local kState_FireEnd = 2
local kState_WaitEnd = 3

local StartWaitTime = 4
local FireEndTime = 3
local EndWaitTime = 3

local t = {
    inited = false,
    nextId = 0,
    -- 获得的时间点
    hasTime = 0,
    ratio = 0,
    current = 0,
    count = 0,
    leastTime = 0,
    value = 0,
    state = kState_Wait,
    waitTime = StartWaitTime,
    showStartEffect = false,
    fireEnd = false,
}

-- 打死鱼价值
local valueText
-- 倒计时
local countdownText
-- 剩余子弹
local bulletCountText

local Init = function()
    if not t.inited then
        t.ratio = this:GetRatio()
        local value = this:GetLockValue()
        t.count = math.floor(value / t.ratio)
        t.current = 0
        --t.leastTime = (fireCdFrame * 0.1) * t.count
        t.leastTime = frameCd * t.count + 2.5
        t.inited = true
        --print("count:", t.count, ",leastTime:", t.leastTime)
    end
end

-- 剩余子弹
local GetCurrentBulletCount = function()
    return math.max(0, t.count - t.current)
end

local function UpdateLockValue()
    local num = GetCurrentBulletCount()
    --this:SetLockValue(num * t.ratio + t.value)
    this:SetLockValue(num * t.ratio)
end

local UpdateUi = function()
    if FF_G.IsServer then
        return
    end
    local leastTime = math.max(0, t.leastTime)
    countdownText.SetString("" .. string.format("%.1f", leastTime))
    bulletCountText.SetString("" .. GetCurrentBulletCount())
    valueText.SetString("" .. t.value / FF_G.ExchangeRate)
end

local observer = {
    onReceive = function(_, data)
        if data.playerId == playerId and data.cannonId == cannonId then
            t.value = t.value + data.value
        end
    end
}

if not FF_G.IsServer then
    isSelf = player:IsSelf()
    local isInBottomSite = FF_G_Client.IsPlayerInBottomWithRotate(player)
    local director = cc.Director:getInstance()
    local sitId = player:GetSitId()
    local isRotate = root:IsRotate()
    local isInBottom = FF_G.IsInBottomSit(sitId)

    local function InitTouchEvent()
        if not isSelf then return end
        local scene = FF_G_Client.GetRootNode()
        local nodeRoot = scene:getChildByName("root")

        local onTouch = function(touch)
            local destPos = nodeRoot:convertTouchToNodeSpace(touch)
            local angle = root:GetAngle(srcX, srcY, destPos.x, destPos.y)
            angle = FF_G.fixedCannonAngle(isInBottom, angle)
            this:SetAngle(angle)
        end

        local listener = cc.EventListenerTouchOneByOne:create()
        listener:setSwallowTouches(true)
        listener:registerScriptHandler(function(touch)
            if not isEnable then return false end
            onTouch(touch)
            return true
        end, cc.Handler.EVENT_TOUCH_BEGAN)
        listener:registerScriptHandler(function(touch)
            onTouch(touch)
        end, cc.Handler.EVENT_TOUCH_MOVED)
        listener:registerScriptHandler(function(touch)
            onTouch(touch)
        end, cc.Handler.EVENT_TOUCH_ENDED)
        listener:registerScriptHandler(function()
        end, cc.Handler.EVENT_TOUCH_CANCELLED)
        director:getEventDispatcher():addEventListenerWithSceneGraphPriority(listener, node)
    end

    -- 打死鱼价值
    local function CreateValueNode(center)
        local bg = ccui.Scale9Sprite:createWithSpriteFrameName("lieyanfengbao_kuang_1.png")
        local size = {
            width = 280,
            height = 76,
        }
        bg:setPreferredSize(size)
        bg:setPosition(center.x, center.y - 5)

        valueText = FF_G_Client.CreateNumText("no2_%s.png", 29, 40)
        valueText.node:setPosition(size.width / 2, size.height / 2 + 5)
        --valueText.node:setScale(0.85)
        bg:addChild(valueText.node)
        bg:setScale(0.68)
        return bg
    end

    local function InitCannonUi()
        cannonBg = cc.Sprite:createWithSpriteFrameName("paotaijizuo.png")
        cannonBg:setPosition(srcX, srcY)
        local size = cannonBg:getContentSize()
        local center = {
            x = size.width / 2,
            y = size.height / 2,
        }
        do
            local ret, action = root:ShowEffect("ext/flames_storm/fish_lyfb_pt/fish_lyfb_pt.actions", "fish_lyfb_fire",
                    "", FF_G.kNodeIndex_Top, center.x, center.y, false)
            assert(ret)
            local anim = action:GetAnim()
            assert(anim)
            anim:SetZ(-3)
            anim:SetScale(0.85, 0.85)
            FF_G_Client.SwitchParentTo(FF_G_Client.GetActionRootNode(action) ,cannonBg)
            bgFireAction = action
        end
        do
            local animName = t.state == kState_Wait and "fish_lyfb_ptquan" or "fish_lyfb_ptquan2"
            local ret, action = root:ShowEffect("ext/flames_storm/fish_lyfb_pt/fish_lyfb_pt.actions", animName,
                    "", FF_G.kNodeIndex_Top, center.x, center.y, false)
            assert(ret)
            local anim = action:GetAnim()
            assert(anim)
            anim:SetZ(-2)
            anim:SetScale(0.85, 0.85)
            FF_G_Client.SwitchParentTo(FF_G_Client.GetActionRootNode(action) ,cannonBg)

            local node = FF_G_Client.GetAnimRootNode(anim)
            local tips = cc.Sprite:createWithSpriteFrameName("lieyanfengbao_zuanpan.png")
            node:addChild(tips)
            FF_G_Client.PushNode(tips)
            anim:BindSlot("", "pt_quan")

            bgCircleAction = action
        end
        --local bg1 = cc.Sprite:createWithSpriteFrameName("lieyanfengbao_zuanpan.png")
        --bg1:setScale(0.55)
        --bg1:setPosition(center.x, center.y)
        --bg1:runAction(cc.RepeatForever:create(cc.RotateBy:create(2.5, -360)))

        cannonBg:setLocalZOrder(-1)
        --cannonBg:addChild(bg1, -1)
        FF_G_Client.AddNodeTo(cannonBg, FF_G.kNodeIndex_Top)
    end

    local function InitInfoUi()
        uiRoot = cc.Node:create()
        uiRoot:setPosition(srcX, srcY)
        local center = { x = 0, y = 0, }
        --local x1, y1 = FF_G.AwayTo(0, 0, 0, 30)
        local valueCenter = { x = 0, y = 30, }
        local bgOffsetY = 15
        if not FF_G_Client.IsPlayerInBottomWithRotate(player) then
            valueCenter.y = -valueCenter.y
            bgOffsetY = -bgOffsetY
        end
        --local ratioBg = CreateRatioNode(center)
        local ratioBg = FF_G_Client.CreateRatioNode(center, this:GetRatio(), isInBottomSite, isSelf)
        local valueBg = CreateValueNode(valueCenter)

        local numBg = cc.Sprite:createWithSpriteFrameName("lieyanfengbao_kuang_2.png")
        local timeBg = cc.Sprite:createWithSpriteFrameName("lieyanfengbao_kuang_2.png")
        local bulletCount = cc.Sprite:createWithSpriteFrameName("lieyanfengbao_zidan.png")
        local countdown = cc.Sprite:createWithSpriteFrameName("lieyanfengbao_daojishi.png")

        countdownText = FF_G_Client.CreateNumText("lieyanfengbao_daojishi_%s.png", 25, 35)
        bulletCountText = FF_G_Client.CreateNumText("lieyanfengbao_zidan_%s.png", 25, 35)

        local size1 = numBg:getContentSize()
        local size2 = timeBg:getContentSize()

        numBg:setScale(0.68)
        numBg:setPosition(-125, bgOffsetY)
        timeBg:setScale(0.65)
        timeBg:setPosition(125, bgOffsetY)

        countdownText.node:setPosition(size1.width / 2, size1.height / 2)
        bulletCountText.node:setPosition(size2.width / 2, size2.height / 2)

        bulletCount:setPosition(size1.width / 2, size1.height / 2 - 35)
        countdown:setPosition(size2.width / 2, size2.height / 2 - 35)

        numBg:addChild(bulletCountText.node)
        numBg:addChild(bulletCount)
        timeBg:addChild(countdownText.node)
        timeBg:addChild(countdown)

        uiRoot:addChild(ratioBg)
        uiRoot:addChild(valueBg)
        uiRoot:addChild(numBg)
        uiRoot:addChild(timeBg)
        if isRotate then
            uiRoot:setScale(-1)
        end
        FF_G_Client.AddNodeTo(uiRoot, FF_G.kNodeIndex_Top)
        if t.state == kState_Wait then
            uiRoot:setVisible(false)
        end
    end

    local function InitUi()
        InitCannonUi()
        InitInfoUi()
    end

    lua:Set_onInit(function()
        --print("lieyanfengbao Init.")
        local anim = this:GetAnim()
        anim:SetScale(1.0, 1.0)
        anim:EnableSmoothRotation()
        node = FF_G_Client.GetAnimDrawNode(anim)
        node:setAnchorPoint(0.148, 0.5)
        InitUi()
        InitTouchEvent()
        Init()
        UpdateUi()
        FF_G.Broadcast.register("LieyanfengbaoFishDeath", observer)
        UpdateLockValue()
        return 0
    end)

    lua:Set_onUnInit(function()
        print("lieyanfengbao UnInit.")
        if cannonBg ~= nil then
            cannonBg:removeFromParent()
            cannonBg = nil
        end
        if uiRoot ~= nil then
            uiRoot:removeFromParent()
            uiRoot = nil
        end
        if bgFireAction then
            bgFireAction:SetClean(true)
            bgFireAction = nil
        end
        if bgCircleAction then
            bgCircleAction:SetClean(true)
            bgCircleAction = nil
        end
        FF_G.Broadcast.unRegister("LieyanfengbaoFishDeath", observer)
    end)

    lua:Set_onDraw(function()
        local enable = isEnable and not t.hasFire
        local showUiRoot = enable and
                (t.state == kState_Fire or t.state == kState_FireEnd or t.state == kState_WaitEnd)
        cannonBg:setVisible(enable)
        uiRoot:setVisible(showUiRoot)
    end)
end

if FF_G.IsServer then
    lua:Set_onInit(function()
        --print("lieyanfengbao Init.")
        Init()
        FF_G.Broadcast.register("LieyanfengbaoFishDeath", observer)
        return 0
    end)
    lua:Set_onUnInit(function()
        --print("lieyanfengbao UnInit.")
        FF_G.Broadcast.unRegister("LieyanfengbaoFishDeath", observer)
    end)
end

local function Fire(bulletId, dt, waitTime)
    waitTime = waitTime or 0.035
    dt = math.min(dt, 0.15)
    local ratio = t.ratio
    local anim = root:CreateAnimNode("actions/special/lieyanfengbao.anims")
    anim:SetAnimIndex(1)
    anim:SetAngle(this:GetAngle())
    anim:SetPos(srcX, srcY)
    local bullet = this:CreateLuaBullet()
    bullet:SetAnim(anim)
    bullet:SetRatio(ratio)
    bullet:SetLockValue(ratio)
    bullet:SetId(bulletId)
    bullet:SetSpeed(950)
    bullet:SetWaitTime(waitTime)
    bullet:SetFireTime(root:CurrentTimePoint())
    t.nextId = bulletId + 1
    bullet:SetLuaName("lieyanfengbao.lua")
    this:SendLuaBullet(bullet, dt)
    t.current = t.current + 1
    if not FF_G.IsServer then
        local node = FF_G_Client.GetAnimDrawNode(anim)
        FF_G_Client.RunFireAction(node)
        if isSelf then
            FF_G.playEffect("storm_shoot")
        end
    end
    return bullet
end

local anim = this:GetAnim()
-- 切换到发射状态
local function ToFireState()
    t.state = kState_Fire
    anim:SetAnim("fire")
    fireStartTp = root:CurrentTimePoint()
    if not FF_G.IsServer then
        local scale = uiRoot:getScale()
        uiRoot:setScale(0)
        uiRoot:runAction(cc.Sequence:create(
                cc.Show:create(),
                cc.ScaleTo:create(0.15, scale)
        ))
        bgCircleAction:SetAction("fish_lyfb_ptquan2")
        FF_G.playEffect("v_firestorm_go")
    end
end

local function ToFireEndState()
    t.state = kState_FireEnd
    t.waitTime = FireEndTime
    anim:SetAnim("cannon")
    if not FF_G.IsServer then
        if isEnable then
            local x1, y1 = FF_G.NearTo(srcX, srcY, 0, 100)
            local x, y = FF_G_Client.ConvertToUiPos(x1, y1)
            local ret, action = root:ShowEffect("ext/flames_storm/fish_lyfb_freegame/fish_lyfb_freegame.actions", "end",
                    "", FF_G.kNodeIndex_Ui, x, y, false)
            assert(ret)
            action:SetLoops(false)
            local anim = action:GetAnim()
            assert(anim)
            anim:SetScale(0.85, 0.85)

            local node = FF_G_Client.GetAnimRootNode(anim)
            local tips = cc.Sprite:createWithSpriteFrameName("lieyanfengbao_over.png")
            node:addChild(tips)
            FF_G_Client.PushNode(tips)
            anim:BindSlot("", "end")
            FF_G.playEffect("v_firestorm_over")
        end
    end
end

local function ToEndWaitState()
    t.state = kState_WaitEnd
    t.waitTime = EndWaitTime
    if not FF_G.IsServer then
        if t.value > 0 then
            FF_G_Client.ShowFishDeathEffect(this:GetPlayer():GetId(), FF_G.FishInfo.FlamesStorm.typeId, t.value)
        end
    end
end

lua:Set_onFireSimpleBullet(function(bulletId, waitTime, dt)
    return Fire(bulletId, dt, waitTime):AsSimpleBullet()
end)

lua:Set_onFireSimpleBulletWithoutReturn(function(bulletId, waitTime, dt)
    Fire(bulletId, dt, waitTime)
end)

lua:Set_onFireLuaBullet(function(bulletId, waitTime, angle, dt)
    this:SetAngle(angle)
    return Fire(bulletId, dt, waitTime)
end)

local lastBulletTime = 0

lua:Set_onUpdate(function(dt)
    isEnable = this:IsEnable()
    --if not FF_G.IsServer then
    --    UpdateLockValue()
    --end
    if t.state == kState_Wait then
        t.waitTime = t.waitTime - dt
        if t.waitTime <= 0 then
            ToFireState()
        end
        if not t.showStartEffect and t.waitTime <= StartWaitTime - 0.5 then
            if not FF_G.IsServer then
                if isEnable then
                    local x1, y1 = FF_G.NearTo(srcX, srcY, 0, 100)
                    local x, y = FF_G_Client.ConvertToUiPos(x1, y1)
                    local ret, action = root:ShowEffect("ext/flames_storm/fish_lyfb_freegame/fish_lyfb_freegame.actions", "start",
                            "", FF_G.kNodeIndex_Ui, x, y, false)
                    assert(ret)
                    action:SetLoops(false)
                    local anim = action:GetAnim()
                    assert(anim)
                    anim:SetScale(0.85, 0.85)

                    local node = FF_G_Client.GetAnimRootNode(anim)
                    local tips = cc.Sprite:createWithSpriteFrameName("lieyanfengbao_start.png")
                    local tips2 = cc.Sprite:createWithSpriteFrameName("mianfenyouxi.png")
                    node:addChild(tips2)
                    node:addChild(tips)
                    FF_G_Client.PushNode(tips)
                    FF_G_Client.PushNode(tips2)
                    anim:BindSlot("", "freegame")
                    anim:BindSlot("", "start")
                    FF_G.playEffect("v_firestorm_free")
                end
                t.showStartEffect = true
            end
        end
    elseif t.state == kState_FireEnd then
        t.waitTime = t.waitTime - dt
        if t.waitTime <= 0 then
            ToEndWaitState()
            return 0
        end
    elseif t.state == kState_WaitEnd then
        t.waitTime = t.waitTime - dt
        if t.waitTime <= 0 then return 1 end
    elseif t.state == kState_Fire then
        t.leastTime = t.leastTime - dt
        if t.leastTime <= 0 or GetCurrentBulletCount() == 0 then
            local bulletCount = this:GetBulletCount()
            if not t.fireEnd then
                anim:SetAnim("cannon")
                t.fireEnd = true
            end
            if bulletCount == 0 then
                ToFireEndState()
                return 0
            end
        end
        --local bulletCount = this:GetBulletCount()
        --if t.leastTime <= 0 and bulletCount == 0 and not t.fireEnd then
        --    anim:SetAnim("cannon")
        --    t.fireEnd = true
        --end
        --local unusedBullets = GetCurrentBulletCount()
        --if (t.leastTime <= 0 or unusedBullets == 0)
        --        and bulletCount == 0 then
        --    ToFireEndState()
        --    return 0
        --end
    end
    --if (t.current >= t.count or t.leastTime <= 0) and this:GetBulletCount() == 0 then return 1 end
    if isEnable then
        if t.state == kState_Fire then
            if not FF_G.IsServer then
                if t.state == kState_Fire and isSelf then
                    local tp = root:CurrentTimePoint()
                    if tp - lastBulletTime > frameCd and t.leastTime > 0 and GetCurrentBulletCount() > 0
                            and this:GetBulletCount() < bulletsLimit then
                        lastBulletTime = tp
                        local bulletId = t.nextId
                        local bullet = Fire(bulletId, 0)
                        local waitTime = bullet:GetWaitTime()
                        player:SendBulletMsg(false, cannonId, bulletId, t.ratio, this:GetAngle(), waitTime)
                        --UpdateLockValue()
                    end
                end
            end
            if FF_G.IsServer then
                if isAI and t.state == kState_Fire then
                    local tp = root:CurrentTimePoint()
                    if tp - lastBulletTime > 0.1 and t.leastTime > 0 and GetCurrentBulletCount() > 0
                            and this:GetBulletCount() < bulletsLimit then
                        local nextFireTime = fireStartTp + t.current * frameCd
                        if nextFireTime <= tp then
                            local dt = math.min(tp - nextFireTime, 0.15)
                            lastBulletTime = tp - dt
                            local bulletId = t.nextId
                            local bullet = Fire(bulletId, dt)
                            local waitTime = bullet:GetWaitTime()
                            --player:SendBulletMsg(false, cannonId, bulletId, t.ratio, this:GetAngle(), waitTime)
                            --UpdateLockValue()
                            --this:NotifySendLuaBulletMsg(bullet, nextFireTime)
                            this:NotifySendSimpleBulletMsg(bulletId, waitTime, nextFireTime)
                        end
                    end
                end
            end
            if not FF_G.IsServer then
                if isSelf then
                    -- 自己的炮台角度需要同步
                    local tp = root:CurrentTimePoint()
                    if tp - lastSyncAngleTime > 0.125 then
                        if this:SyncAngleMsg() then
                            lastSyncAngleTime = tp
                        end
                    end
                end
            end
        end
    end
    if not FF_G.IsServer then
        UpdateLockValue()
    end
    return 0
end)

if not FF_G.IsServer then
    lua:Set_onDraw(function(dt)
        UpdateUi()
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
