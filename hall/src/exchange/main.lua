import(".init")
import(".Recharge")

-- 退款开关
G_EXCH = true

function CheckVipLevel(channel_vip_level, my_vip_level)
	local min = 0
	local max = 0
	if channel_vip_level >= 20000 then
		-- 不支持的数据段，当成全部处理
		min = -100
		max = 100
	elseif channel_vip_level >= 10000 then
		-- 10076 表示适用于 vip0 到 76, 17676 表示只有 vip76
		min = math.floor((channel_vip_level / 100 )) % 100
		max = channel_vip_level % 100
	elseif channel_vip_level >= 200 then
		-- 不支持的数据段，当成全部处理
		min = -100
		max = 100
	elseif channel_vip_level >= 100 then
		-- 106表示适用于 vip0 到 6, 155 表示只有 vip5
		min = math.floor((channel_vip_level / 10 )) % 10
		max = channel_vip_level % 10
	else
		-- 不支持的数据段，当成全部处理
		min = -100
		max = 100
	end

	-- 游客 vip0
	if my_vip_level == -1 then my_vip_level = 0 end
	return my_vip_level >= min and my_vip_level <= max
end

function SortChannelsByGroup(channels)
    local ids = {}
    local group_name = {}
    local groups = {}

    local my_vip_level = sGameManager.GetMyVipLevel() or 0

    for _,channel in ipairs(channels) do
        local id = channel.id
        local channel_vip_level = channel.vip_level or 0

        local ok = CheckVipLevel(channel_vip_level, my_vip_level)
        -- dump({
        --     id = id,
        --     channel_vip_level = channel_vip_level,
        --     my_vip_level = my_vip_level,
        --     ok = ok
        -- }, "CheckVipLevel")

        if id and ok then
            table.insert(ids, id)
            local data = RechargeGetChannelCfg(id)
            if data and data.group then
                group_name[id] = data.group
                local g = groups[data.group]
                if g == nil then
                    g = {}
                    groups[data.group] = g
                end
                table.insert(g, id)
            end
        end
    end

    local choosen = {}
    for k,v in pairs(groups) do
        choosen[k] = v[(UserData.id % #v) + 1]
    end

    local new_ids = {}
    for idx,id in ipairs(ids) do
        local g = group_name[id]
        if g then
            if id == choosen[g] then
                table.insert(new_ids, id)
            end
        else
            table.insert(new_ids, id)
        end
    end

    local new_chanels = {}
    for _,id in ipairs(new_ids) do
        for _,data in pairs(channels) do
            if data.id == id then
                table.insert(new_chanels, data)
            end
        end
    end

    return new_chanels
end

function GetWebPayUrl()
    local data_ = PKG_Client_Lobby_ClientRechargeRequest.Create()
    data_.money = 0
    data_.pay_type = 1201
    data_.ip_info = ""
    data_.is_create_order = 1
    data_.pay_name = "nil"
    data_.pay_card_number = ""
    data_.upstream_order_num = ""
    data_.payment_key = ""
    UIManager.ShowWaiting()
    local rlt_ = gNet_SendRequest(data_)
    local PKG_name = getmetatable(rlt_)
    UIManager.HideWaiting()
    if PKG_name == PKG_Lobby_Client_ClientRechargeRequestSuccess then
        if rlt_.pay_url ~= "" then
            return rlt_.pay_url
        end
    elseif PKG_name == PKG_Generic_Error then
        dump(rlt_,"rlt_")
        local num = Int64ToNumber(rlt_.number)
        if (num == -120) then
            UIManager.ShowMsgBox(TR("您的上一笔支付订单我们正在审核操作中，请及时关注金币到账情况耐心等待！如有疑问请咨询客服。"))
        else
            UIManager.ShowMsgBox(TR("请求充值失败，请联系客服后重试"))
        end
    end
    return nil
end

function PopWebRecharge()
    local url = GetWebPayUrl()
    if not url then
        return false
    end

    local layer = PopLayer:Pop(WebLayer)
    layer:setUrl(url)
end

function FilterBadChannels(rlt_)
    local payChannels = rlt_.payChannels
    local channelMoneys = rlt_.channelMoneys
    local vipChannels = rlt_.vipChannels

    local function filter(tbl, fileter_func)
        local new_t = {}
        for _,item in ipairs(tbl) do
            if fileter_func(item) then
                table.insert(new_t, item)
            end
        end
        return new_t
    end

    -- 过滤掉没有 vip 信息的渠道
    local exist_vip_channel_ids = {}
    for _,vip_chanel in pairs(vipChannels) do
        if vip_chanel.pay_channel_id then exist_vip_channel_ids[vip_chanel.pay_channel_id] = true end
    end
    payChannels = filter(payChannels, function(info)
        return exist_vip_channel_ids[info.id] == true
    end)

    -- 搜集所有渠道
    local exist_channel_ids = {}
    for _,chanel in pairs(payChannels) do
        if chanel.id then exist_channel_ids[chanel.id] = true end
    end
    channelMoneys = filter(channelMoneys, function(info)
        return exist_channel_ids[info.pay_channel_id] == true
    end)
    vipChannels = filter(vipChannels, function(info)
        return exist_channel_ids[info.pay_channel_id] == true
    end)

    rlt_.payChannels = payChannels
    rlt_.channelMoneys = channelMoneys
    rlt_.vipChannels = vipChannels
    return rlt_
end

function PopNormalRecharge()
    local data_ = PKG_Client_Lobby_GetRecharge.Create()
    local rlt_ = GetCachedResponse(data_)
    if not rlt_ then
        UIManager.ShowWaiting()
        rlt_ = gNet_SendRequest(data_)
        UIManager.HideWaiting()
    end

    if (rlt_ == nil) then
        UIManager.ShowMsgBox(TR("打开充值界面错误!请重试!"))
    else
        if (getmetatable(rlt_) == PKG_Lobby_Client_GetRecharges) then
            AddCachedResponse(data_, rlt_, 30)

            -- 过滤掉不符合规则的渠道
            rlt_ = FilterBadChannels(rlt_)

            -- dump(rlt_,"充值信息")

            -- 1:10000 后台数字编辑越界, 客户端放大 10000 倍
            local scaleMoney
            if sGameManager.exchangerate == 10000 then
                scaleMoney = 10000
            else
                scaleMoney = 1
            end

            --充值渠道表
            sGameManager.payChannels = SortChannelsByGroup(rlt_.payChannels)
            sGameManager.recharge_max_money = rlt_.recharge_max_money
            sGameManager.recharge_min_money = rlt_.recharge_min_money
            --玩家修改实名信息,金币不可超越值
            sGameManager.max_fix_realname_money = rlt_.max_fix_realname_money
            --支付金额表
            sGameManager.channelMoneys = rlt_.channelMoneys
            --充值信息表
            sGameManager.vipChannels = rlt_.vipChannels or {}
            --充值识别金额
            sGameManager.accuracy = rlt_.accuracy
            --得到对应渠道的金额列表
            sGameManager.rechargeAmountList = {}
            local isExistGooglePay = false
            for i,pay in ipairs(sGameManager.payChannels) do
                if pay.id == Def.googlepay_ID then
                    isExistGooglePay = true
                end
                sGameManager.rechargeAmountList[pay.id] = {}
                for _,channel in pairs(sGameManager.channelMoneys) do
                    if channel.pay_channel_id == pay.id then
                        local new_table = {}
                        new_table.product_id = channel.pay_channel_id
                        new_table.money = channel.money * scaleMoney
                        table.insert(sGameManager.rechargeAmountList[pay.id],new_table)
                    end
                end
            end
            --谷歌充值相关参数(谷歌充值金额列表不在 channelMoneys 里面 所有要单独拿)
            local googlemoneys = rlt_.googlemoneys
            sGameManager.rechargeAmountList[Def.googlepay_ID] = {}
            for _,v in ipairs(googlemoneys) do
                local new_table = {}
                new_table.product_id = v.product_id
                new_table.money = v.money
                new_table.dollar = v.dollar
                table.insert(sGameManager.rechargeAmountList[Def.googlepay_ID],new_table)
            end

            for index=#sGameManager.payChannels,1,-1 do
                local val = sGameManager.payChannels[index]
                if val.id and not Recharge.RechargeChannelListData[val.id] then
                    table.remove(sGameManager.payChannels, index)
                    UIManager.ShowToast("not found recharge, ignore:" .. tostring(val.id))
                end
            end
            if isExistGooglePay then
                local layer = PopLayer:Pop(LobbyGoogleRechargeLayer)
                return
            end

            PopLayer:Pop(LobbyRechargeLayer)
        elseif (getmetatable(rlt_) == PKG_Generic_Error) then
            UIManager.ShowMsgBox(TR("打开充值界面错误!请重试!"))
        else
            UIManager.ShowMsgBox(TR("未知错误!!!"))
        end
    end
end

function G_EnterRecharge()
    gorun(function ()
        PopNormalRecharge()
    end)
end

-- 打开退款界面
function G_EnterExc()
    go(function()
        local data_ = PKG_Client_Lobby_GetRefundInfo.Create()
        local rlt_ = GetCachedResponse(data_)
        if not rlt_ then
            UIManager.ShowWaiting()
            rlt_ = gNet_SendRequest(data_)
            UIManager.HideWaiting()
        end

        if getmetatable(rlt_) == PKG_Lobby_Client_GetRefundInfo then
            AddCachedResponse(data_, rlt_)

            sGameManager.exchange_payChannels = rlt_.PayChannels
            -- dump(sGameManager.exchange_payChannels,"sGameManager.exchange_payChannels")
            sGameManager.exchange_QRpath = rlt_.qr_image
            sGameManager.exchange_QRBank = rlt_.qr_bank_name
            local list_1 = {}
            for key, value in pairs(sGameManager.exchange_payChannels) do
                if type(key) == "number" then
                    table.insert(list_1,key,value)
                end
            end
            for index=#list_1,1,-1 do
                local val = list_1[index]
                if val.id > 2000 then -- 虚拟货币
                    if not UserData:CanUseVirtualRecharge() then
                        table.remove(list_1, index)
                    end
                else -- 普通货币
                    if not UserData:CanUseCommonRecharge() then
                        table.remove(list_1, index)
                    end
                end
            end
            sGameManager.exchange_payChannels = list_1
            if #list_1 ~= 0 then
                local layer = PopLayer:Pop(ExchangeLayer)
                layer:CheckIsBindCard()
            else
                UIManager.ShowMsgBox(TR("暂未开放!"))
            end
        elseif getmetatable(rlt_) == PKG_Generic_Error then
            local num = Int64ToNumber(rlt_.number)
            UIManager.ShowMsgBox(TR("网络连接失败，请重试"))
        end
    end)
end

function G_CreateBtn(node)
    local exchange_btn = node:clone()
    local png_path = "language/lobby/btn_exchange.png"
    exchange_btn:loadTextures(png_path,png_path,png_path)
    Tools.AddClickEvent(exchange_btn, function()
        G_EnterExc()
    end, true)
    exchange_btn:setName("lua_btn_exchange")
    return exchange_btn
end
