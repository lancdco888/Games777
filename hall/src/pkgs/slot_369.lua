
require('g_net')
CodeGen_slot_369_md5 ="#*MD5<ca494223a0512890ce9a18dfbc521ab8>*#"

PKG_MoneyIcons_NormalSpin = {
    typeName = "PKG_MoneyIcons_NormalSpin",
    typeId = 36900,
    Create = function(o)
        if o == nil then
            o = {}
            setmetatable(o, PKG_MoneyIcons_NormalSpin)
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
        o.grids = {} -- List<PKG.MoneyIcons.Cell>
        --[[
        (符合连线规则)
        ]]
        o.lines = {} -- List<PKG.MoneyIcons.Line>
        --[[
        (转盘奖励信息)
        ]]
        o.rewards = {} -- List<PKG.MoneyIcons.Reward>
        --[[
        是否进入免费游戏
        ]]
        o.intoFree = 0 -- Int32
        --[[
        是否进入12选3
        ]]
        o.intoCollect = 0 -- Int32
        --[[
        是否进入转盘游戏
        ]]
        o.intoReward = 0 -- Int32
        --[[
        剩余免费次数。
        ]]
        o.freeTime = 0 -- Int32
        --[[
        两个奖励值范围。
        ]]
        o.pay1 = 0 -- Int64
        o.pay2 = 0 -- Int64
        --[[
        大奖锁定
        ]]
        o.lockStates = 0 -- Int32
        o.slotMoneyGift = PKG_SlotsBase_SlotMoneyGift.Create() -- PKG.SlotsBase.SlotMoneyGift
        o.slotMoney = PKG_SlotsBase_SlotMoney.Create() -- PKG.SlotsBase.SlotMoney
        o.levelUpMoney = 0 -- Int64
        o.levelUpMoneys = {} -- List<Int64>
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
            o[i] = PKG_MoneyIcons_Cell.Create(); r = o[i]:Read(om)
            if r ~= 0 then return r end
        end
        if r ~= 0 then return r end
        -- lines
        r, len = d:Rvu32()
        if len > d:GetLeft() then return -1 end
        o = {}
        self.lines = o
        for i = 1, len do
            o[i] = PKG_MoneyIcons_Line.Create(); r = o[i]:Read(om)
            if r ~= 0 then return r end
        end
        if r ~= 0 then return r end
        -- rewards
        r, len = d:Rvu32()
        if len > d:GetLeft() then return -1 end
        o = {}
        self.rewards = o
        for i = 1, len do
            o[i] = PKG_MoneyIcons_Reward.Create(); r = o[i]:Read(om)
            if r ~= 0 then return r end
        end
        if r ~= 0 then return r end
        -- intoFree
        r, self.intoFree = d:Rvi32()
        if r ~= 0 then return r end
        -- intoCollect
        r, self.intoCollect = d:Rvi32()
        if r ~= 0 then return r end
        -- intoReward
        r, self.intoReward = d:Rvi32()
        if r ~= 0 then return r end
        -- freeTime
        r, self.freeTime = d:Rvi32()
        if r ~= 0 then return r end
        -- pay1
        r, self.pay1 = d:Rvi64()
        if r ~= 0 then return r end
        -- pay2
        r, self.pay2 = d:Rvi64()
        if r ~= 0 then return r end
        -- lockStates
        r, self.lockStates = d:Rvi32()
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
        -- lines
        o = self.lines
        len = #o
        d:Wvu32(len)
        for i = 1, len do
            o[i]:Write(om)
        end
        -- rewards
        o = self.rewards
        len = #o
        d:Wvu32(len)
        for i = 1, len do
            o[i]:Write(om)
        end
        -- intoFree
        d:Wvi32(self.intoFree)
        -- intoCollect
        d:Wvi32(self.intoCollect)
        -- intoReward
        d:Wvi32(self.intoReward)
        -- freeTime
        d:Wvi32(self.freeTime)
        -- pay1
        d:Wvi64(self.pay1)
        -- pay2
        d:Wvi64(self.pay2)
        -- lockStates
        d:Wvi32(self.lockStates)
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
PKG_MoneyIcons_NormalSpin.__index = PKG_MoneyIcons_NormalSpin

PKG_MoneyIcons_FreeSpin = {
    typeName = "PKG_MoneyIcons_FreeSpin",
    typeId = 36901,
    Create = function(o)
        if o == nil then
            o = {}
            setmetatable(o, PKG_MoneyIcons_FreeSpin)
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
        o.grids = {} -- List<PKG.MoneyIcons.Cell>
        --[[
        中奖的线
        ]]
        o.lines = {} -- List<PKG.MoneyIcons.Line>
        --[[
        剩余免费次数。
        ]]
        o.freeTime = 0 -- Int32
        --[[
        总免费次数。
        ]]
        o.totalFreeTime = 0 -- Int32
        --[[
        是否进入12选3
        ]]
        o.intoCollect = 0 -- Int32
        o.slotMoneyGift = PKG_SlotsBase_SlotMoneyGift.Create() -- PKG.SlotsBase.SlotMoneyGift
        o.slotMoney = PKG_SlotsBase_SlotMoney.Create() -- PKG.SlotsBase.SlotMoney
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
            o[i] = PKG_MoneyIcons_Cell.Create(); r = o[i]:Read(om)
            if r ~= 0 then return r end
        end
        if r ~= 0 then return r end
        -- lines
        r, len = d:Rvu32()
        if len > d:GetLeft() then return -1 end
        o = {}
        self.lines = o
        for i = 1, len do
            o[i] = PKG_MoneyIcons_Line.Create(); r = o[i]:Read(om)
            if r ~= 0 then return r end
        end
        if r ~= 0 then return r end
        -- freeTime
        r, self.freeTime = d:Rvi32()
        if r ~= 0 then return r end
        -- totalFreeTime
        r, self.totalFreeTime = d:Rvi32()
        if r ~= 0 then return r end
        -- intoCollect
        r, self.intoCollect = d:Rvi32()
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
        -- lines
        o = self.lines
        len = #o
        d:Wvu32(len)
        for i = 1, len do
            o[i]:Write(om)
        end
        -- freeTime
        d:Wvi32(self.freeTime)
        -- totalFreeTime
        d:Wvi32(self.totalFreeTime)
        -- intoCollect
        d:Wvi32(self.intoCollect)
        -- slotMoneyGift
        self.slotMoneyGift:Write(om)
        -- slotMoney
        self.slotMoney:Write(om)
    end
}
PKG_MoneyIcons_FreeSpin.__index = PKG_MoneyIcons_FreeSpin

PKG_MoneyIcons_RewardSpin = {
    typeName = "PKG_MoneyIcons_RewardSpin",
    typeId = 36902,
    Create = function(o)
        if o == nil then
            o = {}
            setmetatable(o, PKG_MoneyIcons_RewardSpin)
        end
        --[[
        转盘上的当前奖励情况。
        ]]
        o.rewards = {} -- List<PKG.MoneyIcons.Reward>
        --[[
        本次中奖。
        ]]
        o.thisReward = PKG_MoneyIcons_Reward.Create() -- PKG.MoneyIcons.Reward
        --[[
        剩余中奖次数。
        ]]
        o.rewardTime = 0 -- Int32
        --[[
        免费剩余次数。
        ]]
        o.freeTime = 0 -- Int32
        --[[
        两个奖励值范围。
        ]]
        o.pay1 = 5 -- Int64
        o.pay2 = 6 -- Int64
        o.slotMoneyGift = PKG_SlotsBase_SlotMoneyGift.Create() -- PKG.SlotsBase.SlotMoneyGift
        o.slotMoney = PKG_SlotsBase_SlotMoney.Create() -- PKG.SlotsBase.SlotMoney
        return o
    end,
    Read = function(self, om)
        local d = om.d
        local r, n, o
        -- rewards
        r, len = d:Rvu32()
        if len > d:GetLeft() then return -1 end
        o = {}
        self.rewards = o
        for i = 1, len do
            o[i] = PKG_MoneyIcons_Reward.Create(); r = o[i]:Read(om)
            if r ~= 0 then return r end
        end
        if r ~= 0 then return r end
        -- thisReward
        self.thisReward = PKG_MoneyIcons_Reward.Create(); r = self.thisReward:Read(om)
        if r ~= 0 then return r end
        -- rewardTime
        r, self.rewardTime = d:Rvi32()
        if r ~= 0 then return r end
        -- freeTime
        r, self.freeTime = d:Rvi32()
        if r ~= 0 then return r end
        -- pay1
        r, self.pay1 = d:Rvi64()
        if r ~= 0 then return r end
        -- pay2
        r, self.pay2 = d:Rvi64()
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
        local o, len
        -- rewards
        o = self.rewards
        len = #o
        d:Wvu32(len)
        for i = 1, len do
            o[i]:Write(om)
        end
        -- thisReward
        self.thisReward:Write(om)
        -- rewardTime
        d:Wvi32(self.rewardTime)
        -- freeTime
        d:Wvi32(self.freeTime)
        -- pay1
        d:Wvi64(self.pay1)
        -- pay2
        d:Wvi64(self.pay2)
        -- slotMoneyGift
        self.slotMoneyGift:Write(om)
        -- slotMoney
        self.slotMoney:Write(om)
    end
}
PKG_MoneyIcons_RewardSpin.__index = PKG_MoneyIcons_RewardSpin

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
普通旋转
]]
PKG_Slots_Client_MoneyIconsNormalRet = {
    typeName = "PKG_Slots_Client_MoneyIconsNormalRet",
    typeId = 36910,
    Create = function(o)
        if o == nil then
            o = {}
            setmetatable(o, PKG_Slots_Client_MoneyIconsNormalRet)
        end
        o.normalSpin = PKG_MoneyIcons_NormalSpin.Create() -- PKG.MoneyIcons.NormalSpin
        return o
    end,
    Read = function(self, om)
        local d = om.d
        local r, n
        -- normalSpin
        self.normalSpin = PKG_MoneyIcons_NormalSpin.Create(); r = self.normalSpin:Read(om)
        if r ~= 0 then return r end
        return 0
    end,
    Write = function(self, om)
        local d = om.d
        -- normalSpin
        self.normalSpin:Write(om)
    end
}
PKG_Slots_Client_MoneyIconsNormalRet.__index = PKG_Slots_Client_MoneyIconsNormalRet

--[[
免费旋转
]]
PKG_Slots_Client_MoneyIconsFreeRet = {
    typeName = "PKG_Slots_Client_MoneyIconsFreeRet",
    typeId = 36911,
    Create = function(o)
        if o == nil then
            o = {}
            setmetatable(o, PKG_Slots_Client_MoneyIconsFreeRet)
        end
        o.freeSpin = PKG_MoneyIcons_FreeSpin.Create() -- PKG.MoneyIcons.FreeSpin
        return o
    end,
    Read = function(self, om)
        local d = om.d
        local r, n
        -- freeSpin
        self.freeSpin = PKG_MoneyIcons_FreeSpin.Create(); r = self.freeSpin:Read(om)
        if r ~= 0 then return r end
        return 0
    end,
    Write = function(self, om)
        local d = om.d
        -- freeSpin
        self.freeSpin:Write(om)
    end
}
PKG_Slots_Client_MoneyIconsFreeRet.__index = PKG_Slots_Client_MoneyIconsFreeRet

--[[
转盘旋转
]]
PKG_Slots_Client_MoneyIconsRewardRet = {
    typeName = "PKG_Slots_Client_MoneyIconsRewardRet",
    typeId = 36912,
    Create = function(o)
        if o == nil then
            o = {}
            setmetatable(o, PKG_Slots_Client_MoneyIconsRewardRet)
        end
        o.rewardSpin = PKG_MoneyIcons_RewardSpin.Create() -- PKG.MoneyIcons.RewardSpin
        return o
    end,
    Read = function(self, om)
        local d = om.d
        local r, n
        -- rewardSpin
        self.rewardSpin = PKG_MoneyIcons_RewardSpin.Create(); r = self.rewardSpin:Read(om)
        if r ~= 0 then return r end
        return 0
    end,
    Write = function(self, om)
        local d = om.d
        -- rewardSpin
        self.rewardSpin:Write(om)
    end
}
PKG_Slots_Client_MoneyIconsRewardRet.__index = PKG_Slots_Client_MoneyIconsRewardRet

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
断线重连
]]
PKG_Slots_Client_MoneyIconsEnterResumed = {
    typeName = "PKG_Slots_Client_MoneyIconsEnterResumed",
    typeId = 36913,
    Create = function(o)
        if o == nil then
            o = {}
            setmetatable(o, PKG_Slots_Client_MoneyIconsEnterResumed)
        end
        --[[
        押注等级
        ]]
        o.lvID = 0 -- Int32
        --[[
        当前赢钱面板上显示的金额
        ]]
        o.currentWinCoin = 0 -- Int64
        --[[
        当前押注金额
        ]]
        o.currentBetMoney = 0 -- Int64
        --[[
        进入游戏的常规数据恢复
        ]]
        o.enterBase = PKG_Slots_Client_Enter_Success.Create() -- PKG.Slots_Client.Enter_Success
        --[[
        恢复普通结果
        ]]
        o.resumedNormal = PKG_Slots_Client_MoneyIconsNormalRet.Create() -- PKG.Slots_Client.MoneyIconsNormalRet
        --[[
        恢复免费游戏结果
        ]]
        o.resumedFree = PKG_Slots_Client_MoneyIconsFreeRet.Create() -- PKG.Slots_Client.MoneyIconsFreeRet
        --[[
        恢复转盘游戏结果
        ]]
        o.resumedReward = PKG_Slots_Client_MoneyIconsRewardRet.Create() -- PKG.Slots_Client.MoneyIconsRewardRet
        o.status = 0 -- Int32
        --[[
        游戏彩金已开的数组
        ]]
        o.cells = {} -- List<Int32>
        return o
    end,
    Read = function(self, om)
        local d = om.d
        local r, n, o
        -- lvID
        r, self.lvID = d:Rvi32()
        if r ~= 0 then return r end
        -- currentWinCoin
        r, self.currentWinCoin = d:Rvi64()
        if r ~= 0 then return r end
        -- currentBetMoney
        r, self.currentBetMoney = d:Rvi64()
        if r ~= 0 then return r end
        -- enterBase
        self.enterBase = PKG_Slots_Client_Enter_Success.Create(); r = self.enterBase:Read(om)
        if r ~= 0 then return r end
        -- resumedNormal
        self.resumedNormal = PKG_Slots_Client_MoneyIconsNormalRet.Create(); r = self.resumedNormal:Read(om)
        if r ~= 0 then return r end
        -- resumedFree
        self.resumedFree = PKG_Slots_Client_MoneyIconsFreeRet.Create(); r = self.resumedFree:Read(om)
        if r ~= 0 then return r end
        -- resumedReward
        self.resumedReward = PKG_Slots_Client_MoneyIconsRewardRet.Create(); r = self.resumedReward:Read(om)
        if r ~= 0 then return r end
        -- status
        r, self.status = d:Rvi32()
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
        return 0
    end,
    Write = function(self, om)
        local d = om.d
        local o, len
        -- lvID
        d:Wvi32(self.lvID)
        -- currentWinCoin
        d:Wvi64(self.currentWinCoin)
        -- currentBetMoney
        d:Wvi64(self.currentBetMoney)
        -- enterBase
        self.enterBase:Write(om)
        -- resumedNormal
        self.resumedNormal:Write(om)
        -- resumedFree
        self.resumedFree:Write(om)
        -- resumedReward
        self.resumedReward:Write(om)
        -- status
        d:Wvi32(self.status)
        -- cells
        o = self.cells
        len = #o
        d:Wvu32(len)
        for i = 1, len do
            d:Wvi32(o[i])
        end
    end
}
PKG_Slots_Client_MoneyIconsEnterResumed.__index = PKG_Slots_Client_MoneyIconsEnterResumed

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
请求转盘图形
]]
PKG_Client_Slots_MoneyIconsRewardSpin = {
    typeName = "PKG_Client_Slots_MoneyIconsRewardSpin",
    typeId = 36922,
    Create = function(o)
        if o == nil then
            o = {}
            setmetatable(o, PKG_Client_Slots_MoneyIconsRewardSpin)
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
PKG_Client_Slots_MoneyIconsRewardSpin.__index = PKG_Client_Slots_MoneyIconsRewardSpin

--[[
请求免费旋转图形
]]
PKG_Client_Slots_MoneyIconsFreeSpin = {
    typeName = "PKG_Client_Slots_MoneyIconsFreeSpin",
    typeId = 36921,
    Create = function(o)
        if o == nil then
            o = {}
            setmetatable(o, PKG_Client_Slots_MoneyIconsFreeSpin)
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
PKG_Client_Slots_MoneyIconsFreeSpin.__index = PKG_Client_Slots_MoneyIconsFreeSpin

--[[
请求获取生成图形
]]
PKG_Client_Slots_MoneyIconsNormalSpin = {
    typeName = "PKG_Client_Slots_MoneyIconsNormalSpin",
    typeId = 36920,
    Create = function(o)
        if o == nil then
            o = {}
            setmetatable(o, PKG_Client_Slots_MoneyIconsNormalSpin)
        end
        --[[
        押注金额
        ]]
        o.betMoney = 0 -- Double
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
        r, self.betMoney = d:Rd()
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
        d:Wd(self.betMoney)
        -- moneyType
        d:Wvi32(self.moneyType)
        -- lvID
        d:Wvi32(self.lvID)
    end
}
PKG_Client_Slots_MoneyIconsNormalSpin.__index = PKG_Client_Slots_MoneyIconsNormalSpin

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

PKG_MoneyIcons_IconReward = {
    typeName = "PKG_MoneyIcons_IconReward",
    Create = function(o)
        if o == nil then
            o = {}
            setmetatable(o, PKG_MoneyIcons_IconReward)
        end
        --[[
        中奖的铜钱位置。
        ]]
        o.index = 0 -- Int32
        --[[
        中奖的铜钱金额。
        ]]
        o.money = 0 -- Double
        return o
    end,
    Read = function(self, om)
        local d = om.d
        local r, n
        -- index
        r, self.index = d:Rvi32()
        if r ~= 0 then return r end
        -- money
        r, self.money = d:Rd()
        if r ~= 0 then return r end
        return 0
    end,
    Write = function(self, om)
        local d = om.d
        -- index
        d:Wvi32(self.index)
        -- money
        d:Wd(self.money)
    end
}
PKG_MoneyIcons_IconReward.__index = PKG_MoneyIcons_IconReward

PKG_MoneyIcons_Cell = {
    typeName = "PKG_MoneyIcons_Cell",
    Create = function(o)
        if o == nil then
            o = {}
            setmetatable(o, PKG_MoneyIcons_Cell)
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
PKG_MoneyIcons_Cell.__index = PKG_MoneyIcons_Cell

PKG_MoneyIcons_Reward = {
    typeName = "PKG_MoneyIcons_Reward",
    Create = function(o)
        if o == nil then
            o = {}
            setmetatable(o, PKG_MoneyIcons_Reward)
        end
        o.rewardType = 0 -- Int32
        o.value1 = 0 -- Int64
        o.value2 = 0 -- Int64
        o.change1 = 0 -- Int64
        o.change2 = 0 -- Int64
        return o
    end,
    Read = function(self, om)
        local d = om.d
        local r, n
        -- rewardType
        r, self.rewardType = d:Rvi32()
        if r ~= 0 then return r end
        -- value1
        r, self.value1 = d:Rvi64()
        if r ~= 0 then return r end
        -- value2
        r, self.value2 = d:Rvi64()
        if r ~= 0 then return r end
        -- change1
        r, self.change1 = d:Rvi64()
        if r ~= 0 then return r end
        -- change2
        r, self.change2 = d:Rvi64()
        if r ~= 0 then return r end
        return 0
    end,
    Write = function(self, om)
        local d = om.d
        -- rewardType
        d:Wvi32(self.rewardType)
        -- value1
        d:Wvi64(self.value1)
        -- value2
        d:Wvi64(self.value2)
        -- change1
        d:Wvi64(self.change1)
        -- change2
        d:Wvi64(self.change2)
    end
}
PKG_MoneyIcons_Reward.__index = PKG_MoneyIcons_Reward

PKG_MoneyIcons_Line = {
    typeName = "PKG_MoneyIcons_Line",
    Create = function(o)
        if o == nil then
            o = {}
            setmetatable(o, PKG_MoneyIcons_Line)
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
        o.icon = 0 -- Int32
        --[[
        一条线上的中奖集合
        ]]
        o.lineCells = {} -- List<PKG.MoneyIcons.Cell>
        --[[
        这条线上，铜钱奖励的钱。
        ]]
        o.iconRewards = {} -- List<PKG.MoneyIcons.IconReward>
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
            o[i] = PKG_MoneyIcons_Cell.Create(); r = o[i]:Read(om)
            if r ~= 0 then return r end
        end
        if r ~= 0 then return r end
        -- iconRewards
        r, len = d:Rvu32()
        if len > d:GetLeft() then return -1 end
        o = {}
        self.iconRewards = o
        for i = 1, len do
            o[i] = PKG_MoneyIcons_IconReward.Create(); r = o[i]:Read(om)
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
        -- iconRewards
        o = self.iconRewards
        len = #o
        d:Wvu32(len)
        for i = 1, len do
            o[i]:Write(om)
        end
    end
}
PKG_MoneyIcons_Line.__index = PKG_MoneyIcons_Line

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
o.Register(PKG_MoneyIcons_NormalSpin)
o.Register(PKG_MoneyIcons_FreeSpin)
o.Register(PKG_MoneyIcons_RewardSpin)
o.Register(PKG_Slots_Client_Enter_Success)
o.Register(PKG_Slots_Client_MoneyIconsNormalRet)
o.Register(PKG_Slots_Client_MoneyIconsFreeRet)
o.Register(PKG_Slots_Client_MoneyIconsRewardRet)
o.Register(PKG_Slots_Client_Leave_Success)
o.Register(PKG_Slots_Client_CollectValue)
o.Register(PKG_Slots_Client_MoneyIconsEnterResumed)
o.Register(PKG_Slots_Client_OfflineCheck)
o.Register(PKG_Client_Slots_MoneyIconsRewardSpin)
o.Register(PKG_Client_Slots_MoneyIconsFreeSpin)
o.Register(PKG_Client_Slots_MoneyIconsNormalSpin)
o.Register(PKG_Slots_Client_LockLeaveSuccess)
o.Register(PKG_Slots_Client_SyncPlayerStates)