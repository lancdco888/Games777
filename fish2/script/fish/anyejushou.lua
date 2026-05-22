-- fish/anyejushou.lua
local this, lua, root = ...

local t, super = FF_G.LoadLuaFunc("script/fish/base.lua")(this, lua, root)

if not FF_G.IsServer then
    local bgSprite
    lua:Set_onInit(function()
        super.OnInit()
        local anim = this:GetAnimNode()
        local node = cc.Node:create()
        bgSprite = cc.Sprite:create("ui/base/anyejushou_zhaoliangquyu.png")
        bgSprite:setScale(1.5)
        node:addChild(bgSprite)
        cc.Director:getInstance():pushNode(node)
        anim:BindBone("LightGlow")
        local root = FF_G_Client.GetAnimRootNode(anim)
        root:addChild(node)
    end)

    lua:Set_onDeath(function(player, cannonId, bulletId, ratio, coin)
        super.PlayDeathEffect()
        FF_G_Client.ShowFishDeathEffect(player:GetId(), this:GetTypeId(), ratio * coin)
        local anim = this:GetAnimNode()
        anim:UnbindBone("LightGlow")
        if bgSprite then
            bgSprite:setVisible(false)
        end
        return 0
    end)
end
