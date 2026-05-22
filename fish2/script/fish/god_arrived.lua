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
        t.disableDeathEffect = true
        this:SetDeathType(FF_G_Client.kFishDeathType_Shake2)

        local anim = this:GetAnimNode()
        local node = FF_G_Client.GetAnimRootNode(anim)
        local drawNode = FF_G_Client.GetAnimDrawNode(anim)

        local node1 = cc.Node:create()
        local txt = FF_G_Client.CreateNumText("no2_%s.png", 108, 120)
        txt.SetString("" .. this:GetCoin())
        node1:addChild(txt.node)
        node:addChild(node1)
        node1:setCascadeOpacityEnabled(true)

        local sy = drawNode:getScaleY()
        txt.node:setScale(sy, sy)
        ratioTxt = txt
    end
end

lua:Set_onInit(funcs.OnInit)

if not FF_G.IsServer then
--     funcs.OnUnInit = function()
--         super.ShowDeathEffect()
--     end
--     lua:Set_onUnInit(funcs.OnUnInit)

    lua:Set_onUpdate(function(dt)
        super.OnUpdate(dt)
        ratioTxt.SetString("" .. this:GetCoin())
        return 0
    end)

    lua:Set_onDeath(function(player, cannonId, bulletId, ratio, coin)
        this:SetShowDeathCoin(false)
        super.PlayDeathEffect()
        local ret, action = root:ShowEffect("ext/fish_scroll_chuxian/fish_scorll.actions", "show",
                            "", FF_G.kNodeIndex_Ui, 0, 0, false)
        assert(ret)
        action:SetLoop(1)

        local x, y = this:GetPos()
        x, y = FF_G_Client.ConvertToUiPos(x, y)
        local px, py = FF_G_Client.GetPlayerUiPos(player)

        local pInBottom = FF_G_Client.IsPlayerInBottomWithRotate(player)
        if not pInBottom then
            py = py - 400
        end

        local anim = action:GetAnim()
        local node = FF_G_Client.GetAnimRootNode(anim)
        --local drawNode = FF_G_Client.GetAnimDrawNode(anim)

        local panel = cc.Node:create()
        FF_G_Client.SwitchParentTo(node, panel)
        FF_G_Client.AddNodeTo(panel, FF_G.kNodeIndex_Ui)

        local playerId = player:GetId()
        local fishTypeId = this:GetTypeId()
        local value = ratio * coin;
        panel:setPosition(x, y)
        -- 11.9333
        panel:runAction(
                cc.Sequence:create(
                        cc.MoveTo:create(0.5, cc.p(0, 0)),
                        cc.DelayTime:create(1.9),
                        cc.MoveTo:create(0.25, cc.p(px, py)),
                        cc.DelayTime:create(9.28),
                        cc.CallFunc:create(function()
                            FF_G_Client.ShowFishDeathEffect(playerId, fishTypeId, value)
                        end),
                        cc.RemoveSelf:create()
                )
        )

        do
            local txt = FF_G_Client.CreateNumText("texiao_suzi_%s.png", 67, 113)
            txt.SetString("" .. 0)
            node:addChild(txt.node)
            FF_G_Client.PushNode(txt.node)
            anim:BindSlot("", "fen")

            local destValue = value
            local tp = root:CurrentTimePoint()
            txt.node:onUpdate(function()
                local secs = root:CurrentTimePoint() - tp
                local value = 0
                local needUpdate = true
                if secs >= 5.67 and secs <= 6.17 then
                    value = destValue / 3 * (secs - 5.67)
                elseif secs >= 7.77 and secs <= 8.27 then
                    value = destValue / 3 + destValue / 3 * (secs - 7.77)
                elseif secs >= 10 and secs <= 10.5 then
                    value = destValue / 3 * 2 + destValue / 3 * (secs - 10)
                else
                    needUpdate = false
                end
                if needUpdate then
                    txt.SetString("" .. math.floor(value))
                end
            end)
        end

        do
            local txt = FF_G_Client.CreateNumText("sz_%s.png", 39, 49)
            txt.SetString("x" .. coin)
            node:addChild(txt.node)
            FF_G_Client.PushNode(txt.node)
            anim:BindSlot("", "X404")
        end
        return 0
    end)
end

return t, funcs