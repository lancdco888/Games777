
CodeGen_class_def_md5 ="#*MD5<49a9e9112881fd52304797e11fd3144c>*#"

--[[
玩家绑定的支付信息
]]
PKG_ClassDef_PayChannelAccount = {
    typeName = "PKG_ClassDef_PayChannelAccount",
    typeId = 502,
    Create = function(o)
        if o == nil then
            o = {}
            setmetatable(o, PKG_ClassDef_PayChannelAccount)
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
PKG_ClassDef_PayChannelAccount.__index = PKG_ClassDef_PayChannelAccount

--[[
老虎机倍率区间
]]
PKG_ClassDef_EntryConditions = {
    typeName = "PKG_ClassDef_EntryConditions",
    typeId = 505,
    Create = function(o)
        if o == nil then
            o = {}
            setmetatable(o, PKG_ClassDef_EntryConditions)
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
PKG_ClassDef_EntryConditions.__index = PKG_ClassDef_EntryConditions

--[[
当前玩家自己的信息
]]
PKG_ClassDef_selfAccount = {
    typeName = "PKG_ClassDef_selfAccount",
    typeId = 501,
    Create = function(o)
        if o == nil then
            o = {}
            setmetatable(o, PKG_ClassDef_selfAccount)
        end
        --[[
        用户Id ( 随机 8 位整数 )
        ]]
        o.id = 0 -- Int32
        --[[
        原始用户名 唯一( GUID )
        ]]
        o.username = "" -- String
        --[[
        昵称 唯一( 默认用某种规则生成 )
        ]]
        o.nickname = "" -- String
        --[[
        账号 如果空就是没有设置
        ]]
        o.account_name = "" -- String
        --[[
        头像
        ]]
        o.avatar_id = 0 -- Int32
        --[[
        电话号码 唯一( 默认填充 username GUID )
        ]]
        o.phone = "" -- String
        --[[
        账户余额( 保留4位小数位, 进部分游戏时会被清0, 结束时会退款返还 )
        ]]
        o.money = 0 -- Double
        --[[
        锁定金币
        ]]
        o.money_gift = 0 -- Double
        --[[
        保险箱( 玩家可在账户余额间搬运数据 )
        ]]
        o.money_safe = 0 -- Double
        --[[
        锁定金币保险箱
        ]]
        o.money_gift_safe = 0 -- Double
        --[[
        累计充值金额
        ]]
        o.total_recharge = 0 -- Double
        --[[
        累计退款金额
        ]]
        o.total_refund = 0 -- Double
        --[[
        支付渠道基表id
        ]]
        o.pay_channel_id = null -- Nullable<Int32>
        --[[
        是否有退款权限(1有退款权限)
        ]]
        o.has_refund_purview = 0 -- Int32
        --[[
        玩家是否已设置赠送金币密码(1已设置)
        ]]
        o.is_gift_money_password = 0 -- Int32
        --[[
        玩家是否已获赠金币(1已赠送)
        ]]
        o.is_system_gift_money = 0 -- Int32
        --[[
        玩家是否是工会会长
        ]]
        o.is_promotion_master = 0 -- Int32
        --[[
        玩家是否已是代理(1=是)
        ]]
        o.have_promotion = 0 -- Int32
        --[[
        玩家是否有赠送金币权限(1有)
        ]]
        o.has_gift_money_purview = 0 -- Int32
        --[[
        这次登录是否SHOW每日签到(1=是)
        ]]
        o.is_signingave = 0 -- Int32
        --[[
        是否显示签到按钮(1=显示)
        ]]
        o.is_shows_signingave_button = 0 -- Int32
        --[[
        退款最小金额
        ]]
        o.refund_min_money = 0 -- Double
        --[[
        退款保底金额
        ]]
        o.refund_min_remain_money = 0 -- Double
        --[[
        退款金额增幅
        ]]
        o.refund_margin = 0 -- Double
        --[[
        中大奖锁 1=锁
        ]]
        o.is_bigwin_lock = 0 -- Int32
        --[[
        可配置多少张银行卡
        ]]
        o.bankcardcount = 0 -- Int32
        --[[
        玩家绑定的支付信息
        ]]
        o.pay_channel_accounts = {} -- List<Shared<PKG.ClassDef.PayChannelAccount>>
        --[[
        锁定金币生产总值(明码)
        ]]
        o.amount_of_gift = 0 -- Double
        --[[
        累积洗码总值(游戏中获得)
        ]]
        o.amount_of_washcode = 0 -- Double
        --[[
        玩家是否是银商
        ]]
        o.is_businessman = 0 -- Int32
        --[[
        vip 等级 -1=没有vip
        ]]
        o.vip_level = 0 -- Int32
        --[[
        充值类型(A,B号),A=0,B=1,A号只允许常规充值,B号只允许虚拟钱包充值
        ]]
        o.virtual_coin_status = 0 -- Int32
        --[[
        是否是试玩账号
        ]]
        o.is_experience = 0 -- Int32
        --[[
        玩家邮箱
        ]]
        o.email = "" -- String
        return o
    end,
    Read = function(self, om)
        local d = om.d
        local r, n, o
        -- id
        r, self.id = d:Rvi32()
        if r ~= 0 then return r end
        -- username
        r, self.username = d:Rstr()
        if r ~= 0 then return r end
        -- nickname
        r, self.nickname = d:Rstr()
        if r ~= 0 then return r end
        -- account_name
        r, self.account_name = d:Rstr()
        if r ~= 0 then return r end
        -- avatar_id
        r, self.avatar_id = d:Rvi32()
        if r ~= 0 then return r end
        -- phone
        r, self.phone = d:Rstr()
        if r ~= 0 then return r end
        -- money
        r, self.money = d:Rd()
        if r ~= 0 then return r end
        -- money_gift
        r, self.money_gift = d:Rd()
        if r ~= 0 then return r end
        -- money_safe
        r, self.money_safe = d:Rd()
        if r ~= 0 then return r end
        -- money_gift_safe
        r, self.money_gift_safe = d:Rd()
        if r ~= 0 then return r end
        -- total_recharge
        r, self.total_recharge = d:Rd()
        if r ~= 0 then return r end
        -- total_refund
        r, self.total_refund = d:Rd()
        if r ~= 0 then return r end
        -- pay_channel_id
        r, self.pay_channel_id = d:Rnvi32()
        if r ~= 0 then return r end
        -- has_refund_purview
        r, self.has_refund_purview = d:Rvi32()
        if r ~= 0 then return r end
        -- is_gift_money_password
        r, self.is_gift_money_password = d:Rvi32()
        if r ~= 0 then return r end
        -- is_system_gift_money
        r, self.is_system_gift_money = d:Rvi32()
        if r ~= 0 then return r end
        -- is_promotion_master
        r, self.is_promotion_master = d:Rvi32()
        if r ~= 0 then return r end
        -- have_promotion
        r, self.have_promotion = d:Rvi32()
        if r ~= 0 then return r end
        -- has_gift_money_purview
        r, self.has_gift_money_purview = d:Rvi32()
        if r ~= 0 then return r end
        -- is_signingave
        r, self.is_signingave = d:Rvi32()
        if r ~= 0 then return r end
        -- is_shows_signingave_button
        r, self.is_shows_signingave_button = d:Rvi32()
        if r ~= 0 then return r end
        -- refund_min_money
        r, self.refund_min_money = d:Rd()
        if r ~= 0 then return r end
        -- refund_min_remain_money
        r, self.refund_min_remain_money = d:Rd()
        if r ~= 0 then return r end
        -- refund_margin
        r, self.refund_margin = d:Rd()
        if r ~= 0 then return r end
        -- is_bigwin_lock
        r, self.is_bigwin_lock = d:Rvi32()
        if r ~= 0 then return r end
        -- bankcardcount
        r, self.bankcardcount = d:Rvi32()
        if r ~= 0 then return r end
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
        -- amount_of_gift
        r, self.amount_of_gift = d:Rd()
        if r ~= 0 then return r end
        -- amount_of_washcode
        r, self.amount_of_washcode = d:Rd()
        if r ~= 0 then return r end
        -- is_businessman
        r, self.is_businessman = d:Rvi32()
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
        -- email
        r, self.email = d:Rstr()
        if r ~= 0 then return r end
        return 0
    end,
    Write = function(self, om)
        local d = om.d
        local o, len
        -- id
        d:Wvi32(self.id)
        -- username
        d:Wstr(self.username)
        -- nickname
        d:Wstr(self.nickname)
        -- account_name
        d:Wstr(self.account_name)
        -- avatar_id
        d:Wvi32(self.avatar_id)
        -- phone
        d:Wstr(self.phone)
        -- money
        d:Wd(self.money)
        -- money_gift
        d:Wd(self.money_gift)
        -- money_safe
        d:Wd(self.money_safe)
        -- money_gift_safe
        d:Wd(self.money_gift_safe)
        -- total_recharge
        d:Wd(self.total_recharge)
        -- total_refund
        d:Wd(self.total_refund)
        -- pay_channel_id
        d:Wnvi32(self.pay_channel_id)
        -- has_refund_purview
        d:Wvi32(self.has_refund_purview)
        -- is_gift_money_password
        d:Wvi32(self.is_gift_money_password)
        -- is_system_gift_money
        d:Wvi32(self.is_system_gift_money)
        -- is_promotion_master
        d:Wvi32(self.is_promotion_master)
        -- have_promotion
        d:Wvi32(self.have_promotion)
        -- has_gift_money_purview
        d:Wvi32(self.has_gift_money_purview)
        -- is_signingave
        d:Wvi32(self.is_signingave)
        -- is_shows_signingave_button
        d:Wvi32(self.is_shows_signingave_button)
        -- refund_min_money
        d:Wd(self.refund_min_money)
        -- refund_min_remain_money
        d:Wd(self.refund_min_remain_money)
        -- refund_margin
        d:Wd(self.refund_margin)
        -- is_bigwin_lock
        d:Wvi32(self.is_bigwin_lock)
        -- bankcardcount
        d:Wvi32(self.bankcardcount)
        -- pay_channel_accounts
        o = self.pay_channel_accounts
        len = #o
        d:Wvu32(len)
        for i = 1, len do
            om:Write(o[i])
        end
        -- amount_of_gift
        d:Wd(self.amount_of_gift)
        -- amount_of_washcode
        d:Wd(self.amount_of_washcode)
        -- is_businessman
        d:Wvi32(self.is_businessman)
        -- vip_level
        d:Wvi32(self.vip_level)
        -- virtual_coin_status
        d:Wvi32(self.virtual_coin_status)
        -- is_experience
        d:Wvi32(self.is_experience)
        -- email
        d:Wstr(self.email)
    end
}
PKG_ClassDef_selfAccount.__index = PKG_ClassDef_selfAccount

--[[
VIP信息
]]
PKG_ClassDef_Vip = {
    typeName = "PKG_ClassDef_Vip",
    typeId = 503,
    Create = function(o)
        if o == nil then
            o = {}
            setmetatable(o, PKG_ClassDef_Vip)
        end
        --[[
        等级
        ]]
        o.id = 0 -- Int32
        --[[
        升级需要达到的洗码值
        ]]
        o.enough_wash = 0 -- Double
        --[[
        捕鱼收益千分比
        ]]
        o.fish_permillage_value = 0 -- Double
        --[[
        老虎机收益千分比
        ]]
        o.slots_permillage_value = 0 -- Double
        --[[
        升级赠送洗码金币
        ]]
        o.levelup_gift = 0 -- Double
        return o
    end,
    Read = function(self, om)
        local d = om.d
        local r, n
        -- id
        r, self.id = d:Rvi32()
        if r ~= 0 then return r end
        -- enough_wash
        r, self.enough_wash = d:Rd()
        if r ~= 0 then return r end
        -- fish_permillage_value
        r, self.fish_permillage_value = d:Rd()
        if r ~= 0 then return r end
        -- slots_permillage_value
        r, self.slots_permillage_value = d:Rd()
        if r ~= 0 then return r end
        -- levelup_gift
        r, self.levelup_gift = d:Rd()
        if r ~= 0 then return r end
        return 0
    end,
    Write = function(self, om)
        local d = om.d
        -- id
        d:Wvi32(self.id)
        -- enough_wash
        d:Wd(self.enough_wash)
        -- fish_permillage_value
        d:Wd(self.fish_permillage_value)
        -- slots_permillage_value
        d:Wd(self.slots_permillage_value)
        -- levelup_gift
        d:Wd(self.levelup_gift)
    end
}
PKG_ClassDef_Vip.__index = PKG_ClassDef_Vip

--[[
老虎机游戏的Level配置
]]
PKG_ClassDef_GameEntryConditions = {
    typeName = "PKG_ClassDef_GameEntryConditions",
    typeId = 504,
    Create = function(o)
        if o == nil then
            o = {}
            setmetatable(o, PKG_ClassDef_GameEntryConditions)
        end
        --[[
        游戏Id
        ]]
        o.gameid = 0 -- Int32
        --[[
        当前老虎机游戏的level
        ]]
        o.Entrys = {} -- List<Shared<PKG.ClassDef.EntryConditions>>
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
PKG_ClassDef_GameEntryConditions.__index = PKG_ClassDef_GameEntryConditions

--[[
码值等级
]]
PKG_ClassDef_gift_cfg = {
    typeName = "PKG_ClassDef_gift_cfg",
    typeId = 506,
    Create = function(o)
        if o == nil then
            o = {}
            setmetatable(o, PKG_ClassDef_gift_cfg)
        end
        --[[
        明码等级
        ]]
        o.id = 0 -- Int32
        --[[
        需要达到的明码值
        ]]
        o.enough_gift = 0 -- Double
        --[[
        收益千分比
        ]]
        o.permillage_value = 0 -- Double
        --[[
        升级赠送金币
        ]]
        o.levelup_value = 0 -- Double
        return o
    end,
    Read = function(self, om)
        local d = om.d
        local r, n
        -- id
        r, self.id = d:Rvi32()
        if r ~= 0 then return r end
        -- enough_gift
        r, self.enough_gift = d:Rd()
        if r ~= 0 then return r end
        -- permillage_value
        r, self.permillage_value = d:Rd()
        if r ~= 0 then return r end
        -- levelup_value
        r, self.levelup_value = d:Rd()
        if r ~= 0 then return r end
        return 0
    end,
    Write = function(self, om)
        local d = om.d
        -- id
        d:Wvi32(self.id)
        -- enough_gift
        d:Wd(self.enough_gift)
        -- permillage_value
        d:Wd(self.permillage_value)
        -- levelup_value
        d:Wd(self.levelup_value)
    end
}
PKG_ClassDef_gift_cfg.__index = PKG_ClassDef_gift_cfg

local o = ObjMgr
o.Register(PKG_ClassDef_PayChannelAccount)
o.Register(PKG_ClassDef_EntryConditions)
o.Register(PKG_ClassDef_selfAccount)
o.Register(PKG_ClassDef_Vip)
o.Register(PKG_ClassDef_GameEntryConditions)
o.Register(PKG_ClassDef_gift_cfg)