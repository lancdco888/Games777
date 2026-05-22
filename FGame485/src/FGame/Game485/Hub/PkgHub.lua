local PkgHub = class("PkgHub", FBasePkgHub)

function PkgHub:ctor(...)
    PkgHub.super.ctor(self, ...)
    self.protoMap = {
        ['PKG_Slots_Client_SyncPlayerStates'] = 'PB.Slots_Client.SyncPlayerStates',
        ['PKG_Slots_Client_Leave_Success'] = 'PB.Slots_Client.Leave_Success',
        ['PKG_Slots_Client_CollectValue'] = 'PB.Slots_Client.CollectValue',
        ['PKG_Client_Slots_FireLinkNormalSpin'] = 'PB.Client_Slots.FireLinkNormalSpin',
        ['PKG_Slots_Client_FireLinkSpecialRet'] = 'PB.Slots_Client.FireLinkSpecialRet',
        ['PKG_Client_Slots_FireLinkSelectType'] = 'PB.Client_Slots.FireLinkSelectType',
        ['PKG_Slots_Client_FireLinkNormalRet'] = 'PB.Slots_Client.FireLinkNormalRet',
        ['PKG_Slots_Client_FireLinkFreeRet'] = 'PB.Slots_Client.FireLinkFreeRet',
        ['PKG_Slots_Client_FireLinkEnterResumed'] = 'PB.Slots_Client.FireLinkEnterResumed',
        ['PKG_Slots_Client_OfflineCheck'] = 'PB.Slots_Client.OfflineCheck',
        ['PKG_Client_Slots_FireLinkFreeSpin'] = 'PB.Client_Slots.FireLinkFreeSpin',
        ['PKG_Slots_Client_FireLinkSelectRet'] = 'PB.Slots_Client.FireLinkSelectRet',
        ['PKG_Slots_Client_LockLeaveSuccess'] = 'PB.Slots_Client.LockLeaveSuccess',
        ['PKG_Slots_Client_Enter_Success'] = 'PB.Slots_Client.Enter_Success',
        ['PKG_Client_Slots_FireLinkSpecialSpin'] = 'PB.Client_Slots.FireLinkSpecialSpin',
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
    elseif pkg.typeName == 'PKG_Slots_Client_FireLinkSpecialRet' then
        pb.specialSpin = {}
        pb.specialSpin.betMoney = pkg.specialSpin.betMoney
        pb.specialSpin.slotMoneyGift = {}
        pb.specialSpin.slotMoneyGift.money_gift = pkg.specialSpin.slotMoneyGift.money_gift
        pb.specialSpin.slotMoneyGift.money_gift_safe = pkg.specialSpin.slotMoneyGift.money_gift_safe
        pb.specialSpin.slotMoneyGift.amount_of_gift = pkg.specialSpin.slotMoneyGift.amount_of_gift
        pb.specialSpin.slotMoney = {}
        pb.specialSpin.slotMoney.money = pkg.specialSpin.slotMoney.money
        pb.specialSpin.slotMoney.money_safe = pkg.specialSpin.slotMoney.money_safe
        pb.specialSpin.grids = {}
        
        for ik, iv in pairs(pkg.specialSpin.grids) do
            pb.specialSpin.grids[ik] = {}
            pb.specialSpin.grids[ik].index = iv.index
            pb.specialSpin.grids[ik].icon = iv.icon
            pb.specialSpin.grids[ik].symbolType = iv.symbolType
            pb.specialSpin.grids[ik].symbolValue = iv.symbolValue
        end
        
        pb.specialSpin.lines = {}
        
        for ik, iv in pairs(pkg.specialSpin.lines) do
            pb.specialSpin.lines[ik] = {}
            pb.specialSpin.lines[ik].lineIndex = iv.lineIndex
            pb.specialSpin.lines[ik].winCoin = iv.winCoin
            pb.specialSpin.lines[ik].icon = iv.icon
            pb.specialSpin.lines[ik].lineCells = {}
            
            for jk, jv in pairs(iv.lineCells) do
                pb.specialSpin.lines[ik].lineCells[jk] = {}
                pb.specialSpin.lines[ik].lineCells[jk].index = jv.index
                pb.specialSpin.lines[ik].lineCells[jk].icon = jv.icon
                pb.specialSpin.lines[ik].lineCells[jk].symbolType = jv.symbolType
                pb.specialSpin.lines[ik].lineCells[jk].symbolValue = jv.symbolValue
            end
        end
        
        pb.specialSpin.winCoin = pkg.specialSpin.winCoin
        pb.specialSpin.lottyGameRestCount = pkg.specialSpin.lottyGameRestCount
        pb.specialSpin.totalWinCoin = pkg.specialSpin.totalWinCoin
        return pb
    elseif pkg.typeName == 'PKG_Slots_Client_FireLinkNormalRet' then
        pb.normalSpin = {}
        pb.normalSpin.betMoney = pkg.normalSpin.betMoney
        pb.normalSpin.slotMoneyGift = {}
        pb.normalSpin.slotMoneyGift.money_gift = pkg.normalSpin.slotMoneyGift.money_gift
        pb.normalSpin.slotMoneyGift.money_gift_safe = pkg.normalSpin.slotMoneyGift.money_gift_safe
        pb.normalSpin.slotMoneyGift.amount_of_gift = pkg.normalSpin.slotMoneyGift.amount_of_gift
        pb.normalSpin.slotMoney = {}
        pb.normalSpin.slotMoney.money = pkg.normalSpin.slotMoney.money
        pb.normalSpin.slotMoney.money_safe = pkg.normalSpin.slotMoney.money_safe
        pb.normalSpin.levelUpMoney = pkg.normalSpin.levelUpMoney
        pb.normalSpin.levelUpMoneys = pkg.normalSpin.levelUpMoneys
        pb.normalSpin.grids = {}
        
        for ik, iv in pairs(pkg.normalSpin.grids) do
            pb.normalSpin.grids[ik] = {}
            pb.normalSpin.grids[ik].index = iv.index
            pb.normalSpin.grids[ik].icon = iv.icon
            pb.normalSpin.grids[ik].symbolType = iv.symbolType
            pb.normalSpin.grids[ik].symbolValue = iv.symbolValue
        end
        
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
                pb.normalSpin.lines[ik].lineCells[jk].symbolType = jv.symbolType
                pb.normalSpin.lines[ik].lineCells[jk].symbolValue = jv.symbolValue
            end
        end
        
        pb.normalSpin.winCoin = pkg.normalSpin.winCoin
        pb.normalSpin.intoFree = pkg.normalSpin.intoFree
        pb.normalSpin.intoSpecial = pkg.normalSpin.intoSpecial
        return pb
    elseif pkg.typeName == 'PKG_Slots_Client_FireLinkFreeRet' then
        pb.freeSpin = {}
        pb.freeSpin.betMoney = pkg.freeSpin.betMoney
        pb.freeSpin.slotMoneyGift = {}
        pb.freeSpin.slotMoneyGift.money_gift = pkg.freeSpin.slotMoneyGift.money_gift
        pb.freeSpin.slotMoneyGift.money_gift_safe = pkg.freeSpin.slotMoneyGift.money_gift_safe
        pb.freeSpin.slotMoneyGift.amount_of_gift = pkg.freeSpin.slotMoneyGift.amount_of_gift
        pb.freeSpin.slotMoney = {}
        pb.freeSpin.slotMoney.money = pkg.freeSpin.slotMoney.money
        pb.freeSpin.slotMoney.money_safe = pkg.freeSpin.slotMoney.money_safe
        pb.freeSpin.grids = {}
        
        for ik, iv in pairs(pkg.freeSpin.grids) do
            pb.freeSpin.grids[ik] = {}
            pb.freeSpin.grids[ik].index = iv.index
            pb.freeSpin.grids[ik].icon = iv.icon
            pb.freeSpin.grids[ik].symbolType = iv.symbolType
            pb.freeSpin.grids[ik].symbolValue = iv.symbolValue
        end
        
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
                pb.freeSpin.lines[ik].lineCells[jk].symbolType = jv.symbolType
                pb.freeSpin.lines[ik].lineCells[jk].symbolValue = jv.symbolValue
            end
        end
        
        pb.freeSpin.winCoin = pkg.freeSpin.winCoin
        pb.freeSpin.intoFree = pkg.freeSpin.intoFree
        pb.freeSpin.freeGameTotalCount = pkg.freeSpin.freeGameTotalCount
        pb.freeSpin.freeGameCurCount = pkg.freeSpin.freeGameCurCount
        pb.freeSpin.totalWinCoin = pkg.freeSpin.totalWinCoin
        pb.freeSpin.scale = pkg.freeSpin.scale
        return pb
    elseif pkg.typeName == 'PKG_Slots_Client_FireLinkEnterResumed' then
        pb.lvID = pkg.lvID
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
        pb.resumedNormal.normalSpin.betMoney = pkg.resumedNormal.normalSpin.betMoney
        pb.resumedNormal.normalSpin.slotMoneyGift = {}
        pb.resumedNormal.normalSpin.slotMoneyGift.money_gift = pkg.resumedNormal.normalSpin.slotMoneyGift.money_gift
        pb.resumedNormal.normalSpin.slotMoneyGift.money_gift_safe = pkg.resumedNormal.normalSpin.slotMoneyGift.money_gift_safe
        pb.resumedNormal.normalSpin.slotMoneyGift.amount_of_gift = pkg.resumedNormal.normalSpin.slotMoneyGift.amount_of_gift
        pb.resumedNormal.normalSpin.slotMoney = {}
        pb.resumedNormal.normalSpin.slotMoney.money = pkg.resumedNormal.normalSpin.slotMoney.money
        pb.resumedNormal.normalSpin.slotMoney.money_safe = pkg.resumedNormal.normalSpin.slotMoney.money_safe
        pb.resumedNormal.normalSpin.levelUpMoney = pkg.resumedNormal.normalSpin.levelUpMoney
        pb.resumedNormal.normalSpin.levelUpMoneys = pkg.resumedNormal.normalSpin.levelUpMoneys
        pb.resumedNormal.normalSpin.grids = {}
        
        for ik, iv in pairs(pkg.resumedNormal.normalSpin.grids) do
            pb.resumedNormal.normalSpin.grids[ik] = {}
            pb.resumedNormal.normalSpin.grids[ik].index = iv.index
            pb.resumedNormal.normalSpin.grids[ik].icon = iv.icon
            pb.resumedNormal.normalSpin.grids[ik].symbolType = iv.symbolType
            pb.resumedNormal.normalSpin.grids[ik].symbolValue = iv.symbolValue
        end
        
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
                pb.resumedNormal.normalSpin.lines[ik].lineCells[jk].symbolType = jv.symbolType
                pb.resumedNormal.normalSpin.lines[ik].lineCells[jk].symbolValue = jv.symbolValue
            end
        end
        
        pb.resumedNormal.normalSpin.winCoin = pkg.resumedNormal.normalSpin.winCoin
        pb.resumedNormal.normalSpin.intoFree = pkg.resumedNormal.normalSpin.intoFree
        pb.resumedNormal.normalSpin.intoSpecial = pkg.resumedNormal.normalSpin.intoSpecial
        pb.resumedFree = {}
        pb.resumedFree.freeSpin = {}
        pb.resumedFree.freeSpin.betMoney = pkg.resumedFree.freeSpin.betMoney
        pb.resumedFree.freeSpin.slotMoneyGift = {}
        pb.resumedFree.freeSpin.slotMoneyGift.money_gift = pkg.resumedFree.freeSpin.slotMoneyGift.money_gift
        pb.resumedFree.freeSpin.slotMoneyGift.money_gift_safe = pkg.resumedFree.freeSpin.slotMoneyGift.money_gift_safe
        pb.resumedFree.freeSpin.slotMoneyGift.amount_of_gift = pkg.resumedFree.freeSpin.slotMoneyGift.amount_of_gift
        pb.resumedFree.freeSpin.slotMoney = {}
        pb.resumedFree.freeSpin.slotMoney.money = pkg.resumedFree.freeSpin.slotMoney.money
        pb.resumedFree.freeSpin.slotMoney.money_safe = pkg.resumedFree.freeSpin.slotMoney.money_safe
        pb.resumedFree.freeSpin.grids = {}
        
        for ik, iv in pairs(pkg.resumedFree.freeSpin.grids) do
            pb.resumedFree.freeSpin.grids[ik] = {}
            pb.resumedFree.freeSpin.grids[ik].index = iv.index
            pb.resumedFree.freeSpin.grids[ik].icon = iv.icon
            pb.resumedFree.freeSpin.grids[ik].symbolType = iv.symbolType
            pb.resumedFree.freeSpin.grids[ik].symbolValue = iv.symbolValue
        end
        
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
                pb.resumedFree.freeSpin.lines[ik].lineCells[jk].symbolType = jv.symbolType
                pb.resumedFree.freeSpin.lines[ik].lineCells[jk].symbolValue = jv.symbolValue
            end
        end
        
        pb.resumedFree.freeSpin.winCoin = pkg.resumedFree.freeSpin.winCoin
        pb.resumedFree.freeSpin.intoFree = pkg.resumedFree.freeSpin.intoFree
        pb.resumedFree.freeSpin.freeGameTotalCount = pkg.resumedFree.freeSpin.freeGameTotalCount
        pb.resumedFree.freeSpin.freeGameCurCount = pkg.resumedFree.freeSpin.freeGameCurCount
        pb.resumedFree.freeSpin.totalWinCoin = pkg.resumedFree.freeSpin.totalWinCoin
        pb.resumedFree.freeSpin.scale = pkg.resumedFree.freeSpin.scale
        pb.resumedSpecial = {}
        pb.resumedSpecial.specialSpin = {}
        pb.resumedSpecial.specialSpin.betMoney = pkg.resumedSpecial.specialSpin.betMoney
        pb.resumedSpecial.specialSpin.slotMoneyGift = {}
        pb.resumedSpecial.specialSpin.slotMoneyGift.money_gift = pkg.resumedSpecial.specialSpin.slotMoneyGift.money_gift
        pb.resumedSpecial.specialSpin.slotMoneyGift.money_gift_safe = pkg.resumedSpecial.specialSpin.slotMoneyGift.money_gift_safe
        pb.resumedSpecial.specialSpin.slotMoneyGift.amount_of_gift = pkg.resumedSpecial.specialSpin.slotMoneyGift.amount_of_gift
        pb.resumedSpecial.specialSpin.slotMoney = {}
        pb.resumedSpecial.specialSpin.slotMoney.money = pkg.resumedSpecial.specialSpin.slotMoney.money
        pb.resumedSpecial.specialSpin.slotMoney.money_safe = pkg.resumedSpecial.specialSpin.slotMoney.money_safe
        pb.resumedSpecial.specialSpin.grids = {}
        
        for ik, iv in pairs(pkg.resumedSpecial.specialSpin.grids) do
            pb.resumedSpecial.specialSpin.grids[ik] = {}
            pb.resumedSpecial.specialSpin.grids[ik].index = iv.index
            pb.resumedSpecial.specialSpin.grids[ik].icon = iv.icon
            pb.resumedSpecial.specialSpin.grids[ik].symbolType = iv.symbolType
            pb.resumedSpecial.specialSpin.grids[ik].symbolValue = iv.symbolValue
        end
        
        pb.resumedSpecial.specialSpin.lines = {}
        
        for ik, iv in pairs(pkg.resumedSpecial.specialSpin.lines) do
            pb.resumedSpecial.specialSpin.lines[ik] = {}
            pb.resumedSpecial.specialSpin.lines[ik].lineIndex = iv.lineIndex
            pb.resumedSpecial.specialSpin.lines[ik].winCoin = iv.winCoin
            pb.resumedSpecial.specialSpin.lines[ik].icon = iv.icon
            pb.resumedSpecial.specialSpin.lines[ik].lineCells = {}
            
            for jk, jv in pairs(iv.lineCells) do
                pb.resumedSpecial.specialSpin.lines[ik].lineCells[jk] = {}
                pb.resumedSpecial.specialSpin.lines[ik].lineCells[jk].index = jv.index
                pb.resumedSpecial.specialSpin.lines[ik].lineCells[jk].icon = jv.icon
                pb.resumedSpecial.specialSpin.lines[ik].lineCells[jk].symbolType = jv.symbolType
                pb.resumedSpecial.specialSpin.lines[ik].lineCells[jk].symbolValue = jv.symbolValue
            end
        end
        
        pb.resumedSpecial.specialSpin.winCoin = pkg.resumedSpecial.specialSpin.winCoin
        pb.resumedSpecial.specialSpin.lottyGameRestCount = pkg.resumedSpecial.specialSpin.lottyGameRestCount
        pb.resumedSpecial.specialSpin.totalWinCoin = pkg.resumedSpecial.specialSpin.totalWinCoin
        pb.resumedSelect = {}
        pb.resumedSelect.selectType = {}
        pb.resumedSelect.selectType.type = pkg.resumedSelect.selectType.type
        pb.resumedSelect.selectType.times = pkg.resumedSelect.selectType.times
        pb.resumedSelect.selectType.scales = pkg.resumedSelect.selectType.scales
        pb.lastMsgType = pkg.lastMsgType
        return pb
    elseif pkg.typeName == 'PKG_Slots_Client_OfflineCheck' then
        return pb
    elseif pkg.typeName == 'PKG_Slots_Client_FireLinkSelectRet' then
        pb.selectType = {}
        pb.selectType.type = pkg.selectType.type
        pb.selectType.times = pkg.selectType.times
        pb.selectType.scales = pkg.selectType.scales
        return pb
    elseif pkg.typeName == 'PKG_Slots_Client_LockLeaveSuccess' then
        return pb
    end
    return PkgHub.super.Pkg2Pb(self, pkg)
end

function PkgHub:Pb2Pkg(pb)
    if pb._msgName_ == 'PB.Client_Slots.FireLinkNormalSpin' then
        local pkg = PKG_Client_Slots_FireLinkNormalSpin.Create()
        pkg.betMoney = pb.betMoney
        pkg.lvID = pb.lvID
        pkg.moneyType = pb.moneyType
        return pkg
    elseif pb._msgName_ == 'PB.Client_Slots.FireLinkSelectType' then
        local pkg = PKG_Client_Slots_FireLinkSelectType.Create()
        pkg.type = pb.type
        return pkg
    elseif pb._msgName_ == 'PB.Client_Slots.FireLinkFreeSpin' then
        local pkg = PKG_Client_Slots_FireLinkFreeSpin.Create()
        return pkg
    elseif pb._msgName_ == 'PB.Client_Slots.FireLinkSpecialSpin' then
        local pkg = PKG_Client_Slots_FireLinkSpecialSpin.Create()
        return pkg
    end
    return PkgHub.super.Pb2Pkg(self, pb)
end

return PkgHub