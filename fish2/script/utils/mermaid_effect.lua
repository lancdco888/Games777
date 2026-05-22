-- utils/mermaid_effect.lua
local root = ...

if not FF_G.IsServer then

    FF_G_Client = FF_G_Client or {}

    local actions = {}

    local ref = 0

    local PushEffect = function(x, y, angle)
        local ret, action = root:ShowEffect(
                "ext/mermaid/fish_meirenyu_effect/fish_meirenyu_effect.actions",
                "kuang", "", FF_G.kNodeIndex_UiBottom, x, y, false)
        assert(ret)
        local anim = action:GetAnim()
        if angle then
            anim:SetAngle(angle)
        end
        table.insert(actions, action)
    end

    --local musicIndex

    -- 美人鱼界面四周❤效果
    FF_G_Client.ShowMermaidEffect = function()
        ref = ref + 1
        if ref > 1 then return end
        --musicIndex = FF_G.playEffect("Phoenix_OutFire", true)
        local offX = {0, -475, 475}
        for i = 1, 3 do
            PushEffect(offX[i], -360 + 35)
            PushEffect(offX[i], 360 - 35)
        end
        local x = 1280 * FF_G_Client.GetScreenScaleX()
        PushEffect(-x / 2 + 60, 0,  -math.pi / 2)
        PushEffect(x / 2 - 60, 0, math.pi / 2)
    end

    FF_G_Client.CloseMermaidEffect = function()
        ref = ref - 1
        if ref > 0 then return end
        for _, action in ipairs(actions) do
            action:SetClean(true)
        end
        ref = 0
        --if musicIndex then
        --    FF_G.stopEffect(musicIndex)
        --end
    end
end