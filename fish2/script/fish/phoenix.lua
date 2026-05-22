-- phoenix.lua
local this, lua, root = ...

local t, super = FF_G.LoadLuaFunc("script/fish/base.lua")(this, lua, root)

lua:Set_onInit(function()
    if not FF_G.IsServer then
        this:SetShowDeathCoin(false)
        this:SetDeathType(FF_G_Client.kFishDeathType_Shake)
    end
    if not FF_G.IsServer then
        FF_G_Client.ShowPhoenixScreenEdgeFireEffect()
    end
end)

if not FF_G.IsServer then
    lua:Set_onUnInit(function()
        super.OnUnInit()
        FF_G_Client.ClosePhoenixScreenEdgeFireEffect()
    end)
end

lua:Set_onDeath(function(player, cannonId, bulletId, ratio, coin)
    --print("phoenix death.")
    local x, y = this:GetAnimNode():GetPos()
    GT = {
        srcX = x,
        srcY = y,
    }
    local cannon = player:GetNormalCannon()
    local bullet = cannon:CreateLuaBullet()
    bullet:SetId(FF_G.GetNextLuaBulletId(player:GetId()))
    bullet:SetRatio(ratio)
    bullet:SetLockValue(coin * ratio)
    bullet:SetLuaName("phoenix.lua")
    bullet:GetLua():SaveLuaDataFromGT()
    cannon:SendLuaBullet(bullet, 0)
    if not FF_G.IsServer then
        super.PlayDeathEffect()
    end
    return 0
end)
