local GameItem = import(".GameItem")

local GameItemPool = class("GameItemPool")

function GameItemPool:ctor()
	self.item = nil
end

function GameItemPool:lazyInitial()
	if self.item == nil then
		local csbNode = cc.CSLoader:createNode("csb/LobbyLayer/GameItem.csb")
		local item = csbNode:getChildByName("item")
		item:retain()
		self.item = item
	end
	return self.item
end

function GameItemPool:createItem(node)
	if not node then
		node = self:lazyInitial():clone()
	end
	
	return GameItem.new(node)
end

function GameItemPool:size()
	local node = self:lazyInitial()
	return node:getContentSize()
end

function GameItemPool:destroy()
	if tolua.isnull(self.item) then
		self.item:release()
		self.item = nil
	end
end

return GameItemPool
