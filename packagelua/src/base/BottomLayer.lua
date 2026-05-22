local BottomLayer = class("BottomLayer")

-- Bottom Layer 管理最底层的界面,该种类型界面只能有一个,打开新界面将关闭旧界面
function BottomLayer:Show(LayerClass)
    local scene = cc.Director:getInstance():getRunningScene()
    local children = scene:getChildren()
    local layer = nil
    for _,c in ipairs(children) do
        if c.__is_bottom_layer then
            if c.__class == LayerClass then
                layer = c
            else
                c:removeFromParent()
            end
        end
    end
    if not layer and LayerClass ~= nil then
        layer = LayerClass.new()
        layer.__is_bottom_layer = true
        layer.__class = LayerClass
        layer:setLocalZOrder(0)
        scene:addChild(layer)
    end
    if layer then
        layer:setVisible(true)
    end
    return layer
end

function BottomLayer:Get(LayerClass)
    local scene = cc.Director:getInstance():getRunningScene()
    local children = scene:getChildren()
    for _,c in ipairs(children) do
        if c.__is_bottom_layer and c.__class == LayerClass then
            return c
        end
    end
    return nil
end

function BottomLayer:Clear()
    local scene = cc.Director:getInstance():getRunningScene()
    local children = scene:getChildren()
    for _,c in ipairs(children) do
        if c.__is_bottom_layer then
            c:removeFromParent()
        end
    end
end

return BottomLayer
