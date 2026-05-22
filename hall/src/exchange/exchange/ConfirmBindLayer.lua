local ConfirmBindLayer = class("ConfirmBindLayer", function()
	return Tools.CreateLayer("csb/ConfirmBindLayer.csb")
end)

function ConfirmBindLayer:onEnter()
	self:InitUI()
	self.bankname = ""
end

function ConfirmBindLayer:InitUI()
	local ui_btn_close = self:findChild("lua_close_btn")
	Tools.AddClickEvent(ui_btn_close, function()
		self:Close()
	end, true)

	local tip = self:findChild("BankTip")
	tip:setString(TR("你的银行"))

	local banktext = self:findChild("banktext")
	banktext:setString(TR("请输入开户行"))
	
	local chooseList = self:findChild("chooseList")
	chooseList:setVisible(false)

	local item = self:findChild("item")
	item:retain()
	chooseList:removeAllItems()
	for id, name in pairs(Recharge.Bank_NameList) do
		local cell = item:clone()
		chooseList:pushBackCustomItem(cell)
		local text = cell:findChild("text")
		text:setString(name)
		local icon = cell:findChild("icon")
		icon:loadTexture(string.format(Recharge.Path_BankName,id))
		local btn = cell:findChild("btn")
		Tools.AddClickEvent(btn, function()
			banktext:setString(name)
			chooseList:setVisible(false)
			self.bankname = name
		end, true)
	end
	item:release()
	Tools.AddClickEvent(banktext, function()
		chooseList:setVisible(true)
	end, false)
	--完成绑定按钮
	self.ui_btn_bind = self:findChild("_lang_btn_bind")
	Tools.AddClickEvent(self.ui_btn_bind, function()
		self:OnBtnBindClick()
	end, true)

	local ifsc = self:findChild("ifsc")
	ifsc:setVisible(ConfigParam.Region == "ina")

	self.ifsc_input = self:findChild("ifsc_input")
    self.ifsc_input = Tools.ReplaceEdit(self:findChild("ifsc_input"))
    self.ifsc_input:setMaxLength(11)
    self.ifsc_input:setFontSize(30)
    self.ifsc_input:setInputMode(cc.EDITBOX_INPUT_MODE_SINGLELINE)
    self.ifsc_input:registerScriptEditBoxHandler(
		function (event,sender)  
			if event == "ended" then
				local str = sender:getText()
				if str == "" then
					return
				end
				local isIFSC = self:CheckIsIFSC(str)
				if not isIFSC then
					UIManager.ShowToast(TR("IFSC格式不正确"))
				end
			end
		end
	)

end

function ConfirmBindLayer:OnBtnBindClick()
	self:BindCard()
end

function ConfirmBindLayer:BindCard()
	if self.onBindHandler then
		self:onBindHandler()
	end
end


function ConfirmBindLayer:CheckIsIFSC(str)
	local ret = string.match(str,"[A-Z]+[0][A-Z0-9]+")
	if ret ~= str then
		return false
	end
	return true
end
---------------------------------------------------------

function ConfirmBindLayer:AddBindHandler(handler)
	self.onBindHandler = handler
end

function ConfirmBindLayer:GetInputName()
	return self.bankname
end

function ConfirmBindLayer:GetInputIFSC()
	return self.ifsc_input:getText()
end
return ConfirmBindLayer