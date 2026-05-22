local BindVirtualCoinLayer = class("BindVirtualCoinLayer", function()
    return Tools.CreateLayer("csb/BindVirtualCoinLayer.csb")
end)

function BindVirtualCoinLayer:onEnter()
    self.addr = ""
    self.addr2 = ""
    self:InitUI()
end

function BindVirtualCoinLayer:setInfo(pay_channel_id)
    self.pay_channel_id = pay_channel_id
end

function BindVirtualCoinLayer:InitUI()
    -- 关闭按钮
    local close = self:getChildByName("close")
    Tools.AddClickEvent(close, function()
		self:Close()
    end, true)
    
	--地址
	local addr_text = self:getChildByName("addr_text")
	addr_text = Tools.ReplaceEdit(addr_text)
	addr_text:setInputMode(cc.EDITBOX_INPUT_MODE_SINGLELINE)
	addr_text:setFontSize(22)
	addr_text:setPlaceholderFontSize(24)
	addr_text:setReturnType(cc.KEYBOARD_RETURNTYPE_DONE)
	addr_text:setTextHorizontalAlignment(cc.TEXT_ALIGNMENT_CENTER)

	--确认地址
	local addr2_text = self:getChildByName("addr2_text")
	addr2_text = Tools.ReplaceEdit(addr2_text)
	addr2_text:setInputMode(cc.EDITBOX_INPUT_MODE_SINGLELINE)
	addr2_text:setFontSize(22)
	addr2_text:setPlaceholderFontSize(24)
	addr2_text:setReturnType(cc.KEYBOARD_RETURNTYPE_DONE)
	addr2_text:setTextHorizontalAlignment(cc.TEXT_ALIGNMENT_CENTER)

    -- 确认按钮
    local _lang_ok = self:getChildByName("_lang_ok")
    Tools.AddClickEvent(_lang_ok,
        function ()
            go(
                function ()
                    self.addr = addr_text:getString()
                    self.addr2 = addr2_text:getString()
                    if self.addr ~= self.addr2 or self.addr == "" then
                        UIManager.ShowMsgBox(TR("请确认钱包地址是否正确"))
                        return
                    end
                    local data_ = PKG_Client_Lobby_BindVirtualCoinAddress.Create()
                    data_.pay_channel_id = self.pay_channel_id
                    data_.virtual_coin_address = self.addr
                    UIManager.ShowWaiting()
                    local rlt_ = gNet_SendRequest(data_)
                    UIManager.HideWaiting()
                    local PKG_name = getmetatable(rlt_)
                    if PKG_name == PKG_Lobby_Client_ResponseBindVirtualCoinAddress then
                        UserData.pay_channel_accounts = rlt_.pay_channel_accounts
                        Dispatcher:Dispatch(UserData)
                        Dispatcher:Dispatch("BIND_VC")
                        UIManager.ShowToast(TR("绑定成功"))
                        self:Close()
                    elseif PKG_name == PKG_Generic_Error then
                        UIManager.ShowMsgBox(rlt_.message)
                    end
                end
            )
    end, true)

end

return BindVirtualCoinLayer