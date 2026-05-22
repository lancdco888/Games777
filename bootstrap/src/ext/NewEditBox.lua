local NewEditBox = class("NewEditBox", function()
    local edit = ccui.EditBox:create(cc.size(0, 0), "")
    edit:enableNodeEvents()
    return edit
end)

function NewEditBox:ctor()
    self.onHandler = nil

    ccui.EditBox.registerScriptEditBoxHandler(
        self,
        function(eventname, sender)
            self:onScriptEditBoxHandler(eventname, sender)
		end
    )

    self.label = cc.Label:create()
    self.label:setTextColor(cc.c3b(220, 220, 220))
    self.label:addTo(self)
    
    --设置占位符对齐方式
    self.label:setAlignment(
        cc.TEXT_ALIGNMENT_LEFT,
        cc.TEXT_ALIGNMENT_CENTER
    )
end

function NewEditBox:onScriptEditBoxHandler(eventname, sender)
    local input = self:getText()
    if input == "" then
        self.label:setString(self.placeHolder)
    else
        self.label:setString("")
    end
    if self.onHandler then
        self.onHandler(eventname, sender)
    end
end

function NewEditBox:onEnter()
    --获取到editBox的锚点及原点来设置占位符所在的label的位置信息
    local eSize = self:getContentSize()
    --设置占位符所在label的位置信息
    self.label:setAnchorPoint(0.5, 0.5)
    self.label:setPosition(eSize.width/2.0, eSize.height/2.0)
    self.label:setDimensions(eSize.width, eSize.height)
end

function NewEditBox:setText(text)
    if text == "" then
        self.label:setString(self.placeHolder)
    else
        self.label:setString("")
    end
    ccui.EditBox.setText(self, text)
end

function NewEditBox:setString(text)
    self:setText(text)
end

function NewEditBox:getString()
    return self:getText()
end

--设置占位符内容
function NewEditBox:setPlaceHolder( _placeHolderContent )
    self.placeHolder = _placeHolderContent
    self.label:setString(_placeHolderContent)
end

--设置占位符的fontSize
function NewEditBox:setPlaceholderFontSize( _placeHolderFontSize )
    self.label:setSystemFontSize(_placeHolderFontSize)
end

--设置占位符的fontName
function NewEditBox:setPlaceholderFontName( _placeHolderFontName )
    self.label:setSystemFontName(_placeHolderFontName)
end

--设置占位符的颜色
function NewEditBox:setPlaceholderColor( _placeHolderColor )
    self.label:setTextColor(_placeHolderColor)
end

function NewEditBox:onEvent(handler)
    self.onHandler = handler
end

function NewEditBox:registerScriptEditBoxHandler(handler)
    self.onHandler = handler
end

return NewEditBox
