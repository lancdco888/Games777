local QuestionLayer = class("QuestionLayer", function(node)
    node:enableNodeEvents()
    return node
end)

function QuestionLayer:ctor()
    self:Init()
end

function QuestionLayer:Init()
    local Text_1 =self:getChildByName("Text_1")
    Text_1:setString(TR("如果有其他问题可直接联系'在线客服'"))

    local Button_6 =self:getChildByName("Button_6")
    Tools.AddClickEvent(Button_6, function()
        if self.onServiceClicked then
            self.onServiceClicked()
        end
    end, true)

    local zxkf = Button_6:getChildByName("_lang_zxkf")
    Tools.CcuiTextIgnoreContentAdaptByScaleX(zxkf)

    self.ListView_question =self:getChildByName("ListView_question")
    self.ListView_question:setScrollBarEnabled(false)
    self.ask_bg = self.ListView_question:getChildByName("ask_bg")
    self.ask_bg:retain()

    self.answer_bg = self.ListView_question:getChildByName("answer_bg")
    self.answer_bg:retain()

    self.ListView_question:removeAllItems()

    self.questions = {}
    self.questions_item = {}

    go(function()
        self:GetQuestions()
    end)
end

-- 获取所有的问题
function QuestionLayer:GetQuestions()
    local data_ = PKG_Client_Lobby_GetFAQ.Create()
    local rlt_ = GetCachedResponse(data_)

    if not rlt_ then
        UIManager.ShowWaiting()
        rlt_ = gNet_SendRequest(data_)
        UIManager.HideWaiting()
    end

    if not rlt_ then
        print("PKG_Client_Lobby_GetFAQ get nil")
        return
    end

    if tolua.isnull(self) then return end

    if getmetatable(rlt_) == PKG_Lobby_Client_FAQList then
        AddCachedResponse(data_, rlt_, 5 * 60)
        self.questions = rlt_.FAQListResult
    else
        print("PKG_Client_Lobby_GetFAQ error ", rlt_.masssage)
    end
end

function QuestionLayer:onServiceClickedEvent(onServiceClicked)
    self.onServiceClicked = onServiceClicked
end

function QuestionLayer:showQuestions()
    if #self.questions_item ~= 0 then return end

    local questions = self.questions
    self.questions_item = {}

    UIManager.ShowWaiting()
    local textforgetlen = self:getChildByName("getlen")
    for i = 1, #questions do
        local item = self.ask_bg:clone()
        item:getChildByName("Text_ask"):setString(questions[i].question)
        local Button_look = item:getChildByName("Button_look")
        Tools.AddClickEvent(item, function()
            local needCreate = true

            -- 删除所有的答案
            for _, _item in pairs(self.questions_item) do
                if _item.islook then
                    local _ind = self.ListView_question:getIndex(_item)
                    local lastPercent = self.ListView_question:getScrolledPercentVertical()
                    local lastContentHeight = self.ListView_question:getInnerContainerSize().height
                    local lastPosHeight = lastContentHeight*lastPercent
                    self.ListView_question:removeItem(_ind+1)
                    local currtentContentHeight = self.ListView_question:getInnerContainerSize().height
                    local currtentPercent = lastPosHeight/currtentContentHeight
                    if tostring(currtentPercent) ~= "inf"
                    and tostring(currtentPercent) ~= "-inf"
                    and tostring(currtentPercent) ~= "nan" then
                        self.ListView_question:jumpToPercentVertical(currtentPercent)
                    end
                    _item:getChildByName("Button_look"):setEnabled(true)
                    _item.islook = false
                    if _item == item then
                        needCreate = false
                    end
                end
            end
            if not needCreate then
                return
            end

            -- 需要创建一个答案
            local index = self.ListView_question:getIndex(item)
            local itemA = self.answer_bg:clone()
            local text_answer = itemA:getChildByName("Text_answer")
            text_answer:setString(questions[i].answer)

            --根据内容设置显示大小
            local size = text_answer:getContentSize()
            local real_size = text_answer:getVirtualRendererSize()
            if real_size.width < size.width then
                size.width = 0
            end
            size.height = 0
            text_answer:setTextAreaSize(size)
            text_answer:ignoreContentAdaptWithSize(false)
            size = text_answer:getVirtualRendererSize()
            text_answer:ignoreContentAdaptWithSize(true)
            text_answer:setContentSize(size)
            itemA:setContentSize(itemA:getContentSize().width,text_answer:getContentSize().height + 20)

            -- 创建图片列表
            -- 图片列表高加入计算
            local pic_list_height = text_answer:getPositionY() + text_answer:getContentSize().height + 5
            local piclist_height = self:CreatePicList(questions[i].images,itemA,pic_list_height)
            itemA:setContentSize(itemA:getContentSize().width,itemA:getContentSize().height + piclist_height)
            local lastPercent = self.ListView_question:getScrolledPercentVertical()
            local lastContentHeight = self.ListView_question:getInnerContainerSize().height
            local lastPosHeight = lastContentHeight*lastPercent
            self.ListView_question:insertCustomItem(itemA,index+1)
            local currtentContentHeight = self.ListView_question:getInnerContainerSize().height
            local currtentPercent = lastPosHeight/currtentContentHeight
            if tostring(currtentPercent) ~= "inf"
            and tostring(currtentPercent) ~= "-inf"
            and tostring(currtentPercent) ~= "nan" then
                self.ListView_question:jumpToPercentVertical(currtentPercent)
            end
            Button_look:setEnabled(false)
            item.islook = true
        end,true)

        self.ListView_question:pushBackCustomItem(item)
        table.insert(self.questions_item, item)
    end

    UIManager.HideWaiting()
    self:setVisible(true)
end

-- 根据图片列表，判断是否显示缩略图表,返回缩略图表高
function QuestionLayer:CreatePicList(images, item_, pos_y)
    local list_images = string.split(images,",")
    if images == "" then
        local btn_pic = item_:getChildByName("pic_btn")
        btn_pic:setVisible(false)
        return 0
    end

    local pic_list = item_:getChildByName("pic_list")
    pic_list:setVisible(true)
    pic_list:setPosition(pic_list:getPositionX(),pos_y)
    local btn_pic = item_:getChildByName("pic_btn")
    btn_pic:retain()

    local designWidth = btn_pic:getContentSize().width
    for key, value in pairs(list_images) do
        local item_pic_btn = btn_pic:clone()
        local picturePath = ""
        if value:find("http") then
            local tab = string.split(value,"/images/")
            local pictureName = string.split(tab[2],",")[1]
            local localPicturePath = const_def.WritablePath.. "picture/" .. pictureName
            if not Tools.FileIsBeing(localPicturePath) then    --如果不本地存在图片
                self:GetPictureWithUrl(value,item_pic_btn,pic_list)    --下载图片
            else
                picturePath = localPicturePath                --存在加载图片
            end
        end
        -- 如果图片非法
        if not cc.Director:getInstance():getTextureCache():addImage(picturePath) then
            pic_list:pushBackCustomItem(item_pic_btn)
        else
            Tools.LoadTexture(item_pic_btn,picturePath)
            local size = item_pic_btn:getVirtualRendererSize()
            if size.width> designWidth then
                item_pic_btn:setScale(designWidth/size.width)
            end
            item_pic_btn:setVisible(true)
            item_pic_btn:setContentSize(size)
            item_pic_btn:addTouchEventListener(function(ref,type)
                if(type == ccui.TouchEventType.ended) then
                    --按键音效
                    gSound.clickSound()
                    self:CreateShowPic(picturePath)
                end
            end)

            pic_list:pushBackCustomItem(item_pic_btn)
        end
    end
    btn_pic:setVisible(false)
    btn_pic:release()
    return pic_list:getContentSize().height
end

-- 创建图片显示
function QuestionLayer:CreateShowPic(pic_path)
    local layer = PopLayer:Pop(service.ImageViewLayer)
    layer:setImagePath(pic_path)
end

-- 创建一个图片节点
function QuestionLayer:CreatePicListChild(pic_path,btn_,pic_list)
    local item_pic_btn = btn_
    local designWidth = btn_:getContentSize().width
    Tools.LoadTexture(item_pic_btn,pic_path)
    local size = item_pic_btn:getVirtualRendererSize()
    if size.width> designWidth then
        item_pic_btn:setScale(designWidth/size.width)
    end
    item_pic_btn:setVisible(true)
    item_pic_btn:setContentSize(size)
    item_pic_btn:addTouchEventListener(function(ref,type)
        if(type == ccui.TouchEventType.ended) then
            --按键音效
            gSound.clickSound()
            self:CreateShowPic(pic_path)
        end
    end)
    pic_list:forceDoLayout()
end

-- 下载图片
function QuestionLayer:GetPictureWithUrl(url, btn_, pic_list)
    btn_:retain()
    pic_list:retain()

    local xhr = cc.XMLHttpRequest:new()
    local tab = string.split(url,"/images/")
    xhr._urlFileName = "download/picture/"..string.split(tab[2],",")[1]  -- 图片的相对路径
    xhr.responseType = cc.XMLHTTPREQUEST_RESPONSE_STRING
    xhr:open("GET", url)
    local function onDownloadImage()
        if xhr.readyState == 4 and (xhr.status >= 200 and xhr.status < 207) then
            local fileData = xhr.response
            local fullFileName = cc.FileUtils:getInstance():getWritablePath() .. xhr._urlFileName

            local dirName = string.match(fullFileName, "(.+)/[^/]*$")
            if not cc.FileUtils:getInstance():isDirectoryExist(dirName) then
                cc.FileUtils:getInstance():createDirectory(dirName)
            end

            local file = io.open(fullFileName,"wb")
            file:write(fileData)
            file:close()

            -- 加载图片
            cc.Director:getInstance():getTextureCache():addImage(fullFileName)

            if tolua.isnull(self) or tolua.isnull(btn_) then return end
            self:CreatePicListChild(fullFileName, btn_, pic_list)
            btn_:release()
            pic_list:release()
        end
    end
    xhr:registerScriptHandler(onDownloadImage)
    xhr:send()
end

return QuestionLayer
