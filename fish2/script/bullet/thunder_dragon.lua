-- bullet/thunder_dragon.lua
local this, lua, root = ...

local State_BoatMove            = 3
local State_HeartMoveToPlayer   = 4
local State_Show                = 5

local destUiX, destUiY = 0, -40

---- 攻击一次的时间
--local AttackSecs = 1.3333333333333333
---- 移动一次的时间
--local MoveSecs = 1.96667
---- 一次移动需要的时间
--local BoatMoveSecs = MoveSecs * 4 + AttackSecs
local BoatMoveSecs = 5
local ServerCdCheckSecs = 2.5
-- 一次移动显示爆炸效果的次数
--local ShowBombTimes = 10
-- UI飞行到玩家位置的时间
local MoveToPlayerSecs = 2.5
-- 展示的时间
local ShowSecs = 1.5
-- 每次爆炸使用的子弹数量
local useBulletCountPerTime = 100

local t = {
    inited = false,
    state = State_BoatMove,
    -- 鱼死亡时的位置
    srcX = 0,
    srcY = 0,
    --time = 0,
    timeLeft = 0,
    hasBomb = false,
    showBombEffectTimes = 0,    -- 显示爆炸的次数
    --boomLeftTime = 0,           -- 爆炸剩余时间
    bombLeftTimes = 0,          -- 剩余爆炸次数
    value = 0,                  -- 打死鱼的价值
    curBombTimes = 1,           -- 当前爆炸次数
    totalBombTimes = 0,
    deathFishCount = 0,
    fishType = 0,
    bombTimes = 0,              -- 已经爆炸的次数
    useSecs = 0,
}

local crabActions = {}
--local ballAction
--local effectAction
local ballNode

-- ui面板
local uiPanel

local CollisionChecks = function()
    --local value = this:GetLockValue()
    local fish = root:AllAttackableFishInScreen()
    local cannon = this:GetCannon()
    local cannonId = cannon:GetId()
    local bulletId = this:GetId()
    local ratio = this:GetRatio()

    local destFish = {}
    for _, fish1 in ipairs(fish) do
        if fish1:IsNormalFish() or fish1:IsGoldenFish() then
            table.insert(destFish, fish1)
        end
    end
    this:HitFish(destFish, cannonId, bulletId, useBulletCountPerTime, ratio, 0, 0)
end

lua:Set_onCreate(function()
    local anim = root:CreateAnimNode("actions/other/space.anims")
    this:SetAnim(anim)
end)

local carbBallActionCnt = 4
--local width = 1280
--if not FF_G.IsServer then
--    width = width * FF_G_Client.GetScreenScaleX()
--end
-- left, right, top, bottom
local destPos = {
    { x = 0, y = 0 },
    { x = 0, y = 0 },
    { x = 0, y = 0 },
    { x = 0, y = 0 },
}
local startPos = {
    { x = 0, y = 0 },
    { x = 0, y = 0 },
    { x = 0, y = 0 },
    { x = 0, y = 0 },
}
local angles = {
    math.pi / 2,
    -math.pi / 2,
    0,
    math.pi,
}

local ResetBombState = function(dt)
    dt = dt or 0
    t.timeLeft = BoatMoveSecs
    t.showBombEffectTimes = dt
    t.hasBomb = false
end

local ResetActions = function()
    if not FF_G.IsServer then
        for i = 1, carbBallActionCnt do
            local action = crabActions[i]
            local anim = action:GetAnim()
            anim:SetAnim("attack")
        end
    end
end

local uiRoot
lua:Set_onInit(function()
    if not t.inited then
        local value = this:GetLockValue()
        local ratio = this:GetRatio()
        local fishRatio = value / ratio
        t.totalBombTimes = math.floor(fishRatio / 100)
        t.bombLeftTimes = t.totalBombTimes
        --print(string.format("fish ratio:%d, left:%d", fishRatio, t.boomLeft))
        ResetBombState()
        t.inited = true
    end
    if not FF_G.IsServer then
        -- init actions.
        do
            --local info = FF_G.TypeIdToFishCreator[t.fishType]
            local animSecs = BoatMoveSecs - t.timeLeft
            for i = 1, carbBallActionCnt do
                local ret, action = root:ShowEffect("spine/dragon_thunder_spine.actions",
                        "attack", "", FF_G.kNodeIndex_Top, 0, 0, false)
                assert(ret)
                local pos = startPos[i]
                local anim = action:GetAnim()
                anim:SetScale(0.5, 0.5)
                anim:SetAngle(angles[i])
                anim:SetPos(pos.x, pos.y)
                anim:SetZ(2)
                anim:SetElapsedSeconds(animSecs)
                anim:Hide()
                table.insert(crabActions, action)
            end
        end

        ---- init ui panel.
        do
            local ratio = this:GetRatio()
            local parent = cc.Node:create()
            local panel = FF_G.LoadLuaFunc("script/panel/thunder_dragon.lua")(this, lua, root)
            panel.Init(parent)
            FF_G_Client.AddNodeTo(parent, FF_G.kNodeIndex_Ui)
            panel.Hide()
            panel.SetDeltaNumber(ratio)
            uiPanel = panel
            uiRoot = parent

            do
                cc.SpriteFrameCache:getInstance():addSpriteFrames("ext/ThunderDragonBall/ThunderDragonBall_0.plist")
                local node = FF_G_Client.CreateFrameAnim("ThunderDragonBall (%d).png", 1, 60, 1 / 60)
                node:setPosition(0, 50)
                parent:addChild(node)
                ballNode = node
            end
        end

        if t.useSecs < 1 then
            local ret, action = root:ShowEffect("ext/boom_coin/boom_coin.actions",
                    "coin_up", "", FF_G.kNodeIndex_Top, t.srcX, t.srcY, false)
            assert(ret)
            action:SetLoop(1)
            local anim = action:GetAnim()
            anim:SetScale(2.5, 2.5)
        end

        FF_G.Broadcast.sendBroadcast(FF_G.kBroadcastKey_Fire, {
            playerId = this:GetCannon():GetPlayer():GetId(),
        })
    end
    return 0
end)

lua:Set_onUnInit(function()
    if not FF_G.IsServer then
        uiPanel.UnInit()
        if uiRoot then
            uiRoot:removeFromParent()
            uiRoot = nil
        end
        for _, action in ipairs(crabActions) do
            action:SetClean(true)
        end
        --ballAction:SetClean(true)
        --effectAction:SetClean(true)
        FF_G_Client.ShowFishDeathEffect(this:GetPlayer():GetId(), t.fishType, t.value)
        FF_G.Broadcast.sendBroadcast(FF_G.kBroadcastKey_Fire, {
            playerId = this:GetCannon():GetPlayer():GetId(),
        })
        this:SetResponsed(true)
    end
end)

local px, py
if not FF_G.IsServer then
    local player = this:GetPlayer()
    px, py = FF_G_Client.GetPlayerUiPos(player)
    px, py = FF_G.NearTo(px, py, 0, 220)
    --px, py = FF_G.AwayTo(px, py, 100, 0)
end

local UpdateUiPos = function()
    if not FF_G.IsServer then
        local dx, dy = destUiX, destUiY
        local needMove = t.state == State_HeartMoveToPlayer
        if needMove then
            local sx, sy = destUiX, destUiY
            dx, dy = px, py
            local percent = 1.0 - t.timeLeft / MoveToPlayerSecs
            local pos = FF_G.GetPercentPos(
                    {x = sx, y = sy},
                    {x = dx, y = dy},
                    percent
            )
            dx, dy = pos.x, pos.y
        elseif  t.state == State_Show then
            dx, dy = px, py
        end
        uiRoot:setPosition(dx, dy)
        uiPanel.Show()
    end
end

---- 移动前部分(从两端往中间移动)
--local MoveFrontSecs = (BoatMoveSecs - AttackSecs) / 2
---- 移动前部分(从两端往中间移动)
--local MoveTailSecs = (BoatMoveSecs + AttackSecs) / 2

local UpdateBoatPos = function()
end

lua:Set_onUpdate(function(dt)
    t.useSecs = t.useSecs + dt
    local timeLeft = t.timeLeft - dt
    t.timeLeft = math.max(0, timeLeft)
    if t.timeLeft == 0 then
        if t.state == State_BoatMove then
            t.bombLeftTimes = t.bombLeftTimes - 1
            if t.bombLeftTimes <= 0 then
                -- 服务器到此结束
                if FF_G.IsServer then
                    return 1
                end
                -- 爆炸阶段结束
                t.state = State_HeartMoveToPlayer
                t.timeLeft = MoveToPlayerSecs
                if not FF_G.IsServer then
                    for _, action in ipairs(crabActions) do
                        action:GetAnim():Hide()
                    end
                end
            else
                ResetBombState(-timeLeft)
                ResetActions()
            end
        elseif t.state == State_HeartMoveToPlayer then
            t.state = State_Show
            t.timeLeft = ShowSecs
        elseif t.state == State_Show then
            return 1
        end
    end
    if FF_G.IsServer then
        if t.state == State_BoatMove then
            -- 触发爆炸
            if not t.hasBomb and t.timeLeft <= BoatMoveSecs - ServerCdCheckSecs then
                CollisionChecks()
                t.hasBomb = true
            end
        end
    end
    if not FF_G.IsServer then
        local showActions = false
        if t.state == State_BoatMove then
            UpdateBoatPos()
            showActions = true
        end
        for _, action in ipairs(crabActions) do
            action:GetAnim():SetVisible(showActions)
        end
        UpdateUiPos()
        if uiPanel.SetValue(t.value) then
            ballNode:runAction(cc.Sequence:create(
                    cc.ScaleTo:create(0.25, 2.5),
                    cc.DelayTime:create(0.25),
                    cc.ScaleTo:create(0.25, 1)
            ))
        end
        uiPanel.Update(dt)
        --
        ---- update lock value.
        local times = t.totalBombTimes - t.bombTimes
        local ratio = this:GetRatio()
        local lockValue = times * useBulletCountPerTime * ratio
        this:SetLockValue(lockValue)
    end
    return 0
end)

if not FF_G.IsServer then
    lua:Set_onFishDeath(function(fishId, relationFish)
        table.insert(relationFish, fishId)
        local player = this:GetPlayer()
        local cannonId = this:GetCannon():GetId()
        local bulletId = this:GetId()
        local ratio = this:GetRatio()
        local angle = this:GetAngle()
        local power = this:GetPower()
        for _, fishId1 in ipairs(relationFish) do
            --print("phoenix:fish death:", fishId1, ratio)
            local fish = root:FindFish(fishId1)
            if not fish:IsNull() then
                fish:SetMoveable(false)
                fish:Death(player, cannonId, bulletId, ratio, angle, power)
                t.value = t.value + this:GetRatio() * fish:GetCoin()
                t.deathFishCount = t.deathFishCount + 1
            end
        end
        if #relationFish > 0 then
            FF_G.playEffect("drill_bomb")
        end
        t.bombTimes = t.bombTimes + 1

        -- show effect
        do
            local ret, action = root:ShowEffect("actions/effect/fish_jxsd/fish_jxsd.actions",
                    "show", "", FF_G.kNodeIndex_Top, 0, 0, false)
            assert(ret)
            action:SetLoop(1)
            root:ShakeScreen(0.5, 16)
        end
        local x = -1000
        for _ = 1, 5 do
            local y = -240
            for _ = 1, 3 do
                local x1 = x + math.random(-100, 100)
                local y1 = y + math.random(-100, 100)
                local ret, action = root:ShowEffect("ext/fish_lbl_baozha/fish_lbl_baozha.actions",
                        "show", "", FF_G.kNodeIndex_Top, x1, y1, false)
                assert(ret)
                action:SetLoop(1)
                action:GetAnim():SetZ(10)
                y = y + 240
            end
            x = x + 500
        end
        return 0
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