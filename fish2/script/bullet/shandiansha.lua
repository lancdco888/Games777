-- bullet/shandiansha.lua
local this, lua, root = ...

local lightningShark = FF_PRAMS.lightningShark
assert(lightningShark)
local lightningSharkId = FF_PRAMS.lightningSharkId
local time = 0

lua:Set_onCreate(function()
    local anim = root:CreateAnimNode("actions/other/space.anims")
    anim:SetAnimIndex(0)
    anim:Hide()
    anim:SetScale(0, 0)
    this:SetAnim(anim)
end)

lua:Set_onInit(function()
    print("bullet shandiansha init.")
    print(lightningShark)
    local ratio = this:GetRatio()
    local lockValue = ratio * lightningShark:GetCoin()
    local action = lightningShark:GetActionNode()
    action:SetAction("die")
    lightningShark:SetMoveable(false)
    lightningShark:SetState(FF_G.kState_Lock)
    local x, y = lightningShark:GetPos()

    local _, effect = root:ShowEffect("actions/special/texiao_shandiansha.actions", "1",
            "", FF_G.kNodeIndex_EffectTop, x, y, true)
    lightningShark:PushEffect(effect)

    local fishId = lightningShark:relationFishId()
    print("len:" .. #fishId)

    local fish = {}
    for _, id in ipairs(fishId) do
        local fish1 = root:FindFish(id)
        if not fish1:IsNull() and fish1:Attackable() then
            local value = ratio * fish1:GetCoin()
            lockValue = lockValue + value
            fish1:SetValue(value)
            local x1, y1 = fish1:GetPos()
            local _, effect1 = root:ShowEffect("actions/special/texiao_shandiansha.actions", "2",
                    "", FF_G.kNodeIndex_EffectTop, x1, y1, true)

            local scale1 = fish1:GetMaxRadius() / 50
            effect1:GetAnim():SetScale(scale1, scale1)
            table.insert(fish, fish1)
            fish1:SetActionStop(true)
            fish1:SetMoveable(false)
            fish1:SetState(FF_G.kState_Lock)

            -- 闪电鲨->目标鱼 闪电
            local _, effect2 = root:ShowEffect("actions/special/texiao_shandiansha.actions", "4",
                    "", FF_G.kNodeIndex_EffectTop, (x + x1) / 2, (y + y1) / 2, true)
            local angle = root:GetAngle(x, y, x1, y1)
            local dis = root:GetDistance(x, y, x1, y1)
            -- 这里需要知道图片高度.
            local scale = dis / 301
            local anim = effect2:GetAnim()
            anim:SetScale(scale, 1)
            anim:SetAngle(angle)

            fish1:PushEffect(effect1)
            fish1:PushEffect(effect2)
        end
    end

    this:SetLockValue(lockValue)
    return 0
end)

if not FF_G.IsServer then
    lua:Set_onUnInit(function()
        this:SetResponsed(true)
    end)
end

lua:Set_onUpdate(function(dt)
    time = time + dt
    if time > 2.0 then
        local lightningShark = root:FindFish(lightningSharkId)
        if not lightningShark:IsNull() then
            lightningShark:SetDeath(true)
            lightningShark:ShowDeathEffect()
            lightningShark:ClearEffects()
        end
        return 1
    end
    return 0
end)
