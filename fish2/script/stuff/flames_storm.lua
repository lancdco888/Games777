-- stuff/flames_storm.lua
local this, lua, root = ...

local State_Show1   = 0
local State_Move    = 1
local State_Show2   = 2

local t = {
    cannonId = 0,
    state = State_Show1,
    hasPushCannon = false,
}

-- 先展示再移动
local showTime = 2
local showTime2 = 1
local player = this:GetPlayer()
local srcTp = this:GetBornTime()
local destTp = this:GetEffectiveTime()
local destUseTime = destTp - srcTp - (showTime + showTime2)
local sx, sy = this:GetSrcPos()
local x, y = player:GetPos()
local dx, dy = FF_G.GetCannonBasePosBySrcPos(x, y)
--local dx, dy = x, y

local function UpdatePos(tp)
    local useTime = tp - srcTp - showTime
    local percent = math.min(1, math.max(0, useTime / destUseTime))
    local x1, y1 = sx + percent * (x - sx), sy + percent * (y - sy)
    this:SetPos(x1, y1)
end

lua:Set_onCreate(function()
    if FF_G.IsServer then
        t.cannonId = player:GetNextCannonId()
    end
    --this:InitAction("actions/special/lieyanfengbao.actions")
    this:InitAction("ext/flames_storm/fish_lyfb/fish_lyfb.actions")
    return 0
end)

lua:Set_onInit(function()
    --print("stuff flames_storm Init, cannon id:", t.cannonId)
    --this:GetActionNode():SetAction("cannon")
    this:GetActionNode():SetAction("fish_lyfb")
    local anim = this:GetAnim()

    if not FF_G.IsServer then
        local node = FF_G_Client.GetAnimRootNode(anim)
        local txt1 = cc.Sprite:createWithSpriteFrameName("lieyanfengbao_zi(1).png")
        local txt2 = cc.Sprite:createWithSpriteFrameName("lieyanfengbao_zi(2).png")
        local txt3 = cc.Sprite:createWithSpriteFrameName("lieyanfengbao_zi(3).png")
        local txt4 = cc.Sprite:createWithSpriteFrameName("lieyanfengbao_zi(4).png")

        node:addChild(txt1)
        FF_G_Client.PushNode(txt1)
        anim:BindSlot("", "1")

        node:addChild(txt2)
        FF_G_Client.PushNode(txt2)
        anim:BindSlot("", "2")

        node:addChild(txt3)
        FF_G_Client.PushNode(txt3)
        anim:BindSlot("", "3")

        node:addChild(txt4)
        FF_G_Client.PushNode(txt4)
        anim:BindSlot("", "4")
    end

    if player:GetSitId() < 2 then
        anim:SetAngle(0)
    else
        anim:SetAngle(math.pi)
    end
    --local tp = root:CurrentTimePoint()
    --if not FF_G.IsServer then
    --    local time = destTp - tp
    --    local node = FF_G_Client.GetAnimDrawNode(anim)
    --    node:setAnchorPoint(0.148, 0.4643)
    --    if time > 1.25 then
    --        time = time - 1
    --        node:runAction(cc.Sequence:create(
    --                cc.ScaleTo:create(time / 4, 1.5),
    --                cc.DelayTime:create(time / 2),
    --                cc.ScaleTo:create(time / 4, 1)
    --        ))
    --    end
    --end
    return 0
end)

--lua:Set_onUnInit(function()
--    print("stuff flames_storm UnInit.")
--end)

lua:Set_onUpdate(function(dt)
    local tp = root:CurrentTimePoint()
    UpdatePos(tp)
    if not t.hasPushCannon and tp >= destTp - 0.5 then
        --print("push flames strom cannon.")
        --local angle = player:GetCurrentCannonAngle()
        local angle
        if FF_G.IsInBottomSit(player:GetSitId()) then
            angle = math.pi * 0.5
        else
            angle = math.pi * 1.5
        end
        local anim = root:CreateAnimNode("actions/special/lieyanfengbao.anims")
        anim:SetAnimIndex(2)
        anim:SetPos(dx, dy)
        anim:SetScale(1.5, 1.5)
        anim:SetAngle(angle)
        local cannon = root:CreateCannon()
        cannon:SetId(t.cannonId)
        cannon:SetAnim(anim)
        cannon:SetRatio(this:GetRatio())
        cannon:SetLockValue(this:GetValue())
        cannon:SetLuaName("lieyanfengbao.lua")
        player:PushCannon(cannon)
        t.hasPushCannon = true
    end
    if tp >= destTp then
        return 1
    end
    return 0
end)

if not FF_G.IsServer then
    local lockValue = this:GetValue()
    print("get lock value in flames_storm:", lockValue)
    lua:Set_onGetLockValue(function()
        if t.hasPushCannon then return 0 end
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
