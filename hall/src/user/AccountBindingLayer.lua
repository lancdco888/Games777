--TODO : 需要处理 通知信息
local AccountBindingLayer = class("AccountBindingLayer", function()
    return Tools.CreateLayer("csb/lobby/AccountBindingLayer.csb")
end)

function AccountBindingLayer:onEnter()
    self:InitUI()
end

function AccountBindingLayer:InitUI()
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

	--查看更多权益按钮
	local view_vip = self:findChild("_lang_btn_view_vip")
	Tools.AddClickEvent(view_vip, function()
		PopLayer:PopInstance(user.VipBenefitLayer)
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

	--popup:setScale(0.01)
	--popup:runAction(cc.EaseBackOut:create(cc.ScaleTo:create(0.5,1)))
end

function AccountBindingLayer:createEditBox(size,pos,name,place_holder,fontSize,length,callfunc,encryption)
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
	edit_box:registerScriptEditBoxHandler(callfunc)
	edit_box:setInputMode(cc.EDITBOX_INPUT_MODE_SINGLELINE)
	if encryption then
		edit_box:setInputFlag(cc.EDITBOX_INPUT_FLAG_PASSWORD)
	end
	return edit_box
end

function AccountBindingLayer:OnBtnClose()
	self:Close()
end

function AccountBindingLayer:OnBtnOk()
	local acc = self.account_name:getText()
	local pwd = self.account_password:getText()
	local pwd2 = self.confirm_password:getText()

	if Tools_Base.HasSpace(acc) then
		UIManager.ShowToast(TR("账号不能含有空白字符"))
	elseif pwd ~= pwd2 then
		UIManager.ShowToast(TR("请确认两次密码输入一致"))
	elseif not (Tools_Base.GetStringWordNum(acc)>=4 and Tools_Base.GetStringWordNum(acc)<=12) then
		local string_ = string.gsub(TR("账号只能NNN至SSS位"),"NNN",4)
		string_ = string.gsub(string_,"SSS",12)
		UIManager.ShowToast(string_)
	elseif not (Tools_Base.GetStringWordNum(pwd)>=8 and Tools_Base.GetStringWordNum(pwd)<=16) then
		local string_ = string.gsub(TR("密码只能NNN至SSS位"),"NNN",8)
		string_ = string.gsub(string_,"SSS",16)
		UIManager.ShowToast(string_)
	else
		self:SendRegist(acc,pwd)
	end
end

-- 注册请求
function AccountBindingLayer:SendRegist(account,password)
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
function AccountBindingLayer:editCB(event,sender)
	if event == "ended" then
		local str = sender:getText()
		if str == "" then
			return
		end
		local lowest = 0
		local highest = 0
		local name = sender:getName()
		if name == "account_name" then
			lowest = 4
			highest = 12
		elseif name == "account_password" or name == "confirm_password" then
			lowest = 8
			highest = 16
		end
	end
end

return AccountBindingLayer