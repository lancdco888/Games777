
CodeGen_slot_742_md5 ="#*MD5<cd2ba3075763bd952ef2a66b93cc2008>*#"

--[[
Sugar请求特殊旋转图形
]]
PKG_RichMummy_NormalSpin = {
    typeName = "PKG_RichMummy_NormalSpin",
    typeId = 43747,
    Create = function(o)
        if o == nil then
            o = {}
            setmetatable(o, PKG_RichMummy_NormalSpin)
        end
        o.betMoney = 0 -- Int64
        o.grids = {} -- List<PKG.RichMummy.Cell>
        o.lines = {} -- List<PKG.RichMummy.Line>
        o.slotMoneyGift = PKG_SlotsBase_SlotMoneyGift.Create() -- PKG.SlotsBase.SlotMoneyGift
        o.slotMoney = PKG_SlotsBase_SlotMoney.Create() -- PKG.SlotsBase.SlotMoney
        o.levelUpMoney = 0 -- Int64
        o.levelUpMoneys = {} -- List<Int64>
        o.curWinCoin = 0 -- Int64
        o.intoSpecial = 0 -- Int32
        o.intoCollect = 0 -- Int32
        o.intoFree = 0 -- Int32
        o.emitLottyGrids = {} -- List<PKG.RichMummy.Cell>
        o.enterTs = PKG_RichMummy_TsStatus.Create() -- PKG.RichMummy.TsStatus
        o.tsInfos = {} -- List<PKG.RichMummy.TsChange>
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
            o[i] = PKG_RichMummy_Cell.Create(); r = o[i]:Read(om)
            if r ~= 0 then return r end
        end
        if r ~= 0 then return r end
        -- lines
        r, len = d:Rvu32()
        if len > d:GetLeft() then return -1 end
        o = {}
        self.lines = o
        for i = 1, len do
            o[i] = PKG_RichMummy_Line.Create(); r = o[i]:Read(om)
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
        -- curWinCoin
        r, self.curWinCoin = d:Rvi64()
        if r ~= 0 then return r end
        -- intoSpecial
        r, self.intoSpecial = d:Rvi32()
        if r ~= 0 then return r end
        -- intoCollect
        r, self.intoCollect = d:Rvi32()
        if r ~= 0 then return r end
        -- intoFree
        r, self.intoFree = d:Rvi32()
        if r ~= 0 then return r end
        -- emitLottyGrids
        r, len = d:Rvu32()
        if len > d:GetLeft() then return -1 end
        o = {}
        self.emitLottyGrids = o
        for i = 1, len do
            o[i] = PKG_RichMummy_Cell.Create(); r = o[i]:Read(om)
            if r ~= 0 then return r end
        end
        if r ~= 0 then return r end
        -- enterTs
        self.enterTs = PKG_RichMummy_TsStatus.Create(); r = self.enterTs:Read(om)
        if r ~= 0 then return r end
        -- tsInfos
        r, len = d:Rvu32()
        if len > d:GetLeft() then return -1 end
        o = {}
        self.tsInfos = o
        for i = 1, len do
            o[i] = PKG_RichMummy_TsChange.Create(); r = o[i]:Read(om)
            if r ~= 0 then return r end
        end
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
        -- curWinCoin
        d:Wvi64(self.curWinCoin)
        -- intoSpecial
        d:Wvi32(self.intoSpecial)
        -- intoCollect
        d:Wvi32(self.intoCollect)
        -- intoFree
        d:Wvi32(self.intoFree)
        -- emitLottyGrids
        o = self.emitLottyGrids
        len = #o
        d:Wvu32(len)
        for i = 1, len do
            o[i]:Write(om)
        end
        -- enterTs
        self.enterTs:Write(om)
        -- tsInfos
        o = self.tsInfos
        len = #o
        d:Wvu32(len)
        for i = 1, len do
            o[i]:Write(om)
        end
    end
}
PKG_RichMummy_NormalSpin.__index = PKG_RichMummy_NormalSpin

--[[
Sugar请求特殊旋转图形
]]
PKG_RichMummy_FreeSpin = {
    typeName = "PKG_RichMummy_FreeSpin",
    typeId = 43748,
    Create = function(o)
        if o == nil then
            o = {}
            setmetatable(o, PKG_RichMummy_FreeSpin)
        end
        o.betMoney = 0 -- Int64
        o.slotMoneyGift = PKG_SlotsBase_SlotMoneyGift.Create() -- PKG.SlotsBase.SlotMoneyGift
        o.slotMoney = PKG_SlotsBase_SlotMoney.Create() -- PKG.SlotsBase.SlotMoney
        o.grids = {} -- List<PKG.RichMummy.Cell>
        o.lines = {} -- List<PKG.RichMummy.Line>
        o.curWinCoin = 0 -- Int64
        o.intoSpecial = 0 -- Int32
        o.intoCollect = 0 -- Int32
        o.intoFree = 0 -- Int32
        o.emitLottyGrids = {} -- List<PKG.RichMummy.Cell>
        o.enterTs = PKG_RichMummy_TsStatus.Create() -- PKG.RichMummy.TsStatus
        o.tsInfos = {} -- List<PKG.RichMummy.TsChange>
        o.restTimes = 0 -- Int32
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
            o[i] = PKG_RichMummy_Cell.Create(); r = o[i]:Read(om)
            if r ~= 0 then return r end
        end
        if r ~= 0 then return r end
        -- lines
        r, len = d:Rvu32()
        if len > d:GetLeft() then return -1 end
        o = {}
        self.lines = o
        for i = 1, len do
            o[i] = PKG_RichMummy_Line.Create(); r = o[i]:Read(om)
            if r ~= 0 then return r end
        end
        if r ~= 0 then return r end
        -- curWinCoin
        r, self.curWinCoin = d:Rvi64()
        if r ~= 0 then return r end
        -- intoSpecial
        r, self.intoSpecial = d:Rvi32()
        if r ~= 0 then return r end
        -- intoCollect
        r, self.intoCollect = d:Rvi32()
        if r ~= 0 then return r end
        -- intoFree
        r, self.intoFree = d:Rvi32()
        if r ~= 0 then return r end
        -- emitLottyGrids
        r, len = d:Rvu32()
        if len > d:GetLeft() then return -1 end
        o = {}
        self.emitLottyGrids = o
        for i = 1, len do
            o[i] = PKG_RichMummy_Cell.Create(); r = o[i]:Read(om)
            if r ~= 0 then return r end
        end
        if r ~= 0 then return r end
        -- enterTs
        self.enterTs = PKG_RichMummy_TsStatus.Create(); r = self.enterTs:Read(om)
        if r ~= 0 then return r end
        -- tsInfos
        r, len = d:Rvu32()
        if len > d:GetLeft() then return -1 end
        o = {}
        self.tsInfos = o
        for i = 1, len do
            o[i] = PKG_RichMummy_TsChange.Create(); r = o[i]:Read(om)
            if r ~= 0 then return r end
        end
        if r ~= 0 then return r end
        -- restTimes
        r, self.restTimes = d:Rvi32()
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
        -- curWinCoin
        d:Wvi64(self.curWinCoin)
        -- intoSpecial
        d:Wvi32(self.intoSpecial)
        -- intoCollect
        d:Wvi32(self.intoCollect)
        -- intoFree
        d:Wvi32(self.intoFree)
        -- emitLottyGrids
        o = self.emitLottyGrids
        len = #o
        d:Wvu32(len)
        for i = 1, len do
            o[i]:Write(om)
        end
        -- enterTs
        self.enterTs:Write(om)
        -- tsInfos
        o = self.tsInfos
        len = #o
        d:Wvu32(len)
        for i = 1, len do
            o[i]:Write(om)
        end
        -- restTimes
        d:Wvi32(self.restTimes)
    end
}
PKG_RichMummy_FreeSpin.__index = PKG_RichMummy_FreeSpin

--[[
Sugar请求免费旋转图形
]]
PKG_RichMummy_SpecialSpin = {
    typeName = "PKG_RichMummy_SpecialSpin",
    typeId = 43749,
    Create = function(o)
        if o == nil then
            o = {}
            setmetatable(o, PKG_RichMummy_SpecialSpin)
        end
        o.betMoney = 0 -- Int64
        o.slotMoneyGift = PKG_SlotsBase_SlotMoneyGift.Create() -- PKG.SlotsBase.SlotMoneyGift
        o.slotMoney = PKG_SlotsBase_SlotMoney.Create() -- PKG.SlotsBase.SlotMoney
        o.grids = {} -- List<PKG.RichMummy.Cell>
        o.lines = {} -- List<PKG.RichMummy.Line>
        o.curWinCoin = 0 -- Int64
        o.enterTs = PKG_RichMummy_TsStatus.Create() -- PKG.RichMummy.TsStatus
        o.directSwallowIndices = {} -- List<Int32>
        o.tsInfos = {} -- List<PKG.RichMummy.TsChange>
        o.growTimes = 0 -- Int32
        o.restTimes = 0 -- Int32
        o.lottyTotalWin = 0 -- Int64
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
            o[i] = PKG_RichMummy_Cell.Create(); r = o[i]:Read(om)
            if r ~= 0 then return r end
        end
        if r ~= 0 then return r end
        -- lines
        r, len = d:Rvu32()
        if len > d:GetLeft() then return -1 end
        o = {}
        self.lines = o
        for i = 1, len do
            o[i] = PKG_RichMummy_Line.Create(); r = o[i]:Read(om)
            if r ~= 0 then return r end
        end
        if r ~= 0 then return r end
        -- curWinCoin
        r, self.curWinCoin = d:Rvi64()
        if r ~= 0 then return r end
        -- enterTs
        self.enterTs = PKG_RichMummy_TsStatus.Create(); r = self.enterTs:Read(om)
        if r ~= 0 then return r end
        -- directSwallowIndices
        r, len = d:Rvu32()
        if len > d:GetLeft() then return -1 end
        o = {}
        self.directSwallowIndices = o
        for i = 1, len do
            r, o[i] = d:Rvi32()
            if r ~= 0 then return r end
        end
        if r ~= 0 then return r end
        -- tsInfos
        r, len = d:Rvu32()
        if len > d:GetLeft() then return -1 end
        o = {}
        self.tsInfos = o
        for i = 1, len do
            o[i] = PKG_RichMummy_TsChange.Create(); r = o[i]:Read(om)
            if r ~= 0 then return r end
        end
        if r ~= 0 then return r end
        -- growTimes
        r, self.growTimes = d:Rvi32()
        if r ~= 0 then return r end
        -- restTimes
        r, self.restTimes = d:Rvi32()
        if r ~= 0 then return r end
        -- lottyTotalWin
        r, self.lottyTotalWin = d:Rvi64()
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
        -- curWinCoin
        d:Wvi64(self.curWinCoin)
        -- enterTs
        self.enterTs:Write(om)
        -- directSwallowIndices
        o = self.directSwallowIndices
        len = #o
        d:Wvu32(len)
        for i = 1, len do
            d:Wvi32(o[i])
        end
        -- tsInfos
        o = self.tsInfos
        len = #o
        d:Wvu32(len)
        for i = 1, len do
            o[i]:Write(om)
        end
        -- growTimes
        d:Wvi32(self.growTimes)
        -- restTimes
        d:Wvi32(self.restTimes)
        -- lottyTotalWin
        d:Wvi64(self.lottyTotalWin)
    end
}
PKG_RichMummy_SpecialSpin.__index = PKG_RichMummy_SpecialSpin

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
PKG_Slots_Client_RichMummyNormalRet = {
    typeName = "PKG_Slots_Client_RichMummyNormalRet",
    typeId = 43750,
    Create = function(o)
        if o == nil then
            o = {}
            setmetatable(o, PKG_Slots_Client_RichMummyNormalRet)
        end
        o.normalSpin = PKG_RichMummy_NormalSpin.Create() -- PKG.RichMummy.NormalSpin
        return o
    end,
    Read = function(self, om)
        local d = om.d
        local r, n
        -- normalSpin
        self.normalSpin = PKG_RichMummy_NormalSpin.Create(); r = self.normalSpin:Read(om)
        if r ~= 0 then return r end
        return 0
    end,
    Write = function(self, om)
        local d = om.d
        -- normalSpin
        self.normalSpin:Write(om)
    end
}
PKG_Slots_Client_RichMummyNormalRet.__index = PKG_Slots_Client_RichMummyNormalRet

--[[
特殊结果
]]
PKG_Slots_Client_RichMummyFreeRet = {
    typeName = "PKG_Slots_Client_RichMummyFreeRet",
    typeId = 43751,
    Create = function(o)
        if o == nil then
            o = {}
            setmetatable(o, PKG_Slots_Client_RichMummyFreeRet)
        end
        o.freeSpin = PKG_RichMummy_FreeSpin.Create() -- PKG.RichMummy.FreeSpin
        return o
    end,
    Read = function(self, om)
        local d = om.d
        local r, n
        -- freeSpin
        self.freeSpin = PKG_RichMummy_FreeSpin.Create(); r = self.freeSpin:Read(om)
        if r ~= 0 then return r end
        return 0
    end,
    Write = function(self, om)
        local d = om.d
        -- freeSpin
        self.freeSpin:Write(om)
    end
}
PKG_Slots_Client_RichMummyFreeRet.__index = PKG_Slots_Client_RichMummyFreeRet

--[[
特殊结果
]]
PKG_Slots_Client_RichMummySpecialRet = {
    typeName = "PKG_Slots_Client_RichMummySpecialRet",
    typeId = 43752,
    Create = function(o)
        if o == nil then
            o = {}
            setmetatable(o, PKG_Slots_Client_RichMummySpecialRet)
        end
        o.specialSpin = PKG_RichMummy_SpecialSpin.Create() -- PKG.RichMummy.SpecialSpin
        return o
    end,
    Read = function(self, om)
        local d = om.d
        local r, n
        -- specialSpin
        self.specialSpin = PKG_RichMummy_SpecialSpin.Create(); r = self.specialSpin:Read(om)
        if r ~= 0 then return r end
        return 0
    end,
    Write = function(self, om)
        local d = om.d
        -- specialSpin
        self.specialSpin:Write(om)
    end
}
PKG_Slots_Client_RichMummySpecialRet.__index = PKG_Slots_Client_RichMummySpecialRet

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

--[[
断线重连数据恢复
]]
PKG_Slots_Client_RichMummyEnterResumed = {
    typeName = "PKG_Slots_Client_RichMummyEnterResumed",
    typeId = 43753,
    Create = function(o)
        if o == nil then
            o = {}
            setmetatable(o, PKG_Slots_Client_RichMummyEnterResumed)
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
        --[[
        12选3已开的数组
        ]]
        o.cells = {} -- List<Int32>
        o.resumedNormal = PKG_Slots_Client_RichMummyNormalRet.Create() -- PKG.Slots_Client.RichMummyNormalRet
        o.resumedFree = PKG_Slots_Client_RichMummyFreeRet.Create() -- PKG.Slots_Client.RichMummyFreeRet
        o.resumedSpecial = PKG_Slots_Client_RichMummySpecialRet.Create() -- PKG.Slots_Client.RichMummySpecialRet
        o.lastMsgType = 0 -- Int32
        o.currentWinCoin = 0 -- Int64
        return o
    end,
    Read = function(self, om)
        local d = om.d
        local r, n, o
        -- enterBase
        self.enterBase = PKG_Slots_Client_Enter_Success.Create(); r = self.enterBase:Read(om)
        if r ~= 0 then return r end
        -- currentBetMoney
        r, self.currentBetMoney = d:Rd()
        if r ~= 0 then return r end
        -- lvID
        r, self.lvID = d:Rvi32()
        if r ~= 0 then return r end
        -- cells
        r, len = d:Rvu32()
        if len > d:GetLeft() then return -1 end
        o = {}
        self.cells = o
        for i = 1, len do
            r, o[i] = d:Rvi32()
            if r ~= 0 then return r end
        end
        if r ~= 0 then return r end
        -- resumedNormal
        self.resumedNormal = PKG_Slots_Client_RichMummyNormalRet.Create(); r = self.resumedNormal:Read(om)
        if r ~= 0 then return r end
        -- resumedFree
        self.resumedFree = PKG_Slots_Client_RichMummyFreeRet.Create(); r = self.resumedFree:Read(om)
        if r ~= 0 then return r end
        -- resumedSpecial
        self.resumedSpecial = PKG_Slots_Client_RichMummySpecialRet.Create(); r = self.resumedSpecial:Read(om)
        if r ~= 0 then return r end
        -- lastMsgType
        r, self.lastMsgType = d:Rvi32()
        if r ~= 0 then return r end
        -- currentWinCoin
        r, self.currentWinCoin = d:Rvi64()
        if r ~= 0 then return r end
        return 0
    end,
    Write = function(self, om)
        local d = om.d
        local o, len
        -- enterBase
        self.enterBase:Write(om)
        -- currentBetMoney
        d:Wd(self.currentBetMoney)
        -- lvID
        d:Wvi32(self.lvID)
        -- cells
        o = self.cells
        len = #o
        d:Wvu32(len)
        for i = 1, len do
            d:Wvi32(o[i])
        end
        -- resumedNormal
        self.resumedNormal:Write(om)
        -- resumedFree
        self.resumedFree:Write(om)
        -- resumedSpecial
        self.resumedSpecial:Write(om)
        -- lastMsgType
        d:Wvi32(self.lastMsgType)
        -- currentWinCoin
        d:Wvi64(self.currentWinCoin)
    end
}
PKG_Slots_Client_RichMummyEnterResumed.__index = PKG_Slots_Client_RichMummyEnterResumed

--[[
金币点击信息
]]
PKG_Client_Slots_CionInfo = {
    typeName = "PKG_Client_Slots_CionInfo",
    typeId = 30116,
    Create = function(o)
        if o == nil then
            o = {}
            setmetatable(o, PKG_Client_Slots_CionInfo)
        end
        o.cells = {} -- List<Int32>
        return o
    end,
    Read = function(self, om)
        local d = om.d
        local r, n, o
        -- cells
        r, len = d:Rvu32()
        if len > d:GetLeft() then return -1 end
        o = {}
        self.cells = o
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
        -- cells
        o = self.cells
        len = #o
        d:Wvu32(len)
        for i = 1, len do
            d:Wvi32(o[i])
        end
    end
}
PKG_Client_Slots_CionInfo.__index = PKG_Client_Slots_CionInfo

--[[
请求同步
]]
PKG_Client_Slots_Sync = {
    typeName = "PKG_Client_Slots_Sync",
    typeId = 30115,
    Create = function(o)
        if o == nil then
            o = {}
            setmetatable(o, PKG_Client_Slots_Sync)
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
PKG_Client_Slots_Sync.__index = PKG_Client_Slots_Sync

--[[
玩家锁住状态离开
]]
PKG_Client_Slots_LockLeave = {
    typeName = "PKG_Client_Slots_LockLeave",
    typeId = 30114,
    Create = function(o)
        if o == nil then
            o = {}
            setmetatable(o, PKG_Client_Slots_LockLeave)
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
PKG_Client_Slots_LockLeave.__index = PKG_Client_Slots_LockLeave

--[[
离开结算
]]
PKG_Client_Slots_Leave = {
    typeName = "PKG_Client_Slots_Leave",
    typeId = 30113,
    Create = function(o)
        if o == nil then
            o = {}
            setmetatable(o, PKG_Client_Slots_Leave)
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
PKG_Client_Slots_Leave.__index = PKG_Client_Slots_Leave

--[[
请求入桌
]]
PKG_Client_Slots_PlayerSit = {
    typeName = "PKG_Client_Slots_PlayerSit",
    typeId = 30112,
    Create = function(o)
        if o == nil then
            o = {}
            setmetatable(o, PKG_Client_Slots_PlayerSit)
        end
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
        -- tableId
        d:Wvi32(self.tableId)
        -- chairId
        d:Wvi32(self.chairId)
    end
}
PKG_Client_Slots_PlayerSit.__index = PKG_Client_Slots_PlayerSit

--[[
请求进入游戏
]]
PKG_Client_Slots_Enter = {
    typeName = "PKG_Client_Slots_Enter",
    typeId = 30111,
    Create = function(o)
        if o == nil then
            o = {}
            setmetatable(o, PKG_Client_Slots_Enter)
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
PKG_Client_Slots_Enter.__index = PKG_Client_Slots_Enter

--[[
特殊旋转
]]
PKG_Client_Slots_RichMummySpecialSpin = {
    typeName = "PKG_Client_Slots_RichMummySpecialSpin",
    typeId = 43756,
    Create = function(o)
        if o == nil then
            o = {}
            setmetatable(o, PKG_Client_Slots_RichMummySpecialSpin)
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
PKG_Client_Slots_RichMummySpecialSpin.__index = PKG_Client_Slots_RichMummySpecialSpin

--[[
特殊旋转
]]
PKG_Client_Slots_RichMummyFreeSpin = {
    typeName = "PKG_Client_Slots_RichMummyFreeSpin",
    typeId = 43755,
    Create = function(o)
        if o == nil then
            o = {}
            setmetatable(o, PKG_Client_Slots_RichMummyFreeSpin)
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
PKG_Client_Slots_RichMummyFreeSpin.__index = PKG_Client_Slots_RichMummyFreeSpin

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
普通旋转
]]
PKG_Client_Slots_RichMummyNormalSpin = {
    typeName = "PKG_Client_Slots_RichMummyNormalSpin",
    typeId = 43754,
    Create = function(o)
        if o == nil then
            o = {}
            setmetatable(o, PKG_Client_Slots_RichMummyNormalSpin)
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
PKG_Client_Slots_RichMummyNormalSpin.__index = PKG_Client_Slots_RichMummyNormalSpin

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

PKG_RichMummy_TsStatus = {
    typeName = "PKG_RichMummy_TsStatus",
    Create = function(o)
        if o == nil then
            o = {}
            setmetatable(o, PKG_RichMummy_TsStatus)
        end
        o.row = 0 -- Int32
        o.col = 0 -- Int32
        o.size = 0 -- Int32
        o.curJP1 = 0 -- Int32
        return o
    end,
    Read = function(self, om)
        local d = om.d
        local r, n
        -- row
        r, self.row = d:Rvi32()
        if r ~= 0 then return r end
        -- col
        r, self.col = d:Rvi32()
        if r ~= 0 then return r end
        -- size
        r, self.size = d:Rvi32()
        if r ~= 0 then return r end
        -- curJP1
        r, self.curJP1 = d:Rvi32()
        if r ~= 0 then return r end
        return 0
    end,
    Write = function(self, om)
        local d = om.d
        -- row
        d:Wvi32(self.row)
        -- col
        d:Wvi32(self.col)
        -- size
        d:Wvi32(self.size)
        -- curJP1
        d:Wvi32(self.curJP1)
    end
}
PKG_RichMummy_TsStatus.__index = PKG_RichMummy_TsStatus

PKG_RichMummy_Cell = {
    typeName = "PKG_RichMummy_Cell",
    Create = function(o)
        if o == nil then
            o = {}
            setmetatable(o, PKG_RichMummy_Cell)
        end
        --[[
        点对应下标
        ]]
        o.index = 0 -- Int32
        --[[
        点对应图形Id
        ]]
        o.icon = 0 -- Int32
        o.lottyType = 0 -- Int32
        o.lottyValue = 0 -- Int64
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
        -- lottyType
        r, self.lottyType = d:Rvi32()
        if r ~= 0 then return r end
        -- lottyValue
        r, self.lottyValue = d:Rvi64()
        if r ~= 0 then return r end
        return 0
    end,
    Write = function(self, om)
        local d = om.d
        -- index
        d:Wvi32(self.index)
        -- icon
        d:Wvi32(self.icon)
        -- lottyType
        d:Wvi32(self.lottyType)
        -- lottyValue
        d:Wvi64(self.lottyValue)
    end
}
PKG_RichMummy_Cell.__index = PKG_RichMummy_Cell

PKG_RichMummy_TsChange = {
    typeName = "PKG_RichMummy_TsChange",
    Create = function(o)
        if o == nil then
            o = {}
            setmetatable(o, PKG_RichMummy_TsChange)
        end
        o.changeType = 0 -- Int32
        o.status = PKG_RichMummy_TsStatus.Create() -- PKG.RichMummy.TsStatus
        o.swallowIndex = 0 -- Int32
        o.swallowMoney = 0 -- Int64
        return o
    end,
    Read = function(self, om)
        local d = om.d
        local r, n
        -- changeType
        r, self.changeType = d:Rvi32()
        if r ~= 0 then return r end
        -- status
        self.status = PKG_RichMummy_TsStatus.Create(); r = self.status:Read(om)
        if r ~= 0 then return r end
        -- swallowIndex
        r, self.swallowIndex = d:Rvi32()
        if r ~= 0 then return r end
        -- swallowMoney
        r, self.swallowMoney = d:Rvi64()
        if r ~= 0 then return r end
        return 0
    end,
    Write = function(self, om)
        local d = om.d
        -- changeType
        d:Wvi32(self.changeType)
        -- status
        self.status:Write(om)
        -- swallowIndex
        d:Wvi32(self.swallowIndex)
        -- swallowMoney
        d:Wvi64(self.swallowMoney)
    end
}
PKG_RichMummy_TsChange.__index = PKG_RichMummy_TsChange

PKG_RichMummy_Line = {
    typeName = "PKG_RichMummy_Line",
    Create = function(o)
        if o == nil then
            o = {}
            setmetatable(o, PKG_RichMummy_Line)
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
        o.lineCells = {} -- List<PKG.RichMummy.Cell>
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
            o[i] = PKG_RichMummy_Cell.Create(); r = o[i]:Read(om)
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
PKG_RichMummy_Line.__index = PKG_RichMummy_Line

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
o.Register(PKG_RichMummy_NormalSpin)
o.Register(PKG_RichMummy_FreeSpin)
o.Register(PKG_RichMummy_SpecialSpin)
o.Register(PKG_Slots_Client_Enter_Success)
o.Register(PKG_Slots_Client_RichMummyNormalRet)
o.Register(PKG_Slots_Client_RichMummyFreeRet)
o.Register(PKG_Slots_Client_RichMummySpecialRet)
o.Register(PKG_Slots_Client_LockLeaveSuccess)
o.Register(PKG_Slots_Client_RichMummyEnterResumed)
o.Register(PKG_Client_Slots_CionInfo)
o.Register(PKG_Client_Slots_Sync)
o.Register(PKG_Client_Slots_LockLeave)
o.Register(PKG_Client_Slots_Leave)
o.Register(PKG_Client_Slots_PlayerSit)
o.Register(PKG_Client_Slots_Enter)
o.Register(PKG_Client_Slots_RichMummySpecialSpin)
o.Register(PKG_Client_Slots_RichMummyFreeSpin)
o.Register(PKG_Slots_Client_OfflineCheck)
o.Register(PKG_Slots_Client_CollectValue)
o.Register(PKG_Slots_Client_SyncPlayerStates)
o.Register(PKG_Slots_Client_Leave_Success)
o.Register(PKG_Client_Slots_RichMummyNormalSpin)