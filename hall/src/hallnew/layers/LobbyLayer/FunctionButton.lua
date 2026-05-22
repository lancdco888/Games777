local FunctionButton = class("FunctionButton", function(node)
    node:enableNodeEvents()
    return node
end)

function FunctionButton:onEnter()
	self:setLocalZOrder(1000)

    self:InitUI()

    Dispatcher:Register(UserData, function() self:Update() end, self)
    Dispatcher:Register(activity.logic, function()
		self:Update()
	end, self)

    self:Update()
end

function FunctionButton:onExit()
    Dispatcher:Remove(self)
	local Panel_4 = self:findChild("Panel_4")
	Panel_4:stopAllActions()
end

function FunctionButton:InitUI()
	-- 客服按钮
	self.btn_service = self:findChild("lua_btn_service")
    Tools.AddClickEvent(self.btn_service, function()
		self:OnBtnService()
    end, true)

	if ConfigParam.Region == "ph" then
		local path_ = "hall/res/lobby/btn_viber.png"
		local full_path_ = cc.FileUtils:getInstance():fullPathForFilename(path_)
		if full_path_ ~= "" then
			self.btn_service:loadTextures(full_path_, full_path_)
			local pos = cc.p(106, 100)
			self.btn_service:findChild("tip"):setPosition(pos)
		end
	end

	-- 保险箱按钮
	self.btn_safebox = self:findChild("lua_btn_safebox")
	self.btn_safebox:addTouchEventListener(function(ref,type)
		if type == ccui.TouchEventType.ended then
			if Tools_Base.PreventContinuousClick(self.btn_safebox, 0.5) then
				self:OnBtnSafeBox()
			end
		end
	end)

	-- 保险箱 金币数字
	self.ui_safebox_coin_num = self:findChild("safebox_coin_num")
	local safe_money_str = Tools.CoinToShowString(UserData.money_safe)
	self.ui_safebox_coin_num:setString(safe_money_str)

	-- 保险箱 洗码数字
	self.ui_safebox_xima_num = self:findChild("safebox_xima_num")
	local safe_xima_str = Tools.CoinToShowString(UserData.money_gift_safe)
	self.ui_safebox_xima_num:setString(safe_xima_str)

	-- 注册会员
	self.btn_facebook = self:findChild("lua_btn_facebook")
    Tools.AddClickEvent(self.btn_facebook, function()
		self:OnBtnRegister()
    end, true)

	if G_EXCH and G_CreateBtn then
		self.exc = G_CreateBtn(self.btn_facebook)
		self:addChild(self.exc)
		Tools.AddClickEvent(self.exc, function()
			G_EnterExc()
		end, true)
	end

	-- 绑定账号
	self.btn_bind = self:findChild("lua_btn_bind")
    Tools.AddClickEvent(self.btn_bind, function()
		self:OnBtnAccountBinding()
    end, true)

	self.btn_vipqy = self:findChild("lua_btn_vipqy")
    Tools.AddClickEvent(self.btn_vipqy, function()
		self:OnBtnVipBenifit()
    end, true)

	-- 活动中心
	self.btn_activity = self:findChild("lua_btn_activity")
    Tools.AddClickEvent(self.btn_activity, function()
		self:OnBtnActivity()
    end, true)

	-- 充值
	self.btn_recharge = self:findChild("lua_recharge_btn")
    Tools.AddClickEvent(self.btn_recharge, function()
		sGameManager.PopRecharge()
    end, true)


	-- 救济金
	self.btn_jjj = self:findChild("lua_btn_jjj")
	Tools.AddClickEvent(self.btn_jjj, function()
		self:OnBtnJjj()
	end, true)

	-- 增送
	self.btn_give = self:findChild("lua_btn_give")
	Tools.AddClickEvent(self.btn_give, function()
		self:OnClickGive()
	end, true)

	-- 保险箱动画
	do
		local effect = self:MakeEffect()
		local node = self.btn_safebox:getChildByName("effect")
		node:addChild(effect)
	end

	-- 充值动画
	do
		local effect = self:MakeRechageEffect()
		local effect_recharge = self:findChild("effect_recharge")
		effect_recharge:addChild(effect)
		effect:setPosition(cc.p(effect_recharge:getContentSize().width/2, 0))
		effect:setLocalZOrder(-1)
	end

	do
		local effect = self:MakeRechageButtonEffect()
		local rt = self.btn_recharge:getContentSize()
		local pos = cc.p(rt.width/2, rt.height/2)

		-- 裁剪
		local cell = cc.ClippingNode:create()
		cell:setAlphaThreshold(0.1)
		cell:setStencil(cc.Sprite:create("language/lobby/btn_recharge.png"))
		cell:addChild(effect)
		effect:setPosition(pos)
		cell:setPosition(pos)
		self.btn_recharge:addChild(cell)
	end

	-- 保险箱的动画
	self:ShowSafeBoxAnim()

	self:ShowTip("lua_btn_service", false)
	self:ShowTip("lua_btn_activity", false)
end

function FunctionButton:MakeEffect()
    local eft = sp.SkeletonAnimation:createWithBinaryFile("hall/res/effect/lobby/hall_money/hall_money.skel", "hall/res/effect/lobby/hall_money/hall_money.atlas")
	eft:setAnchorPoint(cc.p(0.5, 0.5))
	eft:setOpacityModifyRGB(false)
	eft:setAnimation(0, "hall_money", true)
	return eft
end

function FunctionButton:MakeRechageEffect()
    local eft = sp.SkeletonAnimation:createWithBinaryFile("hall/res/effect/lobby/hall_zhuanpan/hall_zhuanpan.skel", "hall/res/effect/lobby/hall_zhuanpan/hall_zhuanpan.atlas")
	eft:setAnchorPoint(cc.p(0.5, 0.5))
	eft:setOpacityModifyRGB(false)
	eft:setAnimation(0, "hall_zhuanpan", true)
	return eft
end

function FunctionButton:MakeRechageButtonEffect()
    local eft = sp.SkeletonAnimation:createWithBinaryFile("hall/res/effect/lobby/hall_chongzhi/hall_chongzhi.skel", "hall/res/effect/lobby/hall_chongzhi/hall_chongzhi.atlas")
	eft:setAnchorPoint(cc.p(0.5, 0.5))
	eft:setOpacityModifyRGB(false)
	eft:setAnimation(0, "hall_chongzhi", true)
	return eft
end

--在某个按钮上显示小圆点提示
function FunctionButton:ShowTip(name, bShow)
	-- 当前只有一个提示
	local btn = self:findChild(name)
	if not btn then
		print("no such button:" .. name)
		return
	end

	local tip = btn:findChild("tip")
	if tip then
		tip:setVisible(bShow)
	end
end

function FunctionButton:Update()
	local safe_money_str = Tools.CoinToShowString(UserData.money_safe)
	self.ui_safebox_coin_num:setString(safe_money_str)
	local safe_xima_str = Tools.CoinToShowString(UserData.money_gift_safe)
	self.ui_safebox_xima_num:setString(safe_xima_str)

	-- 隐藏所有按钮
	do
		local all = {
			self.exc,
			self.btn_service,
			self.btn_safebox,
			self.btn_facebook,
			self.btn_bind,
			self.btn_vipqy,
			self.btn_activity,
			self.btn_jjj,
			self.btn_give
		}
		for _, btn in pairs(all) do
			if btn then
				btn:setVisible(false)
			end
		end
	end

	-- 需要显示的按钮
	local buttonList = UserData.buttonList
	local need_show_btns = {}

	-- 搜集所有需要显示的按钮
	if buttonList[108] ~= 0 then	-- 客服
		table.insert(need_show_btns, self.btn_service)
	end

	if buttonList[103] ~= 0 then	-- 保险箱
		table.insert(need_show_btns, self.btn_safebox)
	end

	if UserData.has_refund_purview ~= 0 then -- 退款
		if buttonList[102] ~= 0 then -- 线下
			table.insert(need_show_btns, self.exc)
        end
	end

    local need_recharge = UserData.has_refund_purview ~= 0 and buttonList[105] ~= 0
	self.btn_recharge:setVisible(need_recharge)
	self:findChild("effect_recharge"):setVisible(need_recharge)

	print("buttonList[106] ",buttonList[106])
	if UserData.has_gift_money_purview ~= 0 then -- 赠送
		if buttonList[106] ~= 0 and self.btn_give then
			table.insert(need_show_btns, self.btn_give)
		end
	end

	if UserData.is_system_gift_money ~= 1 then -- 新手绑定
		if buttonList[104] ~= 0 then
			table.insert(need_show_btns, self.btn_facebook)
		end
	end

	if UserData.account_name == "" then-- 账号绑定
		if buttonList[111] ~= 0 then
			table.insert(need_show_btns, self.btn_bind)
		end
	end

	if buttonList[114] ~= 0 then
		table.insert(need_show_btns, self.btn_vipqy)
	end

	if buttonList[113] ~= 0 then
		table.insert(need_show_btns, self.btn_activity)
	end

	-- 默认在线客服一直存在所以排序
	do
		local x = self.btn_service:getPositionX() - self.btn_service:getContentSize().width/2.0
		for __, btn in ipairs(need_show_btns) do
			-- 计算自己位置
			local y = btn:getPositionY()
			local btn_w = btn:getContentSize().width
			x = x + btn_w/2.0
			-- 设置
			btn:setPosition(cc.p(x, y))
			btn:setVisible(true)
			-- 准备下个按钮位置
			x = x + btn_w/2.0 + 15
		end
	end

	-- 活动中心红点
    local bAward = false
	self:ShowTip("lua_btn_activity", bAward)
end

function FunctionButton:OnBtnService()
	--按键音效
	gSound.clickSound()
	go(function()
            local layer = PopLayer:Pop(service.ServiceMailLayer)
            PopLayer:SetCached(service.ServiceMailLayer, true)
            if layer then
                layer:ShowType(service.ServiceLogic.SERVICE)
            end

			cc.UserDefault:getInstance():setBoolForKey("ServiceTips", false)
			UserData.ServiceTips = false
			self:ShowTip("lua_btn_service", false)
    end)
end

function FunctionButton:OnBtnSafeBox()
    sGameManager.PopSafeBoxLayer()
end

function FunctionButton:RunEnterAni()
    local x,y = self:getPosition()
    local show_pos = cc.p(x, 0)
    local y = - self:getBoundingBox().height - 40
    local hide_pos = cc.p(x, y)
    self:setPosition(hide_pos)
    self:stopAllActions()
    self:runAction(cc.MoveTo:create(0.22, show_pos))

	local effect_recharge = self:findChild("effect_recharge")
	effect_recharge:setVisible(true)
end

function FunctionButton:RunExitAni()
    local x,y = self:getPosition()
    local show_pos = cc.p(x, 0)
    local y = - self:getBoundingBox().height - 40
    local hide_pos = cc.p(x, y)
    self:setPosition(show_pos)
    self:stopAllActions()
    self:runAction(cc.MoveTo:create(0.22, hide_pos))

	local effect_recharge = self:findChild("effect_recharge")
	effect_recharge:setVisible(false)
end

function FunctionButton:OnBtnRegister()
    local Facebook = require("hall.src.sdk.Facebook")
    Facebook.HandleBind()
end

function FunctionButton:OnBtnAccountBinding()
	if UserData.is_open_email_bind and
		UserData.is_open_email_bind == 1 then

		PopLayer:Pop(user.AccountEmailBindingLayer)
		return
	end
    PopLayer:Pop(user.AccountBindingLayer)
end

function FunctionButton:OnBtnVipBenifit()
	PopLayer:Pop(user.VipBenefitLayer)
end

function FunctionButton:OnBtnActivity()
	go(function()
		UIManager.ShowWaiting()
		local result = activity.logic:ReqActivityStatus()
		UIManager.HideWaiting()
		if not result then
			return
		end

		PopLayer:Pop(activity.ActivityCenterLayer)
	end)
end

function FunctionButton:OnBtnJjj()
end

function FunctionButton:ShowSafeBoxAnim()
	if not sGameManager.IsBindCodeOpen() then
		local Page_1 = self:findChild("Page_1")
		Page_1:show()
	else
		local Page_1 = self:findChild("Page_1")
		local Page_2 = self:findChild("Page_2")
		local start_x = Page_1:getPositionX()
		local start_y = Page_1:getPositionY()
		local move_height = Page_1:getContentSize().height
		local Panel_4 = self:findChild("Panel_4")
		local anim_type = 0 -- 0 是金币->洗码 1 是洗码->金币
		-- 初始化位置
		Page_2:setPosition(cc.p(start_x,start_y-move_height))
		Page_1:show()
		Page_2:show()
		Panel_4:runAction(cc.RepeatForever:create(
			cc.Sequence:create(
				cc.CallFunc:create(
					function()
						Page_1:runAction(cc.MoveBy:create(1, cc.p(0, move_height)))
						Page_2:runAction(cc.MoveBy:create(1, cc.p(0, move_height)))
					end
				),
				cc.DelayTime:create(1),
				cc.CallFunc:create(
					function()
						if anim_type == 0 then
							Page_1:setPosition(cc.p(start_x,start_y-move_height))
							anim_type = 1
						else
							Page_2:setPosition(cc.p(start_x,start_y-move_height))
							anim_type = 0
						end
					end
				),
				cc.DelayTime:create(3)
			)
		))
	end
end

-- 赠送
function FunctionButton:OnClickGive()
    if UserData.is_gift_money_password ~= 1 then
        local layer = PopLayer:Pop(GivePasswordLayer)
		layer:OnSetPasswdDone(function ()
			PopLayer:Pop(GiveLayer)
		end)
    else
        PopLayer:Pop(GiveLayer)
    end
end
return FunctionButton
