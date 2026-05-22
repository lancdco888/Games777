-- zuantouxie.lua
local this, lua, root = ...

local t, super = FF_G.LoadLuaFunc("script/fish/base.lua")(this, lua, root)

lua:Set_onDeath(function(player, cannonId, bulletId, ratio, coin)
    --print("zuantouxie death.")
    if FF_G.IsServer then
        if not player:IsNull() then
            local tp = root:CurrentTimePoint()
            local effectTp = tp + 2.5
            --print("ratio:" .. ratio)
            local x, y = this:GetPos()
            player:PushStuff(x, y, 0, FF_G.kStuff_DrillCarb, ratio, this:GetValue(), tp, effectTp, "drill_carb.lua", true)
        end
    end
    if not FF_G.IsServer then
        this:SetShowDeathCoin(false)
        super.PlayDeathEffect()
    end
    return 0
end)
