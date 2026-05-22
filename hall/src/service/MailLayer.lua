local MailLayer = class("MailLayer", function(node)
    node:enableNodeEvents()
    return node
end)

function MailLayer:ctor()
    self.item = nil
    self.mail_list = nil
    self.on_new_mail = nil

    self:Init()
end

function MailLayer:Init()
	self.mail_list = self:getChildByName("ListView_mail")
	self.mail_list:setScrollBarEnabled(false)
	self.item = self.mail_list:getChildByName("Item")
	self.item:retain()
	self.mail_list:removeAllItems()
end

-- 获取邮件消息
function MailLayer:GetMails()
    local data_ = PKG_Client_Lobby_GetNotice.Create()
    local rlt_ = GetCachedResponse(data_)
    if not rlt_ then
        UIManager.ShowWaiting()
        rlt_ = gNet_SendRequest(data_)
        UIManager.HideWaiting()
    end

    if (getmetatable(rlt_) == PKG_Lobby_Client_GetNotices) then
        AddCachedResponse(data_, rlt_, 60)

        service.ServiceLogic:OnMailData(rlt_)
        local mails = service.ServiceLogic:GetNotices()
        if tolua.isnull(self) then return false end

        self.mails = mails

        if self.on_new_mail and service.ServiceLogic:CheckUnRead() then
            self.on_new_mail()
        end
        return true
    else
        UIManager.ShowMsgBox(TR("网络连接失败，请重试"))
    end
    return false
end

function MailLayer:setMailInfo(item, mail)
    -- 标题
    local text_title
    if mail.template_key and mail.template_key ~= "" then
        local tmp_title = service.MailTemplates:GetTitle(mail.template_key)
        if tmp_title ~= nil and tmp_title ~= "" then
            text_title = TR(tmp_title)
        end
    end
    if not text_title then
        text_title = mail.title
    end

    -- 时间
    local time_ = string.format("%d/%d/%d",Int64ToDateTime(mail.create_time))
    -- 阅读标识
    local is_read = mail.is_read -- 1 是已读
    local Image_readed = item:getChildByName("Image_readed")
    local Image_new = item:getChildByName("Image_new")
    local type_text = item:getChildByName("Text_type")
    type_text:setString(TR("发件人:系统"))

    if is_read == 0 then
        Image_readed:setVisible(false)
        Image_new:setVisible(true)
    else
        Image_readed:setVisible(true)
        Image_new:setVisible(false)
    end

    local btn_read = item:getChildByName("item_btn")
    Tools.AddClickEvent(btn_read, function()
        go(function()
            if mail.is_read == 0 then
                local read = self:ReadMail(mail)
                if not read then return end

                Image_readed:setVisible(true)
                Image_new:setVisible(false)
            end

            local layer = PopLayer:Pop(service.MailDetailLayer)
            layer:SetDetailInfo(mail)
            PopLayer:SetTopMost(layer)
        end)
    end)

    item:getChildByName("Text_content"):setString(text_title)
    item:getChildByName("Text_time"):setString(time_)
end

function MailLayer:ReadMail(mail)
    local rlt_ = service.ServiceLogic:SendReadMail(mail.id, mail.type)
    if tolua.isnull(self) then return false end

    if rlt_ then
        mail.is_read = 1
        return true
    else
        UIManager.ShowToast(TR("网络连接失败，请重试"))
        return false
    end
end

------------------------------------------------------------

function MailLayer:ShowMails()
    go(function()
        if not self:GetMails() then return end

        self.mail_list:removeAllItems()
        local mails = self.mails
        for _,mail in ipairs(mails) do
            local new_item = self.item:clone()
            self:setMailInfo(new_item, mail)
            self.mail_list:pushBackCustomItem(new_item)
        end

        TR_Node(self.mail_list)
        self:setVisible(true)
    end)
end

function MailLayer:onNewMailEvent(onNewMail)
    self.on_new_mail = onNewMail
end

return MailLayer
