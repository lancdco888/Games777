local BindCardAndPhoneLayer = class("BindCardAndPhoneLayer", function()
    return Tools.CreateLayer("csb/BindCardAndPhoneLayer.csb")
end)

function BindCardAndPhoneLayer:onEnter()
    self.default_name = ""
    self.default_bankname = ""
    self.default_bankCard = ""
    self.default_phone = ""
    self.listisshow = true
    self:InitUI()
end

function BindCardAndPhoneLayer:InitUI()
    if ConfigParam.Region == "tha" then
        self:getChildByName("_lang_sjh"):setVisible(false)
        self:getChildByName("_lang_qrsjh"):setString(TR("确认TrueMoney账号"))
        -- self:getChildByName("qrsjh"):setVisible(false)
    elseif ConfigParam.Region == "ind" or ConfigParam.Region == "ms" then
        self:getChildByName("_lang_true_money"):setVisible(false)
        self:getChildByName("_lang_qrsjh"):setString(TR("确认手机号"))
        -- self:getChildByName("querenshoujihao"):setVisible(false)
    end
    
    local _lang_xm = self:getChildByName("_lang_xm")
    Tools.CcuiTextIgnoreContentAdaptByScaleX(_lang_xm)
    --姓名
    self.xingming_input = Tools.ReplaceEdit(self:getChildByName("xm_input"))
    self.xingming_input:setMaxLength(50)
    self.xingming_input:setFontSize(24)
    self.xingming_input:setInputMode(cc.EDITBOX_INPUT_MODE_SINGLELINE)
    self.xingming_input:registerScriptEditBoxHandler(self.EditCB)
    --开户行
    self.khh_input = Tools.ReplaceEdit(self:getChildByName("khh_input"))
    self.khh_input:setMaxLength(50)
    self.khh_input:setFontSize(24)
    self.khh_input:setInputMode(cc.EDITBOX_INPUT_MODE_SINGLELINE)
    self.khh_input:registerScriptEditBoxHandler(self.EditCB)
    --卡号
    self.yhkh_input = Tools.ReplaceEdit(self:getChildByName("yhkh_input"))
    self.yhkh_input:setMaxLength(Recharge.Bank_MaxNumber)
    self.yhkh_input:setFontSize(24)
    self.yhkh_input:setInputMode(cc.EDITBOX_INPUT_MODE_NUMERIC)
    self.yhkh_input:registerScriptEditBoxHandler(self.EditCB)

    --手机号
    local max_num = 0
    if ConfigParam.Region == "tha"  then
        _, max_num = exutils.GetTrueMoneyLength()
    elseif ConfigParam.Region == "ms" then
        _, max_num = exutils.GetPhoneLenth()
    else
        max_num = exutils.GetPhoneLenth()
    end
    self.sjh_input = Tools.ReplaceEdit(self:getChildByName("sjh_input"))
    self.sjh_input:setMaxLength(max_num)
    self.sjh_input:setFontSize(24)
    self.sjh_input:registerScriptEditBoxHandler(self.EditCB)

    --确认手机号
    self.qrsjh_input = Tools.ReplaceEdit(self:getChildByName("qrsjh_input"))
    self.qrsjh_input:setMaxLength(max_num)
    self.qrsjh_input:setFontSize(24)
    self.qrsjh_input:registerScriptEditBoxHandler(self.EditCB)
    if ConfigParam.Region == "tha" then
        self.qrsjh_input:setInputMode(cc.EDITBOX_INPUT_MODE_SINGLELINE)
        self.sjh_input:setInputMode(cc.EDITBOX_INPUT_MODE_SINGLELINE)
    else
        self.qrsjh_input:setInputMode(cc.EDITBOX_INPUT_MODE_NUMERIC)
        self.sjh_input:setInputMode(cc.EDITBOX_INPUT_MODE_NUMERIC)
    end
    --开户行列表初始化
    self:InitBankNameList()
    --关闭按钮
    local btn_ = self:getChildByName("close")
	Tools.AddClickEvent(btn_, function()
        PopLayer:Close(LobbyRechargeLayer)
		self:Close()
    end, true)
    --确认按钮
    local btn_ok = self:getChildByName("_lang_btn_ok")
    Tools.AddClickEvent(btn_ok, function()
		self:BtnFun()
    end, true)
end

--开户行列表初始化(暂时仅泰国使用)
function BindCardAndPhoneLayer:InitBankNameList()
    self.banknamelist_bg = self:getChildByName("khhlist_bg")
    self.list_show_btn = self:getChildByName("list_show_btn")
    self.banknamelist_bg:setVisible(false)
    if not Recharge.Bank_NameList then
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
    btn_up:setVisible(true)
    local btn_down = self.list_show_btn:getChildByName("btn_down")
    btn_down:setVisible(false)
    self.khh_input:setEnabled(false)
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
function BindCardAndPhoneLayer:ShowBankNameList()
    self.banknamelist_bg:setVisible(true)
    self.listisshow = false
    --更换朝向
    local btn_up = self.list_show_btn:getChildByName("btn_up")
    btn_up:setVisible(false)
    local btn_down = self.list_show_btn:getChildByName("btn_down")
    btn_down:setVisible(true)
    self.yhkh_input:setEnabled(false)
    self.yhkh_input:setVisible(false)
    self.sjh_input:setEnabled(false)
    self.sjh_input:setVisible(false)
    self.qrsjh_input:setEnabled(false)
    self.qrsjh_input:setVisible(false)
end

--隐藏开户银行表
function BindCardAndPhoneLayer:HideBankNameList(bankname)
    self.listisshow = true
    if bankname then
        self.khh_input:setText(bankname)
    end
    self.banknamelist_bg:setVisible(false)
    --更换朝向
    local btn_up = self.list_show_btn:getChildByName("btn_up")
    btn_up:setVisible(true)
    local btn_down = self.list_show_btn:getChildByName("btn_down")
    btn_down:setVisible(false)  
    if self.type_ == "modify" then
        if self.default_phone ~= "" and self.default_bankCard == "" then
            self.yhkh_input:setEnabled(false)
            self.list_show_btn:setEnabled(false)
            self.sjh_input:setEnabled(true)
            self.qrsjh_input:setEnabled(true)
        elseif self.default_bankCard ~= "" and self.default_phone == "" then
            self.yhkh_input:setEnabled(true)
            self.list_show_btn:setEnabled(true)
            self.sjh_input:setEnabled(false)
            self.qrsjh_input:setEnabled(false)
        elseif self.default_phone ~= "" and self.default_bankCard ~= "" then
            self.yhkh_input:setEnabled(true)
            self.sjh_input:setEnabled(true)
            self.qrsjh_input:setEnabled(true)
        end
    else
        if self.default_phone ~= "" then
            self.yhkh_input:setEnabled(true)
            self.list_show_btn:setEnabled(true)
        end
        if self.default_bankCard ~= "" then
            self.sjh_input:setEnabled(true)
            self.qrsjh_input:setEnabled(true)
        end
        if self.default_bankCard == "" and self.default_phone == "" then
            self.yhkh_input:setEnabled(true)
            self.list_show_btn:setEnabled(true)
            self.sjh_input:setEnabled(true)
            self.qrsjh_input:setEnabled(true)
        end
    end
    self.yhkh_input:setVisible(true)
    self.qrsjh_input:setVisible(true)
    self.sjh_input:setVisible(true)
end

--设置账号信息
function BindCardAndPhoneLayer:SetDefInfo(info,type_)
    self.default_name = info.name
    self.default_bankname = info.bankname
    self.default_bankCard = info.bankCard
    self.default_phone = info.phone
    self.type_ = type_
    --根据默认值设置状态
	if self.default_bankCard ~= "" then
		self.xingming_input:setString(self.default_name)
		self.xingming_input:setEnabled(false)
		self.yhkh_input:setText(self.default_bankCard)
		self.yhkh_input:setEnabled(false)
		self.khh_input:setText(self.default_bankname)
		self.list_show_btn:setEnabled(false)
	end
	if self.default_phone ~= "" then
		self.xingming_input:setText(self.default_name)
		self.xingming_input:setEnabled(false)
		self.sjh_input:setText(self.default_phone)
		self.sjh_input:setEnabled(false)
		self.qrsjh_input:setText(self.default_phone)
		self.qrsjh_input:setEnabled(false)
    end
    if self.type_ == "modify" then
        if self.default_phone ~= "" and self.default_bankCard == "" then
            self.yhkh_input:setEnabled(false)
            self.list_show_btn:setEnabled(false)
            self.sjh_input:setEnabled(true)
            self.qrsjh_input:setEnabled(true)
        elseif self.default_bankCard ~= "" and self.default_phone == "" then
            self.yhkh_input:setEnabled(true)
            self.list_show_btn:setEnabled(true)
            self.sjh_input:setEnabled(false)
            self.qrsjh_input:setEnabled(false)
        elseif self.default_phone ~= "" and self.default_bankCard ~= "" then
            self.yhkh_input:setEnabled(true)
            self.sjh_input:setEnabled(true)
            self.qrsjh_input:setEnabled(true)
            self.list_show_btn:setEnabled(true)
        end
        self.xingming_input:setEnabled(true)
    end
end

function BindCardAndPhoneLayer:EditCB(event,sender)
    if event == "ended" then
        local str = sender:getText()
        if str == "" then
            return
        end
        local name = sender:getName()
        if name == "yhkh_input" then
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
        elseif "sjh_input" == name or "qrsjh_input" == name then
            if ConfigParam.Region == "tha" then
                -- 检查是否为 合法的 true money 账号
                if not exutils.CheckTrueMoneyAccount(str) then
                    local msg = exutils.GetTrueMoneyInputTips()
                    UIManager.ShowMsgBox(msg)
                    return
                end
            else
                if exutils.CheckPhone(#str)then
                    local str_1 = 0
                    if ConfigParam.Region == "ms" then
                        local min,max = exutils.GetPhoneLenth()
                        str_1 = tostring(min) .. "-" .. tostring(max)
                    else
                        str_1 = exutils.GetPhoneLenth()
                    end
                    local str_ = string.gsub(TR("请输入AAA位数的手机号"),"AAA",str_1)
                    UIManager.ShowMsgBox(str_)
                end
            end
        end
    end
end

--确认回调
function BindCardAndPhoneLayer:BtnFun()
    gSound.clickSound()
    local name = self.xingming_input:getText()
    local card = self.yhkh_input:getText()
    local bankname = self.khh_input:getText()
    local phone = self.sjh_input:getText()
    local qrphone = self.qrsjh_input:getText()
    --名字未输入
    if #name == 0 then
        UIManager.ShowMsgBox(TR("请输入姓名"))
        return
    end
    --名字纯空格
    if exutils.strIsBlank(name) then
        UIManager.ShowMsgBox(TR("姓名不能全是空格，请输入正确的姓名"))
        return
    end
    --卡号和手机号都未输入
    if card == "" and phone == "" then
        UIManager.ShowMsgBox(TR("至少在银行卡和手机号中二选一进行绑定"))
        return
    end
    if ConfigParam.Region == "tha" then
        if card == phone then
            UIManager.ShowMsgBox(TR("银行卡号与TRUE MONEY号码不能一致，绑定失败!"))
            return
        end
    end
    --第一次绑定，两个银行卡，手机号同时绑定时
    if (self.default_bankCard == "" and self.default_phone == ""
        and card ~= "" and phone ~= "") then
        if ConfigParam.Region == "tha" then
            -- 检查是否为 合法的 true money 账号
            if not exutils.CheckTrueMoneyAccount(phone) then
                local msg = exutils.GetTrueMoneyInputTips()
                UIManager.ShowMsgBox(msg)
                return
            end
        else
            -- 检查手机号码
            local str_1 = 0
            if ConfigParam.Region == "ms" then
                local min,max = exutils.GetPhoneLenth()
                str_1 = tostring(min) .. "-" .. tostring(max)
            else
                str_1 = exutils.GetPhoneLenth()
            end
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
        --两次输入不一致
        if phone ~= qrphone then
            UIManager.ShowMsgBox(TR("请确认两次输入一致"))
            return
        end
    end
    if self.type_ == "bind" then
        --没有绑定银行卡，输入了银行卡信息的
        if self.default_bankCard == "" and card ~= "" then
            --卡号位数不够或者未输入
            if ConfigParam.Region == "tha" then
                if #card ~= Recharge.Bank_MinNumber and #card ~= Recharge.Bank_MaxNumber then
                    UIManager.ShowMsgBox(string.format(TR("%d或%d位数的银行卡号"),Recharge.Bank_MinNumber,Recharge.Bank_MaxNumber))
                    return
                end
            else
                if #card < Recharge.Bank_MinNumber or #card > Recharge.Bank_MaxNumber then
                    UIManager.ShowMsgBox(string.format(TR("%d-%d位数的银行卡号"),Recharge.Bank_MinNumber,Recharge.Bank_MaxNumber))
                    return
                end
            end
            --付款银行纯空格
            if exutils.strIsBlank(bankname) then
                UIManager.ShowMsgBox(TR("付款银行名不能全是空格"))
                return
            end
            --付款银行未填
            if bankname == "" then
                UIManager.ShowMsgBox(TR("请输入开户行"))
                return
            end
            --卡号有空格或特殊字符
            if string.find(card," ") or (math.floor(tonumber(card)) < tonumber(card)) then
                UIManager.ShowMsgBox(TR("付款银行号码不能全是空格"))
                return
            end
            --不管有没有手机号信息，都会添加，有就还会发送绑定手机号包
            local tab = {
                bankname = bankname,
                payer_name = name,
                payer_card_number = card,
                phone = phone,
            }
            self:SendRegist(tab)
            return
        end
        --绑过银行卡的，再次进来绑定手机号
        --或者没绑过银行卡，只是绑定手机号
        if self.default_phone == "" and phone ~= "" then
            --没绑过银行卡，只是绑定手机号,印尼强制不能只绑手机号
            if ConfigParam.Region == "ind" then
                if self.default_bankCard == "" then
                    UIManager.ShowMsgBox(string.format(TR("%d-%d位数的银行卡号"),Recharge.Bank_MinNumber,Recharge.Bank_MaxNumber))
                    return
                end
            end

            if ConfigParam.Region == "tha" then
                -- 检查是否为 合法的 true money 账号
                if not exutils.CheckTrueMoneyAccount(str) then
                    local msg = exutils.GetTrueMoneyInputTips()
                    UIManager.ShowMsgBox(msg)
                    return
                end
            else
                -- 检查手机号
                local str_1 = 0
                if ConfigParam.Region == "ms" then
                    local min,max = exutils.GetPhoneLenth()
                    str_1 = tostring(min) .. "-" .. tostring(max)
                else
                    str_1 = exutils.GetPhoneLenth()
                end
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
            --两次输入不一致
            if phone ~= qrphone then
                UIManager.ShowMsgBox(TR("请确认两次输入一致"))
                return
            end
            --不管有没有银行卡号信息，都会添加
            local tab = {
                bankname = bankname,
                payer_name = name,
                payer_card_number = card,
                phone = phone,
            }
            self:SendRegist(tab)
        end
    elseif (self.type_ == "modify") then
        if card ~= "" then
            --卡号位数不够或者未输入
            if ConfigParam.Region == "tha" then
                if #card ~= Recharge.Bank_MinNumber and #card ~= Recharge.Bank_MaxNumber then
                    UIManager.ShowMsgBox(string.format(TR("%d或%d位数的银行卡号"),Recharge.Bank_MinNumber,Recharge.Bank_MaxNumber))
                    return
                end
            else
                if #card < Recharge.Bank_MinNumber or #card > Recharge.Bank_MaxNumber then
                    UIManager.ShowMsgBox(string.format(TR("%d-%d位数的银行卡号"),Recharge.Bank_MinNumber,Recharge.Bank_MaxNumber))
                    return
                end
            end
            --付款银行纯空格
            if exutils.strIsBlank(bankname) then
                UIManager.ShowMsgBox(TR("付款银行名不能全是空格"))
                return
            end
            --付款银行未填
            if bankname == "" then
                UIManager.ShowMsgBox(TR("请输入开户行"))
                return
            end
            --卡号有空格或特殊字符
            if string.find(card," ") or (math.floor(tonumber(card)) < tonumber(card)) then
                UIManager.ShowMsgBox(TR("付款银行号码不能全是空格"))
                return
            end
        end
        if phone ~= "" then
            --没绑过银行卡，只是绑定手机号,印尼强制不能只绑手机号
            if ConfigParam.Region == "ind" then
                if card == "" then
                    UIManager.ShowMsgBox(string.format(TR("%d-%d位数的银行卡号"),Recharge.Bank_MinNumber,Recharge.Bank_MaxNumber))
                    return
                end
            end
            local str_1 = 0
            if ConfigParam.Region == "ms" or ConfigParam.Region == "tha" then
                local min,max = exutils.GetPhoneLenth()
                str_1 = tostring(min) .. "-" .. tostring(max)
            else
                str_1 = exutils.GetPhoneLenth()
            end
            if ConfigParam.Region == "tha" then
                --手机号未输入或位数不够
                local min,max = exutils.GetPhoneLenth()
                if not(Tools_Base.formatString(phone,min,max)) then
                    local str_ = string.gsub(TR("请输入AAA位数的手机号"),"AAA",str_1)
                    UIManager.ShowMsgBox(str_)
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
            --两次输入不一致
            if phone ~= qrphone then
                UIManager.ShowMsgBox(TR("请确认两次输入一致"))
                return
            end
        end
        local tab = {
            bankname = bankname,
            payer_name = name,
            payer_card_number = card,
            phone = phone,
        }
        self:SendModify(tab)
    end
end

--请求绑定
function BindCardAndPhoneLayer:SendRegist(tab)
    go(
        function()
            local data_ = nil
            if tab.payer_card_number ~= "" and self.default_bankCard == "" then
                data_ = PKG_Client_Lobby_BandingRealNameBankInfo.Create()
                data_.bankname = tab.bankname
                data_.payer_name = tab.payer_name
                data_.payer_card_number = tab.payer_card_number
            elseif tab.phone ~= "" and self.default_phone == "" then
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
                    if tab.payer_card_number ~= "" and self.default_bankCard == "" then
                        self.default_bankCard = tab.payer_card_number
                        --没有默认手机号，并且在绑定界面输入了
                        if self.default_phone == "" and tab.phone ~= "" then
                            self:SendRegist(tab)
                            return
                        end
                    end
                    if tab.phone ~= "" and self.default_phone == "" then
                        self.default_phone = tab.phone
                    end
                    UserData.pay_channel_accounts = rlt_.pay_channel_accounts
				    Dispatcher:Dispatch(UserData)
                    Dispatcher:Dispatch("BIND_INFO_RECHARGE")
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
end

--请求修改审批
function BindCardAndPhoneLayer:SendModify(tab)
    go(function()
        local data_ = nil
        data_ = PKG_Client_Lobby_ApplyFixRealname.Create()
        data_.bankname = tab.bankname
        data_.payer_name = tab.payer_name
        data_.payer_card_number = tab.payer_card_number
        data_.phone = tab.phone
        UIManager.ShowWaiting()
        local rlt_ = gNet_SendRequest(data_)
        UIManager.HideWaiting()
        if(rlt_ ~= nil) then
            --收到返回数据
            local PKG_name = getmetatable(rlt_)
            if PKG_name == PKG_Generic_Success then
                UIManager.ShowMsgBox(TR("信息正在审核中，请耐心等待!"))
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

return BindCardAndPhoneLayer