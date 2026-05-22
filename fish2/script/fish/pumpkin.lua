-- god_arrived.lua
local this, lua, root = ...

local t, super = FF_G.LoadLuaFunc("script/fish/base.lua")(this, lua, root)

local funcs = {}

local ratioTxt

funcs.OnInit = function()
    super.OnInit()
    if FF_G.IsServer then
        this:SetCoinChangeable(true)
    end
    if not FF_G.IsServer then
        this:SetBeatable(false)
        this:SetDeathType(FF_G_Client.kFishDeathType_Shake2)

        local anim = this:GetAnimNode()
        local node = FF_G_Client.GetAnimRootNode(anim)
        local drawNode = FF_G_Client.GetAnimDrawNode(anim)

        do
            local sy = drawNode:getScaleY()
            local flip = sy < 0
            local offY = flip and 110 or -110
            local ret, action = root:ShowEffect("ext/fish_ngsxd/fish_ngsxd.actions", "show",
                    "", FF_G.kNodeIndex_Ui, 0, offY, false)
            assert(ret)
            local node1 = FF_G_Client.GetActionRootNode(action)
            node1:setCascadeOpacityEnabled(true)
            FF_G_Client.SwitchParentTo(node1, node)

            local txt = FF_G_Client.CreateNumText("no2_%s.png", 108, 120)
            txt.SetString("" .. this:GetCoin())
            --txt.node:setScale(sy, sy)
            txt.node:setPosition(0, -25)
            txt.node:setCascadeOpacityEnabled(true)
            node1:addChild(txt.node)

            if flip then
                action:GetAnim():SetAngle(math.pi)
            end

            ratioTxt = txt
        end
    end
end

lua:Set_onInit(funcs.OnInit)

if not FF_G.IsServer then
    lua:Set_onUnInit(function()
        super.OnUnInit()
        if this:IsDeath() then
            cc.SpriteFrameCache:getInstance():addSpriteFrames("ext/pumpkinBomb/pumpkinBomb_0.plist")
            local node = FF_G_Client.CreateFrameAnim(
                    "pumpkinBomb (%d).png", 1, 12, 1 / 15, true)
            node:setScale(3)
            FF_G_Client.AddNodeTo(node, FF_G.kNodeIndex_Ui)
        end
    end)

    lua:Set_onUpdate(function(dt)
        super.OnUpdate(dt)
        ratioTxt.SetString("" .. this:GetCoin())
        return 0
    end)

end

return t, funcs