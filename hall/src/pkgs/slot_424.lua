
require('g_net')
CodeGen_slot_334_md5 ="#*MD5<0ffad6c9858b3e939c0a7bda90ed9d87>*#"

--[[
Sugar请求特殊旋转图形
]]
PKG_LuckyDice_Dice = {
    typeName = "PKG_LuckyDice_Dice",
    typeId = 31005,
    Create = function(o)
        if o == nil then
            o = {}
            setmetatable(o, PKG_LuckyDice_Dice)
        end
        --[[
        需要亮出骰子的总个数
        ]]
        o.diceCount = 0 -- Int32
        --[[
        赢的钱
        ]]
        o.diceMoney = 0 -- Int64
        --[[
        位置信息,按位与得到结果,1为亮
        ]]
        o.diceCompressPosition = {} -- List<Int32>
        return o
    end,
    Read = function(self, om)
        local d = om.d
        local r, n, o
        -- diceCount
        r, self.diceCount = d:Rvi32()
        if r ~= 0 then return r end
        -- diceMoney
        r, self.diceMoney = d:Rvi64()
        if r ~= 0 then return r end
        -- diceCompressPosition
        r, len = d:Rvu32()
        if len > d:GetLeft() then return -1 end
        o = {}
        self.diceCompressPosition = o
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
        -- diceCount
        d:Wvi32(self.diceCount)
        -- diceMoney
        d:Wvi64(self.diceMoney)
        -- diceCompressPosition
        o = self.diceCompressPosition
        len = #o
        d:Wvu32(len)
        for i = 1, len do
            d:Wvi32(o[i])
        end
    end
}
PKG_LuckyDice_Dice.__index = PKG_LuckyDice_Dice

--[[
Sugar请求特殊旋转图形
]]
PKG_LuckyDice_FreeSpin = {
    typeName = "PKG_LuckyDice_FreeSpin",
    typeId = 31003,
    Create = function(o)
        if o == nil then
            o = {}
            setmetatable(o, PKG_LuckyDice_FreeSpin)
        end
        o.slotMoneyGift = PKG_SlotsBase_SlotMoneyGift.Create() -- PKG.SlotsBase.SlotMoneyGift
        o.slotMoney = PKG_SlotsBase_SlotMoney.Create() -- PKG.SlotsBase.SlotMoney
        --[[
        (一次旋转押注 )
        ]]
        o.bet = 0 -- Int64
        --[[
        (一次旋转赢钱)
        ]]
        o.curWinCoin = 0 -- Int64
        --[[
        生成的15个图形集合
        ]]
        o.grids = {} -- List<PKG.LuckyDice.Cell>
        --[[
        中奖的线
        ]]
        o.lines = {} -- List<PKG.LuckyDice.Line>
        --[[
        大奖锁定
        ]]
        o.lockStates = 0 -- Int32
        --[[
        大奖锁定
        ]]
        o.gameTotalTimesCount = 0 -- Int32
        --[[
        大奖锁定
        ]]
        o.gameCurTimesNum = 0 -- Int32
        --[[
        剩余未使用的选择机会的次数
        ]]
        o.restSelectCount = 0 -- Int32
        --[[
        大奖锁定
        ]]
        o.wildScale = 0 -- Int32
        return o
    end,
    Read = function(self, om)
        local d = om.d
        local r, n, o
        -- slotMoneyGift
        self.slotMoneyGift = PKG_SlotsBase_SlotMoneyGift.Create(); r = self.slotMoneyGift:Read(om)
        if r ~= 0 then return r end
        -- slotMoney
        self.slotMoney = PKG_SlotsBase_SlotMoney.Create(); r = self.slotMoney:Read(om)
        if r ~= 0 then return r end
        -- bet
        r, self.bet = d:Rvi64()
        if r ~= 0 then return r end
        -- curWinCoin
        r, self.curWinCoin = d:Rvi64()
        if r ~= 0 then return r end
        -- grids
        r, len = d:Rvu32()
        if len > d:GetLeft() then return -1 end
        o = {}
        self.grids = o
        for i = 1, len do
            o[i] = PKG_LuckyDice_Cell.Create(); r = o[i]:Read(om)
            if r ~= 0 then return r end
        end
        if r ~= 0 then return r end
        -- lines
        r, len = d:Rvu32()
        if len > d:GetLeft() then return -1 end
        o = {}
        self.lines = o
        for i = 1, len do
            o[i] = PKG_LuckyDice_Line.Create(); r = o[i]:Read(om)
            if r ~= 0 then return r end
        end
        if r ~= 0 then return r end
        -- lockStates
        r, self.lockStates = d:Rvi32()
        if r ~= 0 then return r end
        -- gameTotalTimesCount
        r, self.gameTotalTimesCount = d:Rvi32()
        if r ~= 0 then return r end
        -- gameCurTimesNum
        r, self.gameCurTimesNum = d:Rvi32()
        if r ~= 0 then return r end
        -- restSelectCount
        r, self.restSelectCount = d:Rvi32()
        if r ~= 0 then return r end
        -- wildScale
        r, self.wildScale = d:Rvi32()
        if r ~= 0 then return r end
        return 0
    end,
    Write = function(self, om)
        local d = om.d
        local o, len
        -- slotMoneyGift
        self.slotMoneyGift:Write(om)
        -- slotMoney
        self.slotMoney:Write(om)
        -- bet
        d:Wvi64(self.bet)
        -- curWinCoin
        d:Wvi64(self.curWinCoin)
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
        -- lockStates
        d:Wvi32(self.lockStates)
        -- gameTotalTimesCount
        d:Wvi32(self.gameTotalTimesCount)
        -- gameCurTimesNum
        d:Wvi32(self.gameCurTimesNum)
        -- restSelectCount
        d:Wvi32(self.restSelectCount)
        -- wildScale
        d:Wvi32(self.wildScale)
    end
}
PKG_LuckyDice_FreeSpin.__index = PKG_LuckyDice_FreeSpin

--[[
免费类型选择
]]
PKG_LuckyDice_SelectType = {
    typeName = "PKG_LuckyDice_SelectType",
    typeId = 31002,
    Create = function(o)
        if o == nil then
            o = {}
            setmetatable(o, PKG_LuckyDice_SelectType)
        end
        --[[
        游戏类型
        ]]
        o.type = 0 -- Int32
        --[[
        游戏次数
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
PKG_LuckyDice_SelectType.__index = PKG_LuckyDice_SelectType

--[[
Sugar请求特殊旋转图形
]]
PKG_LuckyDice_NormalSpin = {
    typeName = "PKG_LuckyDice_NormalSpin",
    typeId = 31001,
    Create = function(o)
        if o == nil then
            o = {}
            setmetatable(o, PKG_LuckyDice_NormalSpin)
        end
        o.slotMoneyGift = PKG_SlotsBase_SlotMoneyGift.Create() -- PKG.SlotsBase.SlotMoneyGift
        o.slotMoney = PKG_SlotsBase_SlotMoney.Create() -- PKG.SlotsBase.SlotMoney
        o.levelUpMoney = 0 -- Int64
        o.levelUpMoneys = {} -- List<Int64>
        --[[
        (一次旋转押注 )
        ]]
        o.bet = 0 -- Int64
        --[[
        (一次旋转赢钱)
        ]]
        o.curwinCoin = 0 -- Int64
        --[[
        生成的15个图形集合
        ]]
        o.grids = {} -- List<PKG.LuckyDice.Cell>
        --[[
        是否进入免费游戏
        ]]
        o.intoFree = 0 -- Int32
        --[[
        (符合连线规则)
        ]]
        o.lines = {} -- List<PKG.LuckyDice.Line>
        --[[
        剩余未使用的选择机会的次数
        ]]
        o.restSelectCount = 0 -- Int32
        --[[
        大奖锁定
        ]]
        o.lockStates = 0 -- Int32
        --[[
        大奖锁定
        ]]
        o.wildScale = 0 -- Int32
        return o
    end,
    Read = function(self, om)
        local d = om.d
        local r, n, o
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
        -- bet
        r, self.bet = d:Rvi64()
        if r ~= 0 then return r end
        -- curwinCoin
        r, self.curwinCoin = d:Rvi64()
        if r ~= 0 then return r end
        -- grids
        r, len = d:Rvu32()
        if len > d:GetLeft() then return -1 end
        o = {}
        self.grids = o
        for i = 1, len do
            o[i] = PKG_LuckyDice_Cell.Create(); r = o[i]:Read(om)
            if r ~= 0 then return r end
        end
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
            o[i] = PKG_LuckyDice_Line.Create(); r = o[i]:Read(om)
            if r ~= 0 then return r end
        end
        if r ~= 0 then return r end
        -- restSelectCount
        r, self.restSelectCount = d:Rvi32()
        if r ~= 0 then return r end
        -- lockStates
        r, self.lockStates = d:Rvi32()
        if r ~= 0 then return r end
        -- wildScale
        r, self.wildScale = d:Rvi32()
        if r ~= 0 then return r end
        return 0
    end,
    Write = function(self, om)
        local d = om.d
        local o, len
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
        -- bet
        d:Wvi64(self.bet)
        -- curwinCoin
        d:Wvi64(self.curwinCoin)
        -- grids
        o = self.grids
        len = #o
        d:Wvu32(len)
        for i = 1, len do
            o[i]:Write(om)
        end
        -- intoFree
        d:Wvi32(self.intoFree)
        -- lines
        o = self.lines
        len = #o
        d:Wvu32(len)
        for i = 1, len do
            o[i]:Write(om)
        end
        -- restSelectCount
        d:Wvi32(self.restSelectCount)
        -- lockStates
        d:Wvi32(self.lockStates)
        -- wildScale
        d:Wvi32(self.wildScale)
    end
}
PKG_LuckyDice_NormalSpin.__index = PKG_LuckyDice_NormalSpin

--[[
Sugar请求特殊旋转图形
]]
PKG_LuckyDice_DiceSpin = {
    typeName = "PKG_LuckyDice_DiceSpin",
    typeId = 31006,
    Create = function(o)
        if o == nil then
            o = {}
            setmetatable(o, PKG_LuckyDice_DiceSpin)
        end
        --[[
        剩余未使用的选择机会的次数
        ]]
        o.restSelectCount = 0 -- Int32
        --[[
        骰子游戏总的轮数
        ]]
        o.diceTotalRoundCount = 0 -- Int32
        --[[
        骰子游戏当前进行到第几轮了
        ]]
        o.diceCurRoundNum = 0 -- Int32
        --[[
        本轮骰子游戏总的次数:334的骰子游戏总是等于3
        ]]
        o.gameTotalTimesCount = 0 -- Int32
        --[[
        本轮骰子游戏进行到第几次了
        ]]
        o.gameCurTimesNum = 0 -- Int32
        --[[
        本次游戏的数据信息
        ]]
        o.dice = PKG_LuckyDice_Dice.Create() -- PKG.LuckyDice.Dice
        --[[
        押注
        ]]
        o.bet = 0 -- Int64
        o.slotMoneyGift = PKG_SlotsBase_SlotMoneyGift.Create() -- PKG.SlotsBase.SlotMoneyGift
        o.slotMoney = PKG_SlotsBase_SlotMoney.Create() -- PKG.SlotsBase.SlotMoney
        --[[
        这一次骰子赢的钱
        ]]
        o.curWinCoin = 0 -- Int64
        return o
    end,
    Read = function(self, om)
        local d = om.d
        local r, n
        -- restSelectCount
        r, self.restSelectCount = d:Rvi32()
        if r ~= 0 then return r end
        -- diceTotalRoundCount
        r, self.diceTotalRoundCount = d:Rvi32()
        if r ~= 0 then return r end
        -- diceCurRoundNum
        r, self.diceCurRoundNum = d:Rvi32()
        if r ~= 0 then return r end
        -- gameTotalTimesCount
        r, self.gameTotalTimesCount = d:Rvi32()
        if r ~= 0 then return r end
        -- gameCurTimesNum
        r, self.gameCurTimesNum = d:Rvi32()
        if r ~= 0 then return r end
        -- dice
        self.dice = PKG_LuckyDice_Dice.Create(); r = self.dice:Read(om)
        if r ~= 0 then return r end
        -- bet
        r, self.bet = d:Rvi64()
        if r ~= 0 then return r end
        -- slotMoneyGift
        self.slotMoneyGift = PKG_SlotsBase_SlotMoneyGift.Create(); r = self.slotMoneyGift:Read(om)
        if r ~= 0 then return r end
        -- slotMoney
        self.slotMoney = PKG_SlotsBase_SlotMoney.Create(); r = self.slotMoney:Read(om)
        if r ~= 0 then return r end
        -- curWinCoin
        r, self.curWinCoin = d:Rvi64()
        if r ~= 0 then return r end
        return 0
    end,
    Write = function(self, om)
        local d = om.d
        -- restSelectCount
        d:Wvi32(self.restSelectCount)
        -- diceTotalRoundCount
        d:Wvi32(self.diceTotalRoundCount)
        -- diceCurRoundNum
        d:Wvi32(self.diceCurRoundNum)
        -- gameTotalTimesCount
        d:Wvi32(self.gameTotalTimesCount)
        -- gameCurTimesNum
        d:Wvi32(self.gameCurTimesNum)
        -- dice
        self.dice:Write(om)
        -- bet
        d:Wvi64(self.bet)
        -- slotMoneyGift
        self.slotMoneyGift:Write(om)
        -- slotMoney
        self.slotMoney:Write(om)
        -- curWinCoin
        d:Wvi64(self.curWinCoin)
    end
}
PKG_LuckyDice_DiceSpin.__index = PKG_LuckyDice_DiceSpin

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

PKG_Slots_Client_LuckyDiceNormalRet = {
    typeName = "PKG_Slots_Client_LuckyDiceNormalRet",
    typeId = 31009,
    Create = function(o)
        if o == nil then
            o = {}
            setmetatable(o, PKG_Slots_Client_LuckyDiceNormalRet)
        end
        o.normalSpin = PKG_LuckyDice_NormalSpin.Create() -- PKG.LuckyDice.NormalSpin
        return o
    end,
    Read = function(self, om)
        local d = om.d
        local r, n
        -- normalSpin
        self.normalSpin = PKG_LuckyDice_NormalSpin.Create(); r = self.normalSpin:Read(om)
        if r ~= 0 then return r end
        return 0
    end,
    Write = function(self, om)
        local d = om.d
        -- normalSpin
        self.normalSpin:Write(om)
    end
}
PKG_Slots_Client_LuckyDiceNormalRet.__index = PKG_Slots_Client_LuckyDiceNormalRet

PKG_Slots_Client_LuckyDiceFreeRet = {
    typeName = "PKG_Slots_Client_LuckyDiceFreeRet",
    typeId = 31010,
    Create = function(o)
        if o == nil then
            o = {}
            setmetatable(o, PKG_Slots_Client_LuckyDiceFreeRet)
        end
        o.freeSpin = PKG_LuckyDice_FreeSpin.Create() -- PKG.LuckyDice.FreeSpin
        return o
    end,
    Read = function(self, om)
        local d = om.d
        local r, n
        -- freeSpin
        self.freeSpin = PKG_LuckyDice_FreeSpin.Create(); r = self.freeSpin:Read(om)
        if r ~= 0 then return r end
        return 0
    end,
    Write = function(self, om)
        local d = om.d
        -- freeSpin
        self.freeSpin:Write(om)
    end
}
PKG_Slots_Client_LuckyDiceFreeRet.__index = PKG_Slots_Client_LuckyDiceFreeRet

PKG_Slots_Client_LuckyDiceDiceRet = {
    typeName = "PKG_Slots_Client_LuckyDiceDiceRet",
    typeId = 31011,
    Create = function(o)
        if o == nil then
            o = {}
            setmetatable(o, PKG_Slots_Client_LuckyDiceDiceRet)
        end
        o.diceSpin = PKG_LuckyDice_DiceSpin.Create() -- PKG.LuckyDice.DiceSpin
        return o
    end,
    Read = function(self, om)
        local d = om.d
        local r, n
        -- diceSpin
        self.diceSpin = PKG_LuckyDice_DiceSpin.Create(); r = self.diceSpin:Read(om)
        if r ~= 0 then return r end
        return 0
    end,
    Write = function(self, om)
        local d = om.d
        -- diceSpin
        self.diceSpin:Write(om)
    end
}
PKG_Slots_Client_LuckyDiceDiceRet.__index = PKG_Slots_Client_LuckyDiceDiceRet

PKG_Slots_Client_LuckyDiceSelectRet = {
    typeName = "PKG_Slots_Client_LuckyDiceSelectRet",
    typeId = 31012,
    Create = function(o)
        if o == nil then
            o = {}
            setmetatable(o, PKG_Slots_Client_LuckyDiceSelectRet)
        end
        o.freeType = PKG_LuckyDice_SelectType.Create() -- PKG.LuckyDice.SelectType
        return o
    end,
    Read = function(self, om)
        local d = om.d
        local r, n
        -- freeType
        self.freeType = PKG_LuckyDice_SelectType.Create(); r = self.freeType:Read(om)
        if r ~= 0 then return r end
        return 0
    end,
    Write = function(self, om)
        local d = om.d
        -- freeType
        self.freeType:Write(om)
    end
}
PKG_Slots_Client_LuckyDiceSelectRet.__index = PKG_Slots_Client_LuckyDiceSelectRet

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

PKG_Client_Slots_LuckyDiceFreeType = {
    typeName = "PKG_Client_Slots_LuckyDiceFreeType",
    typeId = 31018,
    Create = function(o)
        if o == nil then
            o = {}
            setmetatable(o, PKG_Client_Slots_LuckyDiceFreeType)
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
PKG_Client_Slots_LuckyDiceFreeType.__index = PKG_Client_Slots_LuckyDiceFreeType

PKG_Client_Slots_LuckyDiceDiceSpin = {
    typeName = "PKG_Client_Slots_LuckyDiceDiceSpin",
    typeId = 31017,
    Create = function(o)
        if o == nil then
            o = {}
            setmetatable(o, PKG_Client_Slots_LuckyDiceDiceSpin)
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
PKG_Client_Slots_LuckyDiceDiceSpin.__index = PKG_Client_Slots_LuckyDiceDiceSpin

PKG_Client_Slots_LuckyDiceFreeSpin = {
    typeName = "PKG_Client_Slots_LuckyDiceFreeSpin",
    typeId = 31016,
    Create = function(o)
        if o == nil then
            o = {}
            setmetatable(o, PKG_Client_Slots_LuckyDiceFreeSpin)
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
PKG_Client_Slots_LuckyDiceFreeSpin.__index = PKG_Client_Slots_LuckyDiceFreeSpin

PKG_Slots_Client_LuckyDiceEnterResumed = {
    typeName = "PKG_Slots_Client_LuckyDiceEnterResumed",
    typeId = 31013,
    Create = function(o)
        if o == nil then
            o = {}
            setmetatable(o, PKG_Slots_Client_LuckyDiceEnterResumed)
        end
        o.betMoney = 0 -- Int32
        o.lvID = 0 -- Int32
        --[[
        进入游戏的常规数据恢复
        ]]
        o.enterBase = PKG_Slots_Client_Enter_Success.Create() -- PKG.Slots_Client.Enter_Success
        o.resumedNormal = PKG_Slots_Client_LuckyDiceNormalRet.Create() -- PKG.Slots_Client.LuckyDiceNormalRet
        o.resumedFree = PKG_Slots_Client_LuckyDiceFreeRet.Create() -- PKG.Slots_Client.LuckyDiceFreeRet
        o.resumedDice = PKG_Slots_Client_LuckyDiceDiceRet.Create() -- PKG.Slots_Client.LuckyDiceDiceRet
        o.resumedSelect = PKG_Slots_Client_LuckyDiceSelectRet.Create() -- PKG.Slots_Client.LuckyDiceSelectRet
        o.status = 0 -- Int32
        o.needSendSelect = 0 -- Int32
        o.accumulativeWin = 0 -- Int64
        o.diceShowStep = 0 -- Int64
        return o
    end,
    Read = function(self, om)
        local d = om.d
        local r, n
        -- betMoney
        r, self.betMoney = d:Rvi32()
        if r ~= 0 then return r end
        -- lvID
        r, self.lvID = d:Rvi32()
        if r ~= 0 then return r end
        -- enterBase
        self.enterBase = PKG_Slots_Client_Enter_Success.Create(); r = self.enterBase:Read(om)
        if r ~= 0 then return r end
        -- resumedNormal
        self.resumedNormal = PKG_Slots_Client_LuckyDiceNormalRet.Create(); r = self.resumedNormal:Read(om)
        if r ~= 0 then return r end
        -- resumedFree
        self.resumedFree = PKG_Slots_Client_LuckyDiceFreeRet.Create(); r = self.resumedFree:Read(om)
        if r ~= 0 then return r end
        -- resumedDice
        self.resumedDice = PKG_Slots_Client_LuckyDiceDiceRet.Create(); r = self.resumedDice:Read(om)
        if r ~= 0 then return r end
        -- resumedSelect
        self.resumedSelect = PKG_Slots_Client_LuckyDiceSelectRet.Create(); r = self.resumedSelect:Read(om)
        if r ~= 0 then return r end
        -- status
        r, self.status = d:Rvi32()
        if r ~= 0 then return r end
        -- needSendSelect
        r, self.needSendSelect = d:Rvi32()
        if r ~= 0 then return r end
        -- accumulativeWin
        r, self.accumulativeWin = d:Rvi64()
        if r ~= 0 then return r end
        -- diceShowStep
        r, self.diceShowStep = d:Rvi64()
        if r ~= 0 then return r end
        return 0
    end,
    Write = function(self, om)
        local d = om.d
        -- betMoney
        d:Wvi32(self.betMoney)
        -- lvID
        d:Wvi32(self.lvID)
        -- enterBase
        self.enterBase:Write(om)
        -- resumedNormal
        self.resumedNormal:Write(om)
        -- resumedFree
        self.resumedFree:Write(om)
        -- resumedDice
        self.resumedDice:Write(om)
        -- resumedSelect
        self.resumedSelect:Write(om)
        -- status
        d:Wvi32(self.status)
        -- needSendSelect
        d:Wvi32(self.needSendSelect)
        -- accumulativeWin
        d:Wvi64(self.accumulativeWin)
        -- diceShowStep
        d:Wvi64(self.diceShowStep)
    end
}
PKG_Slots_Client_LuckyDiceEnterResumed.__index = PKG_Slots_Client_LuckyDiceEnterResumed

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

PKG_Client_Slots_LuckyDiceNormalSpin = {
    typeName = "PKG_Client_Slots_LuckyDiceNormalSpin",
    typeId = 31015,
    Create = function(o)
        if o == nil then
            o = {}
            setmetatable(o, PKG_Client_Slots_LuckyDiceNormalSpin)
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
PKG_Client_Slots_LuckyDiceNormalSpin.__index = PKG_Client_Slots_LuckyDiceNormalSpin

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

PKG_LuckyDice_Cell = {
    typeName = "PKG_LuckyDice_Cell",
    Create = function(o)
        if o == nil then
            o = {}
            setmetatable(o, PKG_LuckyDice_Cell)
        end
        --[[
        点对应下标
        ]]
        o.index = 0 -- Int32
        --[[
        点对应图形Id
        ]]
        o.icon = 0 -- Int32
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
PKG_LuckyDice_Cell.__index = PKG_LuckyDice_Cell

PKG_LuckyDice_Line = {
    typeName = "PKG_LuckyDice_Line",
    Create = function(o)
        if o == nil then
            o = {}
            setmetatable(o, PKG_LuckyDice_Line)
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
        o.lineCells = {} -- List<PKG.LuckyDice.Cell>
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
            o[i] = PKG_LuckyDice_Cell.Create(); r = o[i]:Read(om)
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
PKG_LuckyDice_Line.__index = PKG_LuckyDice_Line

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
o.Register(PKG_LuckyDice_Dice)
o.Register(PKG_LuckyDice_FreeSpin)
o.Register(PKG_LuckyDice_SelectType)
o.Register(PKG_LuckyDice_NormalSpin)
o.Register(PKG_LuckyDice_DiceSpin)
o.Register(PKG_Slots_Client_Enter_Success)
o.Register(PKG_Slots_Client_LuckyDiceNormalRet)
o.Register(PKG_Slots_Client_LuckyDiceFreeRet)
o.Register(PKG_Slots_Client_LuckyDiceDiceRet)
o.Register(PKG_Slots_Client_LuckyDiceSelectRet)
o.Register(PKG_Slots_Client_Leave_Success)
o.Register(PKG_Client_Slots_CionInfo)
o.Register(PKG_Client_Slots_Sync)
o.Register(PKG_Client_Slots_LockLeave)
o.Register(PKG_Client_Slots_Leave)
o.Register(PKG_Client_Slots_PlayerSit)
o.Register(PKG_Client_Slots_Enter)
o.Register(PKG_Client_Slots_LuckyDiceFreeType)
o.Register(PKG_Client_Slots_LuckyDiceDiceSpin)
o.Register(PKG_Client_Slots_LuckyDiceFreeSpin)
o.Register(PKG_Slots_Client_LuckyDiceEnterResumed)
o.Register(PKG_Slots_Client_CollectValue)
o.Register(PKG_Slots_Client_SyncPlayerStates)
o.Register(PKG_Slots_Client_LockLeaveSuccess)
o.Register(PKG_Slots_Client_OfflineCheck)
o.Register(PKG_Client_Slots_LuckyDiceNormalSpin)