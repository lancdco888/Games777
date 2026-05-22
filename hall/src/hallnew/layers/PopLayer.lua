local PopLayer = class("PopLayer")

local g_pop_root = nil

function PopLayer:ctor()
    self:ResetRoot()
end

function PopLayer:ResetRoot()
    gScene = cc.Director:getInstance():getRunningScene()
    local pop_root = gScene:findChild("pop_root")
    if not pop_root then
        pop_root = cc.Node:create()
        pop_root:setName("pop_root")
        gScene:addChild(pop_root)
    end
    pop_root:setLocalZOrder(1000)
    pop_root:setPosition(cc.p(Def.visibleSize.width/2.0, Def.visibleSize.height/2.0))
    self.pop_root = pop_root
    g_pop_root = pop_root
end

function PopLayer:GetPopRootNode()
    return g_pop_root
end

function PopLayer:Get(Layer)
    if Layer == nil then
        release_print("Warning: PopLayer:Get Layer with nil")
        return
    end

    local children = self.pop_root:getChildren()
    for _,child in ipairs(children) do
        if child.__class == Layer then
            return child.__real_node, child
        end
    end
    return nil
end

--关闭所有此种类型的弹窗
function PopLayer:Close(Layer)
    local children = self.pop_root:getChildren()
    for _,child in ipairs(children) do
        if child.__class == Layer then
            self:CloseLayer(child)
        end
    end
end

function PopLayer:SetCached(Layer, cached)
    local children = self.pop_root:getChildren()
    for _,child in ipairs(children) do
        if child.__class == Layer then
            child.__cached = cached
        end
    end
end

function PopLayer:CloseAll()
    local children = self.pop_root:getChildren()
    for _,child in ipairs(children) do
        if child.__is_poped then
            self:CloseLayer(child)
        end
    end
end

function PopLayer:CloseLayer(layer)
    go(function()
        if  layer.__real_node ~= nil then
            layer.__real_node:Close()
        end
    end
    )
end

-----------------------------------------------------
-- level = 0, 1, 2, 3
local levels = {
    {level = 0, type = "BACKGROUND", zorder = 0 },
    {level = 1, type = "LAYER", zorder = 100 },
    {level = 2, type = "POPUP", zorder = 1000 },
    {level = 3, type = "TOPMOST", zorder = 10000 },
}

function PopLayer:GetZOrder(level)
    for _,v in ipairs(levels) do
        if v.level == level then
            return v.zorder
        end
    end
    return 0
end

--增加 半透明背景 并弹出
function PopLayer:DoPopNode(LayerClass, level, show_bg)
    local layer, node
    local node, layer = self:Get(LayerClass)
    if node and layer and layer.__cached then
        layer:setVisible(true)
        node:setVisible(true)
    else
        layer = cc.Node:create()
        self.pop_root:addChild(layer)
        node = LayerClass.new()
        layer:addChild(node)
    end

    --增加防点击 半透明背景层
    if show_bg then
        self:CreateShadow(node)
    end

    layer.__is_poped = true
    layer.__class = LayerClass
    layer.__real_node = node

    level = level or 1
    local zorder = self:GetZOrder(level)
    layer:setLocalZOrder(zorder)
    --节点自己的 Close 函数
    if node.Close then
        print("已经有了Close函数!")
    else
        node.Close = function()
            --移除数据改变的通知
            local delay = 0.15

            if layer.__cached then
                layer:runAction(
                    cc.Sequence:create(
                        cc.ScaleTo:create(
                            delay,
                            0),
                        cc.Hide:create()
                    )
                )

                self:DestroyShadow(node)
                return
            end

            Dispatcher:Remove(node)
            layer:runAction(
                cc.Sequence:create(
                    cc.ScaleTo:create(
                        delay,
                        0),
                    cc.RemoveSelf:create()
                )
            )

            if node:getParent() ~= layer then
                node:runAction(
                    cc.Sequence:create(
                        cc.ScaleTo:create(
                            delay,
                            0),
                        cc.RemoveSelf:create()
                    )
                )
            end

            local bg = layer:getChildByName("bg")
            if bg then
                bg:runAction(cc.FadeOut:create(delay))
            end
            if coroutine.running() then
                SleepSecs(delay)
            end
        end
    end
    --弹出处理
    layer:setScale(0)
    layer:updateOrderOfArrival()    --显示在同级节点的最前面
    local scale = Def.ScaleMin
    --弹出框显示时的动画时间
    local open_time = 0.15
    local shrink_time = 0.05
    layer:runAction(cc.Sequence:create(cc.ScaleTo:create(open_time, scale*1.1),
        cc.ScaleTo:create(shrink_time, scale)))
    return node
end

function PopLayer:CreateShadow(root)
    local bg = root:getChild("__mask_bg")
    if not bg then
        bg = cc.LayerColor:create(cc.c4b(0,0,0,0),Def.visibleSize.width, Def.visibleSize.height)
        bg:setAnchorPoint(cc.p(0.5,0.5))
        bg:setLocalZOrder(-1)
        bg:setScale(200)

        local listener = cc.EventListenerTouchOneByOne:create()
		listener:setSwallowTouches(true)
		listener:registerScriptHandler(function(touch,event)
			return true
		end, cc.Handler.EVENT_TOUCH_BEGAN)
        cc.Director:getInstance():getEventDispatcher():addEventListenerWithSceneGraphPriority(listener, bg)

        bg:setPosition(0,0)
        bg:setName("__mask_bg")
        bg:runAction(cc.FadeTo:create(0.3, 0.6*255))
        root:addChild(bg)
    end
end

function PopLayer:DestroyShadow(root)
    local bg = root:getChild("__mask_bg")
    if bg then
        print("DestroyShadow(): bg found __mask_bg")
        local dispatcher = cc.Director:getInstance():getEventDispatcher()
        dispatcher:removeEventListenersForTarget(bg)
        bg:removeFromParent()
    end
end

function PopLayer:Pop(LayerClass, level)
    level = level or 1
    return self:DoPopNode(LayerClass, level, true)
end

function PopLayer:PopTopNode(LayerClass)
    return self:DoPopNode(LayerClass, 3, true)
end

function PopLayer:PopToastNode(LayerClass)
    return self:DoPopNode(LayerClass, 3, false)
end

------
function PopLayer:Pop_BAP(LayerClass, level)
	--该函数只适用 LayerClass 子节点有tag是 99999 和 999999 的
    level = level or 1
    return self:DoPopNode_BAP(LayerClass, level, true)
end

function PopLayer:DoPopNode_BAP(LayerClass, level, show_bg)
	--该函数只适用 LayerClass 子节点有tag是 99999 和 999999 的
    local layer = cc.Node:create()
    self.pop_root:addChild(layer)
    if show_bg then
        self:CreateShadow(layer)
    end
    local node = LayerClass.new()
    layer:addChild(node)
    layer.__is_poped = true
    layer.__class = LayerClass
    layer.__real_node = node
    level = level or 1
    local zorder = self:GetZOrder(level)
    layer:setLocalZOrder(zorder)
    --节点自己的 Close 函数
    if node.Close then
        print("已经有了Close函数!")
    else
        node.Close = function()
            --移除数据改变的通知
            local delay = 0.15
            Dispatcher:Remove(node)

            layer:runAction(
                cc.Sequence:create(
                    cc.ScaleTo:create(
                        delay,
                        0),
                    cc.RemoveSelf:create()
                )
            )

            if node:getParent() ~= layer then
                node:runAction(
                    cc.Sequence:create(
                        cc.ScaleTo:create(
                            delay,
                            0),
                        cc.RemoveSelf:create()
                    )
                )
            end

            local bg = layer:getChildByName("bg")
            if bg then
                bg:runAction(cc.FadeOut:create(delay))
            end

            if coroutine.running() then
                SleepSecs(delay)
            end
        end
    end
    --弹出处理
    --layer:setScale(0)
    layer:updateOrderOfArrival()    --显示在同级节点的最前面
    --弹出框显示时的动画时间
    local open_time = 0.15
    local shrink_time = 0.05
	local bg_im = node:getChildByTag(99999)
	local panel = node:getChildByTag(999999)
	bg_im:setScale(0)
	panel:setScale(0)
	local action_max = cc.EaseBackOut:create(cc.ScaleTo:create(0.5,Def.ScaleMax))
	local action_min = cc.EaseBackOut:create(cc.ScaleTo:create(0.5,Def.ScaleMin))
	--local action_max = cc.Sequence:create(cc.ScaleTo:create(open_time, Def.ScaleMax*1.1),cc.ScaleTo:create(shrink_time, Def.ScaleMax))
	--local action_min = cc.Sequence:create(cc.ScaleTo:create(open_time, Def.ScaleMin*1.1),cc.ScaleTo:create(shrink_time, Def.ScaleMin))
	bg_im:runAction(action_max)
	panel:runAction(action_min)
    if coroutine.running() then
        SleepSecs(shrink_time * 2 + open_time)
    end
    return node
end

function PopLayer:PopInstance(Layer)
    local layer = self:Get(Layer)
    if layer then
        layer:Close()
    end
    return self:Pop(Layer)
end

function PopLayer:SetTopMost(layer)
    local p = layer:getParent()
    local pp = p:getParent()
    local zorder = -1
    local children = pp:getChildren()
    for _,child in ipairs(children) do
        local z = child:getLocalZOrder()
        if z > zorder then
            zorder = z
        end
    end
    zorder = zorder + 1
    p:setLocalZOrder(zorder)
end

-----------------------------------------------------

return PopLayer
