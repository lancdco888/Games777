local Notice = class("Notice", function()
    return Tools.CreateNode("csb/common/Notice.csb")
end)

function Notice:onEnter()
    self.width_layer = self:findChild("Panel_width")
    self.height_layer = self:findChild("Panel_height")
    self.width_bg = self.width_layer:findChild("bg")
    self.height_bg = self.height_layer:findChild("bg_1")
    self.width_list = self.width_layer:findChild("list")
    self.height_list = self.height_layer:findChild("list_1")
    self.width_list:setScrollBarEnabled(false)
    self.height_list:setScrollBarEnabled(false)
    self.width_list.pos = cc.p(self.width_list:getPosition())
    self.height_list.pos = cc.p(self.height_list:getPosition())
    --跑马灯适配
    local width_size = self.width_list:getContentSize()
    local height_size = self.height_list:getContentSize()
    self.width_list:setContentSize(width_size.width*Def.ScaleMin,width_size.height*Def.ScaleMin)
    self.height_list:setContentSize(height_size.width*Def.ScaleMin,height_size.height*Def.ScaleMin)

    --当前需要显示的跑马灯表
    self.nowshowlist = {}

    self:DelayCheck(2.0)
end

-----------------------------------------------------------
--渲染
function Notice:MakeNoticeList(notice_tbl)
    self.width_list:removeAllItems()
    self.height_list:removeAllItems()
    for _,notice in ipairs(notice_tbl) do
        local width_item = self:MakeNoticeItem(notice,"width")
        local height_item = self:MakeNoticeItem(notice,"height")
        if width_item then
            self.width_list:pushBackCustomItem(width_item)
        end
        if height_item then
            self.height_list:pushBackCustomItem(height_item)
        end
    end  
end

function Notice:MakeNoticeItem(notice,screen_type)
    local type = notice.type
    if type == "text" then
        return self:MakeText(notice)
    elseif type == "image" then
        return self:MakeImage(notice,screen_type)
    elseif type == "font" then
        return self:MakeFont(notice)
    else
        print("Notice:MakeNoticeItem failed.")
        return nil
    end
end

-- notice: color, content, size
function Notice:MakeText(notice)
    local content = notice.content or ""
    local size = notice.size or 20
    local color = notice.color or cc.c3b(255, 255, 255)
    local text =  ccui.Text:create(
        content or "",
        "Arial",
        size
    )
	text:setColor(color)
    text:setAnchorPoint(cc.p(0,0))
    return text
end

--notice: path
function Notice:MakeImage(notice,screen_type)
    local path = notice.path or "common/dollar.png"
    local image = ccui.ImageView:create(path)
    local height = 0
    if screen_type == "height" then
        height = self.height_list:getContentSize().height
    else
        height = self.width_list:getContentSize().height
    end
    local size = image:getVirtualRendererSize()
    image:setScale(height/size.height)
    return image
end

--notice: fnt, content
function Notice:MakeFont(notice)
    local fnt = notice.fnt or "common/coin_fnt.fnt"
    local content = notice.content or ""
    local font = ccui.TextBMFont:create(content, fnt)
    return font
end

-----------------------------------------------------------
--运动控制
function Notice:EnterAction(layer,list,bool_)
    layer:stopAllActions()
    --
    local toScale = Def.ScaleMin
    local startScale = 0.1 * toScale
    --原跑马灯处理竖屏有问题, 不改其他地方的话只能改这里
    if self.screen_type == "height" then
        local width, height = 720, 1280
        local vsize = cc.Director:getInstance():getVisibleSize()
        local scale = math.min(vsize.width / width, vsize.height / height)
        toScale = 1.2 * scale
        startScale = 0.1 * toScale
    end
    --
    layer:setScale(toScale, startScale)
    layer:setOpacity(0)
    local width_action = cc.Sequence:create(
        cc.FadeIn:create(0.1),
        cc.ScaleTo:create(0.1, toScale),
        cc.CallFunc:create(
            function()
                self:StartRunning(layer,list,bool_)
            end
        )
    )
    self:MoveToRight(list)
    layer:runAction(width_action)
end

function Notice:MoveToRight(list)
    local width_pos = list.pos
    list:setPosition(width_pos)
    --将坐标设置到最右边
    local width_size = list:getContentSize()
    local width_right = cc.p(width_size.width, width_size.height/2.0)
    width_right = list:convertToWorldSpace(width_right)
    width_pos = list:getParent():convertToNodeSpace(width_right)
    list:setPosition(width_pos)
end

function Notice:StartRunning(layer,list,bool_)
    list:stopAllActions()
    local width_w = 0
    if bool_ then
        width_w = self:CalcWidth_Width()
    else
        width_w = self:CalcWidth_Height()
    end
    local width_duaration = width_w / 100
    list:runAction(
        cc.Sequence:create(
            cc.MoveBy:create(width_duaration, cc.p(-width_w, 0)),
            cc.CallFunc:create(function() 
                local action = cc.Sequence:create(
                cc.Spawn:create(
                    cc.FadeOut:create(0.2),
                    cc.ScaleTo:create(0.2, 1, 0.1),
                    cc.CallFunc:create(function()
                        if bool_ then
                            self:setVisible_("width",false)
                        else
                            self:setVisible_("height",false)
                        end
                        self:DelayCheck(5.0)
                    end)))
                layer:runAction(action)
          end)))
end

--横屏跑马灯宽计算用
function Notice:CalcWidth_Width()
    local items = self.width_list:getItems()
    local w = 0
    for _,item in ipairs(items) do
        w = w + item:getContentSize().width * item:getScale()
    end
    return w + self.width_list:getContentSize().width + 20
end

--竖屏跑马灯宽计算用
function Notice:CalcWidth_Height()
    local items = self.height_list:getItems()
    local w = 0
    for _,item in ipairs(items) do
        w = w + item:getContentSize().width * item:getScale()
    end
    return w + self.height_list:getContentSize().width + 20
end

-----------------------------------------------------------
function Notice:MakeNoticeByTemplate(data_, msg)
    --先分割成序列
    local tokens = self:Split(msg)
    local list = {}
    for _,t in ipairs(tokens) do
        if t == "[vip]" then
            local item = {}
            item.type = "text"
            item.color = cc.c3b(255, 255, 255)
            item.content = ""
            table.insert(list, item)
            -- local item = {}
            -- item.type = "image"
            -- item.path = "hall/res/common/notice_vip.png"
            -- table.insert(list, item)
            -- local item2 = {}
            -- item2.type = "font"
            -- item2.fnt = "hall/res/common/vip_fnt.fnt"
            -- local vip_num = 0
            -- if data_.total_recharge then
            --     vip_num = data_.total_recharge
            -- end
            -- if data_.totalRecharge then
            --     vip_num = data_.totalRecharge
            -- end
            -- item2.content = tostring(sGameManager.GetVip(vip_num))
            -- table.insert(list, item2)
        elseif t == "[name]" then
            local item = {}
            item.type = "text"
            item.color = cc.c3b(255, 0, 0)
            item.content = data_.nickName
            table.insert(list, item)
        elseif t == "[bet]" then
            local item = {}
            item.type = "font"
            item.fnt = "hall/res/common/coin_fnt.fnt"
            item.content = Tools.CoinToShowString(data_.bet)
            table.insert(list, item)
        elseif t == "[gameId]" then
            local idx = nil
            if data_.game_id then
                idx = data_.game_id
            end
            if data_.gameId then
                idx = data_.gameId
            end
            local cfg = const_game.Param[idx]
            if cfg then
                local item = {}
                item.type = "text"
                item.color = cc.c3b(255, 0, 0)
                item.content = TR(cfg[const_game.Game_Name])
                table.insert(list, item)
            end
        elseif t == "[fish]" then
            local item = {}
            item.type = "text"
            item.color = cc.c3b(255, 0, 0)
            item.content = self:getFishNameById(data_.fish_id)
            table.insert(list, item)
        elseif t == "[coin]" then
            local item = {}
            item.type = "font"
            item.fnt = "hall/res/common/coin_fnt.fnt"
            item.content = Tools.CoinToShowString(data_.coin)
            table.insert(list, item)
        elseif t == "[winMoney]" then
            local item = {}
            item.type = "font"
            item.fnt = "hall/res/common/coin_fnt.fnt"
            item.content = Tools.CoinToShowString(data_.winMoney)
            table.insert(list, item)
        else
            --普通文本
            local item = {}
            item.type = "text"
            item.color = cc.c3b(255, 255, 255)
            item.content = t
            table.insert(list, item)
        end
    end
    return list
end

-- 将 abc[de]fg[hi]分割成 :abc, [de], fg, [hi]
function Notice:Split(str)
    local ret = {}
    while true do
        local i,j,s = string.find(str, "(%[.-%])")
        if i then
            if i > 1 then
                table.insert(ret, string.sub(str, 1, i-1))
            end
            table.insert(ret, s)
            str = string.sub(str, j+1, -1)
        else
            table.insert(ret, str)
            break
        end
    end
    return ret
end

-----------------------------------------------------------
-- 延时一段时间检查 跑马灯, 空闲时调用
function Notice:DelayCheck(sec)
    if sec < 0 then
        sec = 0.1
    end
    local action = cc.Sequence:create(
        cc.DelayTime:create(sec),
        cc.CallFunc:create(
            function()
                self:CheckMarquee()
            end))
    if self.screen_type == "height" then
        self.height_layer:runAction(action)
    else
        self.width_layer:runAction(action)
    end
end

function Notice:CheckMarquee()
    local data_ = MarqueeLogic:GetMarquee()
    if not data_ then
        if self.entry ~= nil then
            self.scheduler:unscheduleScriptEntry(self.entry)
            self.entry = nil
        end
        self:DelayCheck(2.0)
        return
    end
    if data_.Marquees_type == "Fish" then
        local fish_name = self:getFishNameById(data_.Marquees.fish_id)
        if not fish_name then
            print("未获取到鱼的名字，忽略此条跑马灯.")
            return
        end

        --组合,一定程度上可以照顾翻译提取 与 可读性
        local template = TR("恭喜[vip][name]使用[bet]倍炮在[gameId]中击杀[fish]获得[coin]金币!")
        local list = self:MakeNoticeByTemplate(data_.Marquees, template)
        self:MakeNoticeList(list)
        if self.screen_type == "width" then
            self:EnterAction(self.width_layer,self.width_list,true)
        else
            self:EnterAction(self.height_layer,self.height_list,false)
        end
        self:setVisible_(self.screen_type,true)
    elseif data_.Marquees_type == "GM" then
        local list = self:MakeNoticeByTemplate(data_.Marquees, data_.Marquees.content)
        self:MakeNoticeList(list)
        if self.screen_type == "width" then
            self:EnterAction(self.width_layer,self.width_list,true)
        else
            self:EnterAction(self.height_layer,self.height_list,false)
        end
        self:setVisible_(self.screen_type,true)
    elseif data_.Marquees_type == "Slots" then
        local template = TR("恭喜[vip][name]在[gameId]中赢得[winMoney]金币!")
        local list = self:MakeNoticeByTemplate(data_.Marquees, template)
        self:MakeNoticeList(list)
        if self.screen_type == "width" then
            self:EnterAction(self.width_layer,self.width_list,true)
        else
            self:EnterAction(self.height_layer,self.height_list,false)
        end
        self:setVisible_(self.screen_type,true)
    else
        print("unknown marquee message!")
    end
end

function Notice:getFishNameById(fish_id)
    local status,cs = pcall(require, "script.config.fish_info_hw")
    if status then
        for k,info in pairs(cs) do
            if info.typeId == fish_id then
                return info.name
            end
        end
    end
    local status,hw = pcall(require, "script.config.fish_info_cs")
    if status then
        for k,info in pairs(hw) do
            if info.typeId == fish_id then
                return info.name
            end
        end
    end
    return nil
end

function Notice:setVisible_(screen_type,bool_)
    if screen_type == nil then
        self.width_layer:setVisible(bool_)
        self.height_layer:setVisible(bool_)
    elseif screen_type == "height" then
        self.height_layer:setVisible(bool_)
    elseif screen_type == "width" then
        self.width_layer:setVisible(bool_)
    end
end

function Notice:SetNoticeType(screen_type)
    self.screen_type = screen_type
end

return Notice
