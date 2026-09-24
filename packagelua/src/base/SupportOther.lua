
-- require('BaseInfo')
CodeGen_SupportOther_md5 ="#*MD5<90edfa45382c183c09c327651a2d4163>*#"

--[[
请求按线算分处理,会出现押注彩金,玩家押注时会去影响彩金值
]]
PKG_Other_Support_ReqSlotCounter = {
    typeName = "PKG_Other_Support_ReqSlotCounter",
    typeId = 20108,
    Create = function(o)
        if o == nil then
            o = {}
            setmetatable(o, PKG_Other_Support_ReqSlotCounter)
        end
        --[[
        玩家ID
        ]]
        o.guid = 0 -- Int32
        --[[
        游戏级别
        ]]
        o.levelId = 0 -- Int32
        --[[
        游戏服ID
        ]]
        o.gameId = 0 -- UInt32
        --[[
        押注金额
        ]]
        o.inMoney = 0 -- Int64
        --[[
        期望获得的金额
        ]]
        o.hopeGet = 0 -- Int64
        --[[
        隐藏金币 用于参与计算 不计入总得
        ]]
        o.hiddenMoney = 0 -- Int64
        --[[
        0代表没有押注彩金
        ]]
        o.lotteryID = 0 -- Int32
        --[[
        本次是否免费 免费则不增加总押
        ]]
        o.isFree = false -- Boolean
        --[[
        是否直接给得分
        ]]
        o.isPresent = false -- Boolean
        --[[
        是否影响该游戏服关联的彩金
        ]]
        o.needChangeLottery = false -- Boolean
        --[[
        押注金币类型 0 是普通金币 1是绑定金币
        ]]
        o.moneyType = 0 -- UInt32
        return o
    end,
    Read = function(self, om)
        local d = om.d
        local r, n
        -- guid
        r, self.guid = d:Rvi32()
        if r ~= 0 then return r end
        -- levelId
        r, self.levelId = d:Rvi32()
        if r ~= 0 then return r end
        -- gameId
        r, self.gameId = d:Rvu32()
        if r ~= 0 then return r end
        -- inMoney
        r, self.inMoney = d:Rvi64()
        if r ~= 0 then return r end
        -- hopeGet
        r, self.hopeGet = d:Rvi64()
        if r ~= 0 then return r end
        -- hiddenMoney
        r, self.hiddenMoney = d:Rvi64()
        if r ~= 0 then return r end
        -- lotteryID
        r, self.lotteryID = d:Rvi32()
        if r ~= 0 then return r end
        -- isFree
        r, self.isFree = d:Rb()
        if r ~= 0 then return r end
        -- isPresent
        r, self.isPresent = d:Rb()
        if r ~= 0 then return r end
        -- needChangeLottery
        r, self.needChangeLottery = d:Rb()
        if r ~= 0 then return r end
        -- moneyType
        r, self.moneyType = d:Rvu32()
        if r ~= 0 then return r end
        return 0
    end,
    Write = function(self, om)
        local d = om.d
        -- guid
        d:Wvi32(self.guid)
        -- levelId
        d:Wvi32(self.levelId)
        -- gameId
        d:Wvu32(self.gameId)
        -- inMoney
        d:Wvi64(self.inMoney)
        -- hopeGet
        d:Wvi64(self.hopeGet)
        -- hiddenMoney
        d:Wvi64(self.hiddenMoney)
        -- lotteryID
        d:Wvi32(self.lotteryID)
        -- isFree
        d:Wb(self.isFree)
        -- isPresent
        d:Wb(self.isPresent)
        -- needChangeLottery
        d:Wb(self.needChangeLottery)
        -- moneyType
        d:Wvu32(self.moneyType)
    end
}
PKG_Other_Support_ReqSlotCounter.__index = PKG_Other_Support_ReqSlotCounter

--[[
算分结果返回
]]
PKG_Support_Other_SlotCountRet = {
    typeName = "PKG_Support_Other_SlotCountRet",
    typeId = 20308,
    Create = function(o)
        if o == nil then
            o = {}
            setmetatable(o, PKG_Support_Other_SlotCountRet)
        end
        o.code = 0 -- Int32
        o.guid = 0 -- Int32
        o.isWin = false -- Boolean
        o.inMoney = 0 -- Int64
        o.winMoney = 0 -- Int64
        o.moneyBase = PKG_BaseInfo_AccountMoney.Create() -- PKG.BaseInfo.AccountMoney
        o.giftInfo = PKG_BaseInfo_AccountMoneyGift.Create() -- PKG.BaseInfo.AccountMoneyGift
        o.levelUps = {} -- List<Int64>
        o.moneyType = 0 -- UInt32
        o.isGrandWin = false -- Boolean
        return o
    end,
    Read = function(self, om)
        local d = om.d
        local r, n, o
        -- code
        r, self.code = d:Rvi32()
        if r ~= 0 then return r end
        -- guid
        r, self.guid = d:Rvi32()
        if r ~= 0 then return r end
        -- isWin
        r, self.isWin = d:Rb()
        if r ~= 0 then return r end
        -- inMoney
        r, self.inMoney = d:Rvi64()
        if r ~= 0 then return r end
        -- winMoney
        r, self.winMoney = d:Rvi64()
        if r ~= 0 then return r end
        -- moneyBase
        self.moneyBase = PKG_BaseInfo_AccountMoney.Create(); r = self.moneyBase:Read(om)
        if r ~= 0 then return r end
        -- giftInfo
        self.giftInfo = PKG_BaseInfo_AccountMoneyGift.Create(); r = self.giftInfo:Read(om)
        if r ~= 0 then return r end
        -- levelUps
        r, len = d:Rvu32()
        if len > d:GetLeft() then return -1 end
        o = {}
        self.levelUps = o
        for i = 1, len do
            r, o[i] = d:Rvi64()
            if r ~= 0 then return r end
        end
        if r ~= 0 then return r end
        -- moneyType
        r, self.moneyType = d:Rvu32()
        if r ~= 0 then return r end
        -- isGrandWin
        r, self.isGrandWin = d:Rb()
        if r ~= 0 then return r end
        return 0
    end,
    Write = function(self, om)
        local d = om.d
        local o, len
        -- code
        d:Wvi32(self.code)
        -- guid
        d:Wvi32(self.guid)
        -- isWin
        d:Wb(self.isWin)
        -- inMoney
        d:Wvi64(self.inMoney)
        -- winMoney
        d:Wvi64(self.winMoney)
        -- moneyBase
        self.moneyBase:Write(om)
        -- giftInfo
        self.giftInfo:Write(om)
        -- levelUps
        o = self.levelUps
        len = #o
        d:Wvu32(len)
        for i = 1, len do
            d:Wvi64(o[i])
        end
        -- moneyType
        d:Wvu32(self.moneyType)
        -- isGrandWin
        d:Wb(self.isGrandWin)
    end
}
PKG_Support_Other_SlotCountRet.__index = PKG_Support_Other_SlotCountRet

--[[
大厅连接
]]
PKG_Other_Support_LobbyConn = {
    typeName = "PKG_Other_Support_LobbyConn",
    typeId = 20101,
    Create = function(o)
        if o == nil then
            o = {}
            setmetatable(o, PKG_Other_Support_LobbyConn)
        end
        o.serviceId = 0 -- UInt32
        return o
    end,
    Read = function(self, om)
        local d = om.d
        local r, n
        -- serviceId
        r, self.serviceId = d:Rvu32()
        if r ~= 0 then return r end
        return 0
    end,
    Write = function(self, om)
        local d = om.d
        -- serviceId
        d:Wvu32(self.serviceId)
    end
}
PKG_Other_Support_LobbyConn.__index = PKG_Other_Support_LobbyConn

--[[
老虎机连接
]]
PKG_Other_Support_SlotsConn = {
    typeName = "PKG_Other_Support_SlotsConn",
    typeId = 20102,
    Create = function(o)
        if o == nil then
            o = {}
            setmetatable(o, PKG_Other_Support_SlotsConn)
        end
        o.serviceId = 0 -- UInt32
        o.gameId = 0 -- UInt32
        return o
    end,
    Read = function(self, om)
        local d = om.d
        local r, n
        -- serviceId
        r, self.serviceId = d:Rvu32()
        if r ~= 0 then return r end
        -- gameId
        r, self.gameId = d:Rvu32()
        if r ~= 0 then return r end
        return 0
    end,
    Write = function(self, om)
        local d = om.d
        -- serviceId
        d:Wvu32(self.serviceId)
        -- gameId
        d:Wvu32(self.gameId)
    end
}
PKG_Other_Support_SlotsConn.__index = PKG_Other_Support_SlotsConn

--[[
捕鱼连接
]]
PKG_Other_Support_FishConn = {
    typeName = "PKG_Other_Support_FishConn",
    typeId = 20103,
    Create = function(o)
        if o == nil then
            o = {}
            setmetatable(o, PKG_Other_Support_FishConn)
        end
        o.serviceId = 0 -- UInt32
        o.gameId = 0 -- UInt32
        return o
    end,
    Read = function(self, om)
        local d = om.d
        local r, n
        -- serviceId
        r, self.serviceId = d:Rvu32()
        if r ~= 0 then return r end
        -- gameId
        r, self.gameId = d:Rvu32()
        if r ~= 0 then return r end
        return 0
    end,
    Write = function(self, om)
        local d = om.d
        -- serviceId
        d:Wvu32(self.serviceId)
        -- gameId
        d:Wvu32(self.gameId)
    end
}
PKG_Other_Support_FishConn.__index = PKG_Other_Support_FishConn

--[[
请求进入游戏
]]
PKG_Other_Support_Enter = {
    typeName = "PKG_Other_Support_Enter",
    typeId = 20104,
    Create = function(o)
        if o == nil then
            o = {}
            setmetatable(o, PKG_Other_Support_Enter)
        end
        o.accountId = 0 -- Int32
        o.levelId = 0 -- Int32
        o.tableId = 0 -- Int32
        o.chairId = 0 -- Int32
        o.cbKey = "" -- String
        o.gameId = 0 -- UInt32
        return o
    end,
    Read = function(self, om)
        local d = om.d
        local r, n
        -- accountId
        r, self.accountId = d:Rvi32()
        if r ~= 0 then return r end
        -- levelId
        r, self.levelId = d:Rvi32()
        if r ~= 0 then return r end
        -- tableId
        r, self.tableId = d:Rvi32()
        if r ~= 0 then return r end
        -- chairId
        r, self.chairId = d:Rvi32()
        if r ~= 0 then return r end
        -- cbKey
        r, self.cbKey = d:Rstr()
        if r ~= 0 then return r end
        -- gameId
        r, self.gameId = d:Rvu32()
        if r ~= 0 then return r end
        return 0
    end,
    Write = function(self, om)
        local d = om.d
        -- accountId
        d:Wvi32(self.accountId)
        -- levelId
        d:Wvi32(self.levelId)
        -- tableId
        d:Wvi32(self.tableId)
        -- chairId
        d:Wvi32(self.chairId)
        -- cbKey
        d:Wstr(self.cbKey)
        -- gameId
        d:Wvu32(self.gameId)
    end
}
PKG_Other_Support_Enter.__index = PKG_Other_Support_Enter

--[[
请求离开
]]
PKG_Other_Support_Leave = {
    typeName = "PKG_Other_Support_Leave",
    typeId = 20105,
    Create = function(o)
        if o == nil then
            o = {}
            setmetatable(o, PKG_Other_Support_Leave)
        end
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
PKG_Other_Support_Leave.__index = PKG_Other_Support_Leave

--[[
请求所有彩金信息
]]
PKG_Other_Support_ReqAllLottery = {
    typeName = "PKG_Other_Support_ReqAllLottery",
    typeId = 20106,
    Create = function(o)
        if o == nil then
            o = {}
            setmetatable(o, PKG_Other_Support_ReqAllLottery)
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
PKG_Other_Support_ReqAllLottery.__index = PKG_Other_Support_ReqAllLottery

--[[
请求自身彩金信息
]]
PKG_Other_Support_ReqOneGameLottery = {
    typeName = "PKG_Other_Support_ReqOneGameLottery",
    typeId = 20107,
    Create = function(o)
        if o == nil then
            o = {}
            setmetatable(o, PKG_Other_Support_ReqOneGameLottery)
        end
        --[[
        游戏id
        ]]
        o.game_id = 0 -- UInt32
        return o
    end,
    Read = function(self, om)
        local d = om.d
        local r, n
        -- game_id
        r, self.game_id = d:Rvu32()
        if r ~= 0 then return r end
        return 0
    end,
    Write = function(self, om)
        local d = om.d
        -- game_id
        d:Wvu32(self.game_id)
    end
}
PKG_Other_Support_ReqOneGameLottery.__index = PKG_Other_Support_ReqOneGameLottery

--[[
一组算分请求
]]
PKG_Other_Support_ReqSlotCounters = {
    typeName = "PKG_Other_Support_ReqSlotCounters",
    typeId = 20109,
    Create = function(o)
        if o == nil then
            o = {}
            setmetatable(o, PKG_Other_Support_ReqSlotCounters)
        end
        o.counters = {} -- List<Shared<PKG.Other_Support.ReqSlotCounter>>
        return o
    end,
    Read = function(self, om)
        local d = om.d
        local r, n, o
        -- counters
        r, len = d:Rvu32()
        if len > d:GetLeft() then return -1 end
        o = {}
        self.counters = o
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
        -- counters
        o = self.counters
        len = #o
        d:Wvu32(len)
        for i = 1, len do
            om:Write(o[i])
        end
    end
}
PKG_Other_Support_ReqSlotCounters.__index = PKG_Other_Support_ReqSlotCounters

--[[
老虎机机器人请求打彩金
]]
PKG_Other_Support_RobotSpinLottery = {
    typeName = "PKG_Other_Support_RobotSpinLottery",
    typeId = 20110,
    Create = function(o)
        if o == nil then
            o = {}
            setmetatable(o, PKG_Other_Support_RobotSpinLottery)
        end
        --[[
        机器人id
        ]]
        o.accountId = 0 -- Int32
        --[[
        机器人旋转金币
        ]]
        o.betMoney = 0 -- Int64
        --[[
        彩金id
        ]]
        o.lotteryId = 0 -- Int32
        return o
    end,
    Read = function(self, om)
        local d = om.d
        local r, n
        -- accountId
        r, self.accountId = d:Rvi32()
        if r ~= 0 then return r end
        -- betMoney
        r, self.betMoney = d:Rvi64()
        if r ~= 0 then return r end
        -- lotteryId
        r, self.lotteryId = d:Rvi32()
        if r ~= 0 then return r end
        return 0
    end,
    Write = function(self, om)
        local d = om.d
        -- accountId
        d:Wvi32(self.accountId)
        -- betMoney
        d:Wvi64(self.betMoney)
        -- lotteryId
        d:Wvi32(self.lotteryId)
    end
}
PKG_Other_Support_RobotSpinLottery.__index = PKG_Other_Support_RobotSpinLottery

--[[
捕鱼机器人请求打彩金
]]
PKG_Other_Support_RobotHitLottery = {
    typeName = "PKG_Other_Support_RobotHitLottery",
    typeId = 20111,
    Create = function(o)
        if o == nil then
            o = {}
            setmetatable(o, PKG_Other_Support_RobotHitLottery)
        end
        --[[
        房间Id
        ]]
        o.roomId = 0 -- Int32
        --[[
        游戏Id
        ]]
        o.gameId = 0 -- UInt32
        --[[
        级别Id
        ]]
        o.levelId = 0 -- Int32
        --[[
        机器人id
        ]]
        o.accountId = 0 -- Int32
        --[[
        机器人旋转金币
        ]]
        o.betMoney = 0 -- Int64
        --[[
        彩金id
        ]]
        o.lotteryId = 0 -- Int32
        return o
    end,
    Read = function(self, om)
        local d = om.d
        local r, n
        -- roomId
        r, self.roomId = d:Rvi32()
        if r ~= 0 then return r end
        -- gameId
        r, self.gameId = d:Rvu32()
        if r ~= 0 then return r end
        -- levelId
        r, self.levelId = d:Rvi32()
        if r ~= 0 then return r end
        -- accountId
        r, self.accountId = d:Rvi32()
        if r ~= 0 then return r end
        -- betMoney
        r, self.betMoney = d:Rvi64()
        if r ~= 0 then return r end
        -- lotteryId
        r, self.lotteryId = d:Rvi32()
        if r ~= 0 then return r end
        return 0
    end,
    Write = function(self, om)
        local d = om.d
        -- roomId
        d:Wvi32(self.roomId)
        -- gameId
        d:Wvu32(self.gameId)
        -- levelId
        d:Wvi32(self.levelId)
        -- accountId
        d:Wvi32(self.accountId)
        -- betMoney
        d:Wvi64(self.betMoney)
        -- lotteryId
        d:Wvi32(self.lotteryId)
    end
}
PKG_Other_Support_RobotHitLottery.__index = PKG_Other_Support_RobotHitLottery

--[[
保险箱操作
]]
PKG_Other_Support_PlayerStore = {
    typeName = "PKG_Other_Support_PlayerStore",
    typeId = 20112,
    Create = function(o)
        if o == nil then
            o = {}
            setmetatable(o, PKG_Other_Support_PlayerStore)
        end
        o.type = 0 -- Int32
        o.accountId = 0 -- Int32
        o.money = 0 -- Int64
        return o
    end,
    Read = function(self, om)
        local d = om.d
        local r, n
        -- type
        r, self.type = d:Rvi32()
        if r ~= 0 then return r end
        -- accountId
        r, self.accountId = d:Rvi32()
        if r ~= 0 then return r end
        -- money
        r, self.money = d:Rvi64()
        if r ~= 0 then return r end
        return 0
    end,
    Write = function(self, om)
        local d = om.d
        -- type
        d:Wvi32(self.type)
        -- accountId
        d:Wvi32(self.accountId)
        -- money
        d:Wvi64(self.money)
    end
}
PKG_Other_Support_PlayerStore.__index = PKG_Other_Support_PlayerStore

--[[
打中鱼的请求(多条请求打包处理)
]]
PKG_Other_Support_HitFish = {
    typeName = "PKG_Other_Support_HitFish",
    typeId = 20113,
    Create = function(o)
        if o == nil then
            o = {}
            setmetatable(o, PKG_Other_Support_HitFish)
        end
        o.groups = {} -- List<PKG.BaseInfo.HitInfoGroup>
        return o
    end,
    Read = function(self, om)
        local d = om.d
        local r, n, o
        -- groups
        r, len = d:Rvu32()
        if len > d:GetLeft() then return -1 end
        o = {}
        self.groups = o
        for i = 1, len do
            o[i] = PKG_BaseInfo_HitInfoGroup.Create(); r = o[i]:Read(om)
            if r ~= 0 then return r end
        end
        if r ~= 0 then return r end
        return 0
    end,
    Write = function(self, om)
        local d = om.d
        local o, len
        -- groups
        o = self.groups
        len = #o
        d:Wvu32(len)
        for i = 1, len do
            o[i]:Write(om)
        end
    end
}
PKG_Other_Support_HitFish.__index = PKG_Other_Support_HitFish

--[[
旋转请求
]]
PKG_Other_Support_ReqSlotSpin = {
    typeName = "PKG_Other_Support_ReqSlotSpin",
    typeId = 20114,
    Create = function(o)
        if o == nil then
            o = {}
            setmetatable(o, PKG_Other_Support_ReqSlotSpin)
        end
        --[[
        玩家ID
        ]]
        o.guid = 0 -- Int32
        --[[
        游戏级别
        ]]
        o.levelId = 0 -- Int32
        --[[
        游戏服ID
        ]]
        o.gameId = 0 -- UInt32
        --[[
        押注金额
        ]]
        o.inMoney = 0 -- Int64
        --[[
        期望获得的金额
        ]]
        o.hopeGet = 0 -- Int64
        --[[
        押注金币类型 0 是普通金币 1是绑定金币
        ]]
        o.moneyType = 0 -- UInt32
        --[[
        是否影响该游戏服关联的彩金
        ]]
        o.needChangeLottery = false -- Boolean
        --[[
        是否需要退钱
        ]]
        o.needReRund = false -- Boolean
        --[[
        (needReRund=false才判定)当0代表没有押注彩金/其他表示该次想打下的彩金
        ]]
        o.lotteryId = 0 -- Int32
        --[[
        旋转类型 0不打包 1免费打包 2落地牌打包 3..
        ]]
        o.spinType = 0 -- UInt32
        return o
    end,
    Read = function(self, om)
        local d = om.d
        local r, n
        -- guid
        r, self.guid = d:Rvi32()
        if r ~= 0 then return r end
        -- levelId
        r, self.levelId = d:Rvi32()
        if r ~= 0 then return r end
        -- gameId
        r, self.gameId = d:Rvu32()
        if r ~= 0 then return r end
        -- inMoney
        r, self.inMoney = d:Rvi64()
        if r ~= 0 then return r end
        -- hopeGet
        r, self.hopeGet = d:Rvi64()
        if r ~= 0 then return r end
        -- moneyType
        r, self.moneyType = d:Rvu32()
        if r ~= 0 then return r end
        -- needChangeLottery
        r, self.needChangeLottery = d:Rb()
        if r ~= 0 then return r end
        -- needReRund
        r, self.needReRund = d:Rb()
        if r ~= 0 then return r end
        -- lotteryId
        r, self.lotteryId = d:Rvi32()
        if r ~= 0 then return r end
        -- spinType
        r, self.spinType = d:Rvu32()
        if r ~= 0 then return r end
        return 0
    end,
    Write = function(self, om)
        local d = om.d
        -- guid
        d:Wvi32(self.guid)
        -- levelId
        d:Wvi32(self.levelId)
        -- gameId
        d:Wvu32(self.gameId)
        -- inMoney
        d:Wvi64(self.inMoney)
        -- hopeGet
        d:Wvi64(self.hopeGet)
        -- moneyType
        d:Wvu32(self.moneyType)
        -- needChangeLottery
        d:Wb(self.needChangeLottery)
        -- needReRund
        d:Wb(self.needReRund)
        -- lotteryId
        d:Wvi32(self.lotteryId)
        -- spinType
        d:Wvu32(self.spinType)
    end
}
PKG_Other_Support_ReqSlotSpin.__index = PKG_Other_Support_ReqSlotSpin

--[[
推送基本统计数据
]]
PKG_Support_Other_UpdateDataStatistics = {
    typeName = "PKG_Support_Other_UpdateDataStatistics",
    typeId = 20317,
    Create = function(o)
        if o == nil then
            o = {}
            setmetatable(o, PKG_Support_Other_UpdateDataStatistics)
        end
        o.datas = {} -- List<PKG.BaseInfo.DataStatistics>
        return o
    end,
    Read = function(self, om)
        local d = om.d
        local r, n, o
        -- datas
        r, len = d:Rvu32()
        if len > d:GetLeft() then return -1 end
        o = {}
        self.datas = o
        for i = 1, len do
            o[i] = PKG_BaseInfo_DataStatistics.Create(); r = o[i]:Read(om)
            if r ~= 0 then return r end
        end
        if r ~= 0 then return r end
        return 0
    end,
    Write = function(self, om)
        local d = om.d
        local o, len
        -- datas
        o = self.datas
        len = #o
        d:Wvu32(len)
        for i = 1, len do
            o[i]:Write(om)
        end
    end
}
PKG_Support_Other_UpdateDataStatistics.__index = PKG_Support_Other_UpdateDataStatistics

--[[
活动计算结果
]]
PKG_Support_Other_ActivityCountRet = {
    typeName = "PKG_Support_Other_ActivityCountRet",
    typeId = 20316,
    Create = function(o)
        if o == nil then
            o = {}
            setmetatable(o, PKG_Support_Other_ActivityCountRet)
        end
        o.code = 0 -- Int32
        o.guid = 0 -- Int32
        o.isWin = false -- Boolean
        return o
    end,
    Read = function(self, om)
        local d = om.d
        local r, n
        -- code
        r, self.code = d:Rvi32()
        if r ~= 0 then return r end
        -- guid
        r, self.guid = d:Rvi32()
        if r ~= 0 then return r end
        -- isWin
        r, self.isWin = d:Rb()
        if r ~= 0 then return r end
        return 0
    end,
    Write = function(self, om)
        local d = om.d
        -- code
        d:Wvi32(self.code)
        -- guid
        d:Wvi32(self.guid)
        -- isWin
        d:Wb(self.isWin)
    end
}
PKG_Support_Other_ActivityCountRet.__index = PKG_Support_Other_ActivityCountRet

--[[
算分结果返回
]]
PKG_Support_Other_SlotSpinRet = {
    typeName = "PKG_Support_Other_SlotSpinRet",
    typeId = 20314,
    Create = function(o)
        if o == nil then
            o = {}
            setmetatable(o, PKG_Support_Other_SlotSpinRet)
        end
        o.code = 0 -- Int32
        o.guid = 0 -- Int32
        o.isWin = false -- Boolean
        o.inMoney = 0 -- Int64
        o.winMoney = 0 -- Int64
        o.moneyBase = PKG_BaseInfo_AccountMoney.Create() -- PKG.BaseInfo.AccountMoney
        o.giftInfo = PKG_BaseInfo_AccountMoneyGift.Create() -- PKG.BaseInfo.AccountMoneyGift
        o.levelUps = {} -- List<Int64>
        o.moneyType = 0 -- UInt32
        return o
    end,
    Read = function(self, om)
        local d = om.d
        local r, n, o
        -- code
        r, self.code = d:Rvi32()
        if r ~= 0 then return r end
        -- guid
        r, self.guid = d:Rvi32()
        if r ~= 0 then return r end
        -- isWin
        r, self.isWin = d:Rb()
        if r ~= 0 then return r end
        -- inMoney
        r, self.inMoney = d:Rvi64()
        if r ~= 0 then return r end
        -- winMoney
        r, self.winMoney = d:Rvi64()
        if r ~= 0 then return r end
        -- moneyBase
        self.moneyBase = PKG_BaseInfo_AccountMoney.Create(); r = self.moneyBase:Read(om)
        if r ~= 0 then return r end
        -- giftInfo
        self.giftInfo = PKG_BaseInfo_AccountMoneyGift.Create(); r = self.giftInfo:Read(om)
        if r ~= 0 then return r end
        -- levelUps
        r, len = d:Rvu32()
        if len > d:GetLeft() then return -1 end
        o = {}
        self.levelUps = o
        for i = 1, len do
            r, o[i] = d:Rvi64()
            if r ~= 0 then return r end
        end
        if r ~= 0 then return r end
        -- moneyType
        r, self.moneyType = d:Rvu32()
        if r ~= 0 then return r end
        return 0
    end,
    Write = function(self, om)
        local d = om.d
        local o, len
        -- code
        d:Wvi32(self.code)
        -- guid
        d:Wvi32(self.guid)
        -- isWin
        d:Wb(self.isWin)
        -- inMoney
        d:Wvi64(self.inMoney)
        -- winMoney
        d:Wvi64(self.winMoney)
        -- moneyBase
        self.moneyBase:Write(om)
        -- giftInfo
        self.giftInfo:Write(om)
        -- levelUps
        o = self.levelUps
        len = #o
        d:Wvu32(len)
        for i = 1, len do
            d:Wvi64(o[i])
        end
        -- moneyType
        d:Wvu32(self.moneyType)
    end
}
PKG_Support_Other_SlotSpinRet.__index = PKG_Support_Other_SlotSpinRet

PKG_Support_Other_FishConnRet = {
    typeName = "PKG_Support_Other_FishConnRet",
    typeId = 20301,
    Create = function(o)
        if o == nil then
            o = {}
            setmetatable(o, PKG_Support_Other_FishConnRet)
        end
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
PKG_Support_Other_FishConnRet.__index = PKG_Support_Other_FishConnRet

--[[
请求进入游戏结果
]]
PKG_Support_Other_EnterRet = {
    typeName = "PKG_Support_Other_EnterRet",
    typeId = 20302,
    Create = function(o)
        if o == nil then
            o = {}
            setmetatable(o, PKG_Support_Other_EnterRet)
        end
        o.accountId = 0 -- Int32
        o.code = 0 -- Int32
        o.saveMoney = PKG_BaseInfo_AccountMoneyAll.Create() -- PKG.BaseInfo.AccountMoneyAll
        o.isRobot = 4 -- Int32
        return o
    end,
    Read = function(self, om)
        local d = om.d
        local r, n
        -- accountId
        r, self.accountId = d:Rvi32()
        if r ~= 0 then return r end
        -- code
        r, self.code = d:Rvi32()
        if r ~= 0 then return r end
        -- saveMoney
        self.saveMoney = PKG_BaseInfo_AccountMoneyAll.Create(); r = self.saveMoney:Read(om)
        if r ~= 0 then return r end
        -- isRobot
        r, self.isRobot = d:Rvi32()
        if r ~= 0 then return r end
        return 0
    end,
    Write = function(self, om)
        local d = om.d
        -- accountId
        d:Wvi32(self.accountId)
        -- code
        d:Wvi32(self.code)
        -- saveMoney
        self.saveMoney:Write(om)
        -- isRobot
        d:Wvi32(self.isRobot)
    end
}
PKG_Support_Other_EnterRet.__index = PKG_Support_Other_EnterRet

--[[
请求离开结果
]]
PKG_Support_Other_LeaveRet = {
    typeName = "PKG_Support_Other_LeaveRet",
    typeId = 20303,
    Create = function(o)
        if o == nil then
            o = {}
            setmetatable(o, PKG_Support_Other_LeaveRet)
        end
        o.accountId = 0 -- Int32
        o.code = 0 -- Int32
        return o
    end,
    Read = function(self, om)
        local d = om.d
        local r, n
        -- accountId
        r, self.accountId = d:Rvi32()
        if r ~= 0 then return r end
        -- code
        r, self.code = d:Rvi32()
        if r ~= 0 then return r end
        return 0
    end,
    Write = function(self, om)
        local d = om.d
        -- accountId
        d:Wvi32(self.accountId)
        -- code
        d:Wvi32(self.code)
    end
}
PKG_Support_Other_LeaveRet.__index = PKG_Support_Other_LeaveRet

--[[
某个服务已经结存(目前用于计算服告知大厅)
]]
PKG_Support_Other_OneServiceSaved = {
    typeName = "PKG_Support_Other_OneServiceSaved",
    typeId = 20304,
    Create = function(o)
        if o == nil then
            o = {}
            setmetatable(o, PKG_Support_Other_OneServiceSaved)
        end
        o.serviceId = 0 -- Int32
        o.accountIds = {} -- List<Int32>
        return o
    end,
    Read = function(self, om)
        local d = om.d
        local r, n, o
        -- serviceId
        r, self.serviceId = d:Rvi32()
        if r ~= 0 then return r end
        -- accountIds
        r, len = d:Rvu32()
        if len > d:GetLeft() then return -1 end
        o = {}
        self.accountIds = o
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
        -- serviceId
        d:Wvi32(self.serviceId)
        -- accountIds
        o = self.accountIds
        len = #o
        d:Wvu32(len)
        for i = 1, len do
            d:Wvi32(o[i])
        end
    end
}
PKG_Support_Other_OneServiceSaved.__index = PKG_Support_Other_OneServiceSaved

--[[
向大厅发起注册
]]
PKG_Support_Other_RegisterToLobby = {
    typeName = "PKG_Support_Other_RegisterToLobby",
    typeId = 20305,
    Create = function(o)
        if o == nil then
            o = {}
            setmetatable(o, PKG_Support_Other_RegisterToLobby)
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
PKG_Support_Other_RegisterToLobby.__index = PKG_Support_Other_RegisterToLobby

--[[
请求退钱结果
]]
PKG_Support_Other_SlotReRundRet = {
    typeName = "PKG_Support_Other_SlotReRundRet",
    typeId = 20315,
    Create = function(o)
        if o == nil then
            o = {}
            setmetatable(o, PKG_Support_Other_SlotReRundRet)
        end
        o.code = 0 -- Int32
        --[[
        玩家ID
        ]]
        o.guid = 0 -- Int32
        --[[
        游戏级别
        ]]
        o.levelId = 0 -- Int32
        --[[
        游戏服ID
        ]]
        o.gameId = 0 -- UInt32
        --[[
        押注金额
        ]]
        o.inMoney = 0 -- Int64
        o.moneyBase = PKG_BaseInfo_AccountMoney.Create() -- PKG.BaseInfo.AccountMoney
        o.giftInfo = PKG_BaseInfo_AccountMoneyGift.Create() -- PKG.BaseInfo.AccountMoneyGift
        return o
    end,
    Read = function(self, om)
        local d = om.d
        local r, n
        -- code
        r, self.code = d:Rvi32()
        if r ~= 0 then return r end
        -- guid
        r, self.guid = d:Rvi32()
        if r ~= 0 then return r end
        -- levelId
        r, self.levelId = d:Rvi32()
        if r ~= 0 then return r end
        -- gameId
        r, self.gameId = d:Rvu32()
        if r ~= 0 then return r end
        -- inMoney
        r, self.inMoney = d:Rvi64()
        if r ~= 0 then return r end
        -- moneyBase
        self.moneyBase = PKG_BaseInfo_AccountMoney.Create(); r = self.moneyBase:Read(om)
        if r ~= 0 then return r end
        -- giftInfo
        self.giftInfo = PKG_BaseInfo_AccountMoneyGift.Create(); r = self.giftInfo:Read(om)
        if r ~= 0 then return r end
        return 0
    end,
    Write = function(self, om)
        local d = om.d
        -- code
        d:Wvi32(self.code)
        -- guid
        d:Wvi32(self.guid)
        -- levelId
        d:Wvi32(self.levelId)
        -- gameId
        d:Wvu32(self.gameId)
        -- inMoney
        d:Wvi64(self.inMoney)
        -- moneyBase
        self.moneyBase:Write(om)
        -- giftInfo
        self.giftInfo:Write(om)
    end
}
PKG_Support_Other_SlotReRundRet.__index = PKG_Support_Other_SlotReRundRet

--[[
返回所有彩金信息
]]
PKG_Support_Other_AllLotteryRet = {
    typeName = "PKG_Support_Other_AllLotteryRet",
    typeId = 20306,
    Create = function(o)
        if o == nil then
            o = {}
            setmetatable(o, PKG_Support_Other_AllLotteryRet)
        end
        o.lotterys = {} -- List<PKG.BaseInfo.LotteryInfo>
        return o
    end,
    Read = function(self, om)
        local d = om.d
        local r, n, o
        -- lotterys
        r, len = d:Rvu32()
        if len > d:GetLeft() then return -1 end
        o = {}
        self.lotterys = o
        for i = 1, len do
            o[i] = PKG_BaseInfo_LotteryInfo.Create(); r = o[i]:Read(om)
            if r ~= 0 then return r end
        end
        if r ~= 0 then return r end
        return 0
    end,
    Write = function(self, om)
        local d = om.d
        local o, len
        -- lotterys
        o = self.lotterys
        len = #o
        d:Wvu32(len)
        for i = 1, len do
            o[i]:Write(om)
        end
    end
}
PKG_Support_Other_AllLotteryRet.__index = PKG_Support_Other_AllLotteryRet

--[[
请求退钱
]]
PKG_Other_Support_ReqSlotReRund = {
    typeName = "PKG_Other_Support_ReqSlotReRund",
    typeId = 20115,
    Create = function(o)
        if o == nil then
            o = {}
            setmetatable(o, PKG_Other_Support_ReqSlotReRund)
        end
        --[[
        玩家ID
        ]]
        o.guid = 0 -- Int32
        --[[
        游戏级别
        ]]
        o.levelId = 0 -- Int32
        --[[
        游戏服ID
        ]]
        o.gameId = 0 -- UInt32
        --[[
        押注金额
        ]]
        o.inMoney = 0 -- Int64
        --[[
        需要退还的金额
        ]]
        o.reRundGet = 0 -- Int64
        --[[
        0代表没有押注彩金/其他表示该次退款被打下的彩金
        ]]
        o.lotteryId = 0 -- Int32
        --[[
        押注金币类型 0 是普通金币 1是绑定金币
        ]]
        o.moneyType = 0 -- UInt32
        return o
    end,
    Read = function(self, om)
        local d = om.d
        local r, n
        -- guid
        r, self.guid = d:Rvi32()
        if r ~= 0 then return r end
        -- levelId
        r, self.levelId = d:Rvi32()
        if r ~= 0 then return r end
        -- gameId
        r, self.gameId = d:Rvu32()
        if r ~= 0 then return r end
        -- inMoney
        r, self.inMoney = d:Rvi64()
        if r ~= 0 then return r end
        -- reRundGet
        r, self.reRundGet = d:Rvi64()
        if r ~= 0 then return r end
        -- lotteryId
        r, self.lotteryId = d:Rvi32()
        if r ~= 0 then return r end
        -- moneyType
        r, self.moneyType = d:Rvu32()
        if r ~= 0 then return r end
        return 0
    end,
    Write = function(self, om)
        local d = om.d
        -- guid
        d:Wvi32(self.guid)
        -- levelId
        d:Wvi32(self.levelId)
        -- gameId
        d:Wvu32(self.gameId)
        -- inMoney
        d:Wvi64(self.inMoney)
        -- reRundGet
        d:Wvi64(self.reRundGet)
        -- lotteryId
        d:Wvi32(self.lotteryId)
        -- moneyType
        d:Wvu32(self.moneyType)
    end
}
PKG_Other_Support_ReqSlotReRund.__index = PKG_Other_Support_ReqSlotReRund

--[[
一组算分结果返回
]]
PKG_Support_Other_SlotCountRets = {
    typeName = "PKG_Support_Other_SlotCountRets",
    typeId = 20309,
    Create = function(o)
        if o == nil then
            o = {}
            setmetatable(o, PKG_Support_Other_SlotCountRets)
        end
        o.code = 0 -- Int32
        o.rets = {} -- List<Shared<PKG.Support_Other.SlotCountRet>>
        return o
    end,
    Read = function(self, om)
        local d = om.d
        local r, n, o
        -- code
        r, self.code = d:Rvi32()
        if r ~= 0 then return r end
        -- rets
        r, len = d:Rvu32()
        if len > d:GetLeft() then return -1 end
        o = {}
        self.rets = o
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
        -- code
        d:Wvi32(self.code)
        -- rets
        o = self.rets
        len = #o
        d:Wvu32(len)
        for i = 1, len do
            om:Write(o[i])
        end
    end
}
PKG_Support_Other_SlotCountRets.__index = PKG_Support_Other_SlotCountRets

--[[
老虎机机器人打掉彩金
]]
PKG_Support_Other_RobotSpinLotterySucces = {
    typeName = "PKG_Support_Other_RobotSpinLotterySucces",
    typeId = 20310,
    Create = function(o)
        if o == nil then
            o = {}
            setmetatable(o, PKG_Support_Other_RobotSpinLotterySucces)
        end
        --[[
        机器人id
        ]]
        o.accountId = 0 -- Int32
        --[[
        机器人旋转金币
        ]]
        o.betMoney = 0 -- Int64
        --[[
        彩金id
        ]]
        o.lotteryId = 0 -- Int32
        --[[
        对应金币
        ]]
        o.money = 0 -- Int64
        return o
    end,
    Read = function(self, om)
        local d = om.d
        local r, n
        -- accountId
        r, self.accountId = d:Rvi32()
        if r ~= 0 then return r end
        -- betMoney
        r, self.betMoney = d:Rvi64()
        if r ~= 0 then return r end
        -- lotteryId
        r, self.lotteryId = d:Rvi32()
        if r ~= 0 then return r end
        -- money
        r, self.money = d:Rvi64()
        if r ~= 0 then return r end
        return 0
    end,
    Write = function(self, om)
        local d = om.d
        -- accountId
        d:Wvi32(self.accountId)
        -- betMoney
        d:Wvi64(self.betMoney)
        -- lotteryId
        d:Wvi32(self.lotteryId)
        -- money
        d:Wvi64(self.money)
    end
}
PKG_Support_Other_RobotSpinLotterySucces.__index = PKG_Support_Other_RobotSpinLotterySucces

--[[
鱼机器人打掉彩金
]]
PKG_Support_Other_RobotHitLotterySucces = {
    typeName = "PKG_Support_Other_RobotHitLotterySucces",
    typeId = 20311,
    Create = function(o)
        if o == nil then
            o = {}
            setmetatable(o, PKG_Support_Other_RobotHitLotterySucces)
        end
        --[[
        房间Id
        ]]
        o.roomId = 0 -- Int32
        --[[
        游戏Id
        ]]
        o.gameId = 0 -- UInt32
        --[[
        级别Id
        ]]
        o.levelId = 0 -- Int32
        --[[
        机器人id
        ]]
        o.accountId = 0 -- Int32
        --[[
        机器人旋转金币
        ]]
        o.betMoney = 0 -- Int64
        --[[
        彩金id
        ]]
        o.lotteryId = 0 -- Int32
        --[[
        对应金币
        ]]
        o.money = 0 -- Int64
        return o
    end,
    Read = function(self, om)
        local d = om.d
        local r, n
        -- roomId
        r, self.roomId = d:Rvi32()
        if r ~= 0 then return r end
        -- gameId
        r, self.gameId = d:Rvu32()
        if r ~= 0 then return r end
        -- levelId
        r, self.levelId = d:Rvi32()
        if r ~= 0 then return r end
        -- accountId
        r, self.accountId = d:Rvi32()
        if r ~= 0 then return r end
        -- betMoney
        r, self.betMoney = d:Rvi64()
        if r ~= 0 then return r end
        -- lotteryId
        r, self.lotteryId = d:Rvi32()
        if r ~= 0 then return r end
        -- money
        r, self.money = d:Rvi64()
        if r ~= 0 then return r end
        return 0
    end,
    Write = function(self, om)
        local d = om.d
        -- roomId
        d:Wvi32(self.roomId)
        -- gameId
        d:Wvu32(self.gameId)
        -- levelId
        d:Wvi32(self.levelId)
        -- accountId
        d:Wvi32(self.accountId)
        -- betMoney
        d:Wvi64(self.betMoney)
        -- lotteryId
        d:Wvi32(self.lotteryId)
        -- money
        d:Wvi64(self.money)
    end
}
PKG_Support_Other_RobotHitLotterySucces.__index = PKG_Support_Other_RobotHitLotterySucces

--[[
操作保险箱结果
]]
PKG_Support_Other_PlayerStoreResult = {
    typeName = "PKG_Support_Other_PlayerStoreResult",
    typeId = 20312,
    Create = function(o)
        if o == nil then
            o = {}
            setmetatable(o, PKG_Support_Other_PlayerStoreResult)
        end
        o.status = 0 -- Int32
        o.accountId = 0 -- Int32
        o.moneyBase = PKG_BaseInfo_AccountMoney.Create() -- PKG.BaseInfo.AccountMoney
        o.giftInfo = PKG_BaseInfo_AccountMoneyGift.Create() -- PKG.BaseInfo.AccountMoneyGift
        return o
    end,
    Read = function(self, om)
        local d = om.d
        local r, n
        -- status
        r, self.status = d:Rvi32()
        if r ~= 0 then return r end
        -- accountId
        r, self.accountId = d:Rvi32()
        if r ~= 0 then return r end
        -- moneyBase
        self.moneyBase = PKG_BaseInfo_AccountMoney.Create(); r = self.moneyBase:Read(om)
        if r ~= 0 then return r end
        -- giftInfo
        self.giftInfo = PKG_BaseInfo_AccountMoneyGift.Create(); r = self.giftInfo:Read(om)
        if r ~= 0 then return r end
        return 0
    end,
    Write = function(self, om)
        local d = om.d
        -- status
        d:Wvi32(self.status)
        -- accountId
        d:Wvi32(self.accountId)
        -- moneyBase
        self.moneyBase:Write(om)
        -- giftInfo
        self.giftInfo:Write(om)
    end
}
PKG_Support_Other_PlayerStoreResult.__index = PKG_Support_Other_PlayerStoreResult

--[[
打中鱼结果(多条请求打包处理)
]]
PKG_Support_Other_HitFishRet = {
    typeName = "PKG_Support_Other_HitFishRet",
    typeId = 20313,
    Create = function(o)
        if o == nil then
            o = {}
            setmetatable(o, PKG_Support_Other_HitFishRet)
        end
        o.code = 0 -- Int32
        o.groups = {} -- List<PKG.BaseInfo.HitInfoRetGroup>
        return o
    end,
    Read = function(self, om)
        local d = om.d
        local r, n, o
        -- code
        r, self.code = d:Rvi32()
        if r ~= 0 then return r end
        -- groups
        r, len = d:Rvu32()
        if len > d:GetLeft() then return -1 end
        o = {}
        self.groups = o
        for i = 1, len do
            o[i] = PKG_BaseInfo_HitInfoRetGroup.Create(); r = o[i]:Read(om)
            if r ~= 0 then return r end
        end
        if r ~= 0 then return r end
        return 0
    end,
    Write = function(self, om)
        local d = om.d
        local o, len
        -- code
        d:Wvi32(self.code)
        -- groups
        o = self.groups
        len = #o
        d:Wvu32(len)
        for i = 1, len do
            o[i]:Write(om)
        end
    end
}
PKG_Support_Other_HitFishRet.__index = PKG_Support_Other_HitFishRet

--[[
返回某个游戏的彩金信息
]]
PKG_Support_Other_OneGameLotteryRet = {
    typeName = "PKG_Support_Other_OneGameLotteryRet",
    typeId = 20307,
    Create = function(o)
        if o == nil then
            o = {}
            setmetatable(o, PKG_Support_Other_OneGameLotteryRet)
        end
        o.infos = {} -- List<PKG.BaseInfo.LotteryInfo>
        return o
    end,
    Read = function(self, om)
        local d = om.d
        local r, n, o
        -- infos
        r, len = d:Rvu32()
        if len > d:GetLeft() then return -1 end
        o = {}
        self.infos = o
        for i = 1, len do
            o[i] = PKG_BaseInfo_LotteryInfo.Create(); r = o[i]:Read(om)
            if r ~= 0 then return r end
        end
        if r ~= 0 then return r end
        return 0
    end,
    Write = function(self, om)
        local d = om.d
        local o, len
        -- infos
        o = self.infos
        len = #o
        d:Wvu32(len)
        for i = 1, len do
            o[i]:Write(om)
        end
    end
}
PKG_Support_Other_OneGameLotteryRet.__index = PKG_Support_Other_OneGameLotteryRet

--[[
活动请求计算
]]
PKG_Other_Support_ReqActivityCount = {
    typeName = "PKG_Other_Support_ReqActivityCount",
    typeId = 20116,
    Create = function(o)
        if o == nil then
            o = {}
            setmetatable(o, PKG_Other_Support_ReqActivityCount)
        end
        --[[
        玩家ID
        ]]
        o.guid = 0 -- Int32
        --[[
        押注金额
        ]]
        o.inMoney = 0 -- Int64
        --[[
        期望获得的金额
        ]]
        o.hopeGet = 0 -- Int64
        return o
    end,
    Read = function(self, om)
        local d = om.d
        local r, n
        -- guid
        r, self.guid = d:Rvi32()
        if r ~= 0 then return r end
        -- inMoney
        r, self.inMoney = d:Rvi64()
        if r ~= 0 then return r end
        -- hopeGet
        r, self.hopeGet = d:Rvi64()
        if r ~= 0 then return r end
        return 0
    end,
    Write = function(self, om)
        local d = om.d
        -- guid
        d:Wvi32(self.guid)
        -- inMoney
        d:Wvi64(self.inMoney)
        -- hopeGet
        d:Wvi64(self.hopeGet)
    end
}
PKG_Other_Support_ReqActivityCount.__index = PKG_Other_Support_ReqActivityCount

local o = ObjMgr
o.Register(PKG_Other_Support_ReqSlotCounter)
o.Register(PKG_Support_Other_SlotCountRet)
o.Register(PKG_Other_Support_LobbyConn)
o.Register(PKG_Other_Support_SlotsConn)
o.Register(PKG_Other_Support_FishConn)
o.Register(PKG_Other_Support_Enter)
o.Register(PKG_Other_Support_Leave)
o.Register(PKG_Other_Support_ReqAllLottery)
o.Register(PKG_Other_Support_ReqOneGameLottery)
o.Register(PKG_Other_Support_ReqSlotCounters)
o.Register(PKG_Other_Support_RobotSpinLottery)
o.Register(PKG_Other_Support_RobotHitLottery)
o.Register(PKG_Other_Support_PlayerStore)
o.Register(PKG_Other_Support_HitFish)
o.Register(PKG_Other_Support_ReqSlotSpin)
o.Register(PKG_Support_Other_UpdateDataStatistics)
o.Register(PKG_Support_Other_ActivityCountRet)
o.Register(PKG_Support_Other_SlotSpinRet)
o.Register(PKG_Support_Other_FishConnRet)
o.Register(PKG_Support_Other_EnterRet)
o.Register(PKG_Support_Other_LeaveRet)
o.Register(PKG_Support_Other_OneServiceSaved)
o.Register(PKG_Support_Other_RegisterToLobby)
o.Register(PKG_Support_Other_SlotReRundRet)
o.Register(PKG_Support_Other_AllLotteryRet)
o.Register(PKG_Other_Support_ReqSlotReRund)
o.Register(PKG_Support_Other_SlotCountRets)
o.Register(PKG_Support_Other_RobotSpinLotterySucces)
o.Register(PKG_Support_Other_RobotHitLotterySucces)
o.Register(PKG_Support_Other_PlayerStoreResult)
o.Register(PKG_Support_Other_HitFishRet)
o.Register(PKG_Support_Other_OneGameLotteryRet)
o.Register(PKG_Other_Support_ReqActivityCount)