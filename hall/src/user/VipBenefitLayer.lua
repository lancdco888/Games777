local VipBenefitLayer = class("VipBenefitLayer", function()
    return Tools.CreateLayer("csb/lobby/VipBenefitLayer.csb")
end)

function VipBenefitLayer:onEnter()
	self:InitUI()
end

function VipBenefitLayer:InitUI()
    local btn_close = self:findChild("btn_close")
    Tools.AddClickEvent(btn_close, function()
        self:Close()
    end, true)

	self.context = self:findChild("context")

	Dispatcher:Register(UserData, function()
		self:UpdateUI()
	end, self)

	-- UserData.amount_of_washcode = 400
	-- dump(GameData.vipInfo)
	local isbj = UserData.activity_give_type == 0
	local _lang_tips = self:findChild("_lang_tips")
	_lang_tips:setVisible(isbj)
	self:UpdateUI()
	
	self:InitLevelButton()
end

function VipBenefitLayer:InitLevelButton()
	local max_level = sGameManager.GetMaxVipLevel()
	local list = self:findChild("btn_list")
	local item = list:findChild("item")
	item:retain()
	list:removeAllChildren()

	for i=1, max_level do
		local new = item:clone()
		new:findChild("num"):setString(tostring(i))
		new:setName("btn_" .. i)
		list:pushBackCustomItem(new)
		
		Tools.AddClickEvent(new, function()
			self:OnClickBtn(i)
		end, true)
	end

	local level = sGameManager.GetMyVipLevel()
	self:OnClickBtn(level <= 0 and 1 or level)
end

function VipBenefitLayer:OnClickBtn(index)
	local max_level = sGameManager.GetMaxVipLevel()
	for i = 1, max_level do
		local btn = self:findChild("btn_"..i)
		local bool_ = (i ~= index)
		btn:setEnabled(bool_)
		btn:setBright(bool_)
	end
	self:SetContextString(index)
	self.center_level_now:setString(index)
end

function VipBenefitLayer:UpdateUI()
	-- 洗马 vip 等级
	local level = sGameManager.GetMyVipLevel()
	if level <= 0 then
		level = 0
	end
	local num = UserData.amount_of_washcode

	-- 洗马 vip 等级
	local level_info_now = sGameManager.GetVipLevelInfo(level)
	local level_info_next = sGameManager.GetVipLevelInfo(level+1)
	local max_level = sGameManager.GetMaxVipLevel()
	if level == max_level then
		level_info_next = level_info_now
	end
	local level_now = self:findChild("level_now")
	level_now:setString(level)
	local level_next = self:findChild("level_next")
	level_next:setString(level == max_level and level or level+1)

	if sGameManager.GetMyVipLevel() < 0 then
		local bind_btn = self:findChild("_lang_btn_bind")
		if bind_btn then
			Tools.AddClickEvent(bind_btn, function()
				sGameManager.PopRecharge()
			end, true)
		end
		
		self:findChild("vip_0"):setVisible(true)
		self:findChild("vip"):setVisible(false)
		self:findChild("vip_max"):setVisible(false)
	elseif level == max_level then
		self:findChild("vip_max"):setVisible(true)
		self:findChild("vip_0"):setVisible(false)
		self:findChild("vip"):setVisible(false)
	else
		local interval = level_info_next.enough_wash - level_info_now.enough_wash
		local reach = num - level_info_now.enough_wash
		local vip_progress = self:findChild("vip_progress")
		vip_progress:setPercent(reach*100/interval)
		local text_progress = self:findChild("text_progress")
		text_progress:setString(Tools.CoinToShowString(reach).."/"..Tools.CoinToShowString(interval))

		self:findChild("vip"):setVisible(true)
		self:findChild("vip_0"):setVisible(false)
		self:findChild("vip_max"):setVisible(false)
	end
	self.center_level_now = self:findChild("center_level_now")

	local Image_4_1 = self:findChild("Image_4_1")
	Image_4_1:setVisible(level==0)
end

function VipBenefitLayer:SetContextString(level)
	local infos = sGameManager.GetVipLevelInfo(level)
	dump(infos,"infos")
	local iscoin = UserData.activity_give_type == 1
	if not iscoin then
		local tips1 = TR("* 开启绑定金币使用权限。")
		local tips2 = TR("* 在游戏中可获取绑定金币。")
		local tips3 = string.format(TR("* 达成此等级，获取%s绑定金币。"), tostring(infos.levelup_gift/sGameManager.exchangerate))
		local tips4 = TR("* 在游戏中可获取更多绑定金币。")
	
		local tips5
		-- 转盘需要的 vip 等级
		local tutle_level = activity.logic:GetTurntableVipLevel()
		if level == tutle_level then
			tips5 = TR("* 解锁转盘。")
		else
			tips5 = TR("* 可参与更多活动。")
		end
	
		if infos.levelup_gift <= 0 then
			self.context:setString( tips1 .. "\n\n" .. tips2 .. "\n\n" .. tips5)
		else
			self.context:setString( tips3 .. "\n\n" .. tips4 .. "\n\n" .. tips5)
		end
	else
		local tips = TR("*玩游戏可获得VIP经验。")
		if level > 1 then
			tips = TR("*玩游戏可获得更多VIP经验。")
		end
		tips = tips .. "\n\n".. TR("* 可参与更多活动。")

		if infos.levelup_gift > 0 then
			tips = tips .. "\n\n".. string.format(TR("*奖励%d金币"), tostring(infos.levelup_gift/sGameManager.exchangerate))
		end

		local tutle_level = activity.logic:GetTurntableVipLevel()
		if level == tutle_level then
			tips = tips .. "\n\n".. TR("* 解锁转盘。")
		end
		self.context:setString(tips)

		-- 1）升级不给奖励（配0）。权益说明文字修改。
		-- 改为：
		-- VIP1
		-- *玩游戏可获得VIP 经验。
		-- *可参与更多活动。
		-- *解锁转盘（根据转盘配置）
		-- VIP2-VIP6
		-- *玩游戏可获得更多的VIP 经验。
		-- *可参与更多活动。
		-- *解锁转盘（根据转盘配置）
		-- 2）升级奖励金币。权益说明文字修改。
		-- 改为：
		-- VIP1
		-- *玩游戏可获得VIP 经验。
		-- *可参与更多活动。
		-- *解锁转盘（根据转盘配置）
		-- VIP2-VIP6
		-- *玩游戏可获得更多的VIP 经验。
		-- *可参与更多活动。
		-- *奖励%d金币
		-- *解锁转盘（根据转盘配置）
	end

	Tools.CcuiTextIgnoreContentAdaptByFontSize(self.context)
end

return VipBenefitLayer
