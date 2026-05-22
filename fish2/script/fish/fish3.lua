-- fish3.lua
local this, lua, root = ...

local t, super = FF_G.LoadLuaFunc("script/fish/base.lua")(this, lua, root)

lua:Set_onInit(function()
    super.OnInit()
    if not FF_G.IsServer then
        --this:SetShowDeathCoin(false)
        t.disableDeathEffect = true
        this:SetDeathType(FF_G_Client.kFishDeathType_Shake2)
    end
    return 0
end)

if not FF_G.IsServer then
    lua:Set_onUnInit(function()
        super.OnUnInit();
        super.ShowDeathEffect()
    end)
end

lua:Set_onUpdate(function(dt)
    if this:GetState() == FF_G.kState_Normal and t.time > 10 then
        return 1
    end
    this:SetPos(0, 0)
    return 0
end)

--if not FF_G.IsServer then
--    lua:Set_onDeath(function(player, _, _,ratio, coin)
--        FF_G_Client.ShowFishDeathEffect(player:GetId(), this:GetTypeId(), ratio * coin)
--        return 0
--    end)
--end

