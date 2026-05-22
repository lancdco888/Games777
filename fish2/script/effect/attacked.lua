-- effect/attacked.lua
local this, _, _, isLaser = ...
-- fish, fish lua, root

-- 受击效果
if not FF_G.IsServer then
    if not isLaser then
        FF_G.playEffect("shoot_01")
    end
    local anim = this:GetAnimNode()
    local node = FF_G_Client.GetAnimDrawNode(anim)

    node:stopActionByTag(100)
    local action = cc.Repeat:create(
            cc.Sequence:create(
                    cc.TintTo:create(0.15, 255, 115, 115),
                    cc.TintTo:create(0.15, 255, 255, 255)
            ),
            2
    )
    action:setTag(100)
    node:runAction(action)
end
