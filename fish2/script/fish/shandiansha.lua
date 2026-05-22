-- shandiansha.lua
local this, lua, root = ...

local t, super = FF_G.LoadLuaFunc("script/fish/base.lua")(this, lua, root)

-- 声明用户数据
t. hasDeath = false

--local t = {
--    hasDeath = false,
--    hasShowComeTips = false,
--    --effectTime = 0,
--    --effectEnd = false
--}

--local nextPlayEffectTime = 0

--local effectIndex
--
--local CloseWalkEffect = function()
--    if effectIndex then
--        FF_G.stopEffect(effectIndex)
--        effectIndex = nil
--    end
--end

lua:Set_onInit(function()
    --print("shandiansha onInit.")
    --effectIndex = FF_G.playEffect("lightningshark_walk", false)
    super:OnInit()
    this:SetLightningShark(true)
    return 0
end)

lua:Set_onUnInit(function()
    super.OnUnInit()
    --print("shandiansha onUnInit.")
    local player = this:GetKillPlayer()
    local playerId = -1
    if not player:IsNull() then
        playerId = player:GetId()
    end
    local allValue = 0
    for _, id in ipairs(this:relationFishId()) do
        local fish1 = root:FindFish(id)
        if not fish1:IsNull() then
            fish1:SetKillPlayerId(playerId)
            fish1:SetActionStop(false)
            fish1:SetDeath(true)
            fish1:ShowDeathEffect()
            fish1:ClearEffects()
            allValue = allValue + fish1:GetValue()
        end
    end
    if not FF_G.IsServer then
        if allValue > 0 then
            FF_G_Client.ShowFishDeathEffect(playerId, this:GetTypeId(), allValue)
        end
    end
    --CloseWalkEffect()
end)

if not FF_G.IsServer then
    --lua:Set_onUpdate(function(dt)
    --    nextPlayEffectTime = nextPlayEffectTime - dt
    --    if nextPlayEffectTime <= 0 then
    --        FF_G.playEffect("lightningshark_walk", false)
    --        nextPlayEffectTime = 15
    --    end
    --    return 0
    --end)

    lua:Set_onDeath(function(player, cannonId, bulletId, ratio, coin)
        --print("shandiansha death.")
        if t.hasDeath then return 1 end

        print(this)
        FF_PRAMS = {
            lightningShark = this,
            lightningSharkId = this:GetId()
        }
        local cannon = player:GetNormalCannon()
        local bullet = cannon:CreateLuaBullet()
        bullet:SetRatio(ratio)
        bullet:SetLuaName("shandiansha.lua")
        cannon:SendLuaBullet(bullet, 0)

        --local action = this:GetActionNode()
        --action:SetAction("die")
        --this:SetMoveable(false)
        --this:SetState(FF_G.kState_Lock)
        --local x, y = this:GetPos()
        --
        --local _, effect = root:ShowEffect("actions/special/texiao_shandiansha.actions", "1",
        --        "", FF_G.kNodeIndex_EffectTop, x, y, true)
        --this:PushEffect(effect)
        --
        --local fishId = this:relationFishId()
        --print("len:" .. #fishId)
        --
        --local fish = {}
        --for _, id in ipairs(fishId) do
        --    local fish1 = root:FindFish(id)
        --    if not fish1:IsNull() and fish1:Attackable() then
        --        local value = ratio * fish1:GetCoin()
        --        fish1:SetValue(value)
        --        local x1, y1 = fish1:GetPos()
        --        local _, effect1 = root:ShowEffect("actions/special/texiao_shandiansha.actions", "2",
        --                "", FF_G.kNodeIndex_EffectTop, x1, y1, true)
        --
        --        local scale1 = fish1:GetMaxRadius() / 50
        --        effect1:GetAnim():SetScale(scale1, scale1)
        --        table.insert(fish, fish1)
        --        fish1:SetActionStop(true)
        --        fish1:SetMoveable(false)
        --        fish1:SetState(FF_G.kState_Lock)
        --
        --        -- 闪电鲨->目标鱼 闪电
        --        local _, effect2 = root:ShowEffect("actions/special/texiao_shandiansha.actions", "4",
        --                "", FF_G.kNodeIndex_EffectTop, (x + x1) / 2, (y + y1) / 2, true)
        --        local angle = root:GetAngle(x, y, x1, y1)
        --        local dis = root:GetDistance(x, y, x1, y1)
        --        -- 这里需要知道图片高度.
        --        local scale = dis / 301
        --        local anim = effect2:GetAnim()
        --        anim:SetScale(scale, 1)
        --        anim:SetAngle(angle)
        --
        --        fish1:PushEffect(effect1)
        --        fish1:PushEffect(effect2)
        --    end
        --end

        t.hasDeath = true
        --CloseWalkEffect()

        return 1
    end)
end

--lua:Set_onUpdate(function(dt)
--    if t.hasDeath and not t.effectEnd then
--        t.effectTime = t.effectTime + dt
--        if t.effectTime >= 2 then
--            this:SetDeath(true)
--            this:ShowDeathEffect()
--            this:ClearEffects()
--
--            t.effectEnd = true
--        end
--    end
--    return 0
--end)