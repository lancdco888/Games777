local BankNameChooseNode = import(".BankNameChooseNode")
local PlayerActionLimiter = require("hall.src.exchange.exchange.PlayerActionLimiter")

local LobbyRechargeLayer = class("LobbyRechargeLayer", function()
    return Tools.CreateLayer("csb/LobbyRechargeLayer.csb")
end)

function LobbyRechargeLayer:onEnter()
    self:InitUI()
	Dispatcher:Register("BIND_INFO_RECHARGE", function()
		if ConfigParam.Region == "tha" then
			self:UpdateRecharge(self.cur_recharge_options_ID)
		end
	end, self)

	self:SelectDefaultRecharge()

end

function LobbyRechargeLayer:onExit()
    Dispatcher:Remove(self)
end

function LobbyRechargeLayer:InitUI()
	--当前充值选项
	self.cur_recharge_options_ID = nil
	--充值模式数量
	local model_number = 9
	self.region_str = "popup_1"
	local popup = self:getChildByName(self.region_str)
	popup:setVisible(true)
	self.popup = popup
	--
	local btn_close = popup:getChildByName("btn_close")
    Tools.AddClickEvent(btn_close, function()
        self:OnBtnClose(model_number)
    end, true)
	self.btn_ok = popup:getChildByName("_lang_btn_ok")
    Tools.AddClickEvent(self.btn_ok, function()
        self:OnBtnRecharge()
    end, true, 1.3)

	--初始化充值按钮列表
	self:InitList()
	--model列表
	self.list_model = {}
	--不同充值界面初始化(参数代表有几种显示方式)
	self:ModelLayerInit(model_number)
end

--初始化充值按钮列表
function LobbyRechargeLayer:InitList()
	local popup = self:getChildByName(self.region_str)
	self.ui_rechargeOptions_list 	= popup:getChildByName("ListView_1")
	self.ui_rechargeOptions_item 	= self.ui_rechargeOptions_list:getChildByName("item")
	self.ui_rechargeOptions_item:retain()
	self.ui_rechargeOptions_list:removeAllItems()
	-- dump(sGameManager.payChannels,"sGameManager.payChannels")
	if not sGameManager.payChannels then
		assert(false)
		return
	end

	for _,value in ipairs(sGameManager.payChannels) do
		local cfg = RechargeGetChannelCfg(value.id)
		if not cfg then
			goto __CONTINUE__
		end

        local button 		= cfg.button
        local button_touch 	= cfg.button_touch
		local new_item = self.ui_rechargeOptions_item:clone()
		new_item:setTag(value.id)
		local btn_recharge = new_item:getChildByName("btn_recharge")
		btn_recharge:loadTextureNormal(button, 0)
		btn_recharge:loadTexturePressed(button, 0)
		btn_recharge:loadTextureDisabled(button_touch,0)
		Tools.AddClickEvent(btn_recharge,
			function()
				self:GetRechargeKey(value.id)
			end, true
		)
		self.ui_rechargeOptions_list:pushBackCustomItem(new_item)

		::__CONTINUE__::
	end

	if sGameManager.is_open_realname_mode == 1 then
		--绑定账号按钮
		local binditem = self.ui_rechargeOptions_item:clone()
		binditem:setName("bind")
		local btn_bind = binditem:getChildByName("btn_recharge")
		btn_bind:loadTextureNormal(Recharge.RechargeChannelListData["bind"].button, 0)
		btn_bind:loadTexturePressed(Recharge.RechargeChannelListData["bind"].button, 0)
		btn_bind:loadTextureDisabled(Recharge.RechargeChannelListData["bind"].button_touch,0)
		btn_bind:setTitleText(TR("绑定账户"))
		AdaptButton(btn_bind)
		Tools.AddClickEvent(btn_bind,
				function()
					local layer = PopLayer:Pop(BindInfoLayer)
				end, true)
		self.ui_rechargeOptions_list:pushBackCustomItem(binditem)
	end
end

function LobbyRechargeLayer:SelectDefaultRecharge()
	for _,value in ipairs(sGameManager.payChannels) do
		local id = value.id
		if id then
			release_print("LobbyRechargeLayer: Try GetRechargeKey ...")
			self:GetRechargeKey(id)
			return true
		end
	end
	release_print("LobbyRechargeLayer: Select DefaultRechargeID failed.")
	return false
end

--不同充值右侧界面初始化
function LobbyRechargeLayer:ModelLayerInit(number)
	for i = 1, number do
		local model = self:getChildByName("model_" .. tostring(i))
		model:setVisible(false)
		self.list_model[i] = model
	end
	--普通充值（只有第四方充值，横版按钮布局）
	self:ModelInit_1or2(self.list_model[1])
	--横版google充值
	self:ModelInit_6or7(self.list_model[7])
	--普通充值（不仅有第四方充值，还有其他充值方式，竖版按钮布局）
	self:ModelInit_1or2(self.list_model[2])
	--越南填写转账充值（6排内容，无金额按钮）
	self:ModelInit_3or5(self.list_model[3])
	--充值内置联系方式列表
	self:ModelInit_4()
	--越南填写转账充值（5排内容，无金额按钮）
	self:ModelInit_3or5(self.list_model[5])
	--竖版google充值
	self:ModelInit_6or7(self.list_model[6])

	--trc充值
	self:ModelInit_8(self.list_model[8])

	-- 泰国的充值，需要从下拉选择银行名称，用于实名绑定
	self:ModelInit_9(self.list_model[9])
end

--普通充值（只有第四方充值国家，横版按钮布局,竖版按钮布局,通用）
function LobbyRechargeLayer:ModelInit_1or2(model_)
	--数量选择区域
	local input = model_:getChildByName("money_input")
	input = Tools.ReplaceEdit(input)
	input:setInputMode(cc.EDITBOX_INPUT_MODE_SINGLELINE)
	input:setFontSize(36)
	input:setMaxLength(20)
	input:setPlaceholderFontSize(30)
	input:setReturnType(cc.KEYBOARD_RETURNTYPE_DONE)
	input:setTextHorizontalAlignment(cc.TEXT_ALIGNMENT_CENTER)
	model_.input = input
	model_.input:onEvent(function(eventname, sender)
		if eventname ~= "return" then
			return
		end
		--检查输入值的合法性
		local input_txt = model_.input:getString()
		local num = tonumber(input_txt)
		if not num or num <= 0 then
			num = 0
			sGameManager.recharge_data.is = false
		else
			num = math.floor(num)
			sGameManager.recharge_data.is = true
			num = num * sGameManager.exchangerate
			if(num < sGameManager.recharge_min_money)then
				num = sGameManager.recharge_min_money
			elseif(num > sGameManager.recharge_max_money)then
				num = sGameManager.recharge_max_money
			end
		end
		sGameManager.recharge_data.money = num
		--修正输入值
		model_.input:setString(num / sGameManager.exchangerate)
	end)
	--
	model_.money_text = model_:getChildByName("money_text")
	model_.input:setVisible(false)
	model_.money_text:setVisible(false)

	--金额按钮列表
	model_.amount_list = model_:getChildByName("ScrollView_1")
	model_.amount_item = model_.amount_list:getChildByName("item")
	model_.amount_item:retain()
	model_.amount_list = Tools.ReplaceScrollView(model_.amount_list)
	model_.amount_list:setItemModel(model_.amount_item)
	model_.amount_list:setScrollBarEnabled(false)
	model_.amount_list:removeAllChildren()
end

--越南填写转账充值（5排或6排内容，无金额按钮）
function LobbyRechargeLayer:ModelInit_3or5(model_)
	--付款人姓名
	local input = model_:getChildByName("input_payer_name")
	input = Tools.ReplaceEdit(input)
	input:setInputMode(cc.EDITBOX_INPUT_MODE_SINGLELINE)
	input:setFontSize(22)
	input:setMaxLength(20)
	input:setPlaceholderFontSize(24)
	input:setReturnType(cc.KEYBOARD_RETURNTYPE_DONE)
	input:setTextHorizontalAlignment(cc.TEXT_ALIGNMENT_CENTER)
	model_.input_payer_name = input

	--付款人卡号
	local input_1 = model_:getChildByName("input_payer_card")
	input_1 = Tools.ReplaceEdit(input_1)
	input_1:setInputMode(cc.EDITBOX_INPUT_MODE_NUMERIC)
	input_1:setFontSize(22)
	input_1:setMaxLength(20)

	if ConfigParam.Region == "tha" then
		input_1:setMaxLength(Recharge.Bank_MaxNumber)
	end

	input_1:setPlaceholderFontSize(24)
	input_1:setReturnType(cc.KEYBOARD_RETURNTYPE_DONE)
	input_1:setTextHorizontalAlignment(cc.TEXT_ALIGNMENT_CENTER)
	model_.input_payer_card = input_1

	--付款金额
	local input_2 = model_:getChildByName("input_money")
	input_2 = Tools.ReplaceEdit(input_2)
	input_2:setFontSize(22)
	input_2:setMaxLength(16)
	input_2:setPlaceholderFontSize(24)
	input_2:setReturnType(cc.KEYBOARD_RETURNTYPE_DONE)
	input_2:setInputMode(cc.EDITBOX_INPUT_MODE_SINGLELINE)
	input_2:setTextHorizontalAlignment(cc.TEXT_ALIGNMENT_CENTER)
	model_.input_money = input_2

	--复制收款人
	local copy_recver = model_:getChildByName("_lang_copy_name")
	Tools.AddClickEvent(copy_recver, function()
		local name = ""
		for index, value in ipairs(sGameManager.vipChannels) do
			if value.pay_channel_id == self.cur_recharge_options_ID then
				name = value.bank_name
			end
		end
        Device:CopyString(name)
		UIManager.ShowToast(TR_("复制成功"))
    end, true)

	--复制收款账号
	local copy_acc = model_:getChildByName("_lang_copy_acc")
	Tools.AddClickEvent(copy_acc, function()
		local acc = ""
		for index, value in ipairs(sGameManager.vipChannels) do
			if value.pay_channel_id == self.cur_recharge_options_ID then
				acc = value.account
			end
		end
        Device:CopyString(acc)
		UIManager.ShowToast(TR_("复制成功"))
    end, true)

	--复制输入金额
	local copy_money = model_:getChildByName("_lang_copy_money")
	Tools.AddClickEvent(copy_money, function()
        Device:CopyString(model_.input_money:getText())
		UIManager.ShowToast(TR_("复制成功"))
    end, true)

	--复制支付Key
	local copy_key = model_:getChildByName("_lang_copy_content")
	if copy_key then
		Tools.AddClickEvent(copy_key, function()
			Device:CopyString(self.pay_key_)
			UIManager.ShowToast(TR_("复制成功"))
		end, true)
	end
end

-- 泰国充值，从下拉选择银行名称，用于实名绑定
function LobbyRechargeLayer:ModelInit_9(model_)
	--付款人姓名
	local input = model_:getChildByName("input_payer_name")
	input = Tools.ReplaceEdit(input)
	input:setInputMode(cc.EDITBOX_INPUT_MODE_SINGLELINE)
	input:setFontSize(22)
	input:setMaxLength(20)
	input:setPlaceholderFontSize(24)
	input:setReturnType(cc.KEYBOARD_RETURNTYPE_DONE)
	input:setTextHorizontalAlignment(cc.TEXT_ALIGNMENT_CENTER)
	model_.input_payer_name = input

	--付款人卡号
	local input_1 = model_:getChildByName("input_payer_card")
	input_1 = Tools.ReplaceEdit(input_1)
	input_1:setInputMode(cc.EDITBOX_INPUT_MODE_NUMERIC)
	input_1:setFontSize(22)
	input_1:setMaxLength(20)

	if ConfigParam.Region == "tha" then
		input_1:setMaxLength(Recharge.Bank_MaxNumber)
	end

	input_1:setPlaceholderFontSize(24)
	input_1:setReturnType(cc.KEYBOARD_RETURNTYPE_DONE)
	input_1:setTextHorizontalAlignment(cc.TEXT_ALIGNMENT_CENTER)
	model_.input_payer_card = input_1

	-- 付款银行
	local node = model_:getChildByName("bank_name_choose")
	if node then
		model_.bank_name_node = self:InitBankNameNode(node)
		model_.bank_name_node:SetDropHandler(function(drop)
			model_.input_payer_card:setEnabled(not drop)
			model_.input_payer_card:setVisible(not drop)

			model_.input_money:setEnabled(not drop)
			model_.input_money:setVisible(not drop)

			local listview_ = model_:getChildByName("listview")
			listview_:setVisible(not drop)
		end)
	end

	-- 修改绑定按钮
	local modify_bind_btn = model_:getChildByName("_lang_modify_bind")
	model_.modify_bind_btn = modify_bind_btn

	if modify_bind_btn then
		Tools.AddClickEvent(modify_bind_btn, function()
			model_.input_payer_card:setString("")
			model_.input_payer_card:setEnabled(true)

			model_.bank_name_node:SetBankName("")
			model_.bank_name_node:setModifyEnabled(true)
		end)
	end

	if modify_bind_btn then
		modify_bind_btn:setVisible(false)
	end

	--付款金额
	local input_2 = model_:getChildByName("input_money")
	input_2 = Tools.ReplaceEdit(input_2)
	input_2:setFontSize(22)
	input_2:setMaxLength(16)
	input_2:setPlaceholderFontSize(24)
	input_2:setReturnType(cc.KEYBOARD_RETURNTYPE_DONE)
	input_2:setInputMode(cc.EDITBOX_INPUT_MODE_SINGLELINE)
	input_2:setTextHorizontalAlignment(cc.TEXT_ALIGNMENT_CENTER)
	model_.input_money = input_2

	--复制收款人
	local copy_recver = model_:getChildByName("_lang_copy_name")
	Tools.AddClickEvent(copy_recver, function()
		local name = ""
		for index, value in ipairs(sGameManager.vipChannels) do
			if value.pay_channel_id == self.cur_recharge_options_ID then
				name = value.bank_name
			end
		end
        Device:CopyString(name)
		UIManager.ShowToast(TR_("复制成功"))
    end, true)

	--复制收款账号
	local copy_acc = model_:getChildByName("_lang_copy_acc")
	Tools.AddClickEvent(copy_acc, function()
		local acc = ""
		for index, value in ipairs(sGameManager.vipChannels) do
			if value.pay_channel_id == self.cur_recharge_options_ID then
				acc = value.account
			end
		end
        Device:CopyString(acc)
		UIManager.ShowToast(TR_("复制成功"))
    end, true)

	--复制输入金额
	local copy_money = model_:getChildByName("_lang_copy_money")
	Tools.AddClickEvent(copy_money, function()
        Device:CopyString(model_.input_money:getText())
		UIManager.ShowToast(TR_("复制成功"))
    end, true)

	--复制支付Key
	local copy_key = model_:getChildByName("_lang_copy_content")
	if copy_key then
		Tools.AddClickEvent(copy_key, function()
			Device:CopyString(self.pay_key_)
			UIManager.ShowToast(TR_("复制成功"))
		end, true)
	end
end

function LobbyRechargeLayer:InitBankNameNode(root)
    local bank_name_node = BankNameChooseNode.new(root)

    local info = RechargeLogic:GetBindInfo()
    bank_name_node:SetBankName(info.bank_name or "")

	return bank_name_node
end

--google充值(横竖版通用一个)
function LobbyRechargeLayer:ModelInit_6or7(model_)
	--金额按钮列表
	model_.amount_list = model_:getChildByName("ScrollView_1")
	model_.amount_item = model_.amount_list:getChildByName("item")
	model_.amount_item:retain()
	model_.amount_list = Tools.ReplaceScrollView(model_.amount_list)
	model_.amount_list:setItemModel(model_.amount_item)
	model_.amount_list:setScrollBarEnabled(false)
	model_.amount_list:removeAllChildren()
	--充值按钮
	local OK = model_:getChildByName("_lang_btn_ok")
	if OK then
		Tools.AddClickEvent(OK, function()
			self:OnBtnRecharge()
		end, true)
	end
end

-- trc充值
function LobbyRechargeLayer:ModelInit_8(model_)
	--金额按钮列表
	model_.amount_list = model_:getChildByName("ScrollView_1")
	model_.amount_item = model_.amount_list:getChildByName("item")
	model_.amount_item:retain()
	model_.amount_list = Tools.ReplaceScrollView(model_.amount_list)
	model_.amount_list:setItemModel(model_.amount_item)
	model_.amount_list:setScrollBarEnabled(false)
	model_.amount_list:removeAllChildren()
	--充值按钮
	local OK = model_:getChildByName("_lang_btn_ok")
	if OK then
		Tools.AddClickEvent(OK, function()
		end, true)
	end
end

--充值内置联系方式列表
function LobbyRechargeLayer:ModelInit_4()
	local id = self.list_model[4]:getChildByName("id")
	id:setString(tostring(UserData.id))
	--复制自身ID
	local copy_id = self.list_model[4]:getChildByName("_lang_copy_self")
	Tools.AddClickEvent(copy_id, function()
		sGameManager.CopyUserID()
		UIManager.ShowMsgBox(TR("复制成功"))
    end, true)
	--联系方式表
	self.list_model[4].list_service = self.list_model[4]:getChildByName("ScrollView_1")
	self.list_model[4].list_item = self.list_model[4].list_service:getChildByName("item")
	self.list_model[4].list_item:retain()
	self.list_model[4].list_service = Tools.ReplaceScrollView(self.list_model[4].list_service)
	self.list_model[4].list_service:setItemModel(self.list_model[4].list_item)
	self.list_model[4].list_service:setScrollBarEnabled(false)
	self.list_model[4].list_service:removeAllChildren()
end

--刷新充值按钮列表
function LobbyRechargeLayer:UpdateRechargeOptions(recharge_ID)
	--上一个按钮回归正常
	if self.cur_recharge_options_ID then
		local item = self.ui_rechargeOptions_list:getChildByTag(self.cur_recharge_options_ID)
		local btn_recharge = item:getChildByName("btn_recharge")
		btn_recharge:setEnabled(true)
		btn_recharge:setTouchEnabled(true)
	end
	--当前按下按钮禁用
	if recharge_ID then
		local item = self.ui_rechargeOptions_list:getChildByTag(recharge_ID)
		local btn_recharge = item:getChildByName("btn_recharge")
		btn_recharge:setEnabled(false)
		btn_recharge:setTouchEnabled(false)
	end
end

--刷新充值界面
function LobbyRechargeLayer:UpdateRecharge(recharge_ID)
	release_print("LobbyRechargeLayer:UpdateRecharge():" .. tostring(recharge_ID))

	--刷新充值按钮列表
	self:UpdateRechargeOptions(recharge_ID)
	--改变当前渠道状态
	self.cur_recharge_options_ID = recharge_ID
	if not self.list_model then
		return
	end

	local cfg_ID = RechargeGetCfgId(recharge_ID)

	--根据ID判断显示Model
	local model_ = self.list_model[1]
	local model_id = 1
	if cfg_ID <= 100 then
		--右侧信息列表+无金额显示+无跳转+可能有二级
		model_ = self.list_model[4]
		model_id = 4
	elseif cfg_ID <= 200 then
		--右侧金额显示，google等sdk充值(101~200)
		model_ = self.list_model[6]
		model_id = 6
	elseif cfg_ID <= 500 then
		--右侧金额显示，跳转浏览器扫码充值(201~300)
		--右侧金额显示，二级弹窗补充充值信息(301~400)
		--早期第四方充值，金额+跳转浏览器拉起第四方apk(401~500)
		if ConfigParam.Region == "ind" or ConfigParam.Region == "vn" or ConfigParam.Region == "tha" then
			model_ = self.list_model[2]
			model_id = 2
		else
			model_ = self.list_model[1]
			model_id = 1
		end
	elseif cfg_ID <= 700 then
		--信息显示+直接填写信息+可能通过浏览器跳转拉起第四方apk(501~600)
		--信息显示+直接填写信息+浏览器跳转扫码,并改变按钮+返回点击发送补充充值信息(601~700)
		if ConfigParam.Region == "tha" then
			model_ = self.list_model[9]
			model_id = 9
		else
			model_ = self.list_model[3]
			model_id = 3
		end
	elseif cfg_ID <= 800 then
		--信息列表+二级弹窗填写补充充值信息(701~800)
		model_ = self.list_model[4]
		model_id = 4
	elseif cfg_ID <= 900 then
		--信息显示+直接填写信息+只用填写4项(801~900):注意仅越南地区为6项(除momo，zalo为5项)
		if ConfigParam.Region == "vn" then
			if Recharge.YN_List[cfg_ID] then
				model_ = self.list_model[5]
				model_id = 5
			else
				model_ = self.list_model[3]
				model_id = 3
			end
		else
			model_ = self.list_model[5]
			model_id = 5
		end
	elseif cfg_ID <= 1000 then
		--信息列表+二级弹窗填写补充充值信息(901~1000)
		model_ = self.list_model[4]
		model_id = 4
	elseif cfg_ID <= 1300 then
		--右侧金额显示，二级弹窗补充充值信息(1001~1100)
		--右侧金额显示，跳转浏览器(1101~1200)
		--右侧金额显示，跳转浏览器(1201~1300),第四方充值
		if ConfigParam.Region == "ind" or ConfigParam.Region == "vn" or ConfigParam.Region == "tha" then
			model_ = self.list_model[2]
			model_id = 2
		else
			model_ = self.list_model[1]
			model_id = 1
		end
	elseif cfg_ID <= 1400 then
		--右侧金额显示，二级弹窗补充充值信息(1300~1400)
		model_ = self.list_model[1]
		model_id = 1
	elseif Recharge.IsVirtualCoin(cfg_ID) then
		-- 虚拟货币
		model_ = self.list_model[8]
		model_id = 8
		sGameManager.recharge_data.is 			= false
		sGameManager.recharge_data.product_id 	= nil
		sGameManager.recharge_data.money 		= nil
    elseif Recharge.IsWWWPay(cfg_ID) then
        -- WWW 支付
        model_ = self.list_model[1]
        model_id = 1
    end
	self:ChangeModelsShow(model_,recharge_ID,model_id)
end

--根据充值渠道不同更换一些model的显示
function LobbyRechargeLayer:ChangeModelsShow(model_,recharge_ID,model_id)
	local list = {}
	for i = 1,#sGameManager.vipChannels do
		if (sGameManager.vipChannels[i].pay_channel_id == recharge_ID) then
			local data_ = sGameManager.vipChannels[i]
			table.insert(list,data_)
		end
	end
	for index, value in ipairs(self.list_model) do
		if index == model_id then
			value:setVisible(true)
		else
			value:setVisible(false)
		end
	end
	--更换一些显示图片
	-- 可能已经没用了

	local cfg = RechargeGetChannelCfg(self.cur_recharge_options_ID)
	if not cfg then
		UIManager.ShowToast("found cfg failed for:" .. tostring(self.cur_recharge_options_ID))
		return
	end

	local icon_path		= cfg.icon
	local icon_font_path= cfg.icon_font

	local fileUtils = cc.FileUtils:getInstance()

	if model_id == 1 or model_id == 2 then
		self.btn_ok:setVisible(true)
		--清空输入
		model_.input:setString("")
		model_.money_text:setString("")
		model_.input:setVisible(true)
		model_.money_text:setVisible(false)
		if icon_path then
			local icon = model_:getChildByName("icon")
			if fileUtils:fullPathForFilename(icon_path) ~= "" then
				Tools.LoadTexture(icon, icon_path)
			end
		else
			print("error: icon_font_path 没有")
		end

		local icon_font = model_:getChildByName("icon_font")
		icon_font:setVisible(true)
		if icon_font_path then
			if fileUtils:fullPathForFilename(icon_font_path) ~= "" then
				Tools.LoadTexture(icon_font, icon_font_path)
			end
		else
			print("error: icon_font_path 没有")
		end

		--金额列表显示
		model_.amount_list:removeAllChildren()
		local rechargeAmountList = sGameManager.rechargeAmountList[self.cur_recharge_options_ID]
		--添加金额按钮
		for _,value in ipairs(rechargeAmountList) do
			local new_item = model_.amount_list:pushBackDefaultItem()
			local btn_money = new_item:getChildByName("btn_money")
			local show_money = value.money
			local strTem = show_money/sGameManager.exchangerate
			if show_money>=1000*sGameManager.exchangerate then
				show_money = show_money/1000
				strTem = show_money/sGameManager.exchangerate .. "k"
			end
			btn_money:getChildByName("fnt"):setString(strTem)
			Tools.AddClickEvent(btn_money,
				function()
					local strTem = tostring(value.money / sGameManager.exchangerate)
					model_.input:setString(strTem)
					model_.money_text:setString(strTem)
					sGameManager.recharge_data.is 			= true
					sGameManager.recharge_data.product_id 	= value.product_id
					sGameManager.recharge_data.money 		= value.money
				end, true)
		end
		model_.amount_list:doLayout()
	elseif model_id == 3 or model_id == 5 then
		sGameManager.recharge_data.is = true
		self.btn_ok:setVisible(true)
		--清空输入
		model_.input_payer_name:setString("")
		model_.input_payer_name:setString(self:GetLastName(recharge_ID))
		model_.input_payer_card:setString("")
		model_.input_payer_card:setString(self:GetLastAcc(recharge_ID))
		if model_.modify_bind_btn then
			model_.modify_bind_btn:setVisible(false)
		end

		model_.input_money:setString("")
		local bank_name = model_:getChildByName("bank_name")
		local bank_acc = model_:getChildByName("bank_acc")
		local listview_ = model_:getChildByName("listview")
		if not model_.text_item then
			model_.text_item = listview_:getChildByName("text")
			model_.text_item:retain()
		end
		if ConfigParam.Region == "vn" then
			if not Recharge.YN_List[recharge_ID] then
				local key_text = model_:getChildByName("content")
				if not self.pay_key_ then
					self.pay_key_ = ""
				end
				key_text:setString(self.pay_key_)
			end
		end

		listview_:removeAllItems()
		if list[1] then
			local new_text = model_.text_item:clone()
			bank_name:setString(tostring(list[1].bank_name))
			bank_acc:setString(tostring(list[1].account))
			new_text:setString(tostring(list[1].description))
			local size = new_text:getContentSize()
			local real_size = new_text:getVirtualRendererSize()
			if real_size.width < size.width then
				size.width = 0
			end
			size.height = 0
			new_text:setTextAreaSize(size)
			new_text:ignoreContentAdaptWithSize(false)
			size = new_text:getVirtualRendererSize()
			new_text:ignoreContentAdaptWithSize(true)
			new_text:setContentSize(size)
			listview_:pushBackCustomItem(new_text)
		end
	elseif model_id == 9 then
		-- 这段代码和 3、5 差不多一样，只是处理了 银行卡选择和绑定的问题
		sGameManager.recharge_data.is = true
		self.btn_ok:setVisible(true)
		--清空输入
		model_.input_payer_name:setString("")
		model_.input_payer_name:setString(self:GetLastName(recharge_ID))
		model_.input_payer_card:setString("")
		model_.input_payer_card:setString(self:GetLastAcc(recharge_ID))
		if model_.modify_bind_btn then
			model_.modify_bind_btn:setVisible(false)
		end

		model_.input_money:setString("")
		local bank_name = model_:getChildByName("bank_name")
		local bank_acc = model_:getChildByName("bank_acc")
		local listview_ = model_:getChildByName("listview")
		if not model_.text_item then
			model_.text_item = listview_:getChildByName("text")
			model_.text_item:retain()
		end

		if ConfigParam.Region == "tha" then
			local info = RechargeLogic:GetBindInfo()
			model_.input_payer_card:setString(info.bank_card or "")
			model_.bank_name_node:SetBankName(info.bank_name or "")
			model_.input_payer_name:setString(info.payer_name or "")

			local can_modify = RechargeLogic:CanModifyBind()
			if not info.bank_card or info.bank_card == "" then
				-- 尚未绑定
				model_.modify_bind_btn:setVisible(false)

				model_.input_payer_card:setEnabled(true)
				model_.bank_name_node:setModifyEnabled(true)
				model_.input_payer_name:setEnabled(true)
			else
				model_.modify_bind_btn:setVisible(can_modify)

				model_.input_payer_card:setEnabled(false)
				model_.bank_name_node:setModifyEnabled(false)
				model_.input_payer_name:setEnabled(false)
			end
		end

		listview_:removeAllItems()
		if list[1] then
			local new_text = model_.text_item:clone()
			bank_name:setString(tostring(list[1].bank_name))
			bank_acc:setString(tostring(list[1].account))
			new_text:setString(tostring(list[1].description))
			local size = new_text:getContentSize()
			local real_size = new_text:getVirtualRendererSize()
			if real_size.width < size.width then
				size.width = 0
			end
			size.height = 0
			new_text:setTextAreaSize(size)
			new_text:ignoreContentAdaptWithSize(false)
			size = new_text:getVirtualRendererSize()
			new_text:ignoreContentAdaptWithSize(true)
			new_text:setContentSize(size)
			listview_:pushBackCustomItem(new_text)
		end
	elseif model_id == 4 then
		sGameManager.recharge_data.is = true
		self.btn_ok:setVisible(false)
		--添加联系方式列表
		model_.list_service:removeAllChildren()
		--添加金额按钮
		for _,value in ipairs(list) do
			local new_item = model_.list_service:pushBackDefaultItem()
			local copy = new_item:getChildByName("_lang_copy")
			Tools.AddClickEvent(copy,function()
				Device:CopyString(value.account)
				UIManager.ShowToast(TR_("复制成功"))
			end, true)
			local text = new_item:getChildByName("text")
			text:setString(value.account)
			local icon_1 = new_item:getChildByName("icon")

			if fileUtils:fullPathForFilename(Recharge.ServiceIcon[value.type]) ~= "" then
				icon_1:loadTexture(Recharge.ServiceIcon[value.type])
			end
		end
		model_.list_service:doLayout()
	elseif model_id == 6 or model_id == 7 then
		self.btn_ok:setVisible(true)
		--渠道图标
		local icon = model_:getChildByName("icon")
		if fileUtils:fullPathForFilename(icon_path) ~= "" then
			Tools.LoadTexture(icon, icon_path)
		end

		local icon_font = model_:getChildByName("icon_font")
		icon_font:setVisible(true)
		if fileUtils:fullPathForFilename(icon_font_path) ~= "" then
			Tools.LoadTexture(icon_font, icon_font_path)
		end

		--金额列表显示
		model_.amount_list:removeAllChildren()
		local rechargeAmountList = sGameManager.rechargeAmountList[self.cur_recharge_options_ID]
		--添加金额按钮
		for _,value in ipairs(rechargeAmountList) do
			local new_item = model_.amount_list:pushBackDefaultItem()
			local btn_money = new_item:getChildByName("btn_money")
			local strTem = Tools.CoinToShowString(value.money)
			btn_money:getChildByName("fnt"):setString(strTem)
			Tools.AddClickEvent(btn_money,
				function()
					sGameManager.recharge_data.is 			= true
					sGameManager.recharge_data.product_id 	= value.product_id
					sGameManager.recharge_data.money 		= value.money
				end, true)
		end
		model_.amount_list:doLayout()
		--提示信息
		local listview_ = model_:getChildByName("listview")
		if not model_.text_item then
			model_.text_item = listview_:getChildByName("text")
			model_.text_item:retain()
		end
		listview_:removeAllItems()
		if list[1] then
			local new_text = model_.text_item:clone()
			new_text:setString(tostring(list[1].description))
			local size = new_text:getContentSize()
			local real_size = new_text:getVirtualRendererSize()
			if real_size.width < size.width then
				size.width = 0
			end
			size.height = 0
			new_text:setTextAreaSize(size)
			new_text:ignoreContentAdaptWithSize(false)
			size = new_text:getVirtualRendererSize()
			new_text:ignoreContentAdaptWithSize(true)
			new_text:setContentSize(size)
			listview_:pushBackCustomItem(new_text)
		end
	elseif model_id == 8 then
		self.btn_ok:setVisible(false)

		if icon_path then
			local icon = model_:getChildByName("icon")
			if fileUtils:fullPathForFilename(icon_path) ~= "" then
				Tools.LoadTexture(icon, icon_path)
			end
		else
			print("error: icon_font_path 没有")
		end
		local icon_font = model_:getChildByName("icon_font")
		if icon_font_path then
			if fileUtils:fullPathForFilename(icon_font_path) ~= "" then
				Tools.LoadTexture(icon_font, icon_font_path)
			end
		else
			print("error: icon_font_path 没有")
		end

		--金额列表显示
		model_.amount_list:removeAllChildren()
		local rechargeAmountList = sGameManager.rechargeAmountList[self.cur_recharge_options_ID]
		local ex = self:GetExchange(self.cur_recharge_options_ID)
		--添加金额按钮
		for _,value in ipairs(rechargeAmountList) do
			local new_item = model_.amount_list:pushBackDefaultItem()
			local Text_4 = new_item:getChildByName("Text_4")
			local btn_money = new_item:getChildByName("btn_money")
			local show_money = value.money
			Text_4:setString(Tools.ShuZiAddDouHao(ex*show_money/sGameManager.exchangerate))
			local strTem = show_money/sGameManager.exchangerate
			if show_money>=1000*sGameManager.exchangerate then
				show_money = show_money/1000
				strTem ="$".. show_money/sGameManager.exchangerate.."k"
			end
			btn_money:getChildByName("fnt"):setString(strTem)
			Tools.AddClickEvent(btn_money,
				function()
					sGameManager.recharge_data.is 			= true
					sGameManager.recharge_data.product_id 	= value.product_id
					sGameManager.recharge_data.money 		= value.money

					local layer = PopLayer:Pop(RechargePopup_VirtualCoin)
					local vip_info = self:FilterVipInfo(self.cur_recharge_options_ID,sGameManager.recharge_data.money)
					local acc_info = self:GetAccInfo(self.cur_recharge_options_ID)
					layer:setInfo(self.cur_recharge_options_ID,vip_info,sGameManager.recharge_data.money/sGameManager.exchangerate,acc_info)

				end, true)
		end
		model_.amount_list:doLayout()
	end
end

--根据退款方式获取基本信息
function LobbyRechargeLayer:GetAccInfo(idx)
	local list = {}
	for key, value in ipairs(UserData.pay_channel_accounts) do
		if value.pay_channel_id == idx then
			table.insert(list,value)
		end
	end
	return list
end

function LobbyRechargeLayer:OnBtnClose(number)
	for i = 1, number do
		if self.list_model then
			if self.list_model[i].amount_item then
				self.list_model[i].amount_item:release()
			end
			if self.list_model[i].list_item then
				self.list_model[i].list_item:release()
			end
			if self.list_model[i].text_item then
				self.list_model[i].text_item:release()
			end
		end
	end
	self.ui_rechargeOptions_item:release()
	self:Close()
end

function LobbyRechargeLayer:OnBtnRecharge()
	if AppsFlyer and AppsFlyer.start_purchase then
		AppsFlyer:start_purchase()
	end

	if not sGameManager.recharge_data.is then
		UIManager.ShowMsgBox(TR("请选择具体金额!!!"))
		return
	end

	print("OnBtnRecharge self.cur_recharge_options_ID:" .. tostring(self.cur_recharge_options_ID))
	local cfg_ID = RechargeGetCfgId(self.cur_recharge_options_ID)
	print("OnBtnRecharge cfg_ID:" .. tostring(cfg_ID))

	--充值操作
	if (cfg_ID == Def.googlepay_ID) then
		local GooglePay = require("hall.src.sdk.GooglePay")
		GooglePay:Recharge()
	elseif (cfg_ID > 200 and cfg_ID <= 300) then
		--右侧金额显示，跳转浏览器扫码充值(201~300)
		if sGameManager.is_open_realname_mode == 1  and cfg_ID == 217 then
			-- 泰国扫码
			local layer = PopLayer:Pop(RechargePopup_tha_qr)
			local money = sGameManager.recharge_data.money
			local info = self:FilterVipInfo(self.cur_recharge_options_ID, money)
			layer:setInfo(self.cur_recharge_options_ID, money, info)
			return
		else
			self:RechargeForOther()
		end
	elseif (cfg_ID > 390 and cfg_ID <= 399) then
		self:RechargeForIND_T()
	elseif (cfg_ID > 300 and cfg_ID <= 400) then
		--右侧金额显示，二级弹窗补充充值信息(301~400)
		if ConfigParam.Region == "ind" then
			self:RechargeForInd_T()
		elseif ConfigParam.Region == "vn" then
			self:RechargeForVN_T()
		elseif ConfigParam.Region == "tha" then
			--todo
			UIManager.ShowToast("tha 300 - 400 error todo")
		elseif ConfigParam.Region == "bd" then
			self:RechargeForMM_T()
		elseif ConfigParam.Region == "mm" then
			self:RechargeForMM_T()
		elseif ConfigParam.Region == "ph" then
			local info = Recharge.RechargeChannelListData[cfg_ID]
			if info and info.type == "RechargePopup_mm" then
				self:RechargeForMM_T()
			elseif info and info.type == "RechargePopup_ind2" then
				self:RechargeForIND_T()
			else
				self:RechargeForPH_T()
			end
		elseif ConfigParam.Region == "es" then
			self:RechargeForIND_T()
		else
			UIManager.ShowToast("300 - 400 Region is error ", ConfigParam.Region)
			print("300 - 400 Region is error ", ConfigParam.Region)
		end
	elseif (cfg_ID > 400 and cfg_ID <= 500) then
		--早期第四方充值，金额+跳转浏览器拉起第四方apk(401~500)
		self:RechargeForOther()
	elseif (cfg_ID > 500 and cfg_ID <= 600) then
		local model_set = self.list_model[3]
		--信息显示+直接填写信息+可能通过浏览器跳转拉起第四方apk(501~600)
		local money = self.list_model[3].input_money:getText()
		local payer = self.list_model[3].input_payer_name:getText()
		local paycard = self.list_model[3].input_payer_card:getText()
		if ConfigParam.Region == "vn" then
			if Recharge.YN_List[cfg_ID] then
				money = self.list_model[5].input_money:getText()
				payer = self.list_model[5].input_payer_name:getText()
				paycard = self.list_model[5].input_payer_card:getText()
				model_set = self.list_model[5]
			end
		elseif ConfigParam.Region == "tha" then
			money = self.list_model[9].input_money:getText()
			payer = self.list_model[9].input_payer_name:getText()
			paycard = self.list_model[9].input_payer_card:getText()
			model_set = self.list_model[9]
		else
			money = self.list_model[5].input_money:getText()
			payer = self.list_model[5].input_payer_name:getText()
			paycard = self.list_model[5].input_payer_card:getText()
			model_set = self.list_model[5]
		end
		if #payer == 0 then
			UIManager.ShowMsgBox(TR("请输入姓名"))
			return
		end
		--名字纯空格
		if exutils.strIsBlank(payer) then
			UIManager.ShowMsgBox(TR("姓名不能全是空格，请输入正确的姓名"))
			return
		end
		if paycard == "" then
			UIManager.ShowMsgBox(TR("账号不能为空"))
			return
		end
		--卡号有空格或特殊字符
		if string.find(paycard," ") or tonumber(paycard) == nil or (math.floor(tonumber(paycard)) < tonumber(paycard)) then
			UIManager.ShowMsgBox(TR("数值不能含有小数"))
			return
		end
		--未输入金额
		if money == "" or money == "0" then
			UIManager.ShowMsgBox(TR("请输入金额！！！"))
			return
		end
		if not tonumber(money) then
			UIManager.ShowMsgBox(TR("请输入金额！！！"))
			return
		end
		--金额含有小数
		if (math.floor(tonumber(money)) < tonumber(money)) then
			UIManager.ShowMsgBox(TR("数值不能含有小数"))
			return
		end
		--最少充值
		if tonumber(money) * sGameManager.exchangerate < sGameManager.recharge_min_money and sGameManager.recharge_min_money > 0 then
			local str_ = TR("最少充值NNN金币")
			local str = string.gsub(str_, "NNN",sGameManager.recharge_min_money / sGameManager.exchangerate)
			UIManager.ShowMsgBox(str)
			return
		end
		--最多充值
		if tonumber(money) * sGameManager.exchangerate > sGameManager.recharge_max_money and sGameManager.recharge_max_money > 0 then
			local str_ = TR("最多充值NNN金币")
			local str = string.gsub(str_, "NNN",sGameManager.recharge_max_money / sGameManager.exchangerate)
			UIManager.ShowMsgBox(str)
			return
		end

		-- 检查银行卡号
		if ConfigParam.Region == "tha" then
			if #paycard ~= Recharge.Bank_MinNumber and #paycard ~= Recharge.Bank_MaxNumber then
				UIManager.ShowMsgBox(string.format(TR("%d或%d位数的银行卡号"),Recharge.Bank_MinNumber,Recharge.Bank_MaxNumber))
				return
			end
		else
			if #paycard < Recharge.Bank_MinNumber or #paycard > Recharge.Bank_MaxNumber then
				UIManager.ShowMsgBox(string.format(TR("%d-%d位数的银行卡号"),Recharge.Bank_MinNumber,Recharge.Bank_MaxNumber))
				return
			end
		end

		if model_set.bank_name_node then
			local bank_name = model_set.bank_name_node:GetBankName()

			--付款银行纯空格
			if exutils.strIsBlank(bank_name) then
				UIManager.ShowMsgBox(TR("付款银行名不能全是空格"))
				return
			end

			--付款银行未填
			if bank_name == "" then
				UIManager.ShowMsgBox(TR("请输入开户行"))
				return
			end
		end

		self:RechargeForVN_ST(model_set)
	elseif (cfg_ID > 600 and cfg_ID <= 700) then
		--信息显示+直接填写信息+浏览器跳转扫码,并改变按钮+返回点击发送补充充值信息(601~700)
		--todo
	elseif (cfg_ID > 700 and cfg_ID <= 800) then
		--信息列表+二级弹窗填写补充充值信息(701~800)
		self:RechargeForVN_T()
	elseif (cfg_ID > 800 and cfg_ID <= 900) then
		--信息显示+直接填写信息+只用填写4项(801~900):注意仅越南地区MOMO,Zalo为5项
		local model_set = self.list_model[3]
		if ConfigParam.Region == "vn" then
			local money = self.list_model[3].input_money:getText()
			local paycard = self.list_model[3].input_payer_card:getText()
			if Recharge.YN_List[cfg_ID] then
				model_set = self.list_model[5]
				money = self.list_model[5].input_money:getText()
				paycard = self.list_model[5].input_payer_card:getText()
				local payer = self.list_model[5].input_payer_name:getText()
				if #payer == 0 then
					UIManager.ShowMsgBox(TR("请输入姓名"))
					return
				end
				--名字纯空格
				if exutils.strIsBlank(payer) then
					UIManager.ShowMsgBox(TR("姓名不能全是空格，请输入正确的姓名"))
					return
				end
			end
			if paycard == "" then
				UIManager.ShowMsgBox(TR("账号不能为空"))
				return
			end
			--卡号有空格或特殊字符
			if string.find(paycard," ") or tonumber(paycard) == nil or (math.floor(tonumber(paycard)) < tonumber(paycard)) then
				UIManager.ShowMsgBox(TR("数值不能含有小数"))
				return
			end
			--未输入金额
			if money == "" or money == "0" then
				UIManager.ShowMsgBox(TR("请输入金额！！！"))
				return
			end
			if not tonumber(money) then
				UIManager.ShowMsgBox(TR("请输入金额！！！"))
				return
			end
			--金额含有小数
			if (math.floor(tonumber(money)) < tonumber(money)) then
				UIManager.ShowMsgBox(TR("数值不能含有小数"))
				return
			end
			--最少充值
			if tonumber(money) * sGameManager.exchangerate < sGameManager.recharge_min_money and sGameManager.recharge_min_money > 0 then
				local str_ = TR("最少充值NNN金币")
				local str = string.gsub(str_, "NNN",sGameManager.recharge_min_money / sGameManager.exchangerate)
				UIManager.ShowMsgBox(str)
				return
			end
			--最多充值
			if tonumber(money) * sGameManager.exchangerate > sGameManager.recharge_max_money and sGameManager.recharge_max_money > 0 then
				local str_ = TR("最多充值NNN金币")
				local str = string.gsub(str_, "NNN",sGameManager.recharge_max_money / sGameManager.exchangerate)
				UIManager.ShowMsgBox(str)
				return
			end
			self:RechargeForVN_ST(model_set)
		else
			--todo
		end
	elseif (cfg_ID > 900 and cfg_ID <= 1000) then
		--信息列表+二级弹窗填写补充充值信息(901~1000)
		self:RechargeForVN_T()
	elseif (cfg_ID > 1000 and cfg_ID <= 1100) then
		--右侧金额显示，二级弹窗补充充值信息(1001~1100)
		self:RechargeForVN_T()
	elseif (cfg_ID > 1100 and cfg_ID <= 1200) then
		if sGameManager.is_open_realname_mode == 1 then
			local info = RechargeLogic:GetBindInfo()
			if info.phone == nil or info.phone == ""  then
				local layer = PopLayer:Pop(BindCardOrPhoneLayer)
				local tab = {}
				tab.state = 801
				tab.name = info.payer_name or ""
				layer:SetDefInfo(tab)
				if tab.name and tab.name ~= "" then
					layer:SetPhoneNameEnabled(false)
				else
					layer:SetPhoneNameEnabled(true)
				end
				layer:SetBindCallback(function()
					self:RechargeForOther()
				end)
				return
			end
		end

		--右侧金额显示，跳转浏览器(1101~1200)
		self:RechargeForOther()
	elseif (cfg_ID > 1200 and cfg_ID <= 1300) then
		--第四方充值，金额表+浏览器跳转
		self:RechargeForOther()
	elseif (cfg_ID > 1300 and cfg_ID <= 1400) then
		-- 充值卡二级弹窗
		--未输入金额
		local money = self.list_model[1].input:getText()
		if money == "" or money == "0" then
			UIManager.ShowMsgBox(TR("请输入金额！！！"))
			return
		end
		self:RechargeForRechargeCard()
	elseif Recharge.IsVirtualCoin(cfg_ID) then
		local layer = PopLayer:Pop(RechargePopup_VirtualCoin)
		local vip_info = self:FilterVipInfo(self.cur_recharge_options_ID,sGameManager.recharge_data.money)
		local acc_info = self:GetAccInfo(self.cur_recharge_options_ID)
		layer:setInfo(self.cur_recharge_options_ID,vip_info,sGameManager.recharge_data.money,acc_info)
		-- self:RechargeForOther()
    elseif Recharge.IsWWWPay(cfg_ID) then
        self:RechargeForOther()
	else
		UIManager.ShowMsgBox(TR("该充值还没做!!!"))
	end
end

--切换按钮就会去获取支付Key(越南)
function LobbyRechargeLayer:GetRechargeKey(idx_)
	release_print("LobbyRechargeLayer:GetRechargeKey():" .. tostring(idx_))

	local pay_key_ = self.pay_key_
	self.pay_key_ = ""
	if ConfigParam.Region == "vn" then
		go(function()
			if self.btn_ok then
				self.btn_ok:setEnabled(false)
				self.btn_ok:setBright(false)
			end
			local data_ = PKG_Client_Lobby_GetPaymentKey.Create()
			UIManager.ShowWaiting()
			local rlt_ = gNet_SendRequest(data_)
			UIManager.HideWaiting()

			if self.btn_ok then
				self.btn_ok:setEnabled(true)
				self.btn_ok:setBright(true)
			end

			if (rlt_ == nil) then
				self.pay_key_ = pay_key_
				UIManager.ShowMsgBox(TR("打开充值界面错误!请重试!"))
			else
				local PKG_name = getmetatable(rlt_)
				if PKG_name == PKG_Lobby_Client_PaymentKeyResult then
					self.pay_key_ = rlt_.key
					self:UpdateRecharge(idx_)
				elseif PKG_name == PKG_Generic_Error then
					self.pay_key_ = pay_key_
					UIManager.ShowMsgBox(TR("打开充值界面错误!请重试!"))
				else
					self.pay_key_ = pay_key_
					UIManager.ShowMsgBox(TR("未知错误!!!"))
				end
			end
		end)
	else
		self:UpdateRecharge(idx_)
	end
end

--普通充值
function LobbyRechargeLayer:RechargeForOther()
	go(function()
		local data_ = PKG_Client_Lobby_ClientRechargeRequest.Create()
		data_.money = sGameManager.recharge_data.money
		data_.pay_type = self.cur_recharge_options_ID
		data_.ip_info = ""
		data_.is_create_order = 1
		data_.pay_name = "nil"
		data_.pay_card_number = ""
		data_.upstream_order_num = ""
		data_.payment_key = self.pay_key_
		UIManager.ShowWaiting()
		local rlt_ = gNet_SendRequest(data_)
		local PKG_name = getmetatable(rlt_)
		UIManager.HideWaiting()
		if PKG_name == PKG_Lobby_Client_ClientRechargeRequestSuccess then
			self:Close()
			if rlt_.pay_url ~= "" then
				-- UIManager.ShowWaiting(5)
				cc.Application:getInstance():openURL(rlt_.pay_url)
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

--印尼特殊充值
function LobbyRechargeLayer:RechargeForInd_T()
	go(function()
		local data_ = PKG_Client_Lobby_ClientRechargeRequest.Create()
		data_.money = sGameManager.recharge_data.money
		local is_accuracy = 0
		for i = 1, #sGameManager.payChannels do
			if sGameManager.payChannels[i].id == self.cur_recharge_options_ID then
				is_accuracy = sGameManager.payChannels[i].is_accuracy
			end
		end
		if is_accuracy == 1 then
			data_.money = data_.money + sGameManager.accuracy * sGameManager.exchangerate
		end
		data_.pay_type = self.cur_recharge_options_ID
		data_.ip_info = ""
		data_.is_create_order = 1
		data_.pay_name = "nil"
		data_.pay_card_number = ""
		data_.upstream_order_num = ""
		data_.payment_key = self.pay_key_
		UIManager.ShowWaiting()
		local rlt_ = gNet_SendRequest(data_)
		UIManager.HideWaiting()
		local PKG_name = getmetatable(rlt_)
		if PKG_name == PKG_Lobby_Client_ClientRechargeRequestSuccess then
			local ordernum = rlt_.order_num
			local layer = PopLayer:Pop(RechargeLayerPopup)
			local info = self:FilterVipInfo(self.cur_recharge_options_ID,data_.money)
			layer:setInfo(ordernum,info)
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

--菲律宾充值
function LobbyRechargeLayer:RechargeForPH_T()
	go(function()
		local data_ = PKG_Client_Lobby_ClientRechargeRequest.Create()
		data_.money = sGameManager.recharge_data.money
		local is_accuracy = 0
		for i = 1, #sGameManager.payChannels do
			if sGameManager.payChannels[i].id == self.cur_recharge_options_ID then
				is_accuracy = sGameManager.payChannels[i].is_accuracy
			end
		end
		if is_accuracy == 1 then
			data_.money = data_.money + sGameManager.accuracy * sGameManager.exchangerate
		end
		data_.pay_type = self.cur_recharge_options_ID
		data_.ip_info = ""
		data_.is_create_order = 1
		data_.pay_name = "nil"
		data_.pay_card_number = ""
		data_.upstream_order_num = ""
		data_.payment_key = self.pay_key_
		UIManager.ShowWaiting()
		local rlt_ = gNet_SendRequest(data_)
		UIManager.HideWaiting()
		local PKG_name = getmetatable(rlt_)
		if PKG_name == PKG_Lobby_Client_ClientRechargeRequestSuccess then
			local ordernum = rlt_.order_num
			local layer = PopLayer:Pop(RechargePopup_bankcard)
			local info = self:FilterVipInfo(self.cur_recharge_options_ID,data_.money)
			layer:setInfo(ordernum,info,tostring(data_.money / sGameManager.exchangerate),self.cur_recharge_options_ID)
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


--越南特殊充值
function LobbyRechargeLayer:RechargeForVN_T()
	go(function()
		local data_ = PKG_Client_Lobby_ClientRechargeRequest.Create()
		data_.money = sGameManager.recharge_data.money
		local is_accuracy = 0
		for i = 1, #sGameManager.payChannels do
			if sGameManager.payChannels[i].id == self.cur_recharge_options_ID then
				is_accuracy = sGameManager.payChannels[i].is_accuracy
			end
		end
		if is_accuracy == 1 then
			data_.money = data_.money + sGameManager.accuracy * sGameManager.exchangerate
		end
		data_.pay_type = self.cur_recharge_options_ID
		data_.ip_info = ""
		data_.is_create_order = 1
		data_.pay_name = "nil"
		data_.pay_card_number = ""
		data_.upstream_order_num = ""
		data_.payment_key = self.pay_key_
		UIManager.ShowWaiting()
		local rlt_ = gNet_SendRequest(data_)
		UIManager.HideWaiting()
		local PKG_name = getmetatable(rlt_)
		if PKG_name == PKG_Lobby_Client_ClientRechargeRequestSuccess then
			local ordernum = rlt_.order_num
			local layer = PopLayer:Pop(RechargePopup_VN)
			local info = self:FilterVipInfo(self.cur_recharge_options_ID,data_.money)
			layer:setInfo(ordernum,info)
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

--缅甸特殊充值
function LobbyRechargeLayer:RechargeForMM_T()
    if not limiter then limiter = PlayerActionLimiter.new(30, 4) end
    if not limiter:canDo() then
        -- "请稍后再试"
        UIManager.ShowMsgBox("ကျေးဇူးပြု၍ နောက်မှ ထပ်စမ်းကြည့်ပါ။")
        return
    end

    local channel_id = self.cur_recharge_options_ID
    go(function()
		local data_ = PKG_Client_Lobby_ClientRechargeRequest.Create()
		dump(sGameManager.recharge_data,"sGameManager.recharge_data")
		data_.money = sGameManager.recharge_data.money
		local is_accuracy = 0
		for i = 1, #sGameManager.payChannels do
			if sGameManager.payChannels[i].id == channel_id then
				is_accuracy = sGameManager.payChannels[i].is_accuracy
			end
		end
		if is_accuracy == 1 then
			data_.money = data_.money + sGameManager.accuracy * sGameManager.exchangerate
		end
		data_.pay_type = channel_id
		data_.ip_info = ""
		data_.is_create_order = 1
		data_.pay_name = "nil"
		data_.pay_card_number = ""
		data_.upstream_order_num = ""
		data_.payment_key = self.pay_key_

        local info = self:FilterVipInfo(channel_id, data_.money)
        if not info then
            UIManager.ShowToast("no VIP info for :" .. tostring(channel_id))
            return
        end

        local rlt_ = GetCachedResponse(data_)
        if not rlt_ then
            UIManager.ShowWaiting()
            rlt_ = gNet_SendRequest(data_)
            UIManager.HideWaiting()
        end

		local PKG_name = getmetatable(rlt_)
		if PKG_name == PKG_Lobby_Client_ClientRechargeRequestSuccess then
			local ordernum = rlt_.order_num
			local layer = PopLayer:Pop(RechargePopup_mm)
			layer:setChannelID(channel_id)
			layer:setInfo(ordernum, info, tostring(data_.money / sGameManager.exchangerate))
		elseif PKG_name == PKG_Generic_Error then
            AddCachedResponse(data_, rlt_, 6)

			local num = Int64ToNumber(rlt_.number)
			if (num == -120) then
				UIManager.ShowMsgBox(TR("您的上一笔支付订单我们正在审核操作中，请及时关注金币到账情况耐心等待！如有疑问请咨询客服。"))
            elseif (num == -9999) then
				-- "您操作太频繁，请稍后再试"
				UIManager.ShowMsgBox("ဆက်တိုက်လုပ်ဆောင်မှုများနေသဖြင့် ခဏစောင့်ဆိုင်းပြီးမှ လုပ်‌ဆောင်ပေးပါရှင့်(E9999)")
            else
				UIManager.ShowMsgBox(TR("请求充值失败，请联系客服后重试"))
			end
		end
	end)
end

--印尼特殊充值 订单后四位
function LobbyRechargeLayer:RechargeForIND_T()
	go(function()
		local data_ = PKG_Client_Lobby_ClientRechargeRequest.Create()
		dump(sGameManager.recharge_data,"sGameManager.recharge_data")
		data_.money = sGameManager.recharge_data.money
		local is_accuracy = 0
		for i = 1, #sGameManager.payChannels do
			if sGameManager.payChannels[i].id == self.cur_recharge_options_ID then
				is_accuracy = sGameManager.payChannels[i].is_accuracy
			end
		end
		if is_accuracy == 1 then
			data_.money = data_.money + sGameManager.accuracy * sGameManager.exchangerate
		end
		data_.pay_type = self.cur_recharge_options_ID
		data_.ip_info = ""
		data_.is_create_order = 1
		data_.pay_name = "nil"
		data_.pay_card_number = ""
		data_.upstream_order_num = ""
		data_.payment_key = self.pay_key_
		UIManager.ShowWaiting()
		local rlt_ = gNet_SendRequest(data_)
		UIManager.HideWaiting()
		local PKG_name = getmetatable(rlt_)
		if PKG_name == PKG_Lobby_Client_ClientRechargeRequestSuccess then
			local ordernum = rlt_.order_num
			local layer
			if self.cur_recharge_options_ID == 395 or self.cur_recharge_options_ID == 396 or self.cur_recharge_options_ID == 378 then
				layer = PopLayer:Pop(RechargePopup_ind2)
			else
				layer = PopLayer:Pop(RechargePopup_ind)
			end
			-- local info = {}
			-- for i = 1,#sGameManager.vipChannels do
			-- 	if (sGameManager.vipChannels[i].pay_channel_id == self.cur_recharge_options_ID) then
			-- 		info = sGameManager.vipChannels[i]
			-- 	end
			-- end
			local info = self:FilterVipInfo(self.cur_recharge_options_ID,data_.money)
			print(data_.money,"data_.money")
			layer:setInfo(ordernum,info,tostring(data_.money / sGameManager.exchangerate),self.cur_recharge_options_ID)
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

-- 充值卡 也是奇葩要改流程
function LobbyRechargeLayer:RechargeForRechargeCard()
	local money = sGameManager.recharge_data.money
	local is_accuracy = 0
	for i = 1, #sGameManager.payChannels do
		if sGameManager.payChannels[i].id == self.cur_recharge_options_ID then
			is_accuracy = sGameManager.payChannels[i].is_accuracy
		end
	end
	if is_accuracy == 1 then
		money = money + sGameManager.accuracy * sGameManager.exchangerate
	end
	local layer = PopLayer:Pop(RechargePopup_rechargeCard)
	local info = self:FilterVipInfo(self.cur_recharge_options_ID,money)
	layer:setInfo(self.cur_recharge_options_ID,info,money)
end

--填写充值信息，可能会收到url充值
function LobbyRechargeLayer:RechargeForVN_ST(model_)
	go(function()
		local money = model_.input_money:getText()
		local pay_name = model_.input_payer_name:getText()
		local pay_card_number = model_.input_payer_card:getText()
		local bank_name
		if model_.bank_name_node then
			bank_name = model_.bank_name_node:GetBankName()
		end

		-- 检查是否需要绑定
		if sGameManager.is_open_realname_mode == 1 then
			local info = RechargeLogic:GetBindInfo()
			if info.payer_name ~= pay_name or info.bank_card ~= pay_card_number or info.bank_name ~= bank_name then
				-- 开始绑定
				local ret = RechargeLogic:RealNameBind(pay_name, bank_name, pay_card_number, nil)
				if not ret then
					UIManager.ShowMsgBox(TR("绑定失败"))
					return
				end
			end
		end

		local data_ = PKG_Client_Lobby_ClientRechargeRequest.Create()
		data_.money = tonumber(money) * sGameManager.exchangerate
		data_.pay_type = self.cur_recharge_options_ID
		data_.ip_info = ""
		data_.is_create_order = 1
		if self.cur_recharge_options_ID > 800 then
			if ConfigParam.Region == "vn" then
				if Recharge.YN_List[self.cur_recharge_options_ID] then
					data_.pay_name = pay_name
				else
					data_.pay_name = "nil"
				end
			else
				data_.pay_name = "nil"
			end
		else
			data_.pay_name = pay_name
		end
		data_.pay_card_number = pay_card_number
		data_.upstream_order_num = ""
		data_.payment_key = self.pay_key_
		dump(data_,"data_")
		UIManager.ShowWaiting()
		local rlt_ = gNet_SendRequest(data_)
		UIManager.HideWaiting()
		local PKG_name = getmetatable(rlt_)
		if PKG_name == PKG_Lobby_Client_ClientRechargeRequestSuccess then
			--越南momo，zalo充值可能跳转浏览器
			if (rlt_.pay_url ~= "") then
				-- UIManager.ShowWaiting(5)
				cc.Application:getInstance():openURL(rlt_.pay_url)
			else
            	UIManager.ShowMsgBox(TR("请等待审核，3分钟内审核通过后系统会自动帮您冲入金币。如有疑问请联络客服查询!"))
			end
			self:SaveAccAndName(self.cur_recharge_options_ID,pay_name,pay_card_number)
			self:Close()
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

--储存上次充值成功输入
function LobbyRechargeLayer:SaveAccAndName(idx,name_,acc_)
	local cfg = RechargeGetChannelCfg(idx)
	if cfg then
		cc.UserDefault:getInstance():setStringForKey(cfg.name .. "name",name_)
		cc.UserDefault:getInstance():setStringForKey(cfg.name .. "acc",acc_)
	end
end

--获取上次充值成功输入姓名
function LobbyRechargeLayer:GetLastName(idx)
	local cfg = RechargeGetChannelCfg(idx)
	if cfg then
		return cc.UserDefault:getInstance():getStringForKey(cfg.name .. "name")
	else
		return ""
	end
end

--获取上次充值成功输入账号
function LobbyRechargeLayer:GetLastAcc(idx)
	local cfg = RechargeGetChannelCfg(idx)
	if cfg then
		return cc.UserDefault:getInstance():getStringForKey(cfg.name .. "acc")
	else
		return ""
	end
end

--vip信息可能会存在同一充值ID有多个信息，需根据金额，选择vip信息传递
function LobbyRechargeLayer:FilterVipInfo(idx_,money_)
	-- 全部的id信息
	local list_vip_info = {}
	local vip_level = sGameManager.GetMyVipLevel()
	for i = 1,#sGameManager.vipChannels do
		if (sGameManager.vipChannels[i].pay_channel_id == idx_) then
			table.insert(list_vip_info,sGameManager.vipChannels[i])
		end
	end
	if #list_vip_info == 0 then
		print("ERROR: VIP 信息没配")
		return {}
	end

	return list_vip_info[1]
end

function LobbyRechargeLayer:GetExchange(id)
	for _, value in ipairs(sGameManager.payChannels) do
		if value.id == id then
            return value.exchange
		end
	end
	return 1
end
return LobbyRechargeLayer
