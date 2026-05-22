local ServiceMailLayer = class("ServiceMailLayer", function()
    return Tools.CreateLayer("csb/serviceMail/ServiceMailLayer.csb")
end)

function ServiceMailLayer:ctor()
    self.type = nil

    self:InitUI()
end

function ServiceMailLayer:InitUI()
    local Panel_bg = self:getChildByName("Panel_bg")
    self.Panel_bg = Panel_bg

	local btn_close = Panel_bg:getChildByName("Button_close")
	Tools.AddClickEvent(btn_close, function()
        self:Close()
	end, true)

	self.Image_left = Panel_bg:getChildByName("Image_left")

    local cfgs = {}
    -- QUESTION
    table.insert(cfgs, {
        type = service.ServiceLogic.QUESTION,
        btn_name = "_lang_Button_question",
        btn = nil,
        panel_class = service.QuestionLayer,
        panel_name = "Panel_question",
        panel = nil,
        tip = nil,
        check_condition = function()
            return service.ServiceLogic:IsOpenQuestion()
        end,
        on_show = function(type, btn, panel)
            panel:showQuestions()
            panel:onServiceClickedEvent(function()
                self:ShowType(service.ServiceLogic.SERVICE)
            end)
        end,
        check_tips = function(btn, panel)
            return false
        end
    })

    -- SERVICE
    table.insert(cfgs, {
        type = service.ServiceLogic.SERVICE,
        btn_name = "_lang_Button_service",
        btn = nil,
        panel_class = service.ServiceLayer,
        panel_name = "Panel_service",
        panel = nil,
        tip = nil,
        check_condition = function()
            return service.ServiceLogic:IsOpenService()
        end,
        on_show = function(type, btn, panel)
            cc.UserDefault:getInstance():setBoolForKey("ServiceTips", false) 
            UserData.ServiceTips = false
            self:ShowTips(type, false)
        end,
        check_tips = function(btn, panel)
            return UserData.ServiceTips
        end
    })

    -- SUGGEST
    table.insert(cfgs, {
        type = service.ServiceLogic.SUGGEST,
        btn_name = "_lang_Button_suggest",
        btn = nil,
        panel_class = service.SugguestLayer,
        panel_name = "Panel_suggest",
        panel = nil,
        tip = nil,
        check_condition = function()
            return service.ServiceLogic:IsOpenSuggest()
        end,
        on_show = function(type, btn, panel)
            panel:onServiceClickedEvent(function()
                self:ShowType(service.ServiceLogic.SERVICE)
            end)
        end,
        check_tips = function(btn, panel)
            return false
        end
    })

    -- MAIL
    table.insert(cfgs, {
        type = service.ServiceLogic.MAIL,
        btn_name = "_lang_Button_Mail",
        btn = nil,
        panel_class = service.MailLayer,
        panel_name = "Panel_mail",
        panel = nil,
        tip = nil,
        check_condition = function()
            return service.ServiceLogic:IsOpenMail()
        end,
        on_show = function(type, btn, panel)
            panel:onNewMailEvent(function()
                self:ShowTips(type, service.ServiceLogic:CheckUnRead())
            end)
            panel:ShowMails()
        end,
        check_tips = function(btn, panel)
            return service.ServiceLogic:CheckUnRead()
        end
    })

    self.cfgs = cfgs

    self:InitButtons()
    self:InitPanels()
    self:CheckConditions()
    self:CheckTips()

    local cfg = self.cfgs[1]
    if cfg and cfg.type then
        self:ShowType(cfg.type)
    end
end

-- 初始化按钮
function ServiceMailLayer:InitButtons()
    local left = self.Image_left
    local cfgs = self.cfgs
    for _,cfg in ipairs(cfgs) do
        local btn_name = cfg.btn_name
        local btn = left:getChildByName(btn_name)
        cfg.btn = btn

        if btn then
            cfg.tip = btn:getChildByName("icon_tip")
        end

        if btn then
            Tools.AddClickEvent(btn, function()
                if self.type ~= cfg.type then
                    self:ShowType(cfg.type)
                end
            end)
            self:ShowTips(cfg.type, false)
        end
    end
end

-- 初始化面板
function ServiceMailLayer:InitPanels()
    local right = self.Panel_bg

    local cfgs = self.cfgs
    for _,cfg in ipairs(cfgs) do
        local panel = right:getChildByName(cfg.panel_name)
        if panel then
            panel:setVisible(false)
            local Class = cfg.panel_class
            cfg.panel = Class:create(panel)
        end
    end
end

function ServiceMailLayer:CheckConditions()
    local left = self.Image_left

    local newcfgs = {}
    local cfgs = self.cfgs
    for _, cfg in ipairs(cfgs) do
        local opened = false
        if cfg.check_condition and cfg.check_condition() then
            opened = true
        end

        local btn = cfg.btn
        if not opened then
            if btn then
                local index = left:getIndex(btn)
                left:removeItem(index)
            end
        else
            table.insert(newcfgs, cfg)
        end
    end

    self.cfgs = newcfgs
end

function ServiceMailLayer:CheckTips()
    local cfgs = self.cfgs

    for _, cfg in ipairs(cfgs) do
        local bshow = false
        if cfg.check_tips and cfg.check_tips(cfg.btn, cfg.panel) then
            bshow = true
        end
        self:ShowTips(cfg.type, bshow)
    end
end

function ServiceMailLayer:ShowType(type)
    local cfgs = self.cfgs
    for _,cfg in ipairs(cfgs) do
        local btn = cfg.btn
        local label = nil
        if btn then
            label = btn:getTitleLabel()
        end
        local panel = cfg.panel

        if type == cfg.type then        -- 选中
            if label then
                label:setTextColor(cc.c3b(0, 0, 0))
            end
            if btn then
                btn:setTouchEnabled(false)
                btn:setEnabled(false)
            end
            if panel then
                panel:setVisible(true)
            end
            if type and btn and panel and cfg.on_show then
                cfg.on_show(type, btn, panel)
            end
        else                            -- 未选中
            if label then
                label:setTextColor(cc.c3b(255, 255, 0))
            end
            if btn then
                btn:setTouchEnabled(true)
                btn:setEnabled(true)
            end
            if panel then
                panel:setVisible(false)
            end
        end
    end
end

function ServiceMailLayer:GetCfgByType(type)
    local cfgs = self.cfgs
    for _,cfg in ipairs(cfgs) do
        if cfg.type == type then
            return cfg
        end
    end
    return nil
end

function ServiceMailLayer:ShowTips(type, bShow)
    local cfg = self:GetCfgByType(type)
    if cfg and cfg.tip then
        cfg.tip:setVisible(bShow)
    end
end

function ServiceMailLayer:receMsg(pkg)
    local type = service.ServiceLogic.SERVICE
    self:ShowType(type)

    local cfg = self:GetCfgByType(type)
    if cfg and cfg.panel then
        cfg.panel:receMsg(pkg)
    end
end

return ServiceMailLayer
