
CodeGen_slot_207_md5 ="#*MD5<ceb84518eba06872ebe0407a063ab397>*#"

PKG_Festival_FestivalSymbol = {
    FestivalMammon = 1,
    Festival9 = 2,
    Festival10 = 3,
    FestivalJ = 4,
    FestivalQ = 5,
    FestivalK = 6,
    FestivalFirecrackers = 7,
    FestivalRedEnvelope = 8,
    FestivalMoneyTree = 9,
    FestivalDrum = 10,
    FestivalLion = 11,
    FestivalLantern = 12
}
--[[
Sugar请求特殊旋转图形
]]
PKG_Festival_FestivalBase = {
    typeName = "PKG_Festival_FestivalBase",
    typeId = 30153,
    Create = function(o)
        if o == nil then
            o = {}
            setmetatable(o, PKG_Festival_FestivalBase)
        end
        --[[
        总押注(一次旋转 免费游戏为0)
        ]]
        o.bet = 0 -- Double
        --[[
        总赢钱(一次旋转)
        ]]
        o.winCoin = 0 -- Double
        --[[
        中奖转盘剩余次数
        ]]
        o.validSpinCount = 0 -- Int32
        --[[
        中奖转盘总次数
        ]]
        o.totalSpinCount = 0 -- Int32
        --[[
        免费游戏增加的替代图形数量
        ]]
        o.freeWildCount = 0 -- Int32
        --[[
        生成的15个图形集合
        ]]
        o.grids = {} -- List<PKG.Festival.Cell>
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
        -- validSpinCount
        r, self.validSpinCount = d:Rvi32()
        if r ~= 0 then return r end
        -- totalSpinCount
        r, self.totalSpinCount = d:Rvi32()
        if r ~= 0 then return r end
        -- freeWildCount
        r, self.freeWildCount = d:Rvi32()
        if r ~= 0 then return r end
        -- grids
        r, len = d:Rvu32()
        if len > d:GetLeft() then return -1 end
        o = {}
        self.grids = o
        for i = 1, len do
            o[i] = PKG_Festival_Cell.Create(); r = o[i]:Read(om)
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
        -- validSpinCount
        d:Wvi32(self.validSpinCount)
        -- totalSpinCount
        d:Wvi32(self.totalSpinCount)
        -- freeWildCount
        d:Wvi32(self.freeWildCount)
        -- grids
        o = self.grids
        len = #o
        d:Wvu32(len)
        for i = 1, len do
            o[i]:Write(om)
        end
    end
}
PKG_Festival_FestivalBase.__index = PKG_Festival_FestivalBase

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
PKG_Slots_Client_FestivalSpinNormalRet = {
    typeName = "PKG_Slots_Client_FestivalSpinNormalRet", -- : PKG_Festival_FestivalBase
    typeId = 30375,
    Create = function(o)
        if o == nil then
            o = {}
            setmetatable(o, PKG_Slots_Client_FestivalSpinNormalRet)
        end
        PKG_Festival_FestivalBase.Create(o)
        --[[
        免费游戏
        ]]
        o.LionFreeLine = null -- Nullable<PKG.Festival.Line>
        --[[
        lightning resipn
        ]]
        o.resipnLine = null -- Nullable<PKG.Festival.Line>
        --[[
        普通的中奖线组(符合连线规则)
        ]]
        o.lines = {} -- List<PKG.Festival.Line>
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
        r = PKG_Festival_FestivalBase.Read(self, om)
        if r ~= 0 then return r end
        -- LionFreeLine
        r, n = d:Ru8(); if r ~= 0 then return r end; if n == 0 then self.LionFreeLine = null else self.LionFreeLine = PKG_Festival_Line.Create(); r = self.LionFreeLine:Read(om) end
        if r ~= 0 then return r end
        -- resipnLine
        r, n = d:Ru8(); if r ~= 0 then return r end; if n == 0 then self.resipnLine = null else self.resipnLine = PKG_Festival_Line.Create(); r = self.resipnLine:Read(om) end
        if r ~= 0 then return r end
        -- lines
        r, len = d:Rvu32()
        if len > d:GetLeft() then return -1 end
        o = {}
        self.lines = o
        for i = 1, len do
            o[i] = PKG_Festival_Line.Create(); r = o[i]:Read(om)
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
        return 0
    end,
    Write = function(self, om)
        local d = om.d
        local o, len
        -- base read
        PKG_Festival_FestivalBase.Write(self, om)
        -- LionFreeLine
        if self.LionFreeLine == null then d:Wu8(0) else d:Wu8(1); self.LionFreeLine:Write(om) end
        -- resipnLine
        if self.resipnLine == null then d:Wu8(0) else d:Wu8(1); self.resipnLine:Write(om) end
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
    end
}
PKG_Slots_Client_FestivalSpinNormalRet.__index = PKG_Slots_Client_FestivalSpinNormalRet

--[[
狂野蛮牛 免费游戏结果
]]
PKG_Slots_Client_FestivalLionFreeRet = {
    typeName = "PKG_Slots_Client_FestivalLionFreeRet", -- : PKG_Festival_FestivalBase
    typeId = 30376,
    Create = function(o)
        if o == nil then
            o = {}
            setmetatable(o, PKG_Slots_Client_FestivalLionFreeRet)
        end
        PKG_Festival_FestivalBase.Create(o)
        --[[
        转盘次数为0时，返回的Bonus Win
        ]]
        o.bonusWinCoin = 0 -- Double
        --[[
        中奖的线
        ]]
        o.lines = {} -- List<PKG.Festival.Line>
        o.slotMoneyGift = PKG_SlotsBase_SlotMoneyGift.Create() -- PKG.SlotsBase.SlotMoneyGift
        o.slotMoney = PKG_SlotsBase_SlotMoney.Create() -- PKG.SlotsBase.SlotMoney
        return o
    end,
    Read = function(self, om)
        local d = om.d
        local r, n, o
        -- base read
        r = PKG_Festival_FestivalBase.Read(self, om)
        if r ~= 0 then return r end
        -- bonusWinCoin
        r, self.bonusWinCoin = d:Rd()
        if r ~= 0 then return r end
        -- lines
        r, len = d:Rvu32()
        if len > d:GetLeft() then return -1 end
        o = {}
        self.lines = o
        for i = 1, len do
            o[i] = PKG_Festival_Line.Create(); r = o[i]:Read(om)
            if r ~= 0 then return r end
        end
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
        -- base read
        PKG_Festival_FestivalBase.Write(self, om)
        -- bonusWinCoin
        d:Wd(self.bonusWinCoin)
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
    end
}
PKG_Slots_Client_FestivalLionFreeRet.__index = PKG_Slots_Client_FestivalLionFreeRet

--[[
狂野蛮牛 免费游戏结果
]]
PKG_Slots_Client_FestivalResipnRet = {
    typeName = "PKG_Slots_Client_FestivalResipnRet", -- : PKG_Festival_FestivalBase
    typeId = 30377,
    Create = function(o)
        if o == nil then
            o = {}
            setmetatable(o, PKG_Slots_Client_FestivalResipnRet)
        end
        PKG_Festival_FestivalBase.Create(o)
        --[[
        转盘次数为0时，返回的Bonus Win
        ]]
        o.bonusWinCoin = 0 -- Double
        --[[
        	正常状态 0,大奖锁住 1,巨奖锁住 2
        ]]
        o.lockStates = 0 -- Int32
        o.slotMoneyGift = PKG_SlotsBase_SlotMoneyGift.Create() -- PKG.SlotsBase.SlotMoneyGift
        o.slotMoney = PKG_SlotsBase_SlotMoney.Create() -- PKG.SlotsBase.SlotMoney
        return o
    end,
    Read = function(self, om)
        local d = om.d
        local r, n
        -- base read
        r = PKG_Festival_FestivalBase.Read(self, om)
        if r ~= 0 then return r end
        -- bonusWinCoin
        r, self.bonusWinCoin = d:Rd()
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
        return 0
    end,
    Write = function(self, om)
        local d = om.d
        -- base read
        PKG_Festival_FestivalBase.Write(self, om)
        -- bonusWinCoin
        d:Wd(self.bonusWinCoin)
        -- lockStates
        d:Wvi32(self.lockStates)
        -- slotMoneyGift
        self.slotMoneyGift:Write(om)
        -- slotMoney
        self.slotMoney:Write(om)
    end
}
PKG_Slots_Client_FestivalResipnRet.__index = PKG_Slots_Client_FestivalResipnRet

--[[
Sugar请求特殊旋转图形
]]
PKG_Client_Slots_FestivalResipnSpin = {
    typeName = "PKG_Client_Slots_FestivalResipnSpin",
    typeId = 30374,
    Create = function(o)
        if o == nil then
            o = {}
            setmetatable(o, PKG_Client_Slots_FestivalResipnSpin)
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
PKG_Client_Slots_FestivalResipnSpin.__index = PKG_Client_Slots_FestivalResipnSpin

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
Sugar请求获取生成图形
]]
PKG_Client_Slots_FestivalNormalSpin = {
    typeName = "PKG_Client_Slots_FestivalNormalSpin",
    typeId = 30372,
    Create = function(o)
        if o == nil then
            o = {}
            setmetatable(o, PKG_Client_Slots_FestivalNormalSpin)
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
PKG_Client_Slots_FestivalNormalSpin.__index = PKG_Client_Slots_FestivalNormalSpin

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
狂野蛮牛 -断线重连数据恢复
]]
PKG_Slots_Client_FestivalEnterResumed = {
    typeName = "PKG_Slots_Client_FestivalEnterResumed",
    typeId = 30378,
    Create = function(o)
        if o == nil then
            o = {}
            setmetatable(o, PKG_Slots_Client_FestivalEnterResumed)
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
        恢复普通结果
        ]]
        o.resumedNormal = null -- Nullable<PKG.Slots_Client.FestivalSpinNormalRet>
        --[[
        恢复免费游戏结果
        ]]
        o.resumedFree = null -- Nullable<PKG.Slots_Client.FestivalLionFreeRet>
        --[[
        恢复特殊游戏结果
        ]]
        o.resumedResipn = null -- Nullable<PKG.Slots_Client.FestivalResipnRet>
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
        -- resumedNormal
        r, n = d:Ru8(); if r ~= 0 then return r end; if n == 0 then self.resumedNormal = null else self.resumedNormal = PKG_Slots_Client_FestivalSpinNormalRet.Create(); r = self.resumedNormal:Read(om) end
        if r ~= 0 then return r end
        -- resumedFree
        r, n = d:Ru8(); if r ~= 0 then return r end; if n == 0 then self.resumedFree = null else self.resumedFree = PKG_Slots_Client_FestivalLionFreeRet.Create(); r = self.resumedFree:Read(om) end
        if r ~= 0 then return r end
        -- resumedResipn
        r, n = d:Ru8(); if r ~= 0 then return r end; if n == 0 then self.resumedResipn = null else self.resumedResipn = PKG_Slots_Client_FestivalResipnRet.Create(); r = self.resumedResipn:Read(om) end
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
        -- resumedNormal
        if self.resumedNormal == null then d:Wu8(0) else d:Wu8(1); self.resumedNormal:Write(om) end
        -- resumedFree
        if self.resumedFree == null then d:Wu8(0) else d:Wu8(1); self.resumedFree:Write(om) end
        -- resumedResipn
        if self.resumedResipn == null then d:Wu8(0) else d:Wu8(1); self.resumedResipn:Write(om) end
    end
}
PKG_Slots_Client_FestivalEnterResumed.__index = PKG_Slots_Client_FestivalEnterResumed

--[[
Sugar请求特殊旋转图形
]]
PKG_Client_Slots_FestivalLionFreeSpin = {
    typeName = "PKG_Client_Slots_FestivalLionFreeSpin",
    typeId = 30373,
    Create = function(o)
        if o == nil then
            o = {}
            setmetatable(o, PKG_Client_Slots_FestivalLionFreeSpin)
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
PKG_Client_Slots_FestivalLionFreeSpin.__index = PKG_Client_Slots_FestivalLionFreeSpin

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

PKG_Festival_Cell = {
    typeName = "PKG_Festival_Cell",
    Create = function(o)
        if o == nil then
            o = {}
            setmetatable(o, PKG_Festival_Cell)
        end
        --[[
        点对应下标
        ]]
        o.index = 0 -- Int32
        --[[
        点对应图形Id
        ]]
        o.icon = 0 -- PKG.Festival.FestivalSymbol
        --[[
        点对应图形Id的类型 0为常规图形 其他为有奖图形 1普通奖励 2小奖分值 3中奖分值 4大奖分值 5巨奖分值
        ]]
        o.FestivalSymbolType = 0 -- Int32
        --[[
        图形的彩金值
        ]]
        o.FestivalSymbolValue = 0 -- Double
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
        -- FestivalSymbolType
        r, self.FestivalSymbolType = d:Rvi32()
        if r ~= 0 then return r end
        -- FestivalSymbolValue
        r, self.FestivalSymbolValue = d:Rd()
        if r ~= 0 then return r end
        return 0
    end,
    Write = function(self, om)
        local d = om.d
        -- index
        d:Wvi32(self.index)
        -- icon
        d:Wvi32(self.icon)
        -- FestivalSymbolType
        d:Wvi32(self.FestivalSymbolType)
        -- FestivalSymbolValue
        d:Wd(self.FestivalSymbolValue)
    end
}
PKG_Festival_Cell.__index = PKG_Festival_Cell

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

PKG_Festival_Line = {
    typeName = "PKG_Festival_Line",
    Create = function(o)
        if o == nil then
            o = {}
            setmetatable(o, PKG_Festival_Line)
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
        o.icon = 0 -- PKG.Festival.FestivalSymbol
        --[[
        一条线上的中奖集合
        ]]
        o.lineCells = {} -- List<PKG.Festival.Cell>
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
            o[i] = PKG_Festival_Cell.Create(); r = o[i]:Read(om)
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
PKG_Festival_Line.__index = PKG_Festival_Line

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
o.Register(PKG_Festival_FestivalBase)
o.Register(PKG_Slots_Client_Enter_Success)
o.Register(PKG_Slots_Client_FestivalSpinNormalRet)
o.Register(PKG_Slots_Client_FestivalLionFreeRet)
o.Register(PKG_Slots_Client_FestivalResipnRet)
o.Register(PKG_Client_Slots_FestivalResipnSpin)
o.Register(PKG_Slots_Client_OfflineCheck)
o.Register(PKG_Slots_Client_Leave_Success)
o.Register(PKG_Client_Slots_FestivalNormalSpin)
o.Register(PKG_Slots_Client_SyncPlayerStates)
o.Register(PKG_Slots_Client_CollectValue)
o.Register(PKG_Slots_Client_FestivalEnterResumed)
o.Register(PKG_Client_Slots_FestivalLionFreeSpin)
o.Register(PKG_Slots_Client_LockLeaveSuccess)