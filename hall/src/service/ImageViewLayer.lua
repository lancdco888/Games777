local ImageViewLayer = class("ImageViewLayer", function()
    return cc.Node:create()
end)

function ImageViewLayer:ctor()
end

function ImageViewLayer:setImage(image)
    self:AddTouchMask()

    if not image then return end
    
    self:addChild(image)
    local size = image:getContentSize()

    local corner = 40
    local scale_x = (Def.visibleSize.width - corner) / size.width
    local scale_y = (Def.visibleSize.height - corner) / size.height
    local scale = math.min(scale_x, scale_y)
    image:setScale(scale)
end

function ImageViewLayer:AddTouchMask()
    local name = "touch"
    local touch = self:getChildByName(name)
    if touch then return end

    local full_width = Def.visibleSize.width / Def.ScaleMin
    local full_height = Def.visibleSize.height / Def.ScaleMin
    touch = cc.LayerColor:create(cc.c4b(0, 0, 0, 0), full_width, full_height)
    touch:setName(name)

    local listener = cc.EventListenerTouchOneByOne:create()
    listener:setSwallowTouches(true)
    listener:registerScriptHandler(function(touch, event)
        self:Close()
        return true
    end, cc.Handler.EVENT_TOUCH_BEGAN)
    cc.Director:getInstance():getEventDispatcher():addEventListenerWithSceneGraphPriority(listener, touch)
    
    touch:setAnchorPoint(cc.p(0.5,0.5))
    touch:setIgnoreAnchorPointForPosition(false)
    touch:setPosition(0, 0)
    touch:setLocalZOrder(-1)
    touch:runAction(cc.FadeTo:create(0.5, 255))

    self:addChild(touch)
end

---------------------------------------------------------

function ImageViewLayer:setImagePath(file_path)
    local sprite = cc.Sprite:create(file_path)
    if not sprite then return end
    self:setImage(sprite)
end

function ImageViewLayer:setBase64Image(base64Data)
    local sprite = createSpriteFromBase64(base64Data)
    if not sprite then return end
    self:setImage(sprite)
end

return ImageViewLayer
