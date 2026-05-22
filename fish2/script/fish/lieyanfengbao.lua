-- fish/lieyanfengbao.lua
local this, lua, root = ...

local t, super = FF_G.LoadLuaFunc("script/fish/base.lua")(this, lua, root)

-- 声明用户数据
t.inited = false

local createEffect = function(rootNode)
    local ret, effect = root:ShowEffect("actions/special/lieyanfengbao.actions", "move_texiao",
            "", FF_G.kNodeIndex_EffectTop, 0, 0, false)
    assert(ret)
    local effectAnim = effect:GetAnim()
    local effectRoot = FF_G_Client.GetAnimRootNode(effectAnim)
    FF_G_Client.SwitchParentTo(effectRoot, rootNode)
    --effectRoot:setLocalZOrder(-1)
    effectAnim:SetZ(-1)
    return effectAnim
end

lua:Set_onInit(function()
    super.OnInit()
    if not FF_G.IsServer then
        local rootNode = FF_G_Client.GetAnimRootNode(this:GetAnimNode())
        local effectNode1 = createEffect(rootNode)
        local effectNode2 = createEffect(rootNode)
        effectNode1:SetPos(-10, -60)
        effectNode2:SetPos(-10, 50)
        effectNode2:SetScale(1, -1)
        --t.mustPlayDeathEffect = true
    end
    t.inited = true
    return 0
end)

lua:Set_onDeath(function(player, cannonId, bulletId, ratio, coin)
    --print("lieyanfengbao death.")
    if FF_G.IsServer then
        if not player:IsNull() then
            local tp = root:CurrentTimePoint()
            local effectTp = tp + 4.5
            --print("ratio:" .. ratio)
            local x, y = this:GetPos()
            player:PushStuff(x, y, 0, FF_G.kStuff_FlamesStorm, ratio, ratio * coin, tp, effectTp, "flames_storm.lua", true)
        end
    end
    if not FF_G.IsServer then
        super.PlayDeathEffect()
        this:SetShowDeathCoin(false)
    end
    return 0
end)

