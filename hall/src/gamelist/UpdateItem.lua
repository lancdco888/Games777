local Update = import(".Update")

local UpdateItem = class("UpdateItem", function(node)
    node:enableNodeEvents()
    return node
end)

function UpdateItem:ctor()
	self.gameId = -1
end

function UpdateItem:onEnter()
    self.is_updating = false
    self.need_update = false

    self:InitUI()

    self:onUpdate(function() self:OnTick() end)

    self:setLocalZOrder(9999)
end

function UpdateItem:InitUI()
    self.percent = self:findChild("percent"):hide()
    self.percent:setLocalZOrder(1000)
end

function UpdateItem:SetNeedUpdate(bNeed)
    self.need_update = bNeed

    if not bNeed then
        self.percent:setString("")
        if self.loading then
            self.loading:setVisible(false)
        end
    end
end

function UpdateItem:setTimerSp(path_)
    local sp = cc.Sprite:create(path_)
    if not sp then return end
    sp:setColor(cc.c4b(0, 0, 0))
    sp:setOpacity(255 * 0.8)

    local timer = cc.ProgressTimer:create(sp)
    timer:setType(kCCProgressTimerTypeBar)
    timer:setMidpoint(cc.p(0, 0))
    timer:setBarChangeRate(cc.p(0, 1))

    self:getParent():addChild(timer)
    local size = self:getContentSize()
    timer:setPosition(cc.p(size.width/2, size.height/2))

    if self.loading then
        timer:setVisible(self.loading:isVisible())
        timer:setPercentage(self.loading:getPercentage())
        self.loading:removeFromParent()
    end
    self.loading = timer
    self.loading:setPercentage(0)
    self.loading:setLocalZOrder(1000)
end

function UpdateItem:StartUpdate()
    self.need_update = false
    self.is_updating = true

    self.percent:setVisible(true)

    self.percent:setString("0%")
    if self.loading then
        self.loading:setVisible(true)
        self.loading:setPercentage(100)
    end
end

function UpdateItem:FreshUpdating(percent)
    percent = 100 - percent
    if percent > 100 then percent = 100 end
    if percent < 0 then percent = 0 end

    if self.loading then
        if percent <= 10 then
            self.loading:runAction(cc.ProgressTo:create(0.3, percent))
        else
            self.loading:setPercentage(percent)
        end
    end
end

function UpdateItem:OnTick()
    if self.loading then
        local percent = 100 - math.floor(self.loading:getPercentage())
        self.percent:setString(tostring(percent) .. "%")
    else
        self.percent:setString("")
    end
end

function UpdateItem:EndUpdating()
    self.is_updating = false

    if self.loading then
        self.loading:setVisible(false)
    end
    self.percent:setVisible(false)
end

-------------------------------------------------
-- 是否需要更新
function UpdateItem:IsNeedUpdate()
    return self.need_update
end

-- 是否正在更新
function UpdateItem:IsUpdating()
    return self.is_updating
end

-------------------------------------------------
-- 检查更新状态
function UpdateItem:setGameId(gameId)
	self.gameId = gameId
end

UpdateItem.lastClickUpdateId = 0

-- 返回 true，已经是最新，玩家可以进入游戏
-- 其他情况无法进入游戏
function UpdateItem:checkEnter()
	local gameId = self.gameId
	UpdateItem.lastClickUpdateId = gameId

	local status = Update:checkGameStatus(gameId)
	if status == Update.State.Error then
		UIManager.ShowToast("No Hotfix Cfg found for this game:" .. tostring(gameId))
		return false
	elseif status == Update.State.Updated then
		return true
	elseif status == Update.State.NeedUpdate then
		-- 检查同时更新的数量
		local count = Update:getUpdatingCount()
		if count >= 1 then
			UIManager.ShowMsgBox(TR("请耐心等待更新完成"))
			return false
		end

		if Update:update(gameId) then
			self:FreshUpdating(0)
			self:StartUpdate()
			self:registerEvent()
			return false
		else
			UIManager.ShowToast("Start Update failed:" .. tostring(gameId))
			return false
		end
	elseif status == Update.State.Updating then
		UIManager.ShowMsgBox(TR("请耐心等待更新完成"))
		return false
	else
		UIManager.ShowToast("UpdateItem:checkEnter(), Error state for game:" .. tostring(gameId))
		return false
	end

	return false
end

function UpdateItem:registerEvent()
	local gameId = self.gameId
	self.lastPercent = 0

	Update:register(gameId,
		function()	-- onSuccess
			if tolua.isnull(self) then return end
			self:EndUpdating()
			self:SetNeedUpdate(false)

			if self.onSuccess then
				self.onSuccess()
			end

			self:unregisterEvent()
		end,
		function()	-- onFailed
			if tolua.isnull(self) then return end
			self:EndUpdating()
			self:SetNeedUpdate(true)

			self:unregisterEvent()
		end,
		function(percent)	-- onPercent
			if tolua.isnull(self) then return end
			if percent < self.lastPercent then percent = self.lastPercent end
			if percent >= 100 or percent - self.lastPercent > 5 then
				self:FreshUpdating(percent)
			end
		end
	)
end

function UpdateItem:setOnSuccess(onSuccess)
	self.onSuccess = onSuccess
end

function UpdateItem:unregisterEvent()
	self.onSuccess = nil

	local gameId = self.gameId
	Update:unregister(gameId)
end

return UpdateItem
