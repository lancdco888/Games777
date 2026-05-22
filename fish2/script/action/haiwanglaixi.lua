-- action/haiwanglaixi.lua
local this, lua, root = ...

if not FF_G.IsServer then
    lua:Set_onInit(function()
        --cc.SpriteFrameCache:getInstance():addSpriteFrames("ui/ui2.plist")
        local ratio = FF_PRAMS.ratio
        local fishType = FF_PRAMS.fishType
        assert(fishType)

        local anim = this:GetAnim()
        local node = FF_G_Client.GetAnimRootNode(anim)
        local bg = cc.LayerColor:create(cc.c4b(0, 0, 0, 150), 3000, 2000)
        bg:setPosition(cc.p(-1500, -1000))
        node:setLocalZOrder(1)
        node:addChild(bg, -1)

        local boss, tips2
        local tips1 = cc.Sprite:createWithSpriteFrameName("texiao_haiwanglaixi.png")
        local tips3 = cc.Sprite:createWithSpriteFrameName("texiao_boss_zuidabeijiangliziti.png")

        if fishType == FF_G.Haiwanglaixi_FishType_NightBeast then
            boss = cc.Sprite:createWithSpriteFrameName("texiao_anyejushou_big.png")
            tips2 = cc.Sprite:createWithSpriteFrameName("texiao_anyejushou_ziti.png")
            ratio = ratio or FF_G.FishInfo.NightBeast.coin[2]
        elseif fishType == FF_G.Haiwanglaixi_FishType_Crocodile then
            boss = cc.Sprite:createWithSpriteFrameName("texiao_shiqianjue_big.png")
            tips2 = cc.Sprite:createWithSpriteFrameName("texiao_shiqianjueziti.png")
            ratio = ratio or FF_G.FishInfo.Crocodile.coin[2]
        elseif fishType == FF_G.Haiwanglaixi_FishType_KingCrab then
            boss = cc.Sprite:createWithSpriteFrameName("texiao_pangxie_big.png")
            tips2 = cc.Sprite:createWithSpriteFrameName("texiao_bawangxieziti.png")
            ratio = ratio or FF_G.FishInfo.KingCrab.coin[2]
        elseif fishType == FF_G.Haiwanglaixi_FishType_KingOctopus then
            boss = cc.Sprite:createWithSpriteFrameName("texiao_bazhuazhangyu_big.png")
            tips2 = cc.Sprite:createWithSpriteFrameName("texiao_bazhuazhangyu_ziti.png")
            ratio = ratio or FF_G.FishInfo.KingOctopus.coin[2]
        elseif fishType == FF_G.Haiwanglaixi_FishType_WakeupNightBeast then
            boss = cc.Sprite:createWithSpriteFrameName("texiao_juexing_anyejushou.png")
            tips2 = cc.Sprite:createWithSpriteFrameName("texiao_anyejushou_ziti.png")
            ratio = ratio or FF_G.FishInfo.WakeupNightBeast.coin[2]
        elseif fishType == FF_G.Haiwanglaixi_FishType_WakeupCrocodile then
            boss = cc.Sprite:createWithSpriteFrameName("texiao_juexing_shiqianjue.png")
            tips2 = cc.Sprite:createWithSpriteFrameName("texiao_shiqianjueziti.png")
            ratio = ratio or FF_G.FishInfo.WakeupCrocodile.coin[2]
        elseif fishType == FF_G.Haiwanglaixi_FishType_WakeupKingCrab then
            boss = cc.Sprite:createWithSpriteFrameName("texiao_juexing_pangxie.png")
            tips2 = cc.Sprite:createWithSpriteFrameName("texiao_bawangxieziti.png")
            ratio = ratio or FF_G.FishInfo.WakeupKingCrab.coin[2]
        elseif fishType == FF_G.Haiwanglaixi_FishType_WakeupKingOctopus then
            boss = cc.Sprite:createWithSpriteFrameName("texiao_juexing_zhangyu.png")
            tips2 = cc.Sprite:createWithSpriteFrameName("texiao_bazhuazhangyu_ziti.png")
            ratio = ratio or FF_G.FishInfo.WakeupKingOctopus.coin[2]
        end

        assert(ratio)
        assert(boss)
        assert(tips1)
        assert(tips2)
        assert(tips3)
        node:addChild(boss)
        node:addChild(tips1)
        node:addChild(tips2)
        node:addChild(tips3)
        FF_G_Client.PushNode(boss)
        anim:BindBone("texiao_booostupian")
        FF_G_Client.PushNode(tips1)
        anim:BindBone("texiao_huangseziti_1")
        FF_G_Client.PushNode(tips2)
        anim:BindBone("texiao_huangseziti_2")
        FF_G_Client.PushNode(tips3)
        anim:BindBone("beijiangli")

        local txt = FF_G_Client.CreateNumText("texiao_suzi1_%s.png", 108, 120)
        txt.SetString("" .. ratio)
        node:addChild(txt.node)
        FF_G_Client.PushNode(txt.node)
        anim:BindBone("shuzi")
    end)
end
