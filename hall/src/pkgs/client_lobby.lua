
CodeGen_client_lobby_md5 ="#*MD5<1b987e9e722b78ab9a9866551f940a9e>*#"

--[[
请求移动指令的处理结果的基类
]]
PKG_Lobby_Client_Move_Result = {
    typeName = "PKG_Lobby_Client_Move_Result",
    typeId = 1201,
    Create = function(o)
        if o == nil then
            o = {}
            setmetatable(o, PKG_Lobby_Client_Move_Result)
        end
        return o
    end,
    Read = function(self, om)
        local d = om.d
        local r, n
        return 0
    end,
    Write = function(self, om)
        local d = om.d
    end
}
PKG_Lobby_Client_Move_Result.__index = PKG_Lobby_Client_Move_Result

--[[
在大厅中移动的所有指令的基类
]]
PKG_Client_Lobby_Move = {
    typeName = "PKG_Client_Lobby_Move",
    typeId = 2001,
    Create = function(o)
        if o == nil then
            o = {}
            setmetatable(o, PKG_Client_Lobby_Move)
        end
        return o
    end,
    Read = function(self, om)
        local d = om.d
        local r, n
        return 0
    end,
    Write = function(self, om)
        local d = om.d
    end
}
PKG_Client_Lobby_Move.__index = PKG_Client_Lobby_Move

--[[
玩家绑定的支付信息
]]
PKG_Lobby_Client_PayChannelAccount = {
    typeName = "PKG_Lobby_Client_PayChannelAccount",
    typeId = 1205,
    Create = function(o)
        if o == nil then
            o = {}
            setmetatable(o, PKG_Lobby_Client_PayChannelAccount)
        end
        --[[
        id
        ]]
        o.id = 0 -- Int32
        --[[
        pay_channel_id
        ]]
        o.pay_channel_id = 0 -- Int32
        --[[
        持卡人姓名/实名人姓名
        ]]
        o.name = "" -- String
        --[[
        银行卡卡号/支付宝账号
        ]]
        o.card_number = "" -- String
        --[[
        银行名称
        ]]
        o.bank_name = "" -- String
        return o
    end,
    Read = function(self, om)
        local d = om.d
        local r, n
        -- id
        r, self.id = d:Rvi32()
        if r ~= 0 then return r end
        -- pay_channel_id
        r, self.pay_channel_id = d:Rvi32()
        if r ~= 0 then return r end
        -- name
        r, self.name = d:Rstr()
        if r ~= 0 then return r end
        -- card_number
        r, self.card_number = d:Rstr()
        if r ~= 0 then return r end
        -- bank_name
        r, self.bank_name = d:Rstr()
        if r ~= 0 then return r end
        return 0
    end,
    Write = function(self, om)
        local d = om.d
        -- id
        d:Wvi32(self.id)
        -- pay_channel_id
        d:Wvi32(self.pay_channel_id)
        -- name
        d:Wstr(self.name)
        -- card_number
        d:Wstr(self.card_number)
        -- bank_name
        d:Wstr(self.bank_name)
    end
}
PKG_Lobby_Client_PayChannelAccount.__index = PKG_Lobby_Client_PayChannelAccount

--[[
所有座位玩家列表
]]
PKG_Lobby_Client_RoomPlayers = {
    typeName = "PKG_Lobby_Client_RoomPlayers",
    typeId = 1212,
    Create = function(o)
        if o == nil then
            o = {}
            setmetatable(o, PKG_Lobby_Client_RoomPlayers)
        end
        --[[
        用户Id ( 随机 8 位整数 )
        ]]
        o.id = 0 -- Int32
        --[[
        昵称 唯一( 默认用某种规则生成 )
        ]]
        o.nickname = "" -- String
        --[[
        头像
        ]]
        o.avatar_id = 0 -- Int32
        --[[
        账户余额( 保留4位小数位, 进部分游戏时会被清0, 结束时会退款返还 )
        ]]
        o.money = 0 -- Double
        --[[
        是否机器人(1机器人)
        ]]
        o.is_robot = 0 -- Int32
        return o
    end,
    Read = function(self, om)
        local d = om.d
        local r, n
        -- id
        r, self.id = d:Rvi32()
        if r ~= 0 then return r end
        -- nickname
        r, self.nickname = d:Rstr()
        if r ~= 0 then return r end
        -- avatar_id
        r, self.avatar_id = d:Rvi32()
        if r ~= 0 then return r end
        -- money
        r, self.money = d:Rd()
        if r ~= 0 then return r end
        -- is_robot
        r, self.is_robot = d:Rvi32()
        if r ~= 0 then return r end
        return 0
    end,
    Write = function(self, om)
        local d = om.d
        -- id
        d:Wvi32(self.id)
        -- nickname
        d:Wstr(self.nickname)
        -- avatar_id
        d:Wvi32(self.avatar_id)
        -- money
        d:Wd(self.money)
        -- is_robot
        d:Wvi32(self.is_robot)
    end
}
PKG_Lobby_Client_RoomPlayers.__index = PKG_Lobby_Client_RoomPlayers

--[[
支付方式信息
]]
PKG_Lobby_Client_PayChannel = {
    typeName = "PKG_Lobby_Client_PayChannel",
    typeId = 1230,
    Create = function(o)
        if o == nil then
            o = {}
            setmetatable(o, PKG_Lobby_Client_PayChannel)
        end
        --[[
        支付方式id
        ]]
        o.id = 0 -- Int32
        --[[
        支付方式名称
        ]]
        o.name = "" -- String
        --[[
        是否添加识别金额
        ]]
        o.is_accuracy = 0 -- Int32
        --[[
        汇率
        ]]
        o.exchange = 0 -- Double
        --[[
        vip等级限制
        ]]
        o.vip_level = 0 -- Int32
        return o
    end,
    Read = function(self, om)
        local d = om.d
        local r, n
        -- id
        r, self.id = d:Rvi32()
        if r ~= 0 then return r end
        -- name
        r, self.name = d:Rstr()
        if r ~= 0 then return r end
        -- is_accuracy
        r, self.is_accuracy = d:Rvi32()
        if r ~= 0 then return r end
        -- exchange
        r, self.exchange = d:Rd()
        if r ~= 0 then return r end
        -- vip_level
        r, self.vip_level = d:Rvi32()
        if r ~= 0 then return r end
        return 0
    end,
    Write = function(self, om)
        local d = om.d
        -- id
        d:Wvi32(self.id)
        -- name
        d:Wstr(self.name)
        -- is_accuracy
        d:Wvi32(self.is_accuracy)
        -- exchange
        d:Wd(self.exchange)
        -- vip_level
        d:Wvi32(self.vip_level)
    end
}
PKG_Lobby_Client_PayChannel.__index = PKG_Lobby_Client_PayChannel

--[[
老虎机倍率区间
]]
PKG_Lobby_Client_EntryConditions = {
    typeName = "PKG_Lobby_Client_EntryConditions",
    typeId = 1263,
    Create = function(o)
        if o == nil then
            o = {}
            setmetatable(o, PKG_Lobby_Client_EntryConditions)
        end
        --[[
        算法级别ID
        ]]
        o.id = 0 -- Int32
        --[[
        押注区间:最小值
        ]]
        o.spinMinMoney = 0 -- Double
        --[[
        押注区间:最大值
        ]]
        o.spinMaxMoney = 0 -- Double
        --[[
        进入该算法区间的最小值
        ]]
        o.enterMinMoney = 0 -- Double
        --[[
        游戏等级进入转换比例
        ]]
        o.exChangeCoinRatio = 0 -- Int32
        --[[
        描述名称
        ]]
        o.desc = "" -- String
        return o
    end,
    Read = function(self, om)
        local d = om.d
        local r, n
        -- id
        r, self.id = d:Rvi32()
        if r ~= 0 then return r end
        -- spinMinMoney
        r, self.spinMinMoney = d:Rd()
        if r ~= 0 then return r end
        -- spinMaxMoney
        r, self.spinMaxMoney = d:Rd()
        if r ~= 0 then return r end
        -- enterMinMoney
        r, self.enterMinMoney = d:Rd()
        if r ~= 0 then return r end
        -- exChangeCoinRatio
        r, self.exChangeCoinRatio = d:Rvi32()
        if r ~= 0 then return r end
        -- desc
        r, self.desc = d:Rstr()
        if r ~= 0 then return r end
        return 0
    end,
    Write = function(self, om)
        local d = om.d
        -- id
        d:Wvi32(self.id)
        -- spinMinMoney
        d:Wd(self.spinMinMoney)
        -- spinMaxMoney
        d:Wd(self.spinMaxMoney)
        -- enterMinMoney
        d:Wd(self.enterMinMoney)
        -- exChangeCoinRatio
        d:Wvi32(self.exChangeCoinRatio)
        -- desc
        d:Wstr(self.desc)
    end
}
PKG_Lobby_Client_EntryConditions.__index = PKG_Lobby_Client_EntryConditions

--[[
返回活动状态
]]
PKG_Lobby_Client_Activity_Status = {
    typeName = "PKG_Lobby_Client_Activity_Status",
    typeId = 1290,
    Create = function(o)
        if o == nil then
            o = {}
            setmetatable(o, PKG_Lobby_Client_Activity_Status)
        end
        --[[
        类型,1=洗码赠送绑定金币活动
        ]]
        o.id = 0 -- Int32
        --[[
        类型,1=打开
        ]]
        o.is_open = 0 -- Int32
        --[[
        活动配置
        ]]
        o.config = "" -- String
        return o
    end,
    Read = function(self, om)
        local d = om.d
        local r, n
        -- id
        r, self.id = d:Rvi32()
        if r ~= 0 then return r end
        -- is_open
        r, self.is_open = d:Rvi32()
        if r ~= 0 then return r end
        -- config
        r, self.config = d:Rstr()
        if r ~= 0 then return r end
        return 0
    end,
    Write = function(self, om)
        local d = om.d
        -- id
        d:Wvi32(self.id)
        -- is_open
        d:Wvi32(self.is_open)
        -- config
        d:Wstr(self.config)
    end
}
PKG_Lobby_Client_Activity_Status.__index = PKG_Lobby_Client_Activity_Status

--[[
我的用户
]]
PKG_Lobby_Client_PromotionUser = {
    typeName = "PKG_Lobby_Client_PromotionUser",
    typeId = 1249,
    Create = function(o)
        if o == nil then
            o = {}
            setmetatable(o, PKG_Lobby_Client_PromotionUser)
        end
        --[[
        ID
        ]]
        o.id = 0 -- Int32
        --[[
        用户名
        ]]
        o.username = "" -- String
        --[[
        昵称
        ]]
        o.nickname = "" -- String
        --[[
        头像id
        ]]
        o.avatar_id = 0 -- Int32
        --[[
        最后在线时间
        ]]
        o.last_online_time = 0 -- Int64
        --[[
        加入工会时间
        ]]
        o.join_promotion_time = 0 -- Int64
        --[[
        状态 0=不在线 1=在线
        ]]
        o.status = 0 -- Int32
        --[[
        是否禁言 1=不能说话 0=可以说话
        ]]
        o.authority = 0 -- Int32
        return o
    end,
    Read = function(self, om)
        local d = om.d
        local r, n
        -- id
        r, self.id = d:Rvi32()
        if r ~= 0 then return r end
        -- username
        r, self.username = d:Rstr()
        if r ~= 0 then return r end
        -- nickname
        r, self.nickname = d:Rstr()
        if r ~= 0 then return r end
        -- avatar_id
        r, self.avatar_id = d:Rvi32()
        if r ~= 0 then return r end
        -- last_online_time
        r, self.last_online_time = d:Rvi64()
        if r ~= 0 then return r end
        -- join_promotion_time
        r, self.join_promotion_time = d:Rvi64()
        if r ~= 0 then return r end
        -- status
        r, self.status = d:Rvi32()
        if r ~= 0 then return r end
        -- authority
        r, self.authority = d:Rvi32()
        if r ~= 0 then return r end
        return 0
    end,
    Write = function(self, om)
        local d = om.d
        -- id
        d:Wvi32(self.id)
        -- username
        d:Wstr(self.username)
        -- nickname
        d:Wstr(self.nickname)
        -- avatar_id
        d:Wvi32(self.avatar_id)
        -- last_online_time
        d:Wvi64(self.last_online_time)
        -- join_promotion_time
        d:Wvi64(self.join_promotion_time)
        -- status
        d:Wvi32(self.status)
        -- authority
        d:Wvi32(self.authority)
    end
}
PKG_Lobby_Client_PromotionUser.__index = PKG_Lobby_Client_PromotionUser

--[[
我的利润
]]
PKG_Lobby_Client_PromotionProfit = {
    typeName = "PKG_Lobby_Client_PromotionProfit",
    typeId = 1248,
    Create = function(o)
        if o == nil then
            o = {}
            setmetatable(o, PKG_Lobby_Client_PromotionProfit)
        end
        --[[
        还有几个分钟后才能领取
        ]]
        o.have_give_minute = 0 -- Int32
        --[[
        收益
        ]]
        o.profit_washcode = 0 -- Double
        --[[
        总收益
        ]]
        o.all_profit = 0 -- Double
        return o
    end,
    Read = function(self, om)
        local d = om.d
        local r, n
        -- have_give_minute
        r, self.have_give_minute = d:Rvi32()
        if r ~= 0 then return r end
        -- profit_washcode
        r, self.profit_washcode = d:Rd()
        if r ~= 0 then return r end
        -- all_profit
        r, self.all_profit = d:Rd()
        if r ~= 0 then return r end
        return 0
    end,
    Write = function(self, om)
        local d = om.d
        -- have_give_minute
        d:Wvi32(self.have_give_minute)
        -- profit_washcode
        d:Wd(self.profit_washcode)
        -- all_profit
        d:Wd(self.all_profit)
    end
}
PKG_Lobby_Client_PromotionProfit.__index = PKG_Lobby_Client_PromotionProfit

--[[
我的推广
]]
PKG_Lobby_Client_PromotionDetail = {
    typeName = "PKG_Lobby_Client_PromotionDetail",
    typeId = 1247,
    Create = function(o)
        if o == nil then
            o = {}
            setmetatable(o, PKG_Lobby_Client_PromotionDetail)
        end
        --[[
        推广链接
        ]]
        o.link_url = "" -- String
        --[[
        推广二维码
        ]]
        o.qrcode_url = "" -- String
        --[[
        推广码
        ]]
        o.promotion_code = "" -- String
        return o
    end,
    Read = function(self, om)
        local d = om.d
        local r, n
        -- link_url
        r, self.link_url = d:Rstr()
        if r ~= 0 then return r end
        -- qrcode_url
        r, self.qrcode_url = d:Rstr()
        if r ~= 0 then return r end
        -- promotion_code
        r, self.promotion_code = d:Rstr()
        if r ~= 0 then return r end
        return 0
    end,
    Write = function(self, om)
        local d = om.d
        -- link_url
        d:Wstr(self.link_url)
        -- qrcode_url
        d:Wstr(self.qrcode_url)
        -- promotion_code
        d:Wstr(self.promotion_code)
    end
}
PKG_Lobby_Client_PromotionDetail.__index = PKG_Lobby_Client_PromotionDetail

--[[
金额变化通知
]]
PKG_Lobby_Client_MoneyChanged = {
    typeName = "PKG_Lobby_Client_MoneyChanged",
    typeId = 1236,
    Create = function(o)
        if o == nil then
            o = {}
            setmetatable(o, PKG_Lobby_Client_MoneyChanged)
        end
        --[[
        账户余额
        ]]
        o.money = 0 -- Double
        --[[
        账户保险箱余额
        ]]
        o.money_safe = 0 -- Double
        --[[
        绑定金币
        ]]
        o.money_gift = 0 -- Double
        --[[
        绑定金币保险箱
        ]]
        o.money_gift_safe = 0 -- Double
        --[[
        累计退款金额
        ]]
        o.total_refund = 0 -- Double
        --[[
        累计充值金额
        ]]
        o.total_recharge = 0 -- Double
        --[[
        vip 等级 -1=没有vip
        ]]
        o.vip_level = 0 -- Int32
        --[[
        虚拟币充值状态=0只允许常规充值,=1只允许虚拟钱包充值
        ]]
        o.virtual_coin_status = 0 -- Int32
        --[[
        是否是测试账号 1=是
        ]]
        o.is_experience = 0 -- Int32
        return o
    end,
    Read = function(self, om)
        local d = om.d
        local r, n
        -- money
        r, self.money = d:Rd()
        if r ~= 0 then return r end
        -- money_safe
        r, self.money_safe = d:Rd()
        if r ~= 0 then return r end
        -- money_gift
        r, self.money_gift = d:Rd()
        if r ~= 0 then return r end
        -- money_gift_safe
        r, self.money_gift_safe = d:Rd()
        if r ~= 0 then return r end
        -- total_refund
        r, self.total_refund = d:Rd()
        if r ~= 0 then return r end
        -- total_recharge
        r, self.total_recharge = d:Rd()
        if r ~= 0 then return r end
        -- vip_level
        r, self.vip_level = d:Rvi32()
        if r ~= 0 then return r end
        -- virtual_coin_status
        r, self.virtual_coin_status = d:Rvi32()
        if r ~= 0 then return r end
        -- is_experience
        r, self.is_experience = d:Rvi32()
        if r ~= 0 then return r end
        return 0
    end,
    Write = function(self, om)
        local d = om.d
        -- money
        d:Wd(self.money)
        -- money_safe
        d:Wd(self.money_safe)
        -- money_gift
        d:Wd(self.money_gift)
        -- money_gift_safe
        d:Wd(self.money_gift_safe)
        -- total_refund
        d:Wd(self.total_refund)
        -- total_recharge
        d:Wd(self.total_recharge)
        -- vip_level
        d:Wvi32(self.vip_level)
        -- virtual_coin_status
        d:Wvi32(self.virtual_coin_status)
        -- is_experience
        d:Wvi32(self.is_experience)
    end
}
PKG_Lobby_Client_MoneyChanged.__index = PKG_Lobby_Client_MoneyChanged

--[[
google充值配置
]]
PKG_Lobby_Client_google_money = {
    typeName = "PKG_Lobby_Client_google_money",
    typeId = 1234,
    Create = function(o)
        if o == nil then
            o = {}
            setmetatable(o, PKG_Lobby_Client_google_money)
        end
        --[[
        产品Id
        ]]
        o.product_id = "" -- String
        --[[
        所得金币
        ]]
        o.money = 0 -- Double
        --[[
        美元
        ]]
        o.dollar = 0 -- Double
        return o
    end,
    Read = function(self, om)
        local d = om.d
        local r, n
        -- product_id
        r, self.product_id = d:Rstr()
        if r ~= 0 then return r end
        -- money
        r, self.money = d:Rd()
        if r ~= 0 then return r end
        -- dollar
        r, self.dollar = d:Rd()
        if r ~= 0 then return r end
        return 0
    end,
    Write = function(self, om)
        local d = om.d
        -- product_id
        d:Wstr(self.product_id)
        -- money
        d:Wd(self.money)
        -- dollar
        d:Wd(self.dollar)
    end
}
PKG_Lobby_Client_google_money.__index = PKG_Lobby_Client_google_money

--[[
配置支付渠道金额
]]
PKG_Lobby_Client_config_channel_money = {
    typeName = "PKG_Lobby_Client_config_channel_money",
    typeId = 1232,
    Create = function(o)
        if o == nil then
            o = {}
            setmetatable(o, PKG_Lobby_Client_config_channel_money)
        end
        --[[
        支付渠道Id
        ]]
        o.pay_channel_id = 0 -- Int32
        --[[
        金额
        ]]
        o.money = 0 -- Int32
        return o
    end,
    Read = function(self, om)
        local d = om.d
        local r, n
        -- pay_channel_id
        r, self.pay_channel_id = d:Rvi32()
        if r ~= 0 then return r end
        -- money
        r, self.money = d:Rvi32()
        if r ~= 0 then return r end
        return 0
    end,
    Write = function(self, om)
        local d = om.d
        -- pay_channel_id
        d:Wvi32(self.pay_channel_id)
        -- money
        d:Wvi32(self.money)
    end
}
PKG_Lobby_Client_config_channel_money.__index = PKG_Lobby_Client_config_channel_money

--[[
私聊聊天记录
]]
PKG_Lobby_Client_PrivateMessage = {
    typeName = "PKG_Lobby_Client_PrivateMessage",
    typeId = 1332,
    Create = function(o)
        if o == nil then
            o = {}
            setmetatable(o, PKG_Lobby_Client_PrivateMessage)
        end
        --[[
        时间戳
        ]]
        o.time = 0 -- Int64
        --[[
        发件人
        ]]
        o.source_id = 0 -- Int32
        --[[
        头像id
        ]]
        o.source_avatar_id = 0 -- Int32
        --[[
        昵称
        ]]
        o.source_nickname = "" -- String
        --[[
        是否是商人 1=商人 0不是
        ]]
        o.source_is_businessman = 0 -- Int32
        --[[
        目标玩家
        ]]
        o.target_id = 0 -- Int32
        --[[
        内容
        ]]
        o.content = "" -- String
        --[[
        金币
        ]]
        o.money = 0 -- Double
        --[[
        VIP等级
        ]]
        o.vip_level = 0 -- Int32
        return o
    end,
    Read = function(self, om)
        local d = om.d
        local r, n
        -- time
        r, self.time = d:Rvi64()
        if r ~= 0 then return r end
        -- source_id
        r, self.source_id = d:Rvi32()
        if r ~= 0 then return r end
        -- source_avatar_id
        r, self.source_avatar_id = d:Rvi32()
        if r ~= 0 then return r end
        -- source_nickname
        r, self.source_nickname = d:Rstr()
        if r ~= 0 then return r end
        -- source_is_businessman
        r, self.source_is_businessman = d:Rvi32()
        if r ~= 0 then return r end
        -- target_id
        r, self.target_id = d:Rvi32()
        if r ~= 0 then return r end
        -- content
        r, self.content = d:Rstr()
        if r ~= 0 then return r end
        -- money
        r, self.money = d:Rd()
        if r ~= 0 then return r end
        -- vip_level
        r, self.vip_level = d:Rvi32()
        if r ~= 0 then return r end
        return 0
    end,
    Write = function(self, om)
        local d = om.d
        -- time
        d:Wvi64(self.time)
        -- source_id
        d:Wvi32(self.source_id)
        -- source_avatar_id
        d:Wvi32(self.source_avatar_id)
        -- source_nickname
        d:Wstr(self.source_nickname)
        -- source_is_businessman
        d:Wvi32(self.source_is_businessman)
        -- target_id
        d:Wvi32(self.target_id)
        -- content
        d:Wstr(self.content)
        -- money
        d:Wd(self.money)
        -- vip_level
        d:Wvi32(self.vip_level)
    end
}
PKG_Lobby_Client_PrivateMessage.__index = PKG_Lobby_Client_PrivateMessage

--[[
公告
]]
PKG_Lobby_Client_Notice = {
    typeName = "PKG_Lobby_Client_Notice",
    typeId = 1227,
    Create = function(o)
        if o == nil then
            o = {}
            setmetatable(o, PKG_Lobby_Client_Notice)
        end
        --[[
        id
        ]]
        o.id = 0 -- Int32
        --[[
        标题
        ]]
        o.title = "" -- String
        --[[
        内容
        ]]
        o.content = "" -- String
        --[[
        图片url(多个图片用逗号分隔)
        ]]
        o.urls = "" -- String
        --[[
        发件人
        ]]
        o.sender = "" -- String
        --[[
        创建时间
        ]]
        o.create_time = 0 -- Int64
        --[[
        是否已读(0未读, 1已读)
        ]]
        o.is_read = 0 -- Int32
        --[[
        1公告，2邮件)
        ]]
        o.type = 0 -- Int32
        --[[
        1全服公告，2大厅公告)
        ]]
        o.notice_type = 0 -- Int32
        --[[
        是否弹出显示(1弹出显示)
        ]]
        o.is_show = 0 -- Int32
        --[[
        对应模板key
        ]]
        o.template_key = "" -- String
        return o
    end,
    Read = function(self, om)
        local d = om.d
        local r, n
        -- id
        r, self.id = d:Rvi32()
        if r ~= 0 then return r end
        -- title
        r, self.title = d:Rstr()
        if r ~= 0 then return r end
        -- content
        r, self.content = d:Rstr()
        if r ~= 0 then return r end
        -- urls
        r, self.urls = d:Rstr()
        if r ~= 0 then return r end
        -- sender
        r, self.sender = d:Rstr()
        if r ~= 0 then return r end
        -- create_time
        r, self.create_time = d:Rvi64()
        if r ~= 0 then return r end
        -- is_read
        r, self.is_read = d:Rvi32()
        if r ~= 0 then return r end
        -- type
        r, self.type = d:Rvi32()
        if r ~= 0 then return r end
        -- notice_type
        r, self.notice_type = d:Rvi32()
        if r ~= 0 then return r end
        -- is_show
        r, self.is_show = d:Rvi32()
        if r ~= 0 then return r end
        -- template_key
        r, self.template_key = d:Rstr()
        if r ~= 0 then return r end
        return 0
    end,
    Write = function(self, om)
        local d = om.d
        -- id
        d:Wvi32(self.id)
        -- title
        d:Wstr(self.title)
        -- content
        d:Wstr(self.content)
        -- urls
        d:Wstr(self.urls)
        -- sender
        d:Wstr(self.sender)
        -- create_time
        d:Wvi64(self.create_time)
        -- is_read
        d:Wvi32(self.is_read)
        -- type
        d:Wvi32(self.type)
        -- notice_type
        d:Wvi32(self.notice_type)
        -- is_show
        d:Wvi32(self.is_show)
        -- template_key
        d:Wstr(self.template_key)
    end
}
PKG_Lobby_Client_Notice.__index = PKG_Lobby_Client_Notice

--[[
...
]]
PKG_Lobby_Client_TodayEarnMoney = {
    typeName = "PKG_Lobby_Client_TodayEarnMoney",
    typeId = 1225,
    Create = function(o)
        if o == nil then
            o = {}
            setmetatable(o, PKG_Lobby_Client_TodayEarnMoney)
        end
        --[[
        名次
        ]]
        o.ranking = 0 -- Int32
        --[[
        玩家id
        ]]
        o.account_id = 0 -- Int32
        --[[
        玩家username
        ]]
        o.username = "" -- String
        --[[
        玩家nickname
        ]]
        o.nickname = "" -- String
        --[[
        玩家头像
        ]]
        o.avatar_id = 0 -- Int32
        --[[
        玩家赢金币总量
        ]]
        o.money = 0 -- Double
        --[[
        玩家Vip等级
        ]]
        o.vip = 0 -- Int32
        return o
    end,
    Read = function(self, om)
        local d = om.d
        local r, n
        -- ranking
        r, self.ranking = d:Rvi32()
        if r ~= 0 then return r end
        -- account_id
        r, self.account_id = d:Rvi32()
        if r ~= 0 then return r end
        -- username
        r, self.username = d:Rstr()
        if r ~= 0 then return r end
        -- nickname
        r, self.nickname = d:Rstr()
        if r ~= 0 then return r end
        -- avatar_id
        r, self.avatar_id = d:Rvi32()
        if r ~= 0 then return r end
        -- money
        r, self.money = d:Rd()
        if r ~= 0 then return r end
        -- vip
        r, self.vip = d:Rvi32()
        if r ~= 0 then return r end
        return 0
    end,
    Write = function(self, om)
        local d = om.d
        -- ranking
        d:Wvi32(self.ranking)
        -- account_id
        d:Wvi32(self.account_id)
        -- username
        d:Wstr(self.username)
        -- nickname
        d:Wstr(self.nickname)
        -- avatar_id
        d:Wvi32(self.avatar_id)
        -- money
        d:Wd(self.money)
        -- vip
        d:Wvi32(self.vip)
    end
}
PKG_Lobby_Client_TodayEarnMoney.__index = PKG_Lobby_Client_TodayEarnMoney

--[[
申请退款表
]]
PKG_Lobby_Client_RefundInfo = {
    typeName = "PKG_Lobby_Client_RefundInfo",
    typeId = 1222,
    Create = function(o)
        if o == nil then
            o = {}
            setmetatable(o, PKG_Lobby_Client_RefundInfo)
        end
        --[[
        退款订单号( 时间戳 )
        ]]
        o.refund_id = 0 -- Int64
        --[[
        帐号id
        ]]
        o.account_id = 0 -- Int32
        --[[
        退款金额
        ]]
        o.money = 0 -- Double
        --[[
        手续费
        ]]
        o.server_fee_money = 0 -- Double
        --[[
        请求退款的实名
        ]]
        o.cash_name = "" -- String
        --[[
        退款请求的实名账号
        ]]
        o.cash_account = "" -- String
        --[[
        如果是银行退款，则会显示银行名称
        ]]
        o.cash_bank_name = "" -- String
        --[[
        0 打款成功或者退币中，1 退币成功
        ]]
        o.return_pay_status = 0 -- Int32
        --[[
        操作状态(0=apply; 1=success; 2=failed;)
        ]]
        o.state = 0 -- Int32
        --[[
        操作描述
        ]]
        o.description = "" -- String
        --[[
        退款申请时间
        ]]
        o.create_time = 0 -- Int64
        --[[
        最后处理时间
        ]]
        o.updated_time = 0 -- Int64
        --[[
        支付渠道基表id，1 支付宝，2 银行卡
        ]]
        o.pay_channel_id = 0 -- Int32
        --[[
        退款前玩家的账户金额
        ]]
        o.before_money = 0 -- Double
        --[[
        退款前玩家的保险箱金额
        ]]
        o.before_money_safe = 0 -- Double
        --[[
        退款后玩家金币
        ]]
        o.after_money = 0 -- Double
        --[[
        退款后玩家保险箱金币
        ]]
        o.after_money_safe = 0 -- Double
        --[[
        是否为异常订单,0不是，1是
        ]]
        o.is_execption = 0 -- Int32
        o.ip = "" -- String
        o.ip_area = "" -- String
        return o
    end,
    Read = function(self, om)
        local d = om.d
        local r, n
        -- refund_id
        r, self.refund_id = d:Rvi64()
        if r ~= 0 then return r end
        -- account_id
        r, self.account_id = d:Rvi32()
        if r ~= 0 then return r end
        -- money
        r, self.money = d:Rd()
        if r ~= 0 then return r end
        -- server_fee_money
        r, self.server_fee_money = d:Rd()
        if r ~= 0 then return r end
        -- cash_name
        r, self.cash_name = d:Rstr()
        if r ~= 0 then return r end
        -- cash_account
        r, self.cash_account = d:Rstr()
        if r ~= 0 then return r end
        -- cash_bank_name
        r, self.cash_bank_name = d:Rstr()
        if r ~= 0 then return r end
        -- return_pay_status
        r, self.return_pay_status = d:Rvi32()
        if r ~= 0 then return r end
        -- state
        r, self.state = d:Rvi32()
        if r ~= 0 then return r end
        -- description
        r, self.description = d:Rstr()
        if r ~= 0 then return r end
        -- create_time
        r, self.create_time = d:Rvi64()
        if r ~= 0 then return r end
        -- updated_time
        r, self.updated_time = d:Rvi64()
        if r ~= 0 then return r end
        -- pay_channel_id
        r, self.pay_channel_id = d:Rvi32()
        if r ~= 0 then return r end
        -- before_money
        r, self.before_money = d:Rd()
        if r ~= 0 then return r end
        -- before_money_safe
        r, self.before_money_safe = d:Rd()
        if r ~= 0 then return r end
        -- after_money
        r, self.after_money = d:Rd()
        if r ~= 0 then return r end
        -- after_money_safe
        r, self.after_money_safe = d:Rd()
        if r ~= 0 then return r end
        -- is_execption
        r, self.is_execption = d:Rvi32()
        if r ~= 0 then return r end
        -- ip
        r, self.ip = d:Rstr()
        if r ~= 0 then return r end
        -- ip_area
        r, self.ip_area = d:Rstr()
        if r ~= 0 then return r end
        return 0
    end,
    Write = function(self, om)
        local d = om.d
        -- refund_id
        d:Wvi64(self.refund_id)
        -- account_id
        d:Wvi32(self.account_id)
        -- money
        d:Wd(self.money)
        -- server_fee_money
        d:Wd(self.server_fee_money)
        -- cash_name
        d:Wstr(self.cash_name)
        -- cash_account
        d:Wstr(self.cash_account)
        -- cash_bank_name
        d:Wstr(self.cash_bank_name)
        -- return_pay_status
        d:Wvi32(self.return_pay_status)
        -- state
        d:Wvi32(self.state)
        -- description
        d:Wstr(self.description)
        -- create_time
        d:Wvi64(self.create_time)
        -- updated_time
        d:Wvi64(self.updated_time)
        -- pay_channel_id
        d:Wvi32(self.pay_channel_id)
        -- before_money
        d:Wd(self.before_money)
        -- before_money_safe
        d:Wd(self.before_money_safe)
        -- after_money
        d:Wd(self.after_money)
        -- after_money_safe
        d:Wd(self.after_money_safe)
        -- is_execption
        d:Wvi32(self.is_execption)
        -- ip
        d:Wstr(self.ip)
        -- ip_area
        d:Wstr(self.ip_area)
    end
}
PKG_Lobby_Client_RefundInfo.__index = PKG_Lobby_Client_RefundInfo

--[[
获取跑马灯信息(系统跑马灯信息)
]]
PKG_Lobby_Client_Marquee_Marquee = {
    typeName = "PKG_Lobby_Client_Marquee_Marquee",
    typeId = 1280,
    Create = function(o)
        if o == nil then
            o = {}
            setmetatable(o, PKG_Lobby_Client_Marquee_Marquee)
        end
        --[[
        内容
        ]]
        o.content = "" -- String
        --[[
        喊话频率(多长时间循环执行一次，单位 秒)
        ]]
        o.frequency = 0 -- Int32
        return o
    end,
    Read = function(self, om)
        local d = om.d
        local r, n
        -- content
        r, self.content = d:Rstr()
        if r ~= 0 then return r end
        -- frequency
        r, self.frequency = d:Rvi32()
        if r ~= 0 then return r end
        return 0
    end,
    Write = function(self, om)
        local d = om.d
        -- content
        d:Wstr(self.content)
        -- frequency
        d:Wvi32(self.frequency)
    end
}
PKG_Lobby_Client_Marquee_Marquee.__index = PKG_Lobby_Client_Marquee_Marquee

--[[
房间玩家信息
]]
PKG_Lobby_Client_GameCatchFish_RoomInfo = {
    typeName = "PKG_Lobby_Client_GameCatchFish_RoomInfo", -- : PKG_Lobby_Client_Move_Result
    typeId = 1211,
    Create = function(o)
        if o == nil then
            o = {}
            setmetatable(o, PKG_Lobby_Client_GameCatchFish_RoomInfo)
        end
        PKG_Lobby_Client_Move_Result.Create(o)
        --[[
        房间id
        ]]
        o.roomId = 0 -- Int32
        --[[
        所有座位玩家列表(定长数组)
        ]]
        o.players = {} -- List<Shared<PKG.Lobby_Client.RoomPlayers>>
        return o
    end,
    Read = function(self, om)
        local d = om.d
        local r, n, o
        -- base read
        r = PKG_Lobby_Client_Move_Result.Read(self, om)
        if r ~= 0 then return r end
        -- roomId
        r, self.roomId = d:Rvi32()
        if r ~= 0 then return r end
        -- players
        r, len = d:Rvu32()
        if len > d:GetLeft() then return -1 end
        o = {}
        self.players = o
        for i = 1, len do
            r, o[i] = om:Read()
            if r ~= 0 then return r end
        end
        if r ~= 0 then return r end
        return 0
    end,
    Write = function(self, om)
        local d = om.d
        local o, len
        -- base read
        PKG_Lobby_Client_Move_Result.Write(self, om)
        -- roomId
        d:Wvi32(self.roomId)
        -- players
        o = self.players
        len = #o
        d:Wvu32(len)
        for i = 1, len do
            om:Write(o[i])
        end
    end
}
PKG_Lobby_Client_GameCatchFish_RoomInfo.__index = PKG_Lobby_Client_GameCatchFish_RoomInfo

--[[
捕鱼游戏级别明细
]]
PKG_Lobby_Client_GameCatchFish_LevelInfo = {
    typeName = "PKG_Lobby_Client_GameCatchFish_LevelInfo", -- : PKG_Lobby_Client_Move_Result
    typeId = 1207,
    Create = function(o)
        if o == nil then
            o = {}
            setmetatable(o, PKG_Lobby_Client_GameCatchFish_LevelInfo)
        end
        PKG_Lobby_Client_Move_Result.Create(o)
        o.levelId = 0 -- Int32
        --[[
        炮值(从)(游戏内金币)
        ]]
        o.minBet = 0 -- Int64
        --[[
        炮值(到)(游戏内金币)
        ]]
        o.maxBet = 0 -- Int64
        --[[
        最低准入金额
        ]]
        o.minMoney = 0 -- Double
        --[[
        money 自动退款成 coin 要 乘除 的系数
        ]]
        o.exchangeCoinRatio = 0 -- Int32
        return o
    end,
    Read = function(self, om)
        local d = om.d
        local r, n
        -- base read
        r = PKG_Lobby_Client_Move_Result.Read(self, om)
        if r ~= 0 then return r end
        -- levelId
        r, self.levelId = d:Rvi32()
        if r ~= 0 then return r end
        -- minBet
        r, self.minBet = d:Rvi64()
        if r ~= 0 then return r end
        -- maxBet
        r, self.maxBet = d:Rvi64()
        if r ~= 0 then return r end
        -- minMoney
        r, self.minMoney = d:Rd()
        if r ~= 0 then return r end
        -- exchangeCoinRatio
        r, self.exchangeCoinRatio = d:Rvi32()
        if r ~= 0 then return r end
        return 0
    end,
    Write = function(self, om)
        local d = om.d
        -- base read
        PKG_Lobby_Client_Move_Result.Write(self, om)
        -- levelId
        d:Wvi32(self.levelId)
        -- minBet
        d:Wvi64(self.minBet)
        -- maxBet
        d:Wvi64(self.maxBet)
        -- minMoney
        d:Wd(self.minMoney)
        -- exchangeCoinRatio
        d:Wvi32(self.exchangeCoinRatio)
    end
}
PKG_Lobby_Client_GameCatchFish_LevelInfo.__index = PKG_Lobby_Client_GameCatchFish_LevelInfo

--[[
VIP方式
]]
PKG_Lobby_Client_vip_channel = {
    typeName = "PKG_Lobby_Client_vip_channel",
    typeId = 1231,
    Create = function(o)
        if o == nil then
            o = {}
            setmetatable(o, PKG_Lobby_Client_vip_channel)
        end
        o.id = 0 -- Int32
        --[[
        代理昵称
        ]]
        o.nickname = "" -- String
        --[[
        银行名称
        ]]
        o.bank_name = "" -- String
        --[[
        卡号
        ]]
        o.account = "" -- String
        --[[
        聊天方式 1：line2：Messenger3：twitter4：viber5：WhatsApp6：zalo
        ]]
        o.type = 0 -- Int32
        --[[
        是否显示中(1显示中)
        ]]
        o.enabled = 0 -- Int32
        --[[
        描述
        ]]
        o.description = "" -- String
        --[[
        上线时间
        ]]
        o.create_time = 0 -- Int64
        --[[
        支付渠道Id
        ]]
        o.pay_channel_id = 0 -- Int32
        --[[
        根据金额选择银行卡用
        ]]
        o.money_level = 0 -- Int64
        --[[
        @VIP等级筛选
        ]]
        o.vip_level = 0 -- Int32
        return o
    end,
    Read = function(self, om)
        local d = om.d
        local r, n
        -- id
        r, self.id = d:Rvi32()
        if r ~= 0 then return r end
        -- nickname
        r, self.nickname = d:Rstr()
        if r ~= 0 then return r end
        -- bank_name
        r, self.bank_name = d:Rstr()
        if r ~= 0 then return r end
        -- account
        r, self.account = d:Rstr()
        if r ~= 0 then return r end
        -- type
        r, self.type = d:Rvi32()
        if r ~= 0 then return r end
        -- enabled
        r, self.enabled = d:Rvi32()
        if r ~= 0 then return r end
        -- description
        r, self.description = d:Rstr()
        if r ~= 0 then return r end
        -- create_time
        r, self.create_time = d:Rvi64()
        if r ~= 0 then return r end
        -- pay_channel_id
        r, self.pay_channel_id = d:Rvi32()
        if r ~= 0 then return r end
        -- money_level
        r, self.money_level = d:Rvi64()
        if r ~= 0 then return r end
        -- vip_level
        r, self.vip_level = d:Rvi32()
        if r ~= 0 then return r end
        return 0
    end,
    Write = function(self, om)
        local d = om.d
        -- id
        d:Wvi32(self.id)
        -- nickname
        d:Wstr(self.nickname)
        -- bank_name
        d:Wstr(self.bank_name)
        -- account
        d:Wstr(self.account)
        -- type
        d:Wvi32(self.type)
        -- enabled
        d:Wvi32(self.enabled)
        -- description
        d:Wstr(self.description)
        -- create_time
        d:Wvi64(self.create_time)
        -- pay_channel_id
        d:Wvi32(self.pay_channel_id)
        -- money_level
        d:Wvi64(self.money_level)
        -- vip_level
        d:Wvi32(self.vip_level)
    end
}
PKG_Lobby_Client_vip_channel.__index = PKG_Lobby_Client_vip_channel

--[[
工会信息
]]
PKG_Lobby_Client_PromotionInfo = {
    typeName = "PKG_Lobby_Client_PromotionInfo",
    typeId = 1251,
    Create = function(o)
        if o == nil then
            o = {}
            setmetatable(o, PKG_Lobby_Client_PromotionInfo)
        end
        --[[
        头像id
        ]]
        o.portrait_id = 0 -- Int32
        --[[
        工会名称
        ]]
        o.promotion_name = "" -- String
        --[[
        简介
        ]]
        o.description = "" -- String
        --[[
        成员增加捕鱼洗码率
        ]]
        o.add_fish_rate = 0 -- Double
        --[[
        成员增加老虎机洗码率
        ]]
        o.add_slots_rate = 0 -- Double
        --[[
        捕鱼的返利率
        ]]
        o.settlement_fish_rate = 0 -- Double
        --[[
        老虎机的返利率
        ]]
        o.settlement_slots_rate = 0 -- Double
        return o
    end,
    Read = function(self, om)
        local d = om.d
        local r, n
        -- portrait_id
        r, self.portrait_id = d:Rvi32()
        if r ~= 0 then return r end
        -- promotion_name
        r, self.promotion_name = d:Rstr()
        if r ~= 0 then return r end
        -- description
        r, self.description = d:Rstr()
        if r ~= 0 then return r end
        -- add_fish_rate
        r, self.add_fish_rate = d:Rd()
        if r ~= 0 then return r end
        -- add_slots_rate
        r, self.add_slots_rate = d:Rd()
        if r ~= 0 then return r end
        -- settlement_fish_rate
        r, self.settlement_fish_rate = d:Rd()
        if r ~= 0 then return r end
        -- settlement_slots_rate
        r, self.settlement_slots_rate = d:Rd()
        if r ~= 0 then return r end
        return 0
    end,
    Write = function(self, om)
        local d = om.d
        -- portrait_id
        d:Wvi32(self.portrait_id)
        -- promotion_name
        d:Wstr(self.promotion_name)
        -- description
        d:Wstr(self.description)
        -- add_fish_rate
        d:Wd(self.add_fish_rate)
        -- add_slots_rate
        d:Wd(self.add_slots_rate)
        -- settlement_fish_rate
        d:Wd(self.settlement_fish_rate)
        -- settlement_slots_rate
        d:Wd(self.settlement_slots_rate)
    end
}
PKG_Lobby_Client_PromotionInfo.__index = PKG_Lobby_Client_PromotionInfo

--[[
玩家赠送金币记录表
]]
PKG_Lobby_Client_log_gift_money_to_account = {
    typeName = "PKG_Lobby_Client_log_gift_money_to_account",
    typeId = 1258,
    Create = function(o)
        if o == nil then
            o = {}
            setmetatable(o, PKG_Lobby_Client_log_gift_money_to_account)
        end
        o.id = 0 -- Int32
        --[[
        赠送金币玩家
        ]]
        o.give_account_id = 0 -- Int32
        --[[
        获赠金币玩家
        ]]
        o.received_account_id = 0 -- Int32
        --[[
        赠送金额
        ]]
        o.money = 0 -- Double
        --[[
        赠送时间
        ]]
        o.create_time = 0 -- Int64
        return o
    end,
    Read = function(self, om)
        local d = om.d
        local r, n
        -- id
        r, self.id = d:Rvi32()
        if r ~= 0 then return r end
        -- give_account_id
        r, self.give_account_id = d:Rvi32()
        if r ~= 0 then return r end
        -- received_account_id
        r, self.received_account_id = d:Rvi32()
        if r ~= 0 then return r end
        -- money
        r, self.money = d:Rd()
        if r ~= 0 then return r end
        -- create_time
        r, self.create_time = d:Rvi64()
        if r ~= 0 then return r end
        return 0
    end,
    Write = function(self, om)
        local d = om.d
        -- id
        d:Wvi32(self.id)
        -- give_account_id
        d:Wvi32(self.give_account_id)
        -- received_account_id
        d:Wvi32(self.received_account_id)
        -- money
        d:Wd(self.money)
        -- create_time
        d:Wvi64(self.create_time)
    end
}
PKG_Lobby_Client_log_gift_money_to_account.__index = PKG_Lobby_Client_log_gift_money_to_account

--[[
公共频道聊天记录
]]
PKG_Lobby_Client_PublicMessage = {
    typeName = "PKG_Lobby_Client_PublicMessage",
    typeId = 1330,
    Create = function(o)
        if o == nil then
            o = {}
            setmetatable(o, PKG_Lobby_Client_PublicMessage)
        end
        --[[
        时间戳
        ]]
        o.time = 0 -- Int64
        --[[
        发件人
        ]]
        o.source_id = 0 -- Int32
        --[[
        头像id
        ]]
        o.source_avatar_id = 0 -- Int32
        --[[
        昵称
        ]]
        o.source_nickname = "" -- String
        --[[
        是否是商人 1=商人 0不是
        ]]
        o.source_is_businessman = 0 -- Int32
        --[[
        内容
        ]]
        o.content = "" -- String
        --[[
        金币
        ]]
        o.money = 0 -- Double
        --[[
        VIP等级
        ]]
        o.vip_level = 0 -- Int32
        return o
    end,
    Read = function(self, om)
        local d = om.d
        local r, n
        -- time
        r, self.time = d:Rvi64()
        if r ~= 0 then return r end
        -- source_id
        r, self.source_id = d:Rvi32()
        if r ~= 0 then return r end
        -- source_avatar_id
        r, self.source_avatar_id = d:Rvi32()
        if r ~= 0 then return r end
        -- source_nickname
        r, self.source_nickname = d:Rstr()
        if r ~= 0 then return r end
        -- source_is_businessman
        r, self.source_is_businessman = d:Rvi32()
        if r ~= 0 then return r end
        -- content
        r, self.content = d:Rstr()
        if r ~= 0 then return r end
        -- money
        r, self.money = d:Rd()
        if r ~= 0 then return r end
        -- vip_level
        r, self.vip_level = d:Rvi32()
        if r ~= 0 then return r end
        return 0
    end,
    Write = function(self, om)
        local d = om.d
        -- time
        d:Wvi64(self.time)
        -- source_id
        d:Wvi32(self.source_id)
        -- source_avatar_id
        d:Wvi32(self.source_avatar_id)
        -- source_nickname
        d:Wstr(self.source_nickname)
        -- source_is_businessman
        d:Wvi32(self.source_is_businessman)
        -- content
        d:Wstr(self.content)
        -- money
        d:Wd(self.money)
        -- vip_level
        d:Wvi32(self.vip_level)
    end
}
PKG_Lobby_Client_PublicMessage.__index = PKG_Lobby_Client_PublicMessage

--[[
服务器发送给客户端的Message
]]
PKG_Lobby_Client_ChatMessage = {
    typeName = "PKG_Lobby_Client_ChatMessage",
    typeId = 1306,
    Create = function(o)
        if o == nil then
            o = {}
            setmetatable(o, PKG_Lobby_Client_ChatMessage)
        end
        --[[
        时间戳
        ]]
        o.time = 0 -- Int64
        --[[
        发件人
        ]]
        o.source_id = 0 -- Int32
        --[[
        头像id
        ]]
        o.source_avatar_id = 0 -- Int32
        --[[
        昵称
        ]]
        o.source_nickname = "" -- String
        --[[
        是否是商人 1=商人 0不是
        ]]
        o.source_is_businessman = 0 -- Int32
        --[[
        类型-1=公频 -2=工会 0=私聊
        ]]
        o.message_type = 0 -- Int32
        --[[
        内容
        ]]
        o.content = "" -- String
        --[[
        金币
        ]]
        o.money = 0 -- Double
        --[[
        VIP等级
        ]]
        o.vip_level = 0 -- Int32
        return o
    end,
    Read = function(self, om)
        local d = om.d
        local r, n
        -- time
        r, self.time = d:Rvi64()
        if r ~= 0 then return r end
        -- source_id
        r, self.source_id = d:Rvi32()
        if r ~= 0 then return r end
        -- source_avatar_id
        r, self.source_avatar_id = d:Rvi32()
        if r ~= 0 then return r end
        -- source_nickname
        r, self.source_nickname = d:Rstr()
        if r ~= 0 then return r end
        -- source_is_businessman
        r, self.source_is_businessman = d:Rvi32()
        if r ~= 0 then return r end
        -- message_type
        r, self.message_type = d:Rvi32()
        if r ~= 0 then return r end
        -- content
        r, self.content = d:Rstr()
        if r ~= 0 then return r end
        -- money
        r, self.money = d:Rd()
        if r ~= 0 then return r end
        -- vip_level
        r, self.vip_level = d:Rvi32()
        if r ~= 0 then return r end
        return 0
    end,
    Write = function(self, om)
        local d = om.d
        -- time
        d:Wvi64(self.time)
        -- source_id
        d:Wvi32(self.source_id)
        -- source_avatar_id
        d:Wvi32(self.source_avatar_id)
        -- source_nickname
        d:Wstr(self.source_nickname)
        -- source_is_businessman
        d:Wvi32(self.source_is_businessman)
        -- message_type
        d:Wvi32(self.message_type)
        -- content
        d:Wstr(self.content)
        -- money
        d:Wd(self.money)
        -- vip_level
        d:Wvi32(self.vip_level)
    end
}
PKG_Lobby_Client_ChatMessage.__index = PKG_Lobby_Client_ChatMessage

--[[
apple充值配置
]]
PKG_Lobby_Client_apple_money = {
    typeName = "PKG_Lobby_Client_apple_money",
    typeId = 1305,
    Create = function(o)
        if o == nil then
            o = {}
            setmetatable(o, PKG_Lobby_Client_apple_money)
        end
        --[[
        产品Id
        ]]
        o.product_id = "" -- String
        --[[
        所得金币
        ]]
        o.money = 0 -- Double
        --[[
        美元
        ]]
        o.dollar = 0 -- Double
        --[[
        配置
        ]]
        o.config = "" -- String
        return o
    end,
    Read = function(self, om)
        local d = om.d
        local r, n
        -- product_id
        r, self.product_id = d:Rstr()
        if r ~= 0 then return r end
        -- money
        r, self.money = d:Rd()
        if r ~= 0 then return r end
        -- dollar
        r, self.dollar = d:Rd()
        if r ~= 0 then return r end
        -- config
        r, self.config = d:Rstr()
        if r ~= 0 then return r end
        return 0
    end,
    Write = function(self, om)
        local d = om.d
        -- product_id
        d:Wstr(self.product_id)
        -- money
        d:Wd(self.money)
        -- dollar
        d:Wd(self.dollar)
        -- config
        d:Wstr(self.config)
    end
}
PKG_Lobby_Client_apple_money.__index = PKG_Lobby_Client_apple_money

--[[
每日签到定义
]]
PKG_Lobby_Client_everyday_signin_monery_config = {
    typeName = "PKG_Lobby_Client_everyday_signin_monery_config",
    typeId = 1255,
    Create = function(o)
        if o == nil then
            o = {}
            setmetatable(o, PKG_Lobby_Client_everyday_signin_monery_config)
        end
        --[[
        天
        ]]
        o.day = 0 -- Int32
        --[[
        送的金币
        ]]
        o.money = 0 -- Double
        return o
    end,
    Read = function(self, om)
        local d = om.d
        local r, n
        -- day
        r, self.day = d:Rvi32()
        if r ~= 0 then return r end
        -- money
        r, self.money = d:Rd()
        if r ~= 0 then return r end
        return 0
    end,
    Write = function(self, om)
        local d = om.d
        -- day
        d:Wvi32(self.day)
        -- money
        d:Wd(self.money)
    end
}
PKG_Lobby_Client_everyday_signin_monery_config.__index = PKG_Lobby_Client_everyday_signin_monery_config

--[[
返利日记
]]
PKG_Lobby_Client_ReceviceSettlementLog = {
    typeName = "PKG_Lobby_Client_ReceviceSettlementLog",
    typeId = 1303,
    Create = function(o)
        if o == nil then
            o = {}
            setmetatable(o, PKG_Lobby_Client_ReceviceSettlementLog)
        end
        o.time = 0 -- Int64
        o.give_washcode = 0 -- Double
        return o
    end,
    Read = function(self, om)
        local d = om.d
        local r, n
        -- time
        r, self.time = d:Rvi64()
        if r ~= 0 then return r end
        -- give_washcode
        r, self.give_washcode = d:Rd()
        if r ~= 0 then return r end
        return 0
    end,
    Write = function(self, om)
        local d = om.d
        -- time
        d:Wvi64(self.time)
        -- give_washcode
        d:Wd(self.give_washcode)
    end
}
PKG_Lobby_Client_ReceviceSettlementLog.__index = PKG_Lobby_Client_ReceviceSettlementLog

--[[
玩家的游戏任务信息
]]
PKG_Lobby_Client_AccountActivityStatus = {
    typeName = "PKG_Lobby_Client_AccountActivityStatus",
    typeId = 1296,
    Create = function(o)
        if o == nil then
            o = {}
            setmetatable(o, PKG_Lobby_Client_AccountActivityStatus)
        end
        --[[
        活动id
        ]]
        o.activity_id = 0 -- Int32
        --[[
        上个任务id
        ]]
        o.prev = 0 -- Int32
        --[[
        游戏等级,为0表示所有等级
        ]]
        o.game_id = 0 -- Int32
        --[[
        位置号,位0表示所有位置
        ]]
        o.table_id = 0 -- Int32
        --[[
        vip 等级,为0表示所有等级,否则>=此等级才能参与
        ]]
        o.vip_level = 0 -- Int32
        --[[
        鱼类型 2选1
        ]]
        o.fish_type = 0 -- Int32
        --[[
        鱼类型 2选1
        ]]
        o.fish_bet = 0 -- Int64
        --[[
        炮值,为0表示所有炮值
        ]]
        o.cannon_bet = 0 -- Int64
        --[[
        需要打死多少条 不可填0 填0此条无效
        ]]
        o.need_count = 0 -- Int32
        --[[
        送多少奖励
        ]]
        o.give_washcode = 0 -- Double
        --[[
        是否开启此规则0=不开 1=开
        ]]
        o.is_open = 0 -- Int32
        --[[
        给客户端文字配置
        ]]
        o.config = "" -- String
        --[[
        当前数量
        ]]
        o.current_count = 0 -- Int32
        --[[
        是否已领取 0=未领取 1=已领取
        ]]
        o.is_receive = 0 -- Int32
        --[[
        游戏类型 1=捕鱼 2=老虎机
        ]]
        o.game_type = 0 -- Int32
        --[[
        老虎机倍率 0表示所有
        ]]
        o.slots_bet_money = 0 -- Int64
        --[[
        老虎机此次赢了满足多少 0表示所有
        ]]
        o.slots_win_money = 0 -- Int64
        --[[
        老虎机 彩金类型 0表示所有
        ]]
        o.slots_lottery_type = 0 -- Int32
        --[[
        老虎机 彩金id 0表示所有
        ]]
        o.slots_lottery_id = 0 -- Int32
        --[[
        旋转类型 (自己配) 0表示所有
        ]]
        o.slots_spin_type = 0 -- Int32
        return o
    end,
    Read = function(self, om)
        local d = om.d
        local r, n
        -- activity_id
        r, self.activity_id = d:Rvi32()
        if r ~= 0 then return r end
        -- prev
        r, self.prev = d:Rvi32()
        if r ~= 0 then return r end
        -- game_id
        r, self.game_id = d:Rvi32()
        if r ~= 0 then return r end
        -- table_id
        r, self.table_id = d:Rvi32()
        if r ~= 0 then return r end
        -- vip_level
        r, self.vip_level = d:Rvi32()
        if r ~= 0 then return r end
        -- fish_type
        r, self.fish_type = d:Rvi32()
        if r ~= 0 then return r end
        -- fish_bet
        r, self.fish_bet = d:Rvi64()
        if r ~= 0 then return r end
        -- cannon_bet
        r, self.cannon_bet = d:Rvi64()
        if r ~= 0 then return r end
        -- need_count
        r, self.need_count = d:Rvi32()
        if r ~= 0 then return r end
        -- give_washcode
        r, self.give_washcode = d:Rd()
        if r ~= 0 then return r end
        -- is_open
        r, self.is_open = d:Rvi32()
        if r ~= 0 then return r end
        -- config
        r, self.config = d:Rstr()
        if r ~= 0 then return r end
        -- current_count
        r, self.current_count = d:Rvi32()
        if r ~= 0 then return r end
        -- is_receive
        r, self.is_receive = d:Rvi32()
        if r ~= 0 then return r end
        -- game_type
        r, self.game_type = d:Rvi32()
        if r ~= 0 then return r end
        -- slots_bet_money
        r, self.slots_bet_money = d:Rvi64()
        if r ~= 0 then return r end
        -- slots_win_money
        r, self.slots_win_money = d:Rvi64()
        if r ~= 0 then return r end
        -- slots_lottery_type
        r, self.slots_lottery_type = d:Rvi32()
        if r ~= 0 then return r end
        -- slots_lottery_id
        r, self.slots_lottery_id = d:Rvi32()
        if r ~= 0 then return r end
        -- slots_spin_type
        r, self.slots_spin_type = d:Rvi32()
        if r ~= 0 then return r end
        return 0
    end,
    Write = function(self, om)
        local d = om.d
        -- activity_id
        d:Wvi32(self.activity_id)
        -- prev
        d:Wvi32(self.prev)
        -- game_id
        d:Wvi32(self.game_id)
        -- table_id
        d:Wvi32(self.table_id)
        -- vip_level
        d:Wvi32(self.vip_level)
        -- fish_type
        d:Wvi32(self.fish_type)
        -- fish_bet
        d:Wvi64(self.fish_bet)
        -- cannon_bet
        d:Wvi64(self.cannon_bet)
        -- need_count
        d:Wvi32(self.need_count)
        -- give_washcode
        d:Wd(self.give_washcode)
        -- is_open
        d:Wvi32(self.is_open)
        -- config
        d:Wstr(self.config)
        -- current_count
        d:Wvi32(self.current_count)
        -- is_receive
        d:Wvi32(self.is_receive)
        -- game_type
        d:Wvi32(self.game_type)
        -- slots_bet_money
        d:Wvi64(self.slots_bet_money)
        -- slots_win_money
        d:Wvi64(self.slots_win_money)
        -- slots_lottery_type
        d:Wvi32(self.slots_lottery_type)
        -- slots_lottery_id
        d:Wvi32(self.slots_lottery_id)
        -- slots_spin_type
        d:Wvi32(self.slots_spin_type)
    end
}
PKG_Lobby_Client_AccountActivityStatus.__index = PKG_Lobby_Client_AccountActivityStatus

--[[
洗码赠送绑定金币等级信息
]]
PKG_Lobby_Client_DailyWashcodeActivityLevel = {
    typeName = "PKG_Lobby_Client_DailyWashcodeActivityLevel",
    typeId = 1292,
    Create = function(o)
        if o == nil then
            o = {}
            setmetatable(o, PKG_Lobby_Client_DailyWashcodeActivityLevel)
        end
        --[[
        洗码量
        ]]
        o.washcode_level = 0 -- Double
        --[[
        赠送量
        ]]
        o.give_washcode = 0 -- Double
        return o
    end,
    Read = function(self, om)
        local d = om.d
        local r, n
        -- washcode_level
        r, self.washcode_level = d:Rd()
        if r ~= 0 then return r end
        -- give_washcode
        r, self.give_washcode = d:Rd()
        if r ~= 0 then return r end
        return 0
    end,
    Write = function(self, om)
        local d = om.d
        -- washcode_level
        d:Wd(self.washcode_level)
        -- give_washcode
        d:Wd(self.give_washcode)
    end
}
PKG_Lobby_Client_DailyWashcodeActivityLevel.__index = PKG_Lobby_Client_DailyWashcodeActivityLevel

--[[
常见问题
]]
PKG_Lobby_Client_FAQItem = {
    typeName = "PKG_Lobby_Client_FAQItem",
    typeId = 1275,
    Create = function(o)
        if o == nil then
            o = {}
            setmetatable(o, PKG_Lobby_Client_FAQItem)
        end
        --[[
        Id
        ]]
        o.Id = 0 -- Int32
        --[[
        问题
        ]]
        o.question = "" -- String
        --[[
        回答
        ]]
        o.answer = "" -- String
        --[[
        图片列表
        ]]
        o.images = "" -- String
        return o
    end,
    Read = function(self, om)
        local d = om.d
        local r, n
        -- Id
        r, self.Id = d:Rvi32()
        if r ~= 0 then return r end
        -- question
        r, self.question = d:Rstr()
        if r ~= 0 then return r end
        -- answer
        r, self.answer = d:Rstr()
        if r ~= 0 then return r end
        -- images
        r, self.images = d:Rstr()
        if r ~= 0 then return r end
        return 0
    end,
    Write = function(self, om)
        local d = om.d
        -- Id
        d:Wvi32(self.Id)
        -- question
        d:Wstr(self.question)
        -- answer
        d:Wstr(self.answer)
        -- images
        d:Wstr(self.images)
    end
}
PKG_Lobby_Client_FAQItem.__index = PKG_Lobby_Client_FAQItem

--[[
充值记录
]]
PKG_Lobby_Client_RechargeInfo = {
    typeName = "PKG_Lobby_Client_RechargeInfo",
    typeId = 1271,
    Create = function(o)
        if o == nil then
            o = {}
            setmetatable(o, PKG_Lobby_Client_RechargeInfo)
        end
        --[[
        订单号
        ]]
        o.order_num = "" -- String
        --[[
        金币
        ]]
        o.money = 0 -- Double
        --[[
        时间
        ]]
        o.time = 0 -- Int64
        --[[
        状态 0=审核中 1=成功 2=失败
        ]]
        o.status = 0 -- Int32
        --[[
        备注
        ]]
        o.remarks = "" -- String
        return o
    end,
    Read = function(self, om)
        local d = om.d
        local r, n
        -- order_num
        r, self.order_num = d:Rstr()
        if r ~= 0 then return r end
        -- money
        r, self.money = d:Rd()
        if r ~= 0 then return r end
        -- time
        r, self.time = d:Rvi64()
        if r ~= 0 then return r end
        -- status
        r, self.status = d:Rvi32()
        if r ~= 0 then return r end
        -- remarks
        r, self.remarks = d:Rstr()
        if r ~= 0 then return r end
        return 0
    end,
    Write = function(self, om)
        local d = om.d
        -- order_num
        d:Wstr(self.order_num)
        -- money
        d:Wd(self.money)
        -- time
        d:Wvi64(self.time)
        -- status
        d:Wvi32(self.status)
        -- remarks
        d:Wstr(self.remarks)
    end
}
PKG_Lobby_Client_RechargeInfo.__index = PKG_Lobby_Client_RechargeInfo

--[[
按钮开关
]]
PKG_Lobby_Client_button_settings = {
    typeName = "PKG_Lobby_Client_button_settings",
    typeId = 1203,
    Create = function(o)
        if o == nil then
            o = {}
            setmetatable(o, PKG_Lobby_Client_button_settings)
        end
        --[[
        按钮id
        ]]
        o.key = 0 -- Int32
        --[[
        是否开启 1=开启 0=关闭
        ]]
        o.is_open = 0 -- Int32
        return o
    end,
    Read = function(self, om)
        local d = om.d
        local r, n
        -- key
        r, self.key = d:Rvi32()
        if r ~= 0 then return r end
        -- is_open
        r, self.is_open = d:Rvi32()
        if r ~= 0 then return r end
        return 0
    end,
    Write = function(self, om)
        local d = om.d
        -- key
        d:Wvi32(self.key)
        -- is_open
        d:Wvi32(self.is_open)
    end
}
PKG_Lobby_Client_button_settings.__index = PKG_Lobby_Client_button_settings

--[[
老虎机游戏的Level配置
]]
PKG_Lobby_Client_GameEntryConditions = {
    typeName = "PKG_Lobby_Client_GameEntryConditions",
    typeId = 1262,
    Create = function(o)
        if o == nil then
            o = {}
            setmetatable(o, PKG_Lobby_Client_GameEntryConditions)
        end
        --[[
        游戏Id
        ]]
        o.gameid = 0 -- Int32
        --[[
        当前老虎机游戏的level
        ]]
        o.Entrys = {} -- List<Shared<PKG.Lobby_Client.EntryConditions>>
        return o
    end,
    Read = function(self, om)
        local d = om.d
        local r, n, o
        -- gameid
        r, self.gameid = d:Rvi32()
        if r ~= 0 then return r end
        -- Entrys
        r, len = d:Rvu32()
        if len > d:GetLeft() then return -1 end
        o = {}
        self.Entrys = o
        for i = 1, len do
            r, o[i] = om:Read()
            if r ~= 0 then return r end
        end
        if r ~= 0 then return r end
        return 0
    end,
    Write = function(self, om)
        local d = om.d
        local o, len
        -- gameid
        d:Wvi32(self.gameid)
        -- Entrys
        o = self.Entrys
        len = #o
        d:Wvu32(len)
        for i = 1, len do
            om:Write(o[i])
        end
    end
}
PKG_Lobby_Client_GameEntryConditions.__index = PKG_Lobby_Client_GameEntryConditions

--[[
玩家的返利信息
]]
PKG_Lobby_Client_SettlementMember = {
    typeName = "PKG_Lobby_Client_SettlementMember",
    typeId = 1300,
    Create = function(o)
        if o == nil then
            o = {}
            setmetatable(o, PKG_Lobby_Client_SettlementMember)
        end
        --[[
        id
        ]]
        o.account_id = 0 -- Int32
        --[[
        玩家昵称
        ]]
        o.name = "" -- String
        --[[
        总共老虎机洗码量
        ]]
        o.slots_washcode = 0 -- Double
        --[[
        总共捕鱼洗码量
        ]]
        o.catchfish_washcode = 0 -- Double
        --[[
        总共返利量
        ]]
        o.settlement_value = 0 -- Double
        --[[
        昨日老虎机洗码量
        ]]
        o.yesterday_slots_washcode = 0 -- Double
        --[[
        昨日捕鱼洗码量
        ]]
        o.yesterday_catchfish_washcode = 0 -- Double
        --[[
        昨日返利量
        ]]
        o.yesterday_settlement_value = 0 -- Double
        return o
    end,
    Read = function(self, om)
        local d = om.d
        local r, n
        -- account_id
        r, self.account_id = d:Rvi32()
        if r ~= 0 then return r end
        -- name
        r, self.name = d:Rstr()
        if r ~= 0 then return r end
        -- slots_washcode
        r, self.slots_washcode = d:Rd()
        if r ~= 0 then return r end
        -- catchfish_washcode
        r, self.catchfish_washcode = d:Rd()
        if r ~= 0 then return r end
        -- settlement_value
        r, self.settlement_value = d:Rd()
        if r ~= 0 then return r end
        -- yesterday_slots_washcode
        r, self.yesterday_slots_washcode = d:Rd()
        if r ~= 0 then return r end
        -- yesterday_catchfish_washcode
        r, self.yesterday_catchfish_washcode = d:Rd()
        if r ~= 0 then return r end
        -- yesterday_settlement_value
        r, self.yesterday_settlement_value = d:Rd()
        if r ~= 0 then return r end
        return 0
    end,
    Write = function(self, om)
        local d = om.d
        -- account_id
        d:Wvi32(self.account_id)
        -- name
        d:Wstr(self.name)
        -- slots_washcode
        d:Wd(self.slots_washcode)
        -- catchfish_washcode
        d:Wd(self.catchfish_washcode)
        -- settlement_value
        d:Wd(self.settlement_value)
        -- yesterday_slots_washcode
        d:Wd(self.yesterday_slots_washcode)
        -- yesterday_catchfish_washcode
        d:Wd(self.yesterday_catchfish_washcode)
        -- yesterday_settlement_value
        d:Wd(self.yesterday_settlement_value)
    end
}
PKG_Lobby_Client_SettlementMember.__index = PKG_Lobby_Client_SettlementMember

--[[
消息包
]]
PKG_Lobby_Client_Message = {
    typeName = "PKG_Lobby_Client_Message",
    typeId = 1267,
    Create = function(o)
        if o == nil then
            o = {}
            setmetatable(o, PKG_Lobby_Client_Message)
        end
        --[[
        此消息唯一标识
        ]]
        o.Id = 0 -- Double
        --[[
        时间
        ]]
        o.createtime = 0 -- Int64
        --[[
        内容
        ]]
        o.content = "" -- String
        --[[
        图片URL
        ]]
        o.image_url = "" -- String
        --[[
        客服
        ]]
        o.auditor = "" -- String
        --[[
        是否已读 0=未读 1=已读
        ]]
        o.status = 0 -- Int32
        --[[
        类型 0=玩家到客服 1=客服到玩家
        ]]
        o.type = 0 -- Int32
        return o
    end,
    Read = function(self, om)
        local d = om.d
        local r, n
        -- Id
        r, self.Id = d:Rd()
        if r ~= 0 then return r end
        -- createtime
        r, self.createtime = d:Rvi64()
        if r ~= 0 then return r end
        -- content
        r, self.content = d:Rstr()
        if r ~= 0 then return r end
        -- image_url
        r, self.image_url = d:Rstr()
        if r ~= 0 then return r end
        -- auditor
        r, self.auditor = d:Rstr()
        if r ~= 0 then return r end
        -- status
        r, self.status = d:Rvi32()
        if r ~= 0 then return r end
        -- type
        r, self.type = d:Rvi32()
        if r ~= 0 then return r end
        return 0
    end,
    Write = function(self, om)
        local d = om.d
        -- Id
        d:Wd(self.Id)
        -- createtime
        d:Wvi64(self.createtime)
        -- content
        d:Wstr(self.content)
        -- image_url
        d:Wstr(self.image_url)
        -- auditor
        d:Wstr(self.auditor)
        -- status
        d:Wvi32(self.status)
        -- type
        d:Wvi32(self.type)
    end
}
PKG_Lobby_Client_Message.__index = PKG_Lobby_Client_Message

--[[
Huca游戏级别明细
]]
PKG_Lobby_Client_GameHuca_LevelInfo = {
    typeName = "PKG_Lobby_Client_GameHuca_LevelInfo", -- : PKG_Lobby_Client_Move_Result
    typeId = 1209,
    Create = function(o)
        if o == nil then
            o = {}
            setmetatable(o, PKG_Lobby_Client_GameHuca_LevelInfo)
        end
        PKG_Lobby_Client_Move_Result.Create(o)
        o.levelId = 0 -- Int32
        --[[
        押注(从)(金额)
        ]]
        o.minBet = 0 -- Double
        --[[
        押注(到)(金额)
        ]]
        o.maxBet = 0 -- Double
        --[[
        最低准入金额
        ]]
        o.minMoney = 0 -- Double
        --[[
        money 自动退款成 coin 要 乘除 的系数
        ]]
        o.exchangeCoinRatio = 0 -- Int32
        return o
    end,
    Read = function(self, om)
        local d = om.d
        local r, n
        -- base read
        r = PKG_Lobby_Client_Move_Result.Read(self, om)
        if r ~= 0 then return r end
        -- levelId
        r, self.levelId = d:Rvi32()
        if r ~= 0 then return r end
        -- minBet
        r, self.minBet = d:Rd()
        if r ~= 0 then return r end
        -- maxBet
        r, self.maxBet = d:Rd()
        if r ~= 0 then return r end
        -- minMoney
        r, self.minMoney = d:Rd()
        if r ~= 0 then return r end
        -- exchangeCoinRatio
        r, self.exchangeCoinRatio = d:Rvi32()
        if r ~= 0 then return r end
        return 0
    end,
    Write = function(self, om)
        local d = om.d
        -- base read
        PKG_Lobby_Client_Move_Result.Write(self, om)
        -- levelId
        d:Wvi32(self.levelId)
        -- minBet
        d:Wd(self.minBet)
        -- maxBet
        d:Wd(self.maxBet)
        -- minMoney
        d:Wd(self.minMoney)
        -- exchangeCoinRatio
        d:Wvi32(self.exchangeCoinRatio)
    end
}
PKG_Lobby_Client_GameHuca_LevelInfo.__index = PKG_Lobby_Client_GameHuca_LevelInfo

--[[
请求进入大厅( 下发游戏列表 )
]]
PKG_Client_Lobby_Enter = {
    typeName = "PKG_Client_Lobby_Enter", -- : PKG_Client_Lobby_Move
    typeId = 2002,
    Create = function(o)
        if o == nil then
            o = {}
            setmetatable(o, PKG_Client_Lobby_Enter)
        end
        PKG_Client_Lobby_Move.Create(o)
        --[[
        大厅生成的token
        ]]
        o.token = "" -- String
        return o
    end,
    Read = function(self, om)
        local d = om.d
        local r, n
        -- base read
        r = PKG_Client_Lobby_Move.Read(self, om)
        if r ~= 0 then return r end
        -- token
        r, self.token = d:Rstr()
        if r ~= 0 then return r end
        return 0
    end,
    Write = function(self, om)
        local d = om.d
        -- base read
        PKG_Client_Lobby_Move.Write(self, om)
        -- token
        d:Wstr(self.token)
    end
}
PKG_Client_Lobby_Enter.__index = PKG_Client_Lobby_Enter

--[[
在线聊天
]]
PKG_Client_Lobby_Chat = {
    typeName = "PKG_Client_Lobby_Chat",
    typeId = 2021,
    Create = function(o)
        if o == nil then
            o = {}
            setmetatable(o, PKG_Client_Lobby_Chat)
        end
        --[[
        内容
        ]]
        o.content = "" -- String
        --[[
        图片url(多个图片用逗号分隔)
        ]]
        o.urls = "" -- String
        return o
    end,
    Read = function(self, om)
        local d = om.d
        local r, n
        -- content
        r, self.content = d:Rstr()
        if r ~= 0 then return r end
        -- urls
        r, self.urls = d:Rstr()
        if r ~= 0 then return r end
        return 0
    end,
    Write = function(self, om)
        local d = om.d
        -- content
        d:Wstr(self.content)
        -- urls
        d:Wstr(self.urls)
    end
}
PKG_Client_Lobby_Chat.__index = PKG_Client_Lobby_Chat

--[[
银行卡渠道信息
]]
PKG_Lobby_Client_ChangePayChannelBank_Success = {
    typeName = "PKG_Lobby_Client_ChangePayChannelBank_Success",
    typeId = 1265,
    Create = function(o)
        if o == nil then
            o = {}
            setmetatable(o, PKG_Lobby_Client_ChangePayChannelBank_Success)
        end
        o.pay_channel_accounts = {} -- List<Shared<PKG.Lobby_Client.PayChannelAccount>>
        return o
    end,
    Read = function(self, om)
        local d = om.d
        local r, n, o
        -- pay_channel_accounts
        r, len = d:Rvu32()
        if len > d:GetLeft() then return -1 end
        o = {}
        self.pay_channel_accounts = o
        for i = 1, len do
            r, o[i] = om:Read()
            if r ~= 0 then return r end
        end
        if r ~= 0 then return r end
        return 0
    end,
    Write = function(self, om)
        local d = om.d
        local o, len
        -- pay_channel_accounts
        o = self.pay_channel_accounts
        len = #o
        d:Wvu32(len)
        for i = 1, len do
            om:Write(o[i])
        end
    end
}
PKG_Lobby_Client_ChangePayChannelBank_Success.__index = PKG_Lobby_Client_ChangePayChannelBank_Success

--[[
解锁大奖
]]
PKG_Lobby_Client_UnLockAccount = {
    typeName = "PKG_Lobby_Client_UnLockAccount",
    typeId = 1266,
    Create = function(o)
        if o == nil then
            o = {}
            setmetatable(o, PKG_Lobby_Client_UnLockAccount)
        end
        return o
    end,
    Read = function(self, om)
        local d = om.d
        local r, n
        return 0
    end,
    Write = function(self, om)
        local d = om.d
    end
}
PKG_Lobby_Client_UnLockAccount.__index = PKG_Lobby_Client_UnLockAccount

--[[
获取公告信息
]]
PKG_Client_Lobby_GetNotice = {
    typeName = "PKG_Client_Lobby_GetNotice",
    typeId = 2020,
    Create = function(o)
        if o == nil then
            o = {}
            setmetatable(o, PKG_Client_Lobby_GetNotice)
        end
        return o
    end,
    Read = function(self, om)
        local d = om.d
        local r, n
        return 0
    end,
    Write = function(self, om)
        local d = om.d
    end
}
PKG_Client_Lobby_GetNotice.__index = PKG_Client_Lobby_GetNotice

--[[
消息包集合
]]
PKG_Lobby_Client_AllMessage = {
    typeName = "PKG_Lobby_Client_AllMessage",
    typeId = 1268,
    Create = function(o)
        if o == nil then
            o = {}
            setmetatable(o, PKG_Lobby_Client_AllMessage)
        end
        --[[
        消息集合
        ]]
        o.messages = {} -- List<Shared<PKG.Lobby_Client.Message>>
        return o
    end,
    Read = function(self, om)
        local d = om.d
        local r, n, o
        -- messages
        r, len = d:Rvu32()
        if len > d:GetLeft() then return -1 end
        o = {}
        self.messages = o
        for i = 1, len do
            r, o[i] = om:Read()
            if r ~= 0 then return r end
        end
        if r ~= 0 then return r end
        return 0
    end,
    Write = function(self, om)
        local d = om.d
        local o, len
        -- messages
        o = self.messages
        len = #o
        d:Wvu32(len)
        for i = 1, len do
            om:Write(o[i])
        end
    end
}
PKG_Lobby_Client_AllMessage.__index = PKG_Lobby_Client_AllMessage

--[[
你有多少条未读消息
]]
PKG_Lobby_Client_UnreadMessage = {
    typeName = "PKG_Lobby_Client_UnreadMessage",
    typeId = 1269,
    Create = function(o)
        if o == nil then
            o = {}
            setmetatable(o, PKG_Lobby_Client_UnreadMessage)
        end
        --[[
        你有多少条未读消息
        ]]
        o.msgcount = 0 -- Int32
        return o
    end,
    Read = function(self, om)
        local d = om.d
        local r, n
        -- msgcount
        r, self.msgcount = d:Rvi32()
        if r ~= 0 then return r end
        return 0
    end,
    Write = function(self, om)
        local d = om.d
        -- msgcount
        d:Wvi32(self.msgcount)
    end
}
PKG_Lobby_Client_UnreadMessage.__index = PKG_Lobby_Client_UnreadMessage

--[[
完成客服问题
]]
PKG_Lobby_Client_ClosedCustomerQuestion = {
    typeName = "PKG_Lobby_Client_ClosedCustomerQuestion",
    typeId = 1270,
    Create = function(o)
        if o == nil then
            o = {}
            setmetatable(o, PKG_Lobby_Client_ClosedCustomerQuestion)
        end
        --[[
        批次Id
        ]]
        o.QuestionId = "" -- String
        --[[
        客服问题
        ]]
        o.cutomer_questions = {} -- List<String>
        --[[
        财务问题
        ]]
        o.finance_questions = {} -- List<String>
        return o
    end,
    Read = function(self, om)
        local d = om.d
        local r, n, o
        -- QuestionId
        r, self.QuestionId = d:Rstr()
        if r ~= 0 then return r end
        -- cutomer_questions
        r, len = d:Rvu32()
        if len > d:GetLeft() then return -1 end
        o = {}
        self.cutomer_questions = o
        for i = 1, len do
            r, o[i] = d:Rstr()
            if r ~= 0 then return r end
        end
        if r ~= 0 then return r end
        -- finance_questions
        r, len = d:Rvu32()
        if len > d:GetLeft() then return -1 end
        o = {}
        self.finance_questions = o
        for i = 1, len do
            r, o[i] = d:Rstr()
            if r ~= 0 then return r end
        end
        if r ~= 0 then return r end
        return 0
    end,
    Write = function(self, om)
        local d = om.d
        local o, len
        -- QuestionId
        d:Wstr(self.QuestionId)
        -- cutomer_questions
        o = self.cutomer_questions
        len = #o
        d:Wvu32(len)
        for i = 1, len do
            d:Wstr(o[i])
        end
        -- finance_questions
        o = self.finance_questions
        len = #o
        d:Wvu32(len)
        for i = 1, len do
            d:Wstr(o[i])
        end
    end
}
PKG_Lobby_Client_ClosedCustomerQuestion.__index = PKG_Lobby_Client_ClosedCustomerQuestion

--[[
保险箱充值/取出.
]]
PKG_Client_Lobby_ChangeMoneySafe = {
    typeName = "PKG_Client_Lobby_ChangeMoneySafe",
    typeId = 2019,
    Create = function(o)
        if o == nil then
            o = {}
            setmetatable(o, PKG_Client_Lobby_ChangeMoneySafe)
        end
        --[[
        账号id
        ]]
        o.accountId = 0 -- Int32
        --[[
        金额(>0充值，<0取出)
        ]]
        o.money = 0 -- Double
        return o
    end,
    Read = function(self, om)
        local d = om.d
        local r, n
        -- accountId
        r, self.accountId = d:Rvi32()
        if r ~= 0 then return r end
        -- money
        r, self.money = d:Rd()
        if r ~= 0 then return r end
        return 0
    end,
    Write = function(self, om)
        local d = om.d
        -- accountId
        d:Wvi32(self.accountId)
        -- money
        d:Wd(self.money)
    end
}
PKG_Client_Lobby_ChangeMoneySafe.__index = PKG_Client_Lobby_ChangeMoneySafe

PKG_Lobby_Client_RechargetInfoList = {
    typeName = "PKG_Lobby_Client_RechargetInfoList",
    typeId = 1272,
    Create = function(o)
        if o == nil then
            o = {}
            setmetatable(o, PKG_Lobby_Client_RechargetInfoList)
        end
        --[[
        订单记录集合
        ]]
        o.rechargeinfos = {} -- List<Shared<PKG.Lobby_Client.RechargeInfo>>
        return o
    end,
    Read = function(self, om)
        local d = om.d
        local r, n, o
        -- rechargeinfos
        r, len = d:Rvu32()
        if len > d:GetLeft() then return -1 end
        o = {}
        self.rechargeinfos = o
        for i = 1, len do
            r, o[i] = om:Read()
            if r ~= 0 then return r end
        end
        if r ~= 0 then return r end
        return 0
    end,
    Write = function(self, om)
        local d = om.d
        local o, len
        -- rechargeinfos
        o = self.rechargeinfos
        len = #o
        d:Wvu32(len)
        for i = 1, len do
            om:Write(o[i])
        end
    end
}
PKG_Lobby_Client_RechargetInfoList.__index = PKG_Lobby_Client_RechargetInfoList

--[[
更改公告/邮件阅读状态
]]
PKG_Client_Lobby_ChangeReadState = {
    typeName = "PKG_Client_Lobby_ChangeReadState",
    typeId = 2022,
    Create = function(o)
        if o == nil then
            o = {}
            setmetatable(o, PKG_Client_Lobby_ChangeReadState)
        end
        --[[
        id
        ]]
        o.id = 0 -- Int32
        --[[
        1公告，2邮件
        ]]
        o.type = 0 -- Int32
        return o
    end,
    Read = function(self, om)
        local d = om.d
        local r, n
        -- id
        r, self.id = d:Rvi32()
        if r ~= 0 then return r end
        -- type
        r, self.type = d:Rvi32()
        if r ~= 0 then return r end
        return 0
    end,
    Write = function(self, om)
        local d = om.d
        -- id
        d:Wvi32(self.id)
        -- type
        d:Wvi32(self.type)
    end
}
PKG_Client_Lobby_ChangeReadState.__index = PKG_Client_Lobby_ChangeReadState

--[[
批量获取消息
]]
PKG_Client_Lobby_GetMessage = {
    typeName = "PKG_Client_Lobby_GetMessage",
    typeId = 2047,
    Create = function(o)
        if o == nil then
            o = {}
            setmetatable(o, PKG_Client_Lobby_GetMessage)
        end
        --[[
        翻页起始位置 0=最新消息 时间倒序
        ]]
        o.limitindex = 0 -- Int32
        --[[
        数量起始位置往后拿多少
        ]]
        o.count = 0 -- Int32
        --[[
        accountid
        ]]
        o.accountid = 0 -- Int32
        --[[
        用户名
        ]]
        o.username = "" -- String
        return o
    end,
    Read = function(self, om)
        local d = om.d
        local r, n
        -- limitindex
        r, self.limitindex = d:Rvi32()
        if r ~= 0 then return r end
        -- count
        r, self.count = d:Rvi32()
        if r ~= 0 then return r end
        -- accountid
        r, self.accountid = d:Rvi32()
        if r ~= 0 then return r end
        -- username
        r, self.username = d:Rstr()
        if r ~= 0 then return r end
        return 0
    end,
    Write = function(self, om)
        local d = om.d
        -- limitindex
        d:Wvi32(self.limitindex)
        -- count
        d:Wvi32(self.count)
        -- accountid
        d:Wvi32(self.accountid)
        -- username
        d:Wstr(self.username)
    end
}
PKG_Client_Lobby_GetMessage.__index = PKG_Client_Lobby_GetMessage

--[[
注册临时聊天服务返回结果
]]
PKG_Lobby_Client_RegisterTempMsgServiceResult = {
    typeName = "PKG_Lobby_Client_RegisterTempMsgServiceResult",
    typeId = 1274,
    Create = function(o)
        if o == nil then
            o = {}
            setmetatable(o, PKG_Lobby_Client_RegisterTempMsgServiceResult)
        end
        --[[
        accountid
        ]]
        o.accountid = 0 -- Int32
        --[[
        用户名
        ]]
        o.username = "" -- String
        --[[
        图片URL
        ]]
        o.url = "" -- String
        return o
    end,
    Read = function(self, om)
        local d = om.d
        local r, n
        -- accountid
        r, self.accountid = d:Rvi32()
        if r ~= 0 then return r end
        -- username
        r, self.username = d:Rstr()
        if r ~= 0 then return r end
        -- url
        r, self.url = d:Rstr()
        if r ~= 0 then return r end
        return 0
    end,
    Write = function(self, om)
        local d = om.d
        -- accountid
        d:Wvi32(self.accountid)
        -- username
        d:Wstr(self.username)
        -- url
        d:Wstr(self.url)
    end
}
PKG_Lobby_Client_RegisterTempMsgServiceResult.__index = PKG_Lobby_Client_RegisterTempMsgServiceResult

--[[
排行榜.
]]
PKG_Client_Lobby_GetTodayEarnMoney = {
    typeName = "PKG_Client_Lobby_GetTodayEarnMoney",
    typeId = 2018,
    Create = function(o)
        if o == nil then
            o = {}
            setmetatable(o, PKG_Client_Lobby_GetTodayEarnMoney)
        end
        return o
    end,
    Read = function(self, om)
        local d = om.d
        local r, n
        return 0
    end,
    Write = function(self, om)
        local d = om.d
    end
}
PKG_Client_Lobby_GetTodayEarnMoney.__index = PKG_Client_Lobby_GetTodayEarnMoney

--[[
常见问题列表
]]
PKG_Lobby_Client_FAQList = {
    typeName = "PKG_Lobby_Client_FAQList",
    typeId = 1276,
    Create = function(o)
        if o == nil then
            o = {}
            setmetatable(o, PKG_Lobby_Client_FAQList)
        end
        --[[
        问题列表
        ]]
        o.FAQListResult = {} -- List<Shared<PKG.Lobby_Client.FAQItem>>
        return o
    end,
    Read = function(self, om)
        local d = om.d
        local r, n, o
        -- FAQListResult
        r, len = d:Rvu32()
        if len > d:GetLeft() then return -1 end
        o = {}
        self.FAQListResult = o
        for i = 1, len do
            r, o[i] = om:Read()
            if r ~= 0 then return r end
        end
        if r ~= 0 then return r end
        return 0
    end,
    Write = function(self, om)
        local d = om.d
        local o, len
        -- FAQListResult
        o = self.FAQListResult
        len = #o
        d:Wvu32(len)
        for i = 1, len do
            om:Write(o[i])
        end
    end
}
PKG_Lobby_Client_FAQList.__index = PKG_Lobby_Client_FAQList

--[[
更新玩家实名制信息
]]
PKG_Lobby_Client_UpdateRealName = {
    typeName = "PKG_Lobby_Client_UpdateRealName",
    typeId = 1277,
    Create = function(o)
        if o == nil then
            o = {}
            setmetatable(o, PKG_Lobby_Client_UpdateRealName)
        end
        --[[
        玩家绑定的支付信息
        ]]
        o.pay_channel_accounts = {} -- List<Shared<PKG.Lobby_Client.PayChannelAccount>>
        return o
    end,
    Read = function(self, om)
        local d = om.d
        local r, n, o
        -- pay_channel_accounts
        r, len = d:Rvu32()
        if len > d:GetLeft() then return -1 end
        o = {}
        self.pay_channel_accounts = o
        for i = 1, len do
            r, o[i] = om:Read()
            if r ~= 0 then return r end
        end
        if r ~= 0 then return r end
        return 0
    end,
    Write = function(self, om)
        local d = om.d
        local o, len
        -- pay_channel_accounts
        o = self.pay_channel_accounts
        len = #o
        d:Wvu32(len)
        for i = 1, len do
            om:Write(o[i])
        end
    end
}
PKG_Lobby_Client_UpdateRealName.__index = PKG_Lobby_Client_UpdateRealName

--[[
返回支付码
]]
PKG_Lobby_Client_PaymentKeyResult = {
    typeName = "PKG_Lobby_Client_PaymentKeyResult",
    typeId = 1278,
    Create = function(o)
        if o == nil then
            o = {}
            setmetatable(o, PKG_Lobby_Client_PaymentKeyResult)
        end
        --[[
        支付码
        ]]
        o.key = "" -- String
        return o
    end,
    Read = function(self, om)
        local d = om.d
        local r, n
        -- key
        r, self.key = d:Rstr()
        if r ~= 0 then return r end
        return 0
    end,
    Write = function(self, om)
        local d = om.d
        -- key
        d:Wstr(self.key)
    end
}
PKG_Lobby_Client_PaymentKeyResult.__index = PKG_Lobby_Client_PaymentKeyResult

--[[
大厅Pong
]]
PKG_Lobby_Client_Pong = {
    typeName = "PKG_Lobby_Client_Pong",
    typeId = 1283,
    Create = function(o)
        if o == nil then
            o = {}
            setmetatable(o, PKG_Lobby_Client_Pong)
        end
        o.ticks = 0 -- Int64
        return o
    end,
    Read = function(self, om)
        local d = om.d
        local r, n
        -- ticks
        r, self.ticks = d:Rvi64()
        if r ~= 0 then return r end
        return 0
    end,
    Write = function(self, om)
        local d = om.d
        -- ticks
        d:Wvi64(self.ticks)
    end
}
PKG_Lobby_Client_Pong.__index = PKG_Lobby_Client_Pong

--[[
获取玩家退款集合
]]
PKG_Client_Lobby_GetRefundList = {
    typeName = "PKG_Client_Lobby_GetRefundList",
    typeId = 2017,
    Create = function(o)
        if o == nil then
            o = {}
            setmetatable(o, PKG_Client_Lobby_GetRefundList)
        end
        return o
    end,
    Read = function(self, om)
        local d = om.d
        local r, n
        return 0
    end,
    Write = function(self, om)
        local d = om.d
    end
}
PKG_Client_Lobby_GetRefundList.__index = PKG_Client_Lobby_GetRefundList

--[[
返回洗码赠送绑定金币信息
]]
PKG_Lobby_Client_DailyWashcodeActivityInfo = {
    typeName = "PKG_Lobby_Client_DailyWashcodeActivityInfo",
    typeId = 1291,
    Create = function(o)
        if o == nil then
            o = {}
            setmetatable(o, PKG_Lobby_Client_DailyWashcodeActivityInfo)
        end
        --[[
        洗码等级赠送信息
        ]]
        o.levels = {} -- List<Shared<PKG.Lobby_Client.DailyWashcodeActivityLevel>>
        --[[
        昨日的洗码量
        ]]
        o.last_washcode = 0 -- Double
        --[[
        今日洗码
        ]]
        o.today_washcode = 0 -- Double
        --[[
        状态 1=能领取 0=不能领取
        ]]
        o.can_give = 0 -- Int32
        return o
    end,
    Read = function(self, om)
        local d = om.d
        local r, n, o
        -- levels
        r, len = d:Rvu32()
        if len > d:GetLeft() then return -1 end
        o = {}
        self.levels = o
        for i = 1, len do
            r, o[i] = om:Read()
            if r ~= 0 then return r end
        end
        if r ~= 0 then return r end
        -- last_washcode
        r, self.last_washcode = d:Rd()
        if r ~= 0 then return r end
        -- today_washcode
        r, self.today_washcode = d:Rd()
        if r ~= 0 then return r end
        -- can_give
        r, self.can_give = d:Rvi32()
        if r ~= 0 then return r end
        return 0
    end,
    Write = function(self, om)
        local d = om.d
        local o, len
        -- levels
        o = self.levels
        len = #o
        d:Wvu32(len)
        for i = 1, len do
            om:Write(o[i])
        end
        -- last_washcode
        d:Wd(self.last_washcode)
        -- today_washcode
        d:Wd(self.today_washcode)
        -- can_give
        d:Wvi32(self.can_give)
    end
}
PKG_Lobby_Client_DailyWashcodeActivityInfo.__index = PKG_Lobby_Client_DailyWashcodeActivityInfo

--[[
申请退款
]]
PKG_Client_Lobby_Refund = {
    typeName = "PKG_Client_Lobby_Refund",
    typeId = 2016,
    Create = function(o)
        if o == nil then
            o = {}
            setmetatable(o, PKG_Client_Lobby_Refund)
        end
        --[[
        银行卡Id
        ]]
        o.id = 0 -- Int32
        --[[
        退款金额
        ]]
        o.money = 0 -- Double
        --[[
        退款请求( 渠道, 账号等 )
        ]]
        o.requirement = "" -- String
        --[[
        退款渠道(1=支付宝,2=银行卡)
        ]]
        o.pay_channel_id = 0 -- Int32
        return o
    end,
    Read = function(self, om)
        local d = om.d
        local r, n
        -- id
        r, self.id = d:Rvi32()
        if r ~= 0 then return r end
        -- money
        r, self.money = d:Rd()
        if r ~= 0 then return r end
        -- requirement
        r, self.requirement = d:Rstr()
        if r ~= 0 then return r end
        -- pay_channel_id
        r, self.pay_channel_id = d:Rvi32()
        if r ~= 0 then return r end
        return 0
    end,
    Write = function(self, om)
        local d = om.d
        -- id
        d:Wvi32(self.id)
        -- money
        d:Wd(self.money)
        -- requirement
        d:Wstr(self.requirement)
        -- pay_channel_id
        d:Wvi32(self.pay_channel_id)
    end
}
PKG_Client_Lobby_Refund.__index = PKG_Client_Lobby_Refund

--[[
领取洗码赠送绑定金币返回结果
]]
PKG_Lobby_Client_GetDailyWashcodeInfo = {
    typeName = "PKG_Lobby_Client_GetDailyWashcodeInfo",
    typeId = 1293,
    Create = function(o)
        if o == nil then
            o = {}
            setmetatable(o, PKG_Lobby_Client_GetDailyWashcodeInfo)
        end
        --[[
        是否领取成功 1=领取成功 0=无法领取
        ]]
        o.status = 0 -- Int32
        --[[
        赠送了多少绑定金币
        ]]
        o.give_washcode = 0 -- Double
        return o
    end,
    Read = function(self, om)
        local d = om.d
        local r, n
        -- status
        r, self.status = d:Rvi32()
        if r ~= 0 then return r end
        -- give_washcode
        r, self.give_washcode = d:Rd()
        if r ~= 0 then return r end
        return 0
    end,
    Write = function(self, om)
        local d = om.d
        -- status
        d:Wvi32(self.status)
        -- give_washcode
        d:Wd(self.give_washcode)
    end
}
PKG_Lobby_Client_GetDailyWashcodeInfo.__index = PKG_Lobby_Client_GetDailyWashcodeInfo

--[[
返回活动状态
]]
PKG_Lobby_Client_ResponeActivityInfo = {
    typeName = "PKG_Lobby_Client_ResponeActivityInfo",
    typeId = 1294,
    Create = function(o)
        if o == nil then
            o = {}
            setmetatable(o, PKG_Lobby_Client_ResponeActivityInfo)
        end
        --[[
        活动开关集合
        ]]
        o.activity_status = {} -- List<Shared<PKG.Lobby_Client.Activity_Status>>
        --[[
        首充开关 1=开 0=关
        ]]
        o.is_open_first_rechange_washcode = 0 -- Int32
        return o
    end,
    Read = function(self, om)
        local d = om.d
        local r, n, o
        -- activity_status
        r, len = d:Rvu32()
        if len > d:GetLeft() then return -1 end
        o = {}
        self.activity_status = o
        for i = 1, len do
            r, o[i] = om:Read()
            if r ~= 0 then return r end
        end
        if r ~= 0 then return r end
        -- is_open_first_rechange_washcode
        r, self.is_open_first_rechange_washcode = d:Rvi32()
        if r ~= 0 then return r end
        return 0
    end,
    Write = function(self, om)
        local d = om.d
        local o, len
        -- activity_status
        o = self.activity_status
        len = #o
        d:Wvu32(len)
        for i = 1, len do
            om:Write(o[i])
        end
        -- is_open_first_rechange_washcode
        d:Wvi32(self.is_open_first_rechange_washcode)
    end
}
PKG_Lobby_Client_ResponeActivityInfo.__index = PKG_Lobby_Client_ResponeActivityInfo

PKG_Lobby_Client_BandingRealNameResult = {
    typeName = "PKG_Lobby_Client_BandingRealNameResult",
    typeId = 1273,
    Create = function(o)
        if o == nil then
            o = {}
            setmetatable(o, PKG_Lobby_Client_BandingRealNameResult)
        end
        --[[
        玩家绑定的支付信息
        ]]
        o.pay_channel_accounts = {} -- List<Shared<PKG.Lobby_Client.PayChannelAccount>>
        return o
    end,
    Read = function(self, om)
        local d = om.d
        local r, n, o
        -- pay_channel_accounts
        r, len = d:Rvu32()
        if len > d:GetLeft() then return -1 end
        o = {}
        self.pay_channel_accounts = o
        for i = 1, len do
            r, o[i] = om:Read()
            if r ~= 0 then return r end
        end
        if r ~= 0 then return r end
        return 0
    end,
    Write = function(self, om)
        local d = om.d
        local o, len
        -- pay_channel_accounts
        o = self.pay_channel_accounts
        len = #o
        d:Wvu32(len)
        for i = 1, len do
            om:Write(o[i])
        end
    end
}
PKG_Lobby_Client_BandingRealNameResult.__index = PKG_Lobby_Client_BandingRealNameResult

--[[
返回当前位置
]]
PKG_Lobby_Client_GetPlaceRet = {
    typeName = "PKG_Lobby_Client_GetPlaceRet",
    typeId = 1261,
    Create = function(o)
        if o == nil then
            o = {}
            setmetatable(o, PKG_Lobby_Client_GetPlaceRet)
        end
        --[[
        0表示在大厅，大于0 等于游戏Id
        ]]
        o.Place = 0 -- Int32
        return o
    end,
    Read = function(self, om)
        local d = om.d
        local r, n
        -- Place
        r, self.Place = d:Rvi32()
        if r ~= 0 then return r end
        return 0
    end,
    Write = function(self, om)
        local d = om.d
        -- Place
        d:Wvi32(self.Place)
    end
}
PKG_Lobby_Client_GetPlaceRet.__index = PKG_Lobby_Client_GetPlaceRet

--[[
玩家赠送记录
]]
PKG_Lobby_Client_ReceivedGiftRecord = {
    typeName = "PKG_Lobby_Client_ReceivedGiftRecord",
    typeId = 1259,
    Create = function(o)
        if o == nil then
            o = {}
            setmetatable(o, PKG_Lobby_Client_ReceivedGiftRecord)
        end
        --[[
        赠送记录上线
        ]]
        o.record_count = 0 -- Int32
        --[[
        赠送记录
        ]]
        o.gift_record = {} -- List<Shared<PKG.Lobby_Client.log_gift_money_to_account>>
        --[[
        获赠记录
        ]]
        o.receive_record = {} -- List<Shared<PKG.Lobby_Client.log_gift_money_to_account>>
        return o
    end,
    Read = function(self, om)
        local d = om.d
        local r, n, o
        -- record_count
        r, self.record_count = d:Rvi32()
        if r ~= 0 then return r end
        -- gift_record
        r, len = d:Rvu32()
        if len > d:GetLeft() then return -1 end
        o = {}
        self.gift_record = o
        for i = 1, len do
            r, o[i] = om:Read()
            if r ~= 0 then return r end
        end
        if r ~= 0 then return r end
        -- receive_record
        r, len = d:Rvu32()
        if len > d:GetLeft() then return -1 end
        o = {}
        self.receive_record = o
        for i = 1, len do
            r, o[i] = om:Read()
            if r ~= 0 then return r end
        end
        if r ~= 0 then return r end
        return 0
    end,
    Write = function(self, om)
        local d = om.d
        local o, len
        -- record_count
        d:Wvi32(self.record_count)
        -- gift_record
        o = self.gift_record
        len = #o
        d:Wvu32(len)
        for i = 1, len do
            om:Write(o[i])
        end
        -- receive_record
        o = self.receive_record
        len = #o
        d:Wvu32(len)
        for i = 1, len do
            om:Write(o[i])
        end
    end
}
PKG_Lobby_Client_ReceivedGiftRecord.__index = PKG_Lobby_Client_ReceivedGiftRecord

--[[
转转盘结果
]]
PKG_Lobby_Client_ResponeSpinInfo = {
    typeName = "PKG_Lobby_Client_ResponeSpinInfo",
    typeId = 1295,
    Create = function(o)
        if o == nil then
            o = {}
            setmetatable(o, PKG_Lobby_Client_ResponeSpinInfo)
        end
        --[[
        转了多少绑定金币
        ]]
        o.give_washcode = 0 -- Int64
        return o
    end,
    Read = function(self, om)
        local d = om.d
        local r, n
        -- give_washcode
        r, self.give_washcode = d:Rvi64()
        if r ~= 0 then return r end
        return 0
    end,
    Write = function(self, om)
        local d = om.d
        -- give_washcode
        d:Wvi64(self.give_washcode)
    end
}
PKG_Lobby_Client_ResponeSpinInfo.__index = PKG_Lobby_Client_ResponeSpinInfo

--[[
客户端发起充值请求
]]
PKG_Client_Lobby_ClientRechargeRequest = {
    typeName = "PKG_Client_Lobby_ClientRechargeRequest",
    typeId = 2029,
    Create = function(o)
        if o == nil then
            o = {}
            setmetatable(o, PKG_Client_Lobby_ClientRechargeRequest)
        end
        --[[
        充值的金额
        ]]
        o.money = 0 -- Double
        --[[
        充值的方式,1 支付宝，2 银行卡, 3 微信，10 谷歌支付
        ]]
        o.pay_type = 0 -- Int32
        --[[
        ip信息
        ]]
        o.ip_info = "" -- String
        --[[
        是否生成订单(1=生成)
        ]]
        o.is_create_order = 0 -- Int32
        --[[
        付款人姓名
        ]]
        o.pay_name = "" -- String
        --[[
        付款人卡号
        ]]
        o.pay_card_number = "" -- String
        --[[
        上游订单号
        ]]
        o.upstream_order_num = "" -- String
        --[[
        支付KEY,如果为空字符,那么由服务器随机生成
        ]]
        o.payment_key = "" -- String
        return o
    end,
    Read = function(self, om)
        local d = om.d
        local r, n
        -- money
        r, self.money = d:Rd()
        if r ~= 0 then return r end
        -- pay_type
        r, self.pay_type = d:Rvi32()
        if r ~= 0 then return r end
        -- ip_info
        r, self.ip_info = d:Rstr()
        if r ~= 0 then return r end
        -- is_create_order
        r, self.is_create_order = d:Rvi32()
        if r ~= 0 then return r end
        -- pay_name
        r, self.pay_name = d:Rstr()
        if r ~= 0 then return r end
        -- pay_card_number
        r, self.pay_card_number = d:Rstr()
        if r ~= 0 then return r end
        -- upstream_order_num
        r, self.upstream_order_num = d:Rstr()
        if r ~= 0 then return r end
        -- payment_key
        r, self.payment_key = d:Rstr()
        if r ~= 0 then return r end
        return 0
    end,
    Write = function(self, om)
        local d = om.d
        -- money
        d:Wd(self.money)
        -- pay_type
        d:Wvi32(self.pay_type)
        -- ip_info
        d:Wstr(self.ip_info)
        -- is_create_order
        d:Wvi32(self.is_create_order)
        -- pay_name
        d:Wstr(self.pay_name)
        -- pay_card_number
        d:Wstr(self.pay_card_number)
        -- upstream_order_num
        d:Wstr(self.upstream_order_num)
        -- payment_key
        d:Wstr(self.payment_key)
    end
}
PKG_Client_Lobby_ClientRechargeRequest.__index = PKG_Client_Lobby_ClientRechargeRequest

--[[
退款结果金额变化通知
]]
PKG_Lobby_Client_RefundResultMoneyChanged = {
    typeName = "PKG_Lobby_Client_RefundResultMoneyChanged", -- : PKG_Lobby_Client_MoneyChanged
    typeId = 1237,
    Create = function(o)
        if o == nil then
            o = {}
            setmetatable(o, PKG_Lobby_Client_RefundResultMoneyChanged)
        end
        PKG_Lobby_Client_MoneyChanged.Create(o)
        --[[
        退款金额
        ]]
        o.refund_money = 0 -- Double
        return o
    end,
    Read = function(self, om)
        local d = om.d
        local r, n
        -- base read
        r = PKG_Lobby_Client_MoneyChanged.Read(self, om)
        if r ~= 0 then return r end
        -- refund_money
        r, self.refund_money = d:Rd()
        if r ~= 0 then return r end
        return 0
    end,
    Write = function(self, om)
        local d = om.d
        -- base read
        PKG_Lobby_Client_MoneyChanged.Write(self, om)
        -- refund_money
        d:Wd(self.refund_money)
    end
}
PKG_Lobby_Client_RefundResultMoneyChanged.__index = PKG_Lobby_Client_RefundResultMoneyChanged

--[[
正式注册赠送金额
]]
PKG_Lobby_Client_FormalRegistMoney = {
    typeName = "PKG_Lobby_Client_FormalRegistMoney",
    typeId = 1238,
    Create = function(o)
        if o == nil then
            o = {}
            setmetatable(o, PKG_Lobby_Client_FormalRegistMoney)
        end
        --[[
        赠送金额
        ]]
        o.money = 0 -- Double
        return o
    end,
    Read = function(self, om)
        local d = om.d
        local r, n
        -- money
        r, self.money = d:Rd()
        if r ~= 0 then return r end
        return 0
    end,
    Write = function(self, om)
        local d = om.d
        -- money
        d:Wd(self.money)
    end
}
PKG_Lobby_Client_FormalRegistMoney.__index = PKG_Lobby_Client_FormalRegistMoney

--[[
发起充值成功返回数据给客户端
]]
PKG_Lobby_Client_ClientRechargeRequestSuccess = {
    typeName = "PKG_Lobby_Client_ClientRechargeRequestSuccess",
    typeId = 1239,
    Create = function(o)
        if o == nil then
            o = {}
            setmetatable(o, PKG_Lobby_Client_ClientRechargeRequestSuccess)
        end
        o.pay_url = "" -- String
        o.order_num = "" -- String
        return o
    end,
    Read = function(self, om)
        local d = om.d
        local r, n
        -- pay_url
        r, self.pay_url = d:Rstr()
        if r ~= 0 then return r end
        -- order_num
        r, self.order_num = d:Rstr()
        if r ~= 0 then return r end
        return 0
    end,
    Write = function(self, om)
        local d = om.d
        -- pay_url
        d:Wstr(self.pay_url)
        -- order_num
        d:Wstr(self.order_num)
    end
}
PKG_Lobby_Client_ClientRechargeRequestSuccess.__index = PKG_Lobby_Client_ClientRechargeRequestSuccess

--[[
公司网站
]]
PKG_Lobby_Client_Website = {
    typeName = "PKG_Lobby_Client_Website",
    typeId = 1240,
    Create = function(o)
        if o == nil then
            o = {}
            setmetatable(o, PKG_Lobby_Client_Website)
        end
        --[[
        官网地址
        ]]
        o.website = "" -- String
        --[[
        官网二维码地址
        ]]
        o.website_qrcode = "" -- String
        return o
    end,
    Read = function(self, om)
        local d = om.d
        local r, n
        -- website
        r, self.website = d:Rstr()
        if r ~= 0 then return r end
        -- website_qrcode
        r, self.website_qrcode = d:Rstr()
        if r ~= 0 then return r end
        return 0
    end,
    Write = function(self, om)
        local d = om.d
        -- website
        d:Wstr(self.website)
        -- website_qrcode
        d:Wstr(self.website_qrcode)
    end
}
PKG_Lobby_Client_Website.__index = PKG_Lobby_Client_Website

--[[
发起充值后的结果信息
]]
PKG_Lobby_Client_ClientRechargeResult = {
    typeName = "PKG_Lobby_Client_ClientRechargeResult",
    typeId = 1241,
    Create = function(o)
        if o == nil then
            o = {}
            setmetatable(o, PKG_Lobby_Client_ClientRechargeResult)
        end
        --[[
        状态(0=success;1=fail)
        ]]
        o.state = 0 -- Int32
        --[[
        充值金额
        ]]
        o.money = 0 -- Double
        --[[
        充值后玩家当前总金额
        ]]
        o.curr_money = 0 -- Double
        --[[
        累计充值
        ]]
        o.total_recharge = 0 -- Double
        return o
    end,
    Read = function(self, om)
        local d = om.d
        local r, n
        -- state
        r, self.state = d:Rvi32()
        if r ~= 0 then return r end
        -- money
        r, self.money = d:Rd()
        if r ~= 0 then return r end
        -- curr_money
        r, self.curr_money = d:Rd()
        if r ~= 0 then return r end
        -- total_recharge
        r, self.total_recharge = d:Rd()
        if r ~= 0 then return r end
        return 0
    end,
    Write = function(self, om)
        local d = om.d
        -- state
        d:Wvi32(self.state)
        -- money
        d:Wd(self.money)
        -- curr_money
        d:Wd(self.curr_money)
        -- total_recharge
        d:Wd(self.total_recharge)
    end
}
PKG_Lobby_Client_ClientRechargeResult.__index = PKG_Lobby_Client_ClientRechargeResult

--[[
当前账号在其他设备上登录
]]
PKG_Lobby_Client_OtherDeviceLogin = {
    typeName = "PKG_Lobby_Client_OtherDeviceLogin",
    typeId = 1242,
    Create = function(o)
        if o == nil then
            o = {}
            setmetatable(o, PKG_Lobby_Client_OtherDeviceLogin)
        end
        return o
    end,
    Read = function(self, om)
        local d = om.d
        local r, n
        return 0
    end,
    Write = function(self, om)
        local d = om.d
    end
}
PKG_Lobby_Client_OtherDeviceLogin.__index = PKG_Lobby_Client_OtherDeviceLogin

--[[
赠送金币的结果信息(赠送者)
]]
PKG_Lobby_Client_GiftMoneyResult = {
    typeName = "PKG_Lobby_Client_GiftMoneyResult",
    typeId = 1243,
    Create = function(o)
        if o == nil then
            o = {}
            setmetatable(o, PKG_Lobby_Client_GiftMoneyResult)
        end
        --[[
        账户余额
        ]]
        o.money = 0 -- Double
        --[[
        账户保险箱余额
        ]]
        o.money_safe = 0 -- Double
        return o
    end,
    Read = function(self, om)
        local d = om.d
        local r, n
        -- money
        r, self.money = d:Rd()
        if r ~= 0 then return r end
        -- money_safe
        r, self.money_safe = d:Rd()
        if r ~= 0 then return r end
        return 0
    end,
    Write = function(self, om)
        local d = om.d
        -- money
        d:Wd(self.money)
        -- money_safe
        d:Wd(self.money_safe)
    end
}
PKG_Lobby_Client_GiftMoneyResult.__index = PKG_Lobby_Client_GiftMoneyResult

--[[
赠送金币的结果信息(获赠者)
]]
PKG_Lobby_Client_ReceivedMoneyResult = {
    typeName = "PKG_Lobby_Client_ReceivedMoneyResult",
    typeId = 1244,
    Create = function(o)
        if o == nil then
            o = {}
            setmetatable(o, PKG_Lobby_Client_ReceivedMoneyResult)
        end
        --[[
        账户余额
        ]]
        o.money = 0 -- Double
        --[[
        账户保险箱余额
        ]]
        o.money_safe = 0 -- Double
        --[[
        累计充值金额
        ]]
        o.total_recharge = 0 -- Double
        --[[
        赠送者id
        ]]
        o.gift_account_id = 0 -- Int32
        --[[
        赠送金额
        ]]
        o.gift_money = 0 -- Double
        return o
    end,
    Read = function(self, om)
        local d = om.d
        local r, n
        -- money
        r, self.money = d:Rd()
        if r ~= 0 then return r end
        -- money_safe
        r, self.money_safe = d:Rd()
        if r ~= 0 then return r end
        -- total_recharge
        r, self.total_recharge = d:Rd()
        if r ~= 0 then return r end
        -- gift_account_id
        r, self.gift_account_id = d:Rvi32()
        if r ~= 0 then return r end
        -- gift_money
        r, self.gift_money = d:Rd()
        if r ~= 0 then return r end
        return 0
    end,
    Write = function(self, om)
        local d = om.d
        -- money
        d:Wd(self.money)
        -- money_safe
        d:Wd(self.money_safe)
        -- total_recharge
        d:Wd(self.total_recharge)
        -- gift_account_id
        d:Wvi32(self.gift_account_id)
        -- gift_money
        d:Wd(self.gift_money)
    end
}
PKG_Lobby_Client_ReceivedMoneyResult.__index = PKG_Lobby_Client_ReceivedMoneyResult

--[[
申请代理结果
]]
PKG_Lobby_Client_ApplyPromotionResult = {
    typeName = "PKG_Lobby_Client_ApplyPromotionResult",
    typeId = 1245,
    Create = function(o)
        if o == nil then
            o = {}
            setmetatable(o, PKG_Lobby_Client_ApplyPromotionResult)
        end
        --[[
        状态(0=失败；1=成功会长；2=成功成员;)
        ]]
        o.state = 0 -- Int32
        return o
    end,
    Read = function(self, om)
        local d = om.d
        local r, n
        -- state
        r, self.state = d:Rvi32()
        if r ~= 0 then return r end
        return 0
    end,
    Write = function(self, om)
        local d = om.d
        -- state
        d:Wvi32(self.state)
    end
}
PKG_Lobby_Client_ApplyPromotionResult.__index = PKG_Lobby_Client_ApplyPromotionResult

--[[
代理信息
]]
PKG_Lobby_Client_ReceivedPromotion = {
    typeName = "PKG_Lobby_Client_ReceivedPromotion",
    typeId = 1246,
    Create = function(o)
        if o == nil then
            o = {}
            setmetatable(o, PKG_Lobby_Client_ReceivedPromotion)
        end
        --[[
        是否是代理(0=没有  1是代理 2是成员)
        ]]
        o.status = 0 -- Int32
        --[[
        工会配置说明
        ]]
        o.desc = "" -- String
        --[[
        工会信息
        ]]
        o.info = null -- Shared<PKG.Lobby_Client.PromotionInfo>
        --[[
        我的推广
        ]]
        o.promotion_detail = null -- Shared<PKG.Lobby_Client.PromotionDetail>
        --[[
        我的利润
        ]]
        o.promotion_profit = null -- Shared<PKG.Lobby_Client.PromotionProfit>
        --[[
        成员
        ]]
        o.promotion_user = {} -- List<Shared<PKG.Lobby_Client.PromotionUser>>
        return o
    end,
    Read = function(self, om)
        local d = om.d
        local r, n, o
        -- status
        r, self.status = d:Rvi32()
        if r ~= 0 then return r end
        -- desc
        r, self.desc = d:Rstr()
        if r ~= 0 then return r end
        -- info
        r, self.info = om:Read()
        if r ~= 0 then return r end
        -- promotion_detail
        r, self.promotion_detail = om:Read()
        if r ~= 0 then return r end
        -- promotion_profit
        r, self.promotion_profit = om:Read()
        if r ~= 0 then return r end
        -- promotion_user
        r, len = d:Rvu32()
        if len > d:GetLeft() then return -1 end
        o = {}
        self.promotion_user = o
        for i = 1, len do
            r, o[i] = om:Read()
            if r ~= 0 then return r end
        end
        if r ~= 0 then return r end
        return 0
    end,
    Write = function(self, om)
        local d = om.d
        local o, len
        -- status
        d:Wvi32(self.status)
        -- desc
        d:Wstr(self.desc)
        -- info
        om:Write(self.info)
        -- promotion_detail
        om:Write(self.promotion_detail)
        -- promotion_profit
        om:Write(self.promotion_profit)
        -- promotion_user
        o = self.promotion_user
        len = #o
        d:Wvu32(len)
        for i = 1, len do
            om:Write(o[i])
        end
    end
}
PKG_Lobby_Client_ReceivedPromotion.__index = PKG_Lobby_Client_ReceivedPromotion

--[[
获取正式注册赠送金额
]]
PKG_Client_Lobby_GetFormalRegistMoney = {
    typeName = "PKG_Client_Lobby_GetFormalRegistMoney",
    typeId = 2028,
    Create = function(o)
        if o == nil then
            o = {}
            setmetatable(o, PKG_Client_Lobby_GetFormalRegistMoney)
        end
        return o
    end,
    Read = function(self, om)
        local d = om.d
        local r, n
        return 0
    end,
    Write = function(self, om)
        local d = om.d
    end
}
PKG_Client_Lobby_GetFormalRegistMoney.__index = PKG_Client_Lobby_GetFormalRegistMoney

--[[
获取退款方式信息
]]
PKG_Client_Lobby_GetRefundInfo = {
    typeName = "PKG_Client_Lobby_GetRefundInfo",
    typeId = 2027,
    Create = function(o)
        if o == nil then
            o = {}
            setmetatable(o, PKG_Client_Lobby_GetRefundInfo)
        end
        return o
    end,
    Read = function(self, om)
        local d = om.d
        local r, n
        return 0
    end,
    Write = function(self, om)
        local d = om.d
    end
}
PKG_Client_Lobby_GetRefundInfo.__index = PKG_Client_Lobby_GetRefundInfo

--[[
获取充值方式信息
]]
PKG_Client_Lobby_GetRecharge = {
    typeName = "PKG_Client_Lobby_GetRecharge",
    typeId = 2026,
    Create = function(o)
        if o == nil then
            o = {}
            setmetatable(o, PKG_Client_Lobby_GetRecharge)
        end
        return o
    end,
    Read = function(self, om)
        local d = om.d
        local r, n
        return 0
    end,
    Write = function(self, om)
        local d = om.d
    end
}
PKG_Client_Lobby_GetRecharge.__index = PKG_Client_Lobby_GetRecharge

--[[
退出工会结果
]]
PKG_Lobby_Client_QuitPromotionResult = {
    typeName = "PKG_Lobby_Client_QuitPromotionResult",
    typeId = 1250,
    Create = function(o)
        if o == nil then
            o = {}
            setmetatable(o, PKG_Lobby_Client_QuitPromotionResult)
        end
        --[[
        1=成功 0=失败
        ]]
        o.status = 0 -- Int32
        --[[
        需要多少分钟后才能退出
        ]]
        o.need_minute = 0 -- Int32
        return o
    end,
    Read = function(self, om)
        local d = om.d
        local r, n
        -- status
        r, self.status = d:Rvi32()
        if r ~= 0 then return r end
        -- need_minute
        r, self.need_minute = d:Rvi32()
        if r ~= 0 then return r end
        return 0
    end,
    Write = function(self, om)
        local d = om.d
        -- status
        d:Wvi32(self.status)
        -- need_minute
        d:Wvi32(self.need_minute)
    end
}
PKG_Lobby_Client_QuitPromotionResult.__index = PKG_Lobby_Client_QuitPromotionResult

--[[
银行卡渠道信息
]]
PKG_Client_Lobby_ChangePayChannelBank = {
    typeName = "PKG_Client_Lobby_ChangePayChannelBank",
    typeId = 2025,
    Create = function(o)
        if o == nil then
            o = {}
            setmetatable(o, PKG_Client_Lobby_ChangePayChannelBank)
        end
        --[[
        id
        ]]
        o.id = 0 -- Int32
        --[[
        银行卡开户人姓名
        ]]
        o.name = "" -- String
        --[[
        银行卡卡号
        ]]
        o.card_number = "" -- String
        --[[
        银行卡开户行
        ]]
        o.bank_name = "" -- String
        --[[
        渠道Id
        ]]
        o.pay_channel_id = 0 -- Int32
        --[[
        ifsc 只有印度有,其他国家传空字符
        ]]
        o.ifsc = "" -- String
        return o
    end,
    Read = function(self, om)
        local d = om.d
        local r, n
        -- id
        r, self.id = d:Rvi32()
        if r ~= 0 then return r end
        -- name
        r, self.name = d:Rstr()
        if r ~= 0 then return r end
        -- card_number
        r, self.card_number = d:Rstr()
        if r ~= 0 then return r end
        -- bank_name
        r, self.bank_name = d:Rstr()
        if r ~= 0 then return r end
        -- pay_channel_id
        r, self.pay_channel_id = d:Rvi32()
        if r ~= 0 then return r end
        -- ifsc
        r, self.ifsc = d:Rstr()
        if r ~= 0 then return r end
        return 0
    end,
    Write = function(self, om)
        local d = om.d
        -- id
        d:Wvi32(self.id)
        -- name
        d:Wstr(self.name)
        -- card_number
        d:Wstr(self.card_number)
        -- bank_name
        d:Wstr(self.bank_name)
        -- pay_channel_id
        d:Wvi32(self.pay_channel_id)
        -- ifsc
        d:Wstr(self.ifsc)
    end
}
PKG_Client_Lobby_ChangePayChannelBank.__index = PKG_Client_Lobby_ChangePayChannelBank

--[[
验证facebook
]]
PKG_Lobby_Client_VerificationFacebook_Success = {
    typeName = "PKG_Lobby_Client_VerificationFacebook_Success",
    typeId = 1254,
    Create = function(o)
        if o == nil then
            o = {}
            setmetatable(o, PKG_Lobby_Client_VerificationFacebook_Success)
        end
        --[[
        账户余额
        ]]
        o.money = 0 -- Double
        --[[
        是否已赠送金币(1已赠送)
        ]]
        o.is_system_gift_money = 0 -- Int32
        --[[
        facebook id
        ]]
        o.facebook = "" -- String
        return o
    end,
    Read = function(self, om)
        local d = om.d
        local r, n
        -- money
        r, self.money = d:Rd()
        if r ~= 0 then return r end
        -- is_system_gift_money
        r, self.is_system_gift_money = d:Rvi32()
        if r ~= 0 then return r end
        -- facebook
        r, self.facebook = d:Rstr()
        if r ~= 0 then return r end
        return 0
    end,
    Write = function(self, om)
        local d = om.d
        -- money
        d:Wd(self.money)
        -- is_system_gift_money
        d:Wvi32(self.is_system_gift_money)
        -- facebook
        d:Wstr(self.facebook)
    end
}
PKG_Lobby_Client_VerificationFacebook_Success.__index = PKG_Lobby_Client_VerificationFacebook_Success

--[[
支付宝渠道信息
]]
PKG_Client_Lobby_ChangePayChannelAlipay = {
    typeName = "PKG_Client_Lobby_ChangePayChannelAlipay",
    typeId = 2024,
    Create = function(o)
        if o == nil then
            o = {}
            setmetatable(o, PKG_Client_Lobby_ChangePayChannelAlipay)
        end
        --[[
        支付宝实名制姓名
        ]]
        o.name = "" -- String
        --[[
        支付宝账号
        ]]
        o.account = "" -- String
        --[[
        是否需要加上判断额0=不加1=加
        ]]
        o.is_accuracy = 0 -- Int32
        return o
    end,
    Read = function(self, om)
        local d = om.d
        local r, n
        -- name
        r, self.name = d:Rstr()
        if r ~= 0 then return r end
        -- account
        r, self.account = d:Rstr()
        if r ~= 0 then return r end
        -- is_accuracy
        r, self.is_accuracy = d:Rvi32()
        if r ~= 0 then return r end
        return 0
    end,
    Write = function(self, om)
        local d = om.d
        -- name
        d:Wstr(self.name)
        -- account
        d:Wstr(self.account)
        -- is_accuracy
        d:Wvi32(self.is_accuracy)
    end
}
PKG_Client_Lobby_ChangePayChannelAlipay.__index = PKG_Client_Lobby_ChangePayChannelAlipay

--[[
每日签到信息
]]
PKG_Lobby_Client_EverydaySigninInfo = {
    typeName = "PKG_Lobby_Client_EverydaySigninInfo",
    typeId = 1256,
    Create = function(o)
        if o == nil then
            o = {}
            setmetatable(o, PKG_Lobby_Client_EverydaySigninInfo)
        end
        --[[
        当前能领取的格子Id(1-7),小于此值的表示已领取，大于此值表示未领取，但是不能领取
        ]]
        o.index = 0 -- Int32
        --[[
        每个格子送的钱，共7个
        ]]
        o.moneylist = {} -- List<Shared<PKG.Lobby_Client.everyday_signin_monery_config>>
        --[[
        今天是否领取
        ]]
        o.IsTodayComplete = 0 -- Int32
        return o
    end,
    Read = function(self, om)
        local d = om.d
        local r, n, o
        -- index
        r, self.index = d:Rvi32()
        if r ~= 0 then return r end
        -- moneylist
        r, len = d:Rvu32()
        if len > d:GetLeft() then return -1 end
        o = {}
        self.moneylist = o
        for i = 1, len do
            r, o[i] = om:Read()
            if r ~= 0 then return r end
        end
        if r ~= 0 then return r end
        -- IsTodayComplete
        r, self.IsTodayComplete = d:Rvi32()
        if r ~= 0 then return r end
        return 0
    end,
    Write = function(self, om)
        local d = om.d
        local o, len
        -- index
        d:Wvi32(self.index)
        -- moneylist
        o = self.moneylist
        len = #o
        d:Wvu32(len)
        for i = 1, len do
            om:Write(o[i])
        end
        -- IsTodayComplete
        d:Wvi32(self.IsTodayComplete)
    end
}
PKG_Lobby_Client_EverydaySigninInfo.__index = PKG_Lobby_Client_EverydaySigninInfo

--[[
签到反馈
]]
PKG_Lobby_Client_SigninToDayResult = {
    typeName = "PKG_Lobby_Client_SigninToDayResult",
    typeId = 1257,
    Create = function(o)
        if o == nil then
            o = {}
            setmetatable(o, PKG_Lobby_Client_SigninToDayResult)
        end
        --[[
        获取了多少钱
        ]]
        o.give_money = 0 -- Double
        --[[
        当前用户一共有多少钱
        ]]
        o.curr_money = 0 -- Double
        return o
    end,
    Read = function(self, om)
        local d = om.d
        local r, n
        -- give_money
        r, self.give_money = d:Rd()
        if r ~= 0 then return r end
        -- curr_money
        r, self.curr_money = d:Rd()
        if r ~= 0 then return r end
        return 0
    end,
    Write = function(self, om)
        local d = om.d
        -- give_money
        d:Wd(self.give_money)
        -- curr_money
        d:Wd(self.curr_money)
    end
}
PKG_Lobby_Client_SigninToDayResult.__index = PKG_Lobby_Client_SigninToDayResult

--[[
获取跑马灯信息
]]
PKG_Client_Lobby_GetMarquee = {
    typeName = "PKG_Client_Lobby_GetMarquee",
    typeId = 2023,
    Create = function(o)
        if o == nil then
            o = {}
            setmetatable(o, PKG_Client_Lobby_GetMarquee)
        end
        return o
    end,
    Read = function(self, om)
        local d = om.d
        local r, n
        return 0
    end,
    Write = function(self, om)
        local d = om.d
    end
}
PKG_Client_Lobby_GetMarquee.__index = PKG_Client_Lobby_GetMarquee

--[[
返回大厅
]]
PKG_Lobby_Client_ReturnLobby = {
    typeName = "PKG_Lobby_Client_ReturnLobby",
    typeId = 1260,
    Create = function(o)
        if o == nil then
            o = {}
            setmetatable(o, PKG_Lobby_Client_ReturnLobby)
        end
        return o
    end,
    Read = function(self, om)
        local d = om.d
        local r, n
        return 0
    end,
    Write = function(self, om)
        local d = om.d
    end
}
PKG_Lobby_Client_ReturnLobby.__index = PKG_Lobby_Client_ReturnLobby

--[[
修改密码, 成功返回 Success
]]
PKG_Client_Lobby_ChangePassword = {
    typeName = "PKG_Client_Lobby_ChangePassword",
    typeId = 2015,
    Create = function(o)
        if o == nil then
            o = {}
            setmetatable(o, PKG_Client_Lobby_ChangePassword)
        end
        --[[
        原先的密码
        ]]
        o.oldPassword = "" -- String
        --[[
        新的密码
        ]]
        o.newPassword = "" -- String
        --[[
        短信验证码内容
        ]]
        o.content = "" -- String
        return o
    end,
    Read = function(self, om)
        local d = om.d
        local r, n
        -- oldPassword
        r, self.oldPassword = d:Rstr()
        if r ~= 0 then return r end
        -- newPassword
        r, self.newPassword = d:Rstr()
        if r ~= 0 then return r end
        -- content
        r, self.content = d:Rstr()
        if r ~= 0 then return r end
        return 0
    end,
    Write = function(self, om)
        local d = om.d
        -- oldPassword
        d:Wstr(self.oldPassword)
        -- newPassword
        d:Wstr(self.newPassword)
        -- content
        d:Wstr(self.content)
    end
}
PKG_Client_Lobby_ChangePassword.__index = PKG_Client_Lobby_ChangePassword

--[[
领取任务反馈
]]
PKG_Lobby_Client_ResponeGameTotalActivityAwards = {
    typeName = "PKG_Lobby_Client_ResponeGameTotalActivityAwards",
    typeId = 1298,
    Create = function(o)
        if o == nil then
            o = {}
            setmetatable(o, PKG_Lobby_Client_ResponeGameTotalActivityAwards)
        end
        --[[
        任务id
        ]]
        o.activity_id = 0 -- Int32
        --[[
        是否领取成功
        ]]
        o.status = 0 -- Int32
        --[[
        领取了多少绑定金币
        ]]
        o.give_washcode = 0 -- Int64
        return o
    end,
    Read = function(self, om)
        local d = om.d
        local r, n
        -- activity_id
        r, self.activity_id = d:Rvi32()
        if r ~= 0 then return r end
        -- status
        r, self.status = d:Rvi32()
        if r ~= 0 then return r end
        -- give_washcode
        r, self.give_washcode = d:Rvi64()
        if r ~= 0 then return r end
        return 0
    end,
    Write = function(self, om)
        local d = om.d
        -- activity_id
        d:Wvi32(self.activity_id)
        -- status
        d:Wvi32(self.status)
        -- give_washcode
        d:Wvi64(self.give_washcode)
    end
}
PKG_Lobby_Client_ResponeGameTotalActivityAwards.__index = PKG_Lobby_Client_ResponeGameTotalActivityAwards

--[[
绑定手机成功
]]
PKG_Lobby_Client_BindPhone_Success = {
    typeName = "PKG_Lobby_Client_BindPhone_Success",
    typeId = 1235,
    Create = function(o)
        if o == nil then
            o = {}
            setmetatable(o, PKG_Lobby_Client_BindPhone_Success)
        end
        --[[
        账户余额
        ]]
        o.money = 0 -- Double
        --[[
        是否已赠送金币(1已赠送)
        ]]
        o.is_system_gift_money = 0 -- Int32
        return o
    end,
    Read = function(self, om)
        local d = om.d
        local r, n
        -- money
        r, self.money = d:Rd()
        if r ~= 0 then return r end
        -- is_system_gift_money
        r, self.is_system_gift_money = d:Rvi32()
        if r ~= 0 then return r end
        return 0
    end,
    Write = function(self, om)
        local d = om.d
        -- money
        d:Wd(self.money)
        -- is_system_gift_money
        d:Wvi32(self.is_system_gift_money)
    end
}
PKG_Lobby_Client_BindPhone_Success.__index = PKG_Lobby_Client_BindPhone_Success

--[[
聊天系统公告
]]
PKG_Lobby_Client_ResponseChatNotice = {
    typeName = "PKG_Lobby_Client_ResponseChatNotice",
    typeId = 1322,
    Create = function(o)
        if o == nil then
            o = {}
            setmetatable(o, PKG_Lobby_Client_ResponseChatNotice)
        end
        --[[
        系统公告
        ]]
        o.system = "" -- String
        --[[
        密语系统公告
        ]]
        o.private_system = "" -- String
        --[[
        银商公告集合
        ]]
        o.businessman_notices = {} -- List<PKG.Lobby_Client.BusinessManNotice>
        return o
    end,
    Read = function(self, om)
        local d = om.d
        local r, n, o
        -- system
        r, self.system = d:Rstr()
        if r ~= 0 then return r end
        -- private_system
        r, self.private_system = d:Rstr()
        if r ~= 0 then return r end
        -- businessman_notices
        r, len = d:Rvu32()
        if len > d:GetLeft() then return -1 end
        o = {}
        self.businessman_notices = o
        for i = 1, len do
            o[i] = PKG_Lobby_Client_BusinessManNotice.Create(); r = o[i]:Read(om)
            if r ~= 0 then return r end
        end
        if r ~= 0 then return r end
        return 0
    end,
    Write = function(self, om)
        local d = om.d
        local o, len
        -- system
        d:Wstr(self.system)
        -- private_system
        d:Wstr(self.private_system)
        -- businessman_notices
        o = self.businessman_notices
        len = #o
        d:Wvu32(len)
        for i = 1, len do
            o[i]:Write(om)
        end
    end
}
PKG_Lobby_Client_ResponseChatNotice.__index = PKG_Lobby_Client_ResponseChatNotice

--[[
虚拟币钱包地址绑定结果
]]
PKG_Lobby_Client_ResponseBindVirtualCoinAddress = {
    typeName = "PKG_Lobby_Client_ResponseBindVirtualCoinAddress",
    typeId = 1323,
    Create = function(o)
        if o == nil then
            o = {}
            setmetatable(o, PKG_Lobby_Client_ResponseBindVirtualCoinAddress)
        end
        --[[
        玩家自身绑定的银行卡及虚拟币钱包地址
        ]]
        o.pay_channel_accounts = {} -- List<Shared<PKG.Lobby_Client.PayChannelAccount>>
        return o
    end,
    Read = function(self, om)
        local d = om.d
        local r, n, o
        -- pay_channel_accounts
        r, len = d:Rvu32()
        if len > d:GetLeft() then return -1 end
        o = {}
        self.pay_channel_accounts = o
        for i = 1, len do
            r, o[i] = om:Read()
            if r ~= 0 then return r end
        end
        if r ~= 0 then return r end
        return 0
    end,
    Write = function(self, om)
        local d = om.d
        local o, len
        -- pay_channel_accounts
        o = self.pay_channel_accounts
        len = #o
        d:Wvu32(len)
        for i = 1, len do
            om:Write(o[i])
        end
    end
}
PKG_Lobby_Client_ResponseBindVirtualCoinAddress.__index = PKG_Lobby_Client_ResponseBindVirtualCoinAddress

--[[
洗码奖励活动信息
]]
PKG_Lobby_Client_ResponseWashcodeActivityInfo = {
    typeName = "PKG_Lobby_Client_ResponseWashcodeActivityInfo",
    typeId = 1324,
    Create = function(o)
        if o == nil then
            o = {}
            setmetatable(o, PKG_Lobby_Client_ResponseWashcodeActivityInfo)
        end
        --[[
        活动id
        ]]
        o.activity_id = 0 -- Int32
        --[[
        能否领取 1=能领取 0=不能领取
        ]]
        o.can_give = 0 -- Int32
        return o
    end,
    Read = function(self, om)
        local d = om.d
        local r, n
        -- activity_id
        r, self.activity_id = d:Rvi32()
        if r ~= 0 then return r end
        -- can_give
        r, self.can_give = d:Rvi32()
        if r ~= 0 then return r end
        return 0
    end,
    Write = function(self, om)
        local d = om.d
        -- activity_id
        d:Wvi32(self.activity_id)
        -- can_give
        d:Wvi32(self.can_give)
    end
}
PKG_Lobby_Client_ResponseWashcodeActivityInfo.__index = PKG_Lobby_Client_ResponseWashcodeActivityInfo

--[[
洗码奖励
]]
PKG_Lobby_Client_ResponseReceiveWashcodeActivity = {
    typeName = "PKG_Lobby_Client_ResponseReceiveWashcodeActivity",
    typeId = 1325,
    Create = function(o)
        if o == nil then
            o = {}
            setmetatable(o, PKG_Lobby_Client_ResponseReceiveWashcodeActivity)
        end
        --[[
        活动id
        ]]
        o.activity_id = 0 -- Int32
        --[[
        奖励类型 0=绑定金币 1=金币
        ]]
        o.reward_type = 0 -- Int32
        --[[
        奖励金额
        ]]
        o.reward_value = 0 -- Int64
        return o
    end,
    Read = function(self, om)
        local d = om.d
        local r, n
        -- activity_id
        r, self.activity_id = d:Rvi32()
        if r ~= 0 then return r end
        -- reward_type
        r, self.reward_type = d:Rvi32()
        if r ~= 0 then return r end
        -- reward_value
        r, self.reward_value = d:Rvi64()
        if r ~= 0 then return r end
        return 0
    end,
    Write = function(self, om)
        local d = om.d
        -- activity_id
        d:Wvi32(self.activity_id)
        -- reward_type
        d:Wvi32(self.reward_type)
        -- reward_value
        d:Wvi64(self.reward_value)
    end
}
PKG_Lobby_Client_ResponseReceiveWashcodeActivity.__index = PKG_Lobby_Client_ResponseReceiveWashcodeActivity

--[[
返回玩家详细信息
]]
PKG_Lobby_Client_ReqPlayerInfo = {
    typeName = "PKG_Lobby_Client_ReqPlayerInfo",
    typeId = 1326,
    Create = function(o)
        if o == nil then
            o = {}
            setmetatable(o, PKG_Lobby_Client_ReqPlayerInfo)
        end
        --[[
        信息
        ]]
        o.info = null -- Shared<PKG.ClassDef.selfAccount>
        return o
    end,
    Read = function(self, om)
        local d = om.d
        local r, n
        -- info
        r, self.info = om:Read()
        if r ~= 0 then return r end
        return 0
    end,
    Write = function(self, om)
        local d = om.d
        -- info
        om:Write(self.info)
    end
}
PKG_Lobby_Client_ReqPlayerInfo.__index = PKG_Lobby_Client_ReqPlayerInfo

--[[
银商私聊按钮组
]]
PKG_Lobby_Client_ResponseBusinessmanPrivateMsgButtons = {
    typeName = "PKG_Lobby_Client_ResponseBusinessmanPrivateMsgButtons",
    typeId = 1327,
    Create = function(o)
        if o == nil then
            o = {}
            setmetatable(o, PKG_Lobby_Client_ResponseBusinessmanPrivateMsgButtons)
        end
        --[[
        是否开启充值 0=不开 1=开
        ]]
        o.is_open_recharge = 0 -- Int32
        --[[
        是否开启退钱 0=不开 1=开
        ]]
        o.is_open_refund = 0 -- Int32
        return o
    end,
    Read = function(self, om)
        local d = om.d
        local r, n
        -- is_open_recharge
        r, self.is_open_recharge = d:Rvi32()
        if r ~= 0 then return r end
        -- is_open_refund
        r, self.is_open_refund = d:Rvi32()
        if r ~= 0 then return r end
        return 0
    end,
    Write = function(self, om)
        local d = om.d
        -- is_open_recharge
        d:Wvi32(self.is_open_recharge)
        -- is_open_refund
        d:Wvi32(self.is_open_refund)
    end
}
PKG_Lobby_Client_ResponseBusinessmanPrivateMsgButtons.__index = PKG_Lobby_Client_ResponseBusinessmanPrivateMsgButtons

--[[
银商私聊按钮组更新
]]
PKG_Lobby_Client_UpdateBusinessmanPrivateMsgButtons = {
    typeName = "PKG_Lobby_Client_UpdateBusinessmanPrivateMsgButtons",
    typeId = 1328,
    Create = function(o)
        if o == nil then
            o = {}
            setmetatable(o, PKG_Lobby_Client_UpdateBusinessmanPrivateMsgButtons)
        end
        --[[
        是否开启充值 0=不开 1=开
        ]]
        o.is_open_recharge = 0 -- Int32
        --[[
        是否开启退钱 0=不开 1=开
        ]]
        o.is_open_refund = 0 -- Int32
        return o
    end,
    Read = function(self, om)
        local d = om.d
        local r, n
        -- is_open_recharge
        r, self.is_open_recharge = d:Rvi32()
        if r ~= 0 then return r end
        -- is_open_refund
        r, self.is_open_refund = d:Rvi32()
        if r ~= 0 then return r end
        return 0
    end,
    Write = function(self, om)
        local d = om.d
        -- is_open_recharge
        d:Wvi32(self.is_open_recharge)
        -- is_open_refund
        d:Wvi32(self.is_open_refund)
    end
}
PKG_Lobby_Client_UpdateBusinessmanPrivateMsgButtons.__index = PKG_Lobby_Client_UpdateBusinessmanPrivateMsgButtons

--[[
公共频道聊天记录集合,已排序 最大30条
]]
PKG_Lobby_Client_ResponsePublicMessages = {
    typeName = "PKG_Lobby_Client_ResponsePublicMessages",
    typeId = 1329,
    Create = function(o)
        if o == nil then
            o = {}
            setmetatable(o, PKG_Lobby_Client_ResponsePublicMessages)
        end
        --[[
        当前页码
        ]]
        o.page = 0 -- UInt32
        --[[
        消息集合
        ]]
        o.messages = {} -- List<Shared<PKG.Lobby_Client.PublicMessage>>
        return o
    end,
    Read = function(self, om)
        local d = om.d
        local r, n, o
        -- page
        r, self.page = d:Rvu32()
        if r ~= 0 then return r end
        -- messages
        r, len = d:Rvu32()
        if len > d:GetLeft() then return -1 end
        o = {}
        self.messages = o
        for i = 1, len do
            r, o[i] = om:Read()
            if r ~= 0 then return r end
        end
        if r ~= 0 then return r end
        return 0
    end,
    Write = function(self, om)
        local d = om.d
        local o, len
        -- page
        d:Wvu32(self.page)
        -- messages
        o = self.messages
        len = #o
        d:Wvu32(len)
        for i = 1, len do
            om:Write(o[i])
        end
    end
}
PKG_Lobby_Client_ResponsePublicMessages.__index = PKG_Lobby_Client_ResponsePublicMessages

--[[
私聊聊天记录集合,已排序 最大30条
]]
PKG_Lobby_Client_ResponsePrivateMessages = {
    typeName = "PKG_Lobby_Client_ResponsePrivateMessages",
    typeId = 1331,
    Create = function(o)
        if o == nil then
            o = {}
            setmetatable(o, PKG_Lobby_Client_ResponsePrivateMessages)
        end
        --[[
        目标玩家id
        ]]
        o.target_id = 0 -- Int32
        --[[
        当前页码
        ]]
        o.page = 0 -- UInt32
        --[[
        消息集合
        ]]
        o.messages = {} -- List<Shared<PKG.Lobby_Client.PrivateMessage>>
        return o
    end,
    Read = function(self, om)
        local d = om.d
        local r, n, o
        -- target_id
        r, self.target_id = d:Rvi32()
        if r ~= 0 then return r end
        -- page
        r, self.page = d:Rvu32()
        if r ~= 0 then return r end
        -- messages
        r, len = d:Rvu32()
        if len > d:GetLeft() then return -1 end
        o = {}
        self.messages = o
        for i = 1, len do
            r, o[i] = om:Read()
            if r ~= 0 then return r end
        end
        if r ~= 0 then return r end
        return 0
    end,
    Write = function(self, om)
        local d = om.d
        local o, len
        -- target_id
        d:Wvi32(self.target_id)
        -- page
        d:Wvu32(self.page)
        -- messages
        o = self.messages
        len = #o
        d:Wvu32(len)
        for i = 1, len do
            om:Write(o[i])
        end
    end
}
PKG_Lobby_Client_ResponsePrivateMessages.__index = PKG_Lobby_Client_ResponsePrivateMessages

--[[
测试账号转盘旋转结果
]]
PKG_Lobby_Client_SpinExperienceResult = {
    typeName = "PKG_Lobby_Client_SpinExperienceResult",
    typeId = 1333,
    Create = function(o)
        if o == nil then
            o = {}
            setmetatable(o, PKG_Lobby_Client_SpinExperienceResult)
        end
        --[[
        获得值
        ]]
        o.give_value = 0 -- Int64
        return o
    end,
    Read = function(self, om)
        local d = om.d
        local r, n
        -- give_value
        r, self.give_value = d:Rvi64()
        if r ~= 0 then return r end
        return 0
    end,
    Write = function(self, om)
        local d = om.d
        -- give_value
        d:Wvi64(self.give_value)
    end
}
PKG_Lobby_Client_SpinExperienceResult.__index = PKG_Lobby_Client_SpinExperienceResult

--[[
领取救济金结果
]]
PKG_Lobby_Client_GiveReliefMoneyResult = {
    typeName = "PKG_Lobby_Client_GiveReliefMoneyResult",
    typeId = 1334,
    Create = function(o)
        if o == nil then
            o = {}
            setmetatable(o, PKG_Lobby_Client_GiveReliefMoneyResult)
        end
        --[[
        获得多少救济金
        ]]
        o.money = 0 -- Double
        return o
    end,
    Read = function(self, om)
        local d = om.d
        local r, n
        -- money
        r, self.money = d:Rd()
        if r ~= 0 then return r end
        return 0
    end,
    Write = function(self, om)
        local d = om.d
        -- money
        d:Wd(self.money)
    end
}
PKG_Lobby_Client_GiveReliefMoneyResult.__index = PKG_Lobby_Client_GiveReliefMoneyResult

--[[
测试账号转正式账号通知
]]
PKG_Lobby_Client_UpdateExperienceStatus = {
    typeName = "PKG_Lobby_Client_UpdateExperienceStatus",
    typeId = 1335,
    Create = function(o)
        if o == nil then
            o = {}
            setmetatable(o, PKG_Lobby_Client_UpdateExperienceStatus)
        end
        return o
    end,
    Read = function(self, om)
        local d = om.d
        local r, n
        return 0
    end,
    Write = function(self, om)
        local d = om.d
    end
}
PKG_Lobby_Client_UpdateExperienceStatus.__index = PKG_Lobby_Client_UpdateExperienceStatus

--[[
绑定手机号结果
]]
PKG_Lobby_Client_BindPhoneNumberResult = {
    typeName = "PKG_Lobby_Client_BindPhoneNumberResult",
    typeId = 1336,
    Create = function(o)
        if o == nil then
            o = {}
            setmetatable(o, PKG_Lobby_Client_BindPhoneNumberResult)
        end
        --[[
        成功为true
        ]]
        o.success = false -- Boolean
        --[[
        绑定的手机号
        ]]
        o.phone_number = "" -- String
        return o
    end,
    Read = function(self, om)
        local d = om.d
        local r, n
        -- success
        r, self.success = d:Rb()
        if r ~= 0 then return r end
        -- phone_number
        r, self.phone_number = d:Rstr()
        if r ~= 0 then return r end
        return 0
    end,
    Write = function(self, om)
        local d = om.d
        -- success
        d:Wb(self.success)
        -- phone_number
        d:Wstr(self.phone_number)
    end
}
PKG_Lobby_Client_BindPhoneNumberResult.__index = PKG_Lobby_Client_BindPhoneNumberResult

--[[
绑定邮箱结果
]]
PKG_Lobby_Client_BindEmailResult = {
    typeName = "PKG_Lobby_Client_BindEmailResult",
    typeId = 1337,
    Create = function(o)
        if o == nil then
            o = {}
            setmetatable(o, PKG_Lobby_Client_BindEmailResult)
        end
        --[[
        成功为true
        ]]
        o.success = false -- Boolean
        --[[
        绑定的邮箱
        ]]
        o.email = "" -- String
        return o
    end,
    Read = function(self, om)
        local d = om.d
        local r, n
        -- success
        r, self.success = d:Rb()
        if r ~= 0 then return r end
        -- email
        r, self.email = d:Rstr()
        if r ~= 0 then return r end
        return 0
    end,
    Write = function(self, om)
        local d = om.d
        -- success
        d:Wb(self.success)
        -- email
        d:Wstr(self.email)
    end
}
PKG_Lobby_Client_BindEmailResult.__index = PKG_Lobby_Client_BindEmailResult

--[[
获取砍一刀存档结果
]]
PKG_Lobby_Client_GetAssistanceStoreResult = {
    typeName = "PKG_Lobby_Client_GetAssistanceStoreResult",
    typeId = 1338,
    Create = function(o)
        if o == nil then
            o = {}
            setmetatable(o, PKG_Lobby_Client_GetAssistanceStoreResult)
        end
        --[[
        存档
        ]]
        o.context = "" -- String
        return o
    end,
    Read = function(self, om)
        local d = om.d
        local r, n
        -- context
        r, self.context = d:Rstr()
        if r ~= 0 then return r end
        return 0
    end,
    Write = function(self, om)
        local d = om.d
        -- context
        d:Wstr(self.context)
    end
}
PKG_Lobby_Client_GetAssistanceStoreResult.__index = PKG_Lobby_Client_GetAssistanceStoreResult

--[[
砍一刀信息返回
]]
PKG_Lobby_Client_GetAssistanceInfoResult = {
    typeName = "PKG_Lobby_Client_GetAssistanceInfoResult",
    typeId = 1339,
    Create = function(o)
        if o == nil then
            o = {}
            setmetatable(o, PKG_Lobby_Client_GetAssistanceInfoResult)
        end
        --[[
        当前状态0=分享状态,1=审核,2=审核成功,3=审核成功,并已领取奖励,-1=审核失败
        ]]
        o.status = 0 -- Int32
        --[[
        分享url
        ]]
        o.url = "" -- String
        --[[
        赠送类型0=绑定金币 1=金币
        ]]
        o.reward_type = 0 -- Int32
        --[[
        赠送值
        ]]
        o.reward_value = 0 -- Double
        --[[
        需要助力的玩家数量
        ]]
        o.need_assistance_user_count = 0 -- Int32
        --[[
        当前已助力玩家表
        ]]
        o.accounts = {} -- List<Int32>
        return o
    end,
    Read = function(self, om)
        local d = om.d
        local r, n, o
        -- status
        r, self.status = d:Rvi32()
        if r ~= 0 then return r end
        -- url
        r, self.url = d:Rstr()
        if r ~= 0 then return r end
        -- reward_type
        r, self.reward_type = d:Rvi32()
        if r ~= 0 then return r end
        -- reward_value
        r, self.reward_value = d:Rd()
        if r ~= 0 then return r end
        -- need_assistance_user_count
        r, self.need_assistance_user_count = d:Rvi32()
        if r ~= 0 then return r end
        -- accounts
        r, len = d:Rvu32()
        if len > d:GetLeft() then return -1 end
        o = {}
        self.accounts = o
        for i = 1, len do
            r, o[i] = d:Rvi32()
            if r ~= 0 then return r end
        end
        if r ~= 0 then return r end
        return 0
    end,
    Write = function(self, om)
        local d = om.d
        local o, len
        -- status
        d:Wvi32(self.status)
        -- url
        d:Wstr(self.url)
        -- reward_type
        d:Wvi32(self.reward_type)
        -- reward_value
        d:Wd(self.reward_value)
        -- need_assistance_user_count
        d:Wvi32(self.need_assistance_user_count)
        -- accounts
        o = self.accounts
        len = #o
        d:Wvu32(len)
        for i = 1, len do
            d:Wvi32(o[i])
        end
    end
}
PKG_Lobby_Client_GetAssistanceInfoResult.__index = PKG_Lobby_Client_GetAssistanceInfoResult

--[[
砍一刀助力结果
]]
PKG_Lobby_Client_AssistanceToUserResult = {
    typeName = "PKG_Lobby_Client_AssistanceToUserResult",
    typeId = 1340,
    Create = function(o)
        if o == nil then
            o = {}
            setmetatable(o, PKG_Lobby_Client_AssistanceToUserResult)
        end
        --[[
        1成功,2今日已满,3对方id错误,4=重复助力
        ]]
        o.result = 0 -- Int32
        return o
    end,
    Read = function(self, om)
        local d = om.d
        local r, n
        -- result
        r, self.result = d:Rvi32()
        if r ~= 0 then return r end
        return 0
    end,
    Write = function(self, om)
        local d = om.d
        -- result
        d:Wvi32(self.result)
    end
}
PKG_Lobby_Client_AssistanceToUserResult.__index = PKG_Lobby_Client_AssistanceToUserResult

--[[
砍一刀助力通知
]]
PKG_Lobby_Client_AssistanceToYou = {
    typeName = "PKG_Lobby_Client_AssistanceToYou",
    typeId = 1341,
    Create = function(o)
        if o == nil then
            o = {}
            setmetatable(o, PKG_Lobby_Client_AssistanceToYou)
        end
        --[[
        对方id
        ]]
        o.account_id = 0 -- Int32
        return o
    end,
    Read = function(self, om)
        local d = om.d
        local r, n
        -- account_id
        r, self.account_id = d:Rvi32()
        if r ~= 0 then return r end
        return 0
    end,
    Write = function(self, om)
        local d = om.d
        -- account_id
        d:Wvi32(self.account_id)
    end
}
PKG_Lobby_Client_AssistanceToYou.__index = PKG_Lobby_Client_AssistanceToYou

--[[
获取跑马灯信息(系统跑马灯信息)
]]
PKG_Lobby_Client_Marquee_GetGMMarquees = {
    typeName = "PKG_Lobby_Client_Marquee_GetGMMarquees",
    typeId = 1281,
    Create = function(o)
        if o == nil then
            o = {}
            setmetatable(o, PKG_Lobby_Client_Marquee_GetGMMarquees)
        end
        --[[
        跑马灯集合
        ]]
        o.marquees = {} -- List<Shared<PKG.Lobby_Client.Marquee.Marquee>>
        return o
    end,
    Read = function(self, om)
        local d = om.d
        local r, n, o
        -- marquees
        r, len = d:Rvu32()
        if len > d:GetLeft() then return -1 end
        o = {}
        self.marquees = o
        for i = 1, len do
            r, o[i] = om:Read()
            if r ~= 0 then return r end
        end
        if r ~= 0 then return r end
        return 0
    end,
    Write = function(self, om)
        local d = om.d
        local o, len
        -- marquees
        o = self.marquees
        len = #o
        d:Wvu32(len)
        for i = 1, len do
            om:Write(o[i])
        end
    end
}
PKG_Lobby_Client_Marquee_GetGMMarquees.__index = PKG_Lobby_Client_Marquee_GetGMMarquees

--[[
获取游戏服跑马灯信息(捕鱼游戏)
]]
PKG_Lobby_Client_Marquee_CatchFishMarquees = {
    typeName = "PKG_Lobby_Client_Marquee_CatchFishMarquees",
    typeId = 1282,
    Create = function(o)
        if o == nil then
            o = {}
            setmetatable(o, PKG_Lobby_Client_Marquee_CatchFishMarquees)
        end
        --[[
        游戏ID
        ]]
        o.game_id = 0 -- Int32
        --[[
        游戏名称
        ]]
        o.gameName = "" -- String
        --[[
        玩家昵称
        ]]
        o.nickName = "" -- String
        --[[
        累计充值金额(计算vip等级)
        ]]
        o.total_recharge = 0 -- Double
        --[[
        赚的金币
        ]]
        o.coin = 0 -- Double
        --[[
        子弹的倍率
        ]]
        o.bet = 0 -- Double
        --[[
        打死的鱼id
        ]]
        o.fish_id = 0 -- Int32
        --[[
        打死的鱼名称
        ]]
        o.fish_name = "" -- String
        --[[
        打死鱼的倍率
        ]]
        o.fish_ratio = 0 -- Int32
        return o
    end,
    Read = function(self, om)
        local d = om.d
        local r, n
        -- game_id
        r, self.game_id = d:Rvi32()
        if r ~= 0 then return r end
        -- gameName
        r, self.gameName = d:Rstr()
        if r ~= 0 then return r end
        -- nickName
        r, self.nickName = d:Rstr()
        if r ~= 0 then return r end
        -- total_recharge
        r, self.total_recharge = d:Rd()
        if r ~= 0 then return r end
        -- coin
        r, self.coin = d:Rd()
        if r ~= 0 then return r end
        -- bet
        r, self.bet = d:Rd()
        if r ~= 0 then return r end
        -- fish_id
        r, self.fish_id = d:Rvi32()
        if r ~= 0 then return r end
        -- fish_name
        r, self.fish_name = d:Rstr()
        if r ~= 0 then return r end
        -- fish_ratio
        r, self.fish_ratio = d:Rvi32()
        if r ~= 0 then return r end
        return 0
    end,
    Write = function(self, om)
        local d = om.d
        -- game_id
        d:Wvi32(self.game_id)
        -- gameName
        d:Wstr(self.gameName)
        -- nickName
        d:Wstr(self.nickName)
        -- total_recharge
        d:Wd(self.total_recharge)
        -- coin
        d:Wd(self.coin)
        -- bet
        d:Wd(self.bet)
        -- fish_id
        d:Wvi32(self.fish_id)
        -- fish_name
        d:Wstr(self.fish_name)
        -- fish_ratio
        d:Wvi32(self.fish_ratio)
    end
}
PKG_Lobby_Client_Marquee_CatchFishMarquees.__index = PKG_Lobby_Client_Marquee_CatchFishMarquees

--[[
验证apple
]]
PKG_Lobby_Client_VerificationAppleSuccess = {
    typeName = "PKG_Lobby_Client_VerificationAppleSuccess",
    typeId = 1320,
    Create = function(o)
        if o == nil then
            o = {}
            setmetatable(o, PKG_Lobby_Client_VerificationAppleSuccess)
        end
        --[[
        账户余额
        ]]
        o.money = 0 -- Double
        --[[
        是否已赠送金币(1已赠送)
        ]]
        o.is_system_gift_money = 0 -- Int32
        --[[
        apple id
        ]]
        o.apple = "" -- String
        return o
    end,
    Read = function(self, om)
        local d = om.d
        local r, n
        -- money
        r, self.money = d:Rd()
        if r ~= 0 then return r end
        -- is_system_gift_money
        r, self.is_system_gift_money = d:Rvi32()
        if r ~= 0 then return r end
        -- apple
        r, self.apple = d:Rstr()
        if r ~= 0 then return r end
        return 0
    end,
    Write = function(self, om)
        local d = om.d
        -- money
        d:Wd(self.money)
        -- is_system_gift_money
        d:Wvi32(self.is_system_gift_money)
        -- apple
        d:Wstr(self.apple)
    end
}
PKG_Lobby_Client_VerificationAppleSuccess.__index = PKG_Lobby_Client_VerificationAppleSuccess

--[[
验证google
]]
PKG_Lobby_Client_VerificationGoogleSuccess = {
    typeName = "PKG_Lobby_Client_VerificationGoogleSuccess",
    typeId = 1319,
    Create = function(o)
        if o == nil then
            o = {}
            setmetatable(o, PKG_Lobby_Client_VerificationGoogleSuccess)
        end
        --[[
        账户余额
        ]]
        o.money = 0 -- Double
        --[[
        是否已赠送金币(1已赠送)
        ]]
        o.is_system_gift_money = 0 -- Int32
        --[[
        google id
        ]]
        o.google = "" -- String
        return o
    end,
    Read = function(self, om)
        local d = om.d
        local r, n
        -- money
        r, self.money = d:Rd()
        if r ~= 0 then return r end
        -- is_system_gift_money
        r, self.is_system_gift_money = d:Rvi32()
        if r ~= 0 then return r end
        -- google
        r, self.google = d:Rstr()
        if r ~= 0 then return r end
        return 0
    end,
    Write = function(self, om)
        local d = om.d
        -- money
        d:Wd(self.money)
        -- is_system_gift_money
        d:Wvi32(self.is_system_gift_money)
        -- google
        d:Wstr(self.google)
    end
}
PKG_Lobby_Client_VerificationGoogleSuccess.__index = PKG_Lobby_Client_VerificationGoogleSuccess

--[[
管理员设置状态
]]
PKG_Lobby_Client_ChatGroupMemberSet = {
    typeName = "PKG_Lobby_Client_ChatGroupMemberSet",
    typeId = 1318,
    Create = function(o)
        if o == nil then
            o = {}
            setmetatable(o, PKG_Lobby_Client_ChatGroupMemberSet)
        end
        --[[
        群id
        ]]
        o.group_id = 0 -- Int64
        --[[
        操作内容 1=禁言 2=设置管理员 3=T人
        ]]
        o.feature = 0 -- Int32
        --[[
        1=禁言 0=解除禁言; 1=设置管理员 0=解除管理员;0=T人
        ]]
        o.value = 0 -- Int32
        return o
    end,
    Read = function(self, om)
        local d = om.d
        local r, n
        -- group_id
        r, self.group_id = d:Rvi64()
        if r ~= 0 then return r end
        -- feature
        r, self.feature = d:Rvi32()
        if r ~= 0 then return r end
        -- value
        r, self.value = d:Rvi32()
        if r ~= 0 then return r end
        return 0
    end,
    Write = function(self, om)
        local d = om.d
        -- group_id
        d:Wvi64(self.group_id)
        -- feature
        d:Wvi32(self.feature)
        -- value
        d:Wvi32(self.value)
    end
}
PKG_Lobby_Client_ChatGroupMemberSet.__index = PKG_Lobby_Client_ChatGroupMemberSet

--[[
群解散通知消息
]]
PKG_Lobby_Client_DisbandChatGroup = {
    typeName = "PKG_Lobby_Client_DisbandChatGroup",
    typeId = 1317,
    Create = function(o)
        if o == nil then
            o = {}
            setmetatable(o, PKG_Lobby_Client_DisbandChatGroup)
        end
        --[[
        群id
        ]]
        o.group_id = 0 -- Int64
        return o
    end,
    Read = function(self, om)
        local d = om.d
        local r, n
        -- group_id
        r, self.group_id = d:Rvi64()
        if r ~= 0 then return r end
        return 0
    end,
    Write = function(self, om)
        local d = om.d
        -- group_id
        d:Wvi64(self.group_id)
    end
}
PKG_Lobby_Client_DisbandChatGroup.__index = PKG_Lobby_Client_DisbandChatGroup

--[[
工会返利结果
]]
PKG_Lobby_Client_PromotionSettlementInfo = {
    typeName = "PKG_Lobby_Client_PromotionSettlementInfo",
    typeId = 1299,
    Create = function(o)
        if o == nil then
            o = {}
            setmetatable(o, PKG_Lobby_Client_PromotionSettlementInfo)
        end
        --[[
        捕鱼返利率
        ]]
        o.catchfish_rate = 0 -- Double
        --[[
        老虎机返利率
        ]]
        o.slots_rate = 0 -- Double
        --[[
        成员返利信息集合
        ]]
        o.settlement_members = {} -- List<Shared<PKG.Lobby_Client.SettlementMember>>
        return o
    end,
    Read = function(self, om)
        local d = om.d
        local r, n, o
        -- catchfish_rate
        r, self.catchfish_rate = d:Rd()
        if r ~= 0 then return r end
        -- slots_rate
        r, self.slots_rate = d:Rd()
        if r ~= 0 then return r end
        -- settlement_members
        r, len = d:Rvu32()
        if len > d:GetLeft() then return -1 end
        o = {}
        self.settlement_members = o
        for i = 1, len do
            r, o[i] = om:Read()
            if r ~= 0 then return r end
        end
        if r ~= 0 then return r end
        return 0
    end,
    Write = function(self, om)
        local d = om.d
        local o, len
        -- catchfish_rate
        d:Wd(self.catchfish_rate)
        -- slots_rate
        d:Wd(self.slots_rate)
        -- settlement_members
        o = self.settlement_members
        len = #o
        d:Wvu32(len)
        for i = 1, len do
            om:Write(o[i])
        end
    end
}
PKG_Lobby_Client_PromotionSettlementInfo.__index = PKG_Lobby_Client_PromotionSettlementInfo

--[[
修改头像
]]
PKG_Client_Lobby_ChangeAvatar = {
    typeName = "PKG_Client_Lobby_ChangeAvatar",
    typeId = 2010,
    Create = function(o)
        if o == nil then
            o = {}
            setmetatable(o, PKG_Client_Lobby_ChangeAvatar)
        end
        --[[
        头像
        ]]
        o.avatar_id = 0 -- Int32
        return o
    end,
    Read = function(self, om)
        local d = om.d
        local r, n
        -- avatar_id
        r, self.avatar_id = d:Rvi32()
        if r ~= 0 then return r end
        return 0
    end,
    Write = function(self, om)
        local d = om.d
        -- avatar_id
        d:Wvi32(self.avatar_id)
    end
}
PKG_Client_Lobby_ChangeAvatar.__index = PKG_Client_Lobby_ChangeAvatar

--[[
领取返利结果
]]
PKG_Lobby_Client_ReceiveSettlementResult = {
    typeName = "PKG_Lobby_Client_ReceiveSettlementResult",
    typeId = 1301,
    Create = function(o)
        if o == nil then
            o = {}
            setmetatable(o, PKG_Lobby_Client_ReceiveSettlementResult)
        end
        o.washcode = 0 -- Double
        return o
    end,
    Read = function(self, om)
        local d = om.d
        local r, n
        -- washcode
        r, self.washcode = d:Rd()
        if r ~= 0 then return r end
        return 0
    end,
    Write = function(self, om)
        local d = om.d
        -- washcode
        d:Wd(self.washcode)
    end
}
PKG_Lobby_Client_ReceiveSettlementResult.__index = PKG_Lobby_Client_ReceiveSettlementResult

--[[
返利日记结果
]]
PKG_Lobby_Client_GetReceviceSettlementLogResult = {
    typeName = "PKG_Lobby_Client_GetReceviceSettlementLogResult",
    typeId = 1302,
    Create = function(o)
        if o == nil then
            o = {}
            setmetatable(o, PKG_Lobby_Client_GetReceviceSettlementLogResult)
        end
        o.logs = {} -- List<Shared<PKG.Lobby_Client.ReceviceSettlementLog>>
        return o
    end,
    Read = function(self, om)
        local d = om.d
        local r, n, o
        -- logs
        r, len = d:Rvu32()
        if len > d:GetLeft() then return -1 end
        o = {}
        self.logs = o
        for i = 1, len do
            r, o[i] = om:Read()
            if r ~= 0 then return r end
        end
        if r ~= 0 then return r end
        return 0
    end,
    Write = function(self, om)
        local d = om.d
        local o, len
        -- logs
        o = self.logs
        len = #o
        d:Wvu32(len)
        for i = 1, len do
            om:Write(o[i])
        end
    end
}
PKG_Lobby_Client_GetReceviceSettlementLogResult.__index = PKG_Lobby_Client_GetReceviceSettlementLogResult

--[[
修改昵称
]]
PKG_Client_Lobby_ChangeNickname = {
    typeName = "PKG_Client_Lobby_ChangeNickname",
    typeId = 2009,
    Create = function(o)
        if o == nil then
            o = {}
            setmetatable(o, PKG_Client_Lobby_ChangeNickname)
        end
        --[[
        昵称
        ]]
        o.nickname = "" -- String
        return o
    end,
    Read = function(self, om)
        local d = om.d
        local r, n
        -- nickname
        r, self.nickname = d:Rstr()
        if r ~= 0 then return r end
        return 0
    end,
    Write = function(self, om)
        local d = om.d
        -- nickname
        d:Wstr(self.nickname)
    end
}
PKG_Client_Lobby_ChangeNickname.__index = PKG_Client_Lobby_ChangeNickname

--[[
领取充值福利结果
]]
PKG_Lobby_Client_RequestWelfareStatus = {
    typeName = "PKG_Lobby_Client_RequestWelfareStatus",
    typeId = 1304,
    Create = function(o)
        if o == nil then
            o = {}
            setmetatable(o, PKG_Lobby_Client_RequestWelfareStatus)
        end
        --[[
        0=绑定金币 1=金币
        ]]
        o.welfare_type = 0 -- Int32
        --[[
        领取了多少福利
        ]]
        o.money = 0 -- Double
        return o
    end,
    Read = function(self, om)
        local d = om.d
        local r, n
        -- welfare_type
        r, self.welfare_type = d:Rvi32()
        if r ~= 0 then return r end
        -- money
        r, self.money = d:Rd()
        if r ~= 0 then return r end
        return 0
    end,
    Write = function(self, om)
        local d = om.d
        -- welfare_type
        d:Wvi32(self.welfare_type)
        -- money
        d:Wd(self.money)
    end
}
PKG_Lobby_Client_RequestWelfareStatus.__index = PKG_Lobby_Client_RequestWelfareStatus

--[[
获取自己的信息
]]
PKG_Client_Lobby_OwnInfo = {
    typeName = "PKG_Client_Lobby_OwnInfo",
    typeId = 2008,
    Create = function(o)
        if o == nil then
            o = {}
            setmetatable(o, PKG_Client_Lobby_OwnInfo)
        end
        return o
    end,
    Read = function(self, om)
        local d = om.d
        local r, n
        return 0
    end,
    Write = function(self, om)
        local d = om.d
    end
}
PKG_Client_Lobby_OwnInfo.__index = PKG_Client_Lobby_OwnInfo

--[[
断线重连状态恢复请求
]]
PKG_Client_Lobby_Restore = {
    typeName = "PKG_Client_Lobby_Restore", -- : PKG_Client_Lobby_Enter
    typeId = 2007,
    Create = function(o)
        if o == nil then
            o = {}
            setmetatable(o, PKG_Client_Lobby_Restore)
        end
        PKG_Client_Lobby_Enter.Create(o)
        --[[
        除开 Enter 的上面层层进入的包的打包体( 逻辑进入顺序需要正确 )
        ]]
        o.moves = {} -- List<Shared<PKG.Client_Lobby.Move>>
        return o
    end,
    Read = function(self, om)
        local d = om.d
        local r, n, o
        -- base read
        r = PKG_Client_Lobby_Enter.Read(self, om)
        if r ~= 0 then return r end
        -- moves
        r, len = d:Rvu32()
        if len > d:GetLeft() then return -1 end
        o = {}
        self.moves = o
        for i = 1, len do
            r, o[i] = om:Read()
            if r ~= 0 then return r end
        end
        if r ~= 0 then return r end
        return 0
    end,
    Write = function(self, om)
        local d = om.d
        local o, len
        -- base read
        PKG_Client_Lobby_Enter.Write(self, om)
        -- moves
        o = self.moves
        len = #o
        d:Wvu32(len)
        for i = 1, len do
            om:Write(o[i])
        end
    end
}
PKG_Client_Lobby_Restore.__index = PKG_Client_Lobby_Restore

--[[
工会成员权限
]]
PKG_Lobby_Client_RequestPromotionChatAuthority = {
    typeName = "PKG_Lobby_Client_RequestPromotionChatAuthority",
    typeId = 1307,
    Create = function(o)
        if o == nil then
            o = {}
            setmetatable(o, PKG_Lobby_Client_RequestPromotionChatAuthority)
        end
        --[[
        权限 1=不能说话 0=可以说话
        ]]
        o.authority = 0 -- Int32
        return o
    end,
    Read = function(self, om)
        local d = om.d
        local r, n
        -- authority
        r, self.authority = d:Rvi32()
        if r ~= 0 then return r end
        return 0
    end,
    Write = function(self, om)
        local d = om.d
        -- authority
        d:Wvi32(self.authority)
    end
}
PKG_Lobby_Client_RequestPromotionChatAuthority.__index = PKG_Lobby_Client_RequestPromotionChatAuthority

--[[
离线私聊消息集合
]]
PKG_Lobby_Client_PrivateChatMessages = {
    typeName = "PKG_Lobby_Client_PrivateChatMessages",
    typeId = 1308,
    Create = function(o)
        if o == nil then
            o = {}
            setmetatable(o, PKG_Lobby_Client_PrivateChatMessages)
        end
        --[[
        离线私聊消息集合
        ]]
        o.msgs = {} -- List<Shared<PKG.Lobby_Client.ChatMessage>>
        return o
    end,
    Read = function(self, om)
        local d = om.d
        local r, n, o
        -- msgs
        r, len = d:Rvu32()
        if len > d:GetLeft() then return -1 end
        o = {}
        self.msgs = o
        for i = 1, len do
            r, o[i] = om:Read()
            if r ~= 0 then return r end
        end
        if r ~= 0 then return r end
        return 0
    end,
    Write = function(self, om)
        local d = om.d
        local o, len
        -- msgs
        o = self.msgs
        len = #o
        d:Wvu32(len)
        for i = 1, len do
            om:Write(o[i])
        end
    end
}
PKG_Lobby_Client_PrivateChatMessages.__index = PKG_Lobby_Client_PrivateChatMessages

--[[
游戏任务信息
]]
PKG_Lobby_Client_ResponeGameTotalActivityInfo = {
    typeName = "PKG_Lobby_Client_ResponeGameTotalActivityInfo",
    typeId = 1297,
    Create = function(o)
        if o == nil then
            o = {}
            setmetatable(o, PKG_Lobby_Client_ResponeGameTotalActivityInfo)
        end
        --[[
        任务信息集合
        ]]
        o.activity_status_array = {} -- List<Shared<PKG.Lobby_Client.AccountActivityStatus>>
        return o
    end,
    Read = function(self, om)
        local d = om.d
        local r, n, o
        -- activity_status_array
        r, len = d:Rvu32()
        if len > d:GetLeft() then return -1 end
        o = {}
        self.activity_status_array = o
        for i = 1, len do
            r, o[i] = om:Read()
            if r ~= 0 then return r end
        end
        if r ~= 0 then return r end
        return 0
    end,
    Write = function(self, om)
        local d = om.d
        local o, len
        -- activity_status_array
        o = self.activity_status_array
        len = #o
        d:Wvu32(len)
        for i = 1, len do
            om:Write(o[i])
        end
    end
}
PKG_Lobby_Client_ResponeGameTotalActivityInfo.__index = PKG_Lobby_Client_ResponeGameTotalActivityInfo

--[[
返回上一级菜单
]]
PKG_Client_Lobby_ReturnUp = {
    typeName = "PKG_Client_Lobby_ReturnUp", -- : PKG_Client_Lobby_Move
    typeId = 2006,
    Create = function(o)
        if o == nil then
            o = {}
            setmetatable(o, PKG_Client_Lobby_ReturnUp)
        end
        PKG_Client_Lobby_Move.Create(o)
        return o
    end,
    Read = function(self, om)
        local d = om.d
        local r, n
        -- base read
        r = PKG_Client_Lobby_Move.Read(self, om)
        if r ~= 0 then return r end
        return 0
    end,
    Write = function(self, om)
        local d = om.d
        -- base read
        PKG_Client_Lobby_Move.Write(self, om)
    end
}
PKG_Client_Lobby_ReturnUp.__index = PKG_Client_Lobby_ReturnUp

PKG_Lobby_Client_PromotionUsers = {
    typeName = "PKG_Lobby_Client_PromotionUsers",
    typeId = 1310,
    Create = function(o)
        if o == nil then
            o = {}
            setmetatable(o, PKG_Lobby_Client_PromotionUsers)
        end
        --[[
        工会成员信息
        ]]
        o.promotion_users = {} -- List<Shared<PKG.Lobby_Client.PromotionUser>>
        return o
    end,
    Read = function(self, om)
        local d = om.d
        local r, n, o
        -- promotion_users
        r, len = d:Rvu32()
        if len > d:GetLeft() then return -1 end
        o = {}
        self.promotion_users = o
        for i = 1, len do
            r, o[i] = om:Read()
            if r ~= 0 then return r end
        end
        if r ~= 0 then return r end
        return 0
    end,
    Write = function(self, om)
        local d = om.d
        local o, len
        -- promotion_users
        o = self.promotion_users
        len = #o
        d:Wvu32(len)
        for i = 1, len do
            om:Write(o[i])
        end
    end
}
PKG_Lobby_Client_PromotionUsers.__index = PKG_Lobby_Client_PromotionUsers

--[[
请求进捕鱼房并坐下( 此动作可能触发动态开房 ). 一般性失败错误码为 0, 即因为时间差, 当前位置上已经有人了.
]]
PKG_Client_Lobby_EnterGameCatchFishLevelRoomSit = {
    typeName = "PKG_Client_Lobby_EnterGameCatchFishLevelRoomSit", -- : PKG_Client_Lobby_Move
    typeId = 2005,
    Create = function(o)
        if o == nil then
            o = {}
            setmetatable(o, PKG_Client_Lobby_EnterGameCatchFishLevelRoomSit)
        end
        PKG_Client_Lobby_Move.Create(o)
        --[[
        捕鱼游戏房间id
        ]]
        o.roomId = 0 -- Int32
        --[[
        目标座位号( 0 ~ 3 ). 如果为 -1 表示自动选择
        ]]
        o.sitIndex = 0 -- Int32
        return o
    end,
    Read = function(self, om)
        local d = om.d
        local r, n
        -- base read
        r = PKG_Client_Lobby_Move.Read(self, om)
        if r ~= 0 then return r end
        -- roomId
        r, self.roomId = d:Rvi32()
        if r ~= 0 then return r end
        -- sitIndex
        r, self.sitIndex = d:Rvi32()
        if r ~= 0 then return r end
        return 0
    end,
    Write = function(self, om)
        local d = om.d
        -- base read
        PKG_Client_Lobby_Move.Write(self, om)
        -- roomId
        d:Wvi32(self.roomId)
        -- sitIndex
        d:Wvi32(self.sitIndex)
    end
}
PKG_Client_Lobby_EnterGameCatchFishLevelRoomSit.__index = PKG_Client_Lobby_EnterGameCatchFishLevelRoomSit

--[[
获取聊天用户信息
]]
PKG_Lobby_Client_ResponseChatPlayerInfos = {
    typeName = "PKG_Lobby_Client_ResponseChatPlayerInfos",
    typeId = 1311,
    Create = function(o)
        if o == nil then
            o = {}
            setmetatable(o, PKG_Lobby_Client_ResponseChatPlayerInfos)
        end
        --[[
        聊天用户信息集合
        ]]
        o.info_list = {} -- List<PKG.Lobby_Client.ChatPlayerInfo>
        return o
    end,
    Read = function(self, om)
        local d = om.d
        local r, n, o
        -- info_list
        r, len = d:Rvu32()
        if len > d:GetLeft() then return -1 end
        o = {}
        self.info_list = o
        for i = 1, len do
            o[i] = PKG_Lobby_Client_ChatPlayerInfo.Create(); r = o[i]:Read(om)
            if r ~= 0 then return r end
        end
        if r ~= 0 then return r end
        return 0
    end,
    Write = function(self, om)
        local d = om.d
        local o, len
        -- info_list
        o = self.info_list
        len = #o
        d:Wvu32(len)
        for i = 1, len do
            o[i]:Write(om)
        end
    end
}
PKG_Lobby_Client_ResponseChatPlayerInfos.__index = PKG_Lobby_Client_ResponseChatPlayerInfos

--[[
好友列表
]]
PKG_Lobby_Client_ResponseFriends = {
    typeName = "PKG_Lobby_Client_ResponseFriends",
    typeId = 1312,
    Create = function(o)
        if o == nil then
            o = {}
            setmetatable(o, PKG_Lobby_Client_ResponseFriends)
        end
        o.account_ids = {} -- List<Int32>
        return o
    end,
    Read = function(self, om)
        local d = om.d
        local r, n, o
        -- account_ids
        r, len = d:Rvu32()
        if len > d:GetLeft() then return -1 end
        o = {}
        self.account_ids = o
        for i = 1, len do
            r, o[i] = d:Rvi32()
            if r ~= 0 then return r end
        end
        if r ~= 0 then return r end
        return 0
    end,
    Write = function(self, om)
        local d = om.d
        local o, len
        -- account_ids
        o = self.account_ids
        len = #o
        d:Wvu32(len)
        for i = 1, len do
            d:Wvi32(o[i])
        end
    end
}
PKG_Lobby_Client_ResponseFriends.__index = PKG_Lobby_Client_ResponseFriends

--[[
请求进入捕鱼游戏的某个级别( 将下发该级别下所有房间列表, 以及里面的玩家分布 )
]]
PKG_Client_Lobby_EnterGameCatchFishLevel = {
    typeName = "PKG_Client_Lobby_EnterGameCatchFishLevel", -- : PKG_Client_Lobby_Move
    typeId = 2004,
    Create = function(o)
        if o == nil then
            o = {}
            setmetatable(o, PKG_Client_Lobby_EnterGameCatchFishLevel)
        end
        PKG_Client_Lobby_Move.Create(o)
        --[[
        捕鱼游戏级别id
        ]]
        o.levelId = 0 -- Int32
        return o
    end,
    Read = function(self, om)
        local d = om.d
        local r, n
        -- base read
        r = PKG_Client_Lobby_Move.Read(self, om)
        if r ~= 0 then return r end
        -- levelId
        r, self.levelId = d:Rvi32()
        if r ~= 0 then return r end
        return 0
    end,
    Write = function(self, om)
        local d = om.d
        -- base read
        PKG_Client_Lobby_Move.Write(self, om)
        -- levelId
        d:Wvi32(self.levelId)
    end
}
PKG_Client_Lobby_EnterGameCatchFishLevel.__index = PKG_Client_Lobby_EnterGameCatchFishLevel

--[[
聊天群信息
]]
PKG_Lobby_Client_ResponseChatGroups = {
    typeName = "PKG_Lobby_Client_ResponseChatGroups",
    typeId = 1313,
    Create = function(o)
        if o == nil then
            o = {}
            setmetatable(o, PKG_Lobby_Client_ResponseChatGroups)
        end
        --[[
        已建立群
        ]]
        o.my_groups = {} -- List<PKG.Lobby_Client.ChatGroup>
        --[[
        已加入群
        ]]
        o.join_groups = {} -- List<PKG.Lobby_Client.ChatGroup>
        --[[
        公开群
        ]]
        o.chat_groups = {} -- List<PKG.Lobby_Client.ChatGroup>
        return o
    end,
    Read = function(self, om)
        local d = om.d
        local r, n, o
        -- my_groups
        r, len = d:Rvu32()
        if len > d:GetLeft() then return -1 end
        o = {}
        self.my_groups = o
        for i = 1, len do
            o[i] = PKG_Lobby_Client_ChatGroup.Create(); r = o[i]:Read(om)
            if r ~= 0 then return r end
        end
        if r ~= 0 then return r end
        -- join_groups
        r, len = d:Rvu32()
        if len > d:GetLeft() then return -1 end
        o = {}
        self.join_groups = o
        for i = 1, len do
            o[i] = PKG_Lobby_Client_ChatGroup.Create(); r = o[i]:Read(om)
            if r ~= 0 then return r end
        end
        if r ~= 0 then return r end
        -- chat_groups
        r, len = d:Rvu32()
        if len > d:GetLeft() then return -1 end
        o = {}
        self.chat_groups = o
        for i = 1, len do
            o[i] = PKG_Lobby_Client_ChatGroup.Create(); r = o[i]:Read(om)
            if r ~= 0 then return r end
        end
        if r ~= 0 then return r end
        return 0
    end,
    Write = function(self, om)
        local d = om.d
        local o, len
        -- my_groups
        o = self.my_groups
        len = #o
        d:Wvu32(len)
        for i = 1, len do
            o[i]:Write(om)
        end
        -- join_groups
        o = self.join_groups
        len = #o
        d:Wvu32(len)
        for i = 1, len do
            o[i]:Write(om)
        end
        -- chat_groups
        o = self.chat_groups
        len = #o
        d:Wvu32(len)
        for i = 1, len do
            o[i]:Write(om)
        end
    end
}
PKG_Lobby_Client_ResponseChatGroups.__index = PKG_Lobby_Client_ResponseChatGroups

--[[
聊天群具体信息
]]
PKG_Lobby_Client_ResponseChatGroupInfo = {
    typeName = "PKG_Lobby_Client_ResponseChatGroupInfo",
    typeId = 1314,
    Create = function(o)
        if o == nil then
            o = {}
            setmetatable(o, PKG_Lobby_Client_ResponseChatGroupInfo)
        end
        --[[
        群id
        ]]
        o.id = 0 -- Int64
        --[[
        群名称
        ]]
        o.name = "" -- String
        --[[
        群公告
        ]]
        o.notice = "" -- String
        --[[
        是否全局禁言 =1是 =0 否
        ]]
        o.global_muted = 0 -- Int32
        --[[
        邀请码 如果是空字符串 就是不需要
        ]]
        o.join_code = "" -- String
        --[[
        权限 0=普通成员 1=群主 2=管理
        ]]
        o.authority = 0 -- Int32
        return o
    end,
    Read = function(self, om)
        local d = om.d
        local r, n
        -- id
        r, self.id = d:Rvi64()
        if r ~= 0 then return r end
        -- name
        r, self.name = d:Rstr()
        if r ~= 0 then return r end
        -- notice
        r, self.notice = d:Rstr()
        if r ~= 0 then return r end
        -- global_muted
        r, self.global_muted = d:Rvi32()
        if r ~= 0 then return r end
        -- join_code
        r, self.join_code = d:Rstr()
        if r ~= 0 then return r end
        -- authority
        r, self.authority = d:Rvi32()
        if r ~= 0 then return r end
        return 0
    end,
    Write = function(self, om)
        local d = om.d
        -- id
        d:Wvi64(self.id)
        -- name
        d:Wstr(self.name)
        -- notice
        d:Wstr(self.notice)
        -- global_muted
        d:Wvi32(self.global_muted)
        -- join_code
        d:Wstr(self.join_code)
        -- authority
        d:Wvi32(self.authority)
    end
}
PKG_Lobby_Client_ResponseChatGroupInfo.__index = PKG_Lobby_Client_ResponseChatGroupInfo

--[[
请求进入游戏( 下发具体游戏的下一级的数据. 捕鱼下发 levels )
]]
PKG_Client_Lobby_EnterGame = {
    typeName = "PKG_Client_Lobby_EnterGame", -- : PKG_Client_Lobby_Move
    typeId = 2003,
    Create = function(o)
        if o == nil then
            o = {}
            setmetatable(o, PKG_Client_Lobby_EnterGame)
        end
        PKG_Client_Lobby_Move.Create(o)
        --[[
        游戏id
        ]]
        o.gameId = 0 -- Int32
        return o
    end,
    Read = function(self, om)
        local d = om.d
        local r, n
        -- base read
        r = PKG_Client_Lobby_Move.Read(self, om)
        if r ~= 0 then return r end
        -- gameId
        r, self.gameId = d:Rvi32()
        if r ~= 0 then return r end
        return 0
    end,
    Write = function(self, om)
        local d = om.d
        -- base read
        PKG_Client_Lobby_Move.Write(self, om)
        -- gameId
        d:Wvi32(self.gameId)
    end
}
PKG_Client_Lobby_EnterGame.__index = PKG_Client_Lobby_EnterGame

--[[
聊天群具体信息
]]
PKG_Lobby_Client_ChatGroupMembersInfo = {
    typeName = "PKG_Lobby_Client_ChatGroupMembersInfo",
    typeId = 1315,
    Create = function(o)
        if o == nil then
            o = {}
            setmetatable(o, PKG_Lobby_Client_ChatGroupMembersInfo)
        end
        --[[
        群用户集合
        ]]
        o.member_list = {} -- List<PKG.Lobby_Client.GroupMemberInfo>
        return o
    end,
    Read = function(self, om)
        local d = om.d
        local r, n, o
        -- member_list
        r, len = d:Rvu32()
        if len > d:GetLeft() then return -1 end
        o = {}
        self.member_list = o
        for i = 1, len do
            o[i] = PKG_Lobby_Client_GroupMemberInfo.Create(); r = o[i]:Read(om)
            if r ~= 0 then return r end
        end
        if r ~= 0 then return r end
        return 0
    end,
    Write = function(self, om)
        local d = om.d
        local o, len
        -- member_list
        o = self.member_list
        len = #o
        d:Wvu32(len)
        for i = 1, len do
            o[i]:Write(om)
        end
    end
}
PKG_Lobby_Client_ChatGroupMembersInfo.__index = PKG_Lobby_Client_ChatGroupMembersInfo

--[[
服务器发送给客户端的Message
]]
PKG_Lobby_Client_ChatGroupMessage = {
    typeName = "PKG_Lobby_Client_ChatGroupMessage",
    typeId = 1316,
    Create = function(o)
        if o == nil then
            o = {}
            setmetatable(o, PKG_Lobby_Client_ChatGroupMessage)
        end
        --[[
        群id
        ]]
        o.group_id = 0 -- Int64
        --[[
        发送者信息
        ]]
        o.source = PKG_Lobby_Client_GroupMemberInfo.Create() -- PKG.Lobby_Client.GroupMemberInfo
        --[[
        时间戳
        ]]
        o.time = 0 -- Int64
        --[[
        内容
        ]]
        o.content = "" -- String
        return o
    end,
    Read = function(self, om)
        local d = om.d
        local r, n
        -- group_id
        r, self.group_id = d:Rvi64()
        if r ~= 0 then return r end
        -- source
        self.source = PKG_Lobby_Client_GroupMemberInfo.Create(); r = self.source:Read(om)
        if r ~= 0 then return r end
        -- time
        r, self.time = d:Rvi64()
        if r ~= 0 then return r end
        -- content
        r, self.content = d:Rstr()
        if r ~= 0 then return r end
        return 0
    end,
    Write = function(self, om)
        local d = om.d
        -- group_id
        d:Wvi64(self.group_id)
        -- source
        self.source:Write(om)
        -- time
        d:Wvi64(self.time)
        -- content
        d:Wstr(self.content)
    end
}
PKG_Lobby_Client_ChatGroupMessage.__index = PKG_Lobby_Client_ChatGroupMessage

PKG_Lobby_Client_BusinessmanMassUsers = {
    typeName = "PKG_Lobby_Client_BusinessmanMassUsers",
    typeId = 1309,
    Create = function(o)
        if o == nil then
            o = {}
            setmetatable(o, PKG_Lobby_Client_BusinessmanMassUsers)
        end
        --[[
        用户列表
        ]]
        o.users = {} -- List<PKG.Lobby_Client.MassUser>
        return o
    end,
    Read = function(self, om)
        local d = om.d
        local r, n, o
        -- users
        r, len = d:Rvu32()
        if len > d:GetLeft() then return -1 end
        o = {}
        self.users = o
        for i = 1, len do
            o[i] = PKG_Lobby_Client_MassUser.Create(); r = o[i]:Read(om)
            if r ~= 0 then return r end
        end
        if r ~= 0 then return r end
        return 0
    end,
    Write = function(self, om)
        local d = om.d
        local o, len
        -- users
        o = self.users
        len = #o
        d:Wvu32(len)
        for i = 1, len do
            o[i]:Write(om)
        end
    end
}
PKG_Lobby_Client_BusinessmanMassUsers.__index = PKG_Lobby_Client_BusinessmanMassUsers

--[[
获取退款方式信息
]]
PKG_Lobby_Client_GetRefundInfo = {
    typeName = "PKG_Lobby_Client_GetRefundInfo",
    typeId = 1285,
    Create = function(o)
        if o == nil then
            o = {}
            setmetatable(o, PKG_Lobby_Client_GetRefundInfo)
        end
        o.PayChannels = {} -- List<Shared<PKG.Lobby_Client.PayChannel>>
        --[[
        金币和真钱比例
        ]]
        o.money_exchange_coin = 0 -- Int32
        --[[
        退款二维码
        ]]
        o.qr_image = "" -- String
        --[[
        二维码所在银行
        ]]
        o.qr_bank_name = "" -- String
        --[[
        退款模式 0=常规模式,1=撮合模式(如果手续费10%,退款100,减110)
        ]]
        o.refund_mode = 0 -- Int32
        --[[
        退款手续费
        ]]
        o.fee = 0 -- Double
        return o
    end,
    Read = function(self, om)
        local d = om.d
        local r, n, o
        -- PayChannels
        r, len = d:Rvu32()
        if len > d:GetLeft() then return -1 end
        o = {}
        self.PayChannels = o
        for i = 1, len do
            r, o[i] = om:Read()
            if r ~= 0 then return r end
        end
        if r ~= 0 then return r end
        -- money_exchange_coin
        r, self.money_exchange_coin = d:Rvi32()
        if r ~= 0 then return r end
        -- qr_image
        r, self.qr_image = d:Rstr()
        if r ~= 0 then return r end
        -- qr_bank_name
        r, self.qr_bank_name = d:Rstr()
        if r ~= 0 then return r end
        -- refund_mode
        r, self.refund_mode = d:Rvi32()
        if r ~= 0 then return r end
        -- fee
        r, self.fee = d:Rd()
        if r ~= 0 then return r end
        return 0
    end,
    Write = function(self, om)
        local d = om.d
        local o, len
        -- PayChannels
        o = self.PayChannels
        len = #o
        d:Wvu32(len)
        for i = 1, len do
            om:Write(o[i])
        end
        -- money_exchange_coin
        d:Wvi32(self.money_exchange_coin)
        -- qr_image
        d:Wstr(self.qr_image)
        -- qr_bank_name
        d:Wstr(self.qr_bank_name)
        -- refund_mode
        d:Wvi32(self.refund_mode)
        -- fee
        d:Wd(self.fee)
    end
}
PKG_Lobby_Client_GetRefundInfo.__index = PKG_Lobby_Client_GetRefundInfo

--[[
玩家正常登出.
]]
PKG_Client_Lobby_Login_out = {
    typeName = "PKG_Client_Lobby_Login_out",
    typeId = 2030,
    Create = function(o)
        if o == nil then
            o = {}
            setmetatable(o, PKG_Client_Lobby_Login_out)
        end
        return o
    end,
    Read = function(self, om)
        local d = om.d
        local r, n
        return 0
    end,
    Write = function(self, om)
        local d = om.d
    end
}
PKG_Client_Lobby_Login_out.__index = PKG_Client_Lobby_Login_out

--[[
获取充值方式信息
]]
PKG_Lobby_Client_GetRecharges = {
    typeName = "PKG_Lobby_Client_GetRecharges",
    typeId = 1233,
    Create = function(o)
        if o == nil then
            o = {}
            setmetatable(o, PKG_Lobby_Client_GetRecharges)
        end
        o.payChannels = {} -- List<Shared<PKG.Lobby_Client.PayChannel>>
        o.vipChannels = {} -- List<Shared<PKG.Lobby_Client.vip_channel>>
        o.channelMoneys = {} -- List<Shared<PKG.Lobby_Client.config_channel_money>>
        --[[
        是否显示whats
        ]]
        o.app_switch = 0 -- Int32
        --[[
        最大充值金币上限
        ]]
        o.recharge_max_money = 0 -- Double
        --[[
        识别额度
        ]]
        o.accuracy = 0 -- Double
        --[[
        最小支付金额
        ]]
        o.recharge_min_money = 0 -- Double
        --[[
        是否可以修改付款人姓名 0=可以修改 1=不能修改
        ]]
        o.is_lock_cardname = 0 -- Int32
        --[[
        google充值金额配置
        ]]
        o.googlemoneys = {} -- List<Shared<PKG.Lobby_Client.google_money>>
        --[[
        玩家修改实名信息,金币不可超越值 0=没有限制
        ]]
        o.max_fix_realname_money = 0 -- Double
        --[[
        apple 充值配置
        ]]
        o.apple_moneys = {} -- List<Shared<PKG.Lobby_Client.apple_money>>
        return o
    end,
    Read = function(self, om)
        local d = om.d
        local r, n, o
        -- payChannels
        r, len = d:Rvu32()
        if len > d:GetLeft() then return -1 end
        o = {}
        self.payChannels = o
        for i = 1, len do
            r, o[i] = om:Read()
            if r ~= 0 then return r end
        end
        if r ~= 0 then return r end
        -- vipChannels
        r, len = d:Rvu32()
        if len > d:GetLeft() then return -1 end
        o = {}
        self.vipChannels = o
        for i = 1, len do
            r, o[i] = om:Read()
            if r ~= 0 then return r end
        end
        if r ~= 0 then return r end
        -- channelMoneys
        r, len = d:Rvu32()
        if len > d:GetLeft() then return -1 end
        o = {}
        self.channelMoneys = o
        for i = 1, len do
            r, o[i] = om:Read()
            if r ~= 0 then return r end
        end
        if r ~= 0 then return r end
        -- app_switch
        r, self.app_switch = d:Rvi32()
        if r ~= 0 then return r end
        -- recharge_max_money
        r, self.recharge_max_money = d:Rd()
        if r ~= 0 then return r end
        -- accuracy
        r, self.accuracy = d:Rd()
        if r ~= 0 then return r end
        -- recharge_min_money
        r, self.recharge_min_money = d:Rd()
        if r ~= 0 then return r end
        -- is_lock_cardname
        r, self.is_lock_cardname = d:Rvi32()
        if r ~= 0 then return r end
        -- googlemoneys
        r, len = d:Rvu32()
        if len > d:GetLeft() then return -1 end
        o = {}
        self.googlemoneys = o
        for i = 1, len do
            r, o[i] = om:Read()
            if r ~= 0 then return r end
        end
        if r ~= 0 then return r end
        -- max_fix_realname_money
        r, self.max_fix_realname_money = d:Rd()
        if r ~= 0 then return r end
        -- apple_moneys
        r, len = d:Rvu32()
        if len > d:GetLeft() then return -1 end
        o = {}
        self.apple_moneys = o
        for i = 1, len do
            r, o[i] = om:Read()
            if r ~= 0 then return r end
        end
        if r ~= 0 then return r end
        return 0
    end,
    Write = function(self, om)
        local d = om.d
        local o, len
        -- payChannels
        o = self.payChannels
        len = #o
        d:Wvu32(len)
        for i = 1, len do
            om:Write(o[i])
        end
        -- vipChannels
        o = self.vipChannels
        len = #o
        d:Wvu32(len)
        for i = 1, len do
            om:Write(o[i])
        end
        -- channelMoneys
        o = self.channelMoneys
        len = #o
        d:Wvu32(len)
        for i = 1, len do
            om:Write(o[i])
        end
        -- app_switch
        d:Wvi32(self.app_switch)
        -- recharge_max_money
        d:Wd(self.recharge_max_money)
        -- accuracy
        d:Wd(self.accuracy)
        -- recharge_min_money
        d:Wd(self.recharge_min_money)
        -- is_lock_cardname
        d:Wvi32(self.is_lock_cardname)
        -- googlemoneys
        o = self.googlemoneys
        len = #o
        d:Wvu32(len)
        for i = 1, len do
            om:Write(o[i])
        end
        -- max_fix_realname_money
        d:Wd(self.max_fix_realname_money)
        -- apple_moneys
        o = self.apple_moneys
        len = #o
        d:Wvu32(len)
        for i = 1, len do
            om:Write(o[i])
        end
    end
}
PKG_Lobby_Client_GetRecharges.__index = PKG_Lobby_Client_GetRecharges

--[[
领取返利
]]
PKG_Client_Lobby_ReceiveSettlement = {
    typeName = "PKG_Client_Lobby_ReceiveSettlement",
    typeId = 2074,
    Create = function(o)
        if o == nil then
            o = {}
            setmetatable(o, PKG_Client_Lobby_ReceiveSettlement)
        end
        return o
    end,
    Read = function(self, om)
        local d = om.d
        local r, n
        return 0
    end,
    Write = function(self, om)
        local d = om.d
    end
}
PKG_Client_Lobby_ReceiveSettlement.__index = PKG_Client_Lobby_ReceiveSettlement

--[[
获取返利日记
]]
PKG_Client_Lobby_GetReceviceSettlementLog = {
    typeName = "PKG_Client_Lobby_GetReceviceSettlementLog",
    typeId = 2075,
    Create = function(o)
        if o == nil then
            o = {}
            setmetatable(o, PKG_Client_Lobby_GetReceviceSettlementLog)
        end
        return o
    end,
    Read = function(self, om)
        local d = om.d
        local r, n
        return 0
    end,
    Write = function(self, om)
        local d = om.d
    end
}
PKG_Client_Lobby_GetReceviceSettlementLog.__index = PKG_Client_Lobby_GetReceviceSettlementLog

--[[
领取充值福利
]]
PKG_Client_Lobby_RequestWelfare = {
    typeName = "PKG_Client_Lobby_RequestWelfare",
    typeId = 2076,
    Create = function(o)
        if o == nil then
            o = {}
            setmetatable(o, PKG_Client_Lobby_RequestWelfare)
        end
        return o
    end,
    Read = function(self, om)
        local d = om.d
        local r, n
        return 0
    end,
    Write = function(self, om)
        local d = om.d
    end
}
PKG_Client_Lobby_RequestWelfare.__index = PKG_Client_Lobby_RequestWelfare

--[[
查询苹果充值情况
]]
PKG_Client_Lobby_GetAppleRechargeResult = {
    typeName = "PKG_Client_Lobby_GetAppleRechargeResult",
    typeId = 2077,
    Create = function(o)
        if o == nil then
            o = {}
            setmetatable(o, PKG_Client_Lobby_GetAppleRechargeResult)
        end
        --[[
        苹果充值返回凭据
        ]]
        o.receipt = "" -- String
        --[[
        购买项目的id
        ]]
        o.product_id = "" -- String
        --[[
        订单号
        ]]
        o.order_num = "" -- String
        return o
    end,
    Read = function(self, om)
        local d = om.d
        local r, n
        -- receipt
        r, self.receipt = d:Rstr()
        if r ~= 0 then return r end
        -- product_id
        r, self.product_id = d:Rstr()
        if r ~= 0 then return r end
        -- order_num
        r, self.order_num = d:Rstr()
        if r ~= 0 then return r end
        return 0
    end,
    Write = function(self, om)
        local d = om.d
        -- receipt
        d:Wstr(self.receipt)
        -- product_id
        d:Wstr(self.product_id)
        -- order_num
        d:Wstr(self.order_num)
    end
}
PKG_Client_Lobby_GetAppleRechargeResult.__index = PKG_Client_Lobby_GetAppleRechargeResult

--[[
发送聊天消息给服务器
]]
PKG_Client_Lobby_RequestChatMessage = {
    typeName = "PKG_Client_Lobby_RequestChatMessage",
    typeId = 2078,
    Create = function(o)
        if o == nil then
            o = {}
            setmetatable(o, PKG_Client_Lobby_RequestChatMessage)
        end
        --[[
        类型-1=公频 -2=工会 account id= 私聊
        ]]
        o.target_id = 0 -- Int32
        --[[
        内容
        ]]
        o.content = "" -- String
        return o
    end,
    Read = function(self, om)
        local d = om.d
        local r, n
        -- target_id
        r, self.target_id = d:Rvi32()
        if r ~= 0 then return r end
        -- content
        r, self.content = d:Rstr()
        if r ~= 0 then return r end
        return 0
    end,
    Write = function(self, om)
        local d = om.d
        -- target_id
        d:Wvi32(self.target_id)
        -- content
        d:Wstr(self.content)
    end
}
PKG_Client_Lobby_RequestChatMessage.__index = PKG_Client_Lobby_RequestChatMessage

--[[
获取工会成员权限
]]
PKG_Client_Lobby_GetPromotionAuthority = {
    typeName = "PKG_Client_Lobby_GetPromotionAuthority",
    typeId = 2079,
    Create = function(o)
        if o == nil then
            o = {}
            setmetatable(o, PKG_Client_Lobby_GetPromotionAuthority)
        end
        --[[
        账号id
        ]]
        o.account_id = 0 -- Int32
        return o
    end,
    Read = function(self, om)
        local d = om.d
        local r, n
        -- account_id
        r, self.account_id = d:Rvi32()
        if r ~= 0 then return r end
        return 0
    end,
    Write = function(self, om)
        local d = om.d
        -- account_id
        d:Wvi32(self.account_id)
    end
}
PKG_Client_Lobby_GetPromotionAuthority.__index = PKG_Client_Lobby_GetPromotionAuthority

--[[
设置工会成员权限
]]
PKG_Client_Lobby_SetPromotionAuthority = {
    typeName = "PKG_Client_Lobby_SetPromotionAuthority",
    typeId = 2080,
    Create = function(o)
        if o == nil then
            o = {}
            setmetatable(o, PKG_Client_Lobby_SetPromotionAuthority)
        end
        --[[
        账号id
        ]]
        o.account_id = 0 -- Int32
        --[[
        权限 0=可以聊天 1=不能聊天
        ]]
        o.authority = 0 -- Int32
        return o
    end,
    Read = function(self, om)
        local d = om.d
        local r, n
        -- account_id
        r, self.account_id = d:Rvi32()
        if r ~= 0 then return r end
        -- authority
        r, self.authority = d:Rvi32()
        if r ~= 0 then return r end
        return 0
    end,
    Write = function(self, om)
        local d = om.d
        -- account_id
        d:Wvi32(self.account_id)
        -- authority
        d:Wvi32(self.authority)
    end
}
PKG_Client_Lobby_SetPromotionAuthority.__index = PKG_Client_Lobby_SetPromotionAuthority

--[[
获取离线私聊消息
]]
PKG_Client_Lobby_GetPrivateOffLineChatMessage = {
    typeName = "PKG_Client_Lobby_GetPrivateOffLineChatMessage",
    typeId = 2081,
    Create = function(o)
        if o == nil then
            o = {}
            setmetatable(o, PKG_Client_Lobby_GetPrivateOffLineChatMessage)
        end
        return o
    end,
    Read = function(self, om)
        local d = om.d
        local r, n
        return 0
    end,
    Write = function(self, om)
        local d = om.d
    end
}
PKG_Client_Lobby_GetPrivateOffLineChatMessage.__index = PKG_Client_Lobby_GetPrivateOffLineChatMessage

--[[
获取商家群发玩家列表
]]
PKG_Client_Lobby_GetBusinessmanMassUsers = {
    typeName = "PKG_Client_Lobby_GetBusinessmanMassUsers",
    typeId = 2082,
    Create = function(o)
        if o == nil then
            o = {}
            setmetatable(o, PKG_Client_Lobby_GetBusinessmanMassUsers)
        end
        return o
    end,
    Read = function(self, om)
        local d = om.d
        local r, n
        return 0
    end,
    Write = function(self, om)
        local d = om.d
    end
}
PKG_Client_Lobby_GetBusinessmanMassUsers.__index = PKG_Client_Lobby_GetBusinessmanMassUsers

--[[
发送群发消息
]]
PKG_Client_Lobby_SendMassMessage = {
    typeName = "PKG_Client_Lobby_SendMassMessage",
    typeId = 2083,
    Create = function(o)
        if o == nil then
            o = {}
            setmetatable(o, PKG_Client_Lobby_SendMassMessage)
        end
        --[[
        群发的用户id
        ]]
        o.user_ids = {} -- List<Int32>
        --[[
        内容
        ]]
        o.content = "" -- String
        return o
    end,
    Read = function(self, om)
        local d = om.d
        local r, n, o
        -- user_ids
        r, len = d:Rvu32()
        if len > d:GetLeft() then return -1 end
        o = {}
        self.user_ids = o
        for i = 1, len do
            r, o[i] = d:Rvi32()
            if r ~= 0 then return r end
        end
        if r ~= 0 then return r end
        -- content
        r, self.content = d:Rstr()
        if r ~= 0 then return r end
        return 0
    end,
    Write = function(self, om)
        local d = om.d
        local o, len
        -- user_ids
        o = self.user_ids
        len = #o
        d:Wvu32(len)
        for i = 1, len do
            d:Wvi32(o[i])
        end
        -- content
        d:Wstr(self.content)
    end
}
PKG_Client_Lobby_SendMassMessage.__index = PKG_Client_Lobby_SendMassMessage

--[[
获取工会返利信息
]]
PKG_Client_Lobby_GetPromotionSettlementInfo = {
    typeName = "PKG_Client_Lobby_GetPromotionSettlementInfo",
    typeId = 2073,
    Create = function(o)
        if o == nil then
            o = {}
            setmetatable(o, PKG_Client_Lobby_GetPromotionSettlementInfo)
        end
        return o
    end,
    Read = function(self, om)
        local d = om.d
        local r, n
        return 0
    end,
    Write = function(self, om)
        local d = om.d
    end
}
PKG_Client_Lobby_GetPromotionSettlementInfo.__index = PKG_Client_Lobby_GetPromotionSettlementInfo

--[[
获取工会成员列表
]]
PKG_Client_Lobby_GetPromotionUsers = {
    typeName = "PKG_Client_Lobby_GetPromotionUsers",
    typeId = 2084,
    Create = function(o)
        if o == nil then
            o = {}
            setmetatable(o, PKG_Client_Lobby_GetPromotionUsers)
        end
        return o
    end,
    Read = function(self, om)
        local d = om.d
        local r, n
        return 0
    end,
    Write = function(self, om)
        local d = om.d
    end
}
PKG_Client_Lobby_GetPromotionUsers.__index = PKG_Client_Lobby_GetPromotionUsers

--[[
获取好友列表
]]
PKG_Client_Lobby_GetFriends = {
    typeName = "PKG_Client_Lobby_GetFriends",
    typeId = 2086,
    Create = function(o)
        if o == nil then
            o = {}
            setmetatable(o, PKG_Client_Lobby_GetFriends)
        end
        return o
    end,
    Read = function(self, om)
        local d = om.d
        local r, n
        return 0
    end,
    Write = function(self, om)
        local d = om.d
    end
}
PKG_Client_Lobby_GetFriends.__index = PKG_Client_Lobby_GetFriends

--[[
获取聊天群信息
]]
PKG_Client_Lobby_GetChatGroups = {
    typeName = "PKG_Client_Lobby_GetChatGroups",
    typeId = 2087,
    Create = function(o)
        if o == nil then
            o = {}
            setmetatable(o, PKG_Client_Lobby_GetChatGroups)
        end
        return o
    end,
    Read = function(self, om)
        local d = om.d
        local r, n
        return 0
    end,
    Write = function(self, om)
        local d = om.d
    end
}
PKG_Client_Lobby_GetChatGroups.__index = PKG_Client_Lobby_GetChatGroups

--[[
建立聊天群
]]
PKG_Client_Lobby_CreateChatGroup = {
    typeName = "PKG_Client_Lobby_CreateChatGroup",
    typeId = 2088,
    Create = function(o)
        if o == nil then
            o = {}
            setmetatable(o, PKG_Client_Lobby_CreateChatGroup)
        end
        --[[
        群名称
        ]]
        o.name = "" -- String
        --[[
        进入码
        ]]
        o.join_code = "" -- String
        return o
    end,
    Read = function(self, om)
        local d = om.d
        local r, n
        -- name
        r, self.name = d:Rstr()
        if r ~= 0 then return r end
        -- join_code
        r, self.join_code = d:Rstr()
        if r ~= 0 then return r end
        return 0
    end,
    Write = function(self, om)
        local d = om.d
        -- name
        d:Wstr(self.name)
        -- join_code
        d:Wstr(self.join_code)
    end
}
PKG_Client_Lobby_CreateChatGroup.__index = PKG_Client_Lobby_CreateChatGroup

--[[
获取已加入聊天群具体信息
]]
PKG_Client_Lobby_GetChatGroupInfo = {
    typeName = "PKG_Client_Lobby_GetChatGroupInfo",
    typeId = 2089,
    Create = function(o)
        if o == nil then
            o = {}
            setmetatable(o, PKG_Client_Lobby_GetChatGroupInfo)
        end
        --[[
        群id
        ]]
        o.group_id = 0 -- Int64
        return o
    end,
    Read = function(self, om)
        local d = om.d
        local r, n
        -- group_id
        r, self.group_id = d:Rvi64()
        if r ~= 0 then return r end
        return 0
    end,
    Write = function(self, om)
        local d = om.d
        -- group_id
        d:Wvi64(self.group_id)
    end
}
PKG_Client_Lobby_GetChatGroupInfo.__index = PKG_Client_Lobby_GetChatGroupInfo

--[[
获取群成员信息
]]
PKG_Client_Lobby_GetChatGroupMember = {
    typeName = "PKG_Client_Lobby_GetChatGroupMember",
    typeId = 2090,
    Create = function(o)
        if o == nil then
            o = {}
            setmetatable(o, PKG_Client_Lobby_GetChatGroupMember)
        end
        --[[
        群id
        ]]
        o.group_id = 0 -- Int64
        return o
    end,
    Read = function(self, om)
        local d = om.d
        local r, n
        -- group_id
        r, self.group_id = d:Rvi64()
        if r ~= 0 then return r end
        return 0
    end,
    Write = function(self, om)
        local d = om.d
        -- group_id
        d:Wvi64(self.group_id)
    end
}
PKG_Client_Lobby_GetChatGroupMember.__index = PKG_Client_Lobby_GetChatGroupMember

--[[
管理员编辑群信息
]]
PKG_Client_Lobby_EditGroupInfo = {
    typeName = "PKG_Client_Lobby_EditGroupInfo",
    typeId = 2091,
    Create = function(o)
        if o == nil then
            o = {}
            setmetatable(o, PKG_Client_Lobby_EditGroupInfo)
        end
        --[[
        群id
        ]]
        o.group_id = 0 -- Int64
        --[[
        群名称
        ]]
        o.name = "" -- String
        --[[
        群公告
        ]]
        o.notice = "" -- String
        --[[
        是否全局禁言 =1是 =0 否
        ]]
        o.global_muted = 0 -- Int32
        --[[
        邀请码 如果是空字符串 就是不需要
        ]]
        o.join_code = "" -- String
        return o
    end,
    Read = function(self, om)
        local d = om.d
        local r, n
        -- group_id
        r, self.group_id = d:Rvi64()
        if r ~= 0 then return r end
        -- name
        r, self.name = d:Rstr()
        if r ~= 0 then return r end
        -- notice
        r, self.notice = d:Rstr()
        if r ~= 0 then return r end
        -- global_muted
        r, self.global_muted = d:Rvi32()
        if r ~= 0 then return r end
        -- join_code
        r, self.join_code = d:Rstr()
        if r ~= 0 then return r end
        return 0
    end,
    Write = function(self, om)
        local d = om.d
        -- group_id
        d:Wvi64(self.group_id)
        -- name
        d:Wstr(self.name)
        -- notice
        d:Wstr(self.notice)
        -- global_muted
        d:Wvi32(self.global_muted)
        -- join_code
        d:Wstr(self.join_code)
    end
}
PKG_Client_Lobby_EditGroupInfo.__index = PKG_Client_Lobby_EditGroupInfo

--[[
管理员操作
]]
PKG_Client_Lobby_GroupAdminMemberSet = {
    typeName = "PKG_Client_Lobby_GroupAdminMemberSet",
    typeId = 2092,
    Create = function(o)
        if o == nil then
            o = {}
            setmetatable(o, PKG_Client_Lobby_GroupAdminMemberSet)
        end
        --[[
        群id
        ]]
        o.group_id = 0 -- Int64
        --[[
        操作的玩家id
        ]]
        o.account_id = 0 -- Int32
        --[[
        操作内容 1=禁言 2=设置管理员 3=T人
        ]]
        o.feature = 0 -- Int32
        --[[
        1=禁言 0=解除禁言; 1=设置管理员 0=解除管理员;0=T人
        ]]
        o.value = 0 -- Int32
        return o
    end,
    Read = function(self, om)
        local d = om.d
        local r, n
        -- group_id
        r, self.group_id = d:Rvi64()
        if r ~= 0 then return r end
        -- account_id
        r, self.account_id = d:Rvi32()
        if r ~= 0 then return r end
        -- feature
        r, self.feature = d:Rvi32()
        if r ~= 0 then return r end
        -- value
        r, self.value = d:Rvi32()
        if r ~= 0 then return r end
        return 0
    end,
    Write = function(self, om)
        local d = om.d
        -- group_id
        d:Wvi64(self.group_id)
        -- account_id
        d:Wvi32(self.account_id)
        -- feature
        d:Wvi32(self.feature)
        -- value
        d:Wvi32(self.value)
    end
}
PKG_Client_Lobby_GroupAdminMemberSet.__index = PKG_Client_Lobby_GroupAdminMemberSet

--[[
解散群
]]
PKG_Client_Lobby_DisbandGroup = {
    typeName = "PKG_Client_Lobby_DisbandGroup",
    typeId = 2093,
    Create = function(o)
        if o == nil then
            o = {}
            setmetatable(o, PKG_Client_Lobby_DisbandGroup)
        end
        --[[
        群id
        ]]
        o.group_id = 0 -- Int64
        return o
    end,
    Read = function(self, om)
        local d = om.d
        local r, n
        -- group_id
        r, self.group_id = d:Rvi64()
        if r ~= 0 then return r end
        return 0
    end,
    Write = function(self, om)
        local d = om.d
        -- group_id
        d:Wvi64(self.group_id)
    end
}
PKG_Client_Lobby_DisbandGroup.__index = PKG_Client_Lobby_DisbandGroup

--[[
加入聊天群
]]
PKG_Client_Lobby_JoinChatGroup = {
    typeName = "PKG_Client_Lobby_JoinChatGroup",
    typeId = 2094,
    Create = function(o)
        if o == nil then
            o = {}
            setmetatable(o, PKG_Client_Lobby_JoinChatGroup)
        end
        --[[
        群id
        ]]
        o.id = 0 -- Int64
        --[[
        加入码 没有就写空字符
        ]]
        o.join_code = "" -- String
        return o
    end,
    Read = function(self, om)
        local d = om.d
        local r, n
        -- id
        r, self.id = d:Rvi64()
        if r ~= 0 then return r end
        -- join_code
        r, self.join_code = d:Rstr()
        if r ~= 0 then return r end
        return 0
    end,
    Write = function(self, om)
        local d = om.d
        -- id
        d:Wvi64(self.id)
        -- join_code
        d:Wstr(self.join_code)
    end
}
PKG_Client_Lobby_JoinChatGroup.__index = PKG_Client_Lobby_JoinChatGroup

--[[
发送群聊消息
]]
PKG_Client_Lobby_RequestChatGroupMessage = {
    typeName = "PKG_Client_Lobby_RequestChatGroupMessage",
    typeId = 2095,
    Create = function(o)
        if o == nil then
            o = {}
            setmetatable(o, PKG_Client_Lobby_RequestChatGroupMessage)
        end
        --[[
        群id
        ]]
        o.id = 0 -- Int64
        --[[
        内容
        ]]
        o.content = "" -- String
        return o
    end,
    Read = function(self, om)
        local d = om.d
        local r, n
        -- id
        r, self.id = d:Rvi64()
        if r ~= 0 then return r end
        -- content
        r, self.content = d:Rstr()
        if r ~= 0 then return r end
        return 0
    end,
    Write = function(self, om)
        local d = om.d
        -- id
        d:Wvi64(self.id)
        -- content
        d:Wstr(self.content)
    end
}
PKG_Client_Lobby_RequestChatGroupMessage.__index = PKG_Client_Lobby_RequestChatGroupMessage

--[[
批量查询玩家信息
]]
PKG_Client_Lobby_GetChatPlayerInfo = {
    typeName = "PKG_Client_Lobby_GetChatPlayerInfo",
    typeId = 2085,
    Create = function(o)
        if o == nil then
            o = {}
            setmetatable(o, PKG_Client_Lobby_GetChatPlayerInfo)
        end
        --[[
        账号id列表
        ]]
        o.account_list = {} -- List<Int32>
        return o
    end,
    Read = function(self, om)
        local d = om.d
        local r, n, o
        -- account_list
        r, len = d:Rvu32()
        if len > d:GetLeft() then return -1 end
        o = {}
        self.account_list = o
        for i = 1, len do
            r, o[i] = d:Rvi32()
            if r ~= 0 then return r end
        end
        if r ~= 0 then return r end
        return 0
    end,
    Write = function(self, om)
        local d = om.d
        local o, len
        -- account_list
        o = self.account_list
        len = #o
        d:Wvu32(len)
        for i = 1, len do
            d:Wvi32(o[i])
        end
    end
}
PKG_Client_Lobby_GetChatPlayerInfo.__index = PKG_Client_Lobby_GetChatPlayerInfo

--[[
退出聊天群
]]
PKG_Client_Lobby_QuitChatGroup = {
    typeName = "PKG_Client_Lobby_QuitChatGroup",
    typeId = 2096,
    Create = function(o)
        if o == nil then
            o = {}
            setmetatable(o, PKG_Client_Lobby_QuitChatGroup)
        end
        --[[
        群id
        ]]
        o.id = 0 -- Int64
        return o
    end,
    Read = function(self, om)
        local d = om.d
        local r, n
        -- id
        r, self.id = d:Rvi64()
        if r ~= 0 then return r end
        return 0
    end,
    Write = function(self, om)
        local d = om.d
        -- id
        d:Wvi64(self.id)
    end
}
PKG_Client_Lobby_QuitChatGroup.__index = PKG_Client_Lobby_QuitChatGroup

--[[
退出工会
]]
PKG_Client_Lobby_QuitPromotion = {
    typeName = "PKG_Client_Lobby_QuitPromotion",
    typeId = 2072,
    Create = function(o)
        if o == nil then
            o = {}
            setmetatable(o, PKG_Client_Lobby_QuitPromotion)
        end
        return o
    end,
    Read = function(self, om)
        local d = om.d
        local r, n
        return 0
    end,
    Write = function(self, om)
        local d = om.d
    end
}
PKG_Client_Lobby_QuitPromotion.__index = PKG_Client_Lobby_QuitPromotion

--[[
修改工会头像
]]
PKG_Client_Lobby_ModifyPromotionIcon = {
    typeName = "PKG_Client_Lobby_ModifyPromotionIcon",
    typeId = 2070,
    Create = function(o)
        if o == nil then
            o = {}
            setmetatable(o, PKG_Client_Lobby_ModifyPromotionIcon)
        end
        --[[
        头像id
        ]]
        o.id = 0 -- Int32
        return o
    end,
    Read = function(self, om)
        local d = om.d
        local r, n
        -- id
        r, self.id = d:Rvi32()
        if r ~= 0 then return r end
        return 0
    end,
    Write = function(self, om)
        local d = om.d
        -- id
        d:Wvi32(self.id)
    end
}
PKG_Client_Lobby_ModifyPromotionIcon.__index = PKG_Client_Lobby_ModifyPromotionIcon

--[[
发送消息
]]
PKG_Client_Lobby_SendMessage = {
    typeName = "PKG_Client_Lobby_SendMessage",
    typeId = 2048,
    Create = function(o)
        if o == nil then
            o = {}
            setmetatable(o, PKG_Client_Lobby_SendMessage)
        end
        --[[
        内容
        ]]
        o.content = "" -- String
        --[[
        图片上传后的图片名字
        ]]
        o.image = "" -- String
        --[[
        accountid
        ]]
        o.accountid = 0 -- Int32
        --[[
        用户名
        ]]
        o.username = "" -- String
        return o
    end,
    Read = function(self, om)
        local d = om.d
        local r, n
        -- content
        r, self.content = d:Rstr()
        if r ~= 0 then return r end
        -- image
        r, self.image = d:Rstr()
        if r ~= 0 then return r end
        -- accountid
        r, self.accountid = d:Rvi32()
        if r ~= 0 then return r end
        -- username
        r, self.username = d:Rstr()
        if r ~= 0 then return r end
        return 0
    end,
    Write = function(self, om)
        local d = om.d
        -- content
        d:Wstr(self.content)
        -- image
        d:Wstr(self.image)
        -- accountid
        d:Wvi32(self.accountid)
        -- username
        d:Wstr(self.username)
    end
}
PKG_Client_Lobby_SendMessage.__index = PKG_Client_Lobby_SendMessage

--[[
设置消息为已读
]]
PKG_Client_Lobby_ReadMessage = {
    typeName = "PKG_Client_Lobby_ReadMessage",
    typeId = 2049,
    Create = function(o)
        if o == nil then
            o = {}
            setmetatable(o, PKG_Client_Lobby_ReadMessage)
        end
        --[[
        消息Id
        ]]
        o.id = 0 -- Double
        return o
    end,
    Read = function(self, om)
        local d = om.d
        local r, n
        -- id
        r, self.id = d:Rd()
        if r ~= 0 then return r end
        return 0
    end,
    Write = function(self, om)
        local d = om.d
        -- id
        d:Wd(self.id)
    end
}
PKG_Client_Lobby_ReadMessage.__index = PKG_Client_Lobby_ReadMessage

--[[
获取是否有未读消息
]]
PKG_Client_Lobby_GetUnreadMessage = {
    typeName = "PKG_Client_Lobby_GetUnreadMessage",
    typeId = 2050,
    Create = function(o)
        if o == nil then
            o = {}
            setmetatable(o, PKG_Client_Lobby_GetUnreadMessage)
        end
        return o
    end,
    Read = function(self, om)
        local d = om.d
        local r, n
        return 0
    end,
    Write = function(self, om)
        local d = om.d
    end
}
PKG_Client_Lobby_GetUnreadMessage.__index = PKG_Client_Lobby_GetUnreadMessage

--[[
客服服务评分反馈
]]
PKG_Client_Lobby_CustomerEvaluate = {
    typeName = "PKG_Client_Lobby_CustomerEvaluate",
    typeId = 2051,
    Create = function(o)
        if o == nil then
            o = {}
            setmetatable(o, PKG_Client_Lobby_CustomerEvaluate)
        end
        --[[
        批次
        ]]
        o.questionid = "" -- String
        --[[
        评分
        ]]
        o.score = 0 -- Int32
        --[[
        评价
        ]]
        o.evaluate = "" -- String
        --[[
        联系方式
        ]]
        o.contact = "" -- String
        return o
    end,
    Read = function(self, om)
        local d = om.d
        local r, n
        -- questionid
        r, self.questionid = d:Rstr()
        if r ~= 0 then return r end
        -- score
        r, self.score = d:Rvi32()
        if r ~= 0 then return r end
        -- evaluate
        r, self.evaluate = d:Rstr()
        if r ~= 0 then return r end
        -- contact
        r, self.contact = d:Rstr()
        if r ~= 0 then return r end
        return 0
    end,
    Write = function(self, om)
        local d = om.d
        -- questionid
        d:Wstr(self.questionid)
        -- score
        d:Wvi32(self.score)
        -- evaluate
        d:Wstr(self.evaluate)
        -- contact
        d:Wstr(self.contact)
    end
}
PKG_Client_Lobby_CustomerEvaluate.__index = PKG_Client_Lobby_CustomerEvaluate

--[[
请求充值记录
]]
PKG_Client_Lobby_GetRechargeList = {
    typeName = "PKG_Client_Lobby_GetRechargeList",
    typeId = 2052,
    Create = function(o)
        if o == nil then
            o = {}
            setmetatable(o, PKG_Client_Lobby_GetRechargeList)
        end
        return o
    end,
    Read = function(self, om)
        local d = om.d
        local r, n
        return 0
    end,
    Write = function(self, om)
        local d = om.d
    end
}
PKG_Client_Lobby_GetRechargeList.__index = PKG_Client_Lobby_GetRechargeList

--[[
设置登录账号和密码
]]
PKG_Client_Lobby_SetAccountNameAndPassword = {
    typeName = "PKG_Client_Lobby_SetAccountNameAndPassword",
    typeId = 2053,
    Create = function(o)
        if o == nil then
            o = {}
            setmetatable(o, PKG_Client_Lobby_SetAccountNameAndPassword)
        end
        --[[
        登录账号
        ]]
        o.account_name = "" -- String
        --[[
        登录密码
        ]]
        o.password = "" -- String
        return o
    end,
    Read = function(self, om)
        local d = om.d
        local r, n
        -- account_name
        r, self.account_name = d:Rstr()
        if r ~= 0 then return r end
        -- password
        r, self.password = d:Rstr()
        if r ~= 0 then return r end
        return 0
    end,
    Write = function(self, om)
        local d = om.d
        -- account_name
        d:Wstr(self.account_name)
        -- password
        d:Wstr(self.password)
    end
}
PKG_Client_Lobby_SetAccountNameAndPassword.__index = PKG_Client_Lobby_SetAccountNameAndPassword

--[[
绑定玩家银行卡实名信息
]]
PKG_Client_Lobby_BandingRealNameBankInfo = {
    typeName = "PKG_Client_Lobby_BandingRealNameBankInfo",
    typeId = 2054,
    Create = function(o)
        if o == nil then
            o = {}
            setmetatable(o, PKG_Client_Lobby_BandingRealNameBankInfo)
        end
        --[[
        银行名
        ]]
        o.bankname = "" -- String
        --[[
        真实姓名
        ]]
        o.payer_name = "" -- String
        --[[
        卡号
        ]]
        o.payer_card_number = "" -- String
        return o
    end,
    Read = function(self, om)
        local d = om.d
        local r, n
        -- bankname
        r, self.bankname = d:Rstr()
        if r ~= 0 then return r end
        -- payer_name
        r, self.payer_name = d:Rstr()
        if r ~= 0 then return r end
        -- payer_card_number
        r, self.payer_card_number = d:Rstr()
        if r ~= 0 then return r end
        return 0
    end,
    Write = function(self, om)
        local d = om.d
        -- bankname
        d:Wstr(self.bankname)
        -- payer_name
        d:Wstr(self.payer_name)
        -- payer_card_number
        d:Wstr(self.payer_card_number)
    end
}
PKG_Client_Lobby_BandingRealNameBankInfo.__index = PKG_Client_Lobby_BandingRealNameBankInfo

--[[
绑定玩家手机实名信息
]]
PKG_Client_Lobby_BandingRealNamePhoneInfo = {
    typeName = "PKG_Client_Lobby_BandingRealNamePhoneInfo",
    typeId = 2055,
    Create = function(o)
        if o == nil then
            o = {}
            setmetatable(o, PKG_Client_Lobby_BandingRealNamePhoneInfo)
        end
        --[[
        真实姓名
        ]]
        o.payer_name = "" -- String
        --[[
        手机号
        ]]
        o.phone = "" -- String
        return o
    end,
    Read = function(self, om)
        local d = om.d
        local r, n
        -- payer_name
        r, self.payer_name = d:Rstr()
        if r ~= 0 then return r end
        -- phone
        r, self.phone = d:Rstr()
        if r ~= 0 then return r end
        return 0
    end,
    Write = function(self, om)
        local d = om.d
        -- payer_name
        d:Wstr(self.payer_name)
        -- phone
        d:Wstr(self.phone)
    end
}
PKG_Client_Lobby_BandingRealNamePhoneInfo.__index = PKG_Client_Lobby_BandingRealNamePhoneInfo

--[[
注册临时聊天服务
]]
PKG_Client_Lobby_RegisterTempMsgService = {
    typeName = "PKG_Client_Lobby_RegisterTempMsgService",
    typeId = 2056,
    Create = function(o)
        if o == nil then
            o = {}
            setmetatable(o, PKG_Client_Lobby_RegisterTempMsgService)
        end
        --[[
        accountid
        ]]
        o.accountid = 0 -- Int32
        --[[
        用户名
        ]]
        o.username = "" -- String
        return o
    end,
    Read = function(self, om)
        local d = om.d
        local r, n
        -- accountid
        r, self.accountid = d:Rvi32()
        if r ~= 0 then return r end
        -- username
        r, self.username = d:Rstr()
        if r ~= 0 then return r end
        return 0
    end,
    Write = function(self, om)
        local d = om.d
        -- accountid
        d:Wvi32(self.accountid)
        -- username
        d:Wstr(self.username)
    end
}
PKG_Client_Lobby_RegisterTempMsgService.__index = PKG_Client_Lobby_RegisterTempMsgService

--[[
请求常见问题列表
]]
PKG_Client_Lobby_GetFAQ = {
    typeName = "PKG_Client_Lobby_GetFAQ",
    typeId = 2057,
    Create = function(o)
        if o == nil then
            o = {}
            setmetatable(o, PKG_Client_Lobby_GetFAQ)
        end
        return o
    end,
    Read = function(self, om)
        local d = om.d
        local r, n
        return 0
    end,
    Write = function(self, om)
        local d = om.d
    end
}
PKG_Client_Lobby_GetFAQ.__index = PKG_Client_Lobby_GetFAQ

--[[
修改工会公告
]]
PKG_Client_Lobby_ModifyPromotionDesc = {
    typeName = "PKG_Client_Lobby_ModifyPromotionDesc",
    typeId = 2071,
    Create = function(o)
        if o == nil then
            o = {}
            setmetatable(o, PKG_Client_Lobby_ModifyPromotionDesc)
        end
        --[[
        公告
        ]]
        o.description = "" -- String
        return o
    end,
    Read = function(self, om)
        local d = om.d
        local r, n
        -- description
        r, self.description = d:Rstr()
        if r ~= 0 then return r end
        return 0
    end,
    Write = function(self, om)
        local d = om.d
        -- description
        d:Wstr(self.description)
    end
}
PKG_Client_Lobby_ModifyPromotionDesc.__index = PKG_Client_Lobby_ModifyPromotionDesc

--[[
投诉
]]
PKG_Client_Lobby_NewComplaint = {
    typeName = "PKG_Client_Lobby_NewComplaint",
    typeId = 2058,
    Create = function(o)
        if o == nil then
            o = {}
            setmetatable(o, PKG_Client_Lobby_NewComplaint)
        end
        --[[
        投诉内容
        ]]
        o.content = "" -- String
        --[[
        投诉上传图片名 以;拆分
        ]]
        o.images = "" -- String
        --[[
        玩家真实姓名
        ]]
        o.realname = "" -- String
        --[[
        玩家联系方式
        ]]
        o.phone = "" -- String
        return o
    end,
    Read = function(self, om)
        local d = om.d
        local r, n
        -- content
        r, self.content = d:Rstr()
        if r ~= 0 then return r end
        -- images
        r, self.images = d:Rstr()
        if r ~= 0 then return r end
        -- realname
        r, self.realname = d:Rstr()
        if r ~= 0 then return r end
        -- phone
        r, self.phone = d:Rstr()
        if r ~= 0 then return r end
        return 0
    end,
    Write = function(self, om)
        local d = om.d
        -- content
        d:Wstr(self.content)
        -- images
        d:Wstr(self.images)
        -- realname
        d:Wstr(self.realname)
        -- phone
        d:Wstr(self.phone)
    end
}
PKG_Client_Lobby_NewComplaint.__index = PKG_Client_Lobby_NewComplaint

--[[
提交二维码
]]
PKG_Client_Lobby_UpQRCodeImage = {
    typeName = "PKG_Client_Lobby_UpQRCodeImage",
    typeId = 2060,
    Create = function(o)
        if o == nil then
            o = {}
            setmetatable(o, PKG_Client_Lobby_UpQRCodeImage)
        end
        --[[
        二维码图片名
        ]]
        o.qr_image = "" -- String
        --[[
        银行名
        ]]
        o.bank_name = "" -- String
        return o
    end,
    Read = function(self, om)
        local d = om.d
        local r, n
        -- qr_image
        r, self.qr_image = d:Rstr()
        if r ~= 0 then return r end
        -- bank_name
        r, self.bank_name = d:Rstr()
        if r ~= 0 then return r end
        return 0
    end,
    Write = function(self, om)
        local d = om.d
        -- qr_image
        d:Wstr(self.qr_image)
        -- bank_name
        d:Wstr(self.bank_name)
    end
}
PKG_Client_Lobby_UpQRCodeImage.__index = PKG_Client_Lobby_UpQRCodeImage

--[[
获取支付码
]]
PKG_Client_Lobby_GetPaymentKey = {
    typeName = "PKG_Client_Lobby_GetPaymentKey",
    typeId = 2061,
    Create = function(o)
        if o == nil then
            o = {}
            setmetatable(o, PKG_Client_Lobby_GetPaymentKey)
        end
        return o
    end,
    Read = function(self, om)
        local d = om.d
        local r, n
        return 0
    end,
    Write = function(self, om)
        local d = om.d
    end
}
PKG_Client_Lobby_GetPaymentKey.__index = PKG_Client_Lobby_GetPaymentKey

--[[
大厅PING
]]
PKG_Client_Lobby_Ping = {
    typeName = "PKG_Client_Lobby_Ping",
    typeId = 2062,
    Create = function(o)
        if o == nil then
            o = {}
            setmetatable(o, PKG_Client_Lobby_Ping)
        end
        o.ticks = 0 -- Int64
        return o
    end,
    Read = function(self, om)
        local d = om.d
        local r, n
        -- ticks
        r, self.ticks = d:Rvi64()
        if r ~= 0 then return r end
        return 0
    end,
    Write = function(self, om)
        local d = om.d
        -- ticks
        d:Wvi64(self.ticks)
    end
}
PKG_Client_Lobby_Ping.__index = PKG_Client_Lobby_Ping

--[[
操作保险箱码值
]]
PKG_Client_Lobby_ChangeMoneyGiftSafe = {
    typeName = "PKG_Client_Lobby_ChangeMoneyGiftSafe",
    typeId = 2063,
    Create = function(o)
        if o == nil then
            o = {}
            setmetatable(o, PKG_Client_Lobby_ChangeMoneyGiftSafe)
        end
        --[[
        账号id
        ]]
        o.accountId = 0 -- Int32
        --[[
        金额(>0充值，<0取出)
        ]]
        o.money = 0 -- Double
        return o
    end,
    Read = function(self, om)
        local d = om.d
        local r, n
        -- accountId
        r, self.accountId = d:Rvi32()
        if r ~= 0 then return r end
        -- money
        r, self.money = d:Rd()
        if r ~= 0 then return r end
        return 0
    end,
    Write = function(self, om)
        local d = om.d
        -- accountId
        d:Wvi32(self.accountId)
        -- money
        d:Wd(self.money)
    end
}
PKG_Client_Lobby_ChangeMoneyGiftSafe.__index = PKG_Client_Lobby_ChangeMoneyGiftSafe

--[[
请求每日洗码赠送洗码活动信息
]]
PKG_Client_Lobby_RequestDailyWashcodeActivityInfo = {
    typeName = "PKG_Client_Lobby_RequestDailyWashcodeActivityInfo",
    typeId = 2064,
    Create = function(o)
        if o == nil then
            o = {}
            setmetatable(o, PKG_Client_Lobby_RequestDailyWashcodeActivityInfo)
        end
        return o
    end,
    Read = function(self, om)
        local d = om.d
        local r, n
        return 0
    end,
    Write = function(self, om)
        local d = om.d
    end
}
PKG_Client_Lobby_RequestDailyWashcodeActivityInfo.__index = PKG_Client_Lobby_RequestDailyWashcodeActivityInfo

--[[
领取每日洗码赠送绑定金币
]]
PKG_Client_Lobby_GetDailyWashcode = {
    typeName = "PKG_Client_Lobby_GetDailyWashcode",
    typeId = 2065,
    Create = function(o)
        if o == nil then
            o = {}
            setmetatable(o, PKG_Client_Lobby_GetDailyWashcode)
        end
        return o
    end,
    Read = function(self, om)
        local d = om.d
        local r, n
        return 0
    end,
    Write = function(self, om)
        local d = om.d
    end
}
PKG_Client_Lobby_GetDailyWashcode.__index = PKG_Client_Lobby_GetDailyWashcode

--[[
获取活动状态
]]
PKG_Client_Lobby_GetActivityInfo = {
    typeName = "PKG_Client_Lobby_GetActivityInfo",
    typeId = 2066,
    Create = function(o)
        if o == nil then
            o = {}
            setmetatable(o, PKG_Client_Lobby_GetActivityInfo)
        end
        return o
    end,
    Read = function(self, om)
        local d = om.d
        local r, n
        return 0
    end,
    Write = function(self, om)
        local d = om.d
    end
}
PKG_Client_Lobby_GetActivityInfo.__index = PKG_Client_Lobby_GetActivityInfo

--[[
开始转转盘
]]
PKG_Client_Lobby_StartSpin = {
    typeName = "PKG_Client_Lobby_StartSpin",
    typeId = 2067,
    Create = function(o)
        if o == nil then
            o = {}
            setmetatable(o, PKG_Client_Lobby_StartSpin)
        end
        return o
    end,
    Read = function(self, om)
        local d = om.d
        local r, n
        return 0
    end,
    Write = function(self, om)
        local d = om.d
    end
}
PKG_Client_Lobby_StartSpin.__index = PKG_Client_Lobby_StartSpin

--[[
获取游戏任务信息
]]
PKG_Client_Lobby_GetGameTotalActivityInfo = {
    typeName = "PKG_Client_Lobby_GetGameTotalActivityInfo",
    typeId = 2068,
    Create = function(o)
        if o == nil then
            o = {}
            setmetatable(o, PKG_Client_Lobby_GetGameTotalActivityInfo)
        end
        return o
    end,
    Read = function(self, om)
        local d = om.d
        local r, n
        return 0
    end,
    Write = function(self, om)
        local d = om.d
    end
}
PKG_Client_Lobby_GetGameTotalActivityInfo.__index = PKG_Client_Lobby_GetGameTotalActivityInfo

--[[
领取任务
]]
PKG_Client_Lobby_GetTotalActivityAwards = {
    typeName = "PKG_Client_Lobby_GetTotalActivityAwards",
    typeId = 2069,
    Create = function(o)
        if o == nil then
            o = {}
            setmetatable(o, PKG_Client_Lobby_GetTotalActivityAwards)
        end
        --[[
        任务id
        ]]
        o.activity_id = 0 -- Int32
        return o
    end,
    Read = function(self, om)
        local d = om.d
        local r, n
        -- activity_id
        r, self.activity_id = d:Rvi32()
        if r ~= 0 then return r end
        return 0
    end,
    Write = function(self, om)
        local d = om.d
        -- activity_id
        d:Wvi32(self.activity_id)
    end
}
PKG_Client_Lobby_GetTotalActivityAwards.__index = PKG_Client_Lobby_GetTotalActivityAwards

--[[
申请修改实名制信息
]]
PKG_Client_Lobby_ApplyFixRealname = {
    typeName = "PKG_Client_Lobby_ApplyFixRealname",
    typeId = 2059,
    Create = function(o)
        if o == nil then
            o = {}
            setmetatable(o, PKG_Client_Lobby_ApplyFixRealname)
        end
        --[[
        银行名
        ]]
        o.bankname = "" -- String
        --[[
        真实姓名
        ]]
        o.payer_name = "" -- String
        --[[
        卡号
        ]]
        o.payer_card_number = "" -- String
        --[[
        手机号
        ]]
        o.phone = "" -- String
        return o
    end,
    Read = function(self, om)
        local d = om.d
        local r, n
        -- bankname
        r, self.bankname = d:Rstr()
        if r ~= 0 then return r end
        -- payer_name
        r, self.payer_name = d:Rstr()
        if r ~= 0 then return r end
        -- payer_card_number
        r, self.payer_card_number = d:Rstr()
        if r ~= 0 then return r end
        -- phone
        r, self.phone = d:Rstr()
        if r ~= 0 then return r end
        return 0
    end,
    Write = function(self, om)
        local d = om.d
        -- bankname
        d:Wstr(self.bankname)
        -- payer_name
        d:Wstr(self.payer_name)
        -- payer_card_number
        d:Wstr(self.payer_card_number)
        -- phone
        d:Wstr(self.phone)
    end
}
PKG_Client_Lobby_ApplyFixRealname.__index = PKG_Client_Lobby_ApplyFixRealname

--[[
添加好友
]]
PKG_Client_Lobby_AddFriend = {
    typeName = "PKG_Client_Lobby_AddFriend",
    typeId = 2097,
    Create = function(o)
        if o == nil then
            o = {}
            setmetatable(o, PKG_Client_Lobby_AddFriend)
        end
        --[[
        对方账号id
        ]]
        o.target_id = 0 -- Int32
        return o
    end,
    Read = function(self, om)
        local d = om.d
        local r, n
        -- target_id
        r, self.target_id = d:Rvi32()
        if r ~= 0 then return r end
        return 0
    end,
    Write = function(self, om)
        local d = om.d
        -- target_id
        d:Wvi32(self.target_id)
    end
}
PKG_Client_Lobby_AddFriend.__index = PKG_Client_Lobby_AddFriend

--[[
删除好友
]]
PKG_Client_Lobby_DeleteFriend = {
    typeName = "PKG_Client_Lobby_DeleteFriend",
    typeId = 2098,
    Create = function(o)
        if o == nil then
            o = {}
            setmetatable(o, PKG_Client_Lobby_DeleteFriend)
        end
        --[[
        对方账号id
        ]]
        o.target_id = 0 -- Int32
        return o
    end,
    Read = function(self, om)
        local d = om.d
        local r, n
        -- target_id
        r, self.target_id = d:Rvi32()
        if r ~= 0 then return r end
        return 0
    end,
    Write = function(self, om)
        local d = om.d
        -- target_id
        d:Wvi32(self.target_id)
    end
}
PKG_Client_Lobby_DeleteFriend.__index = PKG_Client_Lobby_DeleteFriend

--[[
验证google token
]]
PKG_Client_Lobby_ClientVerificationGoogle = {
    typeName = "PKG_Client_Lobby_ClientVerificationGoogle",
    typeId = 2099,
    Create = function(o)
        if o == nil then
            o = {}
            setmetatable(o, PKG_Client_Lobby_ClientVerificationGoogle)
        end
        --[[
        google token
        ]]
        o.token = "" -- String
        return o
    end,
    Read = function(self, om)
        local d = om.d
        local r, n
        -- token
        r, self.token = d:Rstr()
        if r ~= 0 then return r end
        return 0
    end,
    Write = function(self, om)
        local d = om.d
        -- token
        d:Wstr(self.token)
    end
}
PKG_Client_Lobby_ClientVerificationGoogle.__index = PKG_Client_Lobby_ClientVerificationGoogle

--[[
请求进游戏 的执行结果( 捕鱼特化版 )
]]
PKG_Lobby_Client_EnterGameCatchFish_Success = {
    typeName = "PKG_Lobby_Client_EnterGameCatchFish_Success", -- : PKG_Lobby_Client_Move_Result
    typeId = 1208,
    Create = function(o)
        if o == nil then
            o = {}
            setmetatable(o, PKG_Lobby_Client_EnterGameCatchFish_Success)
        end
        PKG_Lobby_Client_Move_Result.Create(o)
        o.levels = {} -- List<Shared<PKG.Lobby_Client.GameCatchFish_LevelInfo>>
        return o
    end,
    Read = function(self, om)
        local d = om.d
        local r, n, o
        -- base read
        r = PKG_Lobby_Client_Move_Result.Read(self, om)
        if r ~= 0 then return r end
        -- levels
        r, len = d:Rvu32()
        if len > d:GetLeft() then return -1 end
        o = {}
        self.levels = o
        for i = 1, len do
            r, o[i] = om:Read()
            if r ~= 0 then return r end
        end
        if r ~= 0 then return r end
        return 0
    end,
    Write = function(self, om)
        local d = om.d
        local o, len
        -- base read
        PKG_Lobby_Client_Move_Result.Write(self, om)
        -- levels
        o = self.levels
        len = #o
        d:Wvu32(len)
        for i = 1, len do
            om:Write(o[i])
        end
    end
}
PKG_Lobby_Client_EnterGameCatchFish_Success.__index = PKG_Lobby_Client_EnterGameCatchFish_Success

--[[
有某玩家坐到了某座位上
]]
PKG_Lobby_Client_Events_PlayerSitdown = {
    typeName = "PKG_Lobby_Client_Events_PlayerSitdown",
    typeId = 1217,
    Create = function(o)
        if o == nil then
            o = {}
            setmetatable(o, PKG_Lobby_Client_Events_PlayerSitdown)
        end
        --[[
        目标玩家
        ]]
        o.player = null -- Shared<PKG.Lobby_Client.RoomPlayers>
        --[[
        房间id
        ]]
        o.roomId = 0 -- Int32
        --[[
        座位下标
        ]]
        o.sitIndex = 0 -- Int32
        return o
    end,
    Read = function(self, om)
        local d = om.d
        local r, n
        -- player
        r, self.player = om:Read()
        if r ~= 0 then return r end
        -- roomId
        r, self.roomId = d:Rvi32()
        if r ~= 0 then return r end
        -- sitIndex
        r, self.sitIndex = d:Rvi32()
        if r ~= 0 then return r end
        return 0
    end,
    Write = function(self, om)
        local d = om.d
        -- player
        om:Write(self.player)
        -- roomId
        d:Wvi32(self.roomId)
        -- sitIndex
        d:Wvi32(self.sitIndex)
    end
}
PKG_Lobby_Client_Events_PlayerSitdown.__index = PKG_Lobby_Client_Events_PlayerSitdown

--[[
请求进游戏 的执行结果
]]
PKG_Lobby_Client_EnterGameHuca_Success = {
    typeName = "PKG_Lobby_Client_EnterGameHuca_Success", -- : PKG_Lobby_Client_Move_Result
    typeId = 1210,
    Create = function(o)
        if o == nil then
            o = {}
            setmetatable(o, PKG_Lobby_Client_EnterGameHuca_Success)
        end
        PKG_Lobby_Client_Move_Result.Create(o)
        o.levels = {} -- List<Shared<PKG.Lobby_Client.GameHuca_LevelInfo>>
        return o
    end,
    Read = function(self, om)
        local d = om.d
        local r, n, o
        -- base read
        r = PKG_Lobby_Client_Move_Result.Read(self, om)
        if r ~= 0 then return r end
        -- levels
        r, len = d:Rvu32()
        if len > d:GetLeft() then return -1 end
        o = {}
        self.levels = o
        for i = 1, len do
            r, o[i] = om:Read()
            if r ~= 0 then return r end
        end
        if r ~= 0 then return r end
        return 0
    end,
    Write = function(self, om)
        local d = om.d
        local o, len
        -- base read
        PKG_Lobby_Client_Move_Result.Write(self, om)
        -- levels
        o = self.levels
        len = #o
        d:Wvu32(len)
        for i = 1, len do
            om:Write(o[i])
        end
    end
}
PKG_Lobby_Client_EnterGameHuca_Success.__index = PKG_Lobby_Client_EnterGameHuca_Success

--[[
验证facebook
]]
PKG_Client_Lobby_ClientVerificationFacebook = {
    typeName = "PKG_Client_Lobby_ClientVerificationFacebook",
    typeId = 2041,
    Create = function(o)
        if o == nil then
            o = {}
            setmetatable(o, PKG_Client_Lobby_ClientVerificationFacebook)
        end
        --[[
        token
        ]]
        o.token = "" -- String
        return o
    end,
    Read = function(self, om)
        local d = om.d
        local r, n
        -- token
        r, self.token = d:Rstr()
        if r ~= 0 then return r end
        return 0
    end,
    Write = function(self, om)
        local d = om.d
        -- token
        d:Wstr(self.token)
    end
}
PKG_Client_Lobby_ClientVerificationFacebook.__index = PKG_Client_Lobby_ClientVerificationFacebook

--[[
申请加入工会
]]
PKG_Client_Lobby_ClientBindPromotionCode = {
    typeName = "PKG_Client_Lobby_ClientBindPromotionCode",
    typeId = 2037,
    Create = function(o)
        if o == nil then
            o = {}
            setmetatable(o, PKG_Client_Lobby_ClientBindPromotionCode)
        end
        o.promotion_code = "" -- String
        return o
    end,
    Read = function(self, om)
        local d = om.d
        local r, n
        -- promotion_code
        r, self.promotion_code = d:Rstr()
        if r ~= 0 then return r end
        return 0
    end,
    Write = function(self, om)
        local d = om.d
        -- promotion_code
        d:Wstr(self.promotion_code)
    end
}
PKG_Client_Lobby_ClientBindPromotionCode.__index = PKG_Client_Lobby_ClientBindPromotionCode

--[[
请求进入捕鱼游戏的某个级别 的执行结果
]]
PKG_Lobby_Client_EnterGameCatchFishLevel_Success = {
    typeName = "PKG_Lobby_Client_EnterGameCatchFishLevel_Success", -- : PKG_Lobby_Client_Move_Result
    typeId = 1213,
    Create = function(o)
        if o == nil then
            o = {}
            setmetatable(o, PKG_Lobby_Client_EnterGameCatchFishLevel_Success)
        end
        PKG_Lobby_Client_Move_Result.Create(o)
        o.rooms = {} -- List<Shared<PKG.Lobby_Client.GameCatchFish_RoomInfo>>
        return o
    end,
    Read = function(self, om)
        local d = om.d
        local r, n, o
        -- base read
        r = PKG_Lobby_Client_Move_Result.Read(self, om)
        if r ~= 0 then return r end
        -- rooms
        r, len = d:Rvu32()
        if len > d:GetLeft() then return -1 end
        o = {}
        self.rooms = o
        for i = 1, len do
            r, o[i] = om:Read()
            if r ~= 0 then return r end
        end
        if r ~= 0 then return r end
        return 0
    end,
    Write = function(self, om)
        local d = om.d
        local o, len
        -- base read
        PKG_Lobby_Client_Move_Result.Write(self, om)
        -- rooms
        o = self.rooms
        len = #o
        d:Wvu32(len)
        for i = 1, len do
            om:Write(o[i])
        end
    end
}
PKG_Lobby_Client_EnterGameCatchFishLevel_Success.__index = PKG_Lobby_Client_EnterGameCatchFishLevel_Success

--[[
请求进捕鱼房并坐下 成功
]]
PKG_Lobby_Client_EnterGameCatchFishLevelRoomSit_Success = {
    typeName = "PKG_Lobby_Client_EnterGameCatchFishLevelRoomSit_Success", -- : PKG_Lobby_Client_Move_Result
    typeId = 1214,
    Create = function(o)
        if o == nil then
            o = {}
            setmetatable(o, PKG_Lobby_Client_EnterGameCatchFishLevelRoomSit_Success)
        end
        PKG_Lobby_Client_Move_Result.Create(o)
        --[[
        游戏服Id
        ]]
        o.GameId = 0 -- Int32
        --[[
        服务Id
        ]]
        o.serviceId = 0 -- Int32
        return o
    end,
    Read = function(self, om)
        local d = om.d
        local r, n
        -- base read
        r = PKG_Lobby_Client_Move_Result.Read(self, om)
        if r ~= 0 then return r end
        -- GameId
        r, self.GameId = d:Rvi32()
        if r ~= 0 then return r end
        -- serviceId
        r, self.serviceId = d:Rvi32()
        if r ~= 0 then return r end
        return 0
    end,
    Write = function(self, om)
        local d = om.d
        -- base read
        PKG_Lobby_Client_Move_Result.Write(self, om)
        -- GameId
        d:Wvi32(self.GameId)
        -- serviceId
        d:Wvi32(self.serviceId)
    end
}
PKG_Lobby_Client_EnterGameCatchFishLevelRoomSit_Success.__index = PKG_Lobby_Client_EnterGameCatchFishLevelRoomSit_Success

--[[
请求进入老虎机游戏 成功
]]
PKG_Lobby_Client_EnterGameSlots_Success = {
    typeName = "PKG_Lobby_Client_EnterGameSlots_Success", -- : PKG_Lobby_Client_Move_Result
    typeId = 1215,
    Create = function(o)
        if o == nil then
            o = {}
            setmetatable(o, PKG_Lobby_Client_EnterGameSlots_Success)
        end
        PKG_Lobby_Client_Move_Result.Create(o)
        --[[
        游戏服Id
        ]]
        o.GameId = 0 -- Int32
        --[[
        服务Id
        ]]
        o.serviceId = 0 -- Int32
        return o
    end,
    Read = function(self, om)
        local d = om.d
        local r, n
        -- base read
        r = PKG_Lobby_Client_Move_Result.Read(self, om)
        if r ~= 0 then return r end
        -- GameId
        r, self.GameId = d:Rvi32()
        if r ~= 0 then return r end
        -- serviceId
        r, self.serviceId = d:Rvi32()
        if r ~= 0 then return r end
        return 0
    end,
    Write = function(self, om)
        local d = om.d
        -- base read
        PKG_Lobby_Client_Move_Result.Write(self, om)
        -- GameId
        d:Wvi32(self.GameId)
        -- serviceId
        d:Wvi32(self.serviceId)
    end
}
PKG_Lobby_Client_EnterGameSlots_Success.__index = PKG_Lobby_Client_EnterGameSlots_Success

--[[
断线重连状态恢复请求 成功
]]
PKG_Lobby_Client_Restore_Success = {
    typeName = "PKG_Lobby_Client_Restore_Success", -- : PKG_Lobby_Client_Move_Result
    typeId = 1216,
    Create = function(o)
        if o == nil then
            o = {}
            setmetatable(o, PKG_Lobby_Client_Restore_Success)
        end
        PKG_Lobby_Client_Move_Result.Create(o)
        --[[
        每一个 moves 的成员的返回结果的打包
        ]]
        o.moveResults = {} -- List<Shared<PKG.Lobby_Client.Move_Result>>
        return o
    end,
    Read = function(self, om)
        local d = om.d
        local r, n, o
        -- base read
        r = PKG_Lobby_Client_Move_Result.Read(self, om)
        if r ~= 0 then return r end
        -- moveResults
        r, len = d:Rvu32()
        if len > d:GetLeft() then return -1 end
        o = {}
        self.moveResults = o
        for i = 1, len do
            r, o[i] = om:Read()
            if r ~= 0 then return r end
        end
        if r ~= 0 then return r end
        return 0
    end,
    Write = function(self, om)
        local d = om.d
        local o, len
        -- base read
        PKG_Lobby_Client_Move_Result.Write(self, om)
        -- moveResults
        o = self.moveResults
        len = #o
        d:Wvu32(len)
        for i = 1, len do
            om:Write(o[i])
        end
    end
}
PKG_Lobby_Client_Restore_Success.__index = PKG_Lobby_Client_Restore_Success

--[[
修改昵称 成功
]]
PKG_Lobby_Client_ChangeNickname_Success = {
    typeName = "PKG_Lobby_Client_ChangeNickname_Success",
    typeId = 1219,
    Create = function(o)
        if o == nil then
            o = {}
            setmetatable(o, PKG_Lobby_Client_ChangeNickname_Success)
        end
        --[[
        修改后的昵称
        ]]
        o.nickname = "" -- String
        return o
    end,
    Read = function(self, om)
        local d = om.d
        local r, n
        -- nickname
        r, self.nickname = d:Rstr()
        if r ~= 0 then return r end
        return 0
    end,
    Write = function(self, om)
        local d = om.d
        -- nickname
        d:Wstr(self.nickname)
    end
}
PKG_Lobby_Client_ChangeNickname_Success.__index = PKG_Lobby_Client_ChangeNickname_Success

--[[
获取每日签到信息
]]
PKG_Client_Lobby_Get_SigninGaveInfo = {
    typeName = "PKG_Client_Lobby_Get_SigninGaveInfo",
    typeId = 2042,
    Create = function(o)
        if o == nil then
            o = {}
            setmetatable(o, PKG_Client_Lobby_Get_SigninGaveInfo)
        end
        return o
    end,
    Read = function(self, om)
        local d = om.d
        local r, n
        return 0
    end,
    Write = function(self, om)
        local d = om.d
    end
}
PKG_Client_Lobby_Get_SigninGaveInfo.__index = PKG_Client_Lobby_Get_SigninGaveInfo

--[[
修改头像 成功
]]
PKG_Lobby_Client_ChangeAvatar_Success = {
    typeName = "PKG_Lobby_Client_ChangeAvatar_Success",
    typeId = 1220,
    Create = function(o)
        if o == nil then
            o = {}
            setmetatable(o, PKG_Lobby_Client_ChangeAvatar_Success)
        end
        --[[
        修改后的头像
        ]]
        o.avatar_id = 0 -- Int32
        return o
    end,
    Read = function(self, om)
        local d = om.d
        local r, n
        -- avatar_id
        r, self.avatar_id = d:Rvi32()
        if r ~= 0 then return r end
        return 0
    end,
    Write = function(self, om)
        local d = om.d
        -- avatar_id
        d:Wvi32(self.avatar_id)
    end
}
PKG_Lobby_Client_ChangeAvatar_Success.__index = PKG_Lobby_Client_ChangeAvatar_Success

--[[
获取玩家退款集合
]]
PKG_Lobby_Client_GetRefundList = {
    typeName = "PKG_Lobby_Client_GetRefundList",
    typeId = 1223,
    Create = function(o)
        if o == nil then
            o = {}
            setmetatable(o, PKG_Lobby_Client_GetRefundList)
        end
        o.accountId = 0 -- Int32
        o.refund_List = {} -- List<Shared<PKG.Lobby_Client.RefundInfo>>
        return o
    end,
    Read = function(self, om)
        local d = om.d
        local r, n, o
        -- accountId
        r, self.accountId = d:Rvi32()
        if r ~= 0 then return r end
        -- refund_List
        r, len = d:Rvu32()
        if len > d:GetLeft() then return -1 end
        o = {}
        self.refund_List = o
        for i = 1, len do
            r, o[i] = om:Read()
            if r ~= 0 then return r end
        end
        if r ~= 0 then return r end
        return 0
    end,
    Write = function(self, om)
        local d = om.d
        local o, len
        -- accountId
        d:Wvi32(self.accountId)
        -- refund_List
        o = self.refund_List
        len = #o
        d:Wvu32(len)
        for i = 1, len do
            om:Write(o[i])
        end
    end
}
PKG_Lobby_Client_GetRefundList.__index = PKG_Lobby_Client_GetRefundList

--[[
保险箱充值/取出
]]
PKG_Lobby_Client_ChangeMoneySafe_Success = {
    typeName = "PKG_Lobby_Client_ChangeMoneySafe_Success",
    typeId = 1224,
    Create = function(o)
        if o == nil then
            o = {}
            setmetatable(o, PKG_Lobby_Client_ChangeMoneySafe_Success)
        end
        --[[
        操作后的总金额
        ]]
        o.money = 0 -- Double
        --[[
        操作后的保险箱金额
        ]]
        o.money_safe = 0 -- Double
        --[[
        操作后的总绑定金额
        ]]
        o.money_gift = 0 -- Double
        --[[
        操作后的保险箱绑定金额
        ]]
        o.money_gift_safe = 0 -- Double
        return o
    end,
    Read = function(self, om)
        local d = om.d
        local r, n
        -- money
        r, self.money = d:Rd()
        if r ~= 0 then return r end
        -- money_safe
        r, self.money_safe = d:Rd()
        if r ~= 0 then return r end
        -- money_gift
        r, self.money_gift = d:Rd()
        if r ~= 0 then return r end
        -- money_gift_safe
        r, self.money_gift_safe = d:Rd()
        if r ~= 0 then return r end
        return 0
    end,
    Write = function(self, om)
        local d = om.d
        -- money
        d:Wd(self.money)
        -- money_safe
        d:Wd(self.money_safe)
        -- money_gift
        d:Wd(self.money_gift)
        -- money_gift_safe
        d:Wd(self.money_gift_safe)
    end
}
PKG_Lobby_Client_ChangeMoneySafe_Success.__index = PKG_Lobby_Client_ChangeMoneySafe_Success

--[[
申请代理
]]
PKG_Client_Lobby_ClientApplyPromotion = {
    typeName = "PKG_Client_Lobby_ClientApplyPromotion",
    typeId = 2035,
    Create = function(o)
        if o == nil then
            o = {}
            setmetatable(o, PKG_Client_Lobby_ClientApplyPromotion)
        end
        --[[
        代理名称
        ]]
        o.promotion_name = "" -- String
        return o
    end,
    Read = function(self, om)
        local d = om.d
        local r, n
        -- promotion_name
        r, self.promotion_name = d:Rstr()
        if r ~= 0 then return r end
        return 0
    end,
    Write = function(self, om)
        local d = om.d
        -- promotion_name
        d:Wstr(self.promotion_name)
    end
}
PKG_Client_Lobby_ClientApplyPromotion.__index = PKG_Client_Lobby_ClientApplyPromotion

--[[
排行榜
]]
PKG_Lobby_Client_GetTodayEarnMoneys = {
    typeName = "PKG_Lobby_Client_GetTodayEarnMoneys", -- : PKG_Lobby_Client_TodayEarnMoney
    typeId = 1226,
    Create = function(o)
        if o == nil then
            o = {}
            setmetatable(o, PKG_Lobby_Client_GetTodayEarnMoneys)
        end
        PKG_Lobby_Client_TodayEarnMoney.Create(o)
        --[[
        排行榜
        ]]
        o.todayEarnMoneys = {} -- List<Shared<PKG.Lobby_Client.TodayEarnMoney>>
        return o
    end,
    Read = function(self, om)
        local d = om.d
        local r, n, o
        -- base read
        r = PKG_Lobby_Client_TodayEarnMoney.Read(self, om)
        if r ~= 0 then return r end
        -- todayEarnMoneys
        r, len = d:Rvu32()
        if len > d:GetLeft() then return -1 end
        o = {}
        self.todayEarnMoneys = o
        for i = 1, len do
            r, o[i] = om:Read()
            if r ~= 0 then return r end
        end
        if r ~= 0 then return r end
        return 0
    end,
    Write = function(self, om)
        local d = om.d
        local o, len
        -- base read
        PKG_Lobby_Client_TodayEarnMoney.Write(self, om)
        -- todayEarnMoneys
        o = self.todayEarnMoneys
        len = #o
        d:Wvu32(len)
        for i = 1, len do
            om:Write(o[i])
        end
    end
}
PKG_Lobby_Client_GetTodayEarnMoneys.__index = PKG_Lobby_Client_GetTodayEarnMoneys

--[[
赠送金币
]]
PKG_Client_Lobby_ClientGiftMoney = {
    typeName = "PKG_Client_Lobby_ClientGiftMoney",
    typeId = 2034,
    Create = function(o)
        if o == nil then
            o = {}
            setmetatable(o, PKG_Client_Lobby_ClientGiftMoney)
        end
        --[[
        获赠玩家id
        ]]
        o.account_id = 0 -- Int32
        --[[
        赠送金额
        ]]
        o.money = 0 -- Double
        --[[
        密码
        ]]
        o.content = "" -- String
        return o
    end,
    Read = function(self, om)
        local d = om.d
        local r, n
        -- account_id
        r, self.account_id = d:Rvi32()
        if r ~= 0 then return r end
        -- money
        r, self.money = d:Rd()
        if r ~= 0 then return r end
        -- content
        r, self.content = d:Rstr()
        if r ~= 0 then return r end
        return 0
    end,
    Write = function(self, om)
        local d = om.d
        -- account_id
        d:Wvi32(self.account_id)
        -- money
        d:Wd(self.money)
        -- content
        d:Wstr(self.content)
    end
}
PKG_Client_Lobby_ClientGiftMoney.__index = PKG_Client_Lobby_ClientGiftMoney

--[[
公告列表
]]
PKG_Lobby_Client_GetNotices = {
    typeName = "PKG_Lobby_Client_GetNotices",
    typeId = 1228,
    Create = function(o)
        if o == nil then
            o = {}
            setmetatable(o, PKG_Lobby_Client_GetNotices)
        end
        --[[
        公告
        ]]
        o.Notices = {} -- List<Shared<PKG.Lobby_Client.Notice>>
        --[[
        需要玩家下载的APP的URL
        ]]
        o.appurl = "" -- String
        --[[
        是否显示whats
        ]]
        o.app_switch = 0 -- Int32
        return o
    end,
    Read = function(self, om)
        local d = om.d
        local r, n, o
        -- Notices
        r, len = d:Rvu32()
        if len > d:GetLeft() then return -1 end
        o = {}
        self.Notices = o
        for i = 1, len do
            r, o[i] = om:Read()
            if r ~= 0 then return r end
        end
        if r ~= 0 then return r end
        -- appurl
        r, self.appurl = d:Rstr()
        if r ~= 0 then return r end
        -- app_switch
        r, self.app_switch = d:Rvi32()
        if r ~= 0 then return r end
        return 0
    end,
    Write = function(self, om)
        local d = om.d
        local o, len
        -- Notices
        o = self.Notices
        len = #o
        d:Wvu32(len)
        for i = 1, len do
            om:Write(o[i])
        end
        -- appurl
        d:Wstr(self.appurl)
        -- app_switch
        d:Wvi32(self.app_switch)
    end
}
PKG_Lobby_Client_GetNotices.__index = PKG_Lobby_Client_GetNotices

--[[
获取充值成功后的money
]]
PKG_Lobby_Client_GetRechargeMoney = {
    typeName = "PKG_Lobby_Client_GetRechargeMoney",
    typeId = 1229,
    Create = function(o)
        if o == nil then
            o = {}
            setmetatable(o, PKG_Lobby_Client_GetRechargeMoney)
        end
        o.money = 0 -- Double
        o.money_safe = 0 -- Double
        o.total_recharge = 0 -- Double
        return o
    end,
    Read = function(self, om)
        local d = om.d
        local r, n
        -- money
        r, self.money = d:Rd()
        if r ~= 0 then return r end
        -- money_safe
        r, self.money_safe = d:Rd()
        if r ~= 0 then return r end
        -- total_recharge
        r, self.total_recharge = d:Rd()
        if r ~= 0 then return r end
        return 0
    end,
    Write = function(self, om)
        local d = om.d
        -- money
        d:Wd(self.money)
        -- money_safe
        d:Wd(self.money_safe)
        -- total_recharge
        d:Wd(self.total_recharge)
    end
}
PKG_Lobby_Client_GetRechargeMoney.__index = PKG_Lobby_Client_GetRechargeMoney

--[[
设置赠送密码
]]
PKG_Client_Lobby_ClientGiftPassword = {
    typeName = "PKG_Client_Lobby_ClientGiftPassword",
    typeId = 2033,
    Create = function(o)
        if o == nil then
            o = {}
            setmetatable(o, PKG_Client_Lobby_ClientGiftPassword)
        end
        --[[
        密码
        ]]
        o.content = "" -- String
        return o
    end,
    Read = function(self, om)
        local d = om.d
        local r, n
        -- content
        r, self.content = d:Rstr()
        if r ~= 0 then return r end
        return 0
    end,
    Write = function(self, om)
        local d = om.d
        -- content
        d:Wstr(self.content)
    end
}
PKG_Client_Lobby_ClientGiftPassword.__index = PKG_Client_Lobby_ClientGiftPassword

--[[
获取客户端发起充值后的结果信息
]]
PKG_Client_Lobby_GetClientRechargeResult = {
    typeName = "PKG_Client_Lobby_GetClientRechargeResult",
    typeId = 2032,
    Create = function(o)
        if o == nil then
            o = {}
            setmetatable(o, PKG_Client_Lobby_GetClientRechargeResult)
        end
        --[[
        packageName
        ]]
        o.packageName = "" -- String
        --[[
        productId
        ]]
        o.productId = "" -- String
        --[[
        token
        ]]
        o.token = "" -- String
        --[[
        订单号
        ]]
        o.order_num = "" -- String
        return o
    end,
    Read = function(self, om)
        local d = om.d
        local r, n
        -- packageName
        r, self.packageName = d:Rstr()
        if r ~= 0 then return r end
        -- productId
        r, self.productId = d:Rstr()
        if r ~= 0 then return r end
        -- token
        r, self.token = d:Rstr()
        if r ~= 0 then return r end
        -- order_num
        r, self.order_num = d:Rstr()
        if r ~= 0 then return r end
        return 0
    end,
    Write = function(self, om)
        local d = om.d
        -- packageName
        d:Wstr(self.packageName)
        -- productId
        d:Wstr(self.productId)
        -- token
        d:Wstr(self.token)
        -- order_num
        d:Wstr(self.order_num)
    end
}
PKG_Client_Lobby_GetClientRechargeResult.__index = PKG_Client_Lobby_GetClientRechargeResult

--[[
获取公司网站
]]
PKG_Client_Lobby_GetWebsite = {
    typeName = "PKG_Client_Lobby_GetWebsite",
    typeId = 2031,
    Create = function(o)
        if o == nil then
            o = {}
            setmetatable(o, PKG_Client_Lobby_GetWebsite)
        end
        return o
    end,
    Read = function(self, om)
        local d = om.d
        local r, n
        return 0
    end,
    Write = function(self, om)
        local d = om.d
    end
}
PKG_Client_Lobby_GetWebsite.__index = PKG_Client_Lobby_GetWebsite

--[[
代理信息
]]
PKG_Client_Lobby_ClientPromotion = {
    typeName = "PKG_Client_Lobby_ClientPromotion",
    typeId = 2036,
    Create = function(o)
        if o == nil then
            o = {}
            setmetatable(o, PKG_Client_Lobby_ClientPromotion)
        end
        --[[
        语言(1=中文;2=英文；3=缅文；4=马来文)
        ]]
        o.language = 0 -- Int32
        return o
    end,
    Read = function(self, om)
        local d = om.d
        local r, n
        -- language
        r, self.language = d:Rvi32()
        if r ~= 0 then return r end
        return 0
    end,
    Write = function(self, om)
        local d = om.d
        -- language
        d:Wvi32(self.language)
    end
}
PKG_Client_Lobby_ClientPromotion.__index = PKG_Client_Lobby_ClientPromotion

--[[
请求进入大厅成功(机器人管理者特殊)
]]
PKG_Lobby_Client_Enter_Success_For_RobotManager = {
    typeName = "PKG_Lobby_Client_Enter_Success_For_RobotManager",
    typeId = 1206,
    Create = function(o)
        if o == nil then
            o = {}
            setmetatable(o, PKG_Lobby_Client_Enter_Success_For_RobotManager)
        end
        --[[
        初级场人数
        ]]
        o.primaryLevelNumber = 0 -- Int32
        --[[
        中级场人数
        ]]
        o.centerLevelNumber = 0 -- Int32
        --[[
        高级场人数
        ]]
        o.topLevelNumber = 0 -- Int32
        return o
    end,
    Read = function(self, om)
        local d = om.d
        local r, n
        -- primaryLevelNumber
        r, self.primaryLevelNumber = d:Rvi32()
        if r ~= 0 then return r end
        -- centerLevelNumber
        r, self.centerLevelNumber = d:Rvi32()
        if r ~= 0 then return r end
        -- topLevelNumber
        r, self.topLevelNumber = d:Rvi32()
        if r ~= 0 then return r end
        return 0
    end,
    Write = function(self, om)
        local d = om.d
        -- primaryLevelNumber
        d:Wvi32(self.primaryLevelNumber)
        -- centerLevelNumber
        d:Wvi32(self.centerLevelNumber)
        -- topLevelNumber
        d:Wvi32(self.topLevelNumber)
    end
}
PKG_Lobby_Client_Enter_Success_For_RobotManager.__index = PKG_Lobby_Client_Enter_Success_For_RobotManager

--[[
签到
]]
PKG_Client_Lobby_SigninToDay = {
    typeName = "PKG_Client_Lobby_SigninToDay",
    typeId = 2043,
    Create = function(o)
        if o == nil then
            o = {}
            setmetatable(o, PKG_Client_Lobby_SigninToDay)
        end
        return o
    end,
    Read = function(self, om)
        local d = om.d
        local r, n
        return 0
    end,
    Write = function(self, om)
        local d = om.d
    end
}
PKG_Client_Lobby_SigninToDay.__index = PKG_Client_Lobby_SigninToDay

--[[
玩家信息
]]
PKG_Lobby_Client_UserInfo = {
    typeName = "PKG_Lobby_Client_UserInfo",
    typeId = 1204,
    Create = function(o)
        if o == nil then
            o = {}
            setmetatable(o, PKG_Lobby_Client_UserInfo)
        end
        --[[
        当前玩家自己的信息
        ]]
        o.self = null -- Shared<PKG.ClassDef.selfAccount>
        --[[
        vip
        ]]
        o.vips = {} -- List<Shared<PKG.ClassDef.Vip>>
        return o
    end,
    Read = function(self, om)
        local d = om.d
        local r, n, o
        -- self
        r, self.self = om:Read()
        if r ~= 0 then return r end
        -- vips
        r, len = d:Rvu32()
        if len > d:GetLeft() then return -1 end
        o = {}
        self.vips = o
        for i = 1, len do
            r, o[i] = om:Read()
            if r ~= 0 then return r end
        end
        if r ~= 0 then return r end
        return 0
    end,
    Write = function(self, om)
        local d = om.d
        local o, len
        -- self
        om:Write(self.self)
        -- vips
        o = self.vips
        len = #o
        d:Wvu32(len)
        for i = 1, len do
            om:Write(o[i])
        end
    end
}
PKG_Lobby_Client_UserInfo.__index = PKG_Lobby_Client_UserInfo

--[[
验证apple token
]]
PKG_Client_Lobby_ClientVerificationApple = {
    typeName = "PKG_Client_Lobby_ClientVerificationApple",
    typeId = 2100,
    Create = function(o)
        if o == nil then
            o = {}
            setmetatable(o, PKG_Client_Lobby_ClientVerificationApple)
        end
        --[[
        apple token
        ]]
        o.token = "" -- String
        return o
    end,
    Read = function(self, om)
        local d = om.d
        local r, n
        -- token
        r, self.token = d:Rstr()
        if r ~= 0 then return r end
        return 0
    end,
    Write = function(self, om)
        local d = om.d
        -- token
        d:Wstr(self.token)
    end
}
PKG_Client_Lobby_ClientVerificationApple.__index = PKG_Client_Lobby_ClientVerificationApple

--[[
获取聊天系统公告
]]
PKG_Client_Lobby_ClientGetChatNotice = {
    typeName = "PKG_Client_Lobby_ClientGetChatNotice",
    typeId = 2101,
    Create = function(o)
        if o == nil then
            o = {}
            setmetatable(o, PKG_Client_Lobby_ClientGetChatNotice)
        end
        return o
    end,
    Read = function(self, om)
        local d = om.d
        local r, n
        return 0
    end,
    Write = function(self, om)
        local d = om.d
    end
}
PKG_Client_Lobby_ClientGetChatNotice.__index = PKG_Client_Lobby_ClientGetChatNotice

--[[
绑定虚拟币钱包地址
]]
PKG_Client_Lobby_BindVirtualCoinAddress = {
    typeName = "PKG_Client_Lobby_BindVirtualCoinAddress",
    typeId = 2102,
    Create = function(o)
        if o == nil then
            o = {}
            setmetatable(o, PKG_Client_Lobby_BindVirtualCoinAddress)
        end
        --[[
        渠道id
        ]]
        o.pay_channel_id = 0 -- Int32
        --[[
        虚拟币地址
        ]]
        o.virtual_coin_address = "" -- String
        return o
    end,
    Read = function(self, om)
        local d = om.d
        local r, n
        -- pay_channel_id
        r, self.pay_channel_id = d:Rvi32()
        if r ~= 0 then return r end
        -- virtual_coin_address
        r, self.virtual_coin_address = d:Rstr()
        if r ~= 0 then return r end
        return 0
    end,
    Write = function(self, om)
        local d = om.d
        -- pay_channel_id
        d:Wvi32(self.pay_channel_id)
        -- virtual_coin_address
        d:Wstr(self.virtual_coin_address)
    end
}
PKG_Client_Lobby_BindVirtualCoinAddress.__index = PKG_Client_Lobby_BindVirtualCoinAddress

--[[
获取洗码返利活动信息
]]
PKG_Client_Lobby_GetWashCodeActivityInfo = {
    typeName = "PKG_Client_Lobby_GetWashCodeActivityInfo",
    typeId = 2103,
    Create = function(o)
        if o == nil then
            o = {}
            setmetatable(o, PKG_Client_Lobby_GetWashCodeActivityInfo)
        end
        --[[
        活动id
        ]]
        o.activity_id = 0 -- Int32
        return o
    end,
    Read = function(self, om)
        local d = om.d
        local r, n
        -- activity_id
        r, self.activity_id = d:Rvi32()
        if r ~= 0 then return r end
        return 0
    end,
    Write = function(self, om)
        local d = om.d
        -- activity_id
        d:Wvi32(self.activity_id)
    end
}
PKG_Client_Lobby_GetWashCodeActivityInfo.__index = PKG_Client_Lobby_GetWashCodeActivityInfo

--[[
领取洗码奖励
]]
PKG_Client_Lobby_ReceiveWashcodeActivity = {
    typeName = "PKG_Client_Lobby_ReceiveWashcodeActivity",
    typeId = 2104,
    Create = function(o)
        if o == nil then
            o = {}
            setmetatable(o, PKG_Client_Lobby_ReceiveWashcodeActivity)
        end
        --[[
        活动id
        ]]
        o.activity_id = 0 -- Int32
        return o
    end,
    Read = function(self, om)
        local d = om.d
        local r, n
        -- activity_id
        r, self.activity_id = d:Rvi32()
        if r ~= 0 then return r end
        return 0
    end,
    Write = function(self, om)
        local d = om.d
        -- activity_id
        d:Wvi32(self.activity_id)
    end
}
PKG_Client_Lobby_ReceiveWashcodeActivity.__index = PKG_Client_Lobby_ReceiveWashcodeActivity

--[[
获取当前玩家详细信息
]]
PKG_Client_Lobby_GetPlayerInfo = {
    typeName = "PKG_Client_Lobby_GetPlayerInfo",
    typeId = 2105,
    Create = function(o)
        if o == nil then
            o = {}
            setmetatable(o, PKG_Client_Lobby_GetPlayerInfo)
        end
        return o
    end,
    Read = function(self, om)
        local d = om.d
        local r, n
        return 0
    end,
    Write = function(self, om)
        local d = om.d
    end
}
PKG_Client_Lobby_GetPlayerInfo.__index = PKG_Client_Lobby_GetPlayerInfo

--[[
获取当前银商私聊按钮状态
]]
PKG_Client_Lobby_GetBusinessmanPrivateMsgButtons = {
    typeName = "PKG_Client_Lobby_GetBusinessmanPrivateMsgButtons",
    typeId = 2106,
    Create = function(o)
        if o == nil then
            o = {}
            setmetatable(o, PKG_Client_Lobby_GetBusinessmanPrivateMsgButtons)
        end
        return o
    end,
    Read = function(self, om)
        local d = om.d
        local r, n
        return 0
    end,
    Write = function(self, om)
        local d = om.d
    end
}
PKG_Client_Lobby_GetBusinessmanPrivateMsgButtons.__index = PKG_Client_Lobby_GetBusinessmanPrivateMsgButtons

--[[
获取公共频道聊天记录 每分页 最大30条
]]
PKG_Client_Lobby_GetPublicMessages = {
    typeName = "PKG_Client_Lobby_GetPublicMessages",
    typeId = 2107,
    Create = function(o)
        if o == nil then
            o = {}
            setmetatable(o, PKG_Client_Lobby_GetPublicMessages)
        end
        --[[
        公屏0 其他数组为群 id
        ]]
        o.channel_id = 0 -- Int64
        --[[
        分页 公式为 limit {page}*30,30
        ]]
        o.page = 0 -- UInt32
        return o
    end,
    Read = function(self, om)
        local d = om.d
        local r, n
        -- channel_id
        r, self.channel_id = d:Rvi64()
        if r ~= 0 then return r end
        -- page
        r, self.page = d:Rvu32()
        if r ~= 0 then return r end
        return 0
    end,
    Write = function(self, om)
        local d = om.d
        -- channel_id
        d:Wvi64(self.channel_id)
        -- page
        d:Wvu32(self.page)
    end
}
PKG_Client_Lobby_GetPublicMessages.__index = PKG_Client_Lobby_GetPublicMessages

--[[
获取私聊聊天记录 每分页 最大30条
]]
PKG_Client_Lobby_GetPrivateMessages = {
    typeName = "PKG_Client_Lobby_GetPrivateMessages",
    typeId = 2108,
    Create = function(o)
        if o == nil then
            o = {}
            setmetatable(o, PKG_Client_Lobby_GetPrivateMessages)
        end
        --[[
        对方的账号 id
        ]]
        o.target_id = 0 -- Int32
        --[[
        分页 公式为 limit {page}*30,30
        ]]
        o.page = 0 -- UInt32
        return o
    end,
    Read = function(self, om)
        local d = om.d
        local r, n
        -- target_id
        r, self.target_id = d:Rvi32()
        if r ~= 0 then return r end
        -- page
        r, self.page = d:Rvu32()
        if r ~= 0 then return r end
        return 0
    end,
    Write = function(self, om)
        local d = om.d
        -- target_id
        d:Wvi32(self.target_id)
        -- page
        d:Wvu32(self.page)
    end
}
PKG_Client_Lobby_GetPrivateMessages.__index = PKG_Client_Lobby_GetPrivateMessages

--[[
测试账号请求旋转转盘
]]
PKG_Client_Lobby_StartSpinExperience = {
    typeName = "PKG_Client_Lobby_StartSpinExperience",
    typeId = 2109,
    Create = function(o)
        if o == nil then
            o = {}
            setmetatable(o, PKG_Client_Lobby_StartSpinExperience)
        end
        return o
    end,
    Read = function(self, om)
        local d = om.d
        local r, n
        return 0
    end,
    Write = function(self, om)
        local d = om.d
    end
}
PKG_Client_Lobby_StartSpinExperience.__index = PKG_Client_Lobby_StartSpinExperience

--[[
领取救济金
]]
PKG_Client_Lobby_GiveReliefMoney = {
    typeName = "PKG_Client_Lobby_GiveReliefMoney",
    typeId = 2110,
    Create = function(o)
        if o == nil then
            o = {}
            setmetatable(o, PKG_Client_Lobby_GiveReliefMoney)
        end
        return o
    end,
    Read = function(self, om)
        local d = om.d
        local r, n
        return 0
    end,
    Write = function(self, om)
        local d = om.d
    end
}
PKG_Client_Lobby_GiveReliefMoney.__index = PKG_Client_Lobby_GiveReliefMoney

--[[
发送手机号验证码
]]
PKG_Client_Lobby_SendPhoneVerificationCode = {
    typeName = "PKG_Client_Lobby_SendPhoneVerificationCode",
    typeId = 2111,
    Create = function(o)
        if o == nil then
            o = {}
            setmetatable(o, PKG_Client_Lobby_SendPhoneVerificationCode)
        end
        --[[
        手机号
        ]]
        o.phone_number = "" -- String
        return o
    end,
    Read = function(self, om)
        local d = om.d
        local r, n
        -- phone_number
        r, self.phone_number = d:Rstr()
        if r ~= 0 then return r end
        return 0
    end,
    Write = function(self, om)
        local d = om.d
        -- phone_number
        d:Wstr(self.phone_number)
    end
}
PKG_Client_Lobby_SendPhoneVerificationCode.__index = PKG_Client_Lobby_SendPhoneVerificationCode

--[[
绑定手机号
]]
PKG_Client_Lobby_BindPhoneNumber = {
    typeName = "PKG_Client_Lobby_BindPhoneNumber",
    typeId = 2112,
    Create = function(o)
        if o == nil then
            o = {}
            setmetatable(o, PKG_Client_Lobby_BindPhoneNumber)
        end
        --[[
        验证码
        ]]
        o.code = "" -- String
        return o
    end,
    Read = function(self, om)
        local d = om.d
        local r, n
        -- code
        r, self.code = d:Rstr()
        if r ~= 0 then return r end
        return 0
    end,
    Write = function(self, om)
        local d = om.d
        -- code
        d:Wstr(self.code)
    end
}
PKG_Client_Lobby_BindPhoneNumber.__index = PKG_Client_Lobby_BindPhoneNumber

--[[
发送邮箱验证码
]]
PKG_Client_Lobby_SendEmailVerificationCode = {
    typeName = "PKG_Client_Lobby_SendEmailVerificationCode",
    typeId = 2113,
    Create = function(o)
        if o == nil then
            o = {}
            setmetatable(o, PKG_Client_Lobby_SendEmailVerificationCode)
        end
        --[[
        邮箱
        ]]
        o.email = "" -- String
        return o
    end,
    Read = function(self, om)
        local d = om.d
        local r, n
        -- email
        r, self.email = d:Rstr()
        if r ~= 0 then return r end
        return 0
    end,
    Write = function(self, om)
        local d = om.d
        -- email
        d:Wstr(self.email)
    end
}
PKG_Client_Lobby_SendEmailVerificationCode.__index = PKG_Client_Lobby_SendEmailVerificationCode

--[[
绑定邮箱
]]
PKG_Client_Lobby_BindEMailNumber = {
    typeName = "PKG_Client_Lobby_BindEMailNumber",
    typeId = 2114,
    Create = function(o)
        if o == nil then
            o = {}
            setmetatable(o, PKG_Client_Lobby_BindEMailNumber)
        end
        --[[
        验证码
        ]]
        o.code = "" -- String
        return o
    end,
    Read = function(self, om)
        local d = om.d
        local r, n
        -- code
        r, self.code = d:Rstr()
        if r ~= 0 then return r end
        return 0
    end,
    Write = function(self, om)
        local d = om.d
        -- code
        d:Wstr(self.code)
    end
}
PKG_Client_Lobby_BindEMailNumber.__index = PKG_Client_Lobby_BindEMailNumber

--[[
获取砍一刀存档
]]
PKG_Client_Lobby_GetAssistanceStore = {
    typeName = "PKG_Client_Lobby_GetAssistanceStore",
    typeId = 2115,
    Create = function(o)
        if o == nil then
            o = {}
            setmetatable(o, PKG_Client_Lobby_GetAssistanceStore)
        end
        return o
    end,
    Read = function(self, om)
        local d = om.d
        local r, n
        return 0
    end,
    Write = function(self, om)
        local d = om.d
    end
}
PKG_Client_Lobby_GetAssistanceStore.__index = PKG_Client_Lobby_GetAssistanceStore

--[[
存储砍一刀存档
]]
PKG_Client_Lobby_SaveAssistanceStore = {
    typeName = "PKG_Client_Lobby_SaveAssistanceStore",
    typeId = 2116,
    Create = function(o)
        if o == nil then
            o = {}
            setmetatable(o, PKG_Client_Lobby_SaveAssistanceStore)
        end
        --[[
        存档信息
        ]]
        o.context = "" -- String
        return o
    end,
    Read = function(self, om)
        local d = om.d
        local r, n
        -- context
        r, self.context = d:Rstr()
        if r ~= 0 then return r end
        return 0
    end,
    Write = function(self, om)
        local d = om.d
        -- context
        d:Wstr(self.context)
    end
}
PKG_Client_Lobby_SaveAssistanceStore.__index = PKG_Client_Lobby_SaveAssistanceStore

--[[
获取砍一刀信息
]]
PKG_Client_Lobby_GetAssistanceInfo = {
    typeName = "PKG_Client_Lobby_GetAssistanceInfo",
    typeId = 2117,
    Create = function(o)
        if o == nil then
            o = {}
            setmetatable(o, PKG_Client_Lobby_GetAssistanceInfo)
        end
        --[[
        活动id
        ]]
        o.activity_id = 0 -- Int32
        return o
    end,
    Read = function(self, om)
        local d = om.d
        local r, n
        -- activity_id
        r, self.activity_id = d:Rvi32()
        if r ~= 0 then return r end
        return 0
    end,
    Write = function(self, om)
        local d = om.d
        -- activity_id
        d:Wvi32(self.activity_id)
    end
}
PKG_Client_Lobby_GetAssistanceInfo.__index = PKG_Client_Lobby_GetAssistanceInfo

--[[
砍一刀助力
]]
PKG_Client_Lobby_AssistanceToUser = {
    typeName = "PKG_Client_Lobby_AssistanceToUser",
    typeId = 2118,
    Create = function(o)
        if o == nil then
            o = {}
            setmetatable(o, PKG_Client_Lobby_AssistanceToUser)
        end
        --[[
        对方id
        ]]
        o.target_id = 0 -- Int32
        --[[
        活动id
        ]]
        o.activity_id = 0 -- Int32
        return o
    end,
    Read = function(self, om)
        local d = om.d
        local r, n
        -- target_id
        r, self.target_id = d:Rvi32()
        if r ~= 0 then return r end
        -- activity_id
        r, self.activity_id = d:Rvi32()
        if r ~= 0 then return r end
        return 0
    end,
    Write = function(self, om)
        local d = om.d
        -- target_id
        d:Wvi32(self.target_id)
        -- activity_id
        d:Wvi32(self.activity_id)
    end
}
PKG_Client_Lobby_AssistanceToUser.__index = PKG_Client_Lobby_AssistanceToUser

--[[
提交审核 如果返回ERROR:活动没开,人数不够,重复提交
]]
PKG_Client_Lobby_RequestActivityAssistanceExamine = {
    typeName = "PKG_Client_Lobby_RequestActivityAssistanceExamine",
    typeId = 2119,
    Create = function(o)
        if o == nil then
            o = {}
            setmetatable(o, PKG_Client_Lobby_RequestActivityAssistanceExamine)
        end
        --[[
        活动id
        ]]
        o.activity_id = 0 -- Int32
        return o
    end,
    Read = function(self, om)
        local d = om.d
        local r, n
        -- activity_id
        r, self.activity_id = d:Rvi32()
        if r ~= 0 then return r end
        return 0
    end,
    Write = function(self, om)
        local d = om.d
        -- activity_id
        d:Wvi32(self.activity_id)
    end
}
PKG_Client_Lobby_RequestActivityAssistanceExamine.__index = PKG_Client_Lobby_RequestActivityAssistanceExamine

--[[
客户端充值生成订单后，提交付款人信息
]]
PKG_Client_Lobby_ClientRechargeRequestPayerInfo = {
    typeName = "PKG_Client_Lobby_ClientRechargeRequestPayerInfo",
    typeId = 2045,
    Create = function(o)
        if o == nil then
            o = {}
            setmetatable(o, PKG_Client_Lobby_ClientRechargeRequestPayerInfo)
        end
        --[[
        订单号
        ]]
        o.order_num = "" -- String
        --[[
        付款人姓名
        ]]
        o.payer_name = "" -- String
        --[[
        付款方式
        ]]
        o.payer_type = "" -- String
        --[[
        付款人卡号
        ]]
        o.payer_cardnumber = "" -- String
        --[[
        上游订单号
        ]]
        o.upstream_order_num = "" -- String
        return o
    end,
    Read = function(self, om)
        local d = om.d
        local r, n
        -- order_num
        r, self.order_num = d:Rstr()
        if r ~= 0 then return r end
        -- payer_name
        r, self.payer_name = d:Rstr()
        if r ~= 0 then return r end
        -- payer_type
        r, self.payer_type = d:Rstr()
        if r ~= 0 then return r end
        -- payer_cardnumber
        r, self.payer_cardnumber = d:Rstr()
        if r ~= 0 then return r end
        -- upstream_order_num
        r, self.upstream_order_num = d:Rstr()
        if r ~= 0 then return r end
        return 0
    end,
    Write = function(self, om)
        local d = om.d
        -- order_num
        d:Wstr(self.order_num)
        -- payer_name
        d:Wstr(self.payer_name)
        -- payer_type
        d:Wstr(self.payer_type)
        -- payer_cardnumber
        d:Wstr(self.payer_cardnumber)
        -- upstream_order_num
        d:Wstr(self.upstream_order_num)
    end
}
PKG_Client_Lobby_ClientRechargeRequestPayerInfo.__index = PKG_Client_Lobby_ClientRechargeRequestPayerInfo

--[[
请求进入大厅成功
]]
PKG_Lobby_Client_Enter_Success = {
    typeName = "PKG_Lobby_Client_Enter_Success", -- : PKG_Lobby_Client_Move_Result
    typeId = 1202,
    Create = function(o)
        if o == nil then
            o = {}
            setmetatable(o, PKG_Lobby_Client_Enter_Success)
        end
        PKG_Lobby_Client_Move_Result.Create(o)
        --[[
        游戏id列表
        ]]
        o.gameIds = {} -- List<Int32>
        --[[
        当前玩家自己的信息
        ]]
        o.self = null -- Shared<PKG.ClassDef.selfAccount>
        --[[
        vip
        ]]
        o.vips = {} -- List<Shared<PKG.ClassDef.Vip>>
        --[[
        官网
        ]]
        o.website = "" -- String
        --[[
        老虎机游戏level集合
        ]]
        o.gameEntryConditionsList = {} -- List<Shared<PKG.Lobby_Client.GameEntryConditions>>
        --[[
        是否开启代理服务 1=开启 0=关闭
        ]]
        o.is_open_promotion = 0 -- Int32
        --[[
        金币和真钱比例 1000 表示 1真钱=1000游戏币
        ]]
        o.money_exchange_coin = 0 -- Int32
        --[[
        聊天服URL
        ]]
        o.contact_service = "" -- String
        --[[
        图片上传URL
        ]]
        o.upload_image_path = "" -- String
        --[[
        功能硬性开关
        ]]
        o.botton_configs = {} -- List<Shared<PKG.Lobby_Client.button_settings>>
        --[[
        version
        ]]
        o.versioninfo = "" -- String
        --[[
        实名制开关 0=关 1=开
        ]]
        o.is_open_realname_mode = 0 -- Int32
        --[[
        游戏类型排序 1=海王 2=昌盛 3=老虎机 123=海王+昌盛+老虎的顺序
        ]]
        o.gameTypeSort = "" -- String
        --[[
        最少赠送金币
        ]]
        o.gift_min_money = 0 -- Double
        --[[
        赠送最少自身保留金币
        ]]
        o.gift_min_remain_money = 0 -- Double
        --[[
        码值等级
        ]]
        o.gift_cfg = {} -- List<Shared<PKG.ClassDef.gift_cfg>>
        --[[
        活动开关集合
        ]]
        o.activity_status = {} -- List<Shared<PKG.Lobby_Client.Activity_Status>>
        --[[
        首充开关 1=开 0=关
        ]]
        o.is_open_first_rechange_washcode = 0 -- Int32
        --[[
        首充送多少绑定金币
        ]]
        o.first_rechange_washcode = 0 -- Double
        --[[
        首充送绑金最低档金币
        ]]
        o.first_rechage_washcode_min_money = 0 -- Double
        --[[
        是否有资格转盘 0=没 1=有
        ]]
        o.is_spin = 0 -- Int32
        --[[
        转盘值列表
        ]]
        o.spin_array = {} -- List<Int64>
        --[[
        是否能领充值福利 0=不能 1=能
        ]]
        o.is_welfare = 0 -- Int32
        --[[
        是否有工会聊天界面
        ]]
        o.has_promotion_msg_win = 0 -- Int32
        --[[
        是否有群聊界面
        ]]
        o.has_chat_group_win = 0 -- Int32
        --[[
        银行卡账号和虚拟币账号资产可切换阀值,玩家资产小于此值,可切换账号A.B状态
        ]]
        o.virtual_coin_status_switch_money = 0 -- Double
        --[[
        活动赠送类型 0=绑定金币 1=金币
        ]]
        o.activity_give_type = 0 -- Int32
        --[[
        是否有资格旋转测试号转盘 0=没 1=有
        ]]
        o.is_experience_spin = 0 -- Int32
        --[[
        测试号转盘值列表
        ]]
        o.experience_spin_array = {} -- List<Int64>
        --[[
        测试号否能领取救济金 0=没 1=有
        ]]
        o.is_experience_relief_money = 0 -- Int32
        --[[
        测试号是否打开充值和退款
        ]]
        o.is_experience_open_recharge_and_refund = 0 -- Int32
        --[[
        是否启用邮箱验证
        ]]
        o.is_open_email_bind = 0 -- Int32
        --[[
        绑定账号密码送
        ]]
        o.bind_account_money_gift = 0 -- Double
        --[[
        最大赠送金币
        ]]
        o.gift_max_money = 0 -- Double
        --[[
        赠送手续费
        ]]
        o.gift_fee = 0 -- Double
        --[[
        赠送模式 0=银商才能赠送,1=无限制
        ]]
        o.gift_money_mode = 0 -- Int32
        return o
    end,
    Read = function(self, om)
        local d = om.d
        local r, n, o
        -- base read
        r = PKG_Lobby_Client_Move_Result.Read(self, om)
        if r ~= 0 then return r end
        -- gameIds
        r, len = d:Rvu32()
        if len > d:GetLeft() then return -1 end
        o = {}
        self.gameIds = o
        for i = 1, len do
            r, o[i] = d:Rvi32()
            if r ~= 0 then return r end
        end
        if r ~= 0 then return r end
        -- self
        r, self.self = om:Read()
        if r ~= 0 then return r end
        -- vips
        r, len = d:Rvu32()
        if len > d:GetLeft() then return -1 end
        o = {}
        self.vips = o
        for i = 1, len do
            r, o[i] = om:Read()
            if r ~= 0 then return r end
        end
        if r ~= 0 then return r end
        -- website
        r, self.website = d:Rstr()
        if r ~= 0 then return r end
        -- gameEntryConditionsList
        r, len = d:Rvu32()
        if len > d:GetLeft() then return -1 end
        o = {}
        self.gameEntryConditionsList = o
        for i = 1, len do
            r, o[i] = om:Read()
            if r ~= 0 then return r end
        end
        if r ~= 0 then return r end
        -- is_open_promotion
        r, self.is_open_promotion = d:Rvi32()
        if r ~= 0 then return r end
        -- money_exchange_coin
        r, self.money_exchange_coin = d:Rvi32()
        if r ~= 0 then return r end
        -- contact_service
        r, self.contact_service = d:Rstr()
        if r ~= 0 then return r end
        -- upload_image_path
        r, self.upload_image_path = d:Rstr()
        if r ~= 0 then return r end
        -- botton_configs
        r, len = d:Rvu32()
        if len > d:GetLeft() then return -1 end
        o = {}
        self.botton_configs = o
        for i = 1, len do
            r, o[i] = om:Read()
            if r ~= 0 then return r end
        end
        if r ~= 0 then return r end
        -- versioninfo
        r, self.versioninfo = d:Rstr()
        if r ~= 0 then return r end
        -- is_open_realname_mode
        r, self.is_open_realname_mode = d:Rvi32()
        if r ~= 0 then return r end
        -- gameTypeSort
        r, self.gameTypeSort = d:Rstr()
        if r ~= 0 then return r end
        -- gift_min_money
        r, self.gift_min_money = d:Rd()
        if r ~= 0 then return r end
        -- gift_min_remain_money
        r, self.gift_min_remain_money = d:Rd()
        if r ~= 0 then return r end
        -- gift_cfg
        r, len = d:Rvu32()
        if len > d:GetLeft() then return -1 end
        o = {}
        self.gift_cfg = o
        for i = 1, len do
            r, o[i] = om:Read()
            if r ~= 0 then return r end
        end
        if r ~= 0 then return r end
        -- activity_status
        r, len = d:Rvu32()
        if len > d:GetLeft() then return -1 end
        o = {}
        self.activity_status = o
        for i = 1, len do
            r, o[i] = om:Read()
            if r ~= 0 then return r end
        end
        if r ~= 0 then return r end
        -- is_open_first_rechange_washcode
        r, self.is_open_first_rechange_washcode = d:Rvi32()
        if r ~= 0 then return r end
        -- first_rechange_washcode
        r, self.first_rechange_washcode = d:Rd()
        if r ~= 0 then return r end
        -- first_rechage_washcode_min_money
        r, self.first_rechage_washcode_min_money = d:Rd()
        if r ~= 0 then return r end
        -- is_spin
        r, self.is_spin = d:Rvi32()
        if r ~= 0 then return r end
        -- spin_array
        r, len = d:Rvu32()
        if len > d:GetLeft() then return -1 end
        o = {}
        self.spin_array = o
        for i = 1, len do
            r, o[i] = d:Rvi64()
            if r ~= 0 then return r end
        end
        if r ~= 0 then return r end
        -- is_welfare
        r, self.is_welfare = d:Rvi32()
        if r ~= 0 then return r end
        -- has_promotion_msg_win
        r, self.has_promotion_msg_win = d:Rvi32()
        if r ~= 0 then return r end
        -- has_chat_group_win
        r, self.has_chat_group_win = d:Rvi32()
        if r ~= 0 then return r end
        -- virtual_coin_status_switch_money
        r, self.virtual_coin_status_switch_money = d:Rd()
        if r ~= 0 then return r end
        -- activity_give_type
        r, self.activity_give_type = d:Rvi32()
        if r ~= 0 then return r end
        -- is_experience_spin
        r, self.is_experience_spin = d:Rvi32()
        if r ~= 0 then return r end
        -- experience_spin_array
        r, len = d:Rvu32()
        if len > d:GetLeft() then return -1 end
        o = {}
        self.experience_spin_array = o
        for i = 1, len do
            r, o[i] = d:Rvi64()
            if r ~= 0 then return r end
        end
        if r ~= 0 then return r end
        -- is_experience_relief_money
        r, self.is_experience_relief_money = d:Rvi32()
        if r ~= 0 then return r end
        -- is_experience_open_recharge_and_refund
        r, self.is_experience_open_recharge_and_refund = d:Rvi32()
        if r ~= 0 then return r end
        -- is_open_email_bind
        r, self.is_open_email_bind = d:Rvi32()
        if r ~= 0 then return r end
        -- bind_account_money_gift
        r, self.bind_account_money_gift = d:Rd()
        if r ~= 0 then return r end
        -- gift_max_money
        r, self.gift_max_money = d:Rd()
        if r ~= 0 then return r end
        -- gift_fee
        r, self.gift_fee = d:Rd()
        if r ~= 0 then return r end
        -- gift_money_mode
        r, self.gift_money_mode = d:Rvi32()
        if r ~= 0 then return r end
        return 0
    end,
    Write = function(self, om)
        local d = om.d
        local o, len
        -- base read
        PKG_Lobby_Client_Move_Result.Write(self, om)
        -- gameIds
        o = self.gameIds
        len = #o
        d:Wvu32(len)
        for i = 1, len do
            d:Wvi32(o[i])
        end
        -- self
        om:Write(self.self)
        -- vips
        o = self.vips
        len = #o
        d:Wvu32(len)
        for i = 1, len do
            om:Write(o[i])
        end
        -- website
        d:Wstr(self.website)
        -- gameEntryConditionsList
        o = self.gameEntryConditionsList
        len = #o
        d:Wvu32(len)
        for i = 1, len do
            om:Write(o[i])
        end
        -- is_open_promotion
        d:Wvi32(self.is_open_promotion)
        -- money_exchange_coin
        d:Wvi32(self.money_exchange_coin)
        -- contact_service
        d:Wstr(self.contact_service)
        -- upload_image_path
        d:Wstr(self.upload_image_path)
        -- botton_configs
        o = self.botton_configs
        len = #o
        d:Wvu32(len)
        for i = 1, len do
            om:Write(o[i])
        end
        -- versioninfo
        d:Wstr(self.versioninfo)
        -- is_open_realname_mode
        d:Wvi32(self.is_open_realname_mode)
        -- gameTypeSort
        d:Wstr(self.gameTypeSort)
        -- gift_min_money
        d:Wd(self.gift_min_money)
        -- gift_min_remain_money
        d:Wd(self.gift_min_remain_money)
        -- gift_cfg
        o = self.gift_cfg
        len = #o
        d:Wvu32(len)
        for i = 1, len do
            om:Write(o[i])
        end
        -- activity_status
        o = self.activity_status
        len = #o
        d:Wvu32(len)
        for i = 1, len do
            om:Write(o[i])
        end
        -- is_open_first_rechange_washcode
        d:Wvi32(self.is_open_first_rechange_washcode)
        -- first_rechange_washcode
        d:Wd(self.first_rechange_washcode)
        -- first_rechage_washcode_min_money
        d:Wd(self.first_rechage_washcode_min_money)
        -- is_spin
        d:Wvi32(self.is_spin)
        -- spin_array
        o = self.spin_array
        len = #o
        d:Wvu32(len)
        for i = 1, len do
            d:Wvi64(o[i])
        end
        -- is_welfare
        d:Wvi32(self.is_welfare)
        -- has_promotion_msg_win
        d:Wvi32(self.has_promotion_msg_win)
        -- has_chat_group_win
        d:Wvi32(self.has_chat_group_win)
        -- virtual_coin_status_switch_money
        d:Wd(self.virtual_coin_status_switch_money)
        -- activity_give_type
        d:Wvi32(self.activity_give_type)
        -- is_experience_spin
        d:Wvi32(self.is_experience_spin)
        -- experience_spin_array
        o = self.experience_spin_array
        len = #o
        d:Wvu32(len)
        for i = 1, len do
            d:Wvi64(o[i])
        end
        -- is_experience_relief_money
        d:Wvi32(self.is_experience_relief_money)
        -- is_experience_open_recharge_and_refund
        d:Wvi32(self.is_experience_open_recharge_and_refund)
        -- is_open_email_bind
        d:Wvi32(self.is_open_email_bind)
        -- bind_account_money_gift
        d:Wd(self.bind_account_money_gift)
        -- gift_max_money
        d:Wd(self.gift_max_money)
        -- gift_fee
        d:Wd(self.gift_fee)
        -- gift_money_mode
        d:Wvi32(self.gift_money_mode)
    end
}
PKG_Lobby_Client_Enter_Success.__index = PKG_Lobby_Client_Enter_Success

--[[
玩家赠送记录
]]
PKG_Client_Lobby_ClientGiftRecord = {
    typeName = "PKG_Client_Lobby_ClientGiftRecord",
    typeId = 2044,
    Create = function(o)
        if o == nil then
            o = {}
            setmetatable(o, PKG_Client_Lobby_ClientGiftRecord)
        end
        return o
    end,
    Read = function(self, om)
        local d = om.d
        local r, n
        return 0
    end,
    Write = function(self, om)
        local d = om.d
    end
}
PKG_Client_Lobby_ClientGiftRecord.__index = PKG_Client_Lobby_ClientGiftRecord

--[[
获取当前位置
]]
PKG_Client_Lobby_GetPlace = {
    typeName = "PKG_Client_Lobby_GetPlace",
    typeId = 2046,
    Create = function(o)
        if o == nil then
            o = {}
            setmetatable(o, PKG_Client_Lobby_GetPlace)
        end
        return o
    end,
    Read = function(self, om)
        local d = om.d
        local r, n
        return 0
    end,
    Write = function(self, om)
        local d = om.d
    end
}
PKG_Client_Lobby_GetPlace.__index = PKG_Client_Lobby_GetPlace

--[[
有某玩家离开了某座位
]]
PKG_Lobby_Client_Events_PlayerStandup = {
    typeName = "PKG_Lobby_Client_Events_PlayerStandup",
    typeId = 1218,
    Create = function(o)
        if o == nil then
            o = {}
            setmetatable(o, PKG_Lobby_Client_Events_PlayerStandup)
        end
        --[[
        房间id
        ]]
        o.roomId = 0 -- Int32
        --[[
        座位下标
        ]]
        o.sitIndex = 0 -- Int32
        return o
    end,
    Read = function(self, om)
        local d = om.d
        local r, n
        -- roomId
        r, self.roomId = d:Rvi32()
        if r ~= 0 then return r end
        -- sitIndex
        r, self.sitIndex = d:Rvi32()
        if r ~= 0 then return r end
        return 0
    end,
    Write = function(self, om)
        local d = om.d
        -- roomId
        d:Wvi32(self.roomId)
        -- sitIndex
        d:Wvi32(self.sitIndex)
    end
}
PKG_Lobby_Client_Events_PlayerStandup.__index = PKG_Lobby_Client_Events_PlayerStandup

--[[
聊天用户信息
]]
PKG_Lobby_Client_GroupMemberInfo = {
    typeName = "PKG_Lobby_Client_GroupMemberInfo",
    Create = function(o)
        if o == nil then
            o = {}
            setmetatable(o, PKG_Lobby_Client_GroupMemberInfo)
        end
        --[[
        用户id
        ]]
        o.account_id = 0 -- Int32
        --[[
        用户VIP等级
        ]]
        o.vip_level = 0 -- Int32
        --[[
        头像id
        ]]
        o.avatar_id = 0 -- Int32
        --[[
        昵称
        ]]
        o.nickname = "" -- String
        --[[
        金币
        ]]
        o.money = 0 -- Double
        --[[
        权限 0=普通成员 1=群主 2=管理
        ]]
        o.authority = 0 -- Int32
        --[[
        当前是否在线 1=在线 0=不在线
        ]]
        o.is_online = 0 -- Int32
        --[[
        是否禁言 1=禁言
        ]]
        o.state = 0 -- Int32
        return o
    end,
    Read = function(self, om)
        local d = om.d
        local r, n
        -- account_id
        r, self.account_id = d:Rvi32()
        if r ~= 0 then return r end
        -- vip_level
        r, self.vip_level = d:Rvi32()
        if r ~= 0 then return r end
        -- avatar_id
        r, self.avatar_id = d:Rvi32()
        if r ~= 0 then return r end
        -- nickname
        r, self.nickname = d:Rstr()
        if r ~= 0 then return r end
        -- money
        r, self.money = d:Rd()
        if r ~= 0 then return r end
        -- authority
        r, self.authority = d:Rvi32()
        if r ~= 0 then return r end
        -- is_online
        r, self.is_online = d:Rvi32()
        if r ~= 0 then return r end
        -- state
        r, self.state = d:Rvi32()
        if r ~= 0 then return r end
        return 0
    end,
    Write = function(self, om)
        local d = om.d
        -- account_id
        d:Wvi32(self.account_id)
        -- vip_level
        d:Wvi32(self.vip_level)
        -- avatar_id
        d:Wvi32(self.avatar_id)
        -- nickname
        d:Wstr(self.nickname)
        -- money
        d:Wd(self.money)
        -- authority
        d:Wvi32(self.authority)
        -- is_online
        d:Wvi32(self.is_online)
        -- state
        d:Wvi32(self.state)
    end
}
PKG_Lobby_Client_GroupMemberInfo.__index = PKG_Lobby_Client_GroupMemberInfo

--[[
银商公告
]]
PKG_Lobby_Client_BusinessManNotice = {
    typeName = "PKG_Lobby_Client_BusinessManNotice",
    Create = function(o)
        if o == nil then
            o = {}
            setmetatable(o, PKG_Lobby_Client_BusinessManNotice)
        end
        --[[
        时间戳
        ]]
        o.time = 0 -- Int64
        --[[
        发件人
        ]]
        o.source_id = 0 -- Int32
        --[[
        头像id
        ]]
        o.source_avatar_id = 0 -- Int32
        --[[
        昵称
        ]]
        o.source_nickname = "" -- String
        --[[
        内容
        ]]
        o.content = "" -- String
        return o
    end,
    Read = function(self, om)
        local d = om.d
        local r, n
        -- time
        r, self.time = d:Rvi64()
        if r ~= 0 then return r end
        -- source_id
        r, self.source_id = d:Rvi32()
        if r ~= 0 then return r end
        -- source_avatar_id
        r, self.source_avatar_id = d:Rvi32()
        if r ~= 0 then return r end
        -- source_nickname
        r, self.source_nickname = d:Rstr()
        if r ~= 0 then return r end
        -- content
        r, self.content = d:Rstr()
        if r ~= 0 then return r end
        return 0
    end,
    Write = function(self, om)
        local d = om.d
        -- time
        d:Wvi64(self.time)
        -- source_id
        d:Wvi32(self.source_id)
        -- source_avatar_id
        d:Wvi32(self.source_avatar_id)
        -- source_nickname
        d:Wstr(self.source_nickname)
        -- content
        d:Wstr(self.content)
    end
}
PKG_Lobby_Client_BusinessManNotice.__index = PKG_Lobby_Client_BusinessManNotice

--[[
聊天群
]]
PKG_Lobby_Client_ChatGroup = {
    typeName = "PKG_Lobby_Client_ChatGroup",
    Create = function(o)
        if o == nil then
            o = {}
            setmetatable(o, PKG_Lobby_Client_ChatGroup)
        end
        --[[
        群id
        ]]
        o.id = 0 -- Int64
        --[[
        群名称
        ]]
        o.name = "" -- String
        --[[
        人数
        ]]
        o.member_count = 0 -- Int32
        --[[
        是否需要邀请码 0==没有 1=有
        ]]
        o.has_join_code = 0 -- Int32
        return o
    end,
    Read = function(self, om)
        local d = om.d
        local r, n
        -- id
        r, self.id = d:Rvi64()
        if r ~= 0 then return r end
        -- name
        r, self.name = d:Rstr()
        if r ~= 0 then return r end
        -- member_count
        r, self.member_count = d:Rvi32()
        if r ~= 0 then return r end
        -- has_join_code
        r, self.has_join_code = d:Rvi32()
        if r ~= 0 then return r end
        return 0
    end,
    Write = function(self, om)
        local d = om.d
        -- id
        d:Wvi64(self.id)
        -- name
        d:Wstr(self.name)
        -- member_count
        d:Wvi32(self.member_count)
        -- has_join_code
        d:Wvi32(self.has_join_code)
    end
}
PKG_Lobby_Client_ChatGroup.__index = PKG_Lobby_Client_ChatGroup

--[[
聊天用户信息
]]
PKG_Lobby_Client_ChatPlayerInfo = {
    typeName = "PKG_Lobby_Client_ChatPlayerInfo",
    Create = function(o)
        if o == nil then
            o = {}
            setmetatable(o, PKG_Lobby_Client_ChatPlayerInfo)
        end
        --[[
        用户id
        ]]
        o.account_id = 0 -- Int32
        --[[
        用户VIP等级
        ]]
        o.vip_level = 0 -- Int32
        --[[
        头像id
        ]]
        o.avatar_id = 0 -- Int32
        --[[
        昵称
        ]]
        o.nickname = "" -- String
        --[[
        金币
        ]]
        o.money = 0 -- Double
        --[[
        是否是商人 1=商人 0不是
        ]]
        o.is_businessman = 0 -- Int32
        --[[
        当前是否在线 1=在线 0=不在线
        ]]
        o.is_online = 0 -- Int32
        return o
    end,
    Read = function(self, om)
        local d = om.d
        local r, n
        -- account_id
        r, self.account_id = d:Rvi32()
        if r ~= 0 then return r end
        -- vip_level
        r, self.vip_level = d:Rvi32()
        if r ~= 0 then return r end
        -- avatar_id
        r, self.avatar_id = d:Rvi32()
        if r ~= 0 then return r end
        -- nickname
        r, self.nickname = d:Rstr()
        if r ~= 0 then return r end
        -- money
        r, self.money = d:Rd()
        if r ~= 0 then return r end
        -- is_businessman
        r, self.is_businessman = d:Rvi32()
        if r ~= 0 then return r end
        -- is_online
        r, self.is_online = d:Rvi32()
        if r ~= 0 then return r end
        return 0
    end,
    Write = function(self, om)
        local d = om.d
        -- account_id
        d:Wvi32(self.account_id)
        -- vip_level
        d:Wvi32(self.vip_level)
        -- avatar_id
        d:Wvi32(self.avatar_id)
        -- nickname
        d:Wstr(self.nickname)
        -- money
        d:Wd(self.money)
        -- is_businessman
        d:Wvi32(self.is_businessman)
        -- is_online
        d:Wvi32(self.is_online)
    end
}
PKG_Lobby_Client_ChatPlayerInfo.__index = PKG_Lobby_Client_ChatPlayerInfo

--[[
群发用户
]]
PKG_Lobby_Client_MassUser = {
    typeName = "PKG_Lobby_Client_MassUser",
    Create = function(o)
        if o == nil then
            o = {}
            setmetatable(o, PKG_Lobby_Client_MassUser)
        end
        --[[
        用户id
        ]]
        o.account_id = 0 -- Int32
        --[[
        用户VIP等级
        ]]
        o.vip_level = 0 -- Int32
        --[[
        当前是否在线 1=在线 0=不在线
        ]]
        o.is_online = 0 -- Int32
        --[[
        最后登录时间
        ]]
        o.last_online_time = 0 -- Int64
        return o
    end,
    Read = function(self, om)
        local d = om.d
        local r, n
        -- account_id
        r, self.account_id = d:Rvi32()
        if r ~= 0 then return r end
        -- vip_level
        r, self.vip_level = d:Rvi32()
        if r ~= 0 then return r end
        -- is_online
        r, self.is_online = d:Rvi32()
        if r ~= 0 then return r end
        -- last_online_time
        r, self.last_online_time = d:Rvi64()
        if r ~= 0 then return r end
        return 0
    end,
    Write = function(self, om)
        local d = om.d
        -- account_id
        d:Wvi32(self.account_id)
        -- vip_level
        d:Wvi32(self.vip_level)
        -- is_online
        d:Wvi32(self.is_online)
        -- last_online_time
        d:Wvi64(self.last_online_time)
    end
}
PKG_Lobby_Client_MassUser.__index = PKG_Lobby_Client_MassUser

local o = ObjMgr
o.Register(PKG_Lobby_Client_Move_Result)
o.Register(PKG_Client_Lobby_Move)
o.Register(PKG_Lobby_Client_PayChannelAccount)
o.Register(PKG_Lobby_Client_RoomPlayers)
o.Register(PKG_Lobby_Client_PayChannel)
o.Register(PKG_Lobby_Client_EntryConditions)
o.Register(PKG_Lobby_Client_Activity_Status)
o.Register(PKG_Lobby_Client_PromotionUser)
o.Register(PKG_Lobby_Client_PromotionProfit)
o.Register(PKG_Lobby_Client_PromotionDetail)
o.Register(PKG_Lobby_Client_MoneyChanged)
o.Register(PKG_Lobby_Client_google_money)
o.Register(PKG_Lobby_Client_config_channel_money)
o.Register(PKG_Lobby_Client_PrivateMessage)
o.Register(PKG_Lobby_Client_Notice)
o.Register(PKG_Lobby_Client_TodayEarnMoney)
o.Register(PKG_Lobby_Client_RefundInfo)
o.Register(PKG_Lobby_Client_Marquee_Marquee)
o.Register(PKG_Lobby_Client_GameCatchFish_RoomInfo)
o.Register(PKG_Lobby_Client_GameCatchFish_LevelInfo)
o.Register(PKG_Lobby_Client_vip_channel)
o.Register(PKG_Lobby_Client_PromotionInfo)
o.Register(PKG_Lobby_Client_log_gift_money_to_account)
o.Register(PKG_Lobby_Client_PublicMessage)
o.Register(PKG_Lobby_Client_ChatMessage)
o.Register(PKG_Lobby_Client_apple_money)
o.Register(PKG_Lobby_Client_everyday_signin_monery_config)
o.Register(PKG_Lobby_Client_ReceviceSettlementLog)
o.Register(PKG_Lobby_Client_AccountActivityStatus)
o.Register(PKG_Lobby_Client_DailyWashcodeActivityLevel)
o.Register(PKG_Lobby_Client_FAQItem)
o.Register(PKG_Lobby_Client_RechargeInfo)
o.Register(PKG_Lobby_Client_button_settings)
o.Register(PKG_Lobby_Client_GameEntryConditions)
o.Register(PKG_Lobby_Client_SettlementMember)
o.Register(PKG_Lobby_Client_Message)
o.Register(PKG_Lobby_Client_GameHuca_LevelInfo)
o.Register(PKG_Client_Lobby_Enter)
o.Register(PKG_Client_Lobby_Chat)
o.Register(PKG_Lobby_Client_ChangePayChannelBank_Success)
o.Register(PKG_Lobby_Client_UnLockAccount)
o.Register(PKG_Client_Lobby_GetNotice)
o.Register(PKG_Lobby_Client_AllMessage)
o.Register(PKG_Lobby_Client_UnreadMessage)
o.Register(PKG_Lobby_Client_ClosedCustomerQuestion)
o.Register(PKG_Client_Lobby_ChangeMoneySafe)
o.Register(PKG_Lobby_Client_RechargetInfoList)
o.Register(PKG_Client_Lobby_ChangeReadState)
o.Register(PKG_Client_Lobby_GetMessage)
o.Register(PKG_Lobby_Client_RegisterTempMsgServiceResult)
o.Register(PKG_Client_Lobby_GetTodayEarnMoney)
o.Register(PKG_Lobby_Client_FAQList)
o.Register(PKG_Lobby_Client_UpdateRealName)
o.Register(PKG_Lobby_Client_PaymentKeyResult)
o.Register(PKG_Lobby_Client_Pong)
o.Register(PKG_Client_Lobby_GetRefundList)
o.Register(PKG_Lobby_Client_DailyWashcodeActivityInfo)
o.Register(PKG_Client_Lobby_Refund)
o.Register(PKG_Lobby_Client_GetDailyWashcodeInfo)
o.Register(PKG_Lobby_Client_ResponeActivityInfo)
o.Register(PKG_Lobby_Client_BandingRealNameResult)
o.Register(PKG_Lobby_Client_GetPlaceRet)
o.Register(PKG_Lobby_Client_ReceivedGiftRecord)
o.Register(PKG_Lobby_Client_ResponeSpinInfo)
o.Register(PKG_Client_Lobby_ClientRechargeRequest)
o.Register(PKG_Lobby_Client_RefundResultMoneyChanged)
o.Register(PKG_Lobby_Client_FormalRegistMoney)
o.Register(PKG_Lobby_Client_ClientRechargeRequestSuccess)
o.Register(PKG_Lobby_Client_Website)
o.Register(PKG_Lobby_Client_ClientRechargeResult)
o.Register(PKG_Lobby_Client_OtherDeviceLogin)
o.Register(PKG_Lobby_Client_GiftMoneyResult)
o.Register(PKG_Lobby_Client_ReceivedMoneyResult)
o.Register(PKG_Lobby_Client_ApplyPromotionResult)
o.Register(PKG_Lobby_Client_ReceivedPromotion)
o.Register(PKG_Client_Lobby_GetFormalRegistMoney)
o.Register(PKG_Client_Lobby_GetRefundInfo)
o.Register(PKG_Client_Lobby_GetRecharge)
o.Register(PKG_Lobby_Client_QuitPromotionResult)
o.Register(PKG_Client_Lobby_ChangePayChannelBank)
o.Register(PKG_Lobby_Client_VerificationFacebook_Success)
o.Register(PKG_Client_Lobby_ChangePayChannelAlipay)
o.Register(PKG_Lobby_Client_EverydaySigninInfo)
o.Register(PKG_Lobby_Client_SigninToDayResult)
o.Register(PKG_Client_Lobby_GetMarquee)
o.Register(PKG_Lobby_Client_ReturnLobby)
o.Register(PKG_Client_Lobby_ChangePassword)
o.Register(PKG_Lobby_Client_ResponeGameTotalActivityAwards)
o.Register(PKG_Lobby_Client_BindPhone_Success)
o.Register(PKG_Lobby_Client_ResponseChatNotice)
o.Register(PKG_Lobby_Client_ResponseBindVirtualCoinAddress)
o.Register(PKG_Lobby_Client_ResponseWashcodeActivityInfo)
o.Register(PKG_Lobby_Client_ResponseReceiveWashcodeActivity)
o.Register(PKG_Lobby_Client_ReqPlayerInfo)
o.Register(PKG_Lobby_Client_ResponseBusinessmanPrivateMsgButtons)
o.Register(PKG_Lobby_Client_UpdateBusinessmanPrivateMsgButtons)
o.Register(PKG_Lobby_Client_ResponsePublicMessages)
o.Register(PKG_Lobby_Client_ResponsePrivateMessages)
o.Register(PKG_Lobby_Client_SpinExperienceResult)
o.Register(PKG_Lobby_Client_GiveReliefMoneyResult)
o.Register(PKG_Lobby_Client_UpdateExperienceStatus)
o.Register(PKG_Lobby_Client_BindPhoneNumberResult)
o.Register(PKG_Lobby_Client_BindEmailResult)
o.Register(PKG_Lobby_Client_GetAssistanceStoreResult)
o.Register(PKG_Lobby_Client_GetAssistanceInfoResult)
o.Register(PKG_Lobby_Client_AssistanceToUserResult)
o.Register(PKG_Lobby_Client_AssistanceToYou)
o.Register(PKG_Lobby_Client_Marquee_GetGMMarquees)
o.Register(PKG_Lobby_Client_Marquee_CatchFishMarquees)
o.Register(PKG_Lobby_Client_VerificationAppleSuccess)
o.Register(PKG_Lobby_Client_VerificationGoogleSuccess)
o.Register(PKG_Lobby_Client_ChatGroupMemberSet)
o.Register(PKG_Lobby_Client_DisbandChatGroup)
o.Register(PKG_Lobby_Client_PromotionSettlementInfo)
o.Register(PKG_Client_Lobby_ChangeAvatar)
o.Register(PKG_Lobby_Client_ReceiveSettlementResult)
o.Register(PKG_Lobby_Client_GetReceviceSettlementLogResult)
o.Register(PKG_Client_Lobby_ChangeNickname)
o.Register(PKG_Lobby_Client_RequestWelfareStatus)
o.Register(PKG_Client_Lobby_OwnInfo)
o.Register(PKG_Client_Lobby_Restore)
o.Register(PKG_Lobby_Client_RequestPromotionChatAuthority)
o.Register(PKG_Lobby_Client_PrivateChatMessages)
o.Register(PKG_Lobby_Client_ResponeGameTotalActivityInfo)
o.Register(PKG_Client_Lobby_ReturnUp)
o.Register(PKG_Lobby_Client_PromotionUsers)
o.Register(PKG_Client_Lobby_EnterGameCatchFishLevelRoomSit)
o.Register(PKG_Lobby_Client_ResponseChatPlayerInfos)
o.Register(PKG_Lobby_Client_ResponseFriends)
o.Register(PKG_Client_Lobby_EnterGameCatchFishLevel)
o.Register(PKG_Lobby_Client_ResponseChatGroups)
o.Register(PKG_Lobby_Client_ResponseChatGroupInfo)
o.Register(PKG_Client_Lobby_EnterGame)
o.Register(PKG_Lobby_Client_ChatGroupMembersInfo)
o.Register(PKG_Lobby_Client_ChatGroupMessage)
o.Register(PKG_Lobby_Client_BusinessmanMassUsers)
o.Register(PKG_Lobby_Client_GetRefundInfo)
o.Register(PKG_Client_Lobby_Login_out)
o.Register(PKG_Lobby_Client_GetRecharges)
o.Register(PKG_Client_Lobby_ReceiveSettlement)
o.Register(PKG_Client_Lobby_GetReceviceSettlementLog)
o.Register(PKG_Client_Lobby_RequestWelfare)
o.Register(PKG_Client_Lobby_GetAppleRechargeResult)
o.Register(PKG_Client_Lobby_RequestChatMessage)
o.Register(PKG_Client_Lobby_GetPromotionAuthority)
o.Register(PKG_Client_Lobby_SetPromotionAuthority)
o.Register(PKG_Client_Lobby_GetPrivateOffLineChatMessage)
o.Register(PKG_Client_Lobby_GetBusinessmanMassUsers)
o.Register(PKG_Client_Lobby_SendMassMessage)
o.Register(PKG_Client_Lobby_GetPromotionSettlementInfo)
o.Register(PKG_Client_Lobby_GetPromotionUsers)
o.Register(PKG_Client_Lobby_GetFriends)
o.Register(PKG_Client_Lobby_GetChatGroups)
o.Register(PKG_Client_Lobby_CreateChatGroup)
o.Register(PKG_Client_Lobby_GetChatGroupInfo)
o.Register(PKG_Client_Lobby_GetChatGroupMember)
o.Register(PKG_Client_Lobby_EditGroupInfo)
o.Register(PKG_Client_Lobby_GroupAdminMemberSet)
o.Register(PKG_Client_Lobby_DisbandGroup)
o.Register(PKG_Client_Lobby_JoinChatGroup)
o.Register(PKG_Client_Lobby_RequestChatGroupMessage)
o.Register(PKG_Client_Lobby_GetChatPlayerInfo)
o.Register(PKG_Client_Lobby_QuitChatGroup)
o.Register(PKG_Client_Lobby_QuitPromotion)
o.Register(PKG_Client_Lobby_ModifyPromotionIcon)
o.Register(PKG_Client_Lobby_SendMessage)
o.Register(PKG_Client_Lobby_ReadMessage)
o.Register(PKG_Client_Lobby_GetUnreadMessage)
o.Register(PKG_Client_Lobby_CustomerEvaluate)
o.Register(PKG_Client_Lobby_GetRechargeList)
o.Register(PKG_Client_Lobby_SetAccountNameAndPassword)
o.Register(PKG_Client_Lobby_BandingRealNameBankInfo)
o.Register(PKG_Client_Lobby_BandingRealNamePhoneInfo)
o.Register(PKG_Client_Lobby_RegisterTempMsgService)
o.Register(PKG_Client_Lobby_GetFAQ)
o.Register(PKG_Client_Lobby_ModifyPromotionDesc)
o.Register(PKG_Client_Lobby_NewComplaint)
o.Register(PKG_Client_Lobby_UpQRCodeImage)
o.Register(PKG_Client_Lobby_GetPaymentKey)
o.Register(PKG_Client_Lobby_Ping)
o.Register(PKG_Client_Lobby_ChangeMoneyGiftSafe)
o.Register(PKG_Client_Lobby_RequestDailyWashcodeActivityInfo)
o.Register(PKG_Client_Lobby_GetDailyWashcode)
o.Register(PKG_Client_Lobby_GetActivityInfo)
o.Register(PKG_Client_Lobby_StartSpin)
o.Register(PKG_Client_Lobby_GetGameTotalActivityInfo)
o.Register(PKG_Client_Lobby_GetTotalActivityAwards)
o.Register(PKG_Client_Lobby_ApplyFixRealname)
o.Register(PKG_Client_Lobby_AddFriend)
o.Register(PKG_Client_Lobby_DeleteFriend)
o.Register(PKG_Client_Lobby_ClientVerificationGoogle)
o.Register(PKG_Lobby_Client_EnterGameCatchFish_Success)
o.Register(PKG_Lobby_Client_Events_PlayerSitdown)
o.Register(PKG_Lobby_Client_EnterGameHuca_Success)
o.Register(PKG_Client_Lobby_ClientVerificationFacebook)
o.Register(PKG_Client_Lobby_ClientBindPromotionCode)
o.Register(PKG_Lobby_Client_EnterGameCatchFishLevel_Success)
o.Register(PKG_Lobby_Client_EnterGameCatchFishLevelRoomSit_Success)
o.Register(PKG_Lobby_Client_EnterGameSlots_Success)
o.Register(PKG_Lobby_Client_Restore_Success)
o.Register(PKG_Lobby_Client_ChangeNickname_Success)
o.Register(PKG_Client_Lobby_Get_SigninGaveInfo)
o.Register(PKG_Lobby_Client_ChangeAvatar_Success)
o.Register(PKG_Lobby_Client_GetRefundList)
o.Register(PKG_Lobby_Client_ChangeMoneySafe_Success)
o.Register(PKG_Client_Lobby_ClientApplyPromotion)
o.Register(PKG_Lobby_Client_GetTodayEarnMoneys)
o.Register(PKG_Client_Lobby_ClientGiftMoney)
o.Register(PKG_Lobby_Client_GetNotices)
o.Register(PKG_Lobby_Client_GetRechargeMoney)
o.Register(PKG_Client_Lobby_ClientGiftPassword)
o.Register(PKG_Client_Lobby_GetClientRechargeResult)
o.Register(PKG_Client_Lobby_GetWebsite)
o.Register(PKG_Client_Lobby_ClientPromotion)
o.Register(PKG_Lobby_Client_Enter_Success_For_RobotManager)
o.Register(PKG_Client_Lobby_SigninToDay)
o.Register(PKG_Lobby_Client_UserInfo)
o.Register(PKG_Client_Lobby_ClientVerificationApple)
o.Register(PKG_Client_Lobby_ClientGetChatNotice)
o.Register(PKG_Client_Lobby_BindVirtualCoinAddress)
o.Register(PKG_Client_Lobby_GetWashCodeActivityInfo)
o.Register(PKG_Client_Lobby_ReceiveWashcodeActivity)
o.Register(PKG_Client_Lobby_GetPlayerInfo)
o.Register(PKG_Client_Lobby_GetBusinessmanPrivateMsgButtons)
o.Register(PKG_Client_Lobby_GetPublicMessages)
o.Register(PKG_Client_Lobby_GetPrivateMessages)
o.Register(PKG_Client_Lobby_StartSpinExperience)
o.Register(PKG_Client_Lobby_GiveReliefMoney)
o.Register(PKG_Client_Lobby_SendPhoneVerificationCode)
o.Register(PKG_Client_Lobby_BindPhoneNumber)
o.Register(PKG_Client_Lobby_SendEmailVerificationCode)
o.Register(PKG_Client_Lobby_BindEMailNumber)
o.Register(PKG_Client_Lobby_GetAssistanceStore)
o.Register(PKG_Client_Lobby_SaveAssistanceStore)
o.Register(PKG_Client_Lobby_GetAssistanceInfo)
o.Register(PKG_Client_Lobby_AssistanceToUser)
o.Register(PKG_Client_Lobby_RequestActivityAssistanceExamine)
o.Register(PKG_Client_Lobby_ClientRechargeRequestPayerInfo)
o.Register(PKG_Lobby_Client_Enter_Success)
o.Register(PKG_Client_Lobby_ClientGiftRecord)
o.Register(PKG_Client_Lobby_GetPlace)
o.Register(PKG_Lobby_Client_Events_PlayerStandup)