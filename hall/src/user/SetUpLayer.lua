local LangCombo = require("packagelua.src.login.LangCombo")

local SetUpLayer = class("SetUpLayer", function()
	return Tools.CreateLayer("csb/lobby/SetUpLayer.csb")
end)

function SetUpLayer:onEnter()
	self:InitUI()
end

function SetUpLayer:InitUI()
	self.bShowLang = true

	self:InitPanel()
	self:InitLangCombo()
	self:InitOption()	--音乐 音效 效果 滚动报喜（跑马灯）开关

	self:InitVersionInfo()
	self:InitTest()

	self:ShowLangSelect(self.bShowLang)
end

function SetUpLayer:ShowLangSelect(bShow)
	if #ConfigParam.Language <= 1 then
		bShow = false
	end

    local node = self:findChild("LangCombo")
	if node then
		node:setVisible(bShow)
	end
	self.bShowLang = bShow

	-- 这个适配与所在皮肤的弹框有关
	if self.opsNode then
		local y
		if not self.bShowLang then
			y = 45
		else
			y = 0
		end
		self.opsNode:setPositionY(y)
	end
end

function SetUpLayer:InitLangCombo()
    local node = self:findChild("LangCombo")

	self.lang_combo = LangCombo:new()
	self.lang_combo:InitNode(node)

	self.lang_combo.OnLangChanged = function()
		self:OnLangIdSelect()
	end
end

function SetUpLayer:InitTest()
	local info = self:findChild("info")
	local cnt = 0
	Tools.AddClickEvent(info, function()
		cnt = cnt + 1
		if cnt >= 8 then
			cc.Director:getInstance():setDisplayStats(true)
		end
	end)

	local btn_test = self:findChild("btn_test")
	if btn_test then
		btn_test:setVisible(false)
	end
end

function SetUpLayer:InitVersionInfo()
    local label = self:findChild("info")
    if label then
        local info = hotfixJson:GetLocalInfosByModule("hall")
        local showtext = "VERSION"
        if info and info.version then
            showtext = "v" .. info.version
        end
		
        label:setString(showtext)
    end
end

function SetUpLayer:InitPanel()
	local btn_close = self:findChild("btn_close")
	Tools.AddClickEvent(btn_close, function()
		self:Close()
	end, true)
end

function SetUpLayer:OnLangIdSelect()
	--重新加载资源
	package.loaded["hall.src.common.Def"] = nil
	require "hall.src.common.Def"
	
	--重新加载搜索路径
	--其他语言加载方式
	--等待界面所需要的路径
	local langName = GetLang()
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
	
	--关闭个人中心
	PopLayer:Close(SelfInfoLayer)
	if self and self.Close then
		self:Close()
	else
		print("出错了~~~")
	end
	
	-- 切换翻译文件
	ResetTranslator()
	
	TR_Node(cc.Director:getInstance():getRunningScene())
end

--------------------------------------------------------------------------
-- 开关
function SetUpLayer:InitOption()
	self.options = {}

	self.opsNode = self:findChild("ops")

	self:InitOp("music")
	self:InitOp("sound")
	self:InitOp("effect")
	self:InitOp("notice")

	self:InitWithUserDefault()
end

function SetUpLayer:InitOp(name)
	local op = self:getChild("ops/" .. name .. "/check")
	self.options[name] = op
	op:onEvent(function(event)
		self:SaveUserDefault()
		self:SyncOnOffImage(op)
	end)
end

function SetUpLayer:SyncOnOffImage(op)
	local on = op:isSelected()
	local on_label = op:getParent():getChildByName("on")
	on_label:setVisible(on)
	local off_label = op:getParent():getChildByName("off")
	off_label:setVisible(not on)
end

function SetUpLayer:SetOp(name, bOn)
	local op = self.options[name]
	op:setSelected(bOn)
	self:SyncOnOffImage(op)
end

function SetUpLayer:GetOp(name)
	local op = self.options[name]
	return op:isSelected()
end

function SetUpLayer:InitWithUserDefault()
	local isMusic = gSound.isMusicOn()
	self:SetOp("music", isMusic)
	local isSoundEffect = gSound.isEffectOn()
	self:SetOp("sound", isSoundEffect)

	local special = cc.UserDefault:getInstance():getIntegerForKey(Def.SpeciaSwitch)
	if special == 0 then special = 1 end
	if special == 1 then
		special = true
	else
		special = false
	end
	self:SetOp("effect", special)

	--滚动报喜（跑马灯）
	local isNotice = MarqueeLogic:GetIsNeedShow()
	self:SetOp("notice", isNotice)
end

function SetUpLayer:SaveUserDefault()
	--音乐
	local bMusicOn = self:GetOp("music")
	gSound.setMusicOn(bMusicOn)

	--音效
	local bSoundOn = self:GetOp("sound")
	gSound.setEffectOn(bSoundOn)

	--特效
	local bEffectOn = self:GetOp("effect")

	--滚动报喜（跑马灯）
	local noticeOn = self:GetOp("notice")
	MarqueeLogic:SetVisible_(noticeOn)
	sGameManager.SaveSetUp(
		bEffectOn,
		noticeOn
	)
end

return SetUpLayer
