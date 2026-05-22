--TODO : 需要处理 通知信息
local AccountEmailBindingLayer = class("AccountEmailBindingLayer", function()
    return Tools.CreateLayer("csb/lobby/AccountEmailBindingLayer.csb")
end)
EmailCodeTimer = 0
Email = ""
function AccountEmailBindingLayer:onEnter()
	self.acc = ""
	self.pwd = ""
	self.pwd2 = ""
	self.emailAcc = ""
	self.code = ""

    self:InitUI()
	self:SetCodeTimer(true)
end

function AccountEmailBindingLayer:InitUI()
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

	--
	local text_1 = popup:getChildByName("Text_1")
	local text_2 = popup:getChildByName("Text_2")
	local text_3 = popup:getChildByName("Text_3")
	--账户名称
	local input_size = text_1:getContentSize()
	local input_pos = cc.p(text_1:getPositionX(),text_1:getPositionY())

	local tips_4_12 = string.format(TR("%d至%d位"), 4, 12)
	if Def.Languages[SettingData.language].name == "mm" then
		-- tips_4_12 = "အက္ခရာ(သို့) ဂဏန်း ၄လုံးမှစ၍ ၁၂လုံးထိထားရှိနိုင်သည်။"
		-- 2022-4-25
		tips_4_12 = "4လုံးမှ12အထိထားရှိနိုင်သည်။"
	end

	self.account_name = self:createEditBox(
		input_size,input_pos,"account_name", tips_4_12, 26, 12, self.editCB,false)
	popup:addChild(self.account_name)
	
	--账户密码
	input_size = text_2:getContentSize()
	local tips_8_16 = string.format(TR("%d至%d位"), 8, 16) 
	if Def.Languages[SettingData.language].name == "mm" then
		-- tips_8_16 = "ဂဏန်း၈လုံးမှစ၍ ၁၆လုံးထိထားရှိနိုင်သည်။"
		-- 2022-4-25
		tips_8_16 = "8လုံးမှစ၍ 16လုံးထိထားနိုင်သည်။"
	end

	input_pos = cc.p(text_2:getPositionX(),text_2:getPositionY())
	self.account_password = self:createEditBox(
		input_size,input_pos,"account_password", tips_8_16, 26, 16, self.editCB, true)
	popup:addChild(self.account_password)
	--确认密码
	input_size = text_3:getContentSize()
	input_pos = cc.p(text_3:getPositionX(),text_3:getPositionY())

	local tips_again = string.format(TR("%d至%d位"), 8, 16) 
	if Def.Languages[SettingData.language].name == "mm" then
		-- tips_again = "သင့်၏အကောင့်စကား၀ှက်ကို ပြန်ရိုက်ထည့်ပါ။"
		-- 2022-4-25
		tips_again = "စကားဝှက်ကိုပြန်လည်ရိုက်ထည့်ပါ။"
	end
	self.confirm_password = self:createEditBox(
		input_size,input_pos,"confirm_password", tips_again, 26, 16, self.editCB, true)
	popup:addChild(self.confirm_password)

	local Text_4 = popup:getChildByName("Text_4")
	-- 邮箱
	input_size = Text_4:getContentSize()
	input_pos = cc.p(Text_4:getPositionX(),Text_4:getPositionY())
	self.email = self:createEditBox(
		input_size,input_pos,"email", "", 26, 100, self.editCB, false)
	popup:addChild(self.email)
	

	self.btn_sendCode = popup:getChildByName("_lang_btn_sendCode")
	Tools.AddClickEvent(self.btn_sendCode, function()
		self:OnBtnSendCode()
	end, true)

	self.code_tips = popup:getChildByName("code_tips")
	self.code_tips:setString("")

	if UserData.email ~= "" then
		self.email:setText(UserData.email)
		self.email:setTouchEnabled(false)
		self.emailAcc = UserData.email
		self.code = 00000
		self.btn_sendCode:setVisible(false)
		
		local input_bg111 = popup:getChildByName("input_bg111")
		if not tolua.isnull(input_bg111) then
			input_bg111:setVisible(false)	
		else
			popup:loadTexture("studio/email/bj_3.png")
		end
		
		local _lang_code = popup:getChildByName("_lang_code")
		_lang_code:setVisible(false)

	else
		self.email:setText(Email)

		local Text_5 = popup:getChildByName("Text_5")
		-- code
		input_size = Text_5:getContentSize()
		input_pos = cc.p(Text_5:getPositionX(),Text_5:getPositionY())
		self.codeInput = self:createEditBox(
			input_size,input_pos,"codeInput", "", 26, 20, self.editCB, false)
		popup:addChild(self.codeInput)
	
	end
end

function AccountEmailBindingLayer:createEditBox(size,pos,name,place_holder,fontSize,length,callfunc,encryption)
	local edit_box = ccui.EditBox:create(size,"src/hall/res/common/tc_shurukuangbeijing.png")
	edit_box:setPosition(pos)
	edit_box:setName(name)
	edit_box:setPlaceHolder(place_holder)
	edit_box:setPlaceholderFont("Arial",fontSize)
	edit_box:setFontSize(fontSize)
	edit_box:setMaxLength(length)
	edit_box:setTextHorizontalAlignment(cc.TEXT_ALIGNMENT_LEFT)
	edit_box:setPlaceholderFontColor(cc.c3b(220,220,220))
	edit_box:setAnchorPoint(cc.p(0.5,0.5))
	edit_box:registerScriptEditBoxHandler(handler(self,callfunc))
	edit_box:setInputMode(cc.EDITBOX_INPUT_MODE_SINGLELINE)
	if encryption then
		edit_box:setInputFlag(cc.EDITBOX_INPUT_FLAG_PASSWORD)
	end
	return edit_box
end

function AccountEmailBindingLayer:OnBtnClose()
	self.btn_sendCode = nil
	self:Close()
end

function AccountEmailBindingLayer:OnBtnOk()
	go(
		function ()
			if Tools_Base.HasSpace(self.acc) then
				UIManager.ShowToast(TR("账号不能含有空白字符"))
				return
			end
			if not (Tools_Base.GetStringWordNum(self.acc)>=4 and Tools_Base.GetStringWordNum(self.acc)<=12) then
				local string_ = string.gsub(TR("账号只能NNN至SSS位"),"NNN",4)
				string_ = string.gsub(string_,"SSS",12)
				UIManager.ShowToast(string_)
				return
			else
				local ok = self:VerifyAccount(self.acc)
				if not ok then
					return
				end
			end
	
			if self.pwd and self.pwd2 and self.pwd ~= self.pwd2 then
				UIManager.ShowToast(TR("请确认两次密码输入一致"))
				return
			end

			if not (Tools_Base.GetStringWordNum(self.pwd)>=8 and Tools_Base.GetStringWordNum(self.pwd)<=16) then
				local string_ = string.gsub(TR("密码只能NNN至SSS位"),"NNN",4)
				string_ = string.gsub(string_,"SSS",12)
				UIManager.ShowToast(string_)
				return
			end
	
			if not self:checkInput(self.emailAcc) then
				UIManager.ShowToast(TR("邮箱格式不正确"))
				return
			end
			if UserData.email ~= "" then
				self:SendAccRegist(self.acc,self.pwd)
			else
				if not self.code then
					return
				end
				self:SendEmailRegist()
			end
		end
	)
		
end

-- 注册请求
function AccountEmailBindingLayer:SendAccRegist(account,password)
	go(
		function()
			local data_ = PKG_Client_Lobby_SetAccountNameAndPassword.Create()
			data_.account_name  = account
			data_.password  = password
			UIManager.ShowWaiting()
			local rlt_ =  gNet_SendRequest(data_)
			UIManager.HideWaiting()
			if(rlt_ ~= nil) then
				--收到返回数据
				if getmetatable(rlt_) == PKG_Generic_Success then
					-- UIManager.ShowToast(TR("账号密码绑定成功"))
					UserData.account_name = account
					LoginData:SetType(LoginData.TYPE.PWD)
					LoginData:SetAccount(account)
					LoginData:SetPassword(password)
					LoginData:ModifyAccDatas("acc_name",account)
					LoginData:ModifyAccDatas("pwd_name",password)
					LoginData:SaveAccDatas()
					Dispatcher:Dispatch(UserData)
					if gStates_Exists("Lobby") then
						gStates_GetState("Lobby").lobbyLayer.function_button:Update()
					end
					-- user.VIPLevelUpLayer.PlayVIPLevelUpEffect()
					-- 触发下次登录 弹出保存官网
					activity.SpreadLogic:SetSavePhoto(false)
					self:OnBtnClose()
				elseif(getmetatable(rlt_) == PKG_Generic_Error) then
					local num = Int64ToNumber(rlt_.number)
					if (num == -115)then
						UIManager.ShowToast(TR("帐户名不能为空"))
					elseif (num == -114)then
						UIManager.ShowToast(TR("重复注册"))
					end
				end
			end
		end
	)
end

--输入框回调
function AccountEmailBindingLayer:editCB(event,sender)
	if event == "return" then
		local str = sender:getText()
		local name = sender:getName()
		if name == "account_name" then
			self.acc = str
			if Tools_Base.HasSpace(str) then
				UIManager.ShowToast(TR("账号不能含有空白字符"))
				return
			end
			if not (Tools_Base.GetStringWordNum(str)>=4 and Tools_Base.GetStringWordNum(str)<=12) then
				local string_ = string.gsub(TR("账号只能NNN至SSS位"),"NNN",4)
				string_ = string.gsub(string_,"SSS",12)
				UIManager.ShowToast(string_)
			else
				go(
					function ()
						self:VerifyAccount(str)
					end
				)
			end
		elseif name == "account_password" then
			if not (Tools_Base.GetStringWordNum(str)>=8 and Tools_Base.GetStringWordNum(str)<=16) then
				local string_ = string.gsub(TR("密码只能NNN至SSS位"),"NNN",4)
				string_ = string.gsub(string_,"SSS",12)
				UIManager.ShowToast(string_)
				return
			end
			self.pwd = str
			if self.pwd2 ~= "" and self.pwd ~= self.pwd2 then
				self.pwd = ""
				UIManager.ShowToast(TR("请确认两次密码输入一致"))
			end
		elseif name == "confirm_password" then
			if not (Tools_Base.GetStringWordNum(str)>=8 and Tools_Base.GetStringWordNum(str)<=16) then
				local string_ = string.gsub(TR("密码只能NNN至SSS位"),"NNN",4)
				string_ = string.gsub(string_,"SSS",12)
				UIManager.ShowToast(string_)
				return
			end
			self.pwd2 = str
			if self.pwd ~= "" and self.pwd ~= self.pwd2 then
				UIManager.ShowToast(TR("请确认两次密码输入一致"))
				self.pwd2 = ""
			end
		elseif name == "email" then
			if self:checkInput(str) then
				self.emailAcc = str
			else
				self.emailAcc = ""
				UIManager.ShowToast(TR("邮箱格式不正确"))
			end
		elseif name == "codeInput" then
			self.code = str
		end
	end
end

function AccountEmailBindingLayer:checkInput(str)
	if not str then
        return false
    end

    if (str:match("[A-Za-z0-9%.%%%+%-]+@[A-Za-z0-9%.%%%+%-]+%.%w%w%w?%w?")) then
        return true
    else
        return false
    end
end


function AccountEmailBindingLayer:VerifyAccount(acc)
	local data_ = PKG_Client_Login_HasAccountName.Create()
	data_.account_name  = acc
	UIManager.ShowWaiting()
	local rlt_ =  gNet_SendRequest(data_)
	UIManager.HideWaiting()
	dump(rlt_,"VerifyAccount")
	if(rlt_ ~= nil) then
		if getmetatable(rlt_) == PKG_Login_Client_HasAccountNameResult then
			if rlt_.okya == true then
				return true
			else
				UIManager.ShowToast(TR("账号已使用"))
			end
		elseif(getmetatable(rlt_) == PKG_Generic_Error) then
			UIManager.ShowToast(TR("账号已使用或不合法"))
		end
	end
	return false
end

function AccountEmailBindingLayer:OnBtnSendCode()
	if not self.emailAcc or self.emailAcc == "" then
		print("self.emailAcc, ", self.emailAcc)
		UIManager.ShowToast(TR("请输入邮箱"))
		return
	end
	if self:checkInput(self.emailAcc) then
		go(
			function ()
				local data_ = PKG_Client_Lobby_SendEmailVerificationCode.Create()
				data_.email = self.emailAcc
				UIManager.ShowWaiting()
				local rlt_ =  gNet_SendRequest(data_)
				UIManager.HideWaiting()
				dump(rlt_,"OnBtnSendCode")
				if(rlt_ ~= nil) then
					if getmetatable(rlt_) == PKG_Generic_Success then
						UIManager.ShowToast(TR("请注意查收邮箱验证码"))
						Email = self.emailAcc
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


function AccountEmailBindingLayer:SetCodeTimer(isInit)
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

-- 注册邮箱请求
function AccountEmailBindingLayer:SendEmailRegist()
	go(
		function()
			local data_ = PKG_Client_Lobby_BindEMailNumber.Create()
			data_.code  = self.code
			UIManager.ShowWaiting()
			local rlt_ =  gNet_SendRequest(data_)
			UIManager.HideWaiting()
			dump(rlt_,"SendRegist")
			if(rlt_ ~= nil) then
				--收到返回数据
				if getmetatable(rlt_) == PKG_Lobby_Client_BindEmailResult then
					if rlt_.success then
						UserData.email = rlt_.email
						Dispatcher:Dispatch(UserData)
						UIManager.ShowToast(TR("邮箱绑定成功"))
						self:OnBtnOk()
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
return AccountEmailBindingLayer