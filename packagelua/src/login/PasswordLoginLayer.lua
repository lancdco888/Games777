local this = {}
this.stateGroupName = "PasswordLoginLayer"
this.stateName = "PasswordLoginLayer"
this.opened = false

function this.Open()
    this.run_layer = cc.Node:create()
    this.accDatas = LoginData.accDatas
	cc.Director:getInstance():getRunningScene():addChild(this.run_layer)
	this.Init()
    this.Adjust()
end

function this.Close()
    this.run_layer:removeFromParent()
    this.accDatas = nil
end

function this.Init()

	this.layer = cc.CSLoader:createNode("packagelua/res/studio/csb/PasswordLoginLayer.csb")
    this.layer:enableNodeEvents()
	TR_Node(this.layer)
	this.run_layer:addChild(this.layer)
	
	local popup = this.layer:getChildByName("popup")
	
	local btn_close = popup:getChildByName("btn_close")
    Tools_Base.AddClickEvent(btn_close, function()
		gSound.clickSound()
        this.OnBtnClose()
    end, true)
	
    local btn_login = popup:getChildByName("_lang_btn_login")
    Tools_Base.AddClickEvent(btn_login, function()
        this.OnBtnLogin(btn_login)
    end, true)
	this.btn_login = btn_login

    local btn_register = popup:getChildByName("_lang_btn_register")
    Tools_Base.AddClickEvent(btn_register, function()
        this.OnBtnRegister(btn_register)
    end, true)

	local btn_service = popup:findChild("btn_service")
    Tools_Base.AddClickEvent(btn_service, function()
        this.OnBtnService(btn_service)
    end, true)
	
    local ok = pcall(
		function()
	        ResetTranslator()
            return require("hall.src.hallnew.layers.lobby.ChatLayer")
        end
    )
	local node_forget_passwd = popup:findChild("node_forget_passwd")
    if not ok then
		node_forget_passwd:setVisible(false)
	else
		node_forget_passwd:setVisible(true)
	end

	local gou = popup:getChildByName("gou")
	if LoginData:GetIsSavePwd() then
		gou:setOpacity(255)
	else
		gou:setOpacity(0)
    end
	gou:addTouchEventListener(function(ref,type)
		if(type == ccui.TouchEventType.ended) then
			--按键音效
			gSound.clickSound()
			if ref:getOpacity() == 0 then -- 勾了
                LoginData:SetIsSavePwd(true)
				ref:setOpacity(255)
			else
				LoginData:SetIsSavePwd(false)
				ref:setOpacity(0)
			end
		end
	end)
	local text_name = popup:getChildByName("text_name")
	local text_password = popup:getChildByName("text_password")
	local fontSize = 26
	local input_pos = cc.p(text_name:getPositionX(),text_name:getPositionY())
	local input_ContentSize = text_name:getContentSize()
	this.editTxt_name = ccui.EditBox:create(input_ContentSize,"")
	popup:addChild(this.editTxt_name)
	this.editTxt_name:setPosition(input_pos)
	this.editTxt_name:setName("name")
	this.editTxt_name:setPlaceHolder(string.format(TR("%d至%d位"),4,12))
	this.editTxt_name:setPlaceholderFont("",fontSize)
	this.editTxt_name:setFontSize(fontSize)
	this.editTxt_name:setMaxLength(12)
	this.editTxt_name:setTextHorizontalAlignment(cc.TEXT_ALIGNMENT_LEFT)
	this.editTxt_name:setPlaceholderFontColor(cc.c3b(220,220,220))
	this.editTxt_name:setAnchorPoint(cc.p(0.5,0.5))
	this.editTxt_name:registerScriptEditBoxHandler(this.editCB)
    this.editTxt_name:setInputMode(cc.EDITBOX_INPUT_MODE_SINGLELINE)
    if this.accDatas and this.accDatas.acc_name and this.accDatas.acc_name ~= nil then
        this.editTxt_name:setText(this.accDatas.acc_name)
    end
	---
	input_pos = cc.p(text_password:getPositionX(),text_password:getPositionY())
	input_ContentSize = text_password:getContentSize()
	this.editTxt_password = ccui.EditBox:create(input_ContentSize,"")
	popup:addChild(this.editTxt_password)
	this.editTxt_password:setPosition(input_pos)
	this.editTxt_password:setName("password")
	this.editTxt_password:setPlaceHolder(string.format(TR("%d至%d位"),8,16))
	this.editTxt_password:setPlaceholderFont("",fontSize)
	this.editTxt_password:setFontSize(fontSize)
	this.editTxt_password:setMaxLength(16)
	this.editTxt_password:setTextHorizontalAlignment(cc.TEXT_ALIGNMENT_LEFT)
	this.editTxt_password:setPlaceholderFontColor(cc.c3b(220,220,220))
	this.editTxt_password:setAnchorPoint(cc.p(0.5,0.5))
	this.editTxt_password:registerScriptEditBoxHandler(this.editCB)
	this.editTxt_password:setInputMode(cc.EDITBOX_INPUT_MODE_SINGLELINE)
	this.editTxt_password:setInputFlag(cc.EDITBOX_INPUT_FLAG_PASSWORD)
    if this.accDatas and this.accDatas.pwd_name and this.accDatas.pwd_name ~= nil then
        this.editTxt_password:setText(this.accDatas.pwd_name)
    end
	popup:setScale(0.01)
	popup:runAction(cc.EaseBackOut:create(cc.ScaleTo:create(0.5,Tools_Base.ScaleMin)))
end

function this.Adjust()
	local shadow = this.layer:getChildByName("shadow")
	shadow:setScale(Tools_Base.ScaleMax)
	
	local popup = this.layer:getChildByName("popup")
    popup:setScale(Tools_Base.ScaleMin)
	
    local center = cc.p(Tools_Base.visibleSize.width/2.0, Tools_Base.visibleSize.height/2.0)
    this.layer:setPosition(center)
end

function this.OnBtnClose()
	gStates_CloseAsync(this)
end

function this.OnBtnLogin(ref)
	if Tools_Base.PreventContinuousClick(ref,0.4) then
		local acc = this.editTxt_name:getText()
		local pwd = this.editTxt_password:getText()

		if Tools_Base.HasSpace(acc) then
			Tools_Base.ShowMsgBox(TR("账号不能含有空白字符"))
		elseif not (Tools_Base.GetStringWordNum(acc)>=4 and Tools_Base.GetStringWordNum(acc)<=12) then
			local str = string.format(TR("%d至%d位"),4,12)
			Tools_Base.ShowMsgBox(str)
        elseif not (Tools_Base.GetStringWordNum(pwd)>=8 and Tools_Base.GetStringWordNum(pwd)<=16) then
			local str = string.format(TR("%d至%d位"),8,16)
			Tools_Base.ShowMsgBox(str)
        else
            print("LoginData:GetIsSavePwd()",LoginData:GetIsSavePwd())
			if not LoginData:GetIsSavePwd() then
                LoginData:ModifyAccDatas("acc_name","")
                LoginData:ModifyAccDatas("pwd_name","")
                LoginData:SaveAccDatas()
			end
			this.SendPKG(acc,pwd)
		end
	end
end

function this.OnBtnRegister(ref)
	if Tools_Base.PreventContinuousClick(ref,0.4) then
		local registerLayer = require("packagelua.src.login.RegisterLayer")
		gStates_SetAsync(registerLayer)
	end
end

function this.OnBtnService(ref)
	if Tools_Base.PreventContinuousClick(ref,0.4) then
		local layer = BottomLayer:Get(LoginLayer)
		if layer then
			layer:OnBtnService()
		end
	end
end

--输入框回调
function this.editCB(event,sender)
	if event == "ended" then
		local str = sender:getText()
		if str == "" then
			return
		end
		local lowest = 0
		local highest = 0
		local name = sender:getName()
		if name == "name" then
			lowest = 4
			highest = 12
		elseif name == "password" then
			lowest = 8
			highest = 16
		end
        if not Tools_Base.formatString(str,lowest,highest) then
            -- print(TR("字母或数字%d至%d位"))
		end
	end
end

-- 登录请求
function this.SendPKG(account,password)
    LoginData:SetType(LoginData.TYPE.PWD)
    LoginData:SetAccount(account)
    LoginData:SetPassword(password)
    go(function()
		this.btn_login:setEnabled(false)
		local layer = BottomLayer:Get(LoginLayer)
		layer:ConnectNetwork()
		if not layer:GetServerVersionInfo() then
			print("get version info faield.")
		end
		SleepSecs(1.2)

		if not tolua.isnull(this.btn_login) then
			this.btn_login:setEnabled(true)
		end
	end)
end

return this
