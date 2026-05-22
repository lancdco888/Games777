local LangCombo = class("LangCombo")

function LangCombo:ctor()
    self.root = nil
end

function LangCombo:InitNode(node_)
    self.root = node_
    self:InitUI()
    self:UpdateLangList()
end

function LangCombo:InitUI()
    self.tips = self.root:findChild("tips")         -- @ i18n
    self.desc = self.root:findChild("desc")
    self.desc:setString(const_def.LangList[Tools_Base.Languages[SettingData.language].name] or "简体中文")
    self.lang_list = self.root:findChild("lang_list"):hide()
    self.lang_list_item = self.lang_list:findChild("item")
    self.lang_list_item:retain()
    self.lang_list:removeAllItems()

    local btn_down = self.root:findChild("btn_down")
    Tools_Base.AddClickEvent(btn_down, function()
        self:OnBtnDownClick()
    end, true)
end

function LangCombo:OnBtnDownClick()
    local lang_list = self.lang_list
    lang_list:setVisible(not lang_list:isVisible())
end

--更新下拉列表
function LangCombo:UpdateLangList()
	self.lang_list:removeAllItems()
	local langs = ConfigParam.Language
	for _,desc in ipairs(langs) do
		local new_item = self.lang_list_item:clone()
		self.lang_list:pushBackCustomItem(new_item)
        Tools_Base.AddClickEvent(new_item, function()
			self:OnLangSelect(desc)			
		end, true)
		local text = new_item:findChild("desc")
        text:setString(const_def.LangList[desc] or "简体中文")
	end
end

--name: cn, en
function LangCombo:OnLangSelect(name)
	self.lang_list:setVisible(false)	--隐藏语言列表
    self.desc:setString(const_def.LangList[name] or "简体中文")

    SettingData.language = Tools_Base.Name2Id(name)
    cc.UserDefault:getInstance():setIntegerForKey("language", SettingData.language)

    -- 给外部用的回调
    if self.OnLangChanged then
        self.OnLangChanged()
    end
end

return LangCombo
