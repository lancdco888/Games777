function TR(text)
    if GetLang() == "cn" then
        return text
    end

    local success, translate = Translator:translate(text)
    if not success then
        return text
    elseif translate == "" then
        return text
    else
        return translate
    end
end

TR_ = TR

-- 按钮上的文本不会超出按钮的宽
function AdaptButton(button)
    local label = button:getTitleLabel()
    local width_label = label:getContentSize().width
    local width_btn = button:getContentSize().width
    while true do
        if width_label > width_btn*1.5 then -- 1.5-->1.2
            local font_size = button.__origin_font_size or label:getRenderingFontSize()
            local font_size_new = math.floor(font_size/(width_label/(width_btn*1.2)))
            label:setSystemFontSize(font_size_new)
        elseif width_label > width_btn*0.9 then
            local scalex = width_btn*0.9/width_label
            label:setScaleX(scalex)
            -- 最终一定要来到这一步
            break
        else
            break
        end
        width_label = label:getContentSize().width
    end
end

-- 翻译一个 node 所有子节点
function TR_Node(node)
    local children = node:getChildren()
    for _,item in ipairs(children) do
        TR_Node(item)
    end

    local name = node:getName()
    if not string.find(name, "_lang") then
        return
    end

    -- print("this node need to translate:" .. tostring(name))
    if tolua.type(node) == "ccui.Button" then
        -- 保存原有数据
        local label = node:getTitleLabel()
        if node.__origin_text == nil then
            node.__origin_text = node:getTitleText()
            node.__origin_font_size = label:getRenderingFontSize()
        end
        local translate = TR(node.__origin_text)
        -- print("translate:" .. tostring(translate))
        node:setTitleText(translate)
        AdaptButton(node)
    elseif tolua.type(node) == "ccui.Text" then
        -- 保存原有数据
        if node.__origin_text == nil then
            node.__origin_text = node:getString()
            node.__origin_text_width = node:getContentSize().width
            node.__font_size = node:getFontSize()
        end
        local translate = TR(node.__origin_text)
        -- print("translate:" .. tostring(translate))
        node:setString(translate)
        if not node:isIgnoreContentAdaptWithSize() then
            return
        end
        local width_label = node:getContentSize().width
        if width_label > node.__origin_text_width*1.5 then
            local scalex = node.__origin_text_width*1.2/width_label
            node:setScaleX(scalex)
        end
    end
end
