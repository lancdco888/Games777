local RechargeLogic = class("RechargeLogic")

function RechargeLogic:CanModifyBind()
    if sGameManager.is_open_realname_mode ~= 1 then
        return true
    end

    -- 小于这个数额，可以修改绑定
    return sGameManager.max_fix_realname_money > UserData.money + UserData.money_safe
end

function RechargeLogic:GetBindInfo()
    local bank_card
    local payer_name
    local bank_name
    local phone
    for key, value in ipairs(UserData.pay_channel_accounts) do
        if value.pay_channel_id == 2 then
            bank_card = value.card_number
            payer_name = value.name
            bank_name  = value.bank_name
        elseif value.pay_channel_id == 801 then
            if not payer_name then
                payer_name = value.name
            end
            phone = value.card_number
        end
    end
    return {
        payer_name = payer_name,
        bank_name = bank_name,
        bank_card = bank_card,
        phone = phone
    }
end

------------------------------------------------------------------------------

function RechargeLogic:BindPhoneNumber(realname, phone)
	local data_ = PKG_Client_Lobby_BandingRealNamePhoneInfo.Create()
	data_.phone = phone
	data_.payer_name = realname

	dump(data_, " ** data_ ** ")
	local rlt_ = gNet_SendRequest(data_)
	dump(rlt_, " ** rlt_ ** ")

	local PKG_name = getmetatable(rlt_)
	if PKG_name == PKG_Lobby_Client_BandingRealNameResult then
		UserData.pay_channel_accounts = rlt_.pay_channel_accounts
		Dispatcher:Dispatch(UserData)
		Dispatcher:Dispatch("BIND_INFO_RECHARGE")
		-- UIManager.ShowToast(TR("账号绑定成功"))
		return true
	elseif(PKG_name == PKG_Generic_Error) then
		local num = Int64ToNumber(rlt_.number)
		if num == -1 then -- 一般不会出现
			UIManager.ShowMsgBox(TR("重复绑定"))
		elseif num == -2 then -- 姓名不匹配
			UIManager.ShowMsgBox(TR("手机号姓名和银行卡姓名不一致"))
		else
			UIManager.ShowMsgBox(num .. rlt_.message)
		end
		return false
	end
	return false
end

function RechargeLogic:BindBankCard(realname, bankcard, bank_name)
    local data_ = PKG_Client_Lobby_BandingRealNameBankInfo.Create()
    data_.bankname = bank_name
    data_.payer_name = realname
    data_.payer_card_number = bankcard

	dump(data_, " ** data_ ** ")
	local rlt_ = gNet_SendRequest(data_)
	dump(rlt_, " ** rlt_ ** ")

	local PKG_name = getmetatable(rlt_)

	if PKG_name == PKG_Lobby_Client_BandingRealNameResult then
		UserData.pay_channel_accounts = rlt_.pay_channel_accounts
		Dispatcher:Dispatch(UserData)
		Dispatcher:Dispatch("BIND_INFO_RECHARGE")
		-- UIManager.ShowToast(TR("账号绑定成功"))
		return true
	elseif(PKG_name == PKG_Generic_Error) then
		local num = Int64ToNumber(rlt_.number)
		if num == -1 then -- 一般不会出现
			UIManager.ShowMsgBox(TR("重复绑定"))
		elseif num == -2 then -- 姓名不匹配
			UIManager.ShowMsgBox(TR("手机号姓名和银行卡姓名不一致"))
		else
			UIManager.ShowMsgBox(num .. rlt_.message)
		end
		return false
	end
	return false
end

-- 请求修改审批
function RechargeLogic:FixRealNameBind(payer_name, bank_name, payer_card_number, phone)
    local data_ = nil
    data_ = PKG_Client_Lobby_ApplyFixRealname.Create()
    data_.bankname = bank_name
    data_.payer_name = payer_name
    data_.payer_card_number = payer_card_number
    data_.phone = phone

	dump(data_, " ** data_ ** ")
    local rlt_ = gNet_SendRequest(data_)
	dump(rlt_, " ** rlt_ ** ")

    if(rlt_ ~= nil) then
        --收到返回数据
        local PKG_name = getmetatable(rlt_)
        if PKG_name == PKG_Generic_Success then
            UIManager.ShowToast(TR("修改成功!"))
            return true
        elseif(PKG_name == PKG_Generic_Error) then
            local num = Int64ToNumber(rlt_.number)
            if num == -2000 then -- 一般不会出现
                UIManager.ShowMsgBox(TR("请勿重复提交，请耐心等待!"))
                return false
            else
                UIManager.ShowMsgBox(num .. rlt_.message)
                return false
            end
        end
    end
    return false
end

-- 绑定总入口
function RechargeLogic:RealNameBind(payer_name, bank_name, bank_card, phone)
    local info = self:GetBindInfo()

    if ( bank_name and bank_name ~= "" and bank_name ~= info.bank_name ) or ( bank_card and bank_card ~= "" and bank_card ~= info.bank_card ) then
        if info.bank_name and info.bank_name ~= "" then
            -- 非首次绑定
            return self:FixRealNameBind(
                payer_name or info.payer_name,
                bank_name or info.bank_name or "",
                bank_card or info.bank_card or "",
                phone or info.phone or "")
        else
            local ret = self:BindBankCard(payer_name, bank_card, bank_name)
            if not ret then
                return false
            end
        end
    end

    if phone and phone ~= "" and phone ~= info.phone then
        if info.phone and info.phone ~= "" then
            -- 非首次绑定
            return self:FixRealNameBind(
                payer_name or info.payer_name,
                bank_name or info.bank_name,
                bank_card or info.bank_card,
                phone or info.phone)
        else
            local ret = self:BindPhoneNumber(payer_name, phone)
            if not ret then
                return false
            end
        end
    end
    return true
end

------------------------------------------------------------------------------

function RechargeLogic:GetPayChannelName(pay_channel)
    for _, info in pairs(sGameManager.payChannels) do
        if info.id == pay_channel then
            return info.name
        end
    end
    return nil
end

function RechargeLogic:GuessBindName()
    local info = self:GetBindInfo()
    return info.payer_name
end

function RechargeLogic:CheckNeedBind(pay_channel, realname, card_number)
    local info = RechargeLogic:GetBindInfo(pay_channel)
    if info.name == realname and info.card_number == card_number then
        return false
    end
    return true
end

return RechargeLogic
