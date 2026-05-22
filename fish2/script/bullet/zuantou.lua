-- bullet/zuantou.lua
local this, lua, root = ...

-- 拖尾效果
local motion
-- root 节点
local node

local anim = this:GetAnim()

local State_Move        = 0
local State_WaitBoom    = 1
local State_Boom        = 2

local t = {
    --startTime = root:CurrentTimePoint(),
    time = 0,
    -- 0.子弹状态 1.等待爆炸 2.爆炸
    state = State_Move,
    hasBoom = false,
    speed = 1100,
    anim = "move2",
    scale = 1.5,
    value = 0,      -- 子弹打死鱼的价值
}

local cd = {}
-- 保留至少20%子弹到boom阶段使用
local boomBulletCount = 0

local CollisionChecks = function()
    if FF_G.IsServer then
        if t.state == State_WaitBoom then
            return
        end
        local time = root:CurrentTimePoint()
        local fish = this:CollisionChecks()
        local cannon = this:GetCannon()
        local cannonId = cannon:GetId()
        -- 剩余价值
        local value = this:GetLockValue()
        local bulletId = this:GetId()
        local ratio = this:GetRatio()
        local count = math.floor(value / ratio)
        --print("least bullet:", count)

        -- 当前阶段子弹已经用完
        if t.state == State_Move and count <= boomBulletCount then
            return
        end

        local bulletStatus = t.state == State_Move
        local destFish = {}
        -- 期望的子弹数
        local expectationCount = 0
        for _, fish1 in ipairs(fish) do
            local fishId = fish1:GetId()
            --print("zuantou fish:", fishId, bulletStatus, fish1:IsNormalFish(), cd[fishId], time)
            -- 只能打死普通鱼
            --if fish1:IsNormalFish() or fish1:IsGoldenFish() and (not bulletStatus or fish1:GetCoin() <= 40) and
            --        (not bulletStatus or cd[fishId] == nil or time - cd[fishId] > 1.0) then
                if (fish1:IsNormalFish() or fish1:IsGoldenFish()) and (not bulletStatus or fish1:GetCoin() <= 40) and
                        (not bulletStatus or cd[fishId] == nil or time - cd[fishId] > 1.0) then
                table.insert(destFish, fish1)
                cd[fishId] = time
                local coin = math.min(20, math.floor(fish1:GetCoin() * 1.0))
                expectationCount = expectationCount + coin
                --print("hitFish:", fishId, time)
            end
        end
        local len = #destFish
        if (len > 0) then
            local useCount = count
            if bulletStatus then
                useCount = math.min(count - boomBulletCount, expectationCount)
            end
            this:HitFish(destFish, cannonId, bulletId, useCount, ratio, this:GetAngle(), 100)
            --print("hitFish, use bullet:", useCount, len)
            this:SetLockValue(value - useCount * ratio)
            --this:NotifySyncLockValue()
            --cannon:UseBullets(useCount)
            --cannon:NotifySyncLockValue();
        end
    end
end

local MoveEndTp     = 8.0
local WaitBoomEndTp = 11.0
local BoomEndTp     = 11.98

lua:Set_onUpdate(function(dt)
    this:SetResponsed(false)
    --local time = root:CurrentTimePoint()
    t.time = t.time + dt
    if t.state == State_Move then
        --if time - t.startTime >= 5.0 then
        if t.time >= MoveEndTp then
            t.anim = "drift"
            t.speed = 800
            --this:GetAnim():SetAnim(t.anim)
            anim:SetAnim(t.anim)
            this:SetSpeed(t.speed)
            t.state = State_WaitBoom
            if not FF_G.IsServer then
                node:runAction(cc.RepeatForever:create(cc.RotateBy:create(3.0, 360)))
                node:runAction(cc.RepeatForever:create(cc.Sequence:create(
                        cc.ScaleTo:create(2.0, 2.5),
                        cc.ScaleTo:create(2.0, 1.5)
                )))
            end
        end
        CollisionChecks()
        --this:Forward(dt)
    elseif t.state == State_WaitBoom then
        --if time - t.startTime >= 7.0 then
        if t.time >= WaitBoomEndTp then
            t.anim = "boom"
            t.speed = 0
            t.scale = 12.5
            --local anim = this:GetAnim()
            anim:SetAnim(t.anim)
            anim:SetScale(t.scale, t.scale)
            this:SetSpeed(t.speed)
            t.state = State_Boom
            if not FF_G.IsServer then
                node:stopAllActions()
                node:setRotation(0)
                FF_G.playEffect("drill_bomb")
            end
        end
        --this:Forward(dt)
    elseif t.state == State_Boom then
        --if time - t.startTime >= 7.1 and not t.hasBoom then
        if not t.hasBoom then
            -- boom
            CollisionChecks()
            t.hasBoom = true
        end
        --if time - t.startTime >= 7.98 then
        if t.time >= BoomEndTp then
            -- boom end
            if not FF_G.IsServer then
                if t.value > 0 then
                    FF_G_Client.ShowFishDeathEffect(this:GetPlayer():GetId(), FF_G.FishInfo.DrillCarb.typeId, t.value)
                end
            end
            return 1
        end
    end
    if t.state < State_Boom then
        if this:Forward(dt) then
            if not FF_G.IsServer then
                root:ShakeScreen(0.15, 12)
            end
        end
    end
    --if t.state < State_WaitBoom then
    --    CollisionChecks()
    --end
    --print("lock value2:" .. this:GetLockValue())
    return 0
end)

local function Init()
    anim:SetAnim(t.anim)
    anim:SetScale(t.scale, t.scale)
    this:SetSpeed(t.speed)
    this:SetPower(100)
    this:SetFixedBounds(true)
    --local cannon = this:GetCannon()
end

if FF_G.IsServer then
    lua:Set_onInit(function()
        --print("zuantou bullet init server.")
        Init()
        local value = this:GetLockValue()
        local ratio = this:GetRatio()
        boomBulletCount = math.floor(value / ratio * 0.2)
        --print("boom bullet count:", boomBulletCount)
        return 0
    end)
end
if not FF_G.IsServer then
    local director = cc.Director:getInstance()
    local scene = FF_G_Client.GetRootNode()
    local nodeRoot = scene:getChildByName("root")
    local nodeTop = nodeRoot:getChildByName("nodeTop")

    lua:Set_onInit(function()
        --print("zuantou bullet init.")
        Init()

        anim:PushRootNode()
        node = director:popNode()

        if t.state == State_WaitBoom then
            node:runAction(cc.RepeatForever:create(cc.RotateBy:create(3.0, 360)))
            node:runAction(cc.RepeatForever:create(cc.Sequence:create(
                    cc.ScaleTo:create(2.0, 2.5),
                    cc.ScaleTo:create(2.0, 1.5)
            )))
        end

        local x, y = this:GetPos()
        --local texture = cc.SpriteFrameCache:getInstance():getSpriteFrameByName("fashe_tuowei.png"):getTexture()
        motion = cc.MotionStreak:create(3.0, 1.0, 70, cc.WHITE, "ui/base/fashe_tuowei.png")
        motion:setAnchorPoint(0.5, 0.5)
        motion:setPosition(x, y)
        nodeTop:addChild(motion, -1)
        FF_G.Broadcast.sendBroadcast(FF_G.kBroadcastKey_Fire, {
            playerId = this:GetCannon():GetPlayer():GetId(),
        })
        return 0
    end)

    lua:Set_onUnInit(function()
        --print("zuantou bullet UnInit.")
        if motion ~= nil then
            motion:removeFromParent()
            motion = nil
        end
        FF_G.Broadcast.sendBroadcast(FF_G.kBroadcastKey_Fire, {
            playerId = this:GetCannon():GetPlayer():GetId(),
        })
        this:SetResponsed(true)
    end)

    lua:Set_onDraw(function()
        local x, y = this:GetPos()
        motion:setPosition(x, y)
    end)

    lua:Set_onFishDeath(function(fishId, relationFish)
        -- 这里做了一个特殊处理来更新子弹的lock value.
        if fishId ~= -1 then
            this:SetLockValue(fishId)
        end
        --table.insert(relationFish, fishId)
        local player = this:GetPlayer()
        local cannonId = this:GetCannon():GetId()
        local bulletId = this:GetId()
        local ratio = this:GetRatio()
        local angle = this:GetAngle()
        local power = this:GetPower()
        -- 子弹状态才有击退效果
        if t.state ~= State_Move then
            power = 0
        end
        for _, fishId1 in ipairs(relationFish) do
            --print("zuantou:fish death", fishId1, ratio)
            local fish = root:FindFish(fishId1)
            if not fish:IsNull() then
                fish:SetMoveable(false)
                fish:Death(player, cannonId, bulletId, ratio, angle, power)
                t.value = t.value + this:GetRatio() * fish:GetCoin()
                if not FF_G.IsServer then
                    if t.state == State_Move then
                        local anim = fish:GetAnimNode()
                        local x, y = anim:GetPos()
                        local ret, action = root:ShowEffect("actions/special/zuantouxie.actions", "collide_effect",
                                "", FF_G.kNodeIndex_Fishnet, x, y, false)
                        assert(ret)
                        local anim1 = action:GetAnim()
                        anim1:SetAngle(angle - math.pi / 2)
                        FF_G.playEffect("drill_hit")
                    end
                end
            end
        end
        return 0
    end)
end

lua:Set_onSerialize(function()
    GT = t
end)

lua:Set_onDeserialize(function()
    --print("zuantou bullet onDeserialize.")
    local t_ = GT
    for k, v in pairs(t_) do
        t[k] = v
    end
end)