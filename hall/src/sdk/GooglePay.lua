local GooglePay = class('GooglePay')

function GooglePay:ctor()

    self.googlePayInit = "0" -- 可能会用

    self.goodsInfo = nil
    self.purchaseToken = nil
    self.orderNum = nil
    self.Google_ID = 0
    self.Google_goods = nil
end

-- 重置谷歌支付参数
function GooglePay:resetGoogleArgs()
    self.goodsInfo = nil
    self.purchaseToken = nil
    self.orderNum = nil
    self.Google_ID = 0
    self.Google_goods = nil
end

--初始化googleplay充值
function GooglePay:GooglePlayInit()
	if self.googlePayInit == "2" then
		return "2"
	end
	local done = false
	local retInit = "0"
	local callbackLua = function(str)
        if str == "true" then
            print("谷歌支付 初始化 成功")
			self.googlePayInit = "2"
			retInit = "2"
        else
            print("谷歌支付 初始化 失败")
			self.googlePayInit = "1"
			retInit = "1"
		end
		done = true
	end
	local luaj = require "cocos.cocos2d.luaj"
	local className = "org/cocos2dx/lua/AppActivity"
	local args = {"googlePayInit", callbackLua}
	local sigs = "(Ljava/lang/String;I)V"
	local ok,ret = luaj.callStaticMethod(className, "googlePayInit", args, sigs)
	print("谷歌支付 初始化")
	while not done do
		yield()
	end
	return retInit
end

--查询商品列表信息
function GooglePay:QueryGoodsInfo()
    print("谷歌支付 查询商品列表信息")
	local luaj = require "cocos.cocos2d.luaj"
	local className = "org/cocos2dx/lua/AppActivity"
	local args = {"queryGoodsInfo", handler(GooglePay.QueryCallBack,self)}
	local sigs = "(Ljava/lang/String;I)V"
	local ok,ret = luaj.callStaticMethod(className, "queryGoodsInfo", args, sigs)
end

--查询结果
function GooglePay:QueryCallBack(str)
    print("谷歌支付 查询商品查询结果")
    dump(str,"查询结果")
	self.goodsInfo = str
end

--购买商品
function GooglePay:PurchaseGood(goodsInfo,callback)
	self.recharge_callback = callback
	go(
		function ()
			local retInit = self:GooglePlayInit()
			if retInit ~= "2" then
				print("谷歌支付 ret = self:GooglePlayInit() ~=2")
				self.recharge_callback = nil
				return
			end
			print("谷歌支付 购买商品")
			local luaj = require "cocos.cocos2d.luaj"
			local className = "org/cocos2dx/lua/AppActivity"
			local args = {goodsInfo, function(str) self:PurchaseCallBack(str) end}
			local sigs = "(Ljava/lang/String;I)V"
			local ok,ret = luaj.callStaticMethod(className, "purchaseGoods", args, sigs)
		end
	)
end

--购买结果
function GooglePay:PurchaseCallBack(str)
    print("谷歌支付 购买结果")
    print("谷歌支付 purchaseToken:",str)
	self.purchaseToken = str
	self.payConfirm = true
	if self.recharge_callback then
		self.recharge_callback()
	else
		GooglePay:SaveGoogleResult()
	end
end

--保存客户端google充值结果
function GooglePay:SaveGoogleResult()
    print("谷歌支付 保存客户端google充值结果")
	cc.UserDefault:getInstance():setBoolForKey(GooglePay.GooglePay_Confirm,false)
	cc.UserDefault:getInstance():setStringForKey(GooglePay.GooglePay_GoodsInfo,sGameManager.recharge_data.product_id)
	if self.orderNum == nil then
		cc.UserDefault:getInstance():setStringForKey(GooglePay.GooglePay_OrderNum,"")
	else
		cc.UserDefault:getInstance():setStringForKey(GooglePay.GooglePay_OrderNum,self.orderNum)
	end
	
	if self.purchaseToken == nil then
		cc.UserDefault:getInstance():setStringForKey(GooglePay.GooglePay_PurchaseToken,"")
	else
		cc.UserDefault:getInstance():setStringForKey(GooglePay.GooglePay_PurchaseToken,self.purchaseToken)
	end
end

--重置客户端google充值结果
function GooglePay:ResetGoogleResult()
    print("谷歌支付 重置客户端google充值结果")
	cc.UserDefault:getInstance():setBoolForKey(GooglePay.GooglePay_Confirm,true)
	cc.UserDefault:getInstance():setStringForKey(GooglePay.GooglePay_GoodsInfo,"")
	cc.UserDefault:getInstance():setStringForKey(GooglePay.GooglePay_OrderNum,"")
	cc.UserDefault:getInstance():setStringForKey(GooglePay.GooglePay_PurchaseToken,"")
	cc.UserDefault:getInstance():setIntegerForKey(GooglePay.GooglePay_ResultNumber,0)
end

--确认上次google充值是否服务器验证并且到账
function GooglePay:CheckGooglePay()
    -- print("谷歌支付 确认上次google充值是否服务器验证并且到账")
	if cc.Application:getInstance():getTargetPlatform() == cc.PLATFORM_OS_ANDROID --[[and Def_majia.GooglePay--]] then
		local isCfm = cc.UserDefault:getInstance():getBoolForKey(GooglePay.GooglePay_Confirm,true)
		local token = cc.UserDefault:getInstance():getStringForKey(GooglePay.GooglePay_PurchaseToken)
		local goods = cc.UserDefault:getInstance():getStringForKey(GooglePay.GooglePay_GoodsInfo)
		local order = cc.UserDefault:getInstance():getStringForKey(GooglePay.GooglePay_OrderNum)
		local number = cc.UserDefault:getInstance():getIntegerForKey(GooglePay.GooglePay_ResultNumber)
		-- print("谷歌支付 确认上次google充值")
		-- print("isCfm",isCfm)
		-- print("token",token)
		-- print("goods",goods)
		-- print("order",order)
		-- print("number",number)
		if number <= GooglePay.GooglePay_MaxNumber then
			if not isCfm and token ~= "" and goods ~= "" and order ~= "" then
				-- self.purchaseToken = token
				-- self.orderNum = order
				-- self.Google_goods = goods
				print("self:SendGooglePayCfmCheck")
				self:SendGooglePayCfmCheck()
			end
		else
			UIManager.ShowMsgBox(TR("请求充值失败，请联系客服后重试"))
			self:ResetGoogleResult()
		end
	end
end

--充值服务器未通过或不正常结束，重新发起申请
function GooglePay:SendGooglePayCfmCheck()
	print("谷歌支付 充值服务器未通过或不正常结束，重新发起申请")
	go(
		function()
			local data_ = PKG_Client_Lobby_GetClientRechargeResult.Create()
			data_.packageName = Device:GetPackageName()
			data_.productId = cc.UserDefault:getInstance():getStringForKey(GooglePay.GooglePay_GoodsInfo)
			data_.token = cc.UserDefault:getInstance():getStringForKey(GooglePay.GooglePay_PurchaseToken)
			data_.order_num = cc.UserDefault:getInstance():getStringForKey(GooglePay.GooglePay_OrderNum)
			print("data_.productId",data_.productId)
			print("data_.token",data_.token)
			print("data_.order_num",data_.order_num)
			local rlt_ = gNet_SendRequest(data_)
			self:HandleGooglePlayCheck(rlt_)
		end
	)
end

--google充值回调
function GooglePay:HandleGooglePlayCheck(rlt_)
    print("谷歌支付 google充值回调")
    dump(rlt_,"google充值回调")
	if rlt_ == nil then
		print("google充值回调 Info_GoogleError")
        return false
	end
	sGameManager.Isrecharged = false
	if(getmetatable(rlt_) == PKG_Lobby_Client_ClientRechargeResult)then
		self:ResetGoogleResult()
		if rlt_.state == 0 then
			local str = string.gsub(TR("恭喜您，充值成功，获得NNN金币"), "NNN", tostring(Tools.CoinToShowString(rlt_.money)))
			UIManager.ShowMsgBox(str)
		else
			UIManager.ShowMsgBox(TR("google充值验证失败，未查询到相应订单，请联系客服"))
		end
		return true
	elseif(getmetatable(rlt_) == PKG_Generic_Error)then
		print(rlt_.message)
	end
	return false
end

function GooglePay:Recharge()
	gorun(function ()
		local data_	 				= PKG_Client_Lobby_ClientRechargeRequest.Create()
		data_.pay_type 				= Def.googlepay_ID
		data_.money 				= sGameManager.recharge_data.money
		data_.ip_info 				= ""
		data_.is_create_order 		= 1
		data_.pay_name 				= "nil"
		data_.upstream_order_num 	= ""
		UIManager.ShowWaiting()
		local rlt_ = gNet_SendRequest(data_)
		UIManager.HideWaiting()
		if rlt_ then
			if(getmetatable(rlt_) == PKG_Lobby_Client_ClientRechargeRequestSuccess)then
				GooglePay.orderNum = rlt_.order_num
				local targetPlatform = cc.Application:getInstance():getTargetPlatform()
				if(cc.PLATFORM_OS_ANDROID == targetPlatform)then
					require("hall.src.common.GooglePay")
					-- 谷歌购买界面回调
					local function call_PurchaseGoodCb()
						print("PurchaseGoodCb")
						if GooglePay.purchaseToken == "1" then
							print("GooglePay.purchaseToken == \"1\"")
							sGameManager.Isrecharged = false
						elseif GooglePay.purchaseToken == "2" then
							print("GooglePay.purchaseToken == \"2\"")
							sGameManager.Isrecharged = false
						else
							GooglePay:SaveGoogleResult()
							GooglePay:SendGooglePayCfmCheck()
						end
					end
					GooglePay:PurchaseGood(sGameManager.recharge_data.product_id,call_PurchaseGoodCb)
				else
					UIManager.ShowMsgBox(TR("非android用户不可用"))
				end
			elseif(getmetatable(rlt_) == PKG_Generic_Error)then
				print("PKG_Generic_Error")
				sGameManager.Isrecharged = false
				local num = Int64ToNumber(rlt_.number)
				if (num == -1) then
					UIManager.ShowMsgBox(TR("请求充值失败，请联系客服后重试"))
				elseif (num == -2) then
					UIManager.ShowMsgBox(TR("暂不可用，请选择其他充值方式"))
				else
					UIManager.ShowMsgBox(TR("请求充值失败，请联系客服后重试"))
				end
			end
		else
			print("rlt_ = nil")
			sGameManager.Isrecharged = false
		end
	end)
end

GooglePay.GooglePay_MaxNumber		=	4
GooglePay.GooglePay_Confirm 		= "GoogleCfm"
GooglePay.GooglePay_GoodsInfo		= "GoodsInfo"
GooglePay.GooglePay_OrderNum		= "OrderNum"
GooglePay.GooglePay_PurchaseToken	= "PurchaseToken"
GooglePay.GooglePay_ResultNumber	= "chongzhiduibibiaoji"

return GooglePay.new()
