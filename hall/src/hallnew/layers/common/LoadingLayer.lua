--[[
	通用加载页面，不用在里面写逻辑，可以通过组合其他类 或者 继承等方式实现特有逻辑
--]]

local LoadingLayer = class("LoadingLayer", function()
	local layer = cc.CSLoader:createNode("packagelua/res/studio/csb/Download.csb")
	layer:enableNodeEvents()

	-- 这里做一次简单的适配
	LoadingLayer.AdjustUI(layer)

	return layer
end)

function LoadingLayer:onEnter()
	self:InitUI()
end

function LoadingLayer:onExit()
	if self.on_exit_event then
		self.on_exit_event()
	end
end

function LoadingLayer:regExitEvent(event)
	self.on_exit_event = event
end

function LoadingLayer:InitUI()
	local panel = self:getChildByName("panel")
    self.percent = panel:getChildByName("percent")
    self.loadingBar = panel:getChildByName("loading_bar")
	self.barBg	= panel:getChildByName("bar_fg")
	self:showLoading(false)
end

--适配界面
function LoadingLayer:AdjustUI()
	--背景 铺满
	local bg = self:getChildByName("bg")
	Tools.AdjustBg(bg)

	local size = cc.Director:getInstance():getVisibleSize()
	local center = cc.p(size.width/2.0, size.height/2.0)
	bg:setPosition(center)

	--面板尽量放大居中
	local panel = self:getChildByName("panel")
	Tools.AdjustCenter(panel)
	panel:setPosition(center)

	bg:setSwallowTouches(true)
	bg:setTouchEnabled(true)
	bg:addTouchEventListener(function()
		return true
	end)
end

-- rate : [0, 1] 范围的浮点数
function LoadingLayer:setRate(rate)
	if rate < 0 then
		rate = 0.0
	end
	if rate > 1 then
		rate = 1.0
	end
	self.loadingBar:setPercent(math.floor(rate * 100))
	self.percent:setString(tostring(math.floor(rate * 100)) .. "%")
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

---------------------------------------------------------------------------
-- 测试用
function LoadingLayer:Test()
	local layer = LoadingLayer:new()
	cc.Director:getInstance():getRunningScene():addChild(layer)
	layer:showLoading(true)
	
	local rate = -0.8
	local seq = cc.Sequence:create(
		cc.DelayTime:create(0.1),
		cc.CallFunc:create(function()
			-- 测试进度改变
			if rate >= 1.5 then
				layer:stopAllActions()
				layer:removeFromParent()
				return
			end
			layer:setRate(rate)
			rate = rate + 0.1
		end)
	)
	layer:runAction(
		cc.RepeatForever:create(seq)
	)
end

return LoadingLayer
