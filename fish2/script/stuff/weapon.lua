-- stuff/weapon.lua
local this, lua, root = ...

local t = {
    cannonId = 0,
}

-- 先展示再移动
local showTime = 2
local player = this:GetPlayer()
local srcTp = this:GetBornTime()
local destTp = this:GetEffectiveTime()
local destUseTime = destTp - srcTp - showTime
local sx, sy = this:GetSrcPos()
local x, y = player:GetPos()
local dx, dy = FF_G.GetCannonBasePosBySrcPos(x, y)

local function UpdatePos(tp)
    local useTime = tp - srcTp - showTime
    local percent = math.min(1, math.max(0, useTime / destUseTime))
    local x, y = sx + percent * (dx - sx), sy + percent * (dy - sy)
    --print(x, y)
    this:SetPos(x, y)
end

lua:Set_onCreate(function()
    if FF_G.IsServer then
        t.cannonId = player:GetNextCannonId()
    end
    local typeId = this:GetTypeId()
    print("stuff create:", typeId)
    if typeId == FF_G.kStuff_DrillCarb then
        this:InitAction("actions/special/zuantouxie.actions")
    elseif typeId == FF_G.kStuff_FlamesStorm then
        this:InitAction("actions/special/lieyanfengbao.actions")
    end
    return 0
end)

lua:Set_onInit(function()
    local typeId = this:GetTypeId()
    print("stuff Init, cannon id:", t.cannonId)
    if typeId == FF_G.kStuff_DrillCarb then
        this:GetActionNode():SetAction("move2")
    elseif typeId == FF_G.kStuff_FlamesStorm then
        this:GetActionNode():SetAction("cannon")
    end
    local anim = this:GetAnim()
    if player:GetSitId() < 2 then
        anim:SetAngle(math.pi / 2)
    else
        anim:SetAngle(-math.pi / 2)
    end
    local tp = root:CurrentTimePoint()
    --UpdatePos(tp)
    if not FF_G.IsServer then
        local time = destTp - tp
        local node = FF_G_Client.GetAnimDrawNode(anim)
        node:setAnchorPoint(0.148, 0.4643)
        if time > 1.25 then
            time = time - 1
            node:runAction(cc.Sequence:create(
                    cc.ScaleTo:create(time / 4, 1.5),
                    cc.DelayTime:create(time / 2),
                    cc.ScaleTo:create(time / 4, 1)
            ))
        end
    end
    return 0
end)

lua:Set_onUpdate(function(dt)
    local tp = root:CurrentTimePoint()
    UpdatePos(tp)
    if tp >= destTp then
        local typeId = this:GetTypeId()
        --print("stuff:", typeId)
        if typeId == FF_G.kStuff_DrillCarb then
            --print("push drill carb cannon.")
            local anim = root:CreateAnimNode("actions/special/zuantouxie.anims")
            anim:SetAnimIndex(2)
            anim:SetPos(dx, dy)
            anim:SetScale(1.5, 1.5)
            anim:SetAngle(player:GetCurrentCannonAngle())
            local cannon = root:CreateCannon()
            cannon:SetId(t.cannonId)
            cannon:SetAnim(anim)
            cannon:SetRatio(this:GetRatio())
            cannon:SetLockValue(this:GetValue())
            cannon:SetLuaName("zuantou.lua")
            player:PushCannon(cannon)
        elseif typeId == FF_G.kStuff_FlamesStorm then
            --print("push flames strom cannon.")
            local anim = root:CreateAnimNode("actions/special/lieyanfengbao.anims")
            anim:SetAnimIndex(2)
            anim:SetPos(dx, dy)
            anim:SetScale(1.5, 1.5)
            anim:SetAngle(player:GetCurrentCannonAngle())
            local cannon = root:CreateCannon()
            cannon:SetId(t.cannonId)
            cannon:SetAnim(anim)
            cannon:SetRatio(this:GetRatio())
            cannon:SetLockValue(this:GetValue())
            cannon:SetLuaName("lieyanfengbao.lua")
            player:PushCannon(cannon)
        end
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
