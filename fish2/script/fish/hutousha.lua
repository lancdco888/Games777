-- fish/hutousha.lua
local this, lua, root = ...

local t, super = FF_G.LoadLuaFunc("script/fish/base.lua")(this, lua, root)

-- 声明用户数据
t.angle = 0
t.init = false

--local t = {
--    angle = 0,
--    init = false
--}

--lua:Set_onInit(function()
--    print("hutousha onInit")
--    return 0
--end)

if not FF_G.IsServer then
    lua:Set_onEvent(function(eventId)
        --print("event:" .. eventId .. "," .. this:GetId())
        if eventId == 1000 then
            local x, y = this:GetPosWithPathway(1)
            local ret, action = root:ShowEffect("actions/golden/hutousha.actions", "pre",
                    "", FF_G.kNodeIndex_EffectBottom, x, y, true)
            assert(ret)
            local animNode = action:GetAnim()
            animNode:PushDrawNode()
            local drawNode = cc.Director:getInstance():popNode()
            local secs = action:GetCurrentActionSeconds()
            drawNode:runAction(cc.FadeOut:create(secs))
            this:PushEffect(action)
        elseif eventId == 1001 then
            local x, y = this:GetPosWithPathway(1.7)
            local ret, action = root:ShowEffect("actions/golden/hutousha.actions", "pre",
                    "", FF_G.kNodeIndex_EffectBottom, x, y, true)
            assert(ret)
            local animNode = action:GetAnim()
            animNode:PushDrawNode()
            local drawNode = cc.Director:getInstance():popNode()
            local secs = action:GetCurrentActionSeconds()
            drawNode:runAction(cc.FadeOut:create(secs))
            this:PushEffect(action)
        end
    end)
end
--if not FF_G.IsServer then
--    lua:Set_onDeath(function(player, _, _,ratio, coin)
--        FF_G_Client.ShowFishDeathEffect(player:GetId(), this:GetTypeId(), ratio * coin)
--        return 0
--    end)
--end
