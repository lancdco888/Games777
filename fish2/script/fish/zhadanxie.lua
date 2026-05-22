-- fish/zhadanxie.lua
local this, lua, root = ...

local t, super = FF_G.LoadLuaFunc("script/fish/base.lua")(this, lua, root)

lua:Set_onDeath(function(player, cannonId, bulletId, ratio, coin)
    --print("bomb crab death.ratio:", ratio)
    if FF_G.IsServer then
        if not player:IsNull() then
            local tp = root:CurrentTimePoint()
            local effectTp = tp + 0.15
            --local typeId = this:GetTypeId() == FF_G.FishInfo.MultipleBombCarb.typeId
            --        and FF_G.kStuff_MultipleBombCarb or FF_G.kStuff_BombCarb
            local typeId = this:GetTypeId()
            local x, y = this:GetPos()
            player:PushStuff(x, y, 0, typeId, ratio, this:GetValue(), tp, effectTp, "bomb_carb.lua", true)
        end
    end
    if not FF_G.IsServer then
        super.PlayDeathEffect()
        this:SetShowDeathCoin(false)
    end

    --local cannon = player:GetNormalCannon()
    --local anim = root:CreateAnimNode("actions/special/zhadanxie.anims")
    --local x, y = this:GetPos()
    --local coin = this:GetCoin()
    ----local value = this:GetValue()
    --local value = coin * ratio
    --anim:SetAngle(this:GetAngle())
    --anim:SetPos(x, y)
    --local bullet = cannon:CreateLuaBullet()
    --bullet:SetAnim(anim)
    --bullet:SetId(cannon:GetNextSpecialBulletId())
    --bullet:SetLuaName("zhadanxie.lua")
    --bullet:SetRatio(ratio)
    --bullet:SetLockValue(value)
    --local isMultiple = this:GetTypeId() == FF_G.FishInfo.MultipleBombCarb.typeId
    --local bulletCount = math.floor(value / ratio)
    --local totalTimes = 1
    --if isMultiple then
    --    totalTimes = math.floor(bulletCount / 100)
    --end
    --GT = {
    --    srcPos = {x, y},
    --    ratio = ratio,
    --    bulletCount = bulletCount,
    --    isMultiple = isMultiple,
    --    totalTimes = math.min(9, totalTimes),
    --}
    --bullet:GetLua():SaveLuaDataFromGT()
    --cannon:SendLuaBullet(bullet, 0)
    this:SetState(FF_G.kState_Clean)
    return 1
end)