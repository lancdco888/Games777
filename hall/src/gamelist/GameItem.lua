local CaiJinItem = import(".CaiJinItem")
local UpdateItem = import(".UpdateItem")
local AnimItem = import(".AnimItem")
local GameGroup = import(".GameGroup")

local GameItem = class("GameItem", function(item)
	return item
end)

function GameItem:ctor()
	self.gameId = -1
	self.icon = self:getChildByName("icon")

    self.icon:setTouchEnabled(true)
    Tools.AddClickEvent(self.icon, function()
        local icon = self.icon
        local start_pos = icon:convertToNodeSpace(icon:getTouchBeganPosition())
        local end_pos = icon:convertToNodeSpace(icon:getTouchEndPosition())
        local distance = cc.pGetDistance(end_pos, start_pos)
        -- 有明显的滑动就不再响应点击事件
        if distance < 30 then
            gSound.clickSound()
            self:onClick()
        end
    end, false)
    self.icon:setSwallowTouches(false)
end

function GameItem:setGameId(gameId)
	self.gameId = gameId

	-- icon
	local iconId
    if GameGroup:isGroupId(gameId) then
        local group_id = gameId
        iconId = GameGroup:getIcon(group_id)
    else
        local resourceId = GameData:GetGameID(gameId)
        local cfg = const_game.Param[resourceId]
        if cfg then
            iconId = cfg[const_game.Icon]
        else
            print("Error: no cfg found for " .. gameId)
            iconId = 101
        end
    end

	path = string.format("lobby/icon/%d.png", iconId)
	if cc.FileUtils:getInstance():fullPathForFilename(path) == "" then
        path = string.format("language/lobby/icon/%d.png", iconId)
    end
    self.icon:loadTextures(path, path)
    self.icon:setScale(1.0)

	-- jackpot
	local caijinNode = self.icon:getChildByName("caijin")
	self.caijin = CaiJinItem.new(caijinNode)
	self.caijin:SetGameID(gameId)
	self.caijin:onEnter()
    self.caijin:setVisible(true)

	-- 更新处理
	local update = self.icon:getChildByName("update")
	self.update = UpdateItem.new(update)
	self.update:setTimerSp(path)
	self.update:setGameId(gameId)
	self.update:setOnSuccess(function()
		if UpdateItem.lastClickUpdateId == gameId and not tolua.isnull(self) then
			self:onClick()
		end
	end)

	-- 动画
    do
		if self.ani then
			self.ani:clear()
			self.ani = nil
		end

		local ani = AnimItem.new(self.icon)
		self.ani = ani
		ani:setGameId(gameId)
    end


	local showTest = BuildConfig and BuildConfig.Debug == "TRUE"
	if showTest then
		self:showTestInfo()
	end
end

function GameItem:showTestInfo()
	local icon = self.icon
	local name = "__game__id__"
	local gameIdLabel = icon:getChildByName(name)
	if not gameIdLabel then
		gameIdLabel = cc.Label:createWithSystemFont("", "Arial", 26)
		gameIdLabel:setName(name)
		local size = self.icon:getContentSize()
		gameIdLabel:setPosition(cc.p(size.width/2, size.height/2 - 240))
		icon:addChild(gameIdLabel)
	end

    local str = tostring(self.gameId)
    if Tools.IsFGUIRuntimeSupport() and GameData:IsFGUIReleaseGame(self.gameId) then
        str = str .. "F"
    end
	gameIdLabel:setString(str)
end

function GameItem:onClick()
	local gameId = self.gameId

    if GameGroup:isGroupId(gameId) then
        local layer = BottomLayer:Get(LobbyLayer)
        if layer then
            local group_id = gameId
            layer.game_list:enterGroup(group_id)
        end
    else
        local update = self.update
        if not update:checkEnter() then
            return
        end

        GameData.game_id = gameId
        local lobby = require("hall.src.hallnew.Panel_Lobby")
        lobby.SendEnterRoomLevel(gameId)
    end
end

--------------------------------------------------------
-- GameList

-- 滑动进入视野
function GameItem:onAdded(gameId)
	self:setGameId(gameId)
end

-- 划动出视野，此时底层 node 可能会被另外 GameItem 复用，此时需要对上层逻辑进行清理
function GameItem:onRemoved(gameId)
	self.update:unregisterEvent()

    do
		if self.ani then
			self.ani:clear()
			self.ani = nil
		end
    end

	if gameId ~= self.gameId then
		print(string.format("Error: gameId = %d, but self.gameId = %d.", gameId, self.gameId ))
		return
	end
end

function GameItem:setJackpot(info)
	if self.caijin then
		if info then
			self.caijin:SetDataList(info)
		end
	end
end

function GameItem:onDestroy()
end

return GameItem
