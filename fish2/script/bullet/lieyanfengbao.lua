-- bullet/lieyanfengbao.lua
local this, lua, root = ...

local anim = this:GetAnim()
local cannon = this:GetCannon()
local player = cannon:GetPlayer()
local isSelf = false
local isAI = player:IsAI()
local checkCollide = false

if FF_G.IsServer then
    checkCollide = isAI
end

if not FF_G.IsServer then
    checkCollide = true
    isSelf = player:IsSelf()
end

local t = {
    time = 0,
}

local CollisionCheck = function()
    local fish = this:CollisionCheckWithPriority(true)

    if not fish:IsNull() then
        fish:Attacked(this);
        local hitAble = fish:IsNormalFish() or fish:IsCycleFish() or fish:IsGoldenFish()
        if not FF_G.IsServer then
            local angle = this:GetAnim():GetAngle()
            local x, y = this:GetPos()
            local offX, offY = root:Rotate(100, 0, angle)
            local ret, action = root:ShowEffect("actions/special/lieyanfengbao.actions", "yuwang",
                    "", FF_G.kNodeIndex_Fishnet, x + offX, y + offY, false)
            assert(ret)
            action:GetAnim():SetAngle(angle)
            action:SetLoop(1)
            if hitAble then
                if isSelf then
                    this:SendHitMsg(fish:GetId())
                end
            else
                this:SetResponsed(true)
            end
        end
        if FF_G.IsServer then
            if isAI then
                if hitAble then
                    local cannonId = cannon:GetId()
                    local bulletId = this:GetId()
                    local ratio = this:GetRatio()
                    this:HitOneFish(fish:GetId(), cannonId, bulletId, ratio, this:GetAngle(), 100)
                end
            end
        end
        return 1
    end
    return 0
end

local function Init()
    local ratio = this:GetRatio()
    anim:SetAnim("bullet")
    this:SetPower(100)
    this:SetLockValue(ratio)
    this:SetHandledMultiple(false)
    --print("ratio:", ratio)
end

lua:Set_onInit(function()
    --print("lieyanfengbao bullet init.")
    Init()
    if not FF_G.IsServer then
        FF_G.Broadcast.sendBroadcast(FF_G.kBroadcastKey_Fire, {
            playerId = this:GetPlayer():GetId(),
        })
    end
    return 0
end)

lua:Set_onUpdate(function(dt)
    t.time = t.time + dt
    if t.time > 30 then return 1 end
    this:Forward(dt)
    if not checkCollide then
        return 0
    end
    return CollisionCheck()
end)

lua:Set_onFishDeath(function(fishId, _)
    local fish = root:FindFish(fishId)
    if not fish:IsNull() then
        local playerId = player:GetId()
        local cannonId = cannon:GetId()
        FF_G.Broadcast.sendBroadcast("LieyanfengbaoFishDeath", {
            playerId = playerId,
            cannonId = cannonId,
            value = fish:GetCoin() * this:GetRatio(),
        })
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