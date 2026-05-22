-- thunder_dragon.lua
local this, lua, root = ...

local t, super = FF_G.LoadLuaFunc("script/fish/once_shake.lua")(this, lua, root)

local funcs = {}

local action

local musicIndex

funcs.OnInit = function()
    super.OnInit()
    if not FF_G.IsServer then
        local ret, action1 = root:ShowEffect("ext/lightning/fish_sd2.actions", "fish_sd2",
                "", FF_G.kNodeIndex_Ui, 0, 0, false)
        assert(ret)
        local anim = action1:GetAnim()
        anim:SetScale(FF_G_Client.GetScreenScaleX(), 1.0)
        action = action1
        musicIndex = FF_G.playEffect("ThunderDragonElectricity", true)
        this:SetShowDeathCoin(false)
    end
end

lua:Set_onInit(funcs.OnInit)

if not FF_G.IsServer then
    funcs.OnUnInit = function()
        super.OnUnInit()
        if action then
            action:SetClean(true)
            action = nil
        end
        if musicIndex then
            FF_G.stopEffect(musicIndex)
        end
    end
    lua:Set_onUnInit(funcs.OnUnInit)
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
    bullet:SetLuaName("thunder_dragon.lua")
    bullet:GetLua():SaveLuaDataFromGT()
    cannon:SendLuaBullet(bullet, 0)
    if not FF_G.IsServer then
        super.PlayDeathEffect()
    end
    return 0
end)

return t, funcs