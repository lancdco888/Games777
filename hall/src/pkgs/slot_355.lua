
require('g_net')
CodeGen_slot_340_md5 ="#*MD5<44f391e0742f39f3689381ec312c5759>*#"

--[[
Sugar请求特殊旋转图形
]]
PKG_Panda_NormalSpin = {
    typeName = "PKG_Panda_NormalSpin",
    typeId = 34001,
    Create = function(o)
        if o == nil then
            o = {}
            setmetatable(o, PKG_Panda_NormalSpin)
        end
        o.betMoney = 0 -- Int64
        o.grids = {} -- List<PKG.Panda.Cell>
        o.lines = {} -- List<PKG.Panda.Line>
        o.slotMoneyGift = PKG_SlotsBase_SlotMoneyGift.Create() -- PKG.SlotsBase.SlotMoneyGift
        o.slotMoney = PKG_SlotsBase_SlotMoney.Create() -- PKG.SlotsBase.SlotMoney
        o.levelUpMoney = 0 -- Int64
        o.levelUpMoneys = {} -- List<Int64>
        o.emitSpecialType = 0 -- Int32
        o.curWinCoin = 0 -- Int64
        return o
    end,
    Read = function(self, om)
        local d = om.d
        local r, n, o
        -- betMoney
        r, self.betMoney = d:Rvi64()
        if r ~= 0 then return r end
        -- grids
        r, len = d:Rvu32()
        if len > d:GetLeft() then return -1 end
        o = {}
        self.grids = o
        for i = 1, len do
            o[i] = PKG_Panda_Cell.Create(); r = o[i]:Read(om)
            if r ~= 0 then return r end
        end
        if r ~= 0 then return r end
        -- lines
        r, len = d:Rvu32()
        if len > d:GetLeft() then return -1 end
        o = {}
        self.lines = o
        for i = 1, len do
            o[i] = PKG_Panda_Line.Create(); r = o[i]:Read(om)
            if r ~= 0 then return r end
        end
        if r ~= 0 then return r end
        -- slotMoneyGift
        self.slotMoneyGift = PKG_SlotsBase_SlotMoneyGift.Create(); r = self.slotMoneyGift:Read(om)
        if r ~= 0 then return r end
        -- slotMoney
        self.slotMoney = PKG_SlotsBase_SlotMoney.Create(); r = self.slotMoney:Read(om)
        if r ~= 0 then return r end
        -- levelUpMoney
        r, self.levelUpMoney = d:Rvi64()
        if r ~= 0 then return r end
        -- levelUpMoneys
        r, len = d:Rvu32()
        if len > d:GetLeft() then return -1 end
        o = {}
        self.levelUpMoneys = o
        for i = 1, len do
            r, o[i] = d:Rvi64()
            if r ~= 0 then return r end
        end
        if r ~= 0 then return r end
        -- emitSpecialType
        r, self.emitSpecialType = d:Rvi32()
        if r ~= 0 then return r end
        -- curWinCoin
        r, self.curWinCoin = d:Rvi64()
        if r ~= 0 then return r end
        return 0
    end,
    Write = function(self, om)
        local d = om.d
        local o, len
        -- betMoney
        d:Wvi64(self.betMoney)
        -- grids
        o = self.grids
        len = #o
        d:Wvu32(len)
        for i = 1, len do
            o[i]:Write(om)
        end
        -- lines
        o = self.lines
        len = #o
        d:Wvu32(len)
        for i = 1, len do
            o[i]:Write(om)
        end
        -- slotMoneyGift
        self.slotMoneyGift:Write(om)
        -- slotMoney
        self.slotMoney:Write(om)
        -- levelUpMoney
        d:Wvi64(self.levelUpMoney)
        -- levelUpMoneys
        o = self.levelUpMoneys
        len = #o
        d:Wvu32(len)
        for i = 1, len do
            d:Wvi64(o[i])
        end
        -- emitSpecialType
        d:Wvi32(self.emitSpecialType)
        -- curWinCoin
        d:Wvi64(self.curWinCoin)
    end
}
PKG_Panda_NormalSpin.__index = PKG_Panda_NormalSpin

--[[
Sugar请求免费旋转图形
]]
PKG_Panda_FreeSpin = {
    typeName = "PKG_Panda_FreeSpin",
    typeId = 34002,
    Create = function(o)
        if o == nil then
            o = {}
            setmetatable(o, PKG_Panda_FreeSpin)
        end
        o.betMoney = 0 -- Int64
        o.slotMoneyGift = PKG_SlotsBase_SlotMoneyGift.Create() -- PKG.SlotsBase.SlotMoneyGift
        o.slotMoney = PKG_SlotsBase_SlotMoney.Create() -- PKG.SlotsBase.SlotMoney
        o.grids = {} -- List<PKG.Panda.Cell>
        o.lines = {} -- List<PKG.Panda.Line>
        o.emitSpecialType = 0 -- Int32
        o.curWinCoin = 0 -- Int64
        o.freeGameTotalCount = 0 -- Int32
        o.freeGameCurCount = 0 -- Int32
        o.restRoundCount = 0 -- Int32
        o.beforeBitVal = 0 -- Int32
        o.afterBitVal = 0 -- Int32
        o.curFreeMode = 0 -- Int32
        o.nextFreeMode = 0 -- Int32
        o.totalWinCoin = 0 -- Int64
        return o
    end,
    Read = function(self, om)
        local d = om.d
        local r, n, o
        -- betMoney
        r, self.betMoney = d:Rvi64()
        if r ~= 0 then return r end
        -- slotMoneyGift
        self.slotMoneyGift = PKG_SlotsBase_SlotMoneyGift.Create(); r = self.slotMoneyGift:Read(om)
        if r ~= 0 then return r end
        -- slotMoney
        self.slotMoney = PKG_SlotsBase_SlotMoney.Create(); r = self.slotMoney:Read(om)
        if r ~= 0 then return r end
        -- grids
        r, len = d:Rvu32()
        if len > d:GetLeft() then return -1 end
        o = {}
        self.grids = o
        for i = 1, len do
            o[i] = PKG_Panda_Cell.Create(); r = o[i]:Read(om)
            if r ~= 0 then return r end
        end
        if r ~= 0 then return r end
        -- lines
        r, len = d:Rvu32()
        if len > d:GetLeft() then return -1 end
        o = {}
        self.lines = o
        for i = 1, len do
            o[i] = PKG_Panda_Line.Create(); r = o[i]:Read(om)
            if r ~= 0 then return r end
        end
        if r ~= 0 then return r end
        -- emitSpecialType
        r, self.emitSpecialType = d:Rvi32()
        if r ~= 0 then return r end
        -- curWinCoin
        r, self.curWinCoin = d:Rvi64()
        if r ~= 0 then return r end
        -- freeGameTotalCount
        r, self.freeGameTotalCount = d:Rvi32()
        if r ~= 0 then return r end
        -- freeGameCurCount
        r, self.freeGameCurCount = d:Rvi32()
        if r ~= 0 then return r end
        -- restRoundCount
        r, self.restRoundCount = d:Rvi32()
        if r ~= 0 then return r end
        -- beforeBitVal
        r, self.beforeBitVal = d:Rvi32()
        if r ~= 0 then return r end
        -- afterBitVal
        r, self.afterBitVal = d:Rvi32()
        if r ~= 0 then return r end
        -- curFreeMode
        r, self.curFreeMode = d:Rvi32()
        if r ~= 0 then return r end
        -- nextFreeMode
        r, self.nextFreeMode = d:Rvi32()
        if r ~= 0 then return r end
        -- totalWinCoin
        r, self.totalWinCoin = d:Rvi64()
        if r ~= 0 then return r end
        return 0
    end,
    Write = function(self, om)
        local d = om.d
        local o, len
        -- betMoney
        d:Wvi64(self.betMoney)
        -- slotMoneyGift
        self.slotMoneyGift:Write(om)
        -- slotMoney
        self.slotMoney:Write(om)
        -- grids
        o = self.grids
        len = #o
        d:Wvu32(len)
        for i = 1, len do
            o[i]:Write(om)
        end
        -- lines
        o = self.lines
        len = #o
        d:Wvu32(len)
        for i = 1, len do
            o[i]:Write(om)
        end
        -- emitSpecialType
        d:Wvi32(self.emitSpecialType)
        -- curWinCoin
        d:Wvi64(self.curWinCoin)
        -- freeGameTotalCount
        d:Wvi32(self.freeGameTotalCount)
        -- freeGameCurCount
        d:Wvi32(self.freeGameCurCount)
        -- restRoundCount
        d:Wvi32(self.restRoundCount)
        -- beforeBitVal
        d:Wvi32(self.beforeBitVal)
        -- afterBitVal
        d:Wvi32(self.afterBitVal)
        -- curFreeMode
        d:Wvi32(self.curFreeMode)
        -- nextFreeMode
        d:Wvi32(self.nextFreeMode)
        -- totalWinCoin
        d:Wvi64(self.totalWinCoin)
    end
}
PKG_Panda_FreeSpin.__index = PKG_Panda_FreeSpin

--[[
进入游戏成功
]]
PKG_Slots_Client_Enter_Success = {
    typeName = "PKG_Slots_Client_Enter_Success",
    typeId = 30104,
    Create = function(o)
        if o == nil then
            o = {}
            setmetatable(o, PKG_Slots_Client_Enter_Success)
        end
        --[[
        用户Id ( 随机 8 位整数 )
        ]]
        o.accountId = 0 -- Int32
        --[[
        原始用户名 唯一( GUID )
        ]]
        o.userName = "" -- String
        --[[
        昵称 唯一( 默认用某种规则生成 )
        ]]
        o.nickName = "" -- String
        --[[
        头像
        ]]
        o.avatarId = 0 -- Int32
        --[[
        玩家进游戏身上的金币
        ]]
        o.enterMoney = 0 -- Double
        --[[
        玩家进游戏保险箱的金币
        ]]
        o.enterMoneySalfe = 0 -- Double
        --[[
        玩家进游戏身上的赠送金币
        ]]
        o.enterMoneyGift = 0 -- Double
        --[[
        玩家进游戏保险箱中的赠送金币
        ]]
        o.enterMoneyGiftSafe = 0 -- Double
        --[[
        押注金额和押注数的对应关系
        ]]
        o.betRatios = {} -- List<PKG.SlotsBase.BetRatio>
        --[[
        各个级别的进入条件
        ]]
        o.entryConditions = {} -- List<PKG.SlotsBase.EntryConditions>
        --[[
        总桌数
        ]]
        o.tableSize = 0 -- Int32
        --[[
        每一桌的椅子数
        ]]
        o.chairSize = 0 -- Int32
        --[[
        桌子ID,为0表示在选座列表
        ]]
        o.tableId = 0 -- Int32
        --[[
        椅子ID,为0表示在选座列表
        ]]
        o.chairId = 0 -- Int32
        --[[
        选座列表上看到在游戏里中的玩家信息
        ]]
        o.players = {} -- List<PKG.SlotsBase.GamingPlayer>
        o.enterSlotMoneyGift = PKG_SlotsBase_SlotMoneyGift.Create() -- PKG.SlotsBase.SlotMoneyGift
        o.enterSlotMoney = PKG_SlotsBase_SlotMoney.Create() -- PKG.SlotsBase.SlotMoney
        o.moneyType = 0 -- Int32
        return o
    end,
    Read = function(self, om)
        local d = om.d
        local r, n, o
        -- accountId
        r, self.accountId = d:Rvi32()
        if r ~= 0 then return r end
        -- userName
        r, self.userName = d:Rstr()
        if r ~= 0 then return r end
        -- nickName
        r, self.nickName = d:Rstr()
        if r ~= 0 then return r end
        -- avatarId
        r, self.avatarId = d:Rvi32()
        if r ~= 0 then return r end
        -- enterMoney
        r, self.enterMoney = d:Rd()
        if r ~= 0 then return r end
        -- enterMoneySalfe
        r, self.enterMoneySalfe = d:Rd()
        if r ~= 0 then return r end
        -- enterMoneyGift
        r, self.enterMoneyGift = d:Rd()
        if r ~= 0 then return r end
        -- enterMoneyGiftSafe
        r, self.enterMoneyGiftSafe = d:Rd()
        if r ~= 0 then return r end
        -- betRatios
        r, len = d:Rvu32()
        if len > d:GetLeft() then return -1 end
        o = {}
        self.betRatios = o
        for i = 1, len do
            o[i] = PKG_SlotsBase_BetRatio.Create(); r = o[i]:Read(om)
            if r ~= 0 then return r end
        end
        if r ~= 0 then return r end
        -- entryConditions
        r, len = d:Rvu32()
        if len > d:GetLeft() then return -1 end
        o = {}
        self.entryConditions = o
        for i = 1, len do
            o[i] = PKG_SlotsBase_EntryConditions.Create(); r = o[i]:Read(om)
            if r ~= 0 then return r end
        end
        if r ~= 0 then return r end
        -- tableSize
        r, self.tableSize = d:Rvi32()
        if r ~= 0 then return r end
        -- chairSize
        r, self.chairSize = d:Rvi32()
        if r ~= 0 then return r end
        -- tableId
        r, self.tableId = d:Rvi32()
        if r ~= 0 then return r end
        -- chairId
        r, self.chairId = d:Rvi32()
        if r ~= 0 then return r end
        -- players
        r, len = d:Rvu32()
        if len > d:GetLeft() then return -1 end
        o = {}
        self.players = o
        for i = 1, len do
            o[i] = PKG_SlotsBase_GamingPlayer.Create(); r = o[i]:Read(om)
            if r ~= 0 then return r end
        end
        if r ~= 0 then return r end
        -- enterSlotMoneyGift
        self.enterSlotMoneyGift = PKG_SlotsBase_SlotMoneyGift.Create(); r = self.enterSlotMoneyGift:Read(om)
        if r ~= 0 then return r end
        -- enterSlotMoney
        self.enterSlotMoney = PKG_SlotsBase_SlotMoney.Create(); r = self.enterSlotMoney:Read(om)
        if r ~= 0 then return r end
        -- moneyType
        r, self.moneyType = d:Rvi32()
        if r ~= 0 then return r end
        return 0
    end,
    Write = function(self, om)
        local d = om.d
        local o, len
        -- accountId
        d:Wvi32(self.accountId)
        -- userName
        d:Wstr(self.userName)
        -- nickName
        d:Wstr(self.nickName)
        -- avatarId
        d:Wvi32(self.avatarId)
        -- enterMoney
        d:Wd(self.enterMoney)
        -- enterMoneySalfe
        d:Wd(self.enterMoneySalfe)
        -- enterMoneyGift
        d:Wd(self.enterMoneyGift)
        -- enterMoneyGiftSafe
        d:Wd(self.enterMoneyGiftSafe)
        -- betRatios
        o = self.betRatios
        len = #o
        d:Wvu32(len)
        for i = 1, len do
            o[i]:Write(om)
        end
        -- entryConditions
        o = self.entryConditions
        len = #o
        d:Wvu32(len)
        for i = 1, len do
            o[i]:Write(om)
        end
        -- tableSize
        d:Wvi32(self.tableSize)
        -- chairSize
        d:Wvi32(self.chairSize)
        -- tableId
        d:Wvi32(self.tableId)
        -- chairId
        d:Wvi32(self.chairId)
        -- players
        o = self.players
        len = #o
        d:Wvu32(len)
        for i = 1, len do
            o[i]:Write(om)
        end
        -- enterSlotMoneyGift
        self.enterSlotMoneyGift:Write(om)
        -- enterSlotMoney
        self.enterSlotMoney:Write(om)
        -- moneyType
        d:Wvi32(self.moneyType)
    end
}
PKG_Slots_Client_Enter_Success.__index = PKG_Slots_Client_Enter_Success

--[[
普通结果
]]
PKG_Slots_Client_PandaNormalRet = {
    typeName = "PKG_Slots_Client_PandaNormalRet",
    typeId = 34020,
    Create = function(o)
        if o == nil then
            o = {}
            setmetatable(o, PKG_Slots_Client_PandaNormalRet)
        end
        o.normalSpin = PKG_Panda_NormalSpin.Create() -- PKG.Panda.NormalSpin
        return o
    end,
    Read = function(self, om)
        local d = om.d
        local r, n
        -- normalSpin
        self.normalSpin = PKG_Panda_NormalSpin.Create(); r = self.normalSpin:Read(om)
        if r ~= 0 then return r end
        return 0
    end,
    Write = function(self, om)
        local d = om.d
        -- normalSpin
        self.normalSpin:Write(om)
    end
}
PKG_Slots_Client_PandaNormalRet.__index = PKG_Slots_Client_PandaNormalRet

--[[
免费游戏结果
]]
PKG_Slots_Client_PandaFreeRet = {
    typeName = "PKG_Slots_Client_PandaFreeRet",
    typeId = 34021,
    Create = function(o)
        if o == nil then
            o = {}
            setmetatable(o, PKG_Slots_Client_PandaFreeRet)
        end
        o.freeSpin = PKG_Panda_FreeSpin.Create() -- PKG.Panda.FreeSpin
        return o
    end,
    Read = function(self, om)
        local d = om.d
        local r, n
        -- freeSpin
        self.freeSpin = PKG_Panda_FreeSpin.Create(); r = self.freeSpin:Read(om)
        if r ~= 0 then return r end
        return 0
    end,
    Write = function(self, om)
        local d = om.d
        -- freeSpin
        self.freeSpin:Write(om)
    end
}
PKG_Slots_Client_PandaFreeRet.__index = PKG_Slots_Client_PandaFreeRet

--[[
退出游戏成功
]]
PKG_Slots_Client_Leave_Success = {
    typeName = "PKG_Slots_Client_Leave_Success",
    typeId = 30102,
    Create = function(o)
        if o == nil then
            o = {}
            setmetatable(o, PKG_Slots_Client_Leave_Success)
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
PKG_Slots_Client_Leave_Success.__index = PKG_Slots_Client_Leave_Success

--[[
请求免费类型
]]
PKG_Client_Slots_PandaFreeSpin = {
    typeName = "PKG_Client_Slots_PandaFreeSpin",
    typeId = 34011,
    Create = function(o)
        if o == nil then
            o = {}
            setmetatable(o, PKG_Client_Slots_PandaFreeSpin)
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
PKG_Client_Slots_PandaFreeSpin.__index = PKG_Client_Slots_PandaFreeSpin

--[[
状态发送变化的玩家信息比如坐下去或者离开了
]]
PKG_Slots_Client_SyncPlayerStates = {
    typeName = "PKG_Slots_Client_SyncPlayerStates",
    typeId = 30105,
    Create = function(o)
        if o == nil then
            o = {}
            setmetatable(o, PKG_Slots_Client_SyncPlayerStates)
        end
        --[[
        选座列表上看到在游戏里中的玩家信息
        ]]
        o.player = PKG_SlotsBase_GamingPlayer.Create() -- PKG.SlotsBase.GamingPlayer
        --[[
        玩家动作 1坐下 2离开 
        ]]
        o.operate = 0 -- Int32
        return o
    end,
    Read = function(self, om)
        local d = om.d
        local r, n
        -- player
        self.player = PKG_SlotsBase_GamingPlayer.Create(); r = self.player:Read(om)
        if r ~= 0 then return r end
        -- operate
        r, self.operate = d:Rvi32()
        if r ~= 0 then return r end
        return 0
    end,
    Write = function(self, om)
        local d = om.d
        -- player
        self.player:Write(om)
        -- operate
        d:Wvi32(self.operate)
    end
}
PKG_Slots_Client_SyncPlayerStates.__index = PKG_Slots_Client_SyncPlayerStates

--[[
玩家收集进度
]]
PKG_Slots_Client_CollectValue = {
    typeName = "PKG_Slots_Client_CollectValue",
    typeId = 30106,
    Create = function(o)
        if o == nil then
            o = {}
            setmetatable(o, PKG_Slots_Client_CollectValue)
        end
        o.nowValue = 0 -- Int32
        return o
    end,
    Read = function(self, om)
        local d = om.d
        local r, n
        -- nowValue
        r, self.nowValue = d:Rvi32()
        if r ~= 0 then return r end
        return 0
    end,
    Write = function(self, om)
        local d = om.d
        -- nowValue
        d:Wvi32(self.nowValue)
    end
}
PKG_Slots_Client_CollectValue.__index = PKG_Slots_Client_CollectValue

--[[
断线重连数据恢复
]]
PKG_Slots_Client_PandaEnterResumed = {
    typeName = "PKG_Slots_Client_PandaEnterResumed",
    typeId = 34022,
    Create = function(o)
        if o == nil then
            o = {}
            setmetatable(o, PKG_Slots_Client_PandaEnterResumed)
        end
        --[[
        进入游戏的常规数据恢复
        ]]
        o.enterBase = PKG_Slots_Client_Enter_Success.Create() -- PKG.Slots_Client.Enter_Success
        --[[
        当前押注金额
        ]]
        o.currentBetMoney = 0 -- Double
        --[[
        当前押注等级
        ]]
        o.lvID = 0 -- Int32
        o.resumedNormal = PKG_Slots_Client_PandaNormalRet.Create() -- PKG.Slots_Client.PandaNormalRet
        o.resumedFree = PKG_Slots_Client_PandaFreeRet.Create() -- PKG.Slots_Client.PandaFreeRet
        o.lastMsgType = 0 -- Int32
        o.totalWinCoin = 0 -- Int64
        return o
    end,
    Read = function(self, om)
        local d = om.d
        local r, n
        -- enterBase
        self.enterBase = PKG_Slots_Client_Enter_Success.Create(); r = self.enterBase:Read(om)
        if r ~= 0 then return r end
        -- currentBetMoney
        r, self.currentBetMoney = d:Rd()
        if r ~= 0 then return r end
        -- lvID
        r, self.lvID = d:Rvi32()
        if r ~= 0 then return r end
        -- resumedNormal
        self.resumedNormal = PKG_Slots_Client_PandaNormalRet.Create(); r = self.resumedNormal:Read(om)
        if r ~= 0 then return r end
        -- resumedFree
        self.resumedFree = PKG_Slots_Client_PandaFreeRet.Create(); r = self.resumedFree:Read(om)
        if r ~= 0 then return r end
        -- lastMsgType
        r, self.lastMsgType = d:Rvi32()
        if r ~= 0 then return r end
        -- totalWinCoin
        r, self.totalWinCoin = d:Rvi64()
        if r ~= 0 then return r end
        return 0
    end,
    Write = function(self, om)
        local d = om.d
        -- enterBase
        self.enterBase:Write(om)
        -- currentBetMoney
        d:Wd(self.currentBetMoney)
        -- lvID
        d:Wvi32(self.lvID)
        -- resumedNormal
        self.resumedNormal:Write(om)
        -- resumedFree
        self.resumedFree:Write(om)
        -- lastMsgType
        d:Wvi32(self.lastMsgType)
        -- totalWinCoin
        d:Wvi64(self.totalWinCoin)
    end
}
PKG_Slots_Client_PandaEnterResumed.__index = PKG_Slots_Client_PandaEnterResumed

--[[
 普通旋转
]]
PKG_Client_Slots_PandaNormalSpin = {
    typeName = "PKG_Client_Slots_PandaNormalSpin",
    typeId = 34010,
    Create = function(o)
        if o == nil then
            o = {}
            setmetatable(o, PKG_Client_Slots_PandaNormalSpin)
        end
        --[[
        押注金额
        ]]
        o.betMoney = 0 -- Int64
        o.moneyType = 0 -- Int32
        --[[
        当前押注等级
        ]]
        o.lvID = 0 -- Int32
        return o
    end,
    Read = function(self, om)
        local d = om.d
        local r, n
        -- betMoney
        r, self.betMoney = d:Rvi64()
        if r ~= 0 then return r end
        -- moneyType
        r, self.moneyType = d:Rvi32()
        if r ~= 0 then return r end
        -- lvID
        r, self.lvID = d:Rvi32()
        if r ~= 0 then return r end
        return 0
    end,
    Write = function(self, om)
        local d = om.d
        -- betMoney
        d:Wvi64(self.betMoney)
        -- moneyType
        d:Wvi32(self.moneyType)
        -- lvID
        d:Wvi32(self.lvID)
    end
}
PKG_Client_Slots_PandaNormalSpin.__index = PKG_Client_Slots_PandaNormalSpin

--[[
玩家长时间未操作离线倒计时
]]
PKG_Slots_Client_OfflineCheck = {
    typeName = "PKG_Slots_Client_OfflineCheck",
    typeId = 30101,
    Create = function(o)
        if o == nil then
            o = {}
            setmetatable(o, PKG_Slots_Client_OfflineCheck)
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
PKG_Slots_Client_OfflineCheck.__index = PKG_Slots_Client_OfflineCheck

--[[
玩家锁住状态离开成功
]]
PKG_Slots_Client_LockLeaveSuccess = {
    typeName = "PKG_Slots_Client_LockLeaveSuccess",
    typeId = 30103,
    Create = function(o)
        if o == nil then
            o = {}
            setmetatable(o, PKG_Slots_Client_LockLeaveSuccess)
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
PKG_Slots_Client_LockLeaveSuccess.__index = PKG_Slots_Client_LockLeaveSuccess

PKG_SlotsBase_SlotMoneyGift = {
    typeName = "PKG_SlotsBase_SlotMoneyGift",
    Create = function(o)
        if o == nil then
            o = {}
            setmetatable(o, PKG_SlotsBase_SlotMoneyGift)
        end
        o.money_gift = 0 -- Int64
        o.money_gift_safe = 0 -- Int64
        o.amount_of_gift = 0 -- Int64
        return o
    end,
    Read = function(self, om)
        local d = om.d
        local r, n
        -- money_gift
        r, self.money_gift = d:Rvi64()
        if r ~= 0 then return r end
        -- money_gift_safe
        r, self.money_gift_safe = d:Rvi64()
        if r ~= 0 then return r end
        -- amount_of_gift
        r, self.amount_of_gift = d:Rvi64()
        if r ~= 0 then return r end
        return 0
    end,
    Write = function(self, om)
        local d = om.d
        -- money_gift
        d:Wvi64(self.money_gift)
        -- money_gift_safe
        d:Wvi64(self.money_gift_safe)
        -- amount_of_gift
        d:Wvi64(self.amount_of_gift)
    end
}
PKG_SlotsBase_SlotMoneyGift.__index = PKG_SlotsBase_SlotMoneyGift

PKG_SlotsBase_SlotMoney = {
    typeName = "PKG_SlotsBase_SlotMoney",
    Create = function(o)
        if o == nil then
            o = {}
            setmetatable(o, PKG_SlotsBase_SlotMoney)
        end
        o.money = 0 -- Int64
        o.money_safe = 0 -- Int64
        return o
    end,
    Read = function(self, om)
        local d = om.d
        local r, n
        -- money
        r, self.money = d:Rvi64()
        if r ~= 0 then return r end
        -- money_safe
        r, self.money_safe = d:Rvi64()
        if r ~= 0 then return r end
        return 0
    end,
    Write = function(self, om)
        local d = om.d
        -- money
        d:Wvi64(self.money)
        -- money_safe
        d:Wvi64(self.money_safe)
    end
}
PKG_SlotsBase_SlotMoney.__index = PKG_SlotsBase_SlotMoney

PKG_Panda_Cell = {
    typeName = "PKG_Panda_Cell",
    Create = function(o)
        if o == nil then
            o = {}
            setmetatable(o, PKG_Panda_Cell)
        end
        o.index = 0 -- Int32
        o.icon = 0 -- Int32
        o.flipIcon = 0 -- Int32
        o.flipVal = 0 -- Int32
        return o
    end,
    Read = function(self, om)
        local d = om.d
        local r, n
        -- index
        r, self.index = d:Rvi32()
        if r ~= 0 then return r end
        -- icon
        r, self.icon = d:Rvi32()
        if r ~= 0 then return r end
        -- flipIcon
        r, self.flipIcon = d:Rvi32()
        if r ~= 0 then return r end
        -- flipVal
        r, self.flipVal = d:Rvi32()
        if r ~= 0 then return r end
        return 0
    end,
    Write = function(self, om)
        local d = om.d
        -- index
        d:Wvi32(self.index)
        -- icon
        d:Wvi32(self.icon)
        -- flipIcon
        d:Wvi32(self.flipIcon)
        -- flipVal
        d:Wvi32(self.flipVal)
    end
}
PKG_Panda_Cell.__index = PKG_Panda_Cell

PKG_Panda_Line = {
    typeName = "PKG_Panda_Line",
    Create = function(o)
        if o == nil then
            o = {}
            setmetatable(o, PKG_Panda_Line)
        end
        --[[
        中奖线(eg:1号线)
        ]]
        o.lineIndex = 0 -- Int32
        --[[
        赢钱(当前线赢的金币)
        ]]
        o.winCoin = 0 -- Int64
        --[[
        一组中奖图标
        ]]
        o.icon = 0 -- Int32
        --[[
        一条线上的中奖集合
        ]]
        o.lineCells = {} -- List<PKG.Panda.Cell>
        return o
    end,
    Read = function(self, om)
        local d = om.d
        local r, n, o
        -- lineIndex
        r, self.lineIndex = d:Rvi32()
        if r ~= 0 then return r end
        -- winCoin
        r, self.winCoin = d:Rvi64()
        if r ~= 0 then return r end
        -- icon
        r, self.icon = d:Rvi32()
        if r ~= 0 then return r end
        -- lineCells
        r, len = d:Rvu32()
        if len > d:GetLeft() then return -1 end
        o = {}
        self.lineCells = o
        for i = 1, len do
            o[i] = PKG_Panda_Cell.Create(); r = o[i]:Read(om)
            if r ~= 0 then return r end
        end
        if r ~= 0 then return r end
        return 0
    end,
    Write = function(self, om)
        local d = om.d
        local o, len
        -- lineIndex
        d:Wvi32(self.lineIndex)
        -- winCoin
        d:Wvi64(self.winCoin)
        -- icon
        d:Wvi32(self.icon)
        -- lineCells
        o = self.lineCells
        len = #o
        d:Wvu32(len)
        for i = 1, len do
            o[i]:Write(om)
        end
    end
}
PKG_Panda_Line.__index = PKG_Panda_Line

--[[
游戏中的玩家的基本信息
]]
PKG_SlotsBase_GamingPlayer = {
    typeName = "PKG_SlotsBase_GamingPlayer",
    Create = function(o)
        if o == nil then
            o = {}
            setmetatable(o, PKG_SlotsBase_GamingPlayer)
        end
        --[[
        用户Id ( 随机 8 位整数 )
        ]]
        o.accountId = 0 -- Int32
        --[[
        原始用户名 唯一( GUID )
        ]]
        o.userName = "" -- String
        --[[
        昵称 唯一( 默认用某种规则生成 )
        ]]
        o.nickName = "" -- String
        --[[
        头像
        ]]
        o.avatarId = 0 -- Int32
        --[[
        桌子ID
        ]]
        o.tableId = 0 -- Int32
        --[[
        椅子ID
        ]]
        o.chairId = 0 -- Int32
        return o
    end,
    Read = function(self, om)
        local d = om.d
        local r, n
        -- accountId
        r, self.accountId = d:Rvi32()
        if r ~= 0 then return r end
        -- userName
        r, self.userName = d:Rstr()
        if r ~= 0 then return r end
        -- nickName
        r, self.nickName = d:Rstr()
        if r ~= 0 then return r end
        -- avatarId
        r, self.avatarId = d:Rvi32()
        if r ~= 0 then return r end
        -- tableId
        r, self.tableId = d:Rvi32()
        if r ~= 0 then return r end
        -- chairId
        r, self.chairId = d:Rvi32()
        if r ~= 0 then return r end
        return 0
    end,
    Write = function(self, om)
        local d = om.d
        -- accountId
        d:Wvi32(self.accountId)
        -- userName
        d:Wstr(self.userName)
        -- nickName
        d:Wstr(self.nickName)
        -- avatarId
        d:Wvi32(self.avatarId)
        -- tableId
        d:Wvi32(self.tableId)
        -- chairId
        d:Wvi32(self.chairId)
    end
}
PKG_SlotsBase_GamingPlayer.__index = PKG_SlotsBase_GamingPlayer

PKG_SlotsBase_BetRatio = {
    typeName = "PKG_SlotsBase_BetRatio",
    Create = function(o)
        if o == nil then
            o = {}
            setmetatable(o, PKG_SlotsBase_BetRatio)
        end
        --[[
        押注金额
        ]]
        o.betMoney = 0 -- Double
        --[[
        押注数
        ]]
        o.betLine = 0 -- Int32
        --[[
        等级
        ]]
        o.lvID = 0 -- Int32
        return o
    end,
    Read = function(self, om)
        local d = om.d
        local r, n
        -- betMoney
        r, self.betMoney = d:Rd()
        if r ~= 0 then return r end
        -- betLine
        r, self.betLine = d:Rvi32()
        if r ~= 0 then return r end
        -- lvID
        r, self.lvID = d:Rvi32()
        if r ~= 0 then return r end
        return 0
    end,
    Write = function(self, om)
        local d = om.d
        -- betMoney
        d:Wd(self.betMoney)
        -- betLine
        d:Wvi32(self.betLine)
        -- lvID
        d:Wvi32(self.lvID)
    end
}
PKG_SlotsBase_BetRatio.__index = PKG_SlotsBase_BetRatio

PKG_SlotsBase_EntryConditions = {
    typeName = "PKG_SlotsBase_EntryConditions",
    Create = function(o)
        if o == nil then
            o = {}
            setmetatable(o, PKG_SlotsBase_EntryConditions)
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
        描述名称
        ]]
        o.desc = "" -- String
        --[[
        c_value
        ]]
        o.c_value = 0 -- Int32
        --[[
        c_lottery_value
        ]]
        o.c_lottery_value = 0 -- Int32
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
        -- desc
        r, self.desc = d:Rstr()
        if r ~= 0 then return r end
        -- c_value
        r, self.c_value = d:Rvi32()
        if r ~= 0 then return r end
        -- c_lottery_value
        r, self.c_lottery_value = d:Rvi32()
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
        -- desc
        d:Wstr(self.desc)
        -- c_value
        d:Wvi32(self.c_value)
        -- c_lottery_value
        d:Wvi32(self.c_lottery_value)
    end
}
PKG_SlotsBase_EntryConditions.__index = PKG_SlotsBase_EntryConditions

local o = ObjMgr
o.Register(PKG_Panda_NormalSpin)
o.Register(PKG_Panda_FreeSpin)
o.Register(PKG_Slots_Client_Enter_Success)
o.Register(PKG_Slots_Client_PandaNormalRet)
o.Register(PKG_Slots_Client_PandaFreeRet)
o.Register(PKG_Slots_Client_Leave_Success)
o.Register(PKG_Client_Slots_PandaFreeSpin)
o.Register(PKG_Slots_Client_SyncPlayerStates)
o.Register(PKG_Slots_Client_CollectValue)
o.Register(PKG_Slots_Client_PandaEnterResumed)
o.Register(PKG_Client_Slots_PandaNormalSpin)
o.Register(PKG_Slots_Client_OfflineCheck)
o.Register(PKG_Slots_Client_LockLeaveSuccess)