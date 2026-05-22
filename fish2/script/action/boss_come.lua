-- action/boss_come.lua
local this, lua, root = ...

if not FF_G.IsServer then
    lua:Set_onInit(function()
        --cc.SpriteFrameCache:getInstance():addSpriteFrames("ui/ui2.plist")
        local maxRatio = FF_PRAMS.ratio or FF_G.GetMaxRatioByFishTypeId(FF_PRAMS.fishTypeId)
        assert(maxRatio)

        local anim = this:GetAnim()
        local node = FF_G_Client.GetAnimRootNode(anim)
        node:setLocalZOrder(1)
        --
        local tips1 = cc.Sprite:createWithSpriteFrameName("texiao_boss_zuidabeijiangliziti.png")
        node:addChild(tips1)
        FF_G_Client.PushNode(tips1)
        anim:BindSlot("best", "best")

        local boss1 = cc.Sprite:createWithSpriteFrameName("boos_dengchang.png")
        local boss2 = cc.Sprite:createWithSpriteFrameName("boos_dengchang.png")

        node:addChild(boss1)
        node:addChild(boss2)
        FF_G_Client.PushNode(boss1)
        FF_G_Client.PushNode(boss2)
        anim:BindSlot("bossfont", "boos_1")
        anim:BindSlot("bossfont", "boos_2")

        local txt = FF_G_Client.CreateNumText("texiao_suzi1_%s.png", 108, 120)
        txt.SetString("" .. maxRatio)
        node:addChild(txt.node)
        FF_G_Client.PushNode(txt.node)
        anim:BindSlot("num", "num")
    end)
end
