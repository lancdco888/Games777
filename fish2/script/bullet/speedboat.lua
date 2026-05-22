-- bullet/speedboat.lua
local this, lua, root = ...

--local State_BoomCoin            = 1
--local State_HeartMoveToCenter   = 2
--local State_Boom                = 3

local State_BoatMove            = 3
local State_HeartMoveToPlayer   = 4
local State_Show                = 5

local srcX, srcY = -1500, 0
-- 目标位置
local destX, destY = 1500, 0
local destUiX, destUiY = 0, -40

local srcPos = {
    x = srcX,
    y = srcY
}

local destPos = {
    x = destX,
    y = destY
}

-- 一次移动需要的时间
local BoatMoveSecs = 3
-- 一次移动显示爆炸效果的次数
local ShowBombTimes = 10
-- 心飞行到玩家位置的时间
local MoveToPlayerSecs = 2.5
-- 展示的时间
local ShowSecs = 1.5
-- 每次爆炸使用的子弹数量
local useBulletCountPerTime = 100

local t = {
    inited = false,
    state = State_BoatMove,
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
}

local boatActions = {}

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

local ResetBombState = function()
    t.timeLeft = BoatMoveSecs
    t.showBombEffectTimes = 0
    t.hasBomb = false
end

lua:Set_onCreate(function()
    local anim = root:CreateAnimNode("actions/other/space.anims")
    this:SetAnim(anim)
end)

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
        -- init boat actions.
        do
            local info = FF_G.TypeIdToFishCreator[t.fishType]
            for _ = 1, 5 do
                local ret, action = root:ShowEffect(info.actionFile,
                        "move", "", FF_G.kNodeIndex_Top, 0, 0, false)
                assert(ret)
                local anim = action:GetAnim()
                anim:SetScale(1.5, 1.5)
                anim:SetPos(-2000, 0)
                anim:SetZ(2)
                table.insert(boatActions, action)
            end
        end

        ---- init ui panel.
        do
            local ratio = this:GetRatio()
            --local ui = FF_G_Client.GetNodeByNodeIndex(FF_G.kNodeIndex_Ui)
            local parent = cc.Node:create()
            --local parent = FF_G_Client.GetActionRootNode(heartAction)
            local panel = FF_G.LoadLuaFunc("script/panel/speedboat.lua")(this, lua, root)
            panel.Init(parent)
            FF_G_Client.AddNodeTo(parent, FF_G.kNodeIndex_Ui)
            panel.Hide()
            panel.SetDeltaNumber(ratio)
            uiPanel = panel
            uiRoot = parent
        end

        FF_G.Broadcast.sendBroadcast(FF_G.kBroadcastKey_Fire, {
            playerId = this:GetCannon():GetPlayer():GetId(),
        })
    end
    --print("fish type:" .. t.fishType)
    return 0
end)

lua:Set_onUnInit(function()
    if not FF_G.IsServer then
        uiPanel.UnInit()
        if uiRoot then
            uiRoot:removeFromParent()
            uiRoot = nil
        end
        for _, action in ipairs(boatActions) do
            action:SetClean(true)
        end
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

local offsets = {
    {0, 0},
    {50, 200},
    {50, -200},
    {0, 400},
    {0, -400},
}

local UpdateBoatPos = function()
    if not FF_G.IsServer then
        local percent = 1.0 - t.timeLeft / BoatMoveSecs
        local pos = FF_G.GetPercentPos(srcPos, destPos, percent)
        for i = 1, 5 do
            local anim = boatActions[i]:GetAnim()
            local offset = offsets[i]
            anim:SetPos(pos.x + offset[1], pos.y + offset[2])
        end
    end
end

lua:Set_onUpdate(function(dt)
    t.timeLeft = math.max(0, t.timeLeft - dt)
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
                    for _, action in ipairs(boatActions) do
                        action:GetAnim():Hide()
                    end
                end
            else
                ResetBombState()
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
            if not t.hasBomb and t.timeLeft <= BoatMoveSecs / 2 then
                CollisionChecks()
                t.hasBomb = true
            end
        end
    end
    if not FF_G.IsServer then
        if t.state == State_BoatMove then
            UpdateBoatPos()
            local useTime = BoatMoveSecs - t.timeLeft
            local effectTime = BoatMoveSecs / ShowBombTimes
            local needShowEffectTimes = math.floor(useTime / effectTime)
            if t.showBombEffectTimes < needShowEffectTimes then
                for _, action in ipairs(boatActions) do
                    local x, y = action:GetAnim():GetPos()
                    local ret, action = root:ShowEffect("ext/speedboat_bomb/BombSpeedboat.actions", "bomb",
                            "", FF_G.kNodeIndex_Top, x, y, false)
                    assert(ret)
                    action:SetLoop(1)
                end
                t.showBombEffectTimes = t.showBombEffectTimes + 1
            end
        end
        UpdateUiPos()
        uiPanel.SetValue(t.value)
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