local VIPLevelUpLayer = {}
--Vip升级特效 
function VIPLevelUpLayer.PlayVIPLevelUpEffect()
    if not sGameManager.IsVipOpen() then
        return
    end

    --当前等级,升级等级
    local upLevel = sGameManager.GetMyVipLevel()
    local effect = {}
    effect.isclick = true
    effect._actionNode = cc.Node:create()
    effect._actionNode:setScale(Def.ScaleMin)
    gScene:addChild(effect._actionNode,1999)
    effect._actionNode:setPosition(cc.p(Def.visibleSize.width/2.0, Def.visibleSize.height/2.0))
    --灰色背景
    PopLayer:CreateShadow(effect._actionNode)
    local curLevel = upLevel - 1
    sp.SkeletonAnimation:attachmentAddNameReplace("num/0",string.format("num/%d",curLevel))
    sp.SkeletonAnimation:attachmentAddNameReplace("num/1",string.format("num/%d",upLevel))
    --创建升级spine动画
    local path = "hall/res/effect/xima/"
    local strJosnname = "slotvip_levelup0_1"
    local btnpos = -300
    local hengpingPos = {
        {20, -210},
    }
    local json_file1 = string.format("%s%s.%s",path,strJosnname,"json")
    local json_file2 = string.format("%s%s.%s",path,strJosnname,"atlas")
    local anim = sp.SkeletonAnimation:createWithJsonFile(json_file1,json_file2,1)
	effect._actionNode:addChild(anim)
    anim:setAnimation(0,"slotvip_levelup",false)
    sp.SkeletonAnimation:attachmentClearNameMap()
    
    --创建退出点击节点
    local path = "hall/res/studio/common/btn_1.png"
    effect._btn = ccui.Button:create(path, path, path, 0)
    effect._btn:addClickEventListener(function (sender)
        if effect.isclick then
            effect:_ClickCallFunc()
        end
    end)
    effect._btn:setName("_lang_qd")
    effect._btn:setTitleFontSize(30)
    -- #414146
    effect._actionNode:addChild(effect._btn)
    effect._btn:setTitleColor(cc.c3b(0x41,0x41,0x46))
    effect._btn:setTitleText("确定")
    effect._btn:setPositionY(btnpos)
    local infos = sGameManager.GetVipLevelInfo(upLevel)
    -- if UserData.activity_give_type == 0 then
    --     effect._tishi = cc.Label:createWithSystemFont("","Arial", 30)
    --     effect._tishi:setPosition(cc.p(hengpingPos[1][1], hengpingPos[1][2]))
    --     effect._actionNode:addChild(effect._tishi)
    --     local str = TR("开启绑定金币使用权限")
    --     effect._tishi:setString(str)
    --     effect._tishi:setScale(0.7)
    -- end

    --点击回调
    function effect:_ClickCallFunc()
        effect.isclick = false
        effect._actionNode:stopActionByTag(11111)
        --消失退出动画
        effect._actionNode:runAction(
            cc.Sequence:create(
                cc.ScaleTo:create(0.3,1.2),
                cc.ScaleTo:create(0.3,0),
                cc.RemoveSelf:create(true)
            )
        )
    end
    effect._actionNode:runAction(cc.Sequence:create(cc.DelayTime:create(4),cc.CallFunc:create(function ()
        anim:setAnimation(0,"slotvip_levelup_stay",true)
    end),cc.DelayTime:create(3),cc.CallFunc:create(function ()
        -- effect:_ClickCallFunc()
    end)))
    effect._actionNode:setTag(11111)
    TR_Node(effect._actionNode)
end

return VIPLevelUpLayer