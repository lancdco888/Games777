local EmailBindingLayer = class("EmailBindingLayer", function()
    return Tools.CreateLayer("csb/lobby/EmailBindingLayer.csb")
end)
EmailCodeTimer = 0
Email = ""
function EmailBindingLayer:onEnter()
    self:InitUI()
end

function EmailBindingLayer:InitUI()
	--
	self:setAnchorPoint(cc.p(0.5,0.5))
	--
	local popup = self:getChildByName("popup")
	--关闭
	self.btn_close = popup:getChildByName("btn_close")
    Tools.AddClickEvent(self.btn_close, function()
		gSound.clickSound()
        self:OnBtnClose()
    end, true)

	--确认
	self.btn_ok = popup:getChildByName("_lang_btn_ok")
    Tools.AddClickEvent(self.btn_ok, function()
		self:OnBtnOk()
	end, true)

	self.btn_sendCode = popup:getChildByName("_lang_btn_sendCode")
    Tools.AddClickEvent(self.btn_sendCode, function()
		self:OnBtnSendCode()
	end, true)
	

	--email
	local text_1 = popup:getChildByName("Text_1")
	local input_size = text_1:getContentSize()
	local input_pos = cc.p(text_1:getPositionX(),text_1:getPositionY())
	self.emailInput = self:createEditBox(input_size,input_pos,"emailInput", 26)
	popup:addChild(self.emailInput)
	self.emailInput:setText(Email)
	--code
	local text_2 = popup:getChildByName("Text_2")
	local input_size2 = text_2:getContentSize()
	local input_pos2 = cc.p(text_2:getPositionX(),text_2:getPositionY())
	self.codeInput = self:createEditBox(input_size2,input_pos2,"codeInput", 26)
	popup:addChild(self.codeInput)

	self.code_tips = popup:getChildByName("code_tips")
	self.code_tips:setString("")

	self:checkOKBtn()
	self:SetCodeTimer(true)
end

function EmailBindingLayer:createEditBox(size,pos,name,fontSize)
	local edit_box = ccui.EditBox:create(size,"src/hall/res/common/tc_shurukuangbeijing.png")
	edit_box:setPosition(pos)
	edit_box:setName(name)
	edit_box:setPlaceHolder("")
	edit_box:setPlaceholderFont("Arial",fontSize)
	edit_box:setFontSize(fontSize)
	edit_box:setTextHorizontalAlignment(cc.TEXT_ALIGNMENT_LEFT)
	edit_box:setPlaceholderFontColor(cc.c3b(220,220,220))
	edit_box:setAnchorPoint(cc.p(0.5,0.5))
	edit_box:registerScriptEditBoxHandler(
		function (event,sender)
			if event == "ended" then
				self:checkOKBtn()
			end
		end
	)
	edit_box:setInputMode(cc.EDITBOX_INPUT_MODE_SINGLELINE)
	return edit_box
end

function EmailBindingLayer:OnBtnClose()
	self.btn_sendCode = nil
	self:Close()
end

function EmailBindingLayer:OnBtnOk()
	local code = self.codeInput:getText()
	if #code>0 then
		self:SendRegist(code)
	end
end

-- 
function EmailBindingLayer:OnBtnSendCode()
	local email = self.emailInput:getText()
	if not email or email == "" then
		UIManager.ShowToast(TR("请输入邮箱"))
		return
	end
	if self:checkInput(email) then
		go(
			function ()
				local data_ = PKG_Client_Lobby_SendEmailVerificationCode.Create()
				data_.email = email
				UIManager.ShowWaiting()
				local rlt_ =  gNet_SendRequest(data_)
				UIManager.HideWaiting()
				if(rlt_ ~= nil) then
					if getmetatable(rlt_) == PKG_Generic_Success then
						UIManager.ShowToast(TR("请注意查收邮箱验证码"))
						Email = email
						self:SetCodeTimer()
					elseif getmetatable(rlt_) == PKG_Generic_Error then
						UIManager.ShowToast(rlt_.message)
					end
				end
			end
		)
	else
		UIManager.ShowToast(TR("邮箱格式不正确"))
	end
end

-- 注册请求
function EmailBindingLayer:SendRegist(code)
	go(
		function()
			local data_ = PKG_Client_Lobby_BindEMailNumber.Create()
			data_.code  = code
			UIManager.ShowWaiting()
			local rlt_ =  gNet_SendRequest(data_)
			UIManager.HideWaiting()
			dump(rlt_,"rlt_")
			if(rlt_ ~= nil) then
				--收到返回数据
				if getmetatable(rlt_) == PKG_Lobby_Client_BindEmailResult then
					if rlt_.success then
						UserData.email = rlt_.email
						self:OnBtnClose()
						Dispatcher:Dispatch(UserData)
						UIManager.ShowToast(TR("邮箱绑定成功"))
					else
						UIManager.ShowToast(TR("验证码错误"))
					end
				elseif getmetatable(rlt_) == PKG_Generic_Error then
					UIManager.ShowToast(TR("验证码错误"))
				end
			end
		end
	)
end

function EmailBindingLayer:checkInput(str)
	if not str then
        return false
    end

    if (str:match("[A-Za-z0-9%.%%%+%-]+@[A-Za-z0-9%.%%%+%-]+%.%w%w%w?%w?")) then
        return true
    else
        return false
    end
end

function EmailBindingLayer:checkOKBtn()
	local email = self.emailInput:getText()
	local code = self.codeInput:getText()
	if #email > 0 and #code > 0 then
		self.btn_ok:setEnabled(true)
		self.btn_ok:setTouchEnabled(true)
	else
		self.btn_ok:setEnabled(false)
		self.btn_ok:setTouchEnabled(false)
	end
end

function EmailBindingLayer:SetCodeTimer(isInit)
	gScene:stopAllActions()
	if not isInit then
		EmailCodeTimer = 60
	end
	local action = cc.Repeat:create(
		cc.Sequence:create(
			cc.CallFunc:create(function()
				if not tolua.isnull(self.btn_sendCode) then
					self.code_tips:setVisible(true)
					self.code_tips:setString(string.format(TR("验证码已发送(%d)"),EmailCodeTimer))
					self.btn_sendCode:setEnabled(false)
					self.btn_sendCode:setTouchEnabled(false)
				end
				EmailCodeTimer = EmailCodeTimer -1
				if not tolua.isnull(self.btn_sendCode) and EmailCodeTimer<=0 then
					self.code_tips:setVisible(false)
					self.btn_sendCode:setEnabled(true)
					self.btn_sendCode:setTouchEnabled(true)
				end
			end),
			cc.DelayTime:create(1)
		), 
	EmailCodeTimer)
	gScene:runAction(action)
end
return EmailBindingLayer