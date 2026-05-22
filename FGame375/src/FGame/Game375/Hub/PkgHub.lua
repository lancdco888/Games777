local PkgHub = class("PkgHub", FBasePkgHub)

function PkgHub:ctor(...)
    PkgHub.super.ctor(self, ...)
    self.protoMap = {
        ['PKG_Slots_Client_SyncPlayerStates'] = 'PB.Slots_Client.SyncPlayerStates',
        ['PKG_Client_Slots_EurekaTrainFreeSpin'] = 'PB.Client_Slots.EurekaTrainFreeSpin',
        ['PKG_Slots_Client_EurekaTrainFreeRet'] = 'PB.Slots_Client.EurekaTrainFreeRet',
        ['PKG_Slots_Client_Leave_Success'] = 'PB.Slots_Client.Leave_Success',
        ['PKG_Slots_Client_EurekaTrainFreeTypeRet'] = 'PB.Slots_Client.EurekaTrainFreeTypeRet',
        ['PKG_Slots_Client_EurekaTrainEnterResumed'] = 'PB.Slots_Client.EurekaTrainEnterResumed',
        ['PKG_Slots_Client_CollectValue'] = 'PB.Slots_Client.CollectValue',
        ['PKG_Client_Slots_EurekaTrainFreeType'] = 'PB.Client_Slots.EurekaTrainFreeType',
        ['PKG_Slots_Client_Enter_Success'] = 'PB.Slots_Client.Enter_Success',
        ['PKG_Slots_Client_OfflineCheck'] = 'PB.Slots_Client.OfflineCheck',
        ['PKG_Client_Slots_EurekaTrainNormalSpin'] = 'PB.Client_Slots.EurekaTrainNormalSpin',
        ['PKG_Client_Slots_EurekaTrainSpecialSpin'] = 'PB.Client_Slots.EurekaTrainSpecialSpin',
        ['PKG_Slots_Client_EurekaTrainNormalRet'] = 'PB.Slots_Client.EurekaTrainNormalRet',
        ['PKG_Slots_Client_LockLeaveSuccess'] = 'PB.Slots_Client.LockLeaveSuccess',
        ['PKG_Slots_Client_EurekaTrainSpecialRet'] = 'PB.Slots_Client.EurekaTrainSpecialRet',
    }
end
function PkgHub:Pkg2Pb(pkg)
    local pb = {}
    pb._msgName_ = self.protoMap[pkg.typeName]
    if pkg.typeName == 'PKG_Slots_Client_EurekaTrainFreeRet' then
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
            pb.freeSpin.grids[ik].trainStart = iv.trainStart
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
                pb.freeSpin.lines[ik].lineCells[jk].trainStart = jv.trainStart
            end
            
            pb.freeSpin.lines[ik].trainType = iv.trainType
            pb.freeSpin.lines[ik].trainStart = iv.trainStart
        end
        
        pb.freeSpin.addTime = pkg.freeSpin.addTime
        pb.freeSpin.trainType = pkg.freeSpin.trainType
        pb.freeSpin.slotMoneyGift = {}
        pb.freeSpin.slotMoneyGift.money_gift = pkg.freeSpin.slotMoneyGift.money_gift
        pb.freeSpin.slotMoneyGift.money_gift_safe = pkg.freeSpin.slotMoneyGift.money_gift_safe
        pb.freeSpin.slotMoneyGift.amount_of_gift = pkg.freeSpin.slotMoneyGift.amount_of_gift
        pb.freeSpin.slotMoney = {}
        pb.freeSpin.slotMoney.money = pkg.freeSpin.slotMoney.money
        pb.freeSpin.slotMoney.money_safe = pkg.freeSpin.slotMoney.money_safe
        return pb
    elseif pkg.typeName == 'PKG_Slots_Client_Leave_Success' then
        return pb
    elseif pkg.typeName == 'PKG_Slots_Client_EurekaTrainFreeTypeRet' then
        pb.freetype = {}
        pb.freetype.type = pkg.freetype.type
        return pb
    elseif pkg.typeName == 'PKG_Slots_Client_EurekaTrainEnterResumed' then
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
            pb.resumedNormal.normalSpin.grids[ik].trainStart = iv.trainStart
        end
        
        pb.resumedNormal.normalSpin.freeType = pkg.resumedNormal.normalSpin.freeType
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
                pb.resumedNormal.normalSpin.lines[ik].lineCells[jk].trainStart = jv.trainStart
            end
            
            pb.resumedNormal.normalSpin.lines[ik].trainType = iv.trainType
            pb.resumedNormal.normalSpin.lines[ik].trainStart = iv.trainStart
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
        pb.resumedNormal.normalSpin.trainType = pkg.resumedNormal.normalSpin.trainType
        pb.resumedFreetype = {}
        pb.resumedFreetype.freetype = {}
        pb.resumedFreetype.freetype.type = pkg.resumedFreeType.freetype.type
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
            pb.resumedFree.freeSpin.grids[ik].trainStart = iv.trainStart
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
                pb.resumedFree.freeSpin.lines[ik].lineCells[jk].trainStart = jv.trainStart
            end
            
            pb.resumedFree.freeSpin.lines[ik].trainType = iv.trainType
            pb.resumedFree.freeSpin.lines[ik].trainStart = iv.trainStart
        end
        
        pb.resumedFree.freeSpin.addTime = pkg.resumedFree.freeSpin.addTime
        pb.resumedFree.freeSpin.trainType = pkg.resumedFree.freeSpin.trainType
        pb.resumedFree.freeSpin.slotMoneyGift = {}
        pb.resumedFree.freeSpin.slotMoneyGift.money_gift = pkg.resumedFree.freeSpin.slotMoneyGift.money_gift
        pb.resumedFree.freeSpin.slotMoneyGift.money_gift_safe = pkg.resumedFree.freeSpin.slotMoneyGift.money_gift_safe
        pb.resumedFree.freeSpin.slotMoneyGift.amount_of_gift = pkg.resumedFree.freeSpin.slotMoneyGift.amount_of_gift
        pb.resumedFree.freeSpin.slotMoney = {}
        pb.resumedFree.freeSpin.slotMoney.money = pkg.resumedFree.freeSpin.slotMoney.money
        pb.resumedFree.freeSpin.slotMoney.money_safe = pkg.resumedFree.freeSpin.slotMoney.money_safe
        pb.resumedSpecial = {}
        pb.resumedSpecial.specialSpin = {}
        pb.resumedSpecial.specialSpin.bet = pkg.resumedSpecial.specialSpin.bet
        pb.resumedSpecial.specialSpin.winCoin = pkg.resumedSpecial.specialSpin.winCoin
        pb.resumedSpecial.specialSpin.graphs = {}
        
        for ik, iv in pairs(pkg.resumedSpecial.specialSpin.graphs) do
            pb.resumedSpecial.specialSpin.graphs[ik] = {}
            pb.resumedSpecial.specialSpin.graphs[ik].grids = {}
            
            for jk, jv in pairs(iv.grids) do
                pb.resumedSpecial.specialSpin.graphs[ik].grids[jk] = {}
                pb.resumedSpecial.specialSpin.graphs[ik].grids[jk].index = jv.index
                pb.resumedSpecial.specialSpin.graphs[ik].grids[jk].icon = jv.icon
                pb.resumedSpecial.specialSpin.graphs[ik].grids[jk].SymbolType = jv.SymbolType
                pb.resumedSpecial.specialSpin.graphs[ik].grids[jk].SymbolValue = jv.SymbolValue
                pb.resumedSpecial.specialSpin.graphs[ik].grids[jk].trainStart = jv.trainStart
            end
            
            pb.resumedSpecial.specialSpin.graphs[ik].lines = {}
            
            for jk, jv in pairs(iv.lines) do
                pb.resumedSpecial.specialSpin.graphs[ik].lines[jk] = {}
                pb.resumedSpecial.specialSpin.graphs[ik].lines[jk].lineIndex = jv.lineIndex
                pb.resumedSpecial.specialSpin.graphs[ik].lines[jk].winCoin = jv.winCoin
                pb.resumedSpecial.specialSpin.graphs[ik].lines[jk].icon = jv.icon
                pb.resumedSpecial.specialSpin.graphs[ik].lines[jk].lineCells = {}
                
                for kk, kv in pairs(jv.lineCells) do
                    pb.resumedSpecial.specialSpin.graphs[ik].lines[jk].lineCells[kk] = {}
                    pb.resumedSpecial.specialSpin.graphs[ik].lines[jk].lineCells[kk].index = kv.index
                    pb.resumedSpecial.specialSpin.graphs[ik].lines[jk].lineCells[kk].icon = kv.icon
                    pb.resumedSpecial.specialSpin.graphs[ik].lines[jk].lineCells[kk].SymbolType = kv.SymbolType
                    pb.resumedSpecial.specialSpin.graphs[ik].lines[jk].lineCells[kk].SymbolValue = kv.SymbolValue
                    pb.resumedSpecial.specialSpin.graphs[ik].lines[jk].lineCells[kk].trainStart = kv.trainStart
                end
                
                pb.resumedSpecial.specialSpin.graphs[ik].lines[jk].trainType = jv.trainType
                pb.resumedSpecial.specialSpin.graphs[ik].lines[jk].trainStart = jv.trainStart
            end
        end
        
        pb.resumedSpecial.specialSpin.bonusWinCoin = pkg.resumedSpecial.specialSpin.bonusWinCoin
        pb.resumedSpecial.specialSpin.allCount = pkg.resumedSpecial.specialSpin.allCount
        pb.resumedSpecial.specialSpin.totalCount = pkg.resumedSpecial.specialSpin.totalCount
        pb.resumedSpecial.specialSpin.AllWinCoin = pkg.resumedSpecial.specialSpin.AllWinCoin
        pb.resumedSpecial.specialSpin.extraSpin = pkg.resumedSpecial.specialSpin.extraSpin
        pb.resumedSpecial.specialSpin.trainType = pkg.resumedSpecial.specialSpin.trainType
        pb.resumedSpecial.specialSpin.slotMoneyGift = {}
        pb.resumedSpecial.specialSpin.slotMoneyGift.money_gift = pkg.resumedSpecial.specialSpin.slotMoneyGift.money_gift
        pb.resumedSpecial.specialSpin.slotMoneyGift.money_gift_safe = pkg.resumedSpecial.specialSpin.slotMoneyGift.money_gift_safe
        pb.resumedSpecial.specialSpin.slotMoneyGift.amount_of_gift = pkg.resumedSpecial.specialSpin.slotMoneyGift.amount_of_gift
        pb.resumedSpecial.specialSpin.slotMoney = {}
        pb.resumedSpecial.specialSpin.slotMoney.money = pkg.resumedSpecial.specialSpin.slotMoney.money
        pb.resumedSpecial.specialSpin.slotMoney.money_safe = pkg.resumedSpecial.specialSpin.slotMoney.money_safe
        pb.resumedSpecial.specialSpin.isFull = pkg.resumedSpecial.specialSpin.isFull
        pb.type = pkg.type
        pb.lvID = pkg.lvID
        return pb
    elseif pkg.typeName == 'PKG_Slots_Client_CollectValue' then
        pb.nowValue = pkg.nowValue
        return pb
    elseif pkg.typeName == 'PKG_Slots_Client_OfflineCheck' then
        return pb
    elseif pkg.typeName == 'PKG_Slots_Client_EurekaTrainNormalRet' then
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
            pb.normalSpin.grids[ik].trainStart = iv.trainStart
        end
        
        pb.normalSpin.freeType = pkg.normalSpin.freeType
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
                pb.normalSpin.lines[ik].lineCells[jk].trainStart = jv.trainStart
            end
            
            pb.normalSpin.lines[ik].trainType = iv.trainType
            pb.normalSpin.lines[ik].trainStart = iv.trainStart
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
        pb.normalSpin.trainType = pkg.normalSpin.trainType
        return pb
    elseif pkg.typeName == 'PKG_Slots_Client_LockLeaveSuccess' then
        return pb
    elseif pkg.typeName == 'PKG_Slots_Client_EurekaTrainSpecialRet' then
        pb.specialSpin = {}
        pb.specialSpin.bet = pkg.specialSpin.bet
        pb.specialSpin.winCoin = pkg.specialSpin.winCoin
        pb.specialSpin.graphs = {}
        
        for ik, iv in pairs(pkg.specialSpin.graphs) do
            pb.specialSpin.graphs[ik] = {}
            pb.specialSpin.graphs[ik].grids = {}
            
            for jk, jv in pairs(iv.grids) do
                pb.specialSpin.graphs[ik].grids[jk] = {}
                pb.specialSpin.graphs[ik].grids[jk].index = jv.index
                pb.specialSpin.graphs[ik].grids[jk].icon = jv.icon
                pb.specialSpin.graphs[ik].grids[jk].SymbolType = jv.SymbolType
                pb.specialSpin.graphs[ik].grids[jk].SymbolValue = jv.SymbolValue
                pb.specialSpin.graphs[ik].grids[jk].trainStart = jv.trainStart
            end
            
            pb.specialSpin.graphs[ik].lines = {}
            
            for jk, jv in pairs(iv.lines) do
                pb.specialSpin.graphs[ik].lines[jk] = {}
                pb.specialSpin.graphs[ik].lines[jk].lineIndex = jv.lineIndex
                pb.specialSpin.graphs[ik].lines[jk].winCoin = jv.winCoin
                pb.specialSpin.graphs[ik].lines[jk].icon = jv.icon
                pb.specialSpin.graphs[ik].lines[jk].lineCells = {}
                
                for kk, kv in pairs(jv.lineCells) do
                    pb.specialSpin.graphs[ik].lines[jk].lineCells[kk] = {}
                    pb.specialSpin.graphs[ik].lines[jk].lineCells[kk].index = kv.index
                    pb.specialSpin.graphs[ik].lines[jk].lineCells[kk].icon = kv.icon
                    pb.specialSpin.graphs[ik].lines[jk].lineCells[kk].SymbolType = kv.SymbolType
                    pb.specialSpin.graphs[ik].lines[jk].lineCells[kk].SymbolValue = kv.SymbolValue
                    pb.specialSpin.graphs[ik].lines[jk].lineCells[kk].trainStart = kv.trainStart
                end
                
                pb.specialSpin.graphs[ik].lines[jk].trainType = jv.trainType
                pb.specialSpin.graphs[ik].lines[jk].trainStart = jv.trainStart
            end
        end
        
        pb.specialSpin.bonusWinCoin = pkg.specialSpin.bonusWinCoin
        pb.specialSpin.allCount = pkg.specialSpin.allCount
        pb.specialSpin.totalCount = pkg.specialSpin.totalCount
        pb.specialSpin.AllWinCoin = pkg.specialSpin.AllWinCoin
        pb.specialSpin.extraSpin = pkg.specialSpin.extraSpin
        pb.specialSpin.trainType = pkg.specialSpin.trainType
        pb.specialSpin.slotMoneyGift = {}
        pb.specialSpin.slotMoneyGift.money_gift = pkg.specialSpin.slotMoneyGift.money_gift
        pb.specialSpin.slotMoneyGift.money_gift_safe = pkg.specialSpin.slotMoneyGift.money_gift_safe
        pb.specialSpin.slotMoneyGift.amount_of_gift = pkg.specialSpin.slotMoneyGift.amount_of_gift
        pb.specialSpin.slotMoney = {}
        pb.specialSpin.slotMoney.money = pkg.specialSpin.slotMoney.money
        pb.specialSpin.slotMoney.money_safe = pkg.specialSpin.slotMoney.money_safe
        pb.specialSpin.isFull = pkg.specialSpin.isFull
        return pb
    end
    return PkgHub.super.Pkg2Pb(self, pkg)
end

function PkgHub:Pb2Pkg(pb)
    if pb._msgName_ == 'PB.Client_Slots.EurekaTrainFreeSpin' then
        local pkg = PKG_Client_Slots_EurekaTrainFreeSpin.Create()
        return pkg
    elseif pb._msgName_ == 'PB.Client_Slots.EurekaTrainFreeType' then
        local pkg = PKG_Client_Slots_EurekaTrainFreeType.Create()
        pkg.type = pb.type
        return pkg
    elseif pb._msgName_ == 'PB.Client_Slots.EurekaTrainNormalSpin' then
        local pkg = PKG_Client_Slots_EurekaTrainNormalSpin.Create()
        pkg.betMoney = pb.betMoney
        pkg.lvID = pb.lvID
        pkg.moneyType = pb.moneyType
        return pkg
    elseif pb._msgName_ == 'PB.Client_Slots.EurekaTrainSpecialSpin' then
        local pkg = PKG_Client_Slots_EurekaTrainSpecialSpin.Create()
        return pkg
    end
    return PkgHub.super.Pb2Pkg(self, pb)
end

return PkgHub