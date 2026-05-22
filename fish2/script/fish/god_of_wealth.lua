-- fish/god_of_wealth.lua
local this, lua, root = ...

local t, super = FF_G.LoadLuaFunc("script/fish/base.lua")(this, lua, root)

if not FF_G.IsServer then
    local ingotAction
    lua:Set_onInit(function()
        super.OnInit()
        local anim = this:GetAnimNode()
        local rootNode = FF_G_Client.GetAnimRootNode(anim)
        local drawNode = FF_G_Client.GetAnimDrawNode(anim)
        local drawNodeScaleY = drawNode:getScaleY()

        -- 显示倍率
        do
            local coinSprite = cc.Sprite:createWithSpriteFrameName("coins_wholelot.png")
            local txt = FF_G_Client.CreateNumText("texiao_suzi_%s.png", 67, 113)
            txt.SetString("" .. this:GetCoin())
            local txtNode = txt.node
            if drawNodeScaleY > 0 then
                coinSprite:setPosition(cc.p(-140, -110))
                coinSprite:setScale(0.5)
                txtNode:setPosition(cc.p(50, -80))
                txtNode:setScale(0.6)
                --print("abbbb")
            else
                coinSprite:setPosition(cc.p(140, 110))
                coinSprite:setScale(-0.5)
                txtNode:setPosition(cc.p(-50, 80))
                txtNode:setScale(-0.6)
                --txtNode:setRotation(8)
            end
            coinSprite:setRotation(-8)
            txtNode:setRotation(-8)
            txtNode:setCascadeOpacityEnabled(true)
            rootNode:addChild(coinSprite)
            rootNode:addChild(txtNode)
        end

        -- 抛金币动画
        do
            local ret, action = root:ShowEffect("ext/ingot/ingot.actions", "coin",
                    "", FF_G.kNodeIndex_FishTop, 0, 50 * drawNodeScaleY, false)
            assert(ret)
            local node = FF_G_Client.GetActionRootNode(action)
            local scale = 0.7
            local sy = scale * drawNodeScaleY

            action:GetAnim():SetScale(scale, sy)
            FF_G_Client.SwitchParentTo(node, rootNode)
            ingotAction = action
        end

        -- 出生动画
        if t.time < 0.5 then
            local ret, action = root:ShowEffect("ext/fish_gxfc/fish_gxfc.actions", "show",
                    "", FF_G.kNodeIndex_Ui, 0, 0, false)
            assert(ret)
            action:SetLoop(1)
            action:GetAnim():SetScale(0.85, 0.85)
            t.hasPopBornAnim = true
        end
    end)

    lua:Set_onUnInit(function()
        super.OnUnInit()
        if ingotAction then
            ingotAction:SetClean(true)
            ingotAction = nil
        end
    end)

end