local Node = cc.Node

function Node:findChild(name)
    local children = self:getChildren()
    for idx, child in ipairs(children) do
        if child:getName() == name then
            return child
        end
        local node = child:findChild(name)
        if node then
            return node
        end
    end
    return nil
end

--扩展版本的 getChildByName, 支持 root/child1/child2 的方式索引子节点
function Node:getChild(name)
    local item = self
    for n in name:gmatch("[%w_]+") do
        item = item:getChildByName(n)
        if not item then
            return nil
        end
    end
    return item
end

local AddChild = Node.addChild
function Node:addChild(node,zorder,tag)
    if node == nil then
        print("Node:addChild == nil")
        print(debug.traceback())
        return
    end
	if tag then
		return AddChild(self, node, zorder, tag)
	end
	
	if zorder then
		return AddChild(self, node, zorder)
	end
	
    return AddChild(self, node)
end

-- return = {
--     int type;
--     std::string file;
--     std::string plist;
-- }
function Node:getTexturesPath()
    local _type = tolua.type(self)
    if _type == "ccui.Button" then
        local normalFile = self:getNormalFile()
        local pressedFile = self:getPressedFile()
        local disabledFile = self:getDisabledFile()
        return {normalFile,pressedFile,disabledFile,type = _type}
    elseif _type == "ccui.ImageView" then
        local renderFile = self:getRenderFile()
        return {renderFile,type = _type}
    -- elseif _type == "cc.Sprite" then
    --     self:getResourceType()
    --     self:getResourceName()
    else
        print("ERROR: getTexturesPath type useless")
        print(debug.traceback())
        return nil
    end
end

-- 拿到所有type类型的节点
-- type:节点类型
-- retNodes :返回的节点数组
function Node:getChildrenByType(type,retNodes)
    if not retNodes then
        print("ERROR: getChildrenByType retNodes nil")
        print(debug.traceback())
        return
    end
    local _type = tolua.type(self)
    if _type == type then
        self._name = self:getName()
        table.insert(retNodes,self)
    end
    local children = self:getChildren()
    for _, child in ipairs(children) do
        child:getChildrenByType(type,retNodes)
    end
end