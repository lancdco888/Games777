local EffectLayerStar = class("EffectLayerStar", function()
    return Tools.CreateLayer()
end)

function EffectLayerStar:ctor()
    self.sp_name = "lobby/star.png"
    self.Lobby_BGEffectHDis = 40
    self.Lobby_BGEffectVDis = 40
end

function EffectLayerStar:onEnter()
    self:runAction(cc.Sequence:create(
        cc.DelayTime:create(0.8),
        cc.CallFunc:create(function()
            self:Start()
        end)
    ))
end

function EffectLayerStar:Start()
    local total = 32
    local num = total / 4
    for i = 1, num do
        self:AddLeftDownEft()
    end
    
    num = total / 2
    for i = total / 4 + 1, num do
        self:AddLeftUpEft()
    end

    num = total / 2
    for i = total / 2 + 1, num do
        self:AddRightDownEft()
    end

    for i = total / 4 * 3 + 1, total do
        self:AddRightUpEft()
    end
end

--光点特效
function EffectLayerStar:AddLeftDownEft()
	local eft = cc.Sprite:create(self.sp_name)
	local posX = math.random(self.Lobby_BGEffectHDis, Def.visibleSize.width / 2)
	local posY = math.random(self.Lobby_BGEffectVDis, Def.visibleSize.height / 2)
	eft:setAnchorPoint(cc.p(0,0))
	eft:setPosition(posX, posY)
	eft:setLocalZOrder(-1)
    self:addChild(eft)

	local offsetX = math.random(-200, 200)
	local offsetY = math.random(-50, 50)
	local time = math.random(2,3)
	local time1 = time / 5
	local time2 = time / 5 * 2
	local time3 = time / 5 * 2
	eft:runAction(cc.Sequence:create(cc.MoveTo:create(time1,cc.p(posX + offsetX / 7, posY + offsetY / 7)), 
									cc.DelayTime:create(0.02),
									cc.MoveTo:create(time2, cc.p(posX + offsetX / 7 * 3, posY + offsetY / 7 * 3)),
									cc.MoveTo:create(time3, cc.p(posX + offsetX , posY + offsetY)),
									cc.RemoveSelf:create()))
	eft:runAction(cc.Sequence:create(cc.ScaleTo:create(time1,1.0),cc.DelayTime:create(0.02),cc.ScaleTo:create(time2 + time3, 0.0)))
    self:runAction(
        cc.Sequence:create(
            cc.DelayTime:create(time1 + 0.02 + time2 + time3),
            cc.CallFunc:create(function()
                self:AddLeftDownEft()
            end))
    )
end

function EffectLayerStar:AddLeftUpEft()
	local eft = cc.Sprite:create(self.sp_name)
	local posX = math.random(self.Lobby_BGEffectHDis, Def.visibleSize.width / 2)
	local posY = math.random(Def.visibleSize.height / 2,Def.visibleSize.height - self.Lobby_BGEffectVDis)
	eft:setAnchorPoint(cc.p(0,0))
	eft:setPosition(posX, posY)
	eft:setLocalZOrder(-1)
    self:addChild(eft)

	local offsetX = math.random(-200, 200)
	local offsetY = math.random(-50, 50)
	local time = math.random(2,3)
	local time1 = time / 5
	local time2 = time / 5 * 2
	local time3 = time / 5 * 2
	eft:runAction(cc.Sequence:create(cc.MoveTo:create(time1,cc.p(posX + offsetX / 7, posY + offsetY / 7)), 
									cc.DelayTime:create(0.02),
									cc.MoveTo:create(time2, cc.p(posX + offsetX / 7 * 3, posY + offsetY / 7 * 3)),
									cc.MoveTo:create(time3, cc.p(posX + offsetX , posY + offsetY)),
									cc.RemoveSelf:create()))
	eft:runAction(cc.Sequence:create(cc.ScaleTo:create(time1,1.0),cc.DelayTime:create(0.02),cc.ScaleTo:create(time2 + time3,0.0)))

	self:runAction(
        cc.Sequence:create(
            cc.DelayTime:create(time1 + 0.02 + time2 + time3),
            cc.CallFunc:create(
                function()
                    self:AddLeftUpEft()
                end
            )
        )
    )
end

function EffectLayerStar:AddRightDownEft()
	local eft = cc.Sprite:create(self.sp_name)
	local posX = math.random(Def.visibleSize.width / 2,Def.visibleSize.width - self.Lobby_BGEffectHDis)
	local posY = math.random(self.Lobby_BGEffectVDis,Def.visibleSize.height / 2)
	eft:setAnchorPoint(cc.p(0,0))
	eft:setPosition(posX, posY)
	eft:setLocalZOrder(-1)

	self:addChild(eft)

	local offsetX = math.random(-200, 200)
	local offsetY = math.random(-50, 50)
	local time = math.random(2,3)
	local time1 = time / 5
	local time2 = time / 5 * 2
	local time3 = time / 5 * 2
	eft:runAction(cc.Sequence:create(cc.MoveTo:create(time1,cc.p(posX + offsetX / 7, posY + offsetY / 7)), 
									cc.DelayTime:create(0.02),
									cc.MoveTo:create(time2, cc.p(posX + offsetX / 7 * 3, posY + offsetY / 7 * 3)),
									cc.MoveTo:create(time3, cc.p(posX + offsetX , posY + offsetY)),
									cc.RemoveSelf:create()))
	eft:runAction(cc.Sequence:create(cc.ScaleTo:create(time1,1.0),cc.DelayTime:create(0.02),cc.ScaleTo:create(time2 + time3,0.0)))
        
    self:runAction(
        cc.Sequence:create(
            cc.DelayTime:create(time1 + 0.02 + time2 + time3),
		    cc.CallFunc:create(
                function()
                    self:AddRightDownEft()
                end))
        )
end

function EffectLayerStar:AddRightUpEft()
	local eft = cc.Sprite:create(self.sp_name)
	local posX = math.random(Def.visibleSize.width / 2,Def.visibleSize.width - self.Lobby_BGEffectHDis)
	local posY = math.random(Def.visibleSize.height / 2,Def.visibleSize.height - self.Lobby_BGEffectVDis)
	eft:setAnchorPoint(cc.p(0,0))
	eft:setPosition(posX, posY)
	eft:setLocalZOrder(-1)

    self:addChild(eft)

	local offsetX = math.random(-200, 200)
	local offsetY = math.random(-50, 50)
	local time = math.random(2,3)
	local time1 = time / 5
	local time2 = time / 5 * 2
	local time3 = time / 5 * 2
	eft:runAction(cc.Sequence:create(cc.MoveTo:create(time1,cc.p(posX + offsetX / 7, posY + offsetY / 7)), 
									cc.DelayTime:create(0.02),
									cc.MoveTo:create(time2, cc.p(posX + offsetX / 7 * 3, posY + offsetY / 7 * 3)),
									cc.MoveTo:create(time3, cc.p(posX + offsetX , posY + offsetY)),
									cc.RemoveSelf:create()))
	eft:runAction(cc.Sequence:create(cc.ScaleTo:create(time1,1.0),cc.DelayTime:create(0.02),cc.ScaleTo:create(time2 + time3,0.0)))

    self:runAction(
        cc.Sequence:create(
            cc.DelayTime:create(time1 + 0.02 + time2 + time3),
            cc.CallFunc:create(
                function()
                    self:AddRightUpEft()
                end))
    )
end

return EffectLayerStar
