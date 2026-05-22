
CodeGen_slot_210_md5 ="#*MD5<facc52c6ded64c85cded440d0882261e>*#"

PKG_Empire88_Empire88Symbol = {
    EgyptianFantasyWild = 1,
    EgyptianFantasyJinZiTa = 2,
    EgyptianFantasyFaLao = 3,
    EgyptianFantasyMao = 4,
    EgyptianFantasyNiu = 5,
    EgyptianFantasyJi = 6,
    EgyptianFantasyTuTen = 7,
    EgyptianFantasyA = 8,
    EgyptianFantasyK = 9,
    EgyptianFantasyQ = 10,
    EgyptianFantasyJ = 11,
    EgyptianFantasy10 = 12,
    EgyptianFantasy9 = 13
}
--[[
Sugar请求特殊旋转图形
]]
PKG_Empire88_FreeSpin = {
    typeName = "PKG_Empire88_FreeSpin",
    typeId = 30213,
    Create = function(o)
        if o == nil then
            o = {}
            setmetatable(o, PKG_Empire88_FreeSpin)
        end
        --[[
        (一次旋转押注 )
        ]]
        o.bet = 0 -- Double
        --[[
        (一次旋转赢钱)
        ]]
        o.winCoin = 0 -- Double
        --[[
        生成的20个图形集合
        ]]
        o.grids = {} -- List<PKG.Empire88.Cell>
        --[[
        转盘次数为0时，返回的Bonus Win
        ]]
        o.bonusWinCoin = 0 -- Double
        --[[
        总次数
        ]]
        o.allCount = 0 -- Int32
        --[[
        当前次数
        ]]
        o.totalCount = 0 -- Int32
        --[[
        再次中免费
        ]]
        o.newFreeTime = 0 -- Int32
        --[[
        替代的倍率
        ]]
        o.wildBet = 0 -- Int32
        --[[
        中奖的线
        ]]
        o.lines = {} -- List<PKG.Empire88.Line>
        return o
    end,
    Read = function(self, om)
        local d = om.d
        local r, n, o
        -- bet
        r, self.bet = d:Rd()
        if r ~= 0 then return r end
        -- winCoin
        r, self.winCoin = d:Rd()
        if r ~= 0 then return r end
        -- grids
        r, len = d:Rvu32()
        if len > d:GetLeft() then return -1 end
        o = {}
        self.grids = o
        for i = 1, len do
            o[i] = PKG_Empire88_Cell.Create(); r = o[i]:Read(om)
            if r ~= 0 then return r end
        end
        if r ~= 0 then return r end
        -- bonusWinCoin
        r, self.bonusWinCoin = d:Rd()
        if r ~= 0 then return r end
        -- allCount
        r, self.allCount = d:Rvi32()
        if r ~= 0 then return r end
        -- totalCount
        r, self.totalCount = d:Rvi32()
        if r ~= 0 then return r end
        -- newFreeTime
        r, self.newFreeTime = d:Rvi32()
        if r ~= 0 then return r end
        -- wildBet
        r, self.wildBet = d:Rvi32()
        if r ~= 0 then return r end
        -- lines
        r, len = d:Rvu32()
        if len > d:GetLeft() then return -1 end
        o = {}
        self.lines = o
        for i = 1, len do
            o[i] = PKG_Empire88_Line.Create(); r = o[i]:Read(om)
            if r ~= 0 then return r end
        end
        if r ~= 0 then return r end
        return 0
    end,
    Write = function(self, om)
        local d = om.d
        local o, len
        -- bet
        d:Wd(self.bet)
        -- winCoin
        d:Wd(self.winCoin)
        -- grids
        o = self.grids
        len = #o
        d:Wvu32(len)
        for i = 1, len do
            o[i]:Write(om)
        end
        -- bonusWinCoin
        d:Wd(self.bonusWinCoin)
        -- allCount
        d:Wvi32(self.allCount)
        -- totalCount
        d:Wvi32(self.totalCount)
        -- newFreeTime
        d:Wvi32(self.newFreeTime)
        -- wildBet
        d:Wvi32(self.wildBet)
        -- lines
        o = self.lines
        len = #o
        d:Wvu32(len)
        for i = 1, len do
            o[i]:Write(om)
        end
    end
}
PKG_Empire88_FreeSpin.__index = PKG_Empire88_FreeSpin

--[[
Sugar请求特殊旋转图形
]]
PKG_Empire88_FreeType = {
    typeName = "PKG_Empire88_FreeType",
    typeId = 30212,
    Create = function(o)
        if o == nil then
            o = {}
            setmetatable(o, PKG_Empire88_FreeType)
        end
        --[[
        倍率类型
        ]]
        o.type = 0 -- Int32
        --[[
        免费次数
        ]]
        o.time = 0 -- Int32
        return o
    end,
    Read = function(self, om)
        local d = om.d
        local r, n
        -- type
        r, self.type = d:Rvi32()
        if r ~= 0 then return r end
        -- time
        r, self.time = d:Rvi32()
        if r ~= 0 then return r end
        return 0
    end,
    Write = function(self, om)
        local d = om.d
        -- type
        d:Wvi32(self.type)
        -- time
        d:Wvi32(self.time)
    end
}
PKG_Empire88_FreeType.__index = PKG_Empire88_FreeType

--[[
Sugar请求特殊旋转图形
]]
PKG_Empire88_NormalSpin = {
    typeName = "PKG_Empire88_NormalSpin",
    typeId = 30211,
    Create = function(o)
        if o == nil then
            o = {}
            setmetatable(o, PKG_Empire88_NormalSpin)
        end
        --[[
        (一次旋转押注 )
        ]]
        o.bet = 0 -- Double
        --[[
        (一次旋转赢钱)
        ]]
        o.winCoin = 0 -- Double
        --[[
        生成的20个图形集合
        ]]
        o.grids = {} -- List<PKG.Empire88.Cell>
        --[[
        替代的倍率
        ]]
        o.wildBet = 0 -- Int32
        --[[
        是否进入免费游戏
        ]]
        o.intoFree = 0 -- Int32
        --[[
        (符合连线规则)
        ]]
        o.lines = {} -- List<PKG.Empire88.Line>
        --[[
        是否进入彩金
        ]]
        o.intoLottery = 0 -- Int32
        return o
    end,
    Read = function(self, om)
        local d = om.d
        local r, n, o
        -- bet
        r, self.bet = d:Rd()
        if r ~= 0 then return r end
        -- winCoin
        r, self.winCoin = d:Rd()
        if r ~= 0 then return r end
        -- grids
        r, len = d:Rvu32()
        if len > d:GetLeft() then return -1 end
        o = {}
        self.grids = o
        for i = 1, len do
            o[i] = PKG_Empire88_Cell.Create(); r = o[i]:Read(om)
            if r ~= 0 then return r end
        end
        if r ~= 0 then return r end
        -- wildBet
        r, self.wildBet = d:Rvi32()
        if r ~= 0 then return r end
        -- intoFree
        r, self.intoFree = d:Rvi32()
        if r ~= 0 then return r end
        -- lines
        r, len = d:Rvu32()
        if len > d:GetLeft() then return -1 end
        o = {}
        self.lines = o
        for i = 1, len do
            o[i] = PKG_Empire88_Line.Create(); r = o[i]:Read(om)
            if r ~= 0 then return r end
        end
        if r ~= 0 then return r end
        -- intoLottery
        r, self.intoLottery = d:Rvi32()
        if r ~= 0 then return r end
        return 0
    end,
    Write = function(self, om)
        local d = om.d
        local o, len
        -- bet
        d:Wd(self.bet)
        -- winCoin
        d:Wd(self.winCoin)
        -- grids
        o = self.grids
        len = #o
        d:Wvu32(len)
        for i = 1, len do
            o[i]:Write(om)
        end
        -- wildBet
        d:Wvi32(self.wildBet)
        -- intoFree
        d:Wvi32(self.intoFree)
        -- lines
        o = self.lines
        len = #o
        d:Wvu32(len)
        for i = 1, len do
            o[i]:Write(om)
        end
        -- intoLottery
        d:Wvi32(self.intoLottery)
    end
}
PKG_Empire88_NormalSpin.__index = PKG_Empire88_NormalSpin

--[[
Sugar请求特殊旋转图形
]]
PKG_Empire88_SpecialSpin = {
    typeName = "PKG_Empire88_SpecialSpin",
    typeId = 30214,
    Create = function(o)
        if o == nil then
            o = {}
            setmetatable(o, PKG_Empire88_SpecialSpin)
        end
        --[[
        (特殊游戏的钱)
        ]]
        o.winMony = 0 -- Double
        o.winCout = 0 -- Int32
        o.allSpecial = {} -- List<PKG.Empire88.OneLine>
        --[[
        总次数
        ]]
        o.allCount = 0 -- Int32
        --[[
        当前次数
        ]]
        o.totalCount = 0 -- Int32
        return o
    end,
    Read = function(self, om)
        local d = om.d
        local r, n, o
        -- winMony
        r, self.winMony = d:Rd()
        if r ~= 0 then return r end
        -- winCout
        r, self.winCout = d:Rvi32()
        if r ~= 0 then return r end
        -- allSpecial
        r, len = d:Rvu32()
        if len > d:GetLeft() then return -1 end
        o = {}
        self.allSpecial = o
        for i = 1, len do
            o[i] = PKG_Empire88_OneLine.Create(); r = o[i]:Read(om)
            if r ~= 0 then return r end
        end
        if r ~= 0 then return r end
        -- allCount
        r, self.allCount = d:Rvi32()
        if r ~= 0 then return r end
        -- totalCount
        r, self.totalCount = d:Rvi32()
        if r ~= 0 then return r end
        return 0
    end,
    Write = function(self, om)
        local d = om.d
        local o, len
        -- winMony
        d:Wd(self.winMony)
        -- winCout
        d:Wvi32(self.winCout)
        -- allSpecial
        o = self.allSpecial
        len = #o
        d:Wvu32(len)
        for i = 1, len do
            o[i]:Write(om)
        end
        -- allCount
        d:Wvi32(self.allCount)
        -- totalCount
        d:Wvi32(self.totalCount)
    end
}
PKG_Empire88_SpecialSpin.__index = PKG_Empire88_SpecialSpin

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
狂野蛮牛-普通结果
]]
PKG_Slots_Client_Empire88NormalRet = {
    typeName = "PKG_Slots_Client_Empire88NormalRet", -- : PKG_Empire88_NormalSpin
    typeId = 30219,
    Create = function(o)
        if o == nil then
            o = {}
            setmetatable(o, PKG_Slots_Client_Empire88NormalRet)
        end
        PKG_Empire88_NormalSpin.Create(o)
        o.slotMoneyGift = PKG_SlotsBase_SlotMoneyGift.Create() -- PKG.SlotsBase.SlotMoneyGift
        o.slotMoney = PKG_SlotsBase_SlotMoney.Create() -- PKG.SlotsBase.SlotMoney
        o.levelUpMoney = 0 -- Int64
        o.levelUpMoneys = {} -- List<Int64>
        return o
    end,
    Read = function(self, om)
        local d = om.d
        local r, n, o
        -- base read
        r = PKG_Empire88_NormalSpin.Read(self, om)
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
        return 0
    end,
    Write = function(self, om)
        local d = om.d
        local o, len
        -- base read
        PKG_Empire88_NormalSpin.Write(self, om)
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
    end
}
PKG_Slots_Client_Empire88NormalRet.__index = PKG_Slots_Client_Empire88NormalRet

--[[
狂野蛮牛 免费游戏结果
]]
PKG_Slots_Client_Empire88FreeRetType = {
    typeName = "PKG_Slots_Client_Empire88FreeRetType", -- : PKG_Empire88_FreeType
    typeId = 30220,
    Create = function(o)
        if o == nil then
            o = {}
            setmetatable(o, PKG_Slots_Client_Empire88FreeRetType)
        end
        PKG_Empire88_FreeType.Create(o)
        return o
    end,
    Read = function(self, om)
        local d = om.d
        local r, n
        -- base read
        r = PKG_Empire88_FreeType.Read(self, om)
        if r ~= 0 then return r end
        return 0
    end,
    Write = function(self, om)
        local d = om.d
        -- base read
        PKG_Empire88_FreeType.Write(self, om)
    end
}
PKG_Slots_Client_Empire88FreeRetType.__index = PKG_Slots_Client_Empire88FreeRetType

--[[
狂野蛮牛 免费游戏结果
]]
PKG_Slots_Client_Empire88FreeRet = {
    typeName = "PKG_Slots_Client_Empire88FreeRet", -- : PKG_Empire88_FreeSpin
    typeId = 30221,
    Create = function(o)
        if o == nil then
            o = {}
            setmetatable(o, PKG_Slots_Client_Empire88FreeRet)
        end
        PKG_Empire88_FreeSpin.Create(o)
        o.slotMoneyGift = PKG_SlotsBase_SlotMoneyGift.Create() -- PKG.SlotsBase.SlotMoneyGift
        o.slotMoney = PKG_SlotsBase_SlotMoney.Create() -- PKG.SlotsBase.SlotMoney
        return o
    end,
    Read = function(self, om)
        local d = om.d
        local r, n
        -- base read
        r = PKG_Empire88_FreeSpin.Read(self, om)
        if r ~= 0 then return r end
        -- slotMoneyGift
        self.slotMoneyGift = PKG_SlotsBase_SlotMoneyGift.Create(); r = self.slotMoneyGift:Read(om)
        if r ~= 0 then return r end
        -- slotMoney
        self.slotMoney = PKG_SlotsBase_SlotMoney.Create(); r = self.slotMoney:Read(om)
        if r ~= 0 then return r end
        return 0
    end,
    Write = function(self, om)
        local d = om.d
        -- base read
        PKG_Empire88_FreeSpin.Write(self, om)
        -- slotMoneyGift
        self.slotMoneyGift:Write(om)
        -- slotMoney
        self.slotMoney:Write(om)
    end
}
PKG_Slots_Client_Empire88FreeRet.__index = PKG_Slots_Client_Empire88FreeRet

--[[
狂野蛮牛 免费游戏结果
]]
PKG_Slots_Client_Empire88SpecialRet = {
    typeName = "PKG_Slots_Client_Empire88SpecialRet", -- : PKG_Empire88_SpecialSpin
    typeId = 30222,
    Create = function(o)
        if o == nil then
            o = {}
            setmetatable(o, PKG_Slots_Client_Empire88SpecialRet)
        end
        PKG_Empire88_SpecialSpin.Create(o)
        o.slotMoneyGift = PKG_SlotsBase_SlotMoneyGift.Create() -- PKG.SlotsBase.SlotMoneyGift
        o.slotMoney = PKG_SlotsBase_SlotMoney.Create() -- PKG.SlotsBase.SlotMoney
        return o
    end,
    Read = function(self, om)
        local d = om.d
        local r, n
        -- base read
        r = PKG_Empire88_SpecialSpin.Read(self, om)
        if r ~= 0 then return r end
        -- slotMoneyGift
        self.slotMoneyGift = PKG_SlotsBase_SlotMoneyGift.Create(); r = self.slotMoneyGift:Read(om)
        if r ~= 0 then return r end
        -- slotMoney
        self.slotMoney = PKG_SlotsBase_SlotMoney.Create(); r = self.slotMoney:Read(om)
        if r ~= 0 then return r end
        return 0
    end,
    Write = function(self, om)
        local d = om.d
        -- base read
        PKG_Empire88_SpecialSpin.Write(self, om)
        -- slotMoneyGift
        self.slotMoneyGift:Write(om)
        -- slotMoney
        self.slotMoney:Write(om)
    end
}
PKG_Slots_Client_Empire88SpecialRet.__index = PKG_Slots_Client_Empire88SpecialRet

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
Sugar请求获取生成图形
]]
PKG_Client_Slots_Empire88NormalSpin = {
    typeName = "PKG_Client_Slots_Empire88NormalSpin",
    typeId = 30215,
    Create = function(o)
        if o == nil then
            o = {}
            setmetatable(o, PKG_Client_Slots_Empire88NormalSpin)
        end
        --[[
        押注金额
        ]]
        o.betMoney = 0 -- Double
        o.moneyType = 0 -- Int32
        return o
    end,
    Read = function(self, om)
        local d = om.d
        local r, n
        -- betMoney
        r, self.betMoney = d:Rd()
        if r ~= 0 then return r end
        -- moneyType
        r, self.moneyType = d:Rvi32()
        if r ~= 0 then return r end
        return 0
    end,
    Write = function(self, om)
        local d = om.d
        -- betMoney
        d:Wd(self.betMoney)
        -- moneyType
        d:Wvi32(self.moneyType)
    end
}
PKG_Client_Slots_Empire88NormalSpin.__index = PKG_Client_Slots_Empire88NormalSpin

--[[
皇朝88 请求免费类型
]]
PKG_Client_Slots_Empire88FreeType = {
    typeName = "PKG_Client_Slots_Empire88FreeType",
    typeId = 30216,
    Create = function(o)
        if o == nil then
            o = {}
            setmetatable(o, PKG_Client_Slots_Empire88FreeType)
        end
        --[[
        押注类型
        ]]
        o.type = 0 -- Int32
        return o
    end,
    Read = function(self, om)
        local d = om.d
        local r, n
        -- type
        r, self.type = d:Rvi32()
        if r ~= 0 then return r end
        return 0
    end,
    Write = function(self, om)
        local d = om.d
        -- type
        d:Wvi32(self.type)
    end
}
PKG_Client_Slots_Empire88FreeType.__index = PKG_Client_Slots_Empire88FreeType

--[[
Sugar请求特殊旋转图形
]]
PKG_Client_Slots_Empire88FreeSpin = {
    typeName = "PKG_Client_Slots_Empire88FreeSpin",
    typeId = 30217,
    Create = function(o)
        if o == nil then
            o = {}
            setmetatable(o, PKG_Client_Slots_Empire88FreeSpin)
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
PKG_Client_Slots_Empire88FreeSpin.__index = PKG_Client_Slots_Empire88FreeSpin

--[[
狂野蛮牛 -断线重连数据恢复
]]
PKG_Slots_Client_Empire88EnterResumed = {
    typeName = "PKG_Slots_Client_Empire88EnterResumed",
    typeId = 30223,
    Create = function(o)
        if o == nil then
            o = {}
            setmetatable(o, PKG_Slots_Client_Empire88EnterResumed)
        end
        --[[
        进入游戏的常规数据恢复
        ]]
        o.enterBase = PKG_Slots_Client_Enter_Success.Create() -- PKG.Slots_Client.Enter_Success
        --[[
        当前赢钱面板上显示的金额
        ]]
        o.currentWinCoin = 0 -- Double
        --[[
        当前押注金额
        ]]
        o.currentBetMoney = 0 -- Double
        o.type = 0 -- Int32
        --[[
        剩余免费轮数
        ]]
        o.freetime = 0 -- Int32
        --[[
        恢复普通结果
        ]]
        o.resumedNormal = PKG_Slots_Client_Empire88NormalRet.Create() -- PKG.Slots_Client.Empire88NormalRet
        --[[
        恢复免费游戏类型
        ]]
        o.resumedFreeType = PKG_Slots_Client_Empire88FreeRetType.Create() -- PKG.Slots_Client.Empire88FreeRetType
        --[[
        恢复免费结果
        ]]
        o.resumedFreeRet = PKG_Slots_Client_Empire88FreeRet.Create() -- PKG.Slots_Client.Empire88FreeRet
        --[[
        恢复特殊结果
        ]]
        o.resumedSpecial = PKG_Slots_Client_Empire88SpecialRet.Create() -- PKG.Slots_Client.Empire88SpecialRet
        return o
    end,
    Read = function(self, om)
        local d = om.d
        local r, n
        -- enterBase
        self.enterBase = PKG_Slots_Client_Enter_Success.Create(); r = self.enterBase:Read(om)
        if r ~= 0 then return r end
        -- currentWinCoin
        r, self.currentWinCoin = d:Rd()
        if r ~= 0 then return r end
        -- currentBetMoney
        r, self.currentBetMoney = d:Rd()
        if r ~= 0 then return r end
        -- type
        r, self.type = d:Rvi32()
        if r ~= 0 then return r end
        -- freetime
        r, self.freetime = d:Rvi32()
        if r ~= 0 then return r end
        -- resumedNormal
        self.resumedNormal = PKG_Slots_Client_Empire88NormalRet.Create(); r = self.resumedNormal:Read(om)
        if r ~= 0 then return r end
        -- resumedFreeType
        self.resumedFreeType = PKG_Slots_Client_Empire88FreeRetType.Create(); r = self.resumedFreeType:Read(om)
        if r ~= 0 then return r end
        -- resumedFreeRet
        self.resumedFreeRet = PKG_Slots_Client_Empire88FreeRet.Create(); r = self.resumedFreeRet:Read(om)
        if r ~= 0 then return r end
        -- resumedSpecial
        self.resumedSpecial = PKG_Slots_Client_Empire88SpecialRet.Create(); r = self.resumedSpecial:Read(om)
        if r ~= 0 then return r end
        return 0
    end,
    Write = function(self, om)
        local d = om.d
        -- enterBase
        self.enterBase:Write(om)
        -- currentWinCoin
        d:Wd(self.currentWinCoin)
        -- currentBetMoney
        d:Wd(self.currentBetMoney)
        -- type
        d:Wvi32(self.type)
        -- freetime
        d:Wvi32(self.freetime)
        -- resumedNormal
        self.resumedNormal:Write(om)
        -- resumedFreeType
        self.resumedFreeType:Write(om)
        -- resumedFreeRet
        self.resumedFreeRet:Write(om)
        -- resumedSpecial
        self.resumedSpecial:Write(om)
    end
}
PKG_Slots_Client_Empire88EnterResumed.__index = PKG_Slots_Client_Empire88EnterResumed

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
Sugar请求特殊旋转图形
]]
PKG_Client_Slots_Empire88SpecialSpin = {
    typeName = "PKG_Client_Slots_Empire88SpecialSpin",
    typeId = 30218,
    Create = function(o)
        if o == nil then
            o = {}
            setmetatable(o, PKG_Client_Slots_Empire88SpecialSpin)
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
PKG_Client_Slots_Empire88SpecialSpin.__index = PKG_Client_Slots_Empire88SpecialSpin

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

PKG_Empire88_Cell = {
    typeName = "PKG_Empire88_Cell",
    Create = function(o)
        if o == nil then
            o = {}
            setmetatable(o, PKG_Empire88_Cell)
        end
        --[[
        点对应下标
        ]]
        o.index = 0 -- Int32
        --[[
        点对应图形Id
        ]]
        o.icon = 0 -- PKG.Empire88.Empire88Symbol
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
        return 0
    end,
    Write = function(self, om)
        local d = om.d
        -- index
        d:Wvi32(self.index)
        -- icon
        d:Wvi32(self.icon)
    end
}
PKG_Empire88_Cell.__index = PKG_Empire88_Cell

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

PKG_Empire88_Line = {
    typeName = "PKG_Empire88_Line",
    Create = function(o)
        if o == nil then
            o = {}
            setmetatable(o, PKG_Empire88_Line)
        end
        --[[
        中奖线(eg:1号线)
        ]]
        o.lineIndex = 0 -- Int32
        --[[
        赢钱(当前线赢的金币)
        ]]
        o.winCoin = 0 -- Double
        --[[
        一组中奖图标
        ]]
        o.icon = 0 -- PKG.Empire88.Empire88Symbol
        --[[
        一条线上的中奖集合
        ]]
        o.lineCells = {} -- List<PKG.Empire88.Cell>
        return o
    end,
    Read = function(self, om)
        local d = om.d
        local r, n, o
        -- lineIndex
        r, self.lineIndex = d:Rvi32()
        if r ~= 0 then return r end
        -- winCoin
        r, self.winCoin = d:Rd()
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
            o[i] = PKG_Empire88_Cell.Create(); r = o[i]:Read(om)
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
        d:Wd(self.winCoin)
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
PKG_Empire88_Line.__index = PKG_Empire88_Line

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

PKG_Empire88_OneLine = {
    typeName = "PKG_Empire88_OneLine",
    Create = function(o)
        if o == nil then
            o = {}
            setmetatable(o, PKG_Empire88_OneLine)
        end
        o.lines = {} -- List<Int32>
        o.add8 = 0 -- Double
        o.end8 = 0 -- Double
        return o
    end,
    Read = function(self, om)
        local d = om.d
        local r, n, o
        -- lines
        r, len = d:Rvu32()
        if len > d:GetLeft() then return -1 end
        o = {}
        self.lines = o
        for i = 1, len do
            r, o[i] = d:Rvi32()
            if r ~= 0 then return r end
        end
        if r ~= 0 then return r end
        -- add8
        r, self.add8 = d:Rd()
        if r ~= 0 then return r end
        -- end8
        r, self.end8 = d:Rd()
        if r ~= 0 then return r end
        return 0
    end,
    Write = function(self, om)
        local d = om.d
        local o, len
        -- lines
        o = self.lines
        len = #o
        d:Wvu32(len)
        for i = 1, len do
            d:Wvi32(o[i])
        end
        -- add8
        d:Wd(self.add8)
        -- end8
        d:Wd(self.end8)
    end
}
PKG_Empire88_OneLine.__index = PKG_Empire88_OneLine

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
        return 0
    end,
    Write = function(self, om)
        local d = om.d
        -- betMoney
        d:Wd(self.betMoney)
        -- betLine
        d:Wvi32(self.betLine)
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
    end
}
PKG_SlotsBase_EntryConditions.__index = PKG_SlotsBase_EntryConditions

local o = ObjMgr
o.Register(PKG_Empire88_FreeSpin)
o.Register(PKG_Empire88_FreeType)
o.Register(PKG_Empire88_NormalSpin)
o.Register(PKG_Empire88_SpecialSpin)
o.Register(PKG_Slots_Client_Enter_Success)
o.Register(PKG_Slots_Client_Empire88NormalRet)
o.Register(PKG_Slots_Client_Empire88FreeRetType)
o.Register(PKG_Slots_Client_Empire88FreeRet)
o.Register(PKG_Slots_Client_Empire88SpecialRet)
o.Register(PKG_Slots_Client_LockLeaveSuccess)
o.Register(PKG_Client_Slots_Empire88NormalSpin)
o.Register(PKG_Client_Slots_Empire88FreeType)
o.Register(PKG_Client_Slots_Empire88FreeSpin)
o.Register(PKG_Slots_Client_Empire88EnterResumed)
o.Register(PKG_Slots_Client_Leave_Success)
o.Register(PKG_Slots_Client_CollectValue)
o.Register(PKG_Slots_Client_OfflineCheck)
o.Register(PKG_Client_Slots_Empire88SpecialSpin)
o.Register(PKG_Slots_Client_SyncPlayerStates)