--[[
	通用加载页面，不用在里面写逻辑，可以通过组合其他类 或者 继承等方式实现特有逻辑
--]]

local LoadingLayer = class("LoadingLayer", function()
	local layer = cc.CSLoader:createNode("bootstrap/res/csb/Download.csb")
	layer:enableNodeEvents()
	TR_Node(layer)
	return layer
end)

function LoadingLayer:onEnter()
	self:InitUI()
	self:AdjustUI()

	self:onUpdate(function() self:OnTick() end)
end

function LoadingLayer:InitUI()
	local panel = self:getChildByName("panel")
    self.percent = panel:getChildByName("percent")
    self.loadingBar = panel:getChildByName("loading_bar")
	self.barBg	= panel:getChildByName("bar_fg")
	self.tips	= panel:getChildByName("tips")
	self:showLoading(false)

	self.loadingBar:setPercent(0)
end

--适配界面
function LoadingLayer:AdjustUI()
	local visibleSize	=	cc.Director:getInstance():getVisibleSize()
	local DesignedX		=	1280.0
	local DesignedY		=	720.0
	local ScaleX		=	visibleSize.width / DesignedX
	local ScaleY		=	visibleSize.height / DesignedY
	local ScaleMax		=   math.max(ScaleX, ScaleY)
	local ScaleMin		=   math.min(ScaleX, ScaleY)

	--背景 铺满
	local size = visibleSize
	local bg = self:getChildByName("bg")
	bg:setScale(ScaleMax)
	local center = cc.p(size.width/2.0, size.height/2.0)
	bg:setPosition(center)

	--面板尽量放大居中
	local panel = self:getChildByName("panel")
	panel:setScale(ScaleMin)
	panel:setPosition(center)
end

-- rate : [0, 1] 范围的浮点数，做平滑处理
function LoadingLayer:setRate(rate)
	if rate < 0 then
		rate = 0.0
	end
	if rate > 1 then
		rate = 1.0
	end

	local percent = math.floor(rate * 100)
	self.loadingBar:runAction(cc.ProgressTo:create(0.3, percent))
end

function LoadingLayer:OnTick()
	if self.percent then
		local percent = math.floor(self.loadingBar:getPercent())
		self.percent:setString(tostring(percent) .. "%")
	end
end

-- 显示&隐藏 加载条
function LoadingLayer:showLoading(bShow)
	if bShow == nil then
		bShow = true
	end
	self.loadingBar:setVisible(bShow)
	self.percent:setVisible(bShow)
	self.barBg:setVisible(bShow)
end

function LoadingLayer:setErrorString(msg)
	self.percent:setString(msg)
end

function LoadingLayer:setTips(msg)
	if self.tips then
		self.tips:setString(msg)
	end
end

---------------------------------------------------------------------------
-- 测试用
function LoadingLayer:Test()
	local layer = LoadingLayer:new()
	cc.Director:getInstance():getRunningScene():addChild(layer)
	layer:showLoading(true)
	
	local rate = -0.8
	local seq = cc.Sequence:create(
		cc.DelayTime:create(0.5),
		cc.CallFunc:create(function()
			-- 测试进度改变
			if rate >= 1.5 then
				layer:stopAllActions()
				layer:removeFromParent()
				return
			end
			layer:setRate(rate)
			rate = rate + 0.25
		end)
	)
	layer:runAction(
		cc.RepeatForever:create(seq)
	)
end

return LoadingLayer
