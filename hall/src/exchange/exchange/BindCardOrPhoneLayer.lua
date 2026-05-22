local BindCardOrPhoneLayer = class("BindCardOrPhoneLayer", function()
    return Tools.CreateLayer("csb/BindCardOrPhoneLayer.csb")
end)

function BindCardOrPhoneLayer:onEnter()
    self.state = 2
    self.default_name = ""
    self.default_bankname = ""
    self.default_account = ""
    self.listisshow = true
    self:InitUI()
    self:InitData()
end

function BindCardOrPhoneLayer:InitUI()
    self:PhoneLayerInit()
    self:BankLayerInit()
end

--只在泰国用得到
function BindCardOrPhoneLayer:InitData()
    self.bankCard_get = ""
    self.phone_get = ""
    self.payer_name_get = ""
    for key, value in ipairs(UserData.pay_channel_accounts) do
        if value.pay_channel_id == 2 then
            self.bankCard_get = value.card_number
            self.payer_name_get = value.name
        elseif value.pay_channel_id == 801 then
            self.phone_get = value.card_number
        end
    end
end

--绑定电话界面
function BindCardOrPhoneLayer:PhoneLayerInit()
    self.phonelayer = self:getChildByName("bindphone")
    self.phonelayer:setVisible(false)
    self.phone_name = Tools.ReplaceEdit(self.phonelayer:getChildByName("name_input"))
    self.phone_name:setMaxLength(50)
    self.phone_name:setFontSize(24)
    self.phone_name:setPlaceHolder(TR("请输入姓名"))
    self.phone_name:setPlaceholderFontSize(24)
    self.phone_name:setInputMode(cc.EDITBOX_INPUT_MODE_SINGLELINE)
    self.phone_name:registerScriptEditBoxHandler(self.EditCB)

    local max_num = 0
    if ConfigParam.Region == "ms" then
        _,max_num = exutils.GetPhoneLenth()
    elseif  ConfigParam.Region == "tha" then
        _,max_num = exutils.GetTrueMoneyLength()
    else
        max_num = exutils.GetPhoneLenth()
    end

    local _lang_sjhm = self:findChild("_lang_sjhm")
    if ConfigParam.Region == "tha" then
        _lang_sjhm:setString(TR("True Money 账号"))
    else
        _lang_sjhm:setString(TR("手机号码"))
    end
    
    self.phone_ = Tools.ReplaceEdit(self.phonelayer:getChildByName("phone_input"))
    self.phone_:setMaxLength(max_num)
    self.phone_:setFontSize(24)

    local str_
    if ConfigParam.Region == "ms" then
        local min,max = exutils.GetPhoneLenth()
        local str_1 = tostring(min) .. "-" .. tostring(max)
        str_ = string.gsub(TR("请输入AAA位数的手机号"), "AAA", str_1)
    elseif ConfigParam.Region == "tha" then
        -- 泰国 为 True Money 账号
        str_ = exutils.GetTrueMoneyInputTips()
    else
        local str_1 = exutils.GetPhoneLenth()
        str_ = string.gsub(TR("请输入AAA位数的手机号"), "AAA", str_1)
    end
    
    self.phone_:setPlaceHolder(str_)
    self.phone_:setPlaceholderFontSize(24)
    if ConfigParam.Region == "tha" then
        self.phone_:setInputMode(cc.EDITBOX_INPUT_MODE_SINGLELINE)
    else
        self.phone_:setInputMode(cc.EDITBOX_INPUT_MODE_NUMERIC)
    end
    self.phone_:registerScriptEditBoxHandler(self.EditCB)

    --关闭按钮
    local close = self.phonelayer:getChildByName("close")
    Tools.AddClickEvent(close,function ()
        self:Close()
    end, true)
    --确定按钮
    local ok = self.phonelayer:getChildByName("_lang_btn_ok")
    Tools.AddClickEvent(ok,function ()
        gSound.clickSound()
        local phone = self.phone_:getText()
        local phoneName = self.phone_name:getText()
        if #phoneName == 0 then
            UIManager.ShowMsgBox(TR("请输入姓名"))
            return
        end
        if exutils.strIsBlank(phoneName) then
            UIManager.ShowMsgBox(TR("姓名不能全是空格，请输入正确的姓名"))
            return
        end
        local str_1 = 0
        if ConfigParam.Region == "ms" or ConfigParam.Region == "tha" then
            local min,max = exutils.GetPhoneLenth()
            str_1 = tostring(min) .. "-" .. tostring(max)
        else
            str_1 = exutils.GetPhoneLenth()
        end
        if ConfigParam.Region == "tha" then
            -- 检查是否为 合法的 true money 账号
            if not exutils.CheckTrueMoneyAccount(phone) then
                local msg = exutils.GetTrueMoneyInputTips()
                UIManager.ShowMsgBox(msg)
                return
            end
        else
            --手机号未输入或位数不够
            if exutils.CheckPhone(#phone)then
                local str_ = string.gsub(TR("请输入AAA位数的手机号"),"AAA",str_1)
                UIManager.ShowMsgBox(str_)
                return
            end
            --手机号号有空格或特殊字符
            if string.find(phone," ") or (math.floor(tonumber(phone)) < tonumber(phone)) then
                local str_ = string.gsub(TR("请输入AAA位数的手机号"),"AAA",str_1)
                UIManager.ShowMsgBox(str_)
                return
            end
        end
        local tab = {
            phone = phone,
            payer_name = phoneName
        }
        self:SendRegist(tab)
    end, true)
end

--绑定银行卡界面
function BindCardOrPhoneLayer:BankLayerInit()
    self.banklayer = self:getChildByName("bindbank")
    self.banklayer:setVisible(false)
    self.bank_name = Tools.ReplaceEdit(self.banklayer:getChildByName("name_input"))
    self.bank_name:setMaxLength(50)
    self.bank_name:setFontSize(24)
    self.bank_name:setPlaceHolder(TR("请输入姓名"))
    self.bank_name:setPlaceholderFontSize(24)
    self.bank_name:setInputMode(cc.EDITBOX_INPUT_MODE_SINGLELINE)
    self.bank_name:registerScriptEditBoxHandler(self.EditCB)

    self.bankcard_ = Tools.ReplaceEdit(self.banklayer:getChildByName("bankcard_input"))
    self.bankcard_:setMaxLength(Recharge.Bank_MaxNumber)
    self.bankcard_:setFontSize(24)
    local str_bankcard_ = TR("%d-%d位数的银行卡号")
    if ConfigParam.Region == "tha" then
        str_bankcard_ = TR("%d或%d位数的银行卡号")
    end
    self.bankcard_:setPlaceHolder(string.format(str_bankcard_,Recharge.Bank_MinNumber,Recharge.Bank_MaxNumber))
    self.bankcard_:setPlaceholderFontSize(20)
    self.bankcard_:setInputMode(cc.EDITBOX_INPUT_MODE_NUMERIC)
    self.bankcard_:registerScriptEditBoxHandler(self.EditCB)

    self.bankname = Tools.ReplaceEdit(self.banklayer:getChildByName("bankname_input"))
    self.bankname:setMaxLength(50)
    self.bankname:setFontSize(24)
    self.bankname:setPlaceholderFontSize(24)
    self.bankname:setInputMode(cc.EDITBOX_INPUT_MODE_SINGLELINE)
    self.bankname:registerScriptEditBoxHandler(self.EditCB)
    --开户行列表初始化
    self:InitBankNameList()

    --关闭按钮
    local close = self.banklayer:getChildByName("close")
    Tools.AddClickEvent(close,function ()
        self:Close()
    end, true)
    --确定按钮
    local ok = self.banklayer:getChildByName("_lang_btn_ok")
    Tools.AddClickEvent(ok,function ()
        gSound.clickSound()
        local name = self.bank_name:getText()
        local acc = self.bankcard_:getText()
        local address = self.bankname:getText()
        if exutils.strIsBlank(address) then
            UIManager.ShowMsgBox(TR("付款银行名不能全是空格"))
            return
        end
        if exutils.strIsBlank(name) then
            UIManager.ShowMsgBox(TR("姓名不能全是空格，请输入正确的姓名"))
            return
        end
        if string.find(acc," ") or (math.floor(tonumber(acc)) < tonumber(acc)) then
            UIManager.ShowMsgBox(TR("付款银行号码不能全是空格"))
            return
        end
        
        if ConfigParam.Region == "tha" then
            if acc == "" or #acc ~= Recharge.Bank_MinNumber and #acc ~= Recharge.Bank_MaxNumber then
                UIManager.ShowMsgBox(string.format(TR("%d或%d位数的银行卡号"),Recharge.Bank_MinNumber,Recharge.Bank_MaxNumber))
                return
            end
        else
            if acc == "" or #acc < Recharge.Bank_MinNumber or #acc > Recharge.Bank_MaxNumber then
                UIManager.ShowMsgBox(string.format(TR("%d-%d位数的银行卡号"),Recharge.Bank_MinNumber,Recharge.Bank_MaxNumber))
                return
            end
        end
        if name ~= "" and  acc ~= "" and address ~= "" and 
        #acc>=Recharge.Bank_MinNumber and #acc<=Recharge.Bank_MaxNumber then
            local tab = {
                bankname = address,
                payer_name = name,
                payer_card_number = acc
            }
            self:SendRegist(tab)
        end
    end, true)
end

--开户行列表初始化(暂时仅泰国使用)
function BindCardOrPhoneLayer:InitBankNameList()
    self.banknamelist_bg = self.banklayer:getChildByName("khhlist_bg")
    self.list_show_btn = self.banklayer:getChildByName("list_show_btn")
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
function BindCardOrPhoneLayer:ShowBankNameList()
    self.banknamelist_bg:setVisible(true)
    self.listisshow = false
    --更换朝向
    local btn_up = self.list_show_btn:getChildByName("btn_up")
    btn_up:setVisible(true)
    local btn_down = self.list_show_btn:getChildByName("btn_down")
    btn_down:setVisible(false)

    self.bank_name:setEnabled(false)
    self.bankcard_:setEnabled(false)
    self.bank_name:setVisible(false)
    self.bankcard_:setVisible(false)
end

--隐藏开户银行表
function BindCardOrPhoneLayer:HideBankNameList(bankname)
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
    
    self.bank_name:setEnabled(true)
    self.bankcard_:setEnabled(true)
    self.bank_name:setVisible(true)
    self.bankcard_:setVisible(true)
end

--输入框回调
function BindCardOrPhoneLayer:EditCB(event,sender)
    if event == "ended" then
        local str = sender:getText()
        if str == "" then
            return
        end
        local name = sender:getName()
        if name == "bankcard_input" then
            if ConfigParam.Region == "tha" then
                if #str ~= Recharge.Bank_MinNumber and #str ~= Recharge.Bank_MaxNumber then
                    UIManager.ShowMsgBox(string.format(TR("%d或%d位数的银行卡号"),Recharge.Bank_MinNumber,Recharge.Bank_MaxNumber))
                end
            else
                if #str < Recharge.Bank_MinNumber or #str > Recharge.Bank_MaxNumber then
                    UIManager.ShowMsgBox(string.format(TR("%d-%d位数的银行卡号"),Recharge.Bank_MinNumber,Recharge.Bank_MaxNumber))
                end
            end
            if string.find(str," ") or (math.floor(tonumber(str)) < tonumber(str))  then
                 UIManager.ShowMsgBox(TR("付款银行名不能全是空格"))
            end
        elseif "phone_input" == name then
            local str_1 = 0
            if ConfigParam.Region == "ms" or ConfigParam.Region == "tha" then
                local min,max = exutils.GetPhoneLenth()
                str_1 = tostring(min) .. "-" .. tostring(max)
            else
                str_1 = exutils.GetPhoneLenth()
            end
            if ConfigParam.Region == "tha" then
                -- tha 为 true money 账号
                if not exutils.CheckTrueMoneyAccount(str) then
                    local msg = exutils.GetTrueMoneyInputTips()
                    UIManager.ShowMsgBox(msg)
                    return
                end
            else
                --手机号未输入或位数不够
                if exutils.CheckPhone(#str)then
                    local str_ = string.gsub(TR("请输入AAA位数的手机号"),"AAA",str_1)
                    UIManager.ShowMsgBox(str_)
                    return
                end
                --手机号号有空格或特殊字符
                if string.find(str," ") or (math.floor(tonumber(str)) < tonumber(str)) then
                    local str_ = string.gsub(TR("请输入AAA位数的手机号"),"AAA",str_1)
                    UIManager.ShowMsgBox(str_)
                    return
                end
            end
        end
    end
end

--设置默认信息
function BindCardOrPhoneLayer:SetDefInfo(info)
    self.state = info.state
    self.default_name = info.name
    if self.state == 2 then
        self.banklayer:setVisible(true)
        self.phonelayer:setVisible(false)
        if self.default_bankname ~= "" then
            self.bank_name:setString(self.default_name)
            self.bank_name:setEnabled(false)
        end
    else
        self.banklayer:setVisible(false)
        self.phonelayer:setVisible(true)
        -- if self.default_bankname ~= "" then
            self.phone_name:setString(self.default_name)
            self.phone_name:setEnabled(false)
        -- end
    end
end

function BindCardOrPhoneLayer:SetPhoneNameEnabled(bEnabled)
    self.phone_name:setEnabled(bEnabled)
end

--发送绑定请求
function BindCardOrPhoneLayer:SendRegist(tab)
    go(function()
        local data_ = nil
        if self.state == 2 then
            data_ = PKG_Client_Lobby_BandingRealNameBankInfo.Create()
            data_.bankname = tab.bankname
            data_.payer_name = tab.payer_name
            data_.payer_card_number = tab.payer_card_number
        else
            data_ = PKG_Client_Lobby_BandingRealNamePhoneInfo.Create()
            data_.phone = tab.phone
            data_.payer_name = tab.payer_name
        end
        UIManager.ShowWaiting()
        local rlt_ = gNet_SendRequest(data_)
        UIManager.HideWaiting()
        if(rlt_ ~= nil) then
            --收到返回数据
            local PKG_name = getmetatable(rlt_)
            if PKG_name == PKG_Lobby_Client_BandingRealNameResult then
                UserData.pay_channel_accounts = rlt_.pay_channel_accounts
                Dispatcher:Dispatch(UserData)
                Dispatcher:Dispatch("UPDATE_CARD")
                
                if self.bind_cbk then
                    self.bind_cbk()
                end
                
                self:Close()
                UIManager.ShowToast(TR("账号绑定成功"))
            elseif(PKG_name == PKG_Generic_Error) then
                local num = Int64ToNumber(rlt_.number)
                if num == -1 then -- 一般不会出现
                    UIManager.ShowMsgBox(TR("重复绑定"))
                elseif num == -2 then -- 姓名不匹配
                    UIManager.ShowMsgBox(TR("手机号姓名和银行卡姓名不一致"))
                else
                    UIManager.ShowMsgBox(num..rlt_.message)
                end
            end
        end
    end
    )

    dump(UserData.pay_channel_accounts, " ** UserData.pay_channel_accounts ** ")
end

--请求修改审批
function BindCardOrPhoneLayer:SendModifyBankName(bankname)
    go(function()
        local data_ = nil
        data_ = PKG_Client_Lobby_ApplyFixRealname.Create()
        data_.bankname = bankname
        data_.payer_name = self.payer_name_get
        data_.payer_card_number = self.bankCard_get
        data_.phone = self.phone_get

        UIManager.ShowWaiting()
        local rlt_ = gNet_SendRequest(data_)
        UIManager.HideWaiting()
        if(rlt_ ~= nil) then
            --收到返回数据
            local PKG_name = getmetatable(rlt_)
            if PKG_name == PKG_Generic_Success then
                UIManager.ShowToast(TR("修改成功!"))
                PopLayer:Close(LobbyRechargeLayer)
                self:Close()
            elseif(PKG_name == PKG_Generic_Error) then
                local num = Int64ToNumber(rlt_.number)
                if num == -2000 then -- 一般不会出现
                    UIManager.ShowMsgBox(TR("请勿重复提交，请耐心等待!"))
                    PopLayer:Close(LobbyRechargeLayer)
                    self:Close()
                else
                    UIManager.ShowMsgBox(num..rlt_.message)
                    PopLayer:Close(LobbyRechargeLayer)
                    self:Close()
                end
            end
        end
    end)
end

function BindCardOrPhoneLayer:SetBindCallback(cbk)
    self.bind_cbk = cbk
end

return BindCardOrPhoneLayer