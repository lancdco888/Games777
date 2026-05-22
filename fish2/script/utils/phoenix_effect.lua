-- utils/phoenix_effect.lua
local root = ...

if not FF_G.IsServer then

    FF_G_Client = FF_G_Client or {}

    local actions = {}

    local ref = 0

    local PushEffect = function(x, y, scaleX, scaleY, angle)
        local ret, action = root:ShowEffect("actions/golden/phoenix.actions", "screen_fire",
                "", FF_G.kNodeIndex_UiBottom, x, y, false)
        assert(ret)
        local anim = action:GetAnim()
        anim:SetScale(2.5 * scaleX, 2.5 * scaleY)
        if angle then
            anim:SetAngle(angle)
        end
        table.insert(actions, action)
    end

    local musicIndex

    --  凤凰火焰效果
    FF_G_Client.ShowPhoenixScreenEdgeFireEffect = function()
        ref = ref + 1
        if ref > 1 then return end
        musicIndex = FF_G.playEffect("Phoenix_OutFire", true)
        local offX = {0, -475, 475}
        for i = 1, 3 do
            PushEffect(offX[i], -360 + 35, 1, 1)
            PushEffect(offX[i], 360 - 35, 1, -1)
        end
        --local visibleSize = cc.Director:getInstance():getVisibleSize()
        --local root = FF_G_Client.GetRootNode():getParent()
        --local x = visibleSize.width / root:getScaleX()
        local x = 1280 * FF_G_Client.GetScreenScaleX()
        PushEffect(- x / 2 + 60, 0, 1, 1, -math.pi / 2)
        PushEffect(x / 2 - 60, 0, 1, 1, math.pi / 2)
    end

    FF_G_Client.ClosePhoenixScreenEdgeFireEffect = function()
        ref = ref - 1
        if ref > 0 then return end
        for _, action in ipairs(actions) do
            action:SetClean(true)
        end
        ref = 0
        if musicIndex then
            FF_G.stopEffect(musicIndex)
        end
    end
end