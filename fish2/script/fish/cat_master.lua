-- fish/cat_master.lua
local this, lua, root = ...

local t, super = FF_G.LoadLuaFunc("script/fish/base.lua")(this, lua, root)

if not FF_G.IsServer then
    local cannon

    local CleanCannon = function()
        if cannon then
            cannon:SetClean(true)
        end
    end

    lua:Set_onDeath(function(player, cannonId, bulletId, ratio, coin)
        local pid = player:GetId()
        local typeId = this:GetTypeId()
        local value = ratio * coin
        if player:IsSelf() then
            require("script.ui.mdy_layer")
            mdy_layer.pop(coin, ratio, function()
                --print("cat master end")
                FF_G_Client.ShowFishDeathEffect(pid, typeId, value)
                CleanCannon()
            end)
            --player:SetAutoFireState(false)
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
            FF_G.AddTimerTask(90, CleanCannon)
            this:SetShowDeathCoin(false)
        else
            FF_G_Client.ShowFishDeathEffect(pid, typeId, value)
        end
        super.PlayDeathEffect()
        return 0
    end)
end

if FF_G.IsServer then
    lua:Set_onDeath(function(player, cannonId, bulletId, ratio, coin)
        local tp = root:CurrentTimePoint()
        local x, y = this:GetPos()
        player:PushStuff(x, y, 0, FF_G.FishInfo.CatMaster.typeId,
                ratio, this:GetValue(), tp, tp, "space.lua", true)
        return 0
    end)
end