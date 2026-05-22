local EnterFishLayer = class("EnterFishLayer", function()
	local layer = cc.CSLoader:createNode("packagelua/res/studio/csb/Download.csb")
		layer:enableNodeEvents()
		return layer
	end)

function EnterFishLayer:onEnter()
	sGameManager.gameState = const_game.Lobby_To_Game_State
	self:InitUI()
	self:AdjustUI()

	go(function()
		self:CheckModuleUpdate("fish_common")

		local gameID = GameData.game_id
		if const_game.Param[GameData:GetGameID(gameID)][const_game.Game_type] == "changsheng" then
			self:CheckModuleUpdate("fish_common_cs")
		end
		self:EnterToFish()
	end)

    self:onUpdate(function() self:OnTick() end)
end

function EnterFishLayer:InitUI()
	--进入游戏时关闭大厅背景音乐
	gSound.stopAll()

	local panel = self:getChildByName("panel")
    self.percent = panel:getChildByName("percent")
    self.loadingBar = panel:getChildByName("loading_bar")
	self.barBg	= panel:getChildByName("bar_fg")
	self.loadingBar:setVisible(false)
	self.barBg:setVisible(false)
	self.percent:setVisible(false)
	self.releaseFunc = nil

	self.loadingBar:setPercent(0)

	--
	MarqueeLogic:SetNoticeType("width")
	MarqueeLogic:HideNotice("height")
	MarqueeLogic:HideNotice_Node()
	local size = Def.visibleSize
	local height = Def.DesignedY * Def.ScaleMin
	height = (size.height - height) / 2
	MarqueeLogic:SetNoticePos(cc.p(size.width*0.5,height + Def.DesignedY * Def.ScaleMin*0.85))
end

----------------------------------------------------------------------

function EnterFishLayer:CheckModuleUpdate(module_)
	self:StartUpdate()

	if not sDownloadMgr.CheckModule(module_) then
		return
	end

    local last_p = 0
	local updateFunc = function(module_)
        local percent = sDownloadMgr.updateTask[module_].percent
        if percent < last_p then
            percent = last_p 
        end
        last_p = percent
		self:FreshUpdate(percent)
	end
	sDownloadMgr.UpdatingCallBack[module_] = updateFunc

	local done = false
	local endFunc = function(module_)
		done = true
	end
	sDownloadMgr.EndCallBack[module_] = endFunc

	-- 正在更新
	if sDownloadMgr.updateTask[module_] == nil then
		sDownloadMgr.StartDownloadTask(module_)
	end

	self.loadingBar:setPercent(0)

	while not done do
        coroutine.yield()
        SleepSecs(0.1)
	end
    SleepSecs(0.2)
end

----------------------------------------------------------------------

function EnterFishLayer:StartUpdate()
	self.loadingBar:setVisible(true)
	self.percent:setVisible(true)
	self.barBg:setVisible(true)
end

function EnterFishLayer:FreshUpdate(percent)
	self.loadingBar:runAction(cc.ProgressTo:create(0.2, percent))
end

function EnterFishLayer:OnTick()
    if self.loadingBar and self.loadingBar:isVisible() then
		local percent = self.loadingBar:getPercent()
        self.percent:setString(tostring(math.floor(percent)) .. "%")
	else
        self.percent:setString("")
	end
end

function EnterFishLayer:SetReleaseFunc(func)
	self.releaseFunc = func
end

function EnterFishLayer:EnterToFish()
	go(function()
		if self.releaseFunc ~= nil then
			self.releaseFunc()
		end
		local status, ret = xpcall(require, __G__TRACKBACK__, "hall.src.hallnew.layers.LobbyLayer.enterfishlayer.EnterGame")
		if not status then
			local error = ret
			print(error)
			print("game module cannot found:" .. name)
			UIManager.ShowMsgBox("游戏载入失败,游戏名字为:" .. name)
			return
		end
		local game = ret
		if type(game) ~= "table" or not game.start or not game.exit then
			print("invalid gamename:" .. name)
			UIManager.ShowMsgBox("非法的游戏,游戏名字为:" .. name)
			return
		end
		go(function()
			SleepSecs(0.5)
			--隐藏大厅和所有弹窗
			local panel = require "hall.src.hallnew.Panel_Lobby"
			gStates_CloseAsync(panel)
			BottomLayer:Clear()
			-- 删除 捕鱼返回大厅创建的背景图
			local FishSenceBG = gScene:getChildByTag(8888)
			if FishSenceBG then
				FishSenceBG:removeFromParent()
			end
		end)
		
		--开始进入游戏
		-- go(function()
		-- 	local bool_ = true
		-- 	while bool_ do
		-- 		if game.start() ~= -1 then
		-- 			bool_ = false
		-- 		else
		-- 			-- 直接断网，断线重连重新进入
		-- 			gNet:Disconnect()
		-- 			break
		-- 		end
		-- 	end
		-- end)

		go(function()
::__start__::
			local nowMS = NowSteadyEpochMS()
			while NowSteadyEpochMS() - nowMS < 5000 do
				yield()
				if not gNet:Alive() then
					print("peer disconnected.")
					return
				end

				if gNet:IsOpened(GameData.serverID) then
					print("game peer open")
					break
				end
			end
			if NowSteadyEpochMS() - nowMS >= 5000 then
				print("game NowSteadyEpochMS() time out")
				gNet:Disconnect()
				goto __start__
			end
			game.start()
		end)
	end)
end

--适配界面
function EnterFishLayer:AdjustUI()
	--背景 铺满
	local size = Def.visibleSize
	local bg = self:getChildByName("bg")
	bg:setScale(Def.ScaleMax)
	local center = cc.p(size.width/2.0, size.height/2.0)
	bg:setPosition(center)
	--面板尽量放大居中
	local panel = self:getChildByName("panel")
	panel:setScale(Def.ScaleMin)
	panel:setPosition(center)

	bg:setSwallowTouches(true)
	bg:setTouchEnabled(true)
	bg:addTouchEventListener(function()
		return true
	end)
end

return EnterFishLayer