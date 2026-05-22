local UserInfoNode = class("UserInfoNode", function(node)
    node:enableNodeEvents()
    return node
end)

function UserInfoNode:onEnter()
    self:InitUI()
	self:Update()
	self:RunAct()
	Dispatcher:Register(UserData, UserInfoNode.Update, self)
	Dispatcher:Register(activity.logic, UserInfoNode.Update, self)

	self:DownloadQR()
end

function UserInfoNode:onExit()
	Dispatcher:Remove(self)
end

function UserInfoNode:InitUI()
	--个人信息区域的点击
	local head_touch = self:findChild("lua_head_touch")
	Tools.AddClickEvent(head_touch, function()
		PopLayer:Pop(user.SelfInfoLayer)
	end)
	
	--玩家头像
	local head_icon = self:findChild("lua_head_icon")
	head_icon:setContentSize(56, 56)
	self.head_icon = head_icon
	
	--昵称
	self.nickname_layer = self:findChild("layout_nickname")
	self.nickname = self:findChild("lua_nickname")
	self.nick_pos = cc.p(self.nickname:getPosition())		--保存初始位置,某些语言可能需要修改

	-- 洗马vip等级
	local washcode_vip_num = self:findChild("washcode_vip_num")
	self.washcode_vip_num = washcode_vip_num
	self.washcode_vip_num:setString(0)
	
	-- 洗马值
	local washcode_num = self:findChild("washcode_num")
	self.washcode_num = washcode_num
	self.washcode_num:setString(0)

	--金币添加按钮
	local coin_btn = self:findChild("lua_coin_btn")
	Tools.AddClickEvent(coin_btn, function()
		if Tools_Base.PreventContinuousClick(self.nickname,0.5) then
			if UserData.has_refund_purview ~= 0 then -- 退款
				if UserData.buttonList[102] ~= 0 and G_EXCH then
					G_EnterExc()
				end
			end
		end
	end, true)

	--金币点击区域
	local coin_touch = self:findChild("lua_coin_touch")
	Tools.AddClickEvent(coin_touch, function()
		if Tools_Base.PreventContinuousClick(self.nickname,0.5) then
			if UserData.has_refund_purview ~= 0 then -- 退款
				if UserData.buttonList[102] ~= 0 and G_EXCH then
					G_EnterExc()
				end
			end
		end
	end)

	--金币数量
	self.coin_num = self:findChild("lua_coin_num")

	--保险柜按钮
	local safebox_btn = self:findChild("lua_safebox_btn")
	Tools.AddClickEvent(safebox_btn, function()
		if Tools_Base.PreventContinuousClick(self.coin_num,0.5) then
			sGameManager.PopSafeBoxLayer()
		end
	end, true)

	--金币点击区域
	local safebox_touch = self:findChild("lua_safebox_touch")
	Tools.AddClickEvent(safebox_touch, function()
		if Tools_Base.PreventContinuousClick(self.coin_num,0.5) then
			sGameManager.PopSafeBoxLayer()
		end
	end)

	--保险箱数量
	self.safebox_num = self:findChild("lua_safebox_num")

	-- 设置按钮
    self.btn_set = self:findChild("lua_btn_set")
	Tools.AddClickEvent(self.btn_set, function()
		local layer = PopLayer:Pop(user.SetUpLayer)
		layer:ShowLangSelect(true)
    end, true)

	-- 聊天
	self.btn_chat = self:findChild("lua_btn_chat")
	self.btn_chat:setVisible(false)

	-- 老玩家福利
	self.btn_lwjfl = self:findChild("lua_btn_lwjfl")
	self.btn_lwjfl:setVisible(false)

	-- 充值
	local btn_recharge = self:findChild("btn_rechage")
	Tools.AddClickEvent(btn_recharge, function()
		sGameManager.PopRecharge()
    end, true)

	-- 复制
	local btn_copy = self:findChild("btn_copy")
    Tools.AddClickEvent(btn_copy, function()
        -- if self.website ~= "" then
        --     cc.Application:getInstance():openURL(self.website)
        -- end

		if self.website ~= "" then
			Device:CopyString(self.website)
			UIManager.ShowToast(TR("复制成功"))
		end
    end, true)

	do
		local effect = self:MakeEffect()
		local center_layout = self:findChild("center_layout")
		center_layout:addChild(effect)
		local rt = center_layout:getContentSize()
		effect:setPosition(cc.p(rt.width/2, rt.height/2))
	end
end

function UserInfoNode:MakeEffect()
    local eft = sp.SkeletonAnimation:createWithBinaryFile("hall/res/effect/lobby/hall_buy/hall_buy.skel", "hall/res/effect/lobby/hall_buy/hall_buy.atlas")
	eft:setAnchorPoint(cc.p(0.5, 0.5))
	eft:setOpacityModifyRGB(false)
	eft:setAnimation(0, "hall_buy", true)
	return eft
end

function UserInfoNode:RunEnterAni(bShowSet)
    local x,y = self:getPosition()
    local show_pos = cc.p(x, Def.visibleSize.height)
    local y = Def.visibleSize.height+self:getBoundingBox().height
    local hide_pos = cc.p(x, y)
    self:setPosition(hide_pos)
    self:stopAllActions()
    self:runAction(cc.MoveTo:create(0.22, show_pos))
	self.btn_set:setVisible(bShowSet)

	local url_layout = self:findChild("url_layout")
	url_layout:setVisible(bShowSet)

	local washcode_layout = self:findChild("washcode_layout")
	if sGameManager.IsBindCodeOpen() then
		washcode_layout:setVisible(bShowSet)
	else
		washcode_layout:setVisible(false)
		url_layout:setPositionY(washcode_layout:getPositionY())
	end
end

function UserInfoNode:RunExitAni()
    local x,y = self:getPosition()
    local show_pos = cc.p(x, Def.visibleSize.height)
    local y = Def.visibleSize.height+self:getBoundingBox().height
    local hide_pos = cc.p(x, y)
    self:setPosition(show_pos)
    self:stopAllActions()
    self:runAction(cc.MoveTo:create(0.22, hide_pos))
end

--更新所有信息
function UserInfoNode:Update()
    self:UpdateHead()

	--昵称
	local str = Tools.GetShowNickName()
	self.nickname:setString(str)

    -- local vipNum_ = sGameManager.GetVip(UserData.total_recharge)
	-- self.vip_num:setString(tostring(vipNum_))

	local num = Tools.CoinToShowString(math.floor(UserData.money_gift))
	self.washcode_num:setString(num)

	-- 洗马 vip 等级
    local level = sGameManager.GetMyVipLevel()
	self.washcode_vip_num:setString(tostring(level))
	if level <= 0 then
		self:findChild("vip"):setVisible(false)
	else
		self:findChild("vip"):setVisible(true)
	end

	local moneyNum = UserData.money
	local money_str = Tools.CoinToShowString(moneyNum)
	local safe_money_str = Tools.CoinToShowString(UserData.money_safe)

	self.coin_num:setString(money_str)
	self.safebox_num:setString(safe_money_str)

	if not sGameManager.IsBindCodeOpen() then	-- 不显示绑定金币
		local washcode_layout = self:findChild("washcode_layout")
		washcode_layout:setVisible(false)
	end

	if not sGameManager.IsVipOpen() then
		self:findChild("vip"):setVisible(false)
	end
end

--更新头像
function UserInfoNode:UpdateHead()
	local head_icon_id = UserData.avatar_id
	if head_icon_id == 0 then
		head_icon_id = 1
	end
	local p = Tools.GetHeadPath(head_icon_id)
	self.head_icon:loadTexture(p)
end

function UserInfoNode:RunAct()
	self.nickname_isrun = false
	self.nickname_layer:runAction(
		cc.RepeatForever:create(
			cc.Sequence:create(
				cc.DelayTime:create(2),
				cc.CallFunc:create(function()
					if not self.nickname_isrun then
						if self.nickname == nil then
							return
						end
						local nickname_len = self.nickname:getContentSize().width
						local nickname_pos = cc.p(self.nickname:getPosition())
						local layer_len = self.nickname_layer:getContentSize().width
						if nickname_len > layer_len then
							self.nickname_isrun = true
							self.nickname:runAction(cc.Sequence:create(
								cc.MoveBy:create(5, cc.p(-nickname_len, 0)),
								cc.CallFunc:create(function() 
									self.nickname_isrun = false
									self.nickname:setPosition(nickname_pos) 
								end)))
							end
						end
					end))))
end

-----------------------------------------------------------------------------------

function UserInfoNode:RunUrlAction()
	local url_text = self:findChild("url_text")
	local url_panel = self:findChild("url_panel")
	url_text:setPositionX(url_panel:getContentSize().width)
	url_text:stopAllActions()

	local left_most_x = -url_text:getContentSize().width
	local y = url_text:getPositionY()
	url_text:runAction(cc.Sequence:create(
		cc.MoveTo:create(5, cc.p(left_most_x, y)),
		cc.CallFunc:create(function()
			-- print("run to end ...")
			self:RunUrlAction()
		end)
	))
end

function UserInfoNode:DownloadQR()
	self:SetWebSite("")
    go(function()
        local data_ = PKG_Client_Lobby_GetWebsite.Create()
        local rlt_ = gNet_SendRequest(data_)
		if rlt_ ~= nil then
			if getmetatable(rlt_) == PKG_Lobby_Client_Website then
				self:SetWebSite(rlt_.website)
				self:RunUrlAction()
			elseif getmetatable(rlt_) == PKG_Generic_Error then
			end
		end
    end)
end

function UserInfoNode:SetWebSite(url_)
	self:findChild("url_text"):setString(url_)
	self.website = url_
	
	sGameManager.SetWebSite(url_)
end

--从一个数字变化到另外一个数字
function UserInfoNode:RunToNumber(time, addNum)
	local from, to = math.floor(UserData.money_gift),math.floor(UserData.money_gift)+addNum
    local MAX_TIMES = time*30 -- 最大变化次数 变成帧率2倍
    local lerp_value = to - from -- 插值
    if lerp_value == 0 then
        return
    end
    local times = 0 --准备变化多少次
    if lerp_value > MAX_TIMES then
        times = MAX_TIMES
    else
        times = lerp_value
    end 
    local delta = (lerp_value / times == 0) and 1 or lerp_value / times
    local index = 0     --当前第几次
    self.washcode_num:runAction(cc.Repeat:create(
        cc.Sequence:create(
            cc.DelayTime:create(time/times),
            cc.CallFunc:create(
                function()
                    index = index + 1
					local num = Tools.CoinToShowString(math.floor(from + delta*index))
                    self.washcode_num:setString(num)
                    if index >= times then
						local num = Tools.CoinToShowString(math.floor(to))
						local strTem = Tools.ShuZi_Exchangerate(to,true)
						self.washcode_num:setString(num)

                    end
                end
            )
        ),
        times
    ))
	go(
		function ()
			SleepSecs(time+0.1)
			UserData.money_gift = UserData.money_gift + addNum
			Dispatcher:Dispatch(UserData)
		end
	)
end

return UserInfoNode
