local WaitingLayer = class("WaitingLayer", function()
    return Tools_Base.CreateLayer()
end)

function WaitingLayer:onEnter()
	local layout = ccui.Layout:create()
	layout:setContentSize(Tools_Base.visibleSize)
	layout:setLocalZOrder(2)
    layout:setBackGroundColorType(ccui.LayoutBackGroundColorType.solid)
	layout:setBackGroundColor(cc.c3b(1, 1, 1))
	layout:setBackGroundColorOpacity(0)
    self:addChild(layout)

    --点击事件
    local listener = cc.EventListenerTouchOneByOne:create()
	listener:setSwallowTouches(true)
	listener:registerScriptHandler(function(touch,event)
		return self:isVisible()			--隐藏时不阻塞事件
	end, cc.Handler.EVENT_TOUCH_BEGAN)
	cc.Director:getInstance():getEventDispatcher():addEventListenerWithSceneGraphPriority(listener, layout)

    --动画
    local eft = sp.SkeletonAnimation:createWithBinaryFile("waitting/texiao_loading.skel", "waitting/texiao_loading.atlas")
	eft:setAnchorPoint(cc.p(0.5,0.5))
	eft:setOpacityModifyRGB(false)
	eft:setAnimation(0, "loading", true)
	eft:setPosition(Tools_Base.visibleSize.width/2,Tools_Base.visibleSize.height/2 + 120)
	self:addChild(eft)
	eft:setScale(Tools_Base.ScaleMin)
	eft:setVisible(false)

	--文字
    -- local text_ = cc.Sprite:create("language/waitting/texiao_jiazaiziti.png")
	-- text_:setAnchorPoint(cc.p(0.5,0.5))
	-- text_:setPosition(Tools_Base.visibleSize.width/2, Tools_Base.visibleSize.height/2 + 60)

    local text_ = cc.Label:create()
	text_:setString(TR("连接中，请稍后"))
	text_:setSystemFontSize(40)
	text_:setAnchorPoint(cc.p(0.5,0.5))
	text_:setPosition(Tools_Base.visibleSize.width/2, Tools_Base.visibleSize.height/2 + 60)
	self:addChild(text_)
	text_:setVisible(false)
	text_:setScale(Tools_Base.ScaleMin)

    local text_2 = cc.Label:create()
	text_2:setString(TR("连接中，请稍后"))
	text_2:setSystemFontSize(40)
	text_:setColor(cc.c3b(0, 0, 0))
	text_2:setAnchorPoint(cc.p(0.5,0.5))
	text_2:setPosition(Tools_Base.visibleSize.width/2+2, Tools_Base.visibleSize.height/2 + 60-2)
	self:addChild(text_2)
	text_2:setVisible(false)
	text_2:setScale(Tools_Base.ScaleMin)

	self:setLocalZOrder(9999999)
	self:runAction(cc.Sequence:create(
		cc.DelayTime:create(0.5),
		cc.CallFunc:create(function()
			layout:setBackGroundColorOpacity(80)
			eft:setVisible(true)
			text_:setVisible(true)
			text_2:setVisible(true)
		end)
	))
end

return WaitingLayer
