-- cannon/zuantou.lua
local this, lua, root = ...

local isEnable = false
local lastSyncAngleTime = root:CurrentTimePoint()
--local hasFire = false

local srcX, srcY = this:GetPos()

local player = this:GetPlayer()
local isSelf = false
--local isAI = player:IsAI()
local isInBottomSit = FF_G.IsInBottomSit(player:GetSitId())

-- animNode cocos::Node
local node
-- 炮台底座图片
local cannonBg
-- 发送(自己才有)
local sendButton
local countdownNode
-- 发射倒计时
local countdownText
-- 图标
local iconSprite

local t = {
    hasFire = false,
    -- 获得的时间点
    hasTime = root:CurrentTimePoint(),
    -- 自动发射时间
    fireTime = 0,
    nextId = 0,
    lockValue = 0,
    inited = false,
}

local function Init()
    if t.inited then return end
    t.fireTime = FF_PRAMS.fireTime
    t.lockValue = this:GetLockValue()
    t.inited = true
end

local readyMusicId
local moveMusicId

local function Fire(bulletId, dt)
    --print("fire zuantou.")
    dt = math.min(dt, 0.15)
    local anim = root:CreateAnimNode("actions/special/zuantouxie.anims")
    --anim:SetAnimIndex(4)
    anim:SetAngle(this:GetAngle())
    anim:SetPos(srcX, srcY)
    local bullet = this:CreateLuaBullet()
    bullet:SetAnim(anim)
    bullet:SetRatio(this:GetRatio())
    bullet:SetLockValue(t.lockValue)
    --print("zuantou lock value:" .. t.lockValue)
    bullet:SetId(bulletId)
    bullet:SetFireTime(root:CurrentTimePoint())
    t.nextId = bulletId + 1
    bullet:SetLuaName("zuantou.lua")
    this:SendLuaBullet(bullet, dt)
    t.hasFire = true

    if not FF_G.IsServer then
        FF_G.playEffect("drill_shoot")
        readyMusicId = FF_G.stopEffect(readyMusicId)
        moveMusicId = FF_G.playEffect("drill_uncon", true)
    end

    --if not FF_G.IsServer then
    --    --node:setVisible(false)
    --    if sendButton ~= nil then sendButton:setVisible(false) end
    --end
    return bullet
end

local function FireByClient()
    local bulletId = t.nextId
    local bullet = Fire(bulletId, 0)
    this:SyncFireLuaBulletMsg(bullet)
end

if FF_G.IsServer then
    lua:Set_onInit(function()
        --print("zuantou Init.")
        Init()
        return 0
    end)
end

local function GetCountDownTime()
    return t.fireTime - root:CurrentTimePoint()
end

if not FF_G.IsServer then
    isSelf = player:IsSelf()
    local director = cc.Director:getInstance()
    local scene = FF_G_Client.GetRootNode()
    local nodeRoot = scene:getChildByName("root")
    local nodeTop = nodeRoot:getChildByName("nodeTop")
    local nodeUiRoot = scene:getChildByName("uiRoot")
    local sitId = player:GetSitId()
    local gx, gy = root:GetGSize()

    local function InitTouchEvent()
        if not isSelf then return end

        local onTouch = function(touch)
            local destPos = nodeRoot:convertTouchToNodeSpace(touch)
            --print("on touch", destPos.x, destPos.y)
            local angle = root:GetAngle(srcX, srcY, destPos.x, destPos.y)
            angle = FF_G.fixedCannonAngle(FF_G.IsInBottomSit(sitId), angle)
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

    local isInBottomSite = FF_G_Client.IsPlayerInBottomWithRotate(player)
    local uiRoot

    local function InitInfoUi()
        uiRoot = cc.Node:create()
        uiRoot:setPosition(srcX, srcY)
        local center = {
            x = 0,
            y = 0,
        }
        local offY = 40
        if not FF_G_Client.IsPlayerInBottomWithRotate(player) then
            offY = -offY
        end
        local ratioBg = FF_G_Client.CreateRatioNode(center, this:GetRatio(), isInBottomSite, isSelf)
        iconSprite = cc.Sprite:createWithSpriteFrameName("zhuantou_tubiao.png")
        iconSprite:setPosition(0, offY)
        iconSprite:setScale(0.75)

        uiRoot:addChild(ratioBg)
        uiRoot:addChild(iconSprite)
        if root:IsRotate() then
            uiRoot:setScale(-1)
        end
        FF_G_Client.AddNodeTo(uiRoot, FF_G.kNodeIndex_Top)
    end

    local function UpdateCountdownUi()
        local time = math.max(0, GetCountDownTime())
        countdownText.SetString(string.format("%ds", math.floor(time)))
    end

    local function InitCountdown()
        local root = cc.Node:create()
        root:setPosition(0, 0)

        local y = -gy / 2 + 110
        local bg = cc.Sprite:createWithSpriteFrameName("fashedaojishikuang.png")
        bg:setPosition(0, y)

        local text = FF_G_Client.CreateNumText("fashedaojishi_%s.png", 25, 32)
        text.node:setPosition(0, y + 2)

        root:addChild(bg)
        root:addChild(text.node)
        nodeUiRoot:addChild(root, -1)

        countdownNode = root
        countdownText = text
    end

    local function InitUi()
        cannonBg = cc.Sprite:createWithSpriteFrameName("paotaijizuo.png")
        cannonBg:setPosition(srcX, srcY)
        nodeTop:addChild(cannonBg, -1)

        if isSelf then
            sendButton = ccui.Button:create("fashe.png", "", "", ccui.TextureResType.plistType)
            sendButton:addTouchEventListener(function(_, type)
                if type ~= ccui.TouchEventType.ended then return end
                if t.hasFire then return end
                FireByClient()
            end)
            sendButton:setPosition(0, -gy / 2 + 40)
            nodeUiRoot:addChild(sendButton, -1)
            InitCountdown();
        end

        InitInfoUi()
    end

    lua:Set_onInit(function()
        print("zuantou Init.")
        Init()
        local anim = this:GetAnim()
        anim:SetScale(1.5, 1.5)
        anim:EnableSmoothRotation()
        anim:PushDrawNode()
        node = director:popNode()
        node:setAnchorPoint(0.148, 0.4643)
        InitTouchEvent()
        InitUi();
        if not t.hasFire then
            readyMusicId = FF_G.playEffect("drill_ready_other", true)
        end
        return 0
    end)

    lua:Set_onUnInit(function()
        print("zuantou UnInit.")
        if cannonBg ~= nil then
            cannonBg:removeFromParent()
            cannonBg = nil
        end
        if sendButton ~= nil then
            sendButton:removeFromParent()
            sendButton = nil
        end

        if countdownNode ~= nil then
            countdownNode:removeFromParent()
            countdownNode = nil
        end

        if uiRoot ~= nil then
            uiRoot:removeFromParent()
            uiRoot = nil
        end

        readyMusicId = FF_G.stopEffect(readyMusicId)
        moveMusicId = FF_G.stopEffect(moveMusicId)
    end)

    lua:Set_onDraw(function()
        local enable = isEnable and not t.hasFire
        node:setVisible(enable)
        iconSprite:setVisible(isEnable and t.hasFire)
        if isSelf then
            countdownNode:setVisible(enable)
            sendButton:setVisible(enable)
            UpdateCountdownUi()
        end
        --print("lock value1:" .. this:GetLockValue())
    end)
end

lua:Set_onFireLuaBullet(function(bulletId, waitTime, angle, dt)
    if t.hasFire then return root:CreateNullLuaBullet() end
    this:SetAngle(angle)
    return Fire(bulletId, dt)
end)

--local aiChangeAngleTime = math.random(100, 140) / 100
--local aiAutoFireTime = math.random(150, 350) / 100

local NotifyRandomAngle = function()
    local angle = math.random(30, 70) * math.pi / 100
    if not isInBottomSit then
        angle = -angle
    end
    this:SetAngle(angle)
    this:NotifySyncAngleMsg()
end

lua:Set_onUpdate(function(dt)
    isEnable = this:IsEnable()
    --print("dt:", dt)
    if not isEnable then return 0 end
    if t.hasFire and this:GetBulletCount() == 0 then return 1 end
    if not t.hasFire then
        this:SetLockValue(t.lockValue)
    end
    if FF_G.IsServer then
        if not t.hasFire then
            local autoFire = false
            --if isAI then
            --    if aiAutoFireTime > 0 then
            --        aiAutoFireTime = aiAutoFireTime - dt
            --    end
            --    if aiChangeAngleTime > 0 then
            --        aiChangeAngleTime = aiChangeAngleTime - dt
            --    end
            --
            --    if aiChangeAngleTime <= 0 then
            --        aiChangeAngleTime = math.random(50, 100) / 100
            --        NotifyRandomAngle()
            --    end
            --    if aiAutoFireTime <= 0 then
            --        autoFire = true
            --    end
            --end
            if autoFire or GetCountDownTime() <= -10 then
                local tp = root:CurrentTimePoint()
                -- 超过10秒自动发射
                NotifyRandomAngle()
                local bullet = Fire(t.nextId, 0)
                --this:NotifySyncAngleMsg()
                this:NotifySendLuaBulletMsg(bullet, tp)
            end
        end
    end
    if not FF_G.IsServer then
        if isSelf then
            if not t.hasFire and GetCountDownTime() <= 0 then
                FireByClient()
            end
            -- 自己的炮台角度需要同步
            local tp = root:CurrentTimePoint()
            if tp - lastSyncAngleTime > 0.125 then
                if this:SyncAngleMsg() then
                    lastSyncAngleTime = tp
                end
            end
        end
    end

    return 0
end)

lua:Set_onSerialize(function()
    GT = t
end)

lua:Set_onDeserialize(function()
    print("zuantou cannon onDeserialize.")
    local t_ = GT
    for k, v in pairs(t_) do
        t[k] = v
    end
end)
