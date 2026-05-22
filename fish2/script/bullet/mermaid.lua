-- bullet/mermaid.lua
local this, lua, root = ...

local State_BoomCoin            = 1
local State_HeartMoveToCenter   = 2
local State_Boom                = 3
local State_HeartMoveToPlayer   = 4
local State_Show                = 5

-- 目标位置
local destX, destY  = 0, 0

-- 爆炸特效时间
local BoomCoinSecs = 1
-- 心飞行到目标位置的时间
local HeartMoveSecs = 1
-- 一次爆炸的流程需要的时间
local BoomLoopSecs = 4.86667
-- 心飞行到玩家位置的时间
local MoveToPlayerSecs = 2.5
-- 展示的时间
local ShowSecs = 1.5
-- 每次爆炸使用的子弹数量
local useBulletCountPerTime = 100

local t = {
    inited = false,
    srcX = 0,
    srcY = 0,
    state = State_BoomCoin,
    --time = 0,
    timeLeft = BoomCoinSecs,
    hasBoom = false,
    boomLeftTime = 0,
    boomLeft = 0,               -- 剩余爆炸次数
    value = 0,                  -- 打死鱼的价值
    curBoomTime = 1,            -- 当前爆炸次数
    deathFishCount = 0,
    fishType = 0,
}

-- 屏幕中心-心形动画
local heartAction
local heartAnim
-- 屏幕中心-美人鱼效果
local boomActions = {}

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
    local len = #destFish
    --print("CollisionChecks:" .. len)
    if (len > 0) then
        this:HitFish(destFish, cannonId, bulletId, useBulletCountPerTime, ratio, 0, 0)
        --print("hitFish, use bullet:", useBulletCountPerFrame, len)
        --this:SetLockValue(value - t.curBoomTime * useBulletCountPerTime * ratio)
        --this:NotifySyncLockValue()
    end
end

lua:Set_onCreate(function()
    local anim = root:CreateAnimNode("actions/other/space.anims")
    this:SetAnim(anim)
end)

lua:Set_onInit(function()
    if not t.inited then
        if not FF_G.IsServer then
            local ret, action = root:ShowEffect("ext/boom_coin/boom_coin.actions", "coin_up",
                    "", FF_G.kNodeIndex_EffectTop, t.srcX, t.srcY, false)
            assert(ret)
            action:SetLoop(1)
        end
        local value = this:GetLockValue()
        local ratio = this:GetRatio()
        local fishRatio = value / ratio
        t.boomLeft = math.floor(fishRatio / 100)
        --print(string.format("fish ratio:%d, left:%d", fishRatio, t.boomLeft))
        t.inited = true
    end
    if not FF_G.IsServer then
        -- init boom action.
        do
            local info = FF_G.TypeIdToFishCreator[t.fishType]
            for i = 0, 4 do
                local ret, action = root:ShowEffect(info.actionFile,
                        "ATK", "", FF_G.kNodeIndex_Ui, 0, 0, false)
                assert(ret)
                local anim = action:GetAnim()
                --boomAction = action
                anim:Hide()
                anim:SetAngle(math.pi * 2 / 5 * i)
                table.insert(boomActions, action)
            end
        end

        -- init heart action.
        do
            local ret, action = root:ShowEffect("ext/mermaid/fish_meirenyu_effect/fish_meirenyu_effect.actions",
                    "stayheart", "", FF_G.kNodeIndex_Ui, 0, 0, false)
            assert(ret)
            heartAction = action
            heartAnim = action:GetAnim()
        end

        -- init ui panel.
        do
            --local parent = FF_G_Client.GetNodeByNodeIndex(FF_G.kNodeIndex_Ui)
            local parent = FF_G_Client.GetActionRootNode(heartAction)
            local panel = FF_G.LoadLuaFunc("script/panel/mermaid.lua")(this, lua, root)
            panel.Init(parent, t.fishType)
            panel.Hide()
            uiPanel = panel
        end

        FF_G_Client.ShowMermaidEffect()
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
        heartAction:SetClean(true)
        for _, boomAction in ipairs(boomActions) do
            boomAction:SetClean(true)
        end
        FF_G_Client.CloseMermaidEffect()
        --FF_G_Client.ShowFishDeathEffect(this:GetPlayer():GetId(), FF_G.FishInfo.MermaidGreen.typeId, t.value)
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

local UpdateHeart = function()
    if not FF_G.IsServer then
        local show = t.state ~= State_BoomCoin
        local dx, dy = destX, destY
        local needMove = t.state == State_HeartMoveToPlayer or t.state == State_HeartMoveToCenter
        if needMove then
            local sx, sy = t.srcX, t.srcY
            local percent
            if t.state == State_HeartMoveToPlayer then
                sx, sy = destX, destY
                dx, dy = px, py
                percent = 1.0 - t.timeLeft / MoveToPlayerSecs
            else
                sx, sy = FF_G_Client.ConvertToUiPos(t.srcX, t.srcY)
                percent = 1.0 - t.timeLeft / BoomCoinSecs
            end
            --local percent = 1.0 - t.timeLeft / BoomCoinSecs
            --print(percent)
            local pos = FF_G.GetPercentPos(
                    {x = sx, y = sy},
                    {x = dx, y = dy},
                    percent
            )
            dx, dy = pos.x, pos.y
        elseif  t.state == State_Show then
            dx, dy = px, py
        end
        heartAnim:SetVisible(show)
        heartAnim:SetPos(dx, dy)
    end
end

local ResetBoomState = function()
    t.timeLeft = BoomLoopSecs
    t.boomLeftTime = 2.8
    t.hasBoom = false
    if not FF_G.IsServer then
        for _, boomAction in ipairs(boomActions) do
            local anim = boomAction:GetAnim()
            boomAction:SetElapsedSeconds(0)
            anim:SetElapsedSeconds(0)
            anim:Show()
        end
        heartAction:SetAction("effect")
    end
end

local Boom = function()
    -- boom
    if FF_G.IsServer then
        CollisionChecks()
    end
    if not FF_G.IsServer then
        uiPanel.ShowScaleEffect()
        root:ShakeScreen(0.5, 24);
    end
end

lua:Set_onUpdate(function(dt)
    t.timeLeft = math.max(0, t.timeLeft - dt)
    if t.timeLeft == 0 then
        if t.state == State_BoomCoin then
            t.state = State_HeartMoveToCenter
            t.timeLeft = HeartMoveSecs
        elseif t.state == State_HeartMoveToCenter then
            t.state = State_Boom
            ResetBoomState()
        elseif t.state == State_Boom then
            t.boomLeft = t.boomLeft - 1
            -- TODO boom fish
            if t.boomLeft <= 0 then
                -- 服务器到此结束
                if FF_G.IsServer then
                    return 1
                end
                -- 爆炸阶段结束
                --return 1
                t.state = State_HeartMoveToPlayer
                t.timeLeft = MoveToPlayerSecs
                if not FF_G.IsServer then
                    heartAction:SetAction("stayheart")
                    for _, boomAction in ipairs(boomActions) do
                        boomAction:GetAnim():Hide()
                    end
                end
            else
                t.state = State_Boom
                t.curBoomTime = t.curBoomTime + 1
                ResetBoomState()
            end
        elseif t.state == State_HeartMoveToPlayer then
            t.state = State_Show
            t.timeLeft = ShowSecs
        elseif t.state == State_Show then
            return 1
        end
    end
    if t.state == State_Boom then
        if not t.hasBoom then
            t.boomLeftTime = t.boomLeftTime - dt
            if t.boomLeftTime <= 0 then
                -- boom
                Boom()
                t.hasBoom = true
            end
        end
    end
    if not FF_G.IsServer then
        UpdateHeart()
        local times = t.curBoomTime
        if t.hasBoom and t.boomLeft > 1 then
            times = times + 1
        end
        local showUi = t.state > State_HeartMoveToCenter
        uiPanel.SetVisible(showUi)
        uiPanel.SetTimes(times)
        uiPanel.SetValue(t.value)

        -- update lock value.
        local times = t.curBoomTime
        if not t.hasBoom then
            times = times - 1
        end
        local ratio = this:GetRatio()
        local lockValue = this:GetLockValue() - times * useBulletCountPerTime * ratio
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