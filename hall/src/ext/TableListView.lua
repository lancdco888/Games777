local TableListView =  class("TableListView")
-- 消息cell之间的间距
local MSG_CELL_SPACING = 0

--传入的的对向必须为listView
function TableListView:ctor(render,mode)
    render:setInnerContainerSize(render:getContentSize())

    --不是ScrollView控件需要替换为ScrollView控件
    if tolua.type(render) ~= "ccui.ScrollView" then
        local scrollView = ccui.ScrollView:create()
        render = Tools.ReplaceNode(render,scrollView)
    end

    self.render = cc.TableViewPro.attachTo(render)
    self.render:setFillOrder(cc.TableViewFillOrderPro.topToBottom)
    self.render:registerFunc(cc.TableViewFuncTypePro.cellSize, handler(self, self.cellSize))
    self.render:registerFunc(cc.TableViewFuncTypePro.cellNum, handler(self, self.cellNum))
    self.render:registerFunc(cc.TableViewFuncTypePro.cellLoad, handler(self, self.cellLoad))

    self.mode_node = nil
    self.mode_size = nil
    self.onLoadCell = nil
    self.max_count = 0
    if mode then
        self:setCellMode(mode)
    end
end
--第一步设置子模型
function TableListView:setCellMode(node)
    if self.mode_node then
        self.mode_node:release()
    end

    self.mode_node = node
    self.mode_node:retain()
    self.mode_node:removeFromParent()
    if self.mode_node then
        self.mode_size = self.mode_node:getContentSize()
    end
    --退出时候释放
    self.render:onNodeEvent("exit",function ()
        self.mode_node:release()
    end)
end

--
function TableListView:setDirection(dir)
    self.render:setDirection(dir)
end

--填充 数据最大填充数量
function TableListView:setData(data)
    if not data then
        self.max_count = 0
        print("数据为空")
        return
    end
    self.max_count = #data
    self.render:reloadData()
end

--第二步设置每个模型的渲染函数
function TableListView:setLoadCellFun(fun)
    self.onLoadCell = fun
end
--自己维护 动态添加创建
function TableListView:cellLoad(tableview,index)
    local cell = tableview:dequeueCell()
    if not cell then
        cell = cc.TableViewCellPro.new()
        local item = self.mode_node:clone()
        item:setAnchorPoint(0,0)
        item:setPosition(0,0)
        cell:addChild(item)
    end
    self.onLoadCell(cell,index)
    return cell
end
--自己维护 格子间距
function TableListView:cellSize(key,fun)
    return self.mode_size.width + MSG_CELL_SPACING,self.mode_size.height + MSG_CELL_SPACING
end
--自己维护 格子最大最大渲染个数
function TableListView:cellNum(tableview)
    return self.max_count
end

cc.TableListViewPro = TableListView
