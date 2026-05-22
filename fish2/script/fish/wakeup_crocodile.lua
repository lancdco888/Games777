-- fish/wakeup_crocodile.lua
local this, lua, root = ...

local t, super = FF_G.LoadLuaFunc("script/fish/base.lua")(this, lua, root)

local funcs = {}

funcs.OnInit = function()
    super.OnInit()
    if not FF_G.IsServer then
        this:SetShowDeathCoin(false)
        this:SetBeatable(false)
        this:SetDeathType(FF_G_Client.kFishDeathType_Shake2)
        t.disableDeathEffect = true
    end
end

if not FF_G.IsServer then
    lua:Set_onUnInit(function()
        super.OnUnInit()
        FF_G_Client.CloseMermaidEffect()
    end)
end

lua:Set_onDeath(function(player, cannonId, bulletId, ratio, coin)
    --local x, y = this:GetAnimNode():GetPos()
    local x, y = this:GetCurrentLockPoint()
    GT = {
        srcX = x,
        srcY = y,
        fishType = this:GetTypeId(),
    }
    local cannon = player:GetNormalCannon()
    local bullet = cannon:CreateLuaBullet()
    bullet:SetId(FF_G.GetNextLuaBulletId(player:GetId()))
    bullet:SetRatio(ratio)
    bullet:SetLockValue(coin * ratio)
    bullet:SetLuaName("wakeup_crocodile.lua")
    bullet:GetLua():SaveLuaDataFromGT()
    cannon:SendLuaBullet(bullet, 0)
    if not FF_G.IsServer then
        super.PlayDeathEffect()
    end
    return 0
end)

lua:Set_onInit(funcs.OnInit)