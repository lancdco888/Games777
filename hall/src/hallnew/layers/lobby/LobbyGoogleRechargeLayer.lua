-- 跟hall的同名函数，加载后会替换hall的函数
function G_EnterRecharge()
	gorun(function ()
		--请求充值列表
		UIManager.ShowWaiting()
		local data_ = PKG_Client_Lobby_GetRecharge.Create()
		local rlt_ = gNet_SendRequest(data_)
		UIManager.HideWaiting()
		if (rlt_ == nil) then
			UIManager.ShowMsgBox(TR("打开充值界面错误!请重试!"))
		else
			if (getmetatable(rlt_) == PKG_Lobby_Client_GetRecharges) then
				--谷歌充值相关参数(谷歌充值金额列表不在 channelMoneys 里面 所有要单独拿)
				local googlemoneys = rlt_.googlemoneys
				dump(googlemoneys,"googlemoneys")
				sGameManager.rechargeAmountList = sGameManager.rechargeAmountList or {}
				sGameManager.rechargeAmountList[Def.googlepay_ID] = {}
				for _,v in ipairs(googlemoneys) do
					local new_table = {}
					new_table.product_id = v.product_id
					new_table.money = v.money
					new_table.dollar = v.dollar
					table.insert(sGameManager.rechargeAmountList[Def.googlepay_ID],new_table)
				end
				local layer = PopLayer:Pop(LobbyGoogleRechargeLayer)
			elseif (getmetatable(rlt_) == PKG_Generic_Error) then
				UIManager.ShowMsgBox(TR("打开充值界面错误!请重试!"))
			else
				UIManager.ShowMsgBox(TR("未知错误!!!"))
			end
		end
	end)
end

local LobbyGoogleRechargeLayer = class("LobbyGoogleRechargeLayer", function()
    return Tools.CreateLayer("csb/lobby/LobbyRechargeLayer.csb")
end)

function LobbyGoogleRechargeLayer:onEnter()
    self:InitUI()
end

function LobbyGoogleRechargeLayer:InitUI()
	local btn_close = self:findChild("btn_close")
    Tools.AddClickEvent(btn_close, function()
        self:Close()
    end, true)

	local rechargeAmountList = sGameManager.rechargeAmountList[Def.googlepay_ID]
	
	local items = self:InitAllItems()
	--添加金额按钮
	for index,value in ipairs(rechargeAmountList) do
		local item = items[index]
		if not item then break end

		local show_money = value.money
		local strTem = "$" .. value.dollar
		item.fnt:setString(strTem)
		item.on_click = function()
			sGameManager.recharge_data.product_id 	= value.product_id
			sGameManager.recharge_data.money 		= value.money
			GooglePay:Recharge()
		end
	end

	local count = #rechargeAmountList

	for i=count, #items do
		local item = items[i]
		if item then
			item:setVisible(false)
		end
	end
end

function LobbyGoogleRechargeLayer:InitAllItems()
	local items = {}
	for index=1,20 do
		local item = self:findChild("item_" .. index)
		if not item then break end

		item.fnt = item:findChild("fnt")
		item.btn = item:findChild("btn_money")
		Tools.AddClickEvent(item.btn, function()
			if item.on_click then
				item.on_click()
			end
		end, true)

		table.insert(items, item)
	end
	return items
end

return LobbyGoogleRechargeLayer