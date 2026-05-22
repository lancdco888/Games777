-- stuff/bomb_carb.lua
local this, lua, root = ...

local t = {
    bulletId = 0,
    isMultiple = false,
    hideZhadanxie = false,
}

local player = this:GetPlayer()
local srcTp = this:GetBornTime()
local destTp = this:GetEffectiveTime()
local destUseTime = destTp - srcTp
local sx, sy = this:GetSrcPos()
local dx, dy = 0, 0

local function UpdatePos(tp)
    local useTime = tp - srcTp
    local percent = math.min(1, math.max(0, useTime / destUseTime))
    local x, y = sx + percent * (dx - sx), sy + percent * (dy - sy)
    this:SetPos(x, y)
end

lua:Set_onCreate(function()
    if FF_G.IsServer then
        t.bulletId = player:GetNormalCannon():GetNextSpecialBulletId()
    end
    local typeId = this:GetTypeId()
    t.isMultiple = typeId == FF_G.kStuff_MultipleBombCarb
    t.hideZhadanxie = (typeId ~= FF_G.kStuff_BombCarb) and (not isMultiple)
    if t.hideZhadanxie then
        this:InitAction("actions/other/space.actions")
    else
        this:InitAction("actions/special/zhadanxie.actions")
    end
    return 0
end)

local Fire = function()
    local x, y = this:GetPos()
    local ratio = this:GetRatio()
    local value = this:GetValue()
    local cannon = player:GetNormalCannon()
    local anim = root:CreateAnimNode(t.hideZhadanxie
            and "actions/other/space.anims" or "actions/special/zhadanxie.anims")
    if FF_G.IsInBottomSit(player:GetSitId()) then
        anim:SetAngle(0)
    else
        anim:SetAngle(math.pi)
    end
    --anim:SetPos(x, y)
    local bullet = cannon:CreateLuaBullet()
    bullet:SetAnim(anim)
    --bullet:SetId(cannon:GetNextSpecialBulletId())
    bullet:SetId(t.bulletId)
    bullet:SetLuaName("zhadanxie.lua")
    bullet:SetRatio(ratio)
    bullet:SetLockValue(value)
    bullet:SetFireTime(root:CurrentTimePoint())
    local typeId = this:GetTypeId()
    --local isMultiple = typeId == FF_G.kStuff_MultipleBombCarb
    --local hideZhadanxie = (typeId ~= FF_G.kStuff_BombCarb) and (not isMultiple)
    local bulletCount = math.floor(value / ratio)
    local totalTimes = 1
    if t.isMultiple then
        totalTimes = math.floor(bulletCount / 100)
    end
    GT = {
        srcPos = {x, y},
        ratio = ratio,
        bulletCount = bulletCount,
        isMultiple = t.isMultiple,
        hideZhadanxie = t.hideZhadanxie,
        totalTimes = math.min(9, totalTimes),
        typeId = this:GetTypeId(),
    }
    bullet:GetLua():SaveLuaDataFromGT()
    cannon:SendLuaBullet(bullet, 0)
end

lua:Set_onInit(function()
    --print("stuff drill_carb Init.bulletId:" .. t.bulletId)
    if not t.hideZhadanxie then
        local action = this:GetActionNode()
        --action:SetAction("1")
        local isMultiple = this:GetTypeId() == FF_G.kStuff_MultipleBombCarb
        if isMultiple then
            action:SetAction("over_multiple")
        else
            action:SetAction("die")
        end
    end
    --this:SetPos(x, y)
    UpdatePos(root:CurrentTimePoint())
    return 0
end)

local destTp = this:GetEffectiveTime()
lua:Set_onUpdate(function(_)
    local tp = root:CurrentTimePoint()
    UpdatePos(tp)
    if tp >= destTp then
        Fire()
        return 1
    end
    return 0
end)

if not FF_G.IsServer then
    local lockValue = this:GetValue()
    print("get lock value in weapon:", lockValue)
    lua:Set_onGetLockValue(function()
        return lockValue
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
