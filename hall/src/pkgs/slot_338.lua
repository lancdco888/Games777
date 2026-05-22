
require('g_net')
CodeGen_slot_338_md5 ="#*MD5<fd409347afe249bd873fe1b3c2a7a3c8>*#"

--[[
免费类型选择
]]
PKG_CoinComboMouse_FreeType = {
    typeName = "PKG_CoinComboMouse_FreeType",
    typeId = 33892,
    Create = function(o)
        if o == nil then
            o = {}
            setmetatable(o, PKG_CoinComboMouse_FreeType)
        end
        --[[
        倍率类型
        ]]
        o.freeType = 0 -- Int32
        return o
    end,
    Read = function(self, om)
        local d = om.d
        local r, n
        -- freeType
        r, self.freeType = d:Rvi32()
        if r ~= 0 then return r end
        return 0
    end,
    Write = function(self, om)
        local d = om.d
        -- freeType
        d:Wvi32(self.freeType)
    end
}
PKG_CoinComboMouse_FreeType.__index = PKG_CoinComboMouse_FreeType

--[[
Sugar请求特殊旋转图形
]]
PKG_CoinComboMouse_NormalSpin = {
    typeName = "PKG_CoinComboMouse_NormalSpin",
    typeId = 33891,
    Create = function(o)
        if o == nil then
            o = {}
            setmetatable(o, PKG_CoinComboMouse_NormalSpin)
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
        o.grids = {} -- List<PKG.CoinComboMouse.Cell>
        o.wildBet = 0 -- Int32
        --[[
        是否进入免费游戏
        ]]
        o.intoFree = 0 -- Int32
        --[[
        (符合连线规则)
        ]]
        o.lines = {} -- List<PKG.CoinComboMouse.Line>
        --[[
        是否进入收集游戏
        ]]
        o.intoCollect = 0 -- Int32
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
            o[i] = PKG_CoinComboMouse_Cell.Create(); r = o[i]:Read(om)
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
            o[i] = PKG_CoinComboMouse_Line.Create(); r = o[i]:Read(om)
            if r ~= 0 then return r end
        end
        if r ~= 0 then return r end
        -- intoCollect
        r, self.intoCollect = d:Rvi32()
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
        -- lockStates
        d:Wvi32(self.lockStates)
    end
}
PKG_CoinComboMouse_NormalSpin.__index = PKG_CoinComboMouse_NormalSpin

--[[
Sugar请求免费旋转图形
]]
PKG_CoinComboMouse_FreeSpin = {
    typeName = "PKG_CoinComboMouse_FreeSpin",
    typeId = 33893,
    Create = function(o)
        if o == nil then
            o = {}
            setmetatable(o, PKG_CoinComboMouse_FreeSpin)
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
        o.grids = {} -- List<PKG.CoinComboMouse.Cell>
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
        是否进入收集游戏
        ]]
        o.intoCollect = 0 -- Int32
        --[[
        中奖的线
        ]]
        o.lines = {} -- List<PKG.CoinComboMouse.Line>
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
            o[i] = PKG_CoinComboMouse_Cell.Create(); r = o[i]:Read(om)
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
        -- intoCollect
        r, self.intoCollect = d:Rvi32()
        if r ~= 0 then return r end
        -- lines
        r, len = d:Rvu32()
        if len > d:GetLeft() then return -1 end
        o = {}
        self.lines = o
        for i = 1, len do
            o[i] = PKG_CoinComboMouse_Line.Create(); r = o[i]:Read(om)
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
        -- intoCollect
        d:Wvi32(self.intoCollect)
        -- lines
        o = self.lines
        len = #o
        d:Wvu32(len)
        for i = 1, len do
            o[i]:Write(om)
        end
    end
}
PKG_CoinComboMouse_FreeSpin.__index = PKG_CoinComboMouse_FreeSpin

--[[
Sugar请求特殊旋转图形
]]
PKG_CoinComboMouse_SpecialSpin = {
    typeName = "PKG_CoinComboMouse_SpecialSpin",
    typeId = 33894,
    Create = function(o)
        if o == nil then
            o = {}
            setmetatable(o, PKG_CoinComboMouse_SpecialSpin)
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
        o.grids = {} -- List<PKG.CoinComboMouse.Cell>
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
        o.lines = {} -- List<PKG.CoinComboMouse.Line>
        --[[
        大奖锁定
        ]]
        o.lockStates = 0 -- Int32
        o.hasdl = 0 -- Int32
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
            o[i] = PKG_CoinComboMouse_Cell.Create(); r = o[i]:Read(om)
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
            o[i] = PKG_CoinComboMouse_Line.Create(); r = o[i]:Read(om)
            if r ~= 0 then return r end
        end
        if r ~= 0 then return r end
        -- lockStates
        r, self.lockStates = d:Rvi32()
        if r ~= 0 then return r end
        -- hasdl
        r, self.hasdl = d:Rvi32()
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
        -- hasdl
        d:Wvi32(self.hasdl)
    end
}
PKG_CoinComboMouse_SpecialSpin.__index = PKG_CoinComboMouse_SpecialSpin

--[[
黄金万两-老鼠 免费游戏结果
]]
PKG_Slots_Client_CoinComboMouseFreeRet = {
    typeName = "PKG_Slots_Client_CoinComboMouseFreeRet", -- : PKG_CoinComboMouse_FreeSpin
    typeId = 33813,
    Create = function(o)
        if o == nil then
            o = {}
            setmetatable(o, PKG_Slots_Client_CoinComboMouseFreeRet)
        end
        PKG_CoinComboMouse_FreeSpin.Create(o)
        o.slotMoneyGift = PKG_SlotsBase_SlotMoneyGift.Create() -- PKG.SlotsBase.SlotMoneyGift
        o.slotMoney = PKG_SlotsBase_SlotMoney.Create() -- PKG.SlotsBase.SlotMoney
        return o
    end,
    Read = function(self, om)
        local d = om.d
        local r, n
        -- base read
        r = PKG_CoinComboMouse_FreeSpin.Read(self, om)
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
        PKG_CoinComboMouse_FreeSpin.Write(self, om)
        -- slotMoneyGift
        self.slotMoneyGift:Write(om)
        -- slotMoney
        self.slotMoney:Write(om)
    end
}
PKG_Slots_Client_CoinComboMouseFreeRet.__index = PKG_Slots_Client_CoinComboMouseFreeRet

--[[
黄金万两-老鼠 特殊结果
]]
PKG_Slots_Client_CoinComboMouseSpecialSpinRet = {
    typeName = "PKG_Slots_Client_CoinComboMouseSpecialSpinRet", -- : PKG_CoinComboMouse_SpecialSpin
    typeId = 33814,
    Create = function(o)
        if o == nil then
            o = {}
            setmetatable(o, PKG_Slots_Client_CoinComboMouseSpecialSpinRet)
        end
        PKG_CoinComboMouse_SpecialSpin.Create(o)
        return o
    end,
    Read = function(self, om)
        local d = om.d
        local r, n
        -- base read
        r = PKG_CoinComboMouse_SpecialSpin.Read(self, om)
        if r ~= 0 then return r end
        return 0
    end,
    Write = function(self, om)
        local d = om.d
        -- base read
        PKG_CoinComboMouse_SpecialSpin.Write(self, om)
    end
}
PKG_Slots_Client_CoinComboMouseSpecialSpinRet.__index = PKG_Slots_Client_CoinComboMouseSpecialSpinRet

--[[
黄金万两-老鼠 免费类型选择
]]
PKG_Slots_Client_CoinComboMouseFreeTypeRet = {
    typeName = "PKG_Slots_Client_CoinComboMouseFreeTypeRet", -- : PKG_CoinComboMouse_FreeType
    typeId = 33812,
    Create = function(o)
        if o == nil then
            o = {}
            setmetatable(o, PKG_Slots_Client_CoinComboMouseFreeTypeRet)
        end
        PKG_CoinComboMouse_FreeType.Create(o)
        return o
    end,
    Read = function(self, om)
        local d = om.d
        local r, n
        -- base read
        r = PKG_CoinComboMouse_FreeType.Read(self, om)
        if r ~= 0 then return r end
        return 0
    end,
    Write = function(self, om)
        local d = om.d
        -- base read
        PKG_CoinComboMouse_FreeType.Write(self, om)
    end
}
PKG_Slots_Client_CoinComboMouseFreeTypeRet.__index = PKG_Slots_Client_CoinComboMouseFreeTypeRet

--[[
黄金万两-老鼠-普通结果
]]
PKG_Slots_Client_CoinComboMouseNormalRet = {
    typeName = "PKG_Slots_Client_CoinComboMouseNormalRet", -- : PKG_CoinComboMouse_NormalSpin
    typeId = 33811,
    Create = function(o)
        if o == nil then
            o = {}
            setmetatable(o, PKG_Slots_Client_CoinComboMouseNormalRet)
        end
        PKG_CoinComboMouse_NormalSpin.Create(o)
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
        r = PKG_CoinComboMouse_NormalSpin.Read(self, om)
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
        PKG_CoinComboMouse_NormalSpin.Write(self, om)
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
PKG_Slots_Client_CoinComboMouseNormalRet.__index = PKG_Slots_Client_CoinComboMouseNormalRet

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
黄金万两-老鼠 请求特殊旋转图形
]]
PKG_Client_Slots_CoinComboMouseSpecialSpin = {
    typeName = "PKG_Client_Slots_CoinComboMouseSpecialSpin",
    typeId = 33804,
    Create = function(o)
        if o == nil then
            o = {}
            setmetatable(o, PKG_Client_Slots_CoinComboMouseSpecialSpin)
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
PKG_Client_Slots_CoinComboMouseSpecialSpin.__index = PKG_Client_Slots_CoinComboMouseSpecialSpin

--[[
黄金万两-老鼠 自定义免费中的12选3
]]
PKG_Client_Slots_FreeCoinInfo = {
    typeName = "PKG_Client_Slots_FreeCoinInfo",
    typeId = 33805,
    Create = function(o)
        if o == nil then
            o = {}
            setmetatable(o, PKG_Client_Slots_FreeCoinInfo)
        end
        o.coinSymbol = 1 -- Int32
        return o
    end,
    Read = function(self, om)
        local d = om.d
        local r, n
        -- coinSymbol
        r, self.coinSymbol = d:Rvi32()
        if r ~= 0 then return r end
        return 0
    end,
    Write = function(self, om)
        local d = om.d
        -- coinSymbol
        d:Wvi32(self.coinSymbol)
    end
}
PKG_Client_Slots_FreeCoinInfo.__index = PKG_Client_Slots_FreeCoinInfo

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
黄金万两-老鼠 -断线重连数据恢复
]]
PKG_Slots_Client_CoinComboMouseEnterResumed = {
    typeName = "PKG_Slots_Client_CoinComboMouseEnterResumed",
    typeId = 33815,
    Create = function(o)
        if o == nil then
            o = {}
            setmetatable(o, PKG_Slots_Client_CoinComboMouseEnterResumed)
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
        --[[
        当前押注等级
        ]]
        o.lvID = 0 -- Int32
        o.type = 0 -- Int32
        --[[
        游戏彩金已开的数组
        ]]
        o.cells = {} -- List<Int32>
        --[[
        恢复普通结果
        ]]
        o.resumedNormal = PKG_Slots_Client_CoinComboMouseNormalRet.Create() -- PKG.Slots_Client.CoinComboMouseNormalRet
        --[[
        恢复免费游戏类型
        ]]
        o.resumedFreeType = PKG_Slots_Client_CoinComboMouseFreeTypeRet.Create() -- PKG.Slots_Client.CoinComboMouseFreeTypeRet
        --[[
        恢复免费游戏结果
        ]]
        o.resumedFree = PKG_Slots_Client_CoinComboMouseFreeRet.Create() -- PKG.Slots_Client.CoinComboMouseFreeRet
        --[[
        恢复特殊游戏结果
        ]]
        o.specialRet = PKG_Slots_Client_CoinComboMouseSpecialSpinRet.Create() -- PKG.Slots_Client.CoinComboMouseSpecialSpinRet
        o.MoneyA = 0 -- Double
        o.MoneyB = 0 -- Double
        --[[
        免费游戏中的彩金已开的数组
        ]]
        o.freeCells = {} -- List<Int32>
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
        -- lvID
        r, self.lvID = d:Rvi32()
        if r ~= 0 then return r end
        -- type
        r, self.type = d:Rvi32()
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
        self.resumedNormal = PKG_Slots_Client_CoinComboMouseNormalRet.Create(); r = self.resumedNormal:Read(om)
        if r ~= 0 then return r end
        -- resumedFreeType
        self.resumedFreeType = PKG_Slots_Client_CoinComboMouseFreeTypeRet.Create(); r = self.resumedFreeType:Read(om)
        if r ~= 0 then return r end
        -- resumedFree
        self.resumedFree = PKG_Slots_Client_CoinComboMouseFreeRet.Create(); r = self.resumedFree:Read(om)
        if r ~= 0 then return r end
        -- specialRet
        self.specialRet = PKG_Slots_Client_CoinComboMouseSpecialSpinRet.Create(); r = self.specialRet:Read(om)
        if r ~= 0 then return r end
        -- MoneyA
        r, self.MoneyA = d:Rd()
        if r ~= 0 then return r end
        -- MoneyB
        r, self.MoneyB = d:Rd()
        if r ~= 0 then return r end
        -- freeCells
        r, len = d:Rvu32()
        if len > d:GetLeft() then return -1 end
        o = {}
        self.freeCells = o
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
        -- enterBase
        self.enterBase:Write(om)
        -- currentWinCoin
        d:Wd(self.currentWinCoin)
        -- currentBetMoney
        d:Wd(self.currentBetMoney)
        -- lvID
        d:Wvi32(self.lvID)
        -- type
        d:Wvi32(self.type)
        -- cells
        o = self.cells
        len = #o
        d:Wvu32(len)
        for i = 1, len do
            d:Wvi32(o[i])
        end
        -- resumedNormal
        self.resumedNormal:Write(om)
        -- resumedFreeType
        self.resumedFreeType:Write(om)
        -- resumedFree
        self.resumedFree:Write(om)
        -- specialRet
        self.specialRet:Write(om)
        -- MoneyA
        d:Wd(self.MoneyA)
        -- MoneyB
        d:Wd(self.MoneyB)
        -- freeCells
        o = self.freeCells
        len = #o
        d:Wvu32(len)
        for i = 1, len do
            d:Wvi32(o[i])
        end
    end
}
PKG_Slots_Client_CoinComboMouseEnterResumed.__index = PKG_Slots_Client_CoinComboMouseEnterResumed

--[[
黄金万两-老鼠 请求免费旋转图形
]]
PKG_Client_Slots_CoinComboMouseFreeSpin = {
    typeName = "PKG_Client_Slots_CoinComboMouseFreeSpin",
    typeId = 33803,
    Create = function(o)
        if o == nil then
            o = {}
            setmetatable(o, PKG_Client_Slots_CoinComboMouseFreeSpin)
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
PKG_Client_Slots_CoinComboMouseFreeSpin.__index = PKG_Client_Slots_CoinComboMouseFreeSpin

--[[
黄金万两-老鼠 请求免费类型
]]
PKG_Client_Slots_CoinComboMouseFreeType = {
    typeName = "PKG_Client_Slots_CoinComboMouseFreeType",
    typeId = 33802,
    Create = function(o)
        if o == nil then
            o = {}
            setmetatable(o, PKG_Client_Slots_CoinComboMouseFreeType)
        end
        --[[
        押注类型
        ]]
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
PKG_Client_Slots_CoinComboMouseFreeType.__index = PKG_Client_Slots_CoinComboMouseFreeType

--[[
Sugar请求获取生成图形
]]
PKG_Client_Slots_CoinComboMouseNormalSpin = {
    typeName = "PKG_Client_Slots_CoinComboMouseNormalSpin",
    typeId = 33801,
    Create = function(o)
        if o == nil then
            o = {}
            setmetatable(o, PKG_Client_Slots_CoinComboMouseNormalSpin)
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
PKG_Client_Slots_CoinComboMouseNormalSpin.__index = PKG_Client_Slots_CoinComboMouseNormalSpin

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

PKG_CoinComboMouse_Cell = {
    typeName = "PKG_CoinComboMouse_Cell",
    Create = function(o)
        if o == nil then
            o = {}
            setmetatable(o, PKG_CoinComboMouse_Cell)
        end
        --[[
        点对应下标
        ]]
        o.index = 0 -- Int32
        --[[
        点对应图形Id
        ]]
        o.icon = 0 -- Int32
        --[[
        图形的彩金值
        ]]
        o.SymbolValue = 0 -- Double
        --[[
        图形的彩金倍率
        ]]
        o.Symbolbet = 0 -- Double
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
        -- Symbolbet
        r, self.Symbolbet = d:Rd()
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
        -- Symbolbet
        d:Wd(self.Symbolbet)
    end
}
PKG_CoinComboMouse_Cell.__index = PKG_CoinComboMouse_Cell

PKG_CoinComboMouse_Line = {
    typeName = "PKG_CoinComboMouse_Line",
    Create = function(o)
        if o == nil then
            o = {}
            setmetatable(o, PKG_CoinComboMouse_Line)
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
        o.lineCells = {} -- List<PKG.CoinComboMouse.Cell>
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
            o[i] = PKG_CoinComboMouse_Cell.Create(); r = o[i]:Read(om)
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
PKG_CoinComboMouse_Line.__index = PKG_CoinComboMouse_Line

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
o.Register(PKG_CoinComboMouse_FreeType)
o.Register(PKG_CoinComboMouse_NormalSpin)
o.Register(PKG_CoinComboMouse_FreeSpin)
o.Register(PKG_CoinComboMouse_SpecialSpin)
o.Register(PKG_Slots_Client_CoinComboMouseFreeRet)
o.Register(PKG_Slots_Client_CoinComboMouseSpecialSpinRet)
o.Register(PKG_Slots_Client_CoinComboMouseFreeTypeRet)
o.Register(PKG_Slots_Client_CoinComboMouseNormalRet)
o.Register(PKG_Slots_Client_Enter_Success)
o.Register(PKG_Slots_Client_SyncPlayerStates)
o.Register(PKG_Client_Slots_CoinComboMouseSpecialSpin)
o.Register(PKG_Client_Slots_FreeCoinInfo)
o.Register(PKG_Slots_Client_LockLeaveSuccess)
o.Register(PKG_Slots_Client_CoinComboMouseEnterResumed)
o.Register(PKG_Client_Slots_CoinComboMouseFreeSpin)
o.Register(PKG_Client_Slots_CoinComboMouseFreeType)
o.Register(PKG_Client_Slots_CoinComboMouseNormalSpin)
o.Register(PKG_Slots_Client_Leave_Success)
o.Register(PKG_Slots_Client_CollectValue)
o.Register(PKG_Slots_Client_OfflineCheck)