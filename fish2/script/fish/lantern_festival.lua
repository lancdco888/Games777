-- fish/lantern_festival.lua
local this, lua, root = ...

local t, super = FF_G.LoadLuaFunc("script/fish/base.lua")(this, lua, root)

if not FF_G.IsServer then
    local effectDelta = 3.0

    lua:Set_onInit(function()
        super.OnInit()
        t.nextShowEffectTime = effectDelta
    end)
    lua:Set_onUpdate(function(dt)
        super.OnUpdate(dt)
        t.nextShowEffectTime = t.nextShowEffectTime - dt
        if t.nextShowEffectTime <= 0 then
            local x, y = this:GetPos()
            local ret, action = root:ShowEffect("ext/yuanxiao/fish_yuanxiao.actions", "yuanxiao",
                    "", FF_G.kNodeIndex_FishTop, x, y, false)
            assert(ret)
            action:SetLoop(1)
            action:GetAnim():SetScale(1.5, 1.5)
            t.nextShowEffectTime = effectDelta
        end
        return 0
    end)
end