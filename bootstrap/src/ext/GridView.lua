-- GridView继承ccui.ScrollView，拥有完全的ccui.ScrollView属性和方法
-- 主要用于 : 多行滑动容器 排列显示
-- 自动排版 子item(按照加入容器顺序)
-- @setItemModel : 设置默认模板
-- @pushBackDefaultItem : 按模板创建节点返回一个实例
-- @doLayout : 按已有items排列，会自动设置滑动区域
local GridView = class(
    'GridView',
    function()
        local view = ccui.ScrollView:create()
        view:enableNodeEvents()
        return view
    end
)

-- 会设置模板的锚点(0,0)和缩放1
function GridView:setItemModel(model)
    if self.model_ then
        print("warning: model is exsit")
        self.model_:release()
        self.model_ = nil
    end
    if model then
        model:retain()
        self.model_ = model
        self.model_w = model:getContentSize().width
        self.model_h = model:getContentSize().height
        local direction = self:getDirection()
        if direction == cc.SCROLLVIEW_DIRECTION_VERTICAL then -- 垂直滑动
            model:setAnchorPoint(0, 1)
        else -- 横向滑动
            model:setAnchorPoint(0, 1)
        end
        model:setScale(1)
    end
end

-- 创建一个item
function GridView:pushBackDefaultItem()
    local node = self.model_:clone()
    self:addChild(node)
    node:setPosition(cc.p(20000,20000))
    return node
end

-- 布局函数
function GridView:doLayout()
    -- cc.SCROLLVIEW_DIRECTION_HORIZONTAL = 0
    -- 
    local self_w = self:getContentSize().width
    local self_h = self:getContentSize().height
    local num = math.floor(self_w/self.model_w)
    local direction = self:getDirection()
    local size = cc.size(0,0)
    if direction == cc.SCROLLVIEW_DIRECTION_VERTICAL then -- 垂直滑动
        height_ = (math.floor((self:getChildrenCount()-1)/num)+1)*self.model_h
        size = cc.size(self_w,height_)
    else -- 横向滑动
        width_ = (math.floor((self:getChildrenCount()-1)/num)+1)*self.model_w
        size = cc.size(width_,self_h)
    end
    local children = self:getChildren() or {}
    for i,child in ipairs(children) do
        child:setPosition(self:getPosByIndex(i,self:getChildrenCount(),direction))
    end
    self:setInnerContainerSize(size)
end

function GridView:ctor()
    self.model_ = nil
    self.model_w = 0
    self.model_h = 0
end

function GridView:onExit()
    if self.model_ then
        self.model_:release()
        self.model_ = nil
    end
end

-- 先做竖向滑动 index = 1,2,3(不包含0) 默认坐标左对齐
-- index : item的自身下标;
-- total : GridView的item总个数
-- direction : GridView 的滑动方向
function GridView:getPosByIndex(index,total,direction)
    local self_w = self:getContentSize().width
    local self_h = self:getContentSize().height
    local num = 1

    if direction == cc.SCROLLVIEW_DIRECTION_VERTICAL then -- 垂直滑动
        num = math.floor(self_w/self.model_w)
    else -- 横向滑动
        num = math.floor(self_h/self.model_h)
    end
    local mod = math.floor((index - 1) / num)
    local remainder = math.fmod(index, num) == 0 and num or math.fmod(index, num)    
    local PosX = 0
    local PosY = 0
    if direction == cc.SCROLLVIEW_DIRECTION_VERTICAL then -- 垂直滑动
        PosX = (remainder-1) * self.model_w
        PosY = (math.floor((total - 1) / num) + 1) * self.model_h < self_h and self_h - mod * self.model_h or (math.floor((total - 1) / num) + 1) * self.model_h - mod * self.model_h
    else -- 横向滑动
        PosX = mod * self.model_w
        PosY = self_h - (remainder - 1) * self.model_h
    end
    return cc.p(PosX,PosY)
end

return GridView