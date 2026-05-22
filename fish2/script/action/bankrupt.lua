-- action/boss_come.lua
local this, lua, root = ...

if not FF_G.IsServer then
    lua:Set_onInit(function()
        print("bankrupt anim.")
        local anim = this:GetAnim()
        anim:SetDisableSlotBindVisibleProp(true)
        local node = FF_G_Client.GetAnimRootNode(anim)
        node:setLocalZOrder(1)

        local txt1 = cc.Sprite:createWithSpriteFrameName("po_01.png")
        local txt2 = cc.Sprite:createWithSpriteFrameName("po_02.png")
        local txt3 = cc.Sprite:createWithSpriteFrameName("chan_01.png")
        local txt4 = cc.Sprite:createWithSpriteFrameName("chan_02.png")

        node:addChild(txt1)
        node:addChild(txt2)
        node:addChild(txt3)
        node:addChild(txt4)

        FF_G_Client.PushNode(txt1)
        FF_G_Client.PushNode(txt2)
        FF_G_Client.PushNode(txt3)
        FF_G_Client.PushNode(txt4)

        anim:BindSlot("", "chan_h")
        anim:BindSlot("", "chan")
        anim:BindSlot("", "po_h")
        anim:BindSlot("", "po")
    end)
end
