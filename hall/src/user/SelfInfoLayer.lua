local SelfInfoLayer = class("SelfInfoLayer", function()
    return Tools.CreateLayer("csb/lobby/SelfInfoLayer.csb")
end)

function SelfInfoLayer:onEnter()
	self:InitUI()
	
    self:InitEvent()
	self:UpVisitMode()
	self:ShowCoin()

	Dispatcher:Register(UserData, function()
		self:UpVisitMode()
	end, self)
end

function SelfInfoLayer:InitUI()
    local close_btn = self:findChild("lua_close_btn")
    Tools.AddClickEvent(close_btn, function()
        self:Close()
    end, true)

	--金币数量
	self.coin_num = self:findChild("lua_coin_num")
	self.coin_num:setString("0")

	-- 洗马值
	local num = Tools.CoinToShowString(math.floor(UserData.money_gift))
	self.lua_washcode_num = self:findChild("lua_washcode_num")
	self.lua_washcode_num:setString(num)
	
	-- 洗马 vip 等级
	self.vip_num = self:findChild("vip_num")
    local level = sGameManager.GetMyVipLevel()
	self.vip_num:setString(tostring(level))

	--头像
	self.head_icon = self:findChild("lua_head_icon")
	local p1, p2 = Tools.GetHeadPath(UserData.avatar_id)
	self.head_icon:loadTextures(p1, p2)

	--昵称控件
	self.nickname = self:findChild("lua_nickname")
	self.nickname:setString(Tools.GetShowNickName())

	--昵称修改按钮
	self.edit_btn = self:findChild("lua_edit_btn")
	Tools.AddClickEvent(self.edit_btn, function()
		PopLayer:Pop(user.ModifyNameLayer)
	end, true)

	--修改过昵称不再显示修改按钮, 等于用户 id 也让用户可以修改
	if UserData.username ~= UserData.nickname and UserData.nickname ~= tostring(UserData.id) then
		self.edit_btn:setVisible(false)
	end

	--更换头像按钮
	local change_btn = self:findChild("_lang_lua_change_btn")
	Tools.AddClickEvent(change_btn, function()
		PopLayer:Pop(user.ChangeHeadLayer)
	end, true)
	self.change_btn = change_btn

	--玩家ID
	local id = self:findChild("lua_id_text")
	local id_str = tostring(UserData.id)
	id:setString(id_str)

	--ID复制按钮
	local copy_btn = self:findChild("_lang_lua_copy_btn")
	Tools.AddClickEvent(copy_btn, function()
		sGameManager.CopyUserID()
		UIManager.ShowToast(TR("复制成功"))
	end, true)

	--账户名称
	local acc_name = self:findChild("user_acc_text")
	acc_name:setString(tostring(UserData.account_name))
	Tools.CcuiTextIgnoreContentAdaptByScaleX(acc_name)

	--账户名称复制按钮
	local copy_btn_acc = self:findChild("_lang_lua_copy_btn_0")
	Tools.AddClickEvent(copy_btn_acc,function()
		if acc_name:getString() ~= "" then
			Device:CopyString(acc_name:getString())
			UIManager.ShowToast(TR("复制成功"))
		end
	end, true)

	local email = self:findChild("email_text")
	if not tolua.isnull(email) then
		-- 邮箱
		email:setString(UserData.email)
		Tools.CcuiTextIgnoreContentAdaptByScaleX(email)
		-- 绑定邮箱
		local bindemail_btn = self:findChild("_lang_lua_bindemail_btn")
		if UserData.email ~= "" then
			bindemail_btn:setVisible(false)
		end
		Tools.AddClickEvent(bindemail_btn,function()
			PopLayer:Pop(user.EmailBindingLayer)
		end, true)
	end

	--设置按钮
	-- self.setting_btn = self:findChild("lua_setting_btn")
	-- Tools.AddClickEvent(self.setting_btn, function()
	-- 	PopLayer:Pop(user.SetUpLayer)
	-- end, true)

	--查看更多权益按钮
	self.view_vip = self:findChild("_lang_btn_view_vip")
	Tools.AddClickEvent(self.view_vip, function()
		PopLayer:Pop(user.VipBenefitLayer)
	end, true)

	--注册按钮
	self.register_btn = self:findChild("_lang_lua_register_btn")
	Tools.AddClickEvent(self.register_btn, function()
		if UserData.is_open_email_bind and
			UserData.is_open_email_bind == 1 then
			
			PopLayer:Pop(user.AccountEmailBindingLayer)
			return
		end
		PopLayer:Pop(user.AccountBindingLayer)
	end, true)

	--登出按钮
	self.lua_logout_btn = self:findChild("_lang_lua_logout_btn")
	Tools.AddClickEvent(self.lua_logout_btn, function()
		local lobby = gStates_GetState("Lobby")
		if lobby then
			go(
				function()
					LogoutLobby()
					EnterLoginPanel()
				end
			)
		end
	end, true)

	self:InitVipNode()

	local email_node = self:findChild("email_node")
	if not tolua.isnull(email_node) then
		email_node:setVisible(UserData.is_open_email_bind and UserData.is_open_email_bind == 1)
	end
end

function SelfInfoLayer:InitVipNode()
	if sGameManager.IsVipOpen() then
		local max_level = sGameManager.GetMaxVipLevel()
		local level = sGameManager.GetMyVipLevel()
		local vip_node = self:findChild("vip_node")
		if level == 0 or level == -1 then
			vip_node:findChild("vip_bg"):setVisible(false)
			vip_node:findChild("vip_num"):setVisible(false)
			vip_node:findChild("vip_0"):setVisible(true)
		else
			vip_node:findChild("vip_bg"):setVisible(true)
			vip_node:findChild("vip_num"):setVisible(true)
			vip_node:findChild("vip_0"):setVisible(false)
		end
	else
		self:findChild("vip_node"):setVisible(false)
	end


	if not sGameManager.IsBindCodeOpen() then
		self:findChild("wash_code_node"):setVisible(false)
		local coin_node = self:findChild("coin_node")
		local y = coin_node:getPositionY()
		coin_node:setPositionY(y - 60)
	end
	
end

function SelfInfoLayer:UpVisitMode()
	self:ShowRegisterBtn(UserData.account_name == "")

	local email = self:findChild("email_text")
	if not tolua.isnull(email) then
		-- 邮箱
		email:setString(UserData.email)
		Tools.CcuiTextIgnoreContentAdaptByScaleX(email)
		-- 绑定邮箱
		local bindemail_btn = self:findChild("_lang_lua_bindemail_btn")
		if UserData.email ~= "" then
			bindemail_btn:setVisible(false)
		end
	end
	local acc_name = self:findChild("user_acc_text")
	acc_name:setString(tostring(UserData.account_name))
	Tools.CcuiTextIgnoreContentAdaptByScaleX(acc_name)
	
	-- if UserData.account_name == "" then
	-- 	self.register_btn:setVisible(true)
	-- else
	-- 	self:HideRegisterButton()
	-- end

    -- local isVisitor = true
	-- if UserData.is_system_gift_money == 1 then
	-- 	isVisitor = false
	-- end
	-- if isVisitor then
	-- 	self.register_btn:setVisible(true)
	-- else
	-- 	self.register_btn:setVisible(false)
	-- end

	-- local platform = cc.Application:getInstance():getTargetPlatform()
    -- if cc.PLATFORM_OS_IPHONE == platform or cc.PLATFORM_OS_IPAD == platform then
	-- 	self:HideRegisterButton()
    -- end
end

function SelfInfoLayer:ShowRegisterBtn(bShow)
	if not self.register_btn_pos then self.register_btn_pos = cc.p(self.register_btn:getPosition()) end
	if not self.logout_btn_pos then self.logout_btn_pos = cc.p(self.lua_logout_btn:getPosition()) end

	if bShow then
		self.register_btn:setVisible(true)
		if not sGameManager.use_fff_res then
			self.register_btn:setPosition(self.register_btn_pos)
			self.lua_logout_btn:setPosition(self.logout_btn_pos)
		end
	else
		self.register_btn:setVisible(false)
		if not sGameManager.use_fff_res then
			self.lua_logout_btn:setPositionY(
			(self.register_btn_pos.y + self.logout_btn_pos.y) / 2
		)
		end
	end
end

function SelfInfoLayer:ShowCoin()
	local num = UserData.money
	local num_str = Tools.CoinToShowString(num)
	self.coin_num:setString(num_str)
end

function SelfInfoLayer:InitEvent()
	Dispatcher:Register(UserData, function()
		self:Update()
	end, self)
end

function SelfInfoLayer:Update()
	self.nickname:setString(Tools.GetShowNickName())
	--修改过昵称不再显示修改按钮
	if UserData.username ~= UserData.nickname then
		self.edit_btn:setVisible(false)
	end
	local p1, p2 = Tools.GetHeadPath(UserData.avatar_id)
	self.head_icon:loadTextures(p1, p2)
end

function SelfInfoLayer:onExit()
    Dispatcher:Remove(self)
end

return SelfInfoLayer
