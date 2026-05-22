
CodeGen_slot_232_md5 ="#*MD5<c83d05f9153c26dbbe455703f34be265>*#"

PKG_GoldenPig_GoldenPigSymbol = {
    GoldenPigWild = 1,
    GoldenPigCaiJin = 2,
    GoldenPigJinZhu = 3,
    GoldenPigDengLong = 4,
    GoldenPigShanZi = 5,
    GoldenPigZhuZi = 6,
    GoldenPigQianBi = 7,
    GoldenPigA = 8,
    GoldenPigK = 9
}
--[[
Sugar请求特殊旋转图形
]]
PKG_GoldenPig_NormalSpin = {
    typeName = "PKG_GoldenPig_NormalSpin",
    typeId = 30441,
    Create = function(o)
        if o == nil then
            o = {}
            setmetatable(o, PKG_GoldenPig_NormalSpin)
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
        生成的15个图形集合
        ]]
        o.grids = {} -- List<PKG.GoldenPig.Cell>
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
        o.lines = {} -- List<PKG.GoldenPig.Line>
        --[[
        是否进入收集游戏
        ]]
        o.intoCollect = 0 -- Int32
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
            o[i] = PKG_GoldenPig_Cell.Create(); r = o[i]:Read(om)
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
            o[i] = PKG_GoldenPig_Line.Create(); r = o[i]:Read(om)
            if r ~= 0 then return r end
        end
        if r ~= 0 then return r end
        -- intoCollect
        r, self.intoCollect = d:Rvi32()
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
        -- intoCollect
        d:Wvi32(self.intoCollect)
    end
}
PKG_GoldenPig_NormalSpin.__index = PKG_GoldenPig_NormalSpin

--[[
Sugar请求特殊旋转图形
]]
PKG_GoldenPig_FreeSpin = {
    typeName = "PKG_GoldenPig_FreeSpin",
    typeId = 30442,
    Create = function(o)
        if o == nil then
            o = {}
            setmetatable(o, PKG_GoldenPig_FreeSpin)
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
        生成的15个图形集合
        ]]
        o.grids = {} -- List<PKG.GoldenPig.Cell>
        --[[
        替代的倍率
        ]]
        o.wildBet = 0 -- Int32
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
        o.addFreeTime = 0 -- Int32
        --[[
        再次中免费的位置
        ]]
        o.listFree = {} -- List<Int32>
        --[[
        中奖的线
        ]]
        o.lines = {} -- List<PKG.GoldenPig.Line>
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
            o[i] = PKG_GoldenPig_Cell.Create(); r = o[i]:Read(om)
            if r ~= 0 then return r end
        end
        if r ~= 0 then return r end
        -- wildBet
        r, self.wildBet = d:Rvi32()
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
        -- addFreeTime
        r, self.addFreeTime = d:Rvi32()
        if r ~= 0 then return r end
        -- listFree
        r, len = d:Rvu32()
        if len > d:GetLeft() then return -1 end
        o = {}
        self.listFree = o
        for i = 1, len do
            r, o[i] = d:Rvi32()
            if r ~= 0 then return r end
        end
        if r ~= 0 then return r end
        -- lines
        r, len = d:Rvu32()
        if len > d:GetLeft() then return -1 end
        o = {}
        self.lines = o
        for i = 1, len do
            o[i] = PKG_GoldenPig_Line.Create(); r = o[i]:Read(om)
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
        -- wildBet
        d:Wvi32(self.wildBet)
        -- bonusWinCoin
        d:Wd(self.bonusWinCoin)
        -- allCount
        d:Wvi32(self.allCount)
        -- totalCount
        d:Wvi32(self.totalCount)
        -- addFreeTime
        d:Wvi32(self.addFreeTime)
        -- listFree
        o = self.listFree
        len = #o
        d:Wvu32(len)
        for i = 1, len do
            d:Wvi32(o[i])
        end
        -- lines
        o = self.lines
        len = #o
        d:Wvu32(len)
        for i = 1, len do
            o[i]:Write(om)
        end
    end
}
PKG_GoldenPig_FreeSpin.__index = PKG_GoldenPig_FreeSpin

--[[
Sugar请求特殊旋转图形
]]
PKG_GoldenPig_SpecialSpin = {
    typeName = "PKG_GoldenPig_SpecialSpin",
    typeId = 30443,
    Create = function(o)
        if o == nil then
            o = {}
            setmetatable(o, PKG_GoldenPig_SpecialSpin)
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
        生成的15个图形集合
        ]]
        o.grids = {} -- List<PKG.GoldenPig.Cell>
        --[[
        转盘次数为0时，返回的Bonus Win
        ]]
        o.bonusWinCoin = 0 -- Double
        --[[
        总次数
        ]]
        o.allCount = 0 -- Int32
        --[[
        剩余次数
        ]]
        o.totalCount = 0 -- Int32
        --[[
        中奖的线
        ]]
        o.lines = {} -- List<PKG.GoldenPig.Line>
        --[[
        大奖锁定
        ]]
        o.lockStates = 0 -- Int32
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
            o[i] = PKG_GoldenPig_Cell.Create(); r = o[i]:Read(om)
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
        -- lines
        r, len = d:Rvu32()
        if len > d:GetLeft() then return -1 end
        o = {}
        self.lines = o
        for i = 1, len do
            o[i] = PKG_GoldenPig_Line.Create(); r = o[i]:Read(om)
            if r ~= 0 then return r end
        end
        if r ~= 0 then return r end
        -- lockStates
        r, self.lockStates = d:Rvi32()
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
        -- lines
        o = self.lines
        len = #o
        d:Wvu32(len)
        for i = 1, len do
            o[i]:Write(om)
        end
        -- lockStates
        d:Wvi32(self.lockStates)
    end
}
PKG_GoldenPig_SpecialSpin.__index = PKG_GoldenPig_SpecialSpin

--[[
狂野蛮牛 免费游戏结果
]]
PKG_Slots_Client_GoldenPigFreeRet = {
    typeName = "PKG_Slots_Client_GoldenPigFreeRet", -- : PKG_GoldenPig_FreeSpin
    typeId = 30450,
    Create = function(o)
        if o == nil then
            o = {}
            setmetatable(o, PKG_Slots_Client_GoldenPigFreeRet)
        end
        PKG_GoldenPig_FreeSpin.Create(o)
        o.slotMoneyGift = PKG_SlotsBase_SlotMoneyGift.Create() -- PKG.SlotsBase.SlotMoneyGift
        o.slotMoney = PKG_SlotsBase_SlotMoney.Create() -- PKG.SlotsBase.SlotMoney
        return o
    end,
    Read = function(self, om)
        local d = om.d
        local r, n
        -- base read
        r = PKG_GoldenPig_FreeSpin.Read(self, om)
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
        PKG_GoldenPig_FreeSpin.Write(self, om)
        -- slotMoneyGift
        self.slotMoneyGift:Write(om)
        -- slotMoney
        self.slotMoney:Write(om)
    end
}
PKG_Slots_Client_GoldenPigFreeRet.__index = PKG_Slots_Client_GoldenPigFreeRet

--[[
狂野蛮牛 免费游戏结果
]]
PKG_Slots_Client_GoldenPigSpecialSpinRet = {
    typeName = "PKG_Slots_Client_GoldenPigSpecialSpinRet", -- : PKG_GoldenPig_SpecialSpin
    typeId = 30451,
    Create = function(o)
        if o == nil then
            o = {}
            setmetatable(o, PKG_Slots_Client_GoldenPigSpecialSpinRet)
        end
        PKG_GoldenPig_SpecialSpin.Create(o)
        o.slotMoneyGift = PKG_SlotsBase_SlotMoneyGift.Create() -- PKG.SlotsBase.SlotMoneyGift
        o.slotMoney = PKG_SlotsBase_SlotMoney.Create() -- PKG.SlotsBase.SlotMoney
        return o
    end,
    Read = function(self, om)
        local d = om.d
        local r, n
        -- base read
        r = PKG_GoldenPig_SpecialSpin.Read(self, om)
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
        PKG_GoldenPig_SpecialSpin.Write(self, om)
        -- slotMoneyGift
        self.slotMoneyGift:Write(om)
        -- slotMoney
        self.slotMoney:Write(om)
    end
}
PKG_Slots_Client_GoldenPigSpecialSpinRet.__index = PKG_Slots_Client_GoldenPigSpecialSpinRet

--[[
狂野蛮牛 免费游戏结果
]]
PKG_Slots_Client_GoldenPigSpecialClickRet = {
    typeName = "PKG_Slots_Client_GoldenPigSpecialClickRet",
    typeId = 30449,
    Create = function(o)
        if o == nil then
            o = {}
            setmetatable(o, PKG_Slots_Client_GoldenPigSpecialClickRet)
        end
        o.index = 0 -- Int32
        o.value = 0 -- Double
        return o
    end,
    Read = function(self, om)
        local d = om.d
        local r, n
        -- index
        r, self.index = d:Rvi32()
        if r ~= 0 then return r end
        -- value
        r, self.value = d:Rd()
        if r ~= 0 then return r end
        return 0
    end,
    Write = function(self, om)
        local d = om.d
        -- index
        d:Wvi32(self.index)
        -- value
        d:Wd(self.value)
    end
}
PKG_Slots_Client_GoldenPigSpecialClickRet.__index = PKG_Slots_Client_GoldenPigSpecialClickRet

--[[
狂野蛮牛-普通结果
]]
PKG_Slots_Client_GoldenPigNormalRet = {
    typeName = "PKG_Slots_Client_GoldenPigNormalRet", -- : PKG_GoldenPig_NormalSpin
    typeId = 30448,
    Create = function(o)
        if o == nil then
            o = {}
            setmetatable(o, PKG_Slots_Client_GoldenPigNormalRet)
        end
        PKG_GoldenPig_NormalSpin.Create(o)
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
        r = PKG_GoldenPig_NormalSpin.Read(self, om)
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
        PKG_GoldenPig_NormalSpin.Write(self, om)
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
PKG_Slots_Client_GoldenPigNormalRet.__index = PKG_Slots_Client_GoldenPigNormalRet

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
Sugar请求特殊旋转图形
]]
PKG_Client_Slots_GoldenPigSpecialClick = {
    typeName = "PKG_Client_Slots_GoldenPigSpecialClick",
    typeId = 30446,
    Create = function(o)
        if o == nil then
            o = {}
            setmetatable(o, PKG_Client_Slots_GoldenPigSpecialClick)
        end
        o.index = 0 -- Int32
        return o
    end,
    Read = function(self, om)
        local d = om.d
        local r, n
        -- index
        r, self.index = d:Rvi32()
        if r ~= 0 then return r end
        return 0
    end,
    Write = function(self, om)
        local d = om.d
        -- index
        d:Wvi32(self.index)
    end
}
PKG_Client_Slots_GoldenPigSpecialClick.__index = PKG_Client_Slots_GoldenPigSpecialClick

--[[
Sugar请求特殊旋转图形
]]
PKG_Client_Slots_GoldenPigSpecialSpin = {
    typeName = "PKG_Client_Slots_GoldenPigSpecialSpin",
    typeId = 30447,
    Create = function(o)
        if o == nil then
            o = {}
            setmetatable(o, PKG_Client_Slots_GoldenPigSpecialSpin)
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
PKG_Client_Slots_GoldenPigSpecialSpin.__index = PKG_Client_Slots_GoldenPigSpecialSpin

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
狂野蛮牛 -断线重连数据恢复
]]
PKG_Slots_Client_GoldenPigEnterResumed = {
    typeName = "PKG_Slots_Client_GoldenPigEnterResumed",
    typeId = 30452,
    Create = function(o)
        if o == nil then
            o = {}
            setmetatable(o, PKG_Slots_Client_GoldenPigEnterResumed)
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
        免费游戏 彩金钱
        ]]
        o.freeIntoMoney = 0 -- Double
        --[[
        断线 彩金累计
        ]]
        o.freeTotalMoney = 0 -- Double
        --[[
        恢复普通结果
        ]]
        o.resumedNormal = PKG_Slots_Client_GoldenPigNormalRet.Create() -- PKG.Slots_Client.GoldenPigNormalRet
        --[[
        恢复免费游戏结果
        ]]
        o.resumedFreeRet = PKG_Slots_Client_GoldenPigFreeRet.Create() -- PKG.Slots_Client.GoldenPigFreeRet
        --[[
        恢复特殊旋转结果
        ]]
        o.specialRet = PKG_Slots_Client_GoldenPigSpecialSpinRet.Create() -- PKG.Slots_Client.GoldenPigSpecialSpinRet
        --[[
        恢复特殊点击结果
        ]]
        o.specialClick = {} -- List<PKG.Slots_Client.GoldenPigSpecialClickRet>
        o.MoneyA = 0 -- Double
        o.MoneyB = 0 -- Double
        return o
    end,
    Read = function(self, om)
        local d = om.d
        local r, n, o
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
        -- freeIntoMoney
        r, self.freeIntoMoney = d:Rd()
        if r ~= 0 then return r end
        -- freeTotalMoney
        r, self.freeTotalMoney = d:Rd()
        if r ~= 0 then return r end
        -- resumedNormal
        self.resumedNormal = PKG_Slots_Client_GoldenPigNormalRet.Create(); r = self.resumedNormal:Read(om)
        if r ~= 0 then return r end
        -- resumedFreeRet
        self.resumedFreeRet = PKG_Slots_Client_GoldenPigFreeRet.Create(); r = self.resumedFreeRet:Read(om)
        if r ~= 0 then return r end
        -- specialRet
        self.specialRet = PKG_Slots_Client_GoldenPigSpecialSpinRet.Create(); r = self.specialRet:Read(om)
        if r ~= 0 then return r end
        -- specialClick
        r, len = d:Rvu32()
        if len > d:GetLeft() then return -1 end
        o = {}
        self.specialClick = o
        for i = 1, len do
            o[i] = PKG_Slots_Client_GoldenPigSpecialClickRet.Create(); r = o[i]:Read(om)
            if r ~= 0 then return r end
        end
        if r ~= 0 then return r end
        -- MoneyA
        r, self.MoneyA = d:Rd()
        if r ~= 0 then return r end
        -- MoneyB
        r, self.MoneyB = d:Rd()
        if r ~= 0 then return r end
        return 0
    end,
    Write = function(self, om)
        local d = om.d
        local o, len
        -- enterBase
        self.enterBase:Write(om)
        -- currentWinCoin
        d:Wd(self.currentWinCoin)
        -- currentBetMoney
        d:Wd(self.currentBetMoney)
        -- type
        d:Wvi32(self.type)
        -- freeIntoMoney
        d:Wd(self.freeIntoMoney)
        -- freeTotalMoney
        d:Wd(self.freeTotalMoney)
        -- resumedNormal
        self.resumedNormal:Write(om)
        -- resumedFreeRet
        self.resumedFreeRet:Write(om)
        -- specialRet
        self.specialRet:Write(om)
        -- specialClick
        o = self.specialClick
        len = #o
        d:Wvu32(len)
        for i = 1, len do
            o[i]:Write(om)
        end
        -- MoneyA
        d:Wd(self.MoneyA)
        -- MoneyB
        d:Wd(self.MoneyB)
    end
}
PKG_Slots_Client_GoldenPigEnterResumed.__index = PKG_Slots_Client_GoldenPigEnterResumed

--[[
发财树 请求免费类型
]]
PKG_Client_Slots_GoldenPigFreeSpin = {
    typeName = "PKG_Client_Slots_GoldenPigFreeSpin",
    typeId = 30445,
    Create = function(o)
        if o == nil then
            o = {}
            setmetatable(o, PKG_Client_Slots_GoldenPigFreeSpin)
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
PKG_Client_Slots_GoldenPigFreeSpin.__index = PKG_Client_Slots_GoldenPigFreeSpin

--[[
Sugar请求获取生成图形
]]
PKG_Client_Slots_GoldenPigNormalSpin = {
    typeName = "PKG_Client_Slots_GoldenPigNormalSpin",
    typeId = 30444,
    Create = function(o)
        if o == nil then
            o = {}
            setmetatable(o, PKG_Client_Slots_GoldenPigNormalSpin)
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
PKG_Client_Slots_GoldenPigNormalSpin.__index = PKG_Client_Slots_GoldenPigNormalSpin

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

PKG_GoldenPig_Cell = {
    typeName = "PKG_GoldenPig_Cell",
    Create = function(o)
        if o == nil then
            o = {}
            setmetatable(o, PKG_GoldenPig_Cell)
        end
        --[[
        点对应下标
        ]]
        o.index = 0 -- Int32
        --[[
        点对应图形Id
        ]]
        o.icon = 0 -- PKG.GoldenPig.GoldenPigSymbol
        o.SymbolValue = 0 -- Double
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
        -- SymbolValue
        r, self.SymbolValue = d:Rd()
        if r ~= 0 then return r end
        return 0
    end,
    Write = function(self, om)
        local d = om.d
        -- index
        d:Wvi32(self.index)
        -- icon
        d:Wvi32(self.icon)
        -- SymbolValue
        d:Wd(self.SymbolValue)
    end
}
PKG_GoldenPig_Cell.__index = PKG_GoldenPig_Cell

PKG_GoldenPig_Line = {
    typeName = "PKG_GoldenPig_Line",
    Create = function(o)
        if o == nil then
            o = {}
            setmetatable(o, PKG_GoldenPig_Line)
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
        o.icon = 0 -- PKG.GoldenPig.GoldenPigSymbol
        --[[
        一条线上的中奖集合
        ]]
        o.lineCells = {} -- List<PKG.GoldenPig.Cell>
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
            o[i] = PKG_GoldenPig_Cell.Create(); r = o[i]:Read(om)
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
PKG_GoldenPig_Line.__index = PKG_GoldenPig_Line

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
o.Register(PKG_GoldenPig_NormalSpin)
o.Register(PKG_GoldenPig_FreeSpin)
o.Register(PKG_GoldenPig_SpecialSpin)
o.Register(PKG_Slots_Client_GoldenPigFreeRet)
o.Register(PKG_Slots_Client_GoldenPigSpecialSpinRet)
o.Register(PKG_Slots_Client_GoldenPigSpecialClickRet)
o.Register(PKG_Slots_Client_GoldenPigNormalRet)
o.Register(PKG_Slots_Client_Enter_Success)
o.Register(PKG_Slots_Client_SyncPlayerStates)
o.Register(PKG_Client_Slots_GoldenPigSpecialClick)
o.Register(PKG_Client_Slots_GoldenPigSpecialSpin)
o.Register(PKG_Slots_Client_LockLeaveSuccess)
o.Register(PKG_Slots_Client_GoldenPigEnterResumed)
o.Register(PKG_Client_Slots_GoldenPigFreeSpin)
o.Register(PKG_Client_Slots_GoldenPigNormalSpin)
o.Register(PKG_Slots_Client_Leave_Success)
o.Register(PKG_Slots_Client_CollectValue)
o.Register(PKG_Slots_Client_OfflineCheck)