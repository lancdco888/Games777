local GameItemPool = import(".GameItemPool")
local Update = import(".Update")
local SwitchLayer = import(".SwitchLayer")
local GameGroup = import(".GameGroup")

local GameList = class("GameList", function(node)
    return node
end)

local lastGroupId = nil

function GameList:ctor()
    if lastGroupId ~= nil then
        self.group_id = lastGroupId
        lastGroupId = nil
    else
        self.group_id = 0
    end

    self.all_game_ids = {}
	self.show_game_ids = {}

	self.items = {}
    self.tableView = nil
	self.itemSize = GameItemPool:size()
	self.itemScale = 1
	self.itemPosition = cc.p(0, 0)
    self:initTableView()

    self.btn_return = nil
    self:initReturnButton()

    self:ShowReturn(true)

	self.lastLotteyData = {}
	self:initCaiJin()
end

function GameList:onExit()
	self:recordPositon()

	GameItemPool:destroy()

	for _,item in pairs(self.items) do
		item:onDestroy()
	end

	Update:destroy()

	self:stopAllActions()
end

------------------------------------------------------------
-- Button Return

function GameList:initReturnButton()
    local btn_return = self:getChildByName("btn_return")
    btn_return:setLocalZOrder(100)

    Tools.AddClickEvent(btn_return, function()
        self:OnClickReturn()
    end)
    self.btn_return = btn_return
end

function GameList:OnClickReturn()
    self:enterGroup(0)
end

function GameList:ShowReturn(bShow)
    self.btn_return:setVisible(bShow == true)
end

function GameList:UpdateReturnPosition(size)
    local csz = self.btn_return:getContentSize()
    self.btn_return:setPositionX(csz.width / 2 + 4)
    self.btn_return:setPositionY(size.height - csz.height / 2 - 16)
end

------------------------------------------------------------
-- TableView

function GameList:initTableView()
    local list = self:getChildByName("list")

	local size = list:getContentSize()
	tableView = cc.TableView:create(size)

	cc.Node.registerScriptHandler(tableView, function(state)
		if state == "enter" then
			self:onEnter()
		end
		if state == "exit" then
			self:onExit()
		end
	end)

	list:getParent():addChild(tableView)
	tableView:setTouchEnabled(true)
    tableView:setIgnoreAnchorPointForPosition(true)
	tableView:setPosition(cc.p(list:getPosition()))

	tableView:setColor(cc.c3b(0, 0, 0))

    tableView:setDirection(cc.SCROLLVIEW_DIRECTION_HORIZONTAL)
    tableView:setVerticalFillOrder(cc.TABLEVIEW_FILL_BOTTOMUP)
	tableView:setClippingToBounds(true)
    tableView:setDelegate()

    tableView:registerScriptHandler(function(...)
        return self:tableCellTouched(...)
    end, cc.TABLECELL_TOUCHED)

    tableView:registerScriptHandler(function(...)
        return self:cellSizeForTable(...)
    end, cc.TABLECELL_SIZE_FOR_INDEX)

    tableView:registerScriptHandler(function(...)
        return self:tableCellAtIndex(...)
    end, cc.TABLECELL_SIZE_AT_INDEX)

    tableView:registerScriptHandler(function(...)
        return self:numberOfCellsInTableView(...)
    end, cc.NUMBER_OF_CELLS_IN_TABLEVIEW)

    tableView:registerScriptHandler(function(...)
        return self:scrollViewDidScroll(...)
    end,
    cc.SCROLLVIEW_SCRIPT_SCROLL)

    self.tableView = tableView
end

function GameList:tableCellTouched(view, cell)
end

function GameList:cellSizeForTable(view, idx)
	local size = self.itemSize
	return size.width, size.height
end

function GameList:tableCellAtIndex(view, idx)
	local cell = view:dequeueCell()

	local item
	local itemName = "__item__name__"
	if cell then
		local lastGameId = cell:getTag()
		local lastItem = self.items[lastGameId]
		if lastItem then
            xpcall(function()
                lastItem:onRemoved(lastGameId)
            end,
            __G__TRACKBACK__)
			self.items[lastGameId] = nil
		end
		item = GameItemPool:createItem(cell:getChildByName(itemName))
	else
		cell = cc.TableViewCell:new()
		item = GameItemPool:createItem()
		item:setName(itemName)
		cell:addChild(item)
	end

	item:setPosition(self.itemPosition)
	item:setScale(self.itemScale)
	item:setOpacity(0)
	item:runAction(cc.FadeIn:create(0.05))

	idx = idx + 1	-- 底层接口从 0 开始的
	local gameId = self.show_game_ids[idx]
	cell:setTag(gameId)

	self.items[gameId] = item

	xpcall(function()
			item:onAdded(gameId)
			self:updateJackpot(gameId)
		end,
		__G__TRACKBACK__)

    return cell
end

function GameList:numberOfCellsInTableView(view)
    return #self.show_game_ids
end

function GameList:scrollViewDidScroll(view)
end

------------------------------------------------------------

-- 定时器获取彩金
function GameList:initCaiJin()
    self:runAction(cc.RepeatForever:create(
        cc.Sequence:create(
            cc.DelayTime:create(const_game.Caijin_UpdateTime),
            cc.CallFunc:create(
                function() go(function() self:onJackpotTick() end) end
            )
        )
    ))

    --初始化时 执行一次
    go(function()
        SleepSecs(0.6)
        if tolua.isnull(self) then return end
        self:onJackpotTick()
    end)
end

function GameList:onJackpotTick()
    if tolua.isnull(self) then return end
    local canjinLogic = self.canjinLogic
    if canjinLogic == nil then
        canjinLogic = require("hall.src.gamelist.CaiJinLogic").new()
        self.canjinLogic = canjinLogic
    end

    local data_ = canjinLogic:GetData()
    if tolua.isnull(self) then return end

    if not data_ then return end

    if tolua.isnull(self) then return end
    self.lastLotteyData = data_
    self:updateAllJackpot()
end

function GameList:updateAllJackpot()
	for gameId, item in pairs(self.items) do
		self:updateJackpot(gameId)
	end
end

function GameList:updateJackpot(gameId)
	local item = self.items[gameId]
	local info = self.lastLotteyData[gameId]
	if item then
		item:setJackpot(info)
	end
end

------------------------------------------------------------

local offset = nil
function GameList:recordPositon()
	offset = self.tableView:getContentOffset()
    lastGroupId = self.group_id
end

function GameList:restorePos()
	if offset ~= nil then
		self.tableView:setContentOffset(offset)
		offset = nil
	end
end

------------------------------------------------------------
-- LobbyLayer

function GameList:onEnter()
end

function GameList:SetGameList(game_ids)
	-- 先根据游戏配置筛选一遍
	local games = {}
	for _,id in ipairs(game_ids) do
		local resGameId = GameData:GetGameID(id)
		if const_game.Param[resGameId] then
			table.insert(games, id)
		end
	end

    self.all_game_ids = games
    self.show_game_ids = {}

    GameGroup:setGameIds(games)

    local group_id = self.group_id
    self.show_game_ids = GameGroup:getGamesByGroupId(group_id)

    self:ShowReturn(group_id ~= 0)

    for game_id,item in pairs(self.items) do
        xpcall(function()
            item:onRemoved(game_id)
        end,
        __G__TRACKBACK__)
    end
    self.items = {}

	self.tableView:reloadData()
end

function GameList:enterGroup(group_id)
    if group_id == self.group_id then return end

    go(function()
        UIManager.DisableTouch(2.0)
        local layer = SwitchLayer.new()
        layer:switch(1)
        SleepSecs(0.5)
        if tolua.isnull(self) then return end

        self.group_id = group_id
        self:SetGameList(self.all_game_ids)
    end)
end

function GameList:RunExitAni()
	self:setVisible(false)
end

function GameList:RunEnterAni()
	self:setVisible(true)
end

function GameList:resize(width, height)
	local size = cc.size(width, height)
	self.tableView:setViewSize(cc.size(width, height))

	-- 计算 item 需要的参数
	local inner = 3
	local itemSize = GameItemPool:size()
	local scale = size.height / itemSize.height
	self.itemScale = scale
	self.itemSize = cc.size(itemSize.width * scale + inner, itemSize.height * scale)
	self.itemPosition = cc.p(self.itemSize.width / 2, self.itemSize.height / 2)

	self.tableView:reloadData()
	self:restorePos()

    self:UpdateReturnPosition(size)
end

return GameList
