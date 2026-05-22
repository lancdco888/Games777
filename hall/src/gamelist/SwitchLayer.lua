local SwitchLayer = class("SwitchLayer", function()
    return Tools.CreateLayer()
end)

-- type_ : 1从左到右, 2从右到左
function SwitchLayer:switch(type_)
	local skel = ""
	local atlas = ""
	local name = ""
	if type_ == 1 then
        skel = "effect/lobby/switch/skeletonhuanting_donghua_01.skel"
        atlas = "effect/lobby/switch/skeletonhuanting_donghua_01.atlas"
		name = "huanting_1"
	else
        skel = "effect/lobby/switch/skeletonhuanting_donghua_02.skel"
        atlas = "effect/lobby/switch/skeletonhuanting_donghua_02.atlas"
		name = "huanting_2"
	end
    local eft = sp.SkeletonAnimation:createWithBinaryFile(skel, atlas)
	eft:setOpacityModifyRGB(false)
    eft:setAnimation(0, name, false)
	eft:setAnchorPoint(cc.p(0.5, 0.5))
	eft:setScale(Def.ScaleMax)
    self:addChild(eft)
	local size = self:getContentSize()
    local eft_size = eft:getContentSize()
    local pos = cc.p(0, 0)
    eft:setPosition(pos)
	eft:setLocalZOrder(-1)
	
	self:stopAllActions()
	self:runAction(cc.Sequence:create(
		cc.DelayTime:create(2.0),
		cc.CallFunc:create(function()
			self:removeFromParent()
		end)
	))

    cc.Director:getInstance():getRunningScene():addChild(self)
    self:setLocalZOrder(100)
    local size = Def.visibleSize
    self:setPositionX(size.width/2)
    self:setPositionY(size.height/2)
end

return SwitchLayer
