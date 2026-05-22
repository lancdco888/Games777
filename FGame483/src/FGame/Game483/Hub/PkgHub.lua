local PkgHub = class("PkgHub", FBasePkgHub)

function PkgHub:ctor(...)
    PkgHub.super.ctor(self, ...)
    self.protoMap = {
        ['PKG_Slots_Client_SyncPlayerStates'] = 'PB.Slots_Client.SyncPlayerStates',
        ['PKG_Slots_Client_Leave_Success'] = 'PB.Slots_Client.Leave_Success',
        ['PKG_Client_Slots_Sync'] = 'PB.Client_Slots.table',
        ['PKG_Slots_Client_CollectValue'] = 'PB.Slots_Client.CollectValue',
        ['PKG_Client_Slots_Leave'] = 'PB.Client_Slots.Leave',
        ['PKG_Slots_Client_MahjongWaysNormalRet'] = 'PB.Slots_Client.MahjongWaysNormalRet',
        ['PKG_Client_Slots_PlayerSit'] = 'PB.Client_Slots.PlayerSit',
        ['PKG_Slots_Client_MahjongWaysEnterResumed'] = 'PB.Slots_Client.MahjongWaysEnterResumed',
        ['PKG_Client_Slots_MahjongWaysFreeSpin'] = 'PB.Client_Slots.MahjongWaysFreeSpin',
        ['PKG_Slots_Client_Enter_Success'] = 'PB.Slots_Client.Enter_Success',
        ['PKG_Client_Slots_CionInfo'] = 'PB.Client_Slots.CionInfo',
        ['PKG_Slots_Client_MahjongWaysFreeRet'] = 'PB.Slots_Client.MahjongWaysFreeRet',
        ['PKG_Client_Slots_Enter'] = 'PB.Client_Slots.Enter',
        ['PKG_Slots_Client_OfflineCheck'] = 'PB.Slots_Client.OfflineCheck',
        ['PKG_Client_Slots_LockLeave'] = 'PB.Client_Slots.LockLeave',
        ['PKG_Client_Slots_MahjongWaysNormalSpin'] = 'PB.Client_Slots.MahjongWaysNormalSpin',
        ['PKG_Slots_Client_LockLeaveSuccess'] = 'PB.Slots_Client.LockLeaveSuccess',
    }
end
function PkgHub:Pkg2Pb(pkg)
    local pb = {}
    pb._msgName_ = self.protoMap[pkg.typeName]
    if pkg.typeName == 'PKG_Slots_Client_Leave_Success' then
        return pb
    elseif pkg.typeName == 'PKG_Slots_Client_CollectValue' then
        pb.nowValue = pkg.nowValue
        return pb
    elseif pkg.typeName == 'PKG_Slots_Client_MahjongWaysNormalRet' then
        pb.normalSpin = {}
        pb.normalSpin.bet = pkg.normalSpin.bet
        pb.normalSpin.winCoin = pkg.normalSpin.winCoin
        pb.normalSpin.results = {}
        pb.normalSpin.results.array = {}
        
        for ik, iv in pairs(pkg.normalSpin.results.array) do
            pb.normalSpin.results.array[ik] = {}
            pb.normalSpin.results.array[ik].grids = {}
            
            for jk, jv in pairs(iv.grids) do
                pb.normalSpin.results.array[ik].grids[jk] = {}
                pb.normalSpin.results.array[ik].grids[jk].index = jv.index
                pb.normalSpin.results.array[ik].grids[jk].icon = jv.icon
                pb.normalSpin.results.array[ik].grids[jk].golden = jv.golden
            end
            
            pb.normalSpin.results.array[ik].lines = {}
            
            for jk, jv in pairs(iv.lines) do
                pb.normalSpin.results.array[ik].lines[jk] = {}
                pb.normalSpin.results.array[ik].lines[jk].lineIndex = jv.lineIndex
                pb.normalSpin.results.array[ik].lines[jk].winCoin = jv.winCoin
                pb.normalSpin.results.array[ik].lines[jk].icon = jv.icon
                pb.normalSpin.results.array[ik].lines[jk].lineCells = {}
                
                for kk, kv in pairs(jv.lineCells) do
                    pb.normalSpin.results.array[ik].lines[jk].lineCells[kk] = {}
                    pb.normalSpin.results.array[ik].lines[jk].lineCells[kk].index = kv.index
                    pb.normalSpin.results.array[ik].lines[jk].lineCells[kk].icon = kv.icon
                    pb.normalSpin.results.array[ik].lines[jk].lineCells[kk].golden = kv.golden
                end
            end
            
            pb.normalSpin.results.array[ik].doubled = iv.doubled
            pb.normalSpin.results.array[ik].lastDoubled = iv.lastDoubled
            pb.normalSpin.results.array[ik].freeTime = iv.freeTime
            pb.normalSpin.results.array[ik].totalFreeTime = iv.totalFreeTime
        end
        
        pb.normalSpin.intoFree = pkg.normalSpin.intoFree
        pb.normalSpin.slotMoneyGift = {}
        pb.normalSpin.slotMoneyGift.money_gift = pkg.normalSpin.slotMoneyGift.money_gift
        pb.normalSpin.slotMoneyGift.money_gift_safe = pkg.normalSpin.slotMoneyGift.money_gift_safe
        pb.normalSpin.slotMoneyGift.amount_of_gift = pkg.normalSpin.slotMoneyGift.amount_of_gift
        pb.normalSpin.slotMoney = {}
        pb.normalSpin.slotMoney.money = pkg.normalSpin.slotMoney.money
        pb.normalSpin.slotMoney.money_safe = pkg.normalSpin.slotMoney.money_safe
        pb.normalSpin.levelUpMoney = pkg.normalSpin.levelUpMoney
        pb.normalSpin.levelUpMoneys = pkg.normalSpin.levelUpMoneys
        return pb
    elseif pkg.typeName == 'PKG_Slots_Client_MahjongWaysEnterResumed' then
        pb.lvID = pkg.lvID
        pb.currentWinCoin = pkg.currentWinCoin
        pb.currentBetMoney = pkg.currentBetMoney
        pb.enterBase = {}
        pb.enterBase.enterSlotMoney = {}
        pb.enterBase.enterSlotMoney.money = pkg.enterBase.enterSlotMoney.money
        pb.enterBase.enterSlotMoney.money_safe = pkg.enterBase.enterSlotMoney.money_safe
        pb.enterBase.userName = pkg.enterBase.userName
        pb.enterBase.avatarId = pkg.enterBase.avatarId
        pb.enterBase.enterMoneySalfe = pkg.enterBase.enterMoneySalfe
        pb.enterBase.enterMoneyGiftSafe = pkg.enterBase.enterMoneyGiftSafe
        pb.enterBase.entryConditions = {}
        
        for ik, iv in pairs(pkg.enterBase.entryConditions) do
            pb.enterBase.entryConditions[ik] = {}
            pb.enterBase.entryConditions[ik].id = iv.id
            pb.enterBase.entryConditions[ik].spinMinMoney = iv.spinMinMoney
            pb.enterBase.entryConditions[ik].spinMaxMoney = iv.spinMaxMoney
            pb.enterBase.entryConditions[ik].enterMinMoney = iv.enterMinMoney
            pb.enterBase.entryConditions[ik].desc = iv.desc
            pb.enterBase.entryConditions[ik].c_value = iv.c_value
            pb.enterBase.entryConditions[ik].c_lottery_value = iv.c_lottery_value
        end
        
        pb.enterBase.chairSize = pkg.enterBase.chairSize
        pb.enterBase.chairId = pkg.enterBase.chairId
        pb.enterBase.enterSlotMoneyGift = {}
        pb.enterBase.enterSlotMoneyGift.money_gift = pkg.enterBase.enterSlotMoneyGift.money_gift
        pb.enterBase.enterSlotMoneyGift.money_gift_safe = pkg.enterBase.enterSlotMoneyGift.money_gift_safe
        pb.enterBase.enterSlotMoneyGift.amount_of_gift = pkg.enterBase.enterSlotMoneyGift.amount_of_gift
        pb.enterBase.accountId = pkg.enterBase.accountId
        pb.enterBase.moneyType = pkg.enterBase.moneyType
        pb.enterBase.nickName = pkg.enterBase.nickName
        pb.enterBase.enterMoney = pkg.enterBase.enterMoney
        pb.enterBase.enterMoneyGift = pkg.enterBase.enterMoneyGift
        pb.enterBase.betRatios = {}
        
        for ik, iv in pairs(pkg.enterBase.betRatios) do
            pb.enterBase.betRatios[ik] = {}
            pb.enterBase.betRatios[ik].betMoney = iv.betMoney
            pb.enterBase.betRatios[ik].betLine = iv.betLine
            pb.enterBase.betRatios[ik].lvID = iv.lvID
        end
        
        pb.enterBase.tableSize = pkg.enterBase.tableSize
        pb.enterBase.tableId = pkg.enterBase.tableId
        pb.enterBase.players = {}
        
        for ik, iv in pairs(pkg.enterBase.players) do
            pb.enterBase.players[ik] = {}
            pb.enterBase.players[ik].accountId = iv.accountId
            pb.enterBase.players[ik].userName = iv.userName
            pb.enterBase.players[ik].nickName = iv.nickName
            pb.enterBase.players[ik].avatarId = iv.avatarId
            pb.enterBase.players[ik].tableId = iv.tableId
            pb.enterBase.players[ik].chairId = iv.chairId
        end
        
        pb.resumedNormal = {}
        pb.resumedNormal.normalSpin = {}
        pb.resumedNormal.normalSpin.bet = pkg.resumedNormal.normalSpin.bet
        pb.resumedNormal.normalSpin.winCoin = pkg.resumedNormal.normalSpin.winCoin
        pb.resumedNormal.normalSpin.results = {}
        pb.resumedNormal.normalSpin.results.array = {}
        
        for ik, iv in pairs(pkg.resumedNormal.normalSpin.results.array) do
            pb.resumedNormal.normalSpin.results.array[ik] = {}
            pb.resumedNormal.normalSpin.results.array[ik].grids = {}
            
            for jk, jv in pairs(iv.grids) do
                pb.resumedNormal.normalSpin.results.array[ik].grids[jk] = {}
                pb.resumedNormal.normalSpin.results.array[ik].grids[jk].index = jv.index
                pb.resumedNormal.normalSpin.results.array[ik].grids[jk].icon = jv.icon
                pb.resumedNormal.normalSpin.results.array[ik].grids[jk].golden = jv.golden
            end
            
            pb.resumedNormal.normalSpin.results.array[ik].lines = {}
            
            for jk, jv in pairs(iv.lines) do
                pb.resumedNormal.normalSpin.results.array[ik].lines[jk] = {}
                pb.resumedNormal.normalSpin.results.array[ik].lines[jk].lineIndex = jv.lineIndex
                pb.resumedNormal.normalSpin.results.array[ik].lines[jk].winCoin = jv.winCoin
                pb.resumedNormal.normalSpin.results.array[ik].lines[jk].icon = jv.icon
                pb.resumedNormal.normalSpin.results.array[ik].lines[jk].lineCells = {}
                
                for kk, kv in pairs(jv.lineCells) do
                    pb.resumedNormal.normalSpin.results.array[ik].lines[jk].lineCells[kk] = {}
                    pb.resumedNormal.normalSpin.results.array[ik].lines[jk].lineCells[kk].index = kv.index
                    pb.resumedNormal.normalSpin.results.array[ik].lines[jk].lineCells[kk].icon = kv.icon
                    pb.resumedNormal.normalSpin.results.array[ik].lines[jk].lineCells[kk].golden = kv.golden
                end
            end
            
            pb.resumedNormal.normalSpin.results.array[ik].doubled = iv.doubled
            pb.resumedNormal.normalSpin.results.array[ik].lastDoubled = iv.lastDoubled
            pb.resumedNormal.normalSpin.results.array[ik].freeTime = iv.freeTime
            pb.resumedNormal.normalSpin.results.array[ik].totalFreeTime = iv.totalFreeTime
        end
        
        pb.resumedNormal.normalSpin.intoFree = pkg.resumedNormal.normalSpin.intoFree
        pb.resumedNormal.normalSpin.slotMoneyGift = {}
        pb.resumedNormal.normalSpin.slotMoneyGift.money_gift = pkg.resumedNormal.normalSpin.slotMoneyGift.money_gift
        pb.resumedNormal.normalSpin.slotMoneyGift.money_gift_safe = pkg.resumedNormal.normalSpin.slotMoneyGift.money_gift_safe
        pb.resumedNormal.normalSpin.slotMoneyGift.amount_of_gift = pkg.resumedNormal.normalSpin.slotMoneyGift.amount_of_gift
        pb.resumedNormal.normalSpin.slotMoney = {}
        pb.resumedNormal.normalSpin.slotMoney.money = pkg.resumedNormal.normalSpin.slotMoney.money
        pb.resumedNormal.normalSpin.slotMoney.money_safe = pkg.resumedNormal.normalSpin.slotMoney.money_safe
        pb.resumedNormal.normalSpin.levelUpMoney = pkg.resumedNormal.normalSpin.levelUpMoney
        pb.resumedNormal.normalSpin.levelUpMoneys = pkg.resumedNormal.normalSpin.levelUpMoneys
        pb.resumedFree = {}
        pb.resumedFree.freeSpin = {}
        pb.resumedFree.freeSpin.bet = pkg.resumedFree.freeSpin.bet
        pb.resumedFree.freeSpin.winCoin = pkg.resumedFree.freeSpin.winCoin
        pb.resumedFree.freeSpin.results = {}
        pb.resumedFree.freeSpin.results.array = {}
        
        for ik, iv in pairs(pkg.resumedFree.freeSpin.results.array) do
            pb.resumedFree.freeSpin.results.array[ik] = {}
            pb.resumedFree.freeSpin.results.array[ik].grids = {}
            
            for jk, jv in pairs(iv.grids) do
                pb.resumedFree.freeSpin.results.array[ik].grids[jk] = {}
                pb.resumedFree.freeSpin.results.array[ik].grids[jk].index = jv.index
                pb.resumedFree.freeSpin.results.array[ik].grids[jk].icon = jv.icon
                pb.resumedFree.freeSpin.results.array[ik].grids[jk].golden = jv.golden
            end
            
            pb.resumedFree.freeSpin.results.array[ik].lines = {}
            
            for jk, jv in pairs(iv.lines) do
                pb.resumedFree.freeSpin.results.array[ik].lines[jk] = {}
                pb.resumedFree.freeSpin.results.array[ik].lines[jk].lineIndex = jv.lineIndex
                pb.resumedFree.freeSpin.results.array[ik].lines[jk].winCoin = jv.winCoin
                pb.resumedFree.freeSpin.results.array[ik].lines[jk].icon = jv.icon
                pb.resumedFree.freeSpin.results.array[ik].lines[jk].lineCells = {}
                
                for kk, kv in pairs(jv.lineCells) do
                    pb.resumedFree.freeSpin.results.array[ik].lines[jk].lineCells[kk] = {}
                    pb.resumedFree.freeSpin.results.array[ik].lines[jk].lineCells[kk].index = kv.index
                    pb.resumedFree.freeSpin.results.array[ik].lines[jk].lineCells[kk].icon = kv.icon
                    pb.resumedFree.freeSpin.results.array[ik].lines[jk].lineCells[kk].golden = kv.golden
                end
            end
            
            pb.resumedFree.freeSpin.results.array[ik].doubled = iv.doubled
            pb.resumedFree.freeSpin.results.array[ik].lastDoubled = iv.lastDoubled
            pb.resumedFree.freeSpin.results.array[ik].freeTime = iv.freeTime
            pb.resumedFree.freeSpin.results.array[ik].totalFreeTime = iv.totalFreeTime
        end
        
        pb.resumedFree.freeSpin.slotMoneyGift = {}
        pb.resumedFree.freeSpin.slotMoneyGift.money_gift = pkg.resumedFree.freeSpin.slotMoneyGift.money_gift
        pb.resumedFree.freeSpin.slotMoneyGift.money_gift_safe = pkg.resumedFree.freeSpin.slotMoneyGift.money_gift_safe
        pb.resumedFree.freeSpin.slotMoneyGift.amount_of_gift = pkg.resumedFree.freeSpin.slotMoneyGift.amount_of_gift
        pb.resumedFree.freeSpin.slotMoney = {}
        pb.resumedFree.freeSpin.slotMoney.money = pkg.resumedFree.freeSpin.slotMoney.money
        pb.resumedFree.freeSpin.slotMoney.money_safe = pkg.resumedFree.freeSpin.slotMoney.money_safe
        pb.status = pkg.status
        return pb
    elseif pkg.typeName == 'PKG_Slots_Client_MahjongWaysFreeRet' then
        pb.freeSpin = {}
        pb.freeSpin.bet = pkg.freeSpin.bet
        pb.freeSpin.winCoin = pkg.freeSpin.winCoin
        pb.freeSpin.results = {}
        pb.freeSpin.results.array = {}
        
        for ik, iv in pairs(pkg.freeSpin.results.array) do
            pb.freeSpin.results.array[ik] = {}
            pb.freeSpin.results.array[ik].grids = {}
            
            for jk, jv in pairs(iv.grids) do
                pb.freeSpin.results.array[ik].grids[jk] = {}
                pb.freeSpin.results.array[ik].grids[jk].index = jv.index
                pb.freeSpin.results.array[ik].grids[jk].icon = jv.icon
                pb.freeSpin.results.array[ik].grids[jk].golden = jv.golden
            end
            
            pb.freeSpin.results.array[ik].lines = {}
            
            for jk, jv in pairs(iv.lines) do
                pb.freeSpin.results.array[ik].lines[jk] = {}
                pb.freeSpin.results.array[ik].lines[jk].lineIndex = jv.lineIndex
                pb.freeSpin.results.array[ik].lines[jk].winCoin = jv.winCoin
                pb.freeSpin.results.array[ik].lines[jk].icon = jv.icon
                pb.freeSpin.results.array[ik].lines[jk].lineCells = {}
                
                for kk, kv in pairs(jv.lineCells) do
                    pb.freeSpin.results.array[ik].lines[jk].lineCells[kk] = {}
                    pb.freeSpin.results.array[ik].lines[jk].lineCells[kk].index = kv.index
                    pb.freeSpin.results.array[ik].lines[jk].lineCells[kk].icon = kv.icon
                    pb.freeSpin.results.array[ik].lines[jk].lineCells[kk].golden = kv.golden
                end
            end
            
            pb.freeSpin.results.array[ik].doubled = iv.doubled
            pb.freeSpin.results.array[ik].lastDoubled = iv.lastDoubled
            pb.freeSpin.results.array[ik].freeTime = iv.freeTime
            pb.freeSpin.results.array[ik].totalFreeTime = iv.totalFreeTime
        end
        
        pb.freeSpin.slotMoneyGift = {}
        pb.freeSpin.slotMoneyGift.money_gift = pkg.freeSpin.slotMoneyGift.money_gift
        pb.freeSpin.slotMoneyGift.money_gift_safe = pkg.freeSpin.slotMoneyGift.money_gift_safe
        pb.freeSpin.slotMoneyGift.amount_of_gift = pkg.freeSpin.slotMoneyGift.amount_of_gift
        pb.freeSpin.slotMoney = {}
        pb.freeSpin.slotMoney.money = pkg.freeSpin.slotMoney.money
        pb.freeSpin.slotMoney.money_safe = pkg.freeSpin.slotMoney.money_safe
        return pb
    elseif pkg.typeName == 'PKG_Slots_Client_OfflineCheck' then
        return pb
    elseif pkg.typeName == 'PKG_Slots_Client_LockLeaveSuccess' then
        return pb
    end
    return PkgHub.super.Pkg2Pb(self, pkg)
end

function PkgHub:Pb2Pkg(pb)
    if pb._msgName_ == 'PB.Client_Slots.table' then
        local pkg = PKG_Client_Slots_Sync.Create()
        return pkg
    elseif pb._msgName_ == 'PB.Client_Slots.Leave' then
        local pkg = PKG_Client_Slots_Leave.Create()
        return pkg
    elseif pb._msgName_ == 'PB.Client_Slots.PlayerSit' then
        local pkg = PKG_Client_Slots_PlayerSit.Create()
        pkg.tableId = pb.tableId
        pkg.chairId = pb.chairId
        return pkg
    elseif pb._msgName_ == 'PB.Client_Slots.MahjongWaysFreeSpin' then
        local pkg = PKG_Client_Slots_MahjongWaysFreeSpin.Create()
        return pkg
    elseif pb._msgName_ == 'PB.Client_Slots.CionInfo' then
        local pkg = PKG_Client_Slots_CionInfo.Create()
        pkg.cells = pb.cells
        return pkg
    elseif pb._msgName_ == 'PB.Client_Slots.Enter' then
        local pkg = PKG_Client_Slots_Enter.Create()
        return pkg
    elseif pb._msgName_ == 'PB.Client_Slots.LockLeave' then
        local pkg = PKG_Client_Slots_LockLeave.Create()
        return pkg
    elseif pb._msgName_ == 'PB.Client_Slots.MahjongWaysNormalSpin' then
        local pkg = PKG_Client_Slots_MahjongWaysNormalSpin.Create()
        pkg.betMoney = pb.betMoney
        pkg.lvID = pb.lvID
        pkg.moneyType = pb.moneyType
        return pkg
    end
    return PkgHub.super.Pb2Pkg(self, pb)
end

return PkgHub