local ServiceLogic = class("ServiceLogic")

ServiceLogic.QUESTION = 116       -- 常见问题
ServiceLogic.SERVICE = 117        -- 在线客服
ServiceLogic.SUGGEST = 118        -- 提交建议
ServiceLogic.MAIL = 119           -- 邮件

function ServiceLogic:ctor()
    self.notices = {}           --邮件数据
    self.app_switch = 1         --what's app 开关
    self.appurl = ""            --玩家下载app 的 url
    self.showMsgs = {}          --弹出的公告

    self.openQuestion = UserData.buttonList[self.QUESTION] ~= 0
    self.openService = UserData.buttonList[self.SERVICE] ~= 0
    self.openSuggest = UserData.buttonList[self.SUGGEST] ~= 0
    self.openMail = UserData.buttonList[self.MAIL] ~= 0

    --注册服务器推送
    gNetHandlers_Register(PKG_Lobby_Client_GetNotices, "GNET_HALL_PKG_Lobby_Client_GetNotices", function(rlt_)
		--print("注册服务器推送")
        self:OnMailData(rlt_,true)-- 收到推送的公告数据 rlt_ : PKG_Lobby_Client_GetNotices
    end)
end

function ServiceLogic:OnMailData(rlt_,isPushed)
    if not rlt_ then
        return false
    end
    if getmetatable(rlt_) == PKG_Generic_Error then
        return false
    end
    if getmetatable(rlt_) == PKG_Lobby_Client_GetNotices then
        self.app_switch = rlt_.app_switch
        self.appurl = rlt_.appurl

        self.notices = {}
        local data_ = self:Data_Sort(rlt_.Notices)
        for __,notice_ in ipairs(data_) do
            table.insert(self.notices, notice_)
        end

        --数据改变, 直接使用 self
        Dispatcher:Dispatch(self)
		--显示全服公告
		self:ShowAllNotice()

        if ConfigParam.Region == "ind" then
            self:PopLastRecharge()
        end

        return true
    end
    return false
end

--显示充值消息
function ServiceLogic:PopLastRecharge()
    local notices = self.notices
    for _, notice_ in ipairs(notices) do
        if notice_.template_key == "mail_recharge_state_success"
            and notice_.is_read == 0            --未读
        then
            local layer = PopLayer:Pop(service.MailDetailLayer)
            layer:SetDetailInfo(notice_)
            PopLayer:SetTopMost(layer)

            go(function()
                local ret = self:SendReadMail(notice_.id, notice_.type)
                if ret then
                    notice_.is_read = 1 --设置为已读
                end
            end)
        end
    end
end

--显示全服公告
function ServiceLogic:ShowAllNotice()
    local notices = self.notices
    for _, notice_ in ipairs(notices) do
        if notice_.type == 1                    --公告
            and notice_.is_show == 1            --需要显示
            and notice_.is_read == 0            --未读
        then
            local isExist = false
            for _, id in ipairs(self.showMsgs) do
                if notice_.id == id  then
                    isExist = true
                end
            end
            if not isExist then
                local layer = PopLayer:Pop(MsgBoxLayer)
                layer:ShowMsgBox(
                    notice_.content,
                    function()  -- onok
                        go(function()
                            local ret = self:SendReadMail(notice_.id, notice_.type)
                            if ret then
                                notice_.is_read = 1 --设置为已读
                            end
                            local index
                            for i, id in ipairs(self.showMsgs) do
                                if notice_.id == id  then
                                    index = i
                                end
                            end
                            if index then
                                table.remove(self.showMsgs,index)
                            end
                        end)
                    end
                )
                table.insert(self.showMsgs,notice_.id)
            end
        end
    end
end

--发送读取邮件
function ServiceLogic:SendReadMail(id_, type_)
	local data_ = PKG_Client_Lobby_ChangeReadState.Create()
	data_.id = id_
    data_.type = type_
    UIManager.ShowWaiting()
    local rlt_ = gNet_SendRequest(data_)
    UIManager.HideWaiting()
    if rlt_ == nil then
        return false
    end
    if getmetatable(rlt_) == PKG_Generic_Success then
        for _, notice in ipairs(self.notices) do
            if notice.id == id_ then
                notice.is_read = 1
            end
        end
        self:Data_Sort(self.notices)
        Dispatcher:Dispatch(self)
        return true
    elseif getmetatable(rlt_) == PKG_Generic_Error then
        return false
    end
end

--检查是否有未读消息
function ServiceLogic:CheckUnRead()
    for _, notice in ipairs(self.notices) do
        if notice.is_read == 0 then
            return true
        end
    end
    return false
end

--主动获取所有的邮件
function ServiceLogic:RequestMails()
    go(function()
        local data_ = PKG_Client_Lobby_GetNotice.Create()
        local rlt_ = GetCachedResponse(data_)
        if not rlt_ then
            UIManager.ShowWaiting()
            rlt_ = gNet_SendRequest(data_)
            UIManager.HideWaiting()
        end

        if getmetatable(rlt_) == PKG_Lobby_Client_GetNotices then
            AddCachedResponse(data_, rlt_, 15)
        end

        self:OnMailData(rlt_)
    end)
end

--数据排序
function ServiceLogic:Data_Sort(Data_)
	if (Data_ ~= nil) then
		local newlist = {}
		for i = 1,#Data_ do
			if Data_[i].is_read == 0 then
				table.insert(newlist,Data_[i])
			end
		end
		for i = 1,#Data_ do
			if Data_[i].is_read == 1 then
				table.insert(newlist,Data_[i])
			end
		end
		return newlist
	end
end

function ServiceLogic:GetNotices()
    return self.notices
end

function ServiceLogic:UpdateWithButtonList(buttonList)
    self.buttonList = buttonList
    self.openQuestion = buttonList[self.QUESTION] ~= 0
    self.openService = buttonList[self.SERVICE] ~= 0
    self.openSuggest = buttonList[self.SUGGEST] ~= 0
    self.openMail = buttonList[self.MAIL] ~= 0
end

function ServiceLogic:IsOpenQuestion()
    return self.openQuestion
end

function ServiceLogic:IsOpenService()
    return self.openService
end

function ServiceLogic:IsOpenSuggest()
    return self.openSuggest
end

function ServiceLogic:IsOpenMail()
    return self.openMail
end

return ServiceLogic
