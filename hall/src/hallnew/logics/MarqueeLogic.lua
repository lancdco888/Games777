-- 跑马灯 相关逻辑处理
local MarqueeLogic = class("MarqueeLogic")

function MarqueeLogic:ctor()
    self.queue = {}             --消息队列
    self.GMList = {}            --大厅公告表
    self.notice = nil
    self.notice_isshow = -1     --切场或横竖屏转换时使用

    local notice_setted = cc.UserDefault:getInstance():getBoolForKey("notice_setted", false)
    if not notice_setted then
        cc.UserDefault:getInstance():setBoolForKey("notice_setted", true)
        -- 跑马灯默认显示
        cc.UserDefault:getInstance():setBoolForKey(Def.IsNoticeShow, true)
    end

    --主节点显示设置
    if cc.UserDefault:getInstance():getBoolForKey(Def.IsNoticeShow, true) then
        self.notice_master_isshow = false
    else
        self.notice_master_isshow = true
    end
    self:Init()
end

function MarqueeLogic:Init()
    self.notice = self:MakeNotice()
    self.changenode = self.notice:findChild("notice")
    self:HideNotice_Node()
    self:HideNotice()
    self.notice:SetNoticeType("width")

    gNetHandlers_Register(
        PKG_Lobby_Client_Marquee_CatchFishMarquees,
        "GNET_HALL_LobbyCatchFishMarquees", 
        function(data_)
            self:OnMarquees(data_)
        end
    )
    gNetHandlers_Register(
        PKG_Lobby_Client_Marquee_GetGMMarquees,
        "GNET_HALL_LobbyGMMarquees", 
        function(data_)
            self:OnMarquees(data_)
        end
    )
    gNetHandlers_Register(
        PKG_Slots_Lobby_SlotsMarquee,
        "GNET_HALL_LobbySlotMarquees", 
        function(data_)
            self:OnMarquees(data_)
        end
    )
end

--跑马灯消息入口 对消息统一处理,然后根据内容进行不同展示
--游戏跑马灯为一条一条的，大厅公告为数组
function MarqueeLogic:OnMarquees(data_)
    self:Sort(data_)
    --队列最大条数
    local MAX_LEN = 100
    local queue = self.queue
    local len = #queue
    
    for i = MAX_LEN,len-1 do      --溢出时 删除队列头部的消息
        table.remove(queue, 1)
    end
    
    if self.notice then
        if self.notice_isshow == 0 then
            if not self.changenode:isVisible() then
                self:ShowNotice_Node()
            end
        end
    end
end

--整理队列
function MarqueeLogic:Sort(data_)
    local PKG_name = getmetatable(data_)
    if PKG_name == PKG_Lobby_Client_Marquee_CatchFishMarquees then
        if #self.queue ~= 0 then
            for i = 1, #self.queue do
                if self.queue[i].Marquees_type == "GM" then
                    if i + 1 <= #self.queue then
                        if self.queue[i + 1].Marquees_type == "GM" then
                            local temp = {}
                            temp.Marquees_type = "Fish"
                            temp.Marquees = data_
                            table.insert(self.queue,i + 1,temp)
                            return
                        end
                    end
                end
            end
        end
        local temp = {}
        temp.Marquees_type = "Fish"
        temp.Marquees = data_
        table.insert(self.queue, temp)
    elseif PKG_name == PKG_Lobby_Client_Marquee_GetGMMarquees then
        local notice = {}
        notice = data_.marquees
        local notice_len = #notice
        --没有跑马灯时
        if #self.queue == 0 then
            self.GMList = notice
            for i = 1, notice_len do
                local temp = {}
                temp.Marquees_type = "GM"
                temp.Marquees = notice[i]
                table.insert(self.queue,temp)
            end
            return
        end
        --是否有改变
        local change = false
        if #self.GMList == notice_len then
            for i = 1,#self.GMList do
                if self.GMList[i].content ~= notice[i].content then
                    change = true
                    break
                end
            end
        end
        --有跑马灯时
        if notice_len ~= #self.GMList then
            self.GMList = notice
        else
            for i = 1,notice_len do
                if (self.GMList[i].content ~= notice[i].content) then
                    self.GMList = notice
                    break
                end
            end
        end
        if #self.GMList == 0 then
            return
        end
        local id = 1
        local len = #self.queue
        local bool_HaveGM = false
        --是否含有大厅公告
        for i = 1, len do
            if self.queue[i].Marquees_type == "GM" then
                bool_HaveGM = true
                break
            end
        end

        --有大厅公告
        if bool_HaveGM then
            --但是没有修改
            if not change then
                return
            end
            for i = 1, len do
                if self.queue[i].Marquees_type == "GM" then
                    if id > #self.GMList then
                        id = 1
                    end
                    self.queue[i].Marquees = self.GMList[id]
                    id = id + 1
                end
            end
            if len < #self.GMList then
                for i = id, #self.GMList do
                    local temp = {}
                    temp.Marquees_type = "GM"
                    temp.Marquees = self.GMList[id]
                    table.insert(self.queue,temp)
                end
            end
        else
        --没有大厅公告
            for i = 1, len do
                if id > #self.GMList then
                    id = 1
                end
                local temp = {}
                temp.Marquees_type = "GM"
                temp.Marquees = self.GMList[id]
                table.insert(self.queue,i * 2 - 1,temp)
                id = id + 1
            end
            if len < #self.GMList then
                for i = id, #self.GMList do
                    local temp = {}
                    temp.Marquees_type = "GM"
                    temp.Marquees = self.GMList[id]
                    table.insert(self.queue,temp)
                end
            end
        end
    elseif PKG_name == PKG_Slots_Lobby_SlotsMarquee then
        if #self.queue ~= 0 then
            for i = 1, #self.queue do
                if self.queue[i].Marquees_type == "GM" then
                    if i + 1 <= #self.queue then
                        if self.queue[i + 1].Marquees_type == "GM" then
                            local temp = {}
                            temp.Marquees_type = "Slots"
                            temp.Marquees = data_
                            table.insert(self.queue,i + 1,temp)
                            return
                        end
                    end
                end
            end
        end
        local temp = {}
        temp.Marquees_type = "Slots"
        temp.Marquees = data_
        table.insert(self.queue, temp)
    end
end

function MarqueeLogic:MakeNotice()
    local Notice = require("hall.src.hallnew.layers.common.Notice")
    local notice = Notice.new()
    local size = Def.visibleSize
    if self.pos == nil then
        notice:setPosition(cc.p(size.width*0.5, size.height*0.85))
    else
        notice:setPosition(self.pos)
    end
    local ishow = cc.UserDefault:getInstance():getBoolForKey(Def.IsNoticeShow,true)
    self.notice_master_isshow = ishow 
    notice:setVisible(self.notice_master_isshow)
    notice:setTag(100000)
    notice:setLocalZOrder(2)
    gScene:addChild(notice)
    return notice
end

--取出一条队列头的消息
function MarqueeLogic:GetMarquee()
    local data_ = self.queue[1]
    table.remove(self.queue, 1)
    return data_
end

--隐藏跑马灯(横竖屏节点)
function MarqueeLogic:HideNotice(screen_type)
    if self.notice then
         self.notice:setVisible_(screen_type,false)
    end
end

--隐藏跑马灯(显示层节点)
function MarqueeLogic:HideNotice_Node()
    self.notice_isshow = 1
    if self.notice then
        self.changenode:setVisible(false)
        self.notice:setVisible_(nil,false)
    end
end

--显示跑马灯(横竖屏节点)
function MarqueeLogic:ShowNotice(screen_type)
    if self.notice then
        self.notice:setVisible_(screen_type,true)
    end
end

--显示跑马灯(显示层节点)
function MarqueeLogic:ShowNotice_Node()
    self.notice_isshow = 0
    if self.notice then
        self.changenode:setVisible(true)
    end
end

--设置跑马灯类型
function MarqueeLogic:SetNoticeType(screen_type)
    self.NoticeType = screen_type
    if self.notice ~= nil then
        self.notice:SetNoticeType(self.NoticeType)
    end
end

--重设置跑马灯位置
function MarqueeLogic:SetNoticePos(posx,posy)
    if posx == nil then
        local size = Def.visibleSize
        self.pos = cc.p(size.width*0.5, size.height*0.85)
    else
        self.pos = cc.p(posx,posy)
    end
    if self.notice ~= nil then
        self.notice:setPosition(self.pos)
    end
end

function MarqueeLogic:SetVisible_(bool_)
    self.notice_master_isshow = bool_
    if self.notice ~= nil then
        self.notice:setVisible(bool_)
    end
end

function MarqueeLogic:GetIsNeedShow()
    local is_ = cc.UserDefault:getInstance():getBoolForKey(Def.IsNoticeShow,true)
    return is_
end

return MarqueeLogic
