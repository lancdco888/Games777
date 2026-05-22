-- fish/wheels_of_god_dragon.lua
local this, lua, root = ...

local t, super = FF_G.LoadLuaFunc("script/fish/base.lua")(this, lua, root)

if not FF_G.IsServer then
    --lua:Set_onInit(function()
    --    super.OnInit()
    --    local particle = cc.ParticleSystemQuad:create("particle/dragon.plist")
    --    particle:setPosition(0, 0)
    --    local root = FF_G_Client.GetActionRootNode(this:GetActionNode())
    --    root:addChild(particle)
    --    --FF_G_Client.AddNodeTo(particle, FF_G.kNodeIndex_UiTop)
    --    --print("wheels of god dragon particle.")
    --    return 0
    --end)
    local cannon

    local CleanCannon = function()
        if cannon then
            cannon:SetClean(true)
        end
    end

    lua:Set_onDeath(function(player, cannonId, bulletId, ratio, coin)
        super.PlayDeathEffect()
        --player:SetAutoFireState(false)
        this:SetState(FF_G.kState_Clean)
        --print("wheels of god dragon death:", ratio, ",", coin)
        local sx, sy = this:GetPos()
        local dx, dy = player:GetPos()
        if dy > 0 then
            dy = dy - 50
        else
            dy = dy + 50
        end
        if root:IsRotate() then
            sx, sy = -sx, -sy
            dx, dy = -dx, -dy
        end
        local pid = player:GetId()
        local typeId = this:GetTypeId()
        local value = ratio * coin
        require("script.ui.effect.dragon_turntable")
        dragon_turntable.create_dragon_turntable(coin, sx, sy, dx, dy, function()
            --print("wheels of god dragon end.")
            FF_G_Client.ShowFishDeathEffect(pid, typeId, value)
            CleanCannon()
        end)
        cannon = player:PushSpaceCannon()
        local bullet = cannon:CreateLuaBullet()
        bullet:SetRatio(ratio)
        bullet:SetLockValue(value)
        bullet:SetId(0)
        bullet:SetSpeed(0)
        bullet:SetWaitTime(1000)
        bullet:SetFireTime(root:CurrentTimePoint())
        bullet:SetLuaName("space.lua")
        cannon:SendLuaBullet(bullet, 0)
        FF_G.AddTimerTask(60, CleanCannon)
        return 0
    end)
end

if FF_G.IsServer then
    lua:Set_onDeath(function(player, cannonId, bulletId, ratio, coin)
        local tp = root:CurrentTimePoint()
        local x, y = this:GetPos()
        player:PushStuff(x, y, 0, FF_G.FishInfo.WheelsOfGodDragon.typeId,
                ratio, this:GetValue(), tp, tp, "space.lua", true)
        return 0
    end)
end