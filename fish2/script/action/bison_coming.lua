-- action/bison_coming.lua
local this, lua, root = ...

if not FF_G.IsServer then
    lua:Set_onInit(function()
        FF_G.playEffect("Buffalo_Announce")
        this:SetLoop(1)
        local isRunAway = FF_PRAMS.isRunAway
        local anim = this:GetAnim()
        anim:SetDisableSlotBindVisibleProp(true)
        local node = FF_G_Client.GetAnimRootNode(anim)
        node:setLocalZOrder(1)

        if isRunAway then

        else
            local come_tittle_L = cc.Sprite:createWithSpriteFrameName("come_tittle_L.png")
            local come_tittle_R = cc.Sprite:createWithSpriteFrameName("come_tittle_R.png")

            local come_tittle_light = cc.Sprite:createWithSpriteFrameName("come_tittle_light.png")
            local come_tittle_light_add = cc.Sprite:createWithSpriteFrameName("come_tittle_light.png")

            local come_tittleBG = cc.Sprite:createWithSpriteFrameName("come_tittleBG.png")
            --local come_tittle02 = cc.Sprite:createWithSpriteFrameName("come_tittle02.png")

            local cominglight = cc.Sprite:createWithSpriteFrameName("cominglight.png")
            local cominglight_add = cc.Sprite:createWithSpriteFrameName("cominglight.png")


            node:addChild(come_tittle_L)
            node:addChild(come_tittle_R)
            node:addChild(come_tittle_light)
            node:addChild(come_tittle_light_add)
            node:addChild(come_tittleBG)
            --node:addChild(come_tittle02)
            node:addChild(cominglight)
            node:addChild(cominglight_add)

            FF_G_Client.PushNode(come_tittle_L)
            FF_G_Client.PushNode(come_tittle_R)
            FF_G_Client.PushNode(come_tittle_light)
            FF_G_Client.PushNode(come_tittle_light_add)
            FF_G_Client.PushNode(come_tittleBG)
            --FF_G_Client.PushNode(come_tittle02)
            FF_G_Client.PushNode(cominglight)
            FF_G_Client.PushNode(cominglight_add)

            anim:BindSlot("", "cominglight_add")
            anim:BindSlot("", "cominglight")
            --anim:BindSlot("", "come_tittle02")
            anim:BindSlot("", "come_tittleBG")
            anim:BindSlot("", "come_tittle_light_add")
            anim:BindSlot("", "come_tittle_light")
            anim:BindSlot("", "come_tittle_R")
            anim:BindSlot("", "come_tittle_L")
        end
    end)
end
