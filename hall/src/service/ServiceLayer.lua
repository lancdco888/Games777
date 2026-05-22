local ServiceLayer = class("ServiceLayer", function(node)
    node:enableNodeEvents()
    return node
end)

local MESSAGE_TYPE = {
    SERVICE_TEXT = 0,-- 客服文本
    SERVICE_PICTURE = 1,-- 客服图片
    PLAYER_TEXT = 2,-- 玩家文本
    PLAYER_PICTURE = 3,-- 玩家图片
}

function ServiceLayer:ctor()
    self.Panel_right_cell = nil
    self.Panel_left_cell = nil
    self.Panel_time = nil

    self:Init()

    self:GetMessage(0, 10)

    self.requireMoreMessages = true
end

-- 获取消息
function ServiceLayer:GetMessage(index, count)
    go(
        function()
            if not gNet:Alive() then
                return
            end
            local data_ = PKG_Client_Lobby_GetMessage.Create()
            data_.limitindex = index or 0
            data_.count = count or 10
            data_.accountid = 0
            data_.username = ""
            UIManager.ShowWaiting()
            local rlt_ = gNet_SendRequest(data_)
            UIManager.HideWaiting()

            if tolua.isnull(self) then return end

            if(getmetatable(rlt_) == PKG_Lobby_Client_AllMessage)then
                if #rlt_.messages == 0 and index ~= 0 then
                    UIManager.ShowToast(TR("没有更多的消息了"))
                    self:runAction(cc.Sequence:create(cc.DelayTime:create(1),
                        cc.CallFunc:create(function() self.requireMoreMessages = true end)))
                    return
                end
                if index == 0 then
                    self:AllMessageToTab(rlt_.messages,true)
                else
                    self:AllMessageToTab(rlt_.messages,false)
                end

            elseif(getmetatable(rlt_) == PKG_Generic_Error)then
                print("ServiceLayer:GetMessage  PKG_Client_Lobby_GetMessage 错误", rlt_.message)
            end
        end
    )
end

function ServiceLayer:CreateChatItem(isImage, type, content, createtime)
    local item = nil
    if type == 0 then
        if isImage then
            item = self:MakeMsg(MESSAGE_TYPE.PLAYER_PICTURE, content)
        else
            item = self:MakeMsg(MESSAGE_TYPE.PLAYER_TEXT, content)
        end
    else
        if isImage then
            item = self:MakeMsg(MESSAGE_TYPE.SERVICE_PICTURE, content)
        else
            item = self:MakeMsg(MESSAGE_TYPE.SERVICE_TEXT, content)
        end
    end

    self.ChatContentLview:insertCustomItem(item, 0)
    local time_cell = self:addTime(self:Int64ToDateTime(createtime), type)
    self.ChatContentLview:insertCustomItem(time_cell, 0)
    return item
end

-- 所有的聊天信息转换成聊天记录
function ServiceLayer:AllMessageToTab(messages, needToBottom)
    local num = 0
    for i=1,#messages do
        local msg = messages[i]
        if msg.image_url and msg.image_url ~= "" then
            num = num + 1
            self:CreateChatItem(true, msg.type, msg.image_url, msg.createtime)
        end

        if msg.content and msg.content ~= "" then
            local isJson = string.sub(msg.content, 1, 5) == "json:"
            if isJson then
                msg.content = string.gsub(msg.content, "json:", "")
                local Msgs = self:Json2Msg(msg)
                for _, jsonMsg in ipairs(Msgs) do
                    num = num + 1
                    if jsonMsg.image_url and jsonMsg.image_url ~= "" then
                        self:CreateChatItem(true, jsonMsg.type, jsonMsg.image_url, jsonMsg.createtime)
                    else
                        self:CreateChatItem(false, jsonMsg.type, jsonMsg.content, jsonMsg.createtime)
                    end
                end
            else
                num = num + 1
                self:CreateChatItem(false, msg.type, msg.content, msg.createtime)
            end
        end
    end

    if needToBottom then
        self.ChatContentLview:jumpToBottom()
    else
        self.ChatContentLview:jumpToItem(num*2+1, cc.p(0,0), cc.p(0,0))
    end

    self:runAction(cc.Sequence:create(cc.DelayTime:create(1),
        cc.CallFunc:create(function() self.requireMoreMessages = true end)))
end

function ServiceLayer:OnPicButtonClick()
    Tools.UploadSelectPhoto(function(success, url, base64data)
        if not success then
            print("upload select image failed.")
            return
        end

        if tolua.isnull(self) then return end
        self:SendMessage(nil, url)
    end)
end

--------------------------------------------------------------

function ServiceLayer:Init()
    -- 发送按钮
    local Button_send = self:getChildByName("_lang_Button_send")
    Tools.AddClickEvent(Button_send, function()
        self:SendBtnCallBack()
    end,true)

    -- 添加图片按钮
    local Button_picture = self:getChildByName("_lang_Button_picture")
    Tools.AddClickEvent(Button_picture, function()
        self:OnPicButtonClick()
    end, true)

    local Image_30 = self:getChildByName("Image_30")
    local Text_10 = Image_30:getChildByName("Text_10")
    Text_10:setVisible(false)

    local input_pos = cc.p(Text_10:getPositionX(),Text_10:getPositionY())
    local input_ContentSize = Text_10:getContentSize()
    local inputEdit = ccui.EditBox:create(input_ContentSize, "")
    self.inputEdit = inputEdit
    inputEdit:setPosition(input_pos)
    inputEdit:setPlaceHolder(TR("请在这里输入你的问题"))

    local PlaceholderFont = 22
    inputEdit:setPlaceholderFont("Arial", PlaceholderFont)
    inputEdit:setFontSize(36)
    inputEdit:setMaxLength(50)
    inputEdit:setTextHorizontalAlignment(cc.TEXT_ALIGNMENT_LEFT)
    inputEdit:setPlaceholderFontColor(cc.c3b(220,220,220))
    inputEdit:setAnchorPoint(cc.p(0,0.5))
    inputEdit:setInputMode(cc.EDITBOX_INPUT_MODE_SINGLELINE)
    inputEdit:registerScriptEditBoxHandler(function(...)
        self:InputCallBack(...)
    end)
    Image_30:addChild(inputEdit)

    -- 聊天框
    local ChatContentLview = self:getChildByName("ListView_service")
    self.ChatContentLview = ChatContentLview
    ChatContentLview:setScrollBarEnabled(false)
    ChatContentLview:addScrollViewEventListener(function(...)
        self:ScrollEvents(...)
    end)

    -- Panel_right 玩家的聊天框预制体
    local Panel_right_cell = self.ChatContentLview:getChildByName("Panel_right")
    self.Panel_right_cell = Panel_right_cell
    Panel_right_cell.designWidth = Panel_right_cell:getChildByName("bg"):getContentSize().width
    Panel_right_cell:retain()

    -- Panel_left 客服的聊天框预制体
    local Panel_left_cell = self.ChatContentLview:getChildByName("Panel_left")
    self.Panel_left_cell = Panel_left_cell
    Panel_left_cell.designWidth = Panel_left_cell:getChildByName("bg"):getContentSize().width
    Panel_left_cell:retain()

    -- Panel_time 时间的预制体
    local Panel_time = self.ChatContentLview:getChildByName("Panel_time")
    self.Panel_time = Panel_time
    Panel_time:retain()
    self.ChatContentLview:removeAllItems()
end

-- listView 滑动事件监听
function ServiceLayer:ScrollEvents(sender, eventType)
    -- 滚动到底部
    if eventType == ccui.ScrollviewEventType.scrollToTop then
        if self.requireMoreMessages then -- 可以请求聊天内容的时候请求，避免反复请求
            self.requireMoreMessages = false
            self:GetMessage(self.ChatContentLview:getChildrenCount()/2, 10)
        end
    end
end

-- 发送按钮的回调
function ServiceLayer:SendBtnCallBack()
    local msg = self.inputEdit:getText()
    msg = string.gsub(msg, "/r/n", "") -- 去掉换行
    msg = string.trim(msg) -- 去掉前后空格
    if msg == "" or msg == nil then -- 消息为空
        return
    end

    self.inputEdit:setText("")
    self.inputEdit:setPlaceHolder(TR("请在这里输入你的问题"))
    self:SendMessage(msg, nil)
end

-- 输入框回调
function ServiceLayer:InputCallBack(event, sender)
    if event == "began" then
        self.inputEdit:setPlaceHolder("")
    elseif event == "changed" then
    elseif event == "return" then
        if self.inputEdit:getText() == "" then
            self.inputEdit:setPlaceHolder(TR("请在这里输入你的问题"))
        end
    elseif event == "end" then
        if self.inputEdit:getText() == "" then
            self.inputEdit:setPlaceHolder(TR("请在这里输入你的问题"))
        end
    end
end

-- 添加一个聊天记录
function ServiceLayer:MakeMsg(type, content)
    if type == nil or content == nil then
        print("检查聊天内容是否有误")
        return nil
    end

    local item = nil
    content = string.gsub(content, "show:", "")
    if type == MESSAGE_TYPE.SERVICE_TEXT then
        item = self:MakeMessage(self.Panel_left_cell,content)
    elseif type == MESSAGE_TYPE.SERVICE_PICTURE then
        item = self:MakePicture(self.Panel_left_cell,content)
    elseif type == MESSAGE_TYPE.PLAYER_TEXT then
        item = self:MakeMessage(self.Panel_right_cell,content, self:GetMyIcon())
    elseif type == MESSAGE_TYPE.PLAYER_PICTURE then
        item = self:MakePicture(self.Panel_right_cell,content, self:GetMyIcon())
    end
    return item
end

-- 获取自己的头像
function ServiceLayer:GetMyIcon()
    local head_icon_id = 0
    if UserData and UserData.avatar_id then
        head_icon_id = UserData.avatar_id
    end
    if head_icon_id == 0 then
        head_icon_id = 1
    end
    local path = Tools.GetHeadPath(head_icon_id)
    return path
end

-- 添加一条文本消息到聊天框中
function ServiceLayer:MakeMessage(cell, message, icon)
    if not cell then
        return
    end

    local newM = cell:clone()
    local contentBG = newM:getChildByName("bg") -- 聊天框
    local headIcon = newM:getChildByName("Image_4") -- 头像
    local content = newM:getChildByName("content") -- 单条聊天记录内容
    if icon then
        headIcon:loadTexture(icon)
    end
    local contentMsg = content:getChildByName("Text_1") -- 聊天文本
    contentMsg:setVisible(true)
    local contentPicture = content:getChildByName("Image_5") -- 聊天图片
    contentPicture:setVisible(false)
    if not message then
        print("AddMessage 没有 message")
        return
    end
    contentMsg:setString(message)
    self:textAdaptHeight(contentMsg)
    local size = cc.size(contentMsg:getContentSize().width+30,contentMsg:getContentSize().height +20)
    contentBG:setContentSize(size)
    size = cc.size(contentMsg:getContentSize().width+30,
        (contentMsg:getContentSize().height>headIcon:getContentSize().height and contentMsg:getContentSize().height or headIcon:getContentSize().height)+20)
    local icon_height= newM:getContentSize().height - size.height
    headIcon:setPosition(headIcon:getPositionX(),headIcon:getPositionY()-icon_height)
    contentBG:setPosition(contentBG:getPositionX(),contentBG:getPositionY()-icon_height)
    content:setPosition(content:getPositionX(),content:getPositionY()-icon_height)
    newM:setContentSize(cc.size(newM:getContentSize().width,size.height+10))
    return newM
end

-- 添加一条图片到聊天框中
function ServiceLayer:MakePicture(cell, picturePath, icon)
    if not cell then
        return
    end

    local newM = cell:clone()
    newM = self:ResetPicture(newM, picturePath, icon)
    return newM
end

-- 重新设置图片
function ServiceLayer:ResetPicture(newM, picturePath, icon)
    local headIcon = newM:getChildByName("Image_4") -- 头像
    local contentBG = newM:getChildByName("bg") -- 聊天框
    local content = newM:getChildByName("content") -- 单条聊天记录内容
    if icon then
        headIcon:loadTexture(icon)
    end
    local contentMsg = newM:getChildByName("content"):getChildByName("Text_1") -- 聊天文本
    contentMsg:setVisible(false)
    local contentPicture = newM:getChildByName("content"):getChildByName("Image_5") -- 聊天图片
    contentPicture:setVisible(true)
    if not picturePath then
        print("AddPicture 没有 picturePath")
    end
    if picturePath:find("http") then
        local tab = string.split(picturePath,"/images/")
        local pictureName = string.split(tab[2],",")[1]
        local localPicturePath = const_def.WritablePath.. "picture/" .. pictureName
        if not Tools.FileIsBeing(localPicturePath) then    --如果不本地存在图片
            self:GetPictureWithUrl(picturePath,newM,icon)
            picturePath = "hallui/serviceEx/Default/ImageFile.png"
        else
            picturePath = localPicturePath
        end
    end
    -- 如果图片非法
    if not cc.Director:getInstance():getTextureCache():addImage(picturePath) then
        picturePath = "hallui/serviceEx/Default/ImageFile.png"
    end
    contentPicture:loadTexture(picturePath,0)
    contentPicture:addTouchEventListener(function(ref,type)
        if(type == ccui.TouchEventType.ended)then
            local layer = PopLayer:Pop(service.ImageViewLayer)
            layer:setImagePath(picturePath)
        end
    end)

    self:pictureAdaptWidth(contentPicture, icon and true or false)
    local iamgeScale  = contentPicture:getScale()
    local size = contentPicture:getContentSize()
    local bgSize = cc.size(size.width*iamgeScale+35,size.height*iamgeScale+18)
    contentBG:setContentSize(bgSize)
    local headIconSize = headIcon:getContentSize()
    local otherSize = cc.size(bgSize.width,
        (size.height>headIconSize.height and size.height*iamgeScale or headIconSize.height)+20)
    local icon_height= newM:getContentSize().height - otherSize.height - 5
    headIcon:setPosition(headIcon:getPositionX(),headIcon:getPositionY()-icon_height)
    contentBG:setPosition(contentBG:getPositionX(),contentBG:getPositionY()-icon_height)
    contentPicture:setPosition(contentPicture:getPositionX(),contentPicture:getPositionY()-icon_height)
    newM:setContentSize(cc.size(newM:getContentSize().width,otherSize.height+10))
    return newM
end

-- 获取网络图片
function ServiceLayer:GetPictureWithUrl(url, node)
    local xhr = cc.XMLHttpRequest:new()

    local tab = string.split(url,"/images/")
    xhr._urlFileName = "download/picture/"..string.split(tab[2],",")[1]  -- 图片的相对路径
    xhr.responseType = cc.XMLHTTPREQUEST_RESPONSE_STRING
    node:retain()
    xhr:open("GET", url)

    local function onDownloadImage()
        if xhr.readyState == 4 and (xhr.status >= 200 and xhr.status < 207) then
            local fileData = xhr.response
            local fullFileName = cc.FileUtils:getInstance():getWritablePath() .. "/".. xhr._urlFileName

            local dirName = string.match(fullFileName, "(.+)/[^/]*$")
            if not cc.FileUtils:getInstance():isDirectoryExist(dirName) then
                cc.FileUtils:getInstance():createDirectory(dirName)
            end

            local file = io.open(fullFileName,"wb")
            if file == nil then
                UIManager.ShowToast("make file failed,maybe disk full")
                return
            end
            file:write(fileData)
            file:close()

            if tolua.isnull(self) then
                return
            end

            self:ResetPicture(node,fullFileName)
            node:release()

            local percent_ = self.ChatContentLview:getScrolledPercentVertical()
            self.ChatContentLview:requestDoLayout()
            if percent_ == percent_ then -- 不要删这一行，判断是否为nan
                self.ChatContentLview:jumpToPercentVertical(percent_)
            end
        end
    end
    xhr:registerScriptHandler(onDownloadImage)
    xhr:send()
end

-- 文本实际宽高
function ServiceLayer:textAdaptHeight(text)
    local size = text:getContentSize()
    local real_size = text:getVirtualRendererSize()
    if real_size.width < size.width then
        size.width = 0
    end
    size.height = 0
    text:setTextAreaSize(size)
    text:ignoreContentAdaptWithSize(false)
    size = text:getVirtualRendererSize()
    text:ignoreContentAdaptWithSize(true)
    text:setContentSize(size)
end

-- 图片实际宽高image:图片;width:设计的宽
function ServiceLayer:pictureAdaptWidth(image, right)
    local width = 0
    if right then
        if self.Panel_right_cell then
            width = self.Panel_right_cell.designWidth
        end
    else
        if self.Panel_left_cell then
            width = self.Panel_left_cell.designWidth
        end
    end
    local size = image:getVirtualRendererSize()
    if size.width>width then
        image:setScale(width/size.width)
    end
    image:setContentSize(size)
end

function ServiceLayer:SendMessage(msg, pictureName)
    go(
        function()
            UIManager.ShowWaiting()
            while not gNet:Alive() do
                yield()
            end

            local data_ = PKG_Client_Lobby_SendMessage.Create()
            data_.content = msg or ""
            data_.image = pictureName or ""
            data_.accountid = UserData.id
            data_.username = UserData.username

            local rlt_ = nil
            for i = 1, 2 do
                rlt_ = gNet_SendRequest(data_)
                dump(rlt_, " ** rlt_ ** ")

                if rlt_ and getmetatable(rlt_) == PKG_Lobby_Client_Message then
                    break
                end

                if rlt_ and getmetatable(rlt_) == PKG_Generic_Error and rlt_.number == -9999 then
                    -- "您操作太频繁，请稍后再试"
                    UIManager.ShowMsgBox("ဆက်တိုက်လုပ်ဆောင်မှုများနေသဖြင့် ခဏစောင့်ဆိုင်းပြီးမှ လုပ်‌ဆောင်ပေးပါရှင့်(E9999)")
                    break
                end

                SleepSecs(0.3)
            end

            UIManager.HideWaiting()

            if tolua.isnull(self) then return end

            if(getmetatable(rlt_) == PKG_Lobby_Client_Message)then
                if rlt_.content and rlt_.content ~= "" then
                    print(rlt_.createtime)

                    local time_cell = self:addTime(self:Int64ToDateTime(rlt_.createtime),rlt_.type)
                    self.ChatContentLview:pushBackCustomItem(time_cell)
                    local item = self:MakeMsg(MESSAGE_TYPE.PLAYER_TEXT,rlt_.content)
                    self.ChatContentLview:pushBackCustomItem(item)
                end
                if rlt_.image_url and rlt_.image_url ~= "" then
                    local time_cell = self:addTime(self:Int64ToDateTime(rlt_.createtime),rlt_.type)
                    self.ChatContentLview:pushBackCustomItem(time_cell)
                    local item = self:MakeMsg(MESSAGE_TYPE.PLAYER_PICTURE, rlt_.image_url)
                    self.ChatContentLview:pushBackCustomItem(item)
                end
                self.ChatContentLview:jumpToBottom()
            elseif(getmetatable(rlt_) == PKG_Generic_Error)then
                print("发送按钮的回调错误")
            end
        end
    )
end

-- 增加一个时间
function ServiceLayer:addTime(time, type)
    if not self.Panel_time then
        return
    end

    local cell = self.Panel_time:clone()
    cell:setVisible(true)

    local left = cell:getChildByName("left")
    local right = cell:getChildByName("right")
    left:setString(time)
    right:setString(time)
    if type == 0 then
        left:setVisible(false)
        right:setVisible(true)
    else
        left:setVisible(true)
        right:setVisible(false)
    end
    return cell
end

-- int64转成标准格式
function ServiceLayer:Int64ToDateTime(time_)
    local year,month,day,hour,min,second,week,dayforyear  = Int64ToDateTime(time_)
    local time = string.format("%02d-%02d %02d:%02d:%02d",month,day,hour,min,second)
    return time
end

-- 服务器发来的消息
function ServiceLayer:receMsg(pkg)
    if pkg.content ~= "" then
        local time_cell = self:addTime(self:Int64ToDateTime(pkg.createtime),pkg.type)
        self.ChatContentLview:pushBackCustomItem(time_cell)
        local item = self:MakeMsg(0,pkg.content)
        self.ChatContentLview:pushBackCustomItem(item)
    end
    if pkg.image_url ~= "" then
        local time_cell = self:addTime(self:Int64ToDateTime(pkg.createtime),pkg.type)
        self.ChatContentLview:pushBackCustomItem(time_cell)
        local item = self:MakeMsg(1, pkg.image_url)
        self.ChatContentLview:pushBackCustomItem(item)
    end

    self.ChatContentLview:jumpToBottom()
    go(
        function()
            local _data = PKG_Client_Lobby_ReadMessage.Create()
            _data.id = pkg.Id
            gNet_SendPush(_data)
        end
    )
end

-- 后台json转成多条消息
function ServiceLayer:Json2Msg(msg)
    local tabs = json.decode(msg.content)
    local rets = {}
    for _, tab in ipairs(tabs) do
        if tab.type == "image" then
            for _, v in ipairs(tab.url) do
                local Message = PKG_Lobby_Client_Message.Create()
                Message.createtime = msg.createtime
                Message.type = msg.type
                Message.image_url = "http://3.1.33.127/upload2/images/" .. v
                table.insert(rets,1,Message)
            end
        else
            local Message = PKG_Lobby_Client_Message.Create()
            Message.createtime = msg.createtime
            Message.type = msg.type
            Message.content = tab.content
            table.insert(rets,1,Message)
        end
    end
    return rets
end

function ServiceLayer:onExit()
    if self.Panel_right_cell then self.Panel_right_cell:release() end
    if self.Panel_left_cell then self.Panel_left_cell:release() end
    if self.Panel_time then self.Panel_time:release() end
end

return ServiceLayer
