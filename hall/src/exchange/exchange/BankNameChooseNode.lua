local BankNameChooseNode = class("BankNameChooseNode", function(node)
    return node
end)

function BankNameChooseNode:ctor()
    release_print("BankNameChooseNode:ctor()")
    self:InitUI()
end

function BankNameChooseNode:InitUI()
    self.bankname = Tools.ReplaceEdit(self:getChildByName("bankname_input"))
    self.bankname:setMaxLength(50)
    self.bankname:setFontSize(24)
    self.bankname:setPlaceholderFontSize(24)
    self.bankname:setInputMode(cc.EDITBOX_INPUT_MODE_SINGLELINE)
	self.bankname:setTextHorizontalAlignment(cc.TEXT_ALIGNMENT_CENTER)

    --开户行列表初始化
    self:InitBankNameList()
end

function BankNameChooseNode:SetBankName(name)
    self.bankname:setText(name)
end

function BankNameChooseNode:GetBankName()
    return self.bankname:getText()
end

function BankNameChooseNode:setModifyEnabled(bEnabled)
    self.bankname:setEnabled(bEnabled)
    self.list_show_btn:setEnabled(bEnabled)
    self.list_show_btn:setBright(true)
end

--开户行列表初始化(暂时仅泰国使用)
function BankNameChooseNode:InitBankNameList()
    self.banknamelist_bg = self:getChildByName("khhlist_bg")
    self.list_show_btn = self:getChildByName("list_show_btn")
    self.banknamelist_bg:setVisible(false)
    if not Recharge.Bank_NameList then
        self.bankname:setPlaceHolder(TR("请输入开户行"))
        self.list_show_btn:setVisible(false)
        return
    end
    Tools.AddClickEvent(self.list_show_btn,
            function()
                if self.listisshow then
                    self:ShowBankNameList()
                else
                    self:HideBankNameList()
                end
            end)
    --更换朝向
    local btn_up = self.list_show_btn:getChildByName("btn_up")
    btn_up:setVisible(false)
    local btn_down = self.list_show_btn:getChildByName("btn_down")
    btn_down:setVisible(true)
    self.bankname:setEnabled(false)
    self.banknamelist = self.banknamelist_bg:getChildByName("khh_list")
    self.item = self.banknamelist:getChildByName("item")
    self.item:retain()
    self.banknamelist:removeAllItems()
    for key, value in pairs(Recharge.Bank_NameList) do
        local new_item = self.item:clone()
        self.banknamelist:pushBackCustomItem(new_item)
        new_item:loadTexture(string.format(Recharge.Path_BankName,key))
        local bank_name = new_item:getChildByName("text")
        bank_name:setString(value)
        local btn = new_item:getChildByName("btn")
		Tools.AddClickEvent(btn,
			function()
				self:HideBankNameList(value)
			end)
    end
end

--显示开户银行表
function BankNameChooseNode:ShowBankNameList()
    self.banknamelist_bg:setVisible(true)
    self.listisshow = false
    --更换朝向
    local btn_up = self.list_show_btn:getChildByName("btn_up")
    btn_up:setVisible(true)
    local btn_down = self.list_show_btn:getChildByName("btn_down")
    btn_down:setVisible(false)

    if self.on_drop then
        self.on_drop(true)
    end
end

--隐藏开户银行表
function BankNameChooseNode:HideBankNameList(bankname)
    self.listisshow = true
    if bankname then
        self.bankname:setText(bankname)
    end
    self.banknamelist_bg:setVisible(false)
    --更换朝向
    local btn_up = self.list_show_btn:getChildByName("btn_up")
    btn_up:setVisible(false)
    local btn_down = self.list_show_btn:getChildByName("btn_down")
    btn_down:setVisible(true)
    
    if self.on_drop then
        self.on_drop(false)
    end
end

function BankNameChooseNode:SetDropHandler(on_drop)
    self.on_drop = on_drop
end

return BankNameChooseNode
