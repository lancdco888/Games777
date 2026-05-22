-- bullet/cs_bomb.lua
local this, lua, root = ...

local anim = this:GetAnim()

-- 爆炸位置
local poses = {
    {0, 0}, -- src pos
    {0, 0},
    {-300, 200},
    {300, -200},
    {300, 200},
    {-300, -200},
    {0, 0},
    {-300, 200},
    {300, -200},
    {300, 200},
    {-300, -200},
}

local roundTime = 2.0
local maxScale = 2.5

local t = {
    srcPos = {0, 0},
    dt = 0,
    ratio = 0,
    bulletCount = 0,
    angle = 0,
    curTimes = 0,
    totalTimes = 1,
    curRoundLeftTime = roundTime,
    scale = 1,
    scaleInc = 2,   -- 放大状态
    value = 0,
    waitTime = 1.0, -- 爆炸后等一段时间
    typeId = 0,
}

-- 数字背景
local bgImg
-- 数字
local timesTxt
-- 范围
local areaNode

lua:Set_onInit(function()
    if not FF_G.IsServer then
        local node = FF_G_Client.GetAnimRootNode(anim)
        areaNode = cc.Sprite:create("ui/base/zhandanxie_baozha_01.png")
        node:addChild(areaNode)
    end
    --anim:SetAngle(t.angle)
    poses[1] = t.srcPos
    if not FF_G.IsServer then
        FF_G.Broadcast.sendBroadcast(FF_G.kBroadcastKey_Fire, {
            playerId = this:GetCannon():GetPlayer():GetId(),
        })
    end
    return 0
end)

lua:Set_onUpdate(function(dt)
    --print("zhadanxie bullet update:", t.curTimes)
    t.dt = t.dt + dt
    if t.curTimes >= t.totalTimes then
        anim:Hide()
        t.waitTime = t.waitTime - dt
        if t.waitTime <= 0 then
            if t.value > 0 then
                local fishTypeId = t.typeId
                FF_G_Client.ShowFishDeathEffect(this:GetPlayer():GetId(), fishTypeId, t.value)
            end
            return 1
        end
        return 0
    end

    local time = t.curRoundLeftTime - dt
    local destPos = poses[t.curTimes + 2]
    if time <= 0 then
        FF_G.playEffect("drill_bomb")
        local ret, action = root:ShowEffect("actions/cs/effect/bomb/bomb.actions", "bomb",
                "", FF_G.kNodeIndex_EffectTop, destPos[1], destPos[2], true)
        assert(ret)
        local anim = action:GetAnim()
        anim:SetScale(2.5, 2.5)
        if FF_G.IsServer then
            local allFish = root:AllAttackableFishInScreen()
            local destFish = {}
            for _, fish1 in ipairs(allFish) do
                local typeId = fish1:GetTypeId()
                if FF_G.IsCSNormalFish(typeId) or FF_G.IsCSCombinedFish(typeId) then
                    table.insert(destFish, fish1)
                end
            end
            --print("bomb:", tostring(#destFish))
            if #destFish > 0 then
                local cannonId = this:GetCannon():GetId()
                local id = this:GetId()
                local isLastTime = t.curTimes == t.totalTimes - 1
                local useCount = isLastTime and t.bulletCount or math.min(t.bulletCount, 100)
                this:HitFish(destFish, cannonId, id, useCount, t.ratio, 0, 0)
                t.bulletCount = t.bulletCount - useCount
                --print("bomb hitFish, use bullet:", useCount, #destFish, cannonId, id)
            end
        end
        t.curTimes = t.curTimes + 1
        t.curRoundLeftTime = roundTime + time
        if timesTxt and t.curTimes < t.totalTimes then
            timesTxt.SetString("" .. (t.curTimes + 1))
        end
        -- 每回合消耗100发子弹
        this:SetLockValue(this:GetLockValue() - 100 * t.ratio)
    else
        t.curRoundLeftTime = time
    end

    if t.scaleInc then
        t.scale = t.scale + 1 * dt
        if t.scale > maxScale then
            t.scaleInc = false
            t.scale = maxScale
        end
    else
        t.scale = t.scale - 1 * dt
        if t.scale < 1 then
            t.scaleInc = true
            t.scale = 1
        end
    end

    local prevPos = poses[t.curTimes + 1]
    --local destPos = poses[t.curTimes + 2]

    -- 一半的时间移动到目标位置
    local percent = math.min(1, (roundTime - t.curRoundLeftTime) / roundTime * 2)
    local curX = prevPos[1] + (destPos[1] - prevPos[1]) * percent
    local curY = prevPos[2] + (destPos[2] - prevPos[2]) * percent

    anim:SetScale(t.scale, t.scale)
    anim:SetPos(curX, curY)
    anim:SetAngle(t.angle)
    t.angle = t.angle + math.pi / 30
    return 0
end)

if not FF_G.IsServer then
    lua:Set_onDraw(function()
        if bgImg then
            bgImg:setRotation(-bgImg:getParent():getRotation())
        end
    end)

    lua:Set_onUnInit(function()
        FF_G.Broadcast.sendBroadcast(FF_G.kBroadcastKey_Fire, {
            playerId = this:GetCannon():GetPlayer():GetId(),
        })
        this:SetResponsed(true)
    end)
end

lua:Set_onFishDeath(function(fishId, relationFish)
    table.insert(relationFish, fishId)
    local player = this:GetPlayer()
    local cannonId = this:GetCannon():GetId()
    local bulletId = this:GetId()
    local ratio = t.ratio
    local angle = 0
    local power = 0
    for _, fishId1 in ipairs(relationFish) do
        local fish = root:FindFish(fishId1)
        if not fish:IsNull() then
            fish:SetMoveable(false)
            fish:Death(player, cannonId, bulletId, ratio, angle, power)
            t.value = t.value + this:GetRatio() * fish:GetCoin()
        end
    end
    return 0
end)

lua:Set_onSerialize(function()
    GT = t
end)

lua:Set_onDeserialize(function()
    local t_ = GT
    for k, v in pairs(t_) do
        t[k] = v
    end
end)