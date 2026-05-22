local ModifyNameLayer = class("ModifyNameLayer", function()
	return Tools.CreateLayer("csb/lobby/ModifyNameLayer.csb")
end)

function ModifyNameLayer:onEnter()
	self:InitUI()
end

function ModifyNameLayer:InitUI()
	--关闭按钮
	local ui_close_btn = self:findChild("lua_close_btn")
	Tools.AddClickEvent(ui_close_btn, function()
		self:Close()
	end, true)

	--输入框
	local input = self:findChild("lua_input_name")
	input = Tools.ReplaceEdit(input)
	input:setInputMode(cc.EDITBOX_INPUT_MODE_SINGLELINE)
	input:setFontSize(26)
	input:setMaxLength(6)
	input:setPlaceholderFontSize(24)
	input:setPlaceHolder(TR("请输入新昵称"))
	input:setReturnType(cc.KEYBOARD_RETURNTYPE_DONE)
	input:setTextHorizontalAlignment(cc.TEXT_ALIGNMENT_CENTER)
	self.ui_input_name = input

	--修改按钮
	local ui_modify_btn = self:findChild("_lang_modify_btn")
	Tools.AddClickEvent(ui_modify_btn, function()
		local input = self.ui_input_name:getString()
		if input == "" then
			UIManager.ShowToast(TR("请输入新昵称"))
			return
		end
		self:HandleChangeNick(input)
	end, true)
end

function ModifyNameLayer:HandleChangeNick(name)
	go(function()
		local data_ = PKG_Client_Lobby_ChangeNickname.Create()
		data_.nickname = name
		UIManager.ShowWaiting()
		local rlt_ = gNet_SendRequest(data_)
		UIManager.HideWaiting()
		if(getmetatable(rlt_) == PKG_Lobby_Client_ChangeNickname_Success) then
			UserData.nickname = rlt_.nickname
			Dispatcher:Dispatch(UserData)
			UIManager.ShowToast(TR("修改昵称成功"))
			self:Close()
		elseif(getmetatable(rlt_) == PKG_Generic_Error)then
			local num = Int64ToNumber(rlt_.number)
			if (num == Def.Net_RepeatNickName) then
				UIManager.ShowMsgBox(TR("该昵称已被使用，请重新输入"))
			else
				UIManager.ShowMsgBox(TR("修改昵称失败"))
			end
		end
	end)
end

return ModifyNameLayer
