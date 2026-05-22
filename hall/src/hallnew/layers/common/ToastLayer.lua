local ToastLayer = class("ToastLayer", function()
    return Tools.CreateLayer("csb/common/Toast.csb")
    -- return Tools.CreateLayer("ui/common/Toast.ui")
end)

function ToastLayer:onEnter()
    self:AdjustUI()
    self:InitUI()
end

function ToastLayer:InitUI()
    self.ui_item = self:findChild("item")
    self.start_pos = cc.p(self.ui_item:getPosition())
    self.size = self.ui_item:findChild("bg"):getContentSize()
    self.ui_item:retain()
    self.ui_item:removeFromParent()
end

function ToastLayer:AdjustUI()
    self:setAnchorPoint(cc.p(0.5, 0.5))
end

function ToastLayer:ShowToast(msg)
    -- 所有之前 item上移
    local children = self:getChildren()
    for _,item in ipairs(children) do
        if item:getName() == "item" then
            item:runAction(cc.MoveBy:create(0.08, cc.p(0, self.size.height)))    
        end
    end
    --创建新item
    local new_item = self:MakeItem(msg)
    self:addChild(new_item)
    local action = self:ToastAction()
    new_item:runAction(action)
end

function ToastLayer:MakeItem(msg)
    local text_width = self:findChild("text_1")
    text_width:setString(tostring(msg))
    local real_size = text_width:getContentSize()
    local new_item = self.ui_item:clone()
    local ui_text = new_item:findChild("text")
    local ui_bg = new_item:getChild("bg")
    local size = ui_text:getContentSize()
    local old_size = ui_bg:getContentSize()
    if real_size.width > Def.DesignedX - 200 then
        ui_text:setContentSize(cc.size(Def.DesignedX - 200,size.height * 2 + 10))
        ui_bg:setContentSize(cc.size(Def.DesignedX - 200, old_size.height * 2 + 10))
    else
        ui_text:setContentSize(cc.size(real_size.width,size.height + 10))
        ui_bg:setContentSize(cc.size(real_size.width, old_size.height + 10))
    end
    ui_text:setString(tostring(msg))
    self.size = ui_bg:getContentSize()
    return new_item
end

function ToastLayer:ToastAction()
    local action = cc.Sequence:create(
        cc.ScaleTo:create(0.1, 1.1),
        cc.DelayTime:create(1.0),
        cc.FadeOut:create(1.0),
        cc.RemoveSelf:create()
    )
    return action
end

function ToastLayer:Close()
    -- 空方法，不会主动退出这个界面
end

return ToastLayer
