
CodeGen_Lobby_Slots_md5 ="#*MD5<f7456969d398a1585cb7d933afb79ce5>*#"

--[[
玩家一段时间游戏操作引起的金币变化
]]
PKG_Slots_Lobby_PlayingGameMoneyChanges = {
    typeName = "PKG_Slots_Lobby_PlayingGameMoneyChanges",
    typeId = 4505,
    Create = function(o)
        if o == nil then
            o = {}
            setmetatable(o, PKG_Slots_Lobby_PlayingGameMoneyChanges)
        end
        o.changes = {} -- List<PKG.BaseInfo.OnceChange>
        return o
    end,
    Read = function(self, om)
        local d = om.d
        local r, n, o
        -- changes
        r, len = d:Rvu32()
        if len > d:GetLeft() then return -1 end
        o = {}
        self.changes = o
        for i = 1, len do
            o[i] = PKG_BaseInfo_OnceChange.Create(); r = o[i]:Read(om)
            if r ~= 0 then return r end
        end
        if r ~= 0 then return r end
        return 0
    end,
    Write = function(self, om)
        local d = om.d
        local o, len
        -- changes
        o = self.changes
        len = #o
        d:Wvu32(len)
        for i = 1, len do
            o[i]:Write(om)
        end
    end
}
PKG_Slots_Lobby_PlayingGameMoneyChanges.__index = PKG_Slots_Lobby_PlayingGameMoneyChanges

--[[
玩家锁住状态离开
]]
PKG_Slots_Lobby_LockLeave = {
    typeName = "PKG_Slots_Lobby_LockLeave",
    typeId = 4504,
    Create = function(o)
        if o == nil then
            o = {}
            setmetatable(o, PKG_Slots_Lobby_LockLeave)
        end
        --[[
        用户Id
        ]]
        o.accountId = 0 -- Int32
        --[[
        正常状态 0,大奖锁住 1,巨奖锁住 2
        ]]
        o.lockStates = 0 -- Int32
        return o
    end,
    Read = function(self, om)
        local d = om.d
        local r, n
        -- accountId
        r, self.accountId = d:Rvi32()
        if r ~= 0 then return r end
        -- lockStates
        r, self.lockStates = d:Rvi32()
        if r ~= 0 then return r end
        return 0
    end,
    Write = function(self, om)
        local d = om.d
        -- accountId
        d:Wvi32(self.accountId)
        -- lockStates
        d:Wvi32(self.lockStates)
    end
}
PKG_Slots_Lobby_LockLeave.__index = PKG_Slots_Lobby_LockLeave

--[[
游戏中的玩家正常离开
]]
PKG_Slots_Lobby_Leave = {
    typeName = "PKG_Slots_Lobby_Leave",
    typeId = 4503,
    Create = function(o)
        if o == nil then
            o = {}
            setmetatable(o, PKG_Slots_Lobby_Leave)
        end
        --[[
        用户Id
        ]]
        o.accountId = 0 -- Int32
        return o
    end,
    Read = function(self, om)
        local d = om.d
        local r, n
        -- accountId
        r, self.accountId = d:Rvi32()
        if r ~= 0 then return r end
        return 0
    end,
    Write = function(self, om)
        local d = om.d
        -- accountId
        d:Wvi32(self.accountId)
    end
}
PKG_Slots_Lobby_Leave.__index = PKG_Slots_Lobby_Leave

--[[
玩家申请进入反馈
]]
PKG_Slots_Lobby_EnterRet = {
    typeName = "PKG_Slots_Lobby_EnterRet",
    typeId = 4502,
    Create = function(o)
        if o == nil then
            o = {}
            setmetatable(o, PKG_Slots_Lobby_EnterRet)
        end
        --[[
        0表示成功 1表示玩家的钱小于最低进入条件 2表示游戏内存在玩家信息
        ]]
        o.code = 0 -- Int32
        return o
    end,
    Read = function(self, om)
        local d = om.d
        local r, n
        -- code
        r, self.code = d:Rvi32()
        if r ~= 0 then return r end
        return 0
    end,
    Write = function(self, om)
        local d = om.d
        -- code
        d:Wvi32(self.code)
    end
}
PKG_Slots_Lobby_EnterRet.__index = PKG_Slots_Lobby_EnterRet

--[[
注册到大厅
]]
PKG_Slots_Lobby_RegisterSlotsService = {
    typeName = "PKG_Slots_Lobby_RegisterSlotsService",
    typeId = 4501,
    Create = function(o)
        if o == nil then
            o = {}
            setmetatable(o, PKG_Slots_Lobby_RegisterSlotsService)
        end
        --[[
        游戏服务ID
        ]]
        o.serviceId = 0 -- Int32
        --[[
        游戏Id
        ]]
        o.gameId = 0 -- Int32
        --[[
        支持多少玩家
        ]]
        o.playerMaxNum = 0 -- Int32
        return o
    end,
    Read = function(self, om)
        local d = om.d
        local r, n
        -- serviceId
        r, self.serviceId = d:Rvi32()
        if r ~= 0 then return r end
        -- gameId
        r, self.gameId = d:Rvi32()
        if r ~= 0 then return r end
        -- playerMaxNum
        r, self.playerMaxNum = d:Rvi32()
        if r ~= 0 then return r end
        return 0
    end,
    Write = function(self, om)
        local d = om.d
        -- serviceId
        d:Wvi32(self.serviceId)
        -- gameId
        d:Wvi32(self.gameId)
        -- playerMaxNum
        d:Wvi32(self.playerMaxNum)
    end
}
PKG_Slots_Lobby_RegisterSlotsService.__index = PKG_Slots_Lobby_RegisterSlotsService

--[[
玩家重连
]]
PKG_Lobby_Slots_ReEnter = {
    typeName = "PKG_Lobby_Slots_ReEnter",
    typeId = 4003,
    Create = function(o)
        if o == nil then
            o = {}
            setmetatable(o, PKG_Lobby_Slots_ReEnter)
        end
        --[[
        账号ID
        ]]
        o.accountId = 0 -- Int32
        --[[
        客户端连接Id
        ]]
        o.clientId = 0 -- UInt32
        --[[
        网关Id
        ]]
        o.gateWayId = 0 -- UInt32
        return o
    end,
    Read = function(self, om)
        local d = om.d
        local r, n
        -- accountId
        r, self.accountId = d:Rvi32()
        if r ~= 0 then return r end
        -- clientId
        r, self.clientId = d:Rvu32()
        if r ~= 0 then return r end
        -- gateWayId
        r, self.gateWayId = d:Rvu32()
        if r ~= 0 then return r end
        return 0
    end,
    Write = function(self, om)
        local d = om.d
        -- accountId
        d:Wvi32(self.accountId)
        -- clientId
        d:Wvu32(self.clientId)
        -- gateWayId
        d:Wvu32(self.gateWayId)
    end
}
PKG_Lobby_Slots_ReEnter.__index = PKG_Lobby_Slots_ReEnter

--[[
大厅通知游戏强制让玩家离开游戏
]]
PKG_Lobby_Slots_KillPlayer = {
    typeName = "PKG_Lobby_Slots_KillPlayer",
    typeId = 4002,
    Create = function(o)
        if o == nil then
            o = {}
            setmetatable(o, PKG_Lobby_Slots_KillPlayer)
        end
        --[[
        账号ID
        ]]
        o.accountId = 0 -- Int32
        return o
    end,
    Read = function(self, om)
        local d = om.d
        local r, n
        -- accountId
        r, self.accountId = d:Rvi32()
        if r ~= 0 then return r end
        return 0
    end,
    Write = function(self, om)
        local d = om.d
        -- accountId
        d:Wvi32(self.accountId)
    end
}
PKG_Lobby_Slots_KillPlayer.__index = PKG_Lobby_Slots_KillPlayer

--[[
玩家申请进入游戏
]]
PKG_Lobby_Slots_Enter = {
    typeName = "PKG_Lobby_Slots_Enter",
    typeId = 4001,
    Create = function(o)
        if o == nil then
            o = {}
            setmetatable(o, PKG_Lobby_Slots_Enter)
        end
        --[[
        网关
        ]]
        o.gateWayId = 0 -- UInt32
        --[[
        客服端
        ]]
        o.clientId = 0 -- UInt32
        --[[
        玩家id
        ]]
        o.accountId = 0 -- Int32
        --[[
        玩家所在到子库KEY
        ]]
        o.cb_key = "" -- String
        --[[
        原始用户名 唯一( GUID )
        ]]
        o.userName = "" -- String
        --[[
        昵称 唯一( 默认用某种规则生成 )
        ]]
        o.nickName = "" -- String
        --[[
        累计充值金额(计算vip等级)
        ]]
        o.totalRecharge = 0 -- Double
        --[[
        头像
        ]]
        o.avatarId = 0 -- Int32
        --[[
        进入时间( 所有进出时间均以大厅生成的为准 )
        ]]
        o.enterTime = 0 -- Int64
        --[[
        杀分比
        ]]
        o.kill_percent = 0 -- Int32
        --[[
        放的钱
        ]]
        o.gift_money = 0 -- Double
        --[[
        是否带入总压总得
        ]]
        o.is_cost_get = 0 -- Int32
        --[[
        玩家钱
        ]]
        o.money = 0 -- Double
        --[[
        保险箱
        ]]
        o.money_safe = 0 -- Double
        --[[
        绑定的金币
        ]]
        o.money_gift = 0 -- Double
        --[[
        绑定金币的保险箱
        ]]
        o.money_gift_safe = 0 -- Double
        --[[
        玩家的洗码级别
        ]]
        o.wash_amount_lv = 0 -- Int32
        --[[
        玩家的洗码量
        ]]
        o.wash_amount_value = 0 -- Double
        --[[
        玩家是否触发洗码派奖状态 0表示不触发 1表示进入派奖逻辑
        ]]
        o.wash_check = 0 -- Int32
        --[[
        回复让玩家进入游戏的序列号
        ]]
        o.serial = 0 -- Int32
        --[[
        是否正式玩家 1=正式 0=游客
        ]]
        o.is_official = 0 -- Int32
        return o
    end,
    Read = function(self, om)
        local d = om.d
        local r, n
        -- gateWayId
        r, self.gateWayId = d:Rvu32()
        if r ~= 0 then return r end
        -- clientId
        r, self.clientId = d:Rvu32()
        if r ~= 0 then return r end
        -- accountId
        r, self.accountId = d:Rvi32()
        if r ~= 0 then return r end
        -- cb_key
        r, self.cb_key = d:Rstr()
        if r ~= 0 then return r end
        -- userName
        r, self.userName = d:Rstr()
        if r ~= 0 then return r end
        -- nickName
        r, self.nickName = d:Rstr()
        if r ~= 0 then return r end
        -- totalRecharge
        r, self.totalRecharge = d:Rd()
        if r ~= 0 then return r end
        -- avatarId
        r, self.avatarId = d:Rvi32()
        if r ~= 0 then return r end
        -- enterTime
        r, self.enterTime = d:Rvi64()
        if r ~= 0 then return r end
        -- kill_percent
        r, self.kill_percent = d:Rvi32()
        if r ~= 0 then return r end
        -- gift_money
        r, self.gift_money = d:Rd()
        if r ~= 0 then return r end
        -- is_cost_get
        r, self.is_cost_get = d:Rvi32()
        if r ~= 0 then return r end
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
        -- wash_amount_lv
        r, self.wash_amount_lv = d:Rvi32()
        if r ~= 0 then return r end
        -- wash_amount_value
        r, self.wash_amount_value = d:Rd()
        if r ~= 0 then return r end
        -- wash_check
        r, self.wash_check = d:Rvi32()
        if r ~= 0 then return r end
        -- serial
        r, self.serial = d:Rvi32()
        if r ~= 0 then return r end
        -- is_official
        r, self.is_official = d:Rvi32()
        if r ~= 0 then return r end
        return 0
    end,
    Write = function(self, om)
        local d = om.d
        -- gateWayId
        d:Wvu32(self.gateWayId)
        -- clientId
        d:Wvu32(self.clientId)
        -- accountId
        d:Wvi32(self.accountId)
        -- cb_key
        d:Wstr(self.cb_key)
        -- userName
        d:Wstr(self.userName)
        -- nickName
        d:Wstr(self.nickName)
        -- totalRecharge
        d:Wd(self.totalRecharge)
        -- avatarId
        d:Wvi32(self.avatarId)
        -- enterTime
        d:Wvi64(self.enterTime)
        -- kill_percent
        d:Wvi32(self.kill_percent)
        -- gift_money
        d:Wd(self.gift_money)
        -- is_cost_get
        d:Wvi32(self.is_cost_get)
        -- money
        d:Wd(self.money)
        -- money_safe
        d:Wd(self.money_safe)
        -- money_gift
        d:Wd(self.money_gift)
        -- money_gift_safe
        d:Wd(self.money_gift_safe)
        -- wash_amount_lv
        d:Wvi32(self.wash_amount_lv)
        -- wash_amount_value
        d:Wd(self.wash_amount_value)
        -- wash_check
        d:Wvi32(self.wash_check)
        -- serial
        d:Wvi32(self.serial)
        -- is_official
        d:Wvi32(self.is_official)
    end
}
PKG_Lobby_Slots_Enter.__index = PKG_Lobby_Slots_Enter

--[[
通知大厅玩家的日志id
]]
PKG_Slots_Lobby_UpdateLogId = {
    typeName = "PKG_Slots_Lobby_UpdateLogId",
    typeId = 4506,
    Create = function(o)
        if o == nil then
            o = {}
            setmetatable(o, PKG_Slots_Lobby_UpdateLogId)
        end
        --[[
        用户Id
        ]]
        o.accountId = 0 -- Int32
        --[[
        本次进入游戏的日志id
        ]]
        o.logId = 0 -- Int64
        return o
    end,
    Read = function(self, om)
        local d = om.d
        local r, n
        -- accountId
        r, self.accountId = d:Rvi32()
        if r ~= 0 then return r end
        -- logId
        r, self.logId = d:Rvi64()
        if r ~= 0 then return r end
        return 0
    end,
    Write = function(self, om)
        local d = om.d
        -- accountId
        d:Wvi32(self.accountId)
        -- logId
        d:Wvi64(self.logId)
    end
}
PKG_Slots_Lobby_UpdateLogId.__index = PKG_Slots_Lobby_UpdateLogId

--[[
slots跑马灯
]]
PKG_Slots_Lobby_SlotsMarquee = {
    typeName = "PKG_Slots_Lobby_SlotsMarquee",
    typeId = 4507,
    Create = function(o)
        if o == nil then
            o = {}
            setmetatable(o, PKG_Slots_Lobby_SlotsMarquee)
        end
        --[[
        玩家昵称
        ]]
        o.nickName = "" -- String
        --[[
        游戏类型
        ]]
        o.gameId = 0 -- UInt32
        --[[
        中奖金额
        ]]
        o.winMoney = 0 -- Int64
        --[[
        累计充值金额(计算vip等级)
        ]]
        o.totalRecharge = 0 -- UInt64
        --[[
        中奖类型 1为普通奖 (2,3不用) 4大奖 5为巨奖 6为五福
        ]]
        o.winType = 0 -- Int32
        --[[
        锁定金币生产总值(明码)
        ]]
        o.amountOfGift = 0 -- Int64
        return o
    end,
    Read = function(self, om)
        local d = om.d
        local r, n
        -- nickName
        r, self.nickName = d:Rstr()
        if r ~= 0 then return r end
        -- gameId
        r, self.gameId = d:Rvu32()
        if r ~= 0 then return r end
        -- winMoney
        r, self.winMoney = d:Rvi64()
        if r ~= 0 then return r end
        -- totalRecharge
        r, self.totalRecharge = d:Rvu64()
        if r ~= 0 then return r end
        -- winType
        r, self.winType = d:Rvi32()
        if r ~= 0 then return r end
        -- amountOfGift
        r, self.amountOfGift = d:Rvi64()
        if r ~= 0 then return r end
        return 0
    end,
    Write = function(self, om)
        local d = om.d
        -- nickName
        d:Wstr(self.nickName)
        -- gameId
        d:Wvu32(self.gameId)
        -- winMoney
        d:Wvi64(self.winMoney)
        -- totalRecharge
        d:Wvu64(self.totalRecharge)
        -- winType
        d:Wvi32(self.winType)
        -- amountOfGift
        d:Wvi64(self.amountOfGift)
    end
}
PKG_Slots_Lobby_SlotsMarquee.__index = PKG_Slots_Lobby_SlotsMarquee

local o = ObjMgr
o.Register(PKG_Slots_Lobby_PlayingGameMoneyChanges)
o.Register(PKG_Slots_Lobby_LockLeave)
o.Register(PKG_Slots_Lobby_Leave)
o.Register(PKG_Slots_Lobby_EnterRet)
o.Register(PKG_Slots_Lobby_RegisterSlotsService)
o.Register(PKG_Lobby_Slots_ReEnter)
o.Register(PKG_Lobby_Slots_KillPlayer)
o.Register(PKG_Lobby_Slots_Enter)
o.Register(PKG_Slots_Lobby_UpdateLogId)
o.Register(PKG_Slots_Lobby_SlotsMarquee)