-- effect/death.lua
local this, lua, root, deathType = ...

-- 死亡效果
if not FF_G.IsServer then
    --print("death:", deathType)
    local anim = this:GetAnimNode()
    local node = FF_G_Client.GetAnimDrawNode(anim)
    local rootNode = FF_G_Client.GetAnimRootNode(anim)

    local action = this:GetActionNode()
    action:SetAction("die")
    if not this:GetBeatable() then
        local drawNode = node
        node = cc.Node:create()
        node:setLocalZOrder(anim:GetZ())
        rootNode:getParent():addChild(node)
        FF_G_Client.SwitchParentTo(rootNode, node)
        action:SetSpeed(0)
        action:SetStop(true)
        drawNode:registerScriptHandler(function(event)
            if event == "exit" then
                --print("exit")
                node:runAction(cc.RemoveSelf:create())
                node:stopAllActions()
            end
        end)
    end
    rootNode:setCascadeOpacityEnabled(true)
    node:setCascadeOpacityEnabled(true)
    do
        --local x, y = anim:GetPos()
        local tp = root:CurrentTimePoint()
        local secs = anim:GetElapsedSeconds()
        node:runAction(cc.RepeatForever:create(cc.Sequence:create(
                cc.CallFunc:create(function()
                    --anim:SetPos(x, y)
                    local dt = root:CurrentTimePoint() - tp
                    local opacity = math.max(0, 255 - 255 * (dt / 1))
                    --print("opacity:", opacity)
                    this:SetOpacity(opacity)
                    rootNode:setOpacity(opacity)
                    anim:SetElapsedSeconds(secs)
                end)
        )))
    end
    if deathType == FF_G_Client.kFishDeathType_Normal then
        node:runAction(cc.Sequence:create(
                cc.DelayTime:create(0.05),
                cc.ScaleTo:create(0.45, 0),
                cc.CallFunc:create(function()
                    this:SetState(FF_G.kState_Clean)
                end)
                --cc.RemoveSelf:create()
        ))
    elseif deathType == FF_G_Client.kFishDeathType_RotationAndFadeOut then
        local action = cc.Sequence:create(
                cc.ScaleTo:create(0.5, 0),
                cc.CallFunc:create(function()
                    this:SetState(FF_G.kState_Clean)
                end)
                --cc.RemoveSelf:create()
        )
        node:runAction(action)
    elseif deathType == FF_G_Client.kFishDeathType_Shake then
        --action:SetStop(true)
        this:SetState(FF_G.kState_Lock)
        local action = cc.Sequence:create(
                cc.Repeat:create(
                        cc.Sequence:create(
                                cc.RotateBy:create(0.05, -15),
                                cc.RotateBy:create(0.05, 15)
                        ), 15),
                cc.CallFunc:create(function()
                    this:SetState(FF_G.kState_Clean)
                end)
        )
        node:runAction(action)
    elseif deathType == FF_G_Client.kFishDeathType_Shake2 then
        --action:SetStop(true)
        this:SetState(FF_G.kState_Lock)
        local action = cc.Sequence:create(
                cc.Repeat:create(
                        cc.Sequence:create(
                                cc.MoveBy:create(0.025, cc.p(15, 0)),
                                cc.MoveBy:create(0.025, cc.p(-15, 0)),
                                cc.MoveBy:create(0.025, cc.p(0, 15)),
                                cc.MoveBy:create(0.025, cc.p(0, -15))
                        ), 20),
                cc.CallFunc:create(function()
                    this:SetState(FF_G.kState_Clean)
                end)
                --cc.RemoveSelf:create()
        )
        node:runAction(action)
    end
    --print(node:getTag())
end
