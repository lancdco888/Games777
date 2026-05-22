-- bullet/xuanfeng.lua
local this, lua, root = ...

local t = {
    fishType = 0,
    relationFishId = {},
    value = 0,
    relationFishInfo = {},
    time = 0,
    inited = false,
}

-- 所有关联鱼
--local fish = {}
local player
local dx, dy

local function GetFishInfo(fish)
    local fishId = fish:GetId()
    local info = t.relationFishInfo[fishId]
    if info then
        return info
    end
    if not FF_G.IsServer then
        fish:GetAnimNode():PushRootNode()
        root:SwitchParent(FF_G.kNodeIndex_FishFront)
    end
    local x, y = fish:GetPos()
    info = {
        sx = x,
        sy = y,
        dx = x / 15 + dx,
        dy = y / 15 + dy,
    }
    t.relationFishInfo[fishId] = info
    return info
end

lua:Set_onCreate(function()
    --print("xuanfeng bullet init onCreate.")
    player = this:GetPlayer()
    dx, dy = player:GetPos()
    if FF_G.IsInBottomSit(player:GetSitId()) then
        dy = dy + 200
    else
        dy = dy - 200
    end
    local anim = root:CreateAnimNode("actions/common/xuanfengyu_over/xuanfengyu_over.anims")
    anim:SetAnimIndex(0)
    anim:SetScale(0, 0)
    anim:SetPos(dx, dy)
    this:SetAnim(anim)
end)

lua:Set_onInit(function()
    --print("xuanfeng bullet init client:" .. t.fishType)
    local lockValue = 0
    local ratio = this:GetRatio()
    for _, id in ipairs(t.relationFishId) do
        local fish1 = root:FindFish(id)
        if not fish1:IsNull() then
            fish1:SetMoveable(false)
            -- 改变状态，让鱼不再可选中
            fish1:SetState(FF_G.kState_Lock)
            lockValue = lockValue + ratio * fish1:GetCoin()
        end
    end
    this:SetLockValue(lockValue)
    return 0
end)

lua:Set_onUnInit(function()
    print("xuanfeng bullet UnInit");
    for _, id in ipairs(t.relationFishId) do
        local fish = root:FindFish(id)
        if not fish:IsNull() then
            fish:SetState(FF_G.kState_Clean)
        end
    end
    if not FF_G.IsServer then
        this:SetResponsed(true)
    end
end)

lua:Set_onUpdate(function(dt)
    t.time = t.time + dt
    local movePercent = math.min(t.time / 0.25, 1)
    local scale = movePercent * 1.5
    this:GetAnim():SetScale(scale, scale)

    local hasFish = false

    for _, id in ipairs(t.relationFishId) do
        local fish = root:FindFish(id)
        if not fish:IsNull() then
            if fish:GetState() ~= FF_G.kState_Clean then
                hasFish = true
                fish:SetAngle(fish:GetAngle() + math.pi / 180)
                --local fishId = fish:GetId()
                --local info = t.relationFishInfo[fishId]
                local info = GetFishInfo(fish)
                if movePercent == 1 then
                    -- 移动完
                    fish:SetPos(info.dx, info.dy)
                    local scale, _ = fish:GetScale()
                    --print(type(scale), scale)
                    if scale <= 0.01 then
                        fish:SetOpacity(0)
                        fish:SetScale(0, 0)
                        -- 标记为可清理状态
                        fish:SetState(FF_G.kState_Clean)
                        t.value = t.value + fish:GetCoin() * this:GetRatio()
                    else
                        scale = math.max(scale - 0.0075, 0)
                        --print(type(scale), scale)
                        fish:SetScale(scale, scale)
                        fish:SetOpacity(math.floor(scale * 255))
                    end
                else
                    fish:SetPos(
                            info.sx + (info.dx - info.sx) * movePercent,
                            info.sy + (info.dy - info.sy) * movePercent
                    )
                end
            end
        end
    end

    if not hasFish then
        if not FF_G.IsServer then
            -- 结算
            if t.value > 0 then
                FF_G.Broadcast.sendBroadcast(FF_G.kBroadcastKey_ShowFishDeathEffect, {
                    playerId = player:GetId(),
                    value = t.value,
                    banner = "caitiao_xuanfenyu.png",
                    avatar = "texiao_xuanfengyu.png"
                })
            end
        end
        return 1
    end
    -- 做一个保护
    return t.time > 15 and 1 or 0
end)

lua:Set_onSerialize(function()
    GT = t
end)

lua:Set_onDeserialize(function()
    --print("xuanfeng bullet onDeserialize.")
    local t_ = GT
    for k, v in pairs(t_) do
        t[k] = v
    end
end)
