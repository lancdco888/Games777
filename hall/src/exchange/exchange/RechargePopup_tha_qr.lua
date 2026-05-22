--TODO : 需要处理 通知信息
local BankNameChooseNode = import(".BankNameChooseNode")

local RechargePopup_tha_qr = class("RechargePopup_tha_qr", function()
    return Tools.CreateLayer("csb/RechargePopup_tha_qr.csb")
end)

function RechargePopup_tha_qr:onEnter()
    self:InitUI()
end

function RechargePopup_tha_qr:OnBtnClose()
	self:Close()
end

function RechargePopup_tha_qr:InitUI()
    local popup = self:getChildByName("bg")

	-- 关闭按钮
	local btn_close = popup:getChildByName("btn_close")
    Tools.AddClickEvent(btn_close, function()
        self:OnBtnClose()
    end, true)

    -- 支付金额
    self.money = popup:getChildByName("pay_num")

    -- 付款人姓名输入框
    local input_name = popup:getChildByName("payer_name")
	input_name = Tools.ReplaceEdit(input_name)
	input_name:setInputMode(cc.EDITBOX_INPUT_MODE_SINGLELINE)
	input_name:setFontSize(24)
	input_name:setMaxLength(100)
	input_name:setPlaceholderFontSize(26)
	input_name:setReturnType(cc.KEYBOARD_RETURNTYPE_DONE)
	input_name:setTextHorizontalAlignment(cc.TEXT_ALIGNMENT_CENTER)
	self.input_name = input_name

    -- 卡号
    self.yhkh_input = Tools.ReplaceEdit(popup:getChildByName("card_number"))
    self.yhkh_input:setMaxLength(Recharge.Bank_MaxNumber)
    self.yhkh_input:setFontSize(24)
    self.yhkh_input:setInputMode(cc.EDITBOX_INPUT_MODE_NUMERIC)
	self.yhkh_input:setTextHorizontalAlignment(cc.TEXT_ALIGNMENT_CENTER)
    -- self.yhkh_input:registerScriptEditBoxHandler(self.EditCB)

    -- 提示信息
    self.tips = popup:getChildByName("tips")

    -- 确定按钮
    local btn_confirm = popup:getChildByName("_lang_btn_cg")
    Tools.AddClickEvent(btn_confirm, function()
        self:OnBtnConfirm()
    end, true)

    -- 放弃支付
    local btn_confirm = popup:getChildByName("_lang_btn_sb")
    Tools.AddClickEvent(btn_confirm, function()
		self:Close()
    end, true)

    self.btn_modify_name = self:findChild("_lang_modify_name")
    self.btn_modify_card = self:findChild("_lang_modify_card_number")
    Tools.AddClickEvent(self.btn_modify_card, function()
        self.yhkh_input:setEnabled(true)
        self.yhkh_input:setString("")
        self.bank_name_node:setModifyEnabled(true)
        self.bank_name_node:SetBankName("")
    end)
    Tools.AddClickEvent(self.btn_modify_name, function()
        self.input_name:setEnabled(true)
        self.input_name:setString("")
    end)

    self.btn_modify_name:setVisible(false)
    self.btn_modify_card:setVisible(false)

    self:InitQRCode()
    self:InitBankNameNode()
    self:InitBindInfo()
end

-- 如果已经绑定了银行卡信息，填写进去
function RechargePopup_tha_qr:InitBindInfo()
    -- TODO
    -- sGameManager.max_fix_realname_money = 122434343434

    local real_name_mode = sGameManager.is_open_realname_mode == 1
    if not real_name_mode then
        self.input_name:setString("")
        self.yhkh_input:setString("")
        self.input_name:setEnabled(true)
        self.yhkh_input:setEnabled(true)
        self.bank_name_node:setModifyEnabled(true)
        return
    end

    local info = RechargeLogic:GetBindInfo()
    local payer_name = info.payer_name
    if payer_name and payer_name ~= "" then
        self.input_name:setString(payer_name)
        self.input_name:setEnabled(false)
    end

    local bank_card = info.bank_card
    if bank_card and bank_card ~= "" then
        self.yhkh_input:setString(bank_card)
        self.yhkh_input:setEnabled(false)
        self.bank_name_node:setModifyEnabled(false)
        local can_modify = RechargeLogic:CanModifyBind()
        self.btn_modify_card:setVisible(can_modify)
    else
        self.yhkh_input:setString("")
        self.yhkh_input:setEnabled(true)
        self.bank_name_node:setModifyEnabled(true)
        self.btn_modify_card:setVisible(false)
    end
end

function RechargePopup_tha_qr:InitQRCode()
    local qr_code = self:findChild("qr_code")
    qr_code:setVisible(false)
    qr_code:retain()

    local lobby = BottomLayer:Get(LobbyLayer)
    local name = RechargeLogic:GetPayChannelName(self.pay_channel)
    if not name then
        release_print("get channel name failed:" .. tostring(self.pay_channel))
        return
    end

    local page = lobby.user_info.website
    if string.sub(page, -1) ~= "/" then
        page = page .. "/"
    end
    local url = string.format("%srecharge/%s/1.jpg", page, name)

    -- url 规则需要完善
    -- local url = "http://888fit.me/recharge/scb_saoma/1.jpg"
    release_print("qr code url:" .. url)

    local fu = cc.FileUtils:getInstance()
    local path_ = fu:getWritablePath() .. "/download/recharge_qr_img.png"

    go(function()
        local done = false
        local result = false
        xhttp_request(url,
            path_,
            function()
                done = true
                result = true
            end,
            function()
                done = true
                result = false
            end,
            function(rate) --progress
                print(rate)
            end
        )
        while not done do
            coroutine.yield()
        end

        if not fu:isFileExist(path_) then
            print("LoadImage Failed:" .. path_)
            return
        end

        cc.Director:getInstance():getTextureCache():reloadTexture(path_)
        qr_code:loadTexture(path_)
        qr_code:setVisible(true)

        qr_code:setTouchEnabled(true)
        Tools.AddClickEvent(qr_code,
            function()
                self:OnTouchQrCode(path_)
                end, true
            )

        qr_code:release()
    end)
end

function RechargePopup_tha_qr:InitBankNameNode()
    local node = self:findChild("bank_name")
    local bank_name_node = BankNameChooseNode.new(node)
    self.bank_name_node = bank_name_node

    local info = RechargeLogic:GetBindInfo()
    self.bank_name_node:SetBankName(info.bank_name or "")
end

function RechargePopup_tha_qr:OnTouchQrCode(file_path_)
    release_print("on touch qr code:" .. file_path_)
    local layer = PopLayer:Pop(service.ImageViewLayer)
    layer:setImagePath(file_path_)
end

function RechargePopup_tha_qr:setInfo(pay_channel, money, info)
    if not money or not pay_channel then
        UIManager.ShowToast("RechargePopup_tha_qr invalid data")
        self:Close()
        return
    end
    
    dump(UserData.pay_channel_accounts, " ** UserData.pay_channel_accounts ** ")
    dump(info , " ** info ** ")
    self.pay_channel = pay_channel
    -- self.tips:setString(self.datelist.description)

    self.money:setString(Tools.CoinToShowString(money))
    self.money_num = money

    self:InitQRCode()
    self:InitBankNameNode()

    -- 处理提示文字
    local description = ""
    if info and info.description then
        description = info.description
    end
    self.tips:setString(description)
end

-- 检查输入信息
function RechargePopup_tha_qr:checkInput()
    local name = self.input_name:getText()
    if name == "" then
        UIManager.ShowToast(TR("姓名不能为空，请输入正确的姓名"))
        return false
    elseif exutils.strIsBlank(name) then
        UIManager.ShowToast(TR("姓名不能全是空格，请输入正确的姓名"))
        return false
    end

    local paycard = self.yhkh_input:getString()
    if #paycard ~= Recharge.Bank_MinNumber and #paycard ~= Recharge.Bank_MaxNumber then
        UIManager.ShowMsgBox(string.format(TR("%d或%d位数的银行卡号"),Recharge.Bank_MinNumber, Recharge.Bank_MaxNumber))
        return false
    end

    local bankname = self.bank_name_node:GetBankName()
    --付款银行纯空格
    if exutils.strIsBlank(bankname) then
        UIManager.ShowMsgBox(TR("付款银行名不能全是空格"))
        return false
    end

    --付款银行未填
    if bankname == "" then
        UIManager.ShowMsgBox(TR("请输入开户行"))
        return false
    end
    return true
end

-- 检查是否需要绑定 或 修改绑定
function RechargePopup_tha_qr:checkBindInfo()
    local name = self.input_name:getText()
    local bank_card = self.yhkh_input:getString()
    local bank_name = self.bank_name_node:GetBankName()

    local info = RechargeLogic:GetBindInfo()
    if info.payer_name == name and info.bank_card == bank_card and info.bank_name == bank_name then
        return true
    end

    -- 开始绑定
    local ret = RechargeLogic:RealNameBind(name, bank_name, bank_card, nil)
    if ret then
        self:InitBindInfo()
    end
    return ret
end

function RechargePopup_tha_qr:sendRechargeInfo()
    go(function()
		local data_ = PKG_Client_Lobby_ClientRechargeRequest.Create()

		data_.money = self.money_num
		data_.pay_type = self.pay_channel
		data_.ip_info = ""
		data_.is_create_order = 1
        data_.pay_name = "nil"

		data_.pay_card_number = self.yhkh_input:getString()
		data_.upstream_order_num = ""
		data_.payment_key = ""

		UIManager.ShowWaiting()
		
        dump(data_, "data_")
		local rlt_ = gNet_SendRequest(data_)
        dump(rlt_, "rlt_")

        UIManager.HideWaiting()
        local PKG_name = getmetatable(rlt_)
		if PKG_name == PKG_Lobby_Client_ClientRechargeRequestSuccess then
            UIManager.ShowMsgBox(TR("请等待审核，3分钟内审核通过后系统会自动帮您冲入金币。如有疑问请联络客服查询!"))

            if not tolua.isnull(self) then
                self:Close()
            end
		elseif PKG_name == PKG_Generic_Error then
			local num = Int64ToNumber(rlt_.number)
			if (num == -120) then
				UIManager.ShowMsgBox(TR("您的上一笔支付订单我们正在审核操作中，请及时关注金币到账情况耐心等待！如有疑问请咨询客服。"))
			else
				UIManager.ShowMsgBox(TR("请求充值失败，请联系客服后重试"))
			end
		end
	end)
end

function RechargePopup_tha_qr:OnBtnConfirm()
    go(function()
        if not self:checkInput() then
            return
        end

        -- 检查绑定信息
        if not self:checkBindInfo() then
            return
        end

        -- 发送订单
        self:sendRechargeInfo()
    end)
end

return RechargePopup_tha_qr
