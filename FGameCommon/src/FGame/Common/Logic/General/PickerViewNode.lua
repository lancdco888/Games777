
local PickerViewNode = Class("PickerViewNode")

function PickerViewNode:ctor(index, view)
	self.x, self.y, self.width, self.height = 0, 0, 0, 0
	self.index = index
	self.visible = true
    self.view = view
end

-- @brief 逻辑节点销毁
function PickerViewNode:__delete()
    self.view = nil
	if self.render then
		self.render:RemoveFromParent(true)
		self.render = nil
	end
end

-- @brief 逻辑节点位置设置
function PickerViewNode:SetPositionY(y)
	self.y = y
	if self.render then self.render.y = y end
end

-- @brief 逻辑节点显示
function PickerViewNode:OnShow()
	if self.render == nil then
		self:LoadRender()
	end
    self.render.visible = true
end

-- @brief 逻辑节点隐藏
function PickerViewNode:OnHide()
	if self.render then
		self.render.visible = false
	end
end

function PickerViewNode:LoadRender()
	if not self.render then
		local render = self.view:OnLoadCell(self.index)
        render.width = self.width
        render.height = self.height
        render.x = self.x
        render.y = self.y
		self.render = render
	end
end

return PickerViewNode