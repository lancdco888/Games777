local PkgHub = class("PkgHub", FBasePkgHub)

function PkgHub:ctor(...)
    PkgHub.super.ctor(self, ...)
    self.protoMap = {
        ['PKG_Slots_Client_SyncPlayerStates'] = 'PB.Slots_Client.SyncPlayerStates',
        ['PKG_Client_Slots_BuffaloFreeSpin'] = 'PB.Client_Slots.BuffaloFreeSpin',
        ['PKG_Slots_Client_Leave_Success'] = 'PB.Slots_Client.Leave_Success',
        ['PKG_Slots_Client_CollectValue'] = 'PB.Slots_Client.CollectValue',
        ['PKG_Slots_Client_BuffaloFreeRet'] = 'PB.Slots_Client.BuffaloFreeRet',
        ['PKG_Slots_Client_BuffaloNormalRet'] = 'PB.Slots_Client.BuffaloNormalRet',
        ['PKG_Slots_Client_BuffaloEnterResumed'] = 'PB.Slots_Client.BuffaloEnterResumed',
        ['PKG_Slots_Client_BuffaloFreeTypeRet'] = 'PB.Slots_Client.BuffaloFreeTypeRet',
        ['PKG_Slots_Client_OfflineCheck'] = 'PB.Slots_Client.OfflineCheck',
        ['PKG_Client_Slots_BuffaloNormalSpin'] = 'PB.Client_Slots.BuffaloNormalSpin',
        ['PKG_Slots_Client_LockLeaveSuccess'] = 'PB.Slots_Client.LockLeaveSuccess',
        ['PKG_Slots_Client_Enter_Success'] = 'PB.Slots_Client.Enter_Success',
        ['PKG_Client_Slots_BuffaloFreeType'] = 'PB.Client_Slots.BuffaloFreeType',
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
    elseif pkg.typeName == 'PKG_Slots_Client_BuffaloFreeRet' then
        pb.freeSpin = {}
        pb.freeSpin.bet = pkg.freeSpin.bet
        pb.freeSpin.winCoin = pkg.freeSpin.winCoin
        pb.freeSpin.grids = {}
        
        for ik, iv in pairs(pkg.freeSpin.grids) do
            pb.freeSpin.grids[ik] = {}
            pb.freeSpin.grids[ik].index = iv.index
            pb.freeSpin.grids[ik].icon = iv.icon
            pb.freeSpin.grids[ik].SymbolType = iv.SymbolType
            pb.freeSpin.grids[ik].SymbolValue = iv.SymbolValue
            pb.freeSpin.grids[ik].IsHide = iv.isHide
        end
        
        pb.freeSpin.bonusWinCoin = pkg.freeSpin.bonusWinCoin
        pb.freeSpin.allCount = pkg.freeSpin.allCount
        pb.freeSpin.totalCount = pkg.freeSpin.totalCount
        pb.freeSpin.lines = {}
        
        for ik, iv in pairs(pkg.freeSpin.lines) do
            pb.freeSpin.lines[ik] = {}
            pb.freeSpin.lines[ik].lineIndex = iv.lineIndex
            pb.freeSpin.lines[ik].winCoin = iv.winCoin
            pb.freeSpin.lines[ik].icon = iv.icon
            pb.freeSpin.lines[ik].lineCells = {}
            
            for jk, jv in pairs(iv.lineCells) do
                pb.freeSpin.lines[ik].lineCells[jk] = {}
                pb.freeSpin.lines[ik].lineCells[jk].index = jv.index
                pb.freeSpin.lines[ik].lineCells[jk].icon = jv.icon
                pb.freeSpin.lines[ik].lineCells[jk].SymbolType = jv.SymbolType
                pb.freeSpin.lines[ik].lineCells[jk].SymbolValue = jv.SymbolValue
                pb.freeSpin.lines[ik].lineCells[jk].IsHide = jv.isHide
            end
        end
        
        pb.freeSpin.addTime = pkg.freeSpin.addTime
        pb.freeSpin.gametype = pkg.freeSpin.gametype
        pb.freeSpin.slotMoneyGift = {}
        pb.freeSpin.slotMoneyGift.money_gift = pkg.freeSpin.slotMoneyGift.money_gift
        pb.freeSpin.slotMoneyGift.money_gift_safe = pkg.freeSpin.slotMoneyGift.money_gift_safe
        pb.freeSpin.slotMoneyGift.amount_of_gift = pkg.freeSpin.slotMoneyGift.amount_of_gift
        pb.freeSpin.slotMoney = {}
        pb.freeSpin.slotMoney.money = pkg.freeSpin.slotMoney.money
        pb.freeSpin.slotMoney.money_safe = pkg.freeSpin.slotMoney.money_safe
        pb.freeSpin.wildType = pkg.freeSpin.wildType
        return pb
    elseif pkg.typeName == 'PKG_Slots_Client_BuffaloNormalRet' then
        pb.normalSpin = {}
        pb.normalSpin.bet = pkg.normalSpin.bet
        pb.normalSpin.winCoin = pkg.normalSpin.winCoin
        pb.normalSpin.grids = {}
        
        for ik, iv in pairs(pkg.normalSpin.grids) do
            pb.normalSpin.grids[ik] = {}
            pb.normalSpin.grids[ik].index = iv.index
            pb.normalSpin.grids[ik].icon = iv.icon
            pb.normalSpin.grids[ik].SymbolType = iv.SymbolType
            pb.normalSpin.grids[ik].SymbolValue = iv.SymbolValue
            pb.normalSpin.grids[ik].IsHide = iv.isHide
        end
        
        pb.normalSpin.intoFree = pkg.normalSpin.intoFree
        pb.normalSpin.lines = {}
        
        for ik, iv in pairs(pkg.normalSpin.lines) do
            pb.normalSpin.lines[ik] = {}
            pb.normalSpin.lines[ik].lineIndex = iv.lineIndex
            pb.normalSpin.lines[ik].winCoin = iv.winCoin
            pb.normalSpin.lines[ik].icon = iv.icon
            pb.normalSpin.lines[ik].lineCells = {}
            
            for jk, jv in pairs(iv.lineCells) do
                pb.normalSpin.lines[ik].lineCells[jk] = {}
                pb.normalSpin.lines[ik].lineCells[jk].index = jv.index
                pb.normalSpin.lines[ik].lineCells[jk].icon = jv.icon
                pb.normalSpin.lines[ik].lineCells[jk].SymbolType = jv.SymbolType
                pb.normalSpin.lines[ik].lineCells[jk].SymbolValue = jv.SymbolValue
                pb.normalSpin.lines[ik].lineCells[jk].IsHide = jv.isHide
            end
        end
        
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
    elseif pkg.typeName == 'PKG_Slots_Client_BuffaloEnterResumed' then
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
        pb.resumedNormal.normalSpin.bet = pkg.resumedNormal.normalSpin.bet
        pb.resumedNormal.normalSpin.winCoin = pkg.resumedNormal.normalSpin.winCoin
        pb.resumedNormal.normalSpin.grids = {}
        
        for ik, iv in pairs(pkg.resumedNormal.normalSpin.grids) do
            pb.resumedNormal.normalSpin.grids[ik] = {}
            pb.resumedNormal.normalSpin.grids[ik].index = iv.index
            pb.resumedNormal.normalSpin.grids[ik].icon = iv.icon
            pb.resumedNormal.normalSpin.grids[ik].SymbolType = iv.SymbolType
            pb.resumedNormal.normalSpin.grids[ik].SymbolValue = iv.SymbolValue
            pb.resumedNormal.normalSpin.grids[ik].IsHide = iv.isHide
        end
        
        pb.resumedNormal.normalSpin.intoFree = pkg.resumedNormal.normalSpin.intoFree
        pb.resumedNormal.normalSpin.lines = {}
        
        for ik, iv in pairs(pkg.resumedNormal.normalSpin.lines) do
            pb.resumedNormal.normalSpin.lines[ik] = {}
            pb.resumedNormal.normalSpin.lines[ik].lineIndex = iv.lineIndex
            pb.resumedNormal.normalSpin.lines[ik].winCoin = iv.winCoin
            pb.resumedNormal.normalSpin.lines[ik].icon = iv.icon
            pb.resumedNormal.normalSpin.lines[ik].lineCells = {}
            
            for jk, jv in pairs(iv.lineCells) do
                pb.resumedNormal.normalSpin.lines[ik].lineCells[jk] = {}
                pb.resumedNormal.normalSpin.lines[ik].lineCells[jk].index = jv.index
                pb.resumedNormal.normalSpin.lines[ik].lineCells[jk].icon = jv.icon
                pb.resumedNormal.normalSpin.lines[ik].lineCells[jk].SymbolType = jv.SymbolType
                pb.resumedNormal.normalSpin.lines[ik].lineCells[jk].SymbolValue = jv.SymbolValue
                pb.resumedNormal.normalSpin.lines[ik].lineCells[jk].IsHide = jv.isHide
            end
        end
        
        pb.resumedNormal.normalSpin.slotMoneyGift = {}
        pb.resumedNormal.normalSpin.slotMoneyGift.money_gift = pkg.resumedNormal.normalSpin.slotMoneyGift.money_gift
        pb.resumedNormal.normalSpin.slotMoneyGift.money_gift_safe = pkg.resumedNormal.normalSpin.slotMoneyGift.money_gift_safe
        pb.resumedNormal.normalSpin.slotMoneyGift.amount_of_gift = pkg.resumedNormal.normalSpin.slotMoneyGift.amount_of_gift
        pb.resumedNormal.normalSpin.slotMoney = {}
        pb.resumedNormal.normalSpin.slotMoney.money = pkg.resumedNormal.normalSpin.slotMoney.money
        pb.resumedNormal.normalSpin.slotMoney.money_safe = pkg.resumedNormal.normalSpin.slotMoney.money_safe
        pb.resumedNormal.normalSpin.levelUpMoney = pkg.resumedNormal.normalSpin.levelUpMoney
        pb.resumedNormal.normalSpin.levelUpMoneys = pkg.resumedNormal.normalSpin.levelUpMoneys
        pb.resumedFreeType = {}
        pb.resumedFreeType.freetype = {}
        pb.resumedFreeType.freetype.type = pkg.resumedFreeType.freetype.type
        pb.resumedFree = {}
        pb.resumedFree.freeSpin = {}
        pb.resumedFree.freeSpin.bet = pkg.resumedFree.freeSpin.bet
        pb.resumedFree.freeSpin.winCoin = pkg.resumedFree.freeSpin.winCoin
        pb.resumedFree.freeSpin.grids = {}
        
        for ik, iv in pairs(pkg.resumedFree.freeSpin.grids) do
            pb.resumedFree.freeSpin.grids[ik] = {}
            pb.resumedFree.freeSpin.grids[ik].index = iv.index
            pb.resumedFree.freeSpin.grids[ik].icon = iv.icon
            pb.resumedFree.freeSpin.grids[ik].SymbolType = iv.SymbolType
            pb.resumedFree.freeSpin.grids[ik].SymbolValue = iv.SymbolValue
            pb.resumedFree.freeSpin.grids[ik].IsHide = iv.isHide
        end
        
        pb.resumedFree.freeSpin.bonusWinCoin = pkg.resumedFree.freeSpin.bonusWinCoin
        pb.resumedFree.freeSpin.allCount = pkg.resumedFree.freeSpin.allCount
        pb.resumedFree.freeSpin.totalCount = pkg.resumedFree.freeSpin.totalCount
        pb.resumedFree.freeSpin.lines = {}
        
        for ik, iv in pairs(pkg.resumedFree.freeSpin.lines) do
            pb.resumedFree.freeSpin.lines[ik] = {}
            pb.resumedFree.freeSpin.lines[ik].lineIndex = iv.lineIndex
            pb.resumedFree.freeSpin.lines[ik].winCoin = iv.winCoin
            pb.resumedFree.freeSpin.lines[ik].icon = iv.icon
            pb.resumedFree.freeSpin.lines[ik].lineCells = {}
            
            for jk, jv in pairs(iv.lineCells) do
                pb.resumedFree.freeSpin.lines[ik].lineCells[jk] = {}
                pb.resumedFree.freeSpin.lines[ik].lineCells[jk].index = jv.index
                pb.resumedFree.freeSpin.lines[ik].lineCells[jk].icon = jv.icon
                pb.resumedFree.freeSpin.lines[ik].lineCells[jk].SymbolType = jv.SymbolType
                pb.resumedFree.freeSpin.lines[ik].lineCells[jk].SymbolValue = jv.SymbolValue
                pb.resumedFree.freeSpin.lines[ik].lineCells[jk].IsHide = jv.isHide
            end
        end
        
        pb.resumedFree.freeSpin.addTime = pkg.resumedFree.freeSpin.addTime
        pb.resumedFree.freeSpin.gametype = pkg.resumedFree.freeSpin.gametype
        pb.resumedFree.freeSpin.slotMoneyGift = {}
        pb.resumedFree.freeSpin.slotMoneyGift.money_gift = pkg.resumedFree.freeSpin.slotMoneyGift.money_gift
        pb.resumedFree.freeSpin.slotMoneyGift.money_gift_safe = pkg.resumedFree.freeSpin.slotMoneyGift.money_gift_safe
        pb.resumedFree.freeSpin.slotMoneyGift.amount_of_gift = pkg.resumedFree.freeSpin.slotMoneyGift.amount_of_gift
        pb.resumedFree.freeSpin.slotMoney = {}
        pb.resumedFree.freeSpin.slotMoney.money = pkg.resumedFree.freeSpin.slotMoney.money
        pb.resumedFree.freeSpin.slotMoney.money_safe = pkg.resumedFree.freeSpin.slotMoney.money_safe
        pb.resumedFree.freeSpin.wildType = pkg.resumedFree.freeSpin.wildType
        pb.type = pkg.type
        pb.cells = pkg.cells
        pb.lvID = pkg.lvID
        return pb
    elseif pkg.typeName == 'PKG_Slots_Client_BuffaloFreeTypeRet' then
        pb.freetype = {}
        pb.freetype.type = pkg.freetype.type
        return pb
    elseif pkg.typeName == 'PKG_Slots_Client_OfflineCheck' then
        return pb
    elseif pkg.typeName == 'PKG_Slots_Client_LockLeaveSuccess' then
        return pb
    end
    return PkgHub.super.Pkg2Pb(self, pkg)
end

function PkgHub:Pb2Pkg(pb)
    if pb._msgName_ == 'PB.Client_Slots.BuffaloFreeSpin' then
        local pkg = PKG_Client_Slots_BuffaloFreeSpin.Create()
        return pkg
    elseif pb._msgName_ == 'PB.Client_Slots.BuffaloNormalSpin' then
        local pkg = PKG_Client_Slots_BuffaloNormalSpin.Create()
        pkg.betMoney = pb.betMoney
        pkg.lvID = pb.lvID
        pkg.moneyType = pb.moneyType
        return pkg
    elseif pb._msgName_ == 'PB.Client_Slots.BuffaloFreeType' then
        local pkg = PKG_Client_Slots_BuffaloFreeType.Create()
        pkg.type = pb.type
        return pkg
    end
    return PkgHub.super.Pb2Pkg(self, pb)
end

return PkgHub