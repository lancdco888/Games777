local GiveLayer = class('GiveLayer', function()
    return Tools.CreateLayer('csb/Give/GiveLayer.csb')
end)

function GiveLayer:onEnter()
    self:InitUI()
end

function GiveLayer:InitUI()
    local ui_btn_close = self:findChild("btn_close")
    Tools.AddClickEvent(ui_btn_close, function()
        self:Close()
    end, true)
    
    local _lang_btn_ok = self:findChild("_lang_btn_ok")
    Tools.AddClickEvent(_lang_btn_ok, function()
        self:OnBtnConfirm()
    end, true)

    local btn_record = self:findChild("_lang_btn_record")
    Tools.AddClickEvent(btn_record, function()
        self:OnBtnRecord()
    end, true)

    -- 目标用户id
    local ui_user_id = self:findChild("inputID")
    self.ui_user_id = self:InitEdit(ui_user_id, "")
    self.ui_user_id:setInputMode(cc.EDITBOX_INPUT_MODE_PHONENUMBER)
    -- 数量
    local ui_amount = self:findChild("inputCoin")
    self.ui_amount = self:InitEdit(ui_amount, "")
    self.ui_amount:setInputMode(cc.EDITBOX_INPUT_MODE_PHONENUMBER)
    self.ui_amount:onEvent(function(eventname, sender)
        if eventname == "began" then
			self.bInput = true
			self.ui_amount:setString("")
            self:OnInputBoxChanged()
		elseif eventname == "changed" then
			self:OnInputBoxChanged()
		elseif eventname == "return" then
			self.bInput = false
		end
	end)
    self.ui_amount:setString("")
    -- 余额
    local ui_rest = self:findChild("rest")
    self.ui_rest = ui_rest
    self.ui_rest:setString(Tools.CoinToString(UserData.money + UserData.money_safe))

    local text = Tools.Fmt(
        TR("最少赠送{0}金币,手续费{1},并且自身最少保留{2}金币"),
        Tools.CoinToString(UserData.gift_min_money),
        self:FormatPercentage(UserData.gift_fee * 100),
        Tools.CoinToString(UserData.gift_min_remain_money)
    )

    local tip_txt = self:findChild("tip_txt")
    tip_txt:getVirtualRenderer():setOverflow(2)
    tip_txt:setString(text)

    self:OnInputBoxChanged()
end

function GiveLayer:FormatPercentage(value)
    if value % 1 == 0 then
        return string.format("%d%%", value)
    else
        return string.format("%.2f%%", value)
    end
end

function GiveLayer:OnBtnConfirm()
    local user_id = self.ui_user_id:getString()
    local amount = self.ui_amount:getString()
    if user_id == "" then
        UIManager.ShowMsgBox(TR("ID不能为空"))
        return
    end

    local user_id_to_num =tonumber(user_id)
    if user_id_to_num == nil or user_id_to_num ~= math.floor(user_id_to_num) then
        self.ui_user_id:setString("")
        UIManager.ShowMsgBox(TR("请输入正确的ID"))
        return
    end

    local num = tonumber(amount)
    if num == nil then
        self.ui_amount:setString("0")
        self:OnInputBoxChanged()
        return
    end
    if (num ~= math.floor(num)) then
        UIManager.ShowMsgBox(TR("数值不能含有小数"))
        return
    end

    --检查额度
    if not self:CheckCoin(num) then
        local str = string.gsub(TR("最少赠送NNN金币，并且自身最少保留SSS金币"), "NNN", Tools.CoinToString(UserData.gift_min_money))
        local info = string.gsub(str, "SSS", Tools.CoinToString(UserData.gift_min_remain_money))
        UIManager.ShowMsgBox(info)
        return
    end

    if UserData.gift_max_money > 0 then
        local maxVal = UserData.gift_max_money / (1 + UserData.gift_fee)
        if num * sGameManager.exchangerate > maxVal then
            UIManager(Tools.Fmt(TR("单次最多赠送{0}金币"), maxVal / sGameManager.exchangerate))
            return
        end
    end

    local layer = PopLayer:Pop(InputGivePasswdLayer)
    layer:SetGiveTips(user_id, num, num * UserData.gift_fee)

    layer:OnInputPasswdDone(function(passwd)
        local real_money = num * sGameManager.exchangerate
        local show_money = real_money

        -- 加上手续费
        real_money = real_money * (1 + UserData.gift_fee)
        real_money = math.floor(real_money)

        self:HandleGive(
            user_id,
            real_money,
            passwd,
            show_money
        )
    end)
end

function GiveLayer:OnInputBoxChanged()
    local amount = Tools.StringToNumber(self.ui_amount:getString())
    local num
    if amount == "" then
        num = 0
    else
        num = tonumber(amount) or 0
    end
    if num < 0 then num = 0 end

    local fee = num * UserData.gift_fee
    local rest = UserData.money_safe + UserData.money - num - fee
    -- print("num", num, "fee", fee, "rest", rest)

    if rest < 0 then
        rest = 0
        num = (UserData.money_safe + UserData.money) / (1 + UserData.gift_fee)
    end
    self.ui_rest:setString(Tools.CoinToString(rest))
    if num == 0 then
        self.ui_amount:setString("")
    else
        self.ui_amount:setString(Tools.CoinToString(num))
    end
end

function GiveLayer:SetGiveID(id)
    self.ui_user_id:setString(id)
    self.ui_user_id:setEnabled(false)
end

function GiveLayer:SetGiveNickname(nickname)
    self.nickname = nickname
end

--检查金币是否符合要求
function GiveLayer:CheckCoin(num)
    num = num * sGameManager.exchangerate
	if num < UserData.gift_min_money then
		return false
	end
	local now_money = UserData.money_safe + UserData.money
    local send_money = math.floor(num * (1 + UserData.gift_fee))
	if now_money - send_money < UserData.gift_min_remain_money then
		return false
	end
	return true
end

function GiveLayer:HandleGive(user_id, money, passwd, show_money)
    go(function()
        local data_ = PKG_Client_Lobby_ClientGiftMoney.Create()
        data_.account_id  = user_id
        data_.money  = money
        data_.content  = passwd
        UIManager.ShowWaiting()
        local result =  gNet_SendRequest(data_)
        UIManager.HideWaiting()
        dump(result, "赠送结果")
        if result == nil then
            UIManager.ShowToast(TR("网络连接失败，请重试"))
            return
        end

        if getmetatable(result) == PKG_Lobby_Client_GiftMoneyResult then
            UserData.money_safe = result.money_safe
            UserData.money = result.money
            Dispatcher:Dispatch(UserData)
            UIManager.ShowMsgBox(
                self:Gsub(
                    TR("成功赠送NNN枚金币给AAA"),
                    {
                        NNN = Tools.CoinToString(show_money),
                        AAA = user_id
                    }
                ),
               function()
                   self:Close()
               end
            )
        elseif getmetatable(result) == PKG_Generic_Error then
            local num = result.number
            if num == Def.Net_GiveRecipientNot then
                UIManager.ShowMsgBox(TR("请输入正确的ID"))
            elseif num == Def.Net_GivePasswordError then
                UIManager.ShowMsgBox(TR("密码输入错误请重新输入"))
            elseif num == Def.Net_GiveInsufficientMoney 
                or num == Def.Net_GiveInsufficientMoney_1 
            then
                UIManager.ShowMsgBox(self:Gsub(
                    TR("最少赠送NNN金币，并且自身最少保留SSS金币"), {
                        NNN = Tools.CoinToString(UserData.gift_min_money),
                        SSS = Tools.CoinToString(UserData.gift_min_remain_money)
                }))
            elseif num == -26 then
                -- money cannot be maximum than xxxx.
                local maxVal = UserData.gift_max_money / (1 + UserData.gift_fee)
                UIManager.ShowMsgBox(Tools.Fmt(TR("单次最多赠送{0}金币"), maxVal / sGameManager.exchangerate))
            elseif num == -31 then
                -- you cannot gift
                UIManager.ShowMsgBox(TR("你不能赠送礼物"))
            elseif num == -10 then
                -- The doctor's account is insufficient
                UIManager.ShowMsgBox(TR("余额不足"))
            else
                UIManager.ShowMsgBox(TR("赠送金币失败"))
            end
        end
    end)
end

function GiveLayer:Gsub(fmt, tbl)
    for k,v in pairs(tbl) do
        fmt = string.gsub(fmt, tostring(k), tostring(v))
    end
    return fmt
end

function GiveLayer:OnBtnRecord()
    self:HandleGiveRecord()
end

function GiveLayer:HandleGiveRecord()
    go(function()
        
        local data_ = PKG_Client_Lobby_ClientGiftRecord.Create()
        UIManager.ShowWaiting()
        local result =  gNet_SendRequest(data_)
        UIManager.HideWaiting()
        dump(result, " ** result ** ")
        if result and getmetatable(result) == PKG_Lobby_Client_ReceivedGiftRecord then
            local layer = PopLayer:Pop(GiveHistoryLayer)
            layer:SetRecords(result)
        else
            UIManager.ShowToast(TR("获取赠送记录失败"))
        end
    end)
end

function GiveLayer:InitEdit(edit, placeholder)
	local new_edit = Tools.ReplaceEdit(edit,placeholder)
	new_edit:setFontSize(24)
    new_edit:setPlaceholderFontSize(24)
    new_edit:setInputMode(cc.EDITBOX_INPUT_MODE_SINGLELINE)
    new_edit:setFontColor(cc.c3b(255,255,255))
	new_edit:setPlaceholderFontColor(cc.c3b(118, 118, 118))
    new_edit:setTextHorizontalAlignment(cc.TEXT_ALIGNMENT_CENTER)
    return new_edit
end

return GiveLayer
