
local LanguageLayer = class("LanguageLayer", 
    function()
        return Tools_Base.CreateLayer("packagelua/res/studio/csb/LanguageLayer.csb")
    end)

function LanguageLayer:onEnter()
    self:InitUI()
    self:AdjustUI()

    self:UpdateList()
    dump(ConfigParam,"ConfigParam")
	self:SetSelLang(ConfigParam.Language[1])
	self:LanguageChange(ConfigParam.Language[1])
end

function LanguageLayer:onExit()
    self.ui_item:release()
end

function LanguageLayer:InitUI()
    local panel_ = self:getChildByName("panel")
    self.ui_list = panel_:getChildByName("list")
    self.ui_item = self.ui_list:getChildByName("item")
    self.ui_item:retain()
    self.ui_list:removeAllItems()
    local btn_ok = panel_:getChildByName("_lang_btn_ok")
    Tools_Base.AddClickEvent(btn_ok, function()
        self:OnBtnOkClick()
    end, true)
end

--适配
function LanguageLayer:AdjustUI()
    --背景 铺满
    local bg = self:getChildByName("bg")
    bg:setScale(Tools_Base.ScaleMax)
    local center = cc.p(Tools_Base.visibleSize.width/2.0, Tools_Base.visibleSize.height/2.0)
    bg:setPosition(center)
    --面板尽量放大居中
    local panel = self:getChildByName("panel")
    panel:setScale(Tools_Base.ScaleMin)
    panel:setPosition(center)
end

function LanguageLayer:SetItemInfo(item, langName)
    local ui_check = item:getChildByName("check")
    ui_check:setSelected(false)
    ui_check:onEvent(function(event)
        if event.name == "selected" then
            self:SetSelLang(langName)
			self:LanguageChange(langName)
        else
            ui_check:setSelected(true)
        end
    end)
    local ui_text = item:getChildByName("text")
    ui_text:setString(const_def.LangList[langName] or "简体中文")
    item.lang = langName        --语言对应名字
    item.ui_check = ui_check
end

function LanguageLayer:SetLangList(langs)
    self.ui_list:removeAllItems()
    for _,lang in ipairs(langs) do
        local new_item = self.ui_item:clone()
        self:SetItemInfo(new_item, lang)
        self.ui_list:pushBackCustomItem(new_item)
    end
end

function LanguageLayer:UpdateList()
	self:SetLangList(ConfigParam.Language)
end

function LanguageLayer:SetSelLang(lang)
    local items = self.ui_list:getItems()
    for _,item in ipairs(items) do
        item.ui_check:setSelected(item.lang == lang)
    end
end

function LanguageLayer:GetSelLang()
    local items = self.ui_list:getItems()
    for _,item in ipairs(items) do
        if item.ui_check:isSelected() then
            return item.lang
        end
    end
    return "en"
end

function LanguageLayer:GetSelLangId()
    local lang = self:GetSelLang()
    for _,info in ipairs(Tools_Base.Languages) do
        if info.name == lang then
            return info.id
        end 
    end
    return 1
end

function LanguageLayer:SetDoneCbk(cbk)
    self.cbk = cbk
end

function LanguageLayer:OnBtnOkClick()
    if self.cbk then
        self.cbk()
    end
end

--刷新语言
function LanguageLayer:LanguageChange(langName)
    SettingData.language = Tools_Base.Name2Id(langName)
    cc.UserDefault:getInstance():setIntegerForKey("language", SettingData.language)
    local fileUtils = cc.FileUtils:getInstance()
    fileUtils:purgeCachedEntries()
    langName = langName == "cn" and "" or  langName .. "/"
    -- 大厅路径
	fileUtils:addSearchPath(const_def.DefaultPath .. "src/hall/res/" .. langName, true)
	fileUtils:addSearchPath(const_def.WritablePath .. "src/hall/res/" .. langName, true)
	fileUtils:addSearchPath(const_def.DefaultPath .. "src/hall/res/studio/" .. langName, true)
	fileUtils:addSearchPath(const_def.WritablePath .. "src/hall/res/studio/" .. langName, true)

	-- package路径
	fileUtils:addSearchPath(const_def.DefaultPath .. "src/packagelua/res/" .. langName, true)
	fileUtils:addSearchPath(const_def.WritablePath .. "src/packagelua/res/" .. langName, true)
	fileUtils:addSearchPath(const_def.DefaultPath .. "src/packagelua/res/studio/" .. langName, true)
	fileUtils:addSearchPath(const_def.WritablePath .. "src/packagelua/res/studio/" .. langName, true)
    if G_SetExchangeSearchPaths then
        G_SetExchangeSearchPaths()
    end
    SettingData:Dispatch()

    TR_Node(self)
end

return LanguageLayer
