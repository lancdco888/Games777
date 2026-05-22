-- fish/wakeup_anyejushou.lua
local this, lua, root = ...

local t, super = FF_G.LoadLuaFunc("script/fish/base.lua")(this, lua, root)

local bgSprite

if not FF_G.IsServer then
    lua:Set_onInit(function()
        super.OnInit()
        local anim = this:GetAnimNode()
        local node = cc.Node:create()
        bgSprite = cc.Sprite:create("ui/base/anyejushou_zhaoliangquyu.png")
        bgSprite:setScale(2.5)
        node:addChild(bgSprite)
        cc.Director:getInstance():pushNode(node)
        anim:BindBone("light electric")
        local root = FF_G_Client.GetAnimRootNode(anim)
        root:addChild(node)
        this:SetBeatable(false)
        this:SetDeathType(FF_G_Client.kFishDeathType_Shake2)
    end)
end

lua:Set_onDeath(function(player, cannonId, bulletId, ratio, coin)
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
    bullet:SetLuaName("wakeup_nightbeast.lua")
    bullet:GetLua():SaveLuaDataFromGT()
    cannon:SendLuaBullet(bullet, 0)
    if not FF_G.IsServer then
        super.PlayDeathEffect()
        --FF_G_Client.ShowFishDeathEffect(player:GetId(), this:GetTypeId(), ratio * coin)
        local anim = this:GetAnimNode()
        anim:UnbindBone("LightGlow")
        if bgSprite then
            bgSprite:setVisible(false)
        end
    end
    return 0
end)
