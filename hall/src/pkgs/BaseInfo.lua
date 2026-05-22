
-- require('g_net')
CodeGen_BaseInfo_md5 ="#*MD5<5074206af32b7d50c80f4892572bc43d>*#"

--[[
鱼值
]]
PKG_BaseInfo_Fish = {
    typeName = "PKG_BaseInfo_Fish",
    Create = function(o)
        if o == nil then
            o = {}
            setmetatable(o, PKG_BaseInfo_Fish)
        end
        o.fishId = 0 -- Int32
        o.value = 0 -- Int64
        o.fishTypeId = 0 -- Int32
        o.fishMultiple = 0 -- UInt32
        return o
    end,
    Read = function(self, om)
        local d = om.d
        local r, n
        -- fishId
        r, self.fishId = d:Rvi32()
        if r ~= 0 then return r end
        -- value
        r, self.value = d:Rvi64()
        if r ~= 0 then return r end
        -- fishTypeId
        r, self.fishTypeId = d:Rvi32()
        if r ~= 0 then return r end
        -- fishMultiple
        r, self.fishMultiple = d:Rvu32()
        if r ~= 0 then return r end
        return 0
    end,
    Write = function(self, om)
        local d = om.d
        -- fishId
        d:Wvi32(self.fishId)
        -- value
        d:Wvi64(self.value)
        -- fishTypeId
        d:Wvi32(self.fishTypeId)
        -- fishMultiple
        d:Wvu32(self.fishMultiple)
    end
}
PKG_BaseInfo_Fish.__index = PKG_BaseInfo_Fish

--[[
与游戏服通信用的普通金币结构
]]
PKG_BaseInfo_AccountMoney = {
    typeName = "PKG_BaseInfo_AccountMoney",
    Create = function(o)
        if o == nil then
            o = {}
            setmetatable(o, PKG_BaseInfo_AccountMoney)
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
PKG_BaseInfo_AccountMoney.__index = PKG_BaseInfo_AccountMoney

--[[
与游戏服通信用的锁定金币结构
]]
PKG_BaseInfo_AccountMoneyGift = {
    typeName = "PKG_BaseInfo_AccountMoneyGift",
    Create = function(o)
        if o == nil then
            o = {}
            setmetatable(o, PKG_BaseInfo_AccountMoneyGift)
        end
        o.money_gift = 0 -- Int64
        o.money_gift_safe = 0 -- Int64
        o.amount_of_gift = 0 -- Int64
        o.amount_of_washcode = 0 -- Int64
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
        -- amount_of_washcode
        r, self.amount_of_washcode = d:Rvi64()
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
        -- amount_of_washcode
        d:Wvi64(self.amount_of_washcode)
    end
}
PKG_BaseInfo_AccountMoneyGift.__index = PKG_BaseInfo_AccountMoneyGift

--[[
与数据库交互的普通金结构
]]
PKG_BaseInfo_DB_AccountMoney = {
    typeName = "PKG_BaseInfo_DB_AccountMoney",
    Create = function(o)
        if o == nil then
            o = {}
            setmetatable(o, PKG_BaseInfo_DB_AccountMoney)
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
PKG_BaseInfo_DB_AccountMoney.__index = PKG_BaseInfo_DB_AccountMoney

--[[
与数据库交互的绑金结构
]]
PKG_BaseInfo_DB_AccountMoneyGift = {
    typeName = "PKG_BaseInfo_DB_AccountMoneyGift",
    Create = function(o)
        if o == nil then
            o = {}
            setmetatable(o, PKG_BaseInfo_DB_AccountMoneyGift)
        end
        o.money_gift = 0 -- Double
        o.money_gift_safe = 0 -- Double
        o.amount_of_gift = 0 -- Double
        o.amount_of_washcode = 0 -- Int64
        return o
    end,
    Read = function(self, om)
        local d = om.d
        local r, n
        -- money_gift
        r, self.money_gift = d:Rd()
        if r ~= 0 then return r end
        -- money_gift_safe
        r, self.money_gift_safe = d:Rd()
        if r ~= 0 then return r end
        -- amount_of_gift
        r, self.amount_of_gift = d:Rd()
        if r ~= 0 then return r end
        -- amount_of_washcode
        r, self.amount_of_washcode = d:Rvi64()
        if r ~= 0 then return r end
        return 0
    end,
    Write = function(self, om)
        local d = om.d
        -- money_gift
        d:Wd(self.money_gift)
        -- money_gift_safe
        d:Wd(self.money_gift_safe)
        -- amount_of_gift
        d:Wd(self.amount_of_gift)
        -- amount_of_washcode
        d:Wvi64(self.amount_of_washcode)
    end
}
PKG_BaseInfo_DB_AccountMoneyGift.__index = PKG_BaseInfo_DB_AccountMoneyGift

--[[
与数据库交互的洗码派彩结构
]]
PKG_BaseInfo_DB_AccountWashAmount = {
    typeName = "PKG_BaseInfo_DB_AccountWashAmount",
    Create = function(o)
        if o == nil then
            o = {}
            setmetatable(o, PKG_BaseInfo_DB_AccountWashAmount)
        end
        o.wash_amount_lv = 0 -- Int32
        o.wash_amount_value = 0 -- Int64
        o.wash_check = 0 -- Int32
        return o
    end,
    Read = function(self, om)
        local d = om.d
        local r, n
        -- wash_amount_lv
        r, self.wash_amount_lv = d:Rvi32()
        if r ~= 0 then return r end
        -- wash_amount_value
        r, self.wash_amount_value = d:Rvi64()
        if r ~= 0 then return r end
        -- wash_check
        r, self.wash_check = d:Rvi32()
        if r ~= 0 then return r end
        return 0
    end,
    Write = function(self, om)
        local d = om.d
        -- wash_amount_lv
        d:Wvi32(self.wash_amount_lv)
        -- wash_amount_value
        d:Wvi64(self.wash_amount_value)
        -- wash_check
        d:Wvi32(self.wash_check)
    end
}
PKG_BaseInfo_DB_AccountWashAmount.__index = PKG_BaseInfo_DB_AccountWashAmount

--[[
与游戏服通信用的洗码结构
]]
PKG_BaseInfo_AccountWashAmount = {
    typeName = "PKG_BaseInfo_AccountWashAmount",
    Create = function(o)
        if o == nil then
            o = {}
            setmetatable(o, PKG_BaseInfo_AccountWashAmount)
        end
        o.wash_amount_lv = 0 -- Int32
        o.wash_amount_value = 0 -- Int64
        o.wash_check = 0 -- Int64
        return o
    end,
    Read = function(self, om)
        local d = om.d
        local r, n
        -- wash_amount_lv
        r, self.wash_amount_lv = d:Rvi32()
        if r ~= 0 then return r end
        -- wash_amount_value
        r, self.wash_amount_value = d:Rvi64()
        if r ~= 0 then return r end
        -- wash_check
        r, self.wash_check = d:Rvi64()
        if r ~= 0 then return r end
        return 0
    end,
    Write = function(self, om)
        local d = om.d
        -- wash_amount_lv
        d:Wvi32(self.wash_amount_lv)
        -- wash_amount_value
        d:Wvi64(self.wash_amount_value)
        -- wash_check
        d:Wvi64(self.wash_check)
    end
}
PKG_BaseInfo_AccountWashAmount.__index = PKG_BaseInfo_AccountWashAmount

--[[
打中鱼结果
]]
PKG_BaseInfo_HitInfoRet = {
    typeName = "PKG_BaseInfo_HitInfoRet",
    Create = function(o)
        if o == nil then
            o = {}
            setmetatable(o, PKG_BaseInfo_HitInfoRet)
        end
        o.code = 0 -- Int32
        o.tableId = 0 -- Int32
        o.accountId = 0 -- Int32
        o.bulletId = 0 -- Int32
        o.bulletValue = 0 -- Int64
        o.missBulletCount = 0 -- Int32
        o.deathFish = {} -- List<PKG.BaseInfo.Fish>
        o.moneyBase = PKG_BaseInfo_AccountMoney.Create() -- PKG.BaseInfo.AccountMoney
        o.giftInfo = PKG_BaseInfo_AccountMoneyGift.Create() -- PKG.BaseInfo.AccountMoneyGift
        o.lotteryId = 0 -- Int32
        o.type = 0 -- Int32
        o.levelUps = {} -- List<Int64>
        return o
    end,
    Read = function(self, om)
        local d = om.d
        local r, n, o
        -- code
        r, self.code = d:Rvi32()
        if r ~= 0 then return r end
        -- tableId
        r, self.tableId = d:Rvi32()
        if r ~= 0 then return r end
        -- accountId
        r, self.accountId = d:Rvi32()
        if r ~= 0 then return r end
        -- bulletId
        r, self.bulletId = d:Rvi32()
        if r ~= 0 then return r end
        -- bulletValue
        r, self.bulletValue = d:Rvi64()
        if r ~= 0 then return r end
        -- missBulletCount
        r, self.missBulletCount = d:Rvi32()
        if r ~= 0 then return r end
        -- deathFish
        r, len = d:Rvu32()
        if len > d:GetLeft() then return -1 end
        o = {}
        self.deathFish = o
        for i = 1, len do
            o[i] = PKG_BaseInfo_Fish.Create(); r = o[i]:Read(om)
            if r ~= 0 then return r end
        end
        if r ~= 0 then return r end
        -- moneyBase
        self.moneyBase = PKG_BaseInfo_AccountMoney.Create(); r = self.moneyBase:Read(om)
        if r ~= 0 then return r end
        -- giftInfo
        self.giftInfo = PKG_BaseInfo_AccountMoneyGift.Create(); r = self.giftInfo:Read(om)
        if r ~= 0 then return r end
        -- lotteryId
        r, self.lotteryId = d:Rvi32()
        if r ~= 0 then return r end
        -- type
        r, self.type = d:Rvi32()
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
        return 0
    end,
    Write = function(self, om)
        local d = om.d
        local o, len
        -- code
        d:Wvi32(self.code)
        -- tableId
        d:Wvi32(self.tableId)
        -- accountId
        d:Wvi32(self.accountId)
        -- bulletId
        d:Wvi32(self.bulletId)
        -- bulletValue
        d:Wvi64(self.bulletValue)
        -- missBulletCount
        d:Wvi32(self.missBulletCount)
        -- deathFish
        o = self.deathFish
        len = #o
        d:Wvu32(len)
        for i = 1, len do
            o[i]:Write(om)
        end
        -- moneyBase
        self.moneyBase:Write(om)
        -- giftInfo
        self.giftInfo:Write(om)
        -- lotteryId
        d:Wvi32(self.lotteryId)
        -- type
        d:Wvi32(self.type)
        -- levelUps
        o = self.levelUps
        len = #o
        d:Wvu32(len)
        for i = 1, len do
            d:Wvi64(o[i])
        end
    end
}
PKG_BaseInfo_HitInfoRet.__index = PKG_BaseInfo_HitInfoRet

--[[
打中鱼信息
]]
PKG_BaseInfo_HitInfo = {
    typeName = "PKG_BaseInfo_HitInfo",
    Create = function(o)
        if o == nil then
            o = {}
            setmetatable(o, PKG_BaseInfo_HitInfo)
        end
        o.tableId = 0 -- Int32
        o.accountId = 0 -- Int32
        o.bulletId = 0 -- Int32
        o.bulletCount = 0 -- Int32
        o.bulletValue = 0 -- Int64
        o.fish = {} -- List<PKG.BaseInfo.Fish>
        o.moneyType = 0 -- UInt32
        o.lotteryId = 0 -- Int32
        o.levelId = 0 -- Int32
        o.gameId = 0 -- Int32
        o.type = 0 -- Int32
        return o
    end,
    Read = function(self, om)
        local d = om.d
        local r, n, o
        -- tableId
        r, self.tableId = d:Rvi32()
        if r ~= 0 then return r end
        -- accountId
        r, self.accountId = d:Rvi32()
        if r ~= 0 then return r end
        -- bulletId
        r, self.bulletId = d:Rvi32()
        if r ~= 0 then return r end
        -- bulletCount
        r, self.bulletCount = d:Rvi32()
        if r ~= 0 then return r end
        -- bulletValue
        r, self.bulletValue = d:Rvi64()
        if r ~= 0 then return r end
        -- fish
        r, len = d:Rvu32()
        if len > d:GetLeft() then return -1 end
        o = {}
        self.fish = o
        for i = 1, len do
            o[i] = PKG_BaseInfo_Fish.Create(); r = o[i]:Read(om)
            if r ~= 0 then return r end
        end
        if r ~= 0 then return r end
        -- moneyType
        r, self.moneyType = d:Rvu32()
        if r ~= 0 then return r end
        -- lotteryId
        r, self.lotteryId = d:Rvi32()
        if r ~= 0 then return r end
        -- levelId
        r, self.levelId = d:Rvi32()
        if r ~= 0 then return r end
        -- gameId
        r, self.gameId = d:Rvi32()
        if r ~= 0 then return r end
        -- type
        r, self.type = d:Rvi32()
        if r ~= 0 then return r end
        return 0
    end,
    Write = function(self, om)
        local d = om.d
        local o, len
        -- tableId
        d:Wvi32(self.tableId)
        -- accountId
        d:Wvi32(self.accountId)
        -- bulletId
        d:Wvi32(self.bulletId)
        -- bulletCount
        d:Wvi32(self.bulletCount)
        -- bulletValue
        d:Wvi64(self.bulletValue)
        -- fish
        o = self.fish
        len = #o
        d:Wvu32(len)
        for i = 1, len do
            o[i]:Write(om)
        end
        -- moneyType
        d:Wvu32(self.moneyType)
        -- lotteryId
        d:Wvi32(self.lotteryId)
        -- levelId
        d:Wvi32(self.levelId)
        -- gameId
        d:Wvi32(self.gameId)
        -- type
        d:Wvi32(self.type)
    end
}
PKG_BaseInfo_HitInfo.__index = PKG_BaseInfo_HitInfo

PKG_BaseInfo_HitInfoGroup = {
    typeName = "PKG_BaseInfo_HitInfoGroup",
    Create = function(o)
        if o == nil then
            o = {}
            setmetatable(o, PKG_BaseInfo_HitInfoGroup)
        end
        o.SerialId = 0 -- Int32
        o.infos = {} -- List<PKG.BaseInfo.HitInfo>
        return o
    end,
    Read = function(self, om)
        local d = om.d
        local r, n, o
        -- SerialId
        r, self.SerialId = d:Rvi32()
        if r ~= 0 then return r end
        -- infos
        r, len = d:Rvu32()
        if len > d:GetLeft() then return -1 end
        o = {}
        self.infos = o
        for i = 1, len do
            o[i] = PKG_BaseInfo_HitInfo.Create(); r = o[i]:Read(om)
            if r ~= 0 then return r end
        end
        if r ~= 0 then return r end
        return 0
    end,
    Write = function(self, om)
        local d = om.d
        local o, len
        -- SerialId
        d:Wvi32(self.SerialId)
        -- infos
        o = self.infos
        len = #o
        d:Wvu32(len)
        for i = 1, len do
            o[i]:Write(om)
        end
    end
}
PKG_BaseInfo_HitInfoGroup.__index = PKG_BaseInfo_HitInfoGroup

--[[
请求玩家数据更新
]]
PKG_BaseInfo_UpdateOne = {
    typeName = "PKG_BaseInfo_UpdateOne",
    Create = function(o)
        if o == nil then
            o = {}
            setmetatable(o, PKG_BaseInfo_UpdateOne)
        end
        o.account_id = 0 -- Int32
        o.db_moneyBase = PKG_BaseInfo_DB_AccountMoney.Create() -- PKG.BaseInfo.DB_AccountMoney
        o.db_giftInfo = PKG_BaseInfo_DB_AccountMoneyGift.Create() -- PKG.BaseInfo.DB_AccountMoneyGift
        o.db_washInfo = PKG_BaseInfo_DB_AccountWashAmount.Create() -- PKG.BaseInfo.DB_AccountWashAmount
        o.cb_key = "" -- String
        o.logId = 0 -- Int32
        return o
    end,
    Read = function(self, om)
        local d = om.d
        local r, n
        -- account_id
        r, self.account_id = d:Rvi32()
        if r ~= 0 then return r end
        -- db_moneyBase
        self.db_moneyBase = PKG_BaseInfo_DB_AccountMoney.Create(); r = self.db_moneyBase:Read(om)
        if r ~= 0 then return r end
        -- db_giftInfo
        self.db_giftInfo = PKG_BaseInfo_DB_AccountMoneyGift.Create(); r = self.db_giftInfo:Read(om)
        if r ~= 0 then return r end
        -- db_washInfo
        self.db_washInfo = PKG_BaseInfo_DB_AccountWashAmount.Create(); r = self.db_washInfo:Read(om)
        if r ~= 0 then return r end
        -- cb_key
        r, self.cb_key = d:Rstr()
        if r ~= 0 then return r end
        -- logId
        r, self.logId = d:Rvi32()
        if r ~= 0 then return r end
        return 0
    end,
    Write = function(self, om)
        local d = om.d
        -- account_id
        d:Wvi32(self.account_id)
        -- db_moneyBase
        self.db_moneyBase:Write(om)
        -- db_giftInfo
        self.db_giftInfo:Write(om)
        -- db_washInfo
        self.db_washInfo:Write(om)
        -- cb_key
        d:Wstr(self.cb_key)
        -- logId
        d:Wvi32(self.logId)
    end
}
PKG_BaseInfo_UpdateOne.__index = PKG_BaseInfo_UpdateOne

--[[
单个彩金信息
]]
PKG_BaseInfo_LotteryInfo = {
    typeName = "PKG_BaseInfo_LotteryInfo",
    Create = function(o)
        if o == nil then
            o = {}
            setmetatable(o, PKG_BaseInfo_LotteryInfo)
        end
        --[[
        彩金ID
        ]]
        o.lotteryID = 0 -- Int32
        --[[
        大厅展示 0不展示  1,是基本展示,101-福树 102-冒火 103-闪电
        ]]
        o.hallShow = 0 -- Int32
        --[[
        彩金类型 0为常规 其他为有奖 1普通奖励 2小奖分值 3中奖分值 4大奖分值 5巨奖分值
        ]]
        o.lType = 0 -- Int32
        --[[
        彩金的属性:0倍数还是 1钱
        ]]
        o.betOrMoney = 0 -- Int32
        --[[
        当前的彩金值/彩金倍数
        ]]
        o.lReal = 0 -- Int64
        --[[
        彩金属性为倍数时,彩金最小倍数
        ]]
        o.lMinBet = 0 -- Int64
        --[[
        彩金属性为倍数时,彩金最大倍数
        ]]
        o.lMaxBet = 0 -- Int64
        --[[
        该彩金最小的押注,超过该值才能影响彩金的变动
        ]]
        o.coinMin = 0 -- Int64
        --[[
        该彩金的增量 ,用于客服端模拟自增
        ]]
        o.setp = 0 -- Int64
        --[[
        该彩金关联的游戏
        ]]
        o.gameIDs = {} -- List<Int32>
        return o
    end,
    Read = function(self, om)
        local d = om.d
        local r, n, o
        -- lotteryID
        r, self.lotteryID = d:Rvi32()
        if r ~= 0 then return r end
        -- hallShow
        r, self.hallShow = d:Rvi32()
        if r ~= 0 then return r end
        -- lType
        r, self.lType = d:Rvi32()
        if r ~= 0 then return r end
        -- betOrMoney
        r, self.betOrMoney = d:Rvi32()
        if r ~= 0 then return r end
        -- lReal
        r, self.lReal = d:Rvi64()
        if r ~= 0 then return r end
        -- lMinBet
        r, self.lMinBet = d:Rvi64()
        if r ~= 0 then return r end
        -- lMaxBet
        r, self.lMaxBet = d:Rvi64()
        if r ~= 0 then return r end
        -- coinMin
        r, self.coinMin = d:Rvi64()
        if r ~= 0 then return r end
        -- setp
        r, self.setp = d:Rvi64()
        if r ~= 0 then return r end
        -- gameIDs
        r, len = d:Rvu32()
        if len > d:GetLeft() then return -1 end
        o = {}
        self.gameIDs = o
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
        -- lotteryID
        d:Wvi32(self.lotteryID)
        -- hallShow
        d:Wvi32(self.hallShow)
        -- lType
        d:Wvi32(self.lType)
        -- betOrMoney
        d:Wvi32(self.betOrMoney)
        -- lReal
        d:Wvi64(self.lReal)
        -- lMinBet
        d:Wvi64(self.lMinBet)
        -- lMaxBet
        d:Wvi64(self.lMaxBet)
        -- coinMin
        d:Wvi64(self.coinMin)
        -- setp
        d:Wvi64(self.setp)
        -- gameIDs
        o = self.gameIDs
        len = #o
        d:Wvu32(len)
        for i = 1, len do
            d:Wvi32(o[i])
        end
    end
}
PKG_BaseInfo_LotteryInfo.__index = PKG_BaseInfo_LotteryInfo

PKG_BaseInfo_HitInfoRetGroup = {
    typeName = "PKG_BaseInfo_HitInfoRetGroup",
    Create = function(o)
        if o == nil then
            o = {}
            setmetatable(o, PKG_BaseInfo_HitInfoRetGroup)
        end
        o.SerialId = 0 -- Int32
        o.infos = {} -- List<PKG.BaseInfo.HitInfoRet>
        return o
    end,
    Read = function(self, om)
        local d = om.d
        local r, n, o
        -- SerialId
        r, self.SerialId = d:Rvi32()
        if r ~= 0 then return r end
        -- infos
        r, len = d:Rvu32()
        if len > d:GetLeft() then return -1 end
        o = {}
        self.infos = o
        for i = 1, len do
            o[i] = PKG_BaseInfo_HitInfoRet.Create(); r = o[i]:Read(om)
            if r ~= 0 then return r end
        end
        if r ~= 0 then return r end
        return 0
    end,
    Write = function(self, om)
        local d = om.d
        local o, len
        -- SerialId
        d:Wvi32(self.SerialId)
        -- infos
        o = self.infos
        len = #o
        d:Wvu32(len)
        for i = 1, len do
            o[i]:Write(om)
        end
    end
}
PKG_BaseInfo_HitInfoRetGroup.__index = PKG_BaseInfo_HitInfoRetGroup

--[[
计算服和db服使用的金币信息
]]
PKG_BaseInfo_DB_AccountMoneyAll = {
    typeName = "PKG_BaseInfo_DB_AccountMoneyAll",
    Create = function(o)
        if o == nil then
            o = {}
            setmetatable(o, PKG_BaseInfo_DB_AccountMoneyAll)
        end
        o.account_id = 0 -- Int32
        o.db_moneyBase = PKG_BaseInfo_DB_AccountMoney.Create() -- PKG.BaseInfo.DB_AccountMoney
        o.db_giftInfo = PKG_BaseInfo_DB_AccountMoneyGift.Create() -- PKG.BaseInfo.DB_AccountMoneyGift
        o.db_washInfo = PKG_BaseInfo_DB_AccountWashAmount.Create() -- PKG.BaseInfo.DB_AccountWashAmount
        o.cb_key = "" -- String
        o.logId = 0 -- Int32
        return o
    end,
    Read = function(self, om)
        local d = om.d
        local r, n
        -- account_id
        r, self.account_id = d:Rvi32()
        if r ~= 0 then return r end
        -- db_moneyBase
        self.db_moneyBase = PKG_BaseInfo_DB_AccountMoney.Create(); r = self.db_moneyBase:Read(om)
        if r ~= 0 then return r end
        -- db_giftInfo
        self.db_giftInfo = PKG_BaseInfo_DB_AccountMoneyGift.Create(); r = self.db_giftInfo:Read(om)
        if r ~= 0 then return r end
        -- db_washInfo
        self.db_washInfo = PKG_BaseInfo_DB_AccountWashAmount.Create(); r = self.db_washInfo:Read(om)
        if r ~= 0 then return r end
        -- cb_key
        r, self.cb_key = d:Rstr()
        if r ~= 0 then return r end
        -- logId
        r, self.logId = d:Rvi32()
        if r ~= 0 then return r end
        return 0
    end,
    Write = function(self, om)
        local d = om.d
        -- account_id
        d:Wvi32(self.account_id)
        -- db_moneyBase
        self.db_moneyBase:Write(om)
        -- db_giftInfo
        self.db_giftInfo:Write(om)
        -- db_washInfo
        self.db_washInfo:Write(om)
        -- cb_key
        d:Wstr(self.cb_key)
        -- logId
        d:Wvi32(self.logId)
    end
}
PKG_BaseInfo_DB_AccountMoneyAll.__index = PKG_BaseInfo_DB_AccountMoneyAll

--[[
整型金币信息
]]
PKG_BaseInfo_AccountMoneyAll = {
    typeName = "PKG_BaseInfo_AccountMoneyAll",
    Create = function(o)
        if o == nil then
            o = {}
            setmetatable(o, PKG_BaseInfo_AccountMoneyAll)
        end
        o.account_id = 0 -- Int32
        o.moneyBase = PKG_BaseInfo_AccountMoney.Create() -- PKG.BaseInfo.AccountMoney
        o.giftInfo = PKG_BaseInfo_AccountMoneyGift.Create() -- PKG.BaseInfo.AccountMoneyGift
        o.washInfo = PKG_BaseInfo_AccountWashAmount.Create() -- PKG.BaseInfo.AccountWashAmount
        o.cb_key = "" -- String
        o.logId = 0 -- Int32
        return o
    end,
    Read = function(self, om)
        local d = om.d
        local r, n
        -- account_id
        r, self.account_id = d:Rvi32()
        if r ~= 0 then return r end
        -- moneyBase
        self.moneyBase = PKG_BaseInfo_AccountMoney.Create(); r = self.moneyBase:Read(om)
        if r ~= 0 then return r end
        -- giftInfo
        self.giftInfo = PKG_BaseInfo_AccountMoneyGift.Create(); r = self.giftInfo:Read(om)
        if r ~= 0 then return r end
        -- washInfo
        self.washInfo = PKG_BaseInfo_AccountWashAmount.Create(); r = self.washInfo:Read(om)
        if r ~= 0 then return r end
        -- cb_key
        r, self.cb_key = d:Rstr()
        if r ~= 0 then return r end
        -- logId
        r, self.logId = d:Rvi32()
        if r ~= 0 then return r end
        return 0
    end,
    Write = function(self, om)
        local d = om.d
        -- account_id
        d:Wvi32(self.account_id)
        -- moneyBase
        self.moneyBase:Write(om)
        -- giftInfo
        self.giftInfo:Write(om)
        -- washInfo
        self.washInfo:Write(om)
        -- cb_key
        d:Wstr(self.cb_key)
        -- logId
        d:Wvi32(self.logId)
    end
}
PKG_BaseInfo_AccountMoneyAll.__index = PKG_BaseInfo_AccountMoneyAll

--[[
玩家一次游戏操作引起的金币变化
]]
PKG_BaseInfo_OnceChange = {
    typeName = "PKG_BaseInfo_OnceChange",
    Create = function(o)
        if o == nil then
            o = {}
            setmetatable(o, PKG_BaseInfo_OnceChange)
        end
        --[[
        账号id
        ]]
        o.accountId = 0 -- Int32
        --[[
        一次游戏操作的金币变化
        ]]
        o.onceChange = 0 -- Int64
        return o
    end,
    Read = function(self, om)
        local d = om.d
        local r, n
        -- accountId
        r, self.accountId = d:Rvi32()
        if r ~= 0 then return r end
        -- onceChange
        r, self.onceChange = d:Rvi64()
        if r ~= 0 then return r end
        return 0
    end,
    Write = function(self, om)
        local d = om.d
        -- accountId
        d:Wvi32(self.accountId)
        -- onceChange
        d:Wvi64(self.onceChange)
    end
}
PKG_BaseInfo_OnceChange.__index = PKG_BaseInfo_OnceChange

--[[
基本的统计数据
]]
PKG_BaseInfo_DataStatistics = {
    typeName = "PKG_BaseInfo_DataStatistics",
    Create = function(o)
        if o == nil then
            o = {}
            setmetatable(o, PKG_BaseInfo_DataStatistics)
        end
        o.accountId = 0 -- Int32
        o.gameType = 0 -- Int32
        o.gameId = 0 -- Int32
        o.levelId = 0 -- Int32
        o.tableId = 0 -- Int32
        o.moneyType = 0 -- Int32
        o.betOrMoney = 0 -- UInt64
        o.winMoney = 0 -- UInt64
        o.vipLv = 0 -- UInt32
        o.deathFish = {} -- List<PKG.BaseInfo.Fish>
        o.lotteryType = 0 -- Int32
        o.lotteryId = 0 -- Int32
        o.spinType = 0 -- UInt32
        return o
    end,
    Read = function(self, om)
        local d = om.d
        local r, n, o
        -- accountId
        r, self.accountId = d:Rvi32()
        if r ~= 0 then return r end
        -- gameType
        r, self.gameType = d:Rvi32()
        if r ~= 0 then return r end
        -- gameId
        r, self.gameId = d:Rvi32()
        if r ~= 0 then return r end
        -- levelId
        r, self.levelId = d:Rvi32()
        if r ~= 0 then return r end
        -- tableId
        r, self.tableId = d:Rvi32()
        if r ~= 0 then return r end
        -- moneyType
        r, self.moneyType = d:Rvi32()
        if r ~= 0 then return r end
        -- betOrMoney
        r, self.betOrMoney = d:Rvu64()
        if r ~= 0 then return r end
        -- winMoney
        r, self.winMoney = d:Rvu64()
        if r ~= 0 then return r end
        -- vipLv
        r, self.vipLv = d:Rvu32()
        if r ~= 0 then return r end
        -- deathFish
        r, len = d:Rvu32()
        if len > d:GetLeft() then return -1 end
        o = {}
        self.deathFish = o
        for i = 1, len do
            o[i] = PKG_BaseInfo_Fish.Create(); r = o[i]:Read(om)
            if r ~= 0 then return r end
        end
        if r ~= 0 then return r end
        -- lotteryType
        r, self.lotteryType = d:Rvi32()
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
        local o, len
        -- accountId
        d:Wvi32(self.accountId)
        -- gameType
        d:Wvi32(self.gameType)
        -- gameId
        d:Wvi32(self.gameId)
        -- levelId
        d:Wvi32(self.levelId)
        -- tableId
        d:Wvi32(self.tableId)
        -- moneyType
        d:Wvi32(self.moneyType)
        -- betOrMoney
        d:Wvu64(self.betOrMoney)
        -- winMoney
        d:Wvu64(self.winMoney)
        -- vipLv
        d:Wvu32(self.vipLv)
        -- deathFish
        o = self.deathFish
        len = #o
        d:Wvu32(len)
        for i = 1, len do
            o[i]:Write(om)
        end
        -- lotteryType
        d:Wvi32(self.lotteryType)
        -- lotteryId
        d:Wvi32(self.lotteryId)
        -- spinType
        d:Wvu32(self.spinType)
    end
}
PKG_BaseInfo_DataStatistics.__index = PKG_BaseInfo_DataStatistics

local o = ObjMgr