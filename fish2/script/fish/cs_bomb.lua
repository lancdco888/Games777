-- fish/cs_bomb.lua
local this, lua, root = ...

local t, super = FF_G.LoadLuaFunc("script/fish/base.lua")(this, lua, root)

lua:Set_onDeath(function(player, cannonId, bulletId, ratio, coin)
    --print("bomb crab death.ratio:", ratio)
    if FF_G.IsServer then
        if not player:IsNull() then
            local tp = root:CurrentTimePoint()
            local effectTp = tp + 0.05
            local typeId = this:GetTypeId()
            local x, y = this:GetPos()
            player:PushStuff(x, y, 0, typeId, ratio, this:GetValue(), tp, effectTp, "cs_bomb.lua", true)
        end
    end
    if not FF_G.IsServer then
        super.PlayDeathEffect()
        this:SetShowDeathCoin(false)
    end
    this:SetState(FF_G.kState_Clean)
    return 1
end)