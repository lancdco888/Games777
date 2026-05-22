local PkgHub = class("PkgHub", FBasePkgHub)

function PkgHub:ctor(...)
    PkgHub.super.ctor(self, ...)
    self.protoMap = {
        ['PKG_Slots_Client_SyncPlayerStates'] = 'PB.Slots_Client.SyncPlayerStates',
        ['PKG_Slots_Client_Leave_Success'] = 'PB.Slots_Client.Leave_Success',
        ['PKG_Slots_Client_CollectValue'] = 'PB.Slots_Client.CollectValue',
        ['PKG_Client_Slots_fafafa_WealthGoldFreeType'] = 'PB.Client_Slots.dragons5FreeType',
        ['PKG_Slots_Client_fafafa_WealthGoldEnterResumed'] = 'PB.Slots_Client.dragons5EnterResumed',
        ['PKG_Client_Slots_fafafa_WealthGoldFreeSpin'] = 'PB.Client_Slots.dragons5FreeSpin',
        ['PKG_Client_Slots_fafafa_WealthGoldNormalSpin'] = 'PB.Client_Slots.dragons5NormalSpin',
        ['PKG_Slots_Client_OfflineCheck'] = 'PB.Slots_Client.OfflineCheck',
        ['PKG_Slots_Client_fafafa_WealthGoldFreeRetType'] = 'PB.Slots_Client.dragons5FreeRetType',
        ['PKG_Slots_Client_Enter_Success'] = 'PB.Slots_Client.Enter_Success',
        ['PKG_Slots_Client_LockLeaveSuccess'] = 'PB.Slots_Client.LockLeaveSuccess',
        ['PKG_Slots_Client_fafafa_WealthGoldNormalRet'] = 'PB.Slots_Client.dragons5NormalRet',
        ['PKG_Slots_Client_fafafa_WealthGoldFreeRet'] = 'PB.Slots_Client.dragons5FreeRet',
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
    elseif pkg.typeName == 'PKG_Slots_Client_fafafa_WealthGoldEnterResumed' then
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
        
        pb.currentWinCoin = pkg.currentWinCoin
        pb.currentBetMoney = pkg.currentBetMoney
        pb.resumedNormal = {}
        pb.resumedNormal.normalSpin = {}
        pb.resumedNormal.normalSpin.bet = pkg.resumedNormal.bet
        pb.resumedNormal.normalSpin.winCoin = pkg.resumedNormal.winCoin
        pb.resumedNormal.normalSpin.grids = {}
        
        for ik, iv in pairs(pkg.resumedNormal.grids) do
            pb.resumedNormal.normalSpin.grids[ik] = {}
            pb.resumedNormal.normalSpin.grids[ik].index = iv.index
            pb.resumedNormal.normalSpin.grids[ik].icon = iv.icon
        end
        
        pb.resumedNormal.normalSpin.intoFree = pkg.resumedNormal.intoFree
        pb.resumedNormal.normalSpin.lines = {}
        
        for ik, iv in pairs(pkg.resumedNormal.lines) do
            pb.resumedNormal.normalSpin.lines[ik] = {}
            pb.resumedNormal.normalSpin.lines[ik].lineIndex = iv.lineIndex
            pb.resumedNormal.normalSpin.lines[ik].winCoin = iv.winCoin
            pb.resumedNormal.normalSpin.lines[ik].icon = iv.icon
            pb.resumedNormal.normalSpin.lines[ik].lineCells = {}
            
            for jk, jv in pairs(iv.lineCells) do
                pb.resumedNormal.normalSpin.lines[ik].lineCells[jk] = {}
                pb.resumedNormal.normalSpin.lines[ik].lineCells[jk].index = jv.index
                pb.resumedNormal.normalSpin.lines[ik].lineCells[jk].icon = jv.icon
            end
        end
        
        pb.resumedNormal.normalSpin.slotMoneyGift = {}
        pb.resumedNormal.normalSpin.slotMoneyGift.money_gift = pkg.resumedNormal.slotMoneyGift.money_gift
        pb.resumedNormal.normalSpin.slotMoneyGift.money_gift_safe = pkg.resumedNormal.slotMoneyGift.money_gift_safe
        pb.resumedNormal.normalSpin.slotMoneyGift.amount_of_gift = pkg.resumedNormal.slotMoneyGift.amount_of_gift
        pb.resumedNormal.normalSpin.slotMoney = {}
        pb.resumedNormal.normalSpin.slotMoney.money = pkg.resumedNormal.slotMoney.money
        pb.resumedNormal.normalSpin.slotMoney.money_safe = pkg.resumedNormal.slotMoney.money_safe
        pb.resumedNormal.normalSpin.levelUpMoney = pkg.resumedNormal.levelUpMoney
        pb.resumedNormal.normalSpin.levelUpMoneys = pkg.resumedNormal.levelUpMoneys
        pb.resumedFree = {}
        pb.resumedFree.freeSpin = {}
        pb.resumedFree.freeSpin.bet = pkg.resumedFree.bet
        pb.resumedFree.freeSpin.winCoin = pkg.resumedFree.winCoin
        pb.resumedFree.freeSpin.grids = {}
        
        for ik, iv in pairs(pkg.resumedFree.grids) do
            pb.resumedFree.freeSpin.grids[ik] = {}
            pb.resumedFree.freeSpin.grids[ik].index = iv.index
            pb.resumedFree.freeSpin.grids[ik].icon = iv.icon
        end
        
        pb.resumedFree.freeSpin.wildBet = pkg.resumedFree.wildBet
        pb.resumedFree.freeSpin.bonusWinCoin = pkg.resumedFree.bonusWinCoin
        pb.resumedFree.freeSpin.allCount = pkg.resumedFree.allCount
        pb.resumedFree.freeSpin.totalCount = pkg.resumedFree.totalCount
        pb.resumedFree.freeSpin.newFreeTime = pkg.resumedFree.newFreeTime
        pb.resumedFree.freeSpin.addTime = pkg.resumedFree.addTime
        pb.resumedFree.freeSpin.lines = {}
        
        for ik, iv in pairs(pkg.resumedFree.lines) do
            pb.resumedFree.freeSpin.lines[ik] = {}
            pb.resumedFree.freeSpin.lines[ik].lineIndex = iv.lineIndex
            pb.resumedFree.freeSpin.lines[ik].winCoin = iv.winCoin
            pb.resumedFree.freeSpin.lines[ik].icon = iv.icon
            pb.resumedFree.freeSpin.lines[ik].lineCells = {}
            
            for jk, jv in pairs(iv.lineCells) do
                pb.resumedFree.freeSpin.lines[ik].lineCells[jk] = {}
                pb.resumedFree.freeSpin.lines[ik].lineCells[jk].index = jv.index
                pb.resumedFree.freeSpin.lines[ik].lineCells[jk].icon = jv.icon
            end
        end
        
        pb.resumedFree.freeSpin.slotMoneyGift = {}
        pb.resumedFree.freeSpin.slotMoneyGift.money_gift = pkg.resumedFree.slotMoneyGift.money_gift
        pb.resumedFree.freeSpin.slotMoneyGift.money_gift_safe = pkg.resumedFree.slotMoneyGift.money_gift_safe
        pb.resumedFree.freeSpin.slotMoneyGift.amount_of_gift = pkg.resumedFree.slotMoneyGift.amount_of_gift
        pb.resumedFree.freeSpin.slotMoney = {}
        pb.resumedFree.freeSpin.slotMoney.money = pkg.resumedFree.slotMoney.money
        pb.resumedFree.freeSpin.slotMoney.money_safe = pkg.resumedFree.slotMoney.money_safe
        pb.freeType = {}
        pb.freeType.freeType = {}
        pb.freeType.freeType.type = pkg.freeType.type
        pb.type = pkg.type
        pb.freetime = pkg.freetime
        pb.lvID = pkg.lvID
        return pb
    elseif pkg.typeName == 'PKG_Slots_Client_OfflineCheck' then
        return pb
    elseif pkg.typeName == 'PKG_Slots_Client_fafafa_WealthGoldFreeRetType' then
        pb.freeType = {}
        pb.freeType.type = pkg.type
        return pb
    elseif pkg.typeName == 'PKG_Slots_Client_LockLeaveSuccess' then
        return pb
    elseif pkg.typeName == 'PKG_Slots_Client_fafafa_WealthGoldNormalRet' then
        pb.normalSpin = {}
        pb.normalSpin.bet = pkg.bet
        pb.normalSpin.winCoin = pkg.winCoin
        pb.normalSpin.grids = {}
        
        for ik, iv in pairs(pkg.grids) do
            pb.normalSpin.grids[ik] = {}
            pb.normalSpin.grids[ik].index = iv.index
            pb.normalSpin.grids[ik].icon = iv.icon
        end
        
        pb.normalSpin.intoFree = pkg.intoFree
        pb.normalSpin.lines = {}
        
        for ik, iv in pairs(pkg.lines) do
            pb.normalSpin.lines[ik] = {}
            pb.normalSpin.lines[ik].lineIndex = iv.lineIndex
            pb.normalSpin.lines[ik].winCoin = iv.winCoin
            pb.normalSpin.lines[ik].icon = iv.icon
            pb.normalSpin.lines[ik].lineCells = {}
            
            for jk, jv in pairs(iv.lineCells) do
                pb.normalSpin.lines[ik].lineCells[jk] = {}
                pb.normalSpin.lines[ik].lineCells[jk].index = jv.index
                pb.normalSpin.lines[ik].lineCells[jk].icon = jv.icon
            end
        end
        
        pb.normalSpin.slotMoneyGift = {}
        pb.normalSpin.slotMoneyGift.money_gift = pkg.slotMoneyGift.money_gift
        pb.normalSpin.slotMoneyGift.money_gift_safe = pkg.slotMoneyGift.money_gift_safe
        pb.normalSpin.slotMoneyGift.amount_of_gift = pkg.slotMoneyGift.amount_of_gift
        pb.normalSpin.slotMoney = {}
        pb.normalSpin.slotMoney.money = pkg.slotMoney.money
        pb.normalSpin.slotMoney.money_safe = pkg.slotMoney.money_safe
        pb.normalSpin.levelUpMoney = pkg.levelUpMoney
        pb.normalSpin.levelUpMoneys = pkg.levelUpMoneys
        return pb
    elseif pkg.typeName == 'PKG_Slots_Client_fafafa_WealthGoldFreeRet' then
        pb.freeSpin = {}
        pb.freeSpin.bet = pkg.bet
        pb.freeSpin.winCoin = pkg.winCoin
        pb.freeSpin.grids = {}
        
        for ik, iv in pairs(pkg.grids) do
            pb.freeSpin.grids[ik] = {}
            pb.freeSpin.grids[ik].index = iv.index
            pb.freeSpin.grids[ik].icon = iv.icon
        end
        
        pb.freeSpin.wildBet = pkg.wildBet
        pb.freeSpin.bonusWinCoin = pkg.bonusWinCoin
        pb.freeSpin.allCount = pkg.allCount
        pb.freeSpin.totalCount = pkg.totalCount
        pb.freeSpin.newFreeTime = pkg.newFreeTime
        pb.freeSpin.addTime = pkg.addTime
        pb.freeSpin.lines = {}
        
        for ik, iv in pairs(pkg.lines) do
            pb.freeSpin.lines[ik] = {}
            pb.freeSpin.lines[ik].lineIndex = iv.lineIndex
            pb.freeSpin.lines[ik].winCoin = iv.winCoin
            pb.freeSpin.lines[ik].icon = iv.icon
            pb.freeSpin.lines[ik].lineCells = {}
            
            for jk, jv in pairs(iv.lineCells) do
                pb.freeSpin.lines[ik].lineCells[jk] = {}
                pb.freeSpin.lines[ik].lineCells[jk].index = jv.index
                pb.freeSpin.lines[ik].lineCells[jk].icon = jv.icon
            end
        end
        
        pb.freeSpin.slotMoneyGift = {}
        pb.freeSpin.slotMoneyGift.money_gift = pkg.slotMoneyGift.money_gift
        pb.freeSpin.slotMoneyGift.money_gift_safe = pkg.slotMoneyGift.money_gift_safe
        pb.freeSpin.slotMoneyGift.amount_of_gift = pkg.slotMoneyGift.amount_of_gift
        pb.freeSpin.slotMoney = {}
        pb.freeSpin.slotMoney.money = pkg.slotMoney.money
        pb.freeSpin.slotMoney.money_safe = pkg.slotMoney.money_safe
        return pb
    end
    return PkgHub.super.Pkg2Pb(self, pkg)
end

function PkgHub:Pb2Pkg(pb)
    if pb._msgName_ == 'PB.Client_Slots.dragons5FreeType' then
        local pkg = PKG_Client_Slots_fafafa_WealthGoldFreeType.Create()
        pkg.type = pb.type
        return pkg
    elseif pb._msgName_ == 'PB.Client_Slots.dragons5FreeSpin' then
        local pkg = PKG_Client_Slots_fafafa_WealthGoldFreeSpin.Create()
        return pkg
    elseif pb._msgName_ == 'PB.Client_Slots.dragons5NormalSpin' then
        local pkg = PKG_Client_Slots_fafafa_WealthGoldNormalSpin.Create()
        pkg.betMoney = pb.betMoney
        pkg.lvID = pb.lvID
        pkg.moneyType = pb.moneyType
        return pkg
    end
    return PkgHub.super.Pb2Pkg(self, pb)
end

return PkgHub