-- bullet/phoenix.lua
local this, lua, root = ...

local State_CoinUpAnim      = 1
local State_FeatherAnim     = 2
local State_FeatherMove     = 3
local State_FeatherAnim2    = 4
local State_DieAnim         = 5
local State_Group           = 6
-- 结束展示
local State_Show            = 7

local destX, destY = 0, 0

local t = {
    srcX = 0,
    srcY = 0,
    anim = "coin_up",
    inited = false,
    state = State_CoinUpAnim,
    time = 0,
    value = 0, -- 打死鱼的价值
    deathFishCount = 0,
}

local showTime = 5
local useBulletCountPerSecond = 40
local useBulletCountPerFrame = math.floor(useBulletCountPerSecond / 10)
local animNode
local lastCreateTime = -10
local createCd = 0.35
local lianjiAction
local lianjiActionNode
local bulletTime = this:GetLockValue() / this:GetRatio() / useBulletCountPerSecond
local deathTimesText -- 死亡鱼数
local deathValueText -- 死亡鱼价值
local uiRoot
--print("phoenix bullet time:", bulletTime)

local CollisionChecks = function()
    local value = this:GetLockValue()
    local fish = root:AllAttackableFishInScreen()
    local cannon = this:GetCannon()
    local cannonId = cannon:GetId()
    local bulletId = this:GetId()
    local ratio = this:GetRatio()
    local count = math.floor(value / ratio)
    --print("least bullet count:", count)

    -- 子弹已经用完
    if count < useBulletCountPerFrame then
        return
    end

    local destFish = {}
    for _, fish1 in ipairs(fish) do
        if fish1:IsNormalFish() then
            table.insert(destFish, fish1)
            if #destFish >= useBulletCountPerFrame then
                break
            end
        end
    end
    local len = #destFish
    if (len > 0) then
        this:HitFish(destFish, cannonId, bulletId, useBulletCountPerFrame, ratio, 0, 0)
        --print("hitFish, use bullet:", useBulletCountPerFrame, len)
        this:SetLockValue(value - useBulletCountPerFrame * ratio)
        --this:NotifySyncLockValue()
    end
end

lua:Set_onCreate(function()
    if not FF_G.IsServer then
        cc.SpriteFrameCache:getInstance():addSpriteFrames("ui/phoenix/phoenix_ui.plist")
    end
    local anim = root:CreateAnimNode("actions/golden/phoenix.anims")
    anim:SetLoops(false)
    this:SetAnim(anim)
    animNode = anim
end)

lua:Set_onInit(function()
    --print("phoenix init")
    if not t.inited then
        animNode:SetPos(t.srcX, t.srcY)
        animNode:SetScale(1.5, 1.5)
        t.inited = true
    end
    --print("phoenix anim:")
    animNode:SetAnim(t.anim)
    if not FF_G.IsServer then
        FF_G_Client.ShowPhoenixScreenEdgeFireEffect()
        FF_G.Broadcast.sendBroadcast(FF_G.kBroadcastKey_Fire, {
            playerId = this:GetCannon():GetPlayer():GetId(),
        })
    end
    return 0
end)

lua:Set_onUnInit(function()
    if lianjiAction then
        lianjiAction:SetClean(true)
    end
    if uiRoot then
        uiRoot:removeFromParent()
    end
    if not FF_G.IsServer then
        FF_G_Client.ClosePhoenixScreenEdgeFireEffect()
        FF_G_Client.ShowFishDeathEffect(this:GetPlayer():GetId(), FF_G.FishInfo.FlamingPhoenix.typeId, t.value)
        FF_G.Broadcast.sendBroadcast(FF_G.kBroadcastKey_Fire, {
            playerId = this:GetCannon():GetPlayer():GetId(),
        })
        this:SetResponsed(true)
    end
end)

local groupStateUiInited = false
local InitGroupStateUi = function()
    if FF_G.IsServer then
        return
    end
    if groupStateUiInited then return end
    groupStateUiInited = true
    local ret, action = root:ShowEffect("actions/golden/phoenix.actions", "lianji",
            "", FF_G.kNodeIndex_Ui, 0, 125, false)
    assert(ret)
    lianjiAction = action
    lianjiActionNode = FF_G_Client.GetActionRootNode(action)

    local coin = FF_G_Client.CreateNumText("texiao_suzi_%s.png", 67, 113)
    local node = FF_G_Client.GetActionRootNode(action)
    coin.node:setPosition(0, 100)
    node:addChild(coin.node)
    coin.SetString(tostring(t.deathFishCount))
    deathTimesText = coin

    uiRoot = cc.Node:create()
    uiRoot:setPosition(0, -170)
    FF_G_Client.AddNodeTo(uiRoot, FF_G.kNodeIndex_Ui)
    FF_G_Client.SwitchParentTo(lianjiActionNode, uiRoot)
    local bg = ccui.Scale9Sprite:createWithSpriteFrameName("storm_frame.png")
    local size = {
        width = 300,
        height = 80,
    }
    bg:setPreferredSize(size)
    local sprite = cc.Sprite:createWithSpriteFrameName("PhoenixHead.png")
    bg:setPosition(20, 0)
    sprite:setPosition(-170, 10)

    local value = FF_G_Client.CreateNumText("buyu_fenghuang_%s.png", 24, 34)
    value.node:setPosition(size.width / 2, size.height / 2 + 5)
    value.SetString(tostring(t.deathFishCount), true)
    deathValueText = value

    bg:addChild(value.node)
    uiRoot:addChild(bg)
    uiRoot:addChild(sprite)
end

local lastDeathFishCount = -1
local UpdateGroupState = function()
    if FF_G.IsServer then
        CollisionChecks()
    end
    if not FF_G.IsServer then
        InitGroupStateUi()
        if lastDeathFishCount ~= t.deathFishCount then
            deathTimesText.SetString(tostring(t.deathFishCount))
            deathValueText.SetString(tostring(t.value / FF_G.ExchangeRate), true)
            lastDeathFishCount = t.deathFishCount
            lianjiActionNode:runAction(cc.Sequence:create(
                    cc.ScaleTo:create(0.05, 1.25),
                    cc.ScaleTo:create(0.05, 1)
            ))
            root:ShakeScreen(0.075, 6)
        end

        if t.time <= bulletTime - 1.5 then
            if t.time - lastCreateTime >= createCd then
                lastCreateTime = t.time
                local times = math.random(2, 3)
                for _ = 1, times do
                    local node = cc.Sprite:createWithSpriteFrameName("phoenix_pingyi.png")
                    node:setScale(0.6)
                    FF_G_Client.AddNodeTo(node, FF_G.kNodeIndex_Top)
                    local y = math.random(-300, 300)
                    local x = math.random(-1540, -1460)
                    node:setPosition(x, y)
                    node:runAction(cc.Sequence:create(
                            cc.MoveTo:create(1.5, {x = -x, y = y}),
                            cc.RemoveSelf:create()
                    ))
                end
            end
        end
    end
end

lua:Set_onUpdate(function(dt)
    local state = t.state
    if state == State_CoinUpAnim
            or state == State_FeatherAnim
            or state == State_FeatherAnim2
            or state == State_DieAnim then
        if animNode:IsPlayEnd() then
            if state == State_CoinUpAnim then
                t.state = State_FeatherAnim
                t.anim = "feather"
                animNode:SetAnim(t.anim)
            elseif state == State_FeatherAnim then
                t.state = State_FeatherMove
            elseif state == State_FeatherAnim2 then
                t.state = State_DieAnim
                t.anim = "die"
                animNode:SetAnim(t.anim)
                animNode:SetScale(3.5, 3.5)
            elseif state == State_DieAnim then
                t.state = State_Group
                t.time = 0
                animNode:Hide()
                InitGroupStateUi()
            end
        end
    elseif state == State_FeatherMove then
        t.time = t.time + dt
        local percent = math.min(1, t.time)
        local curX = t.srcX + (destX - t.srcX) * percent
        local curY = t.srcY + (destY - t.srcY) * percent
        animNode:SetPos(curX, curY)
        if t.time >= 1 then
            t.state = State_FeatherAnim2
            t.anim = "feather"
            animNode:SetAnim(t.anim)
        end
    elseif state == State_Group then
        t.time = t.time + dt
        UpdateGroupState()
        if t.time >= bulletTime then
            -- 服务器直接跳过展示阶段
            if FF_G.IsServer then
                return 1
            end
            t.state = State_Show
            t.time = 0
            if not FF_G.IsServer then
                local player = this:GetPlayer()
                local x, y = FF_G_Client.GetPlayerUiPos(player)
                uiRoot:runAction(cc.Sequence:create(
                        cc.DelayTime:create(2),
                        cc.MoveTo:create(1, {x = x, y = y}),
                        cc.DelayTime:create(2)
                ))
            end
        end
    elseif state == State_Show then
        t.time = t.time + dt
        if t.time >= showTime then
            return 1
        end
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