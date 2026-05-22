local super = require("FGame.Common.Special.Creator.DataHub.GameProtocolHub")
---@class Game465Hub : GameProtocolHub
local Game465Hub = class("Game465Hub", super)

function Game465Hub:parseNormalSpinRet(aData)
    local ret = { normalSpin = {} }
    ret._msgName_ = "PB.Slots_Client.dragons5NormalRet"
    
    ret.normalSpin.bet = aData.bet
    ret.normalSpin.winCoin = aData.win
    ret.normalSpin.intoFree = aData.is_free_game and 1 or 0
    ret.normalSpin.levelUpMoney = aData.vip_level;
    ret.normalSpin.levelUpMoneys = aData.level_ups;
    ret.normalSpin.slotMoneyGift = self:convertMoneyGift(aData)
    ret.normalSpin.slotMoney = self:convertMoney(aData)

    ret.normalSpin.grids = {}
    for index, value in ipairs(aData.grid) do
        ret.normalSpin.grids[index] = self:parseGrid(value)
    end

    ret.normalSpin.lines = {};
    for index, value in ipairs(aData.lines) do
        table.insert(ret.normalSpin.lines, {
            lineIndex = value.line_index,
            winCoin = value.win,
            icon = value.icon,
            lineCells = self:parseGrids(value.line_cells),
        })
    end
    return ret;
end

function Game465Hub:parseResumeFreeSpinType(index)
    local ret = {}
    ret._msgName_ = "PB.Slots_Client.dragons5FreeRetType"
    local list = {[1] = 25,[2] = 20,[3] = 15,[4] = 13,[5] = 10, [6] = 0}
    ret.freeType = {
        type = list[index],
    }
    return ret
end

function Game465Hub:parseFreeSpinType(aData)
    dump(aData, "-----------------parseFreeSpinType")
    local ret = {}
    ret._msgName_ = "PB.Slots_Client.dragons5FreeRetType"
    local list = {[1] = 25,[2] = 20,[3] = 15,[4] = 13,[5] = 10}
    ret.freeType = {
        type = list[aData._typeid_],
    }
    return ret
end

function Game465Hub:parseFreeSpinRet(aData)
    local ret = {}
    local spinret = {}
    ret._msgName_ = "PB.Slots_Client.dragons5FreeRet"

    spinret.bet = 0
    spinret.wildBet = aData.wild_bet;
    spinret.winCoin = aData.win;
    spinret.intoCollect = 0
    spinret.bonusWinCoin = 0
    if spinret.totalCount == spinret.allCount then
        spinret.bonusWinCoin = aData.enter_win + aData.total_win
    end

    spinret.allCount = aData.total_count;
    spinret.totalCount = aData.current_count
    spinret.addTime = aData.total_round - aData.current_round

    spinret.slotMoneyGift = self:convertMoneyGift(aData)

    spinret.slotMoney = self:convertMoney(aData)

    spinret.grids = {}
    for index, value in ipairs(aData.grid) do
        spinret.grids[index] = self:parseGrid(value)
    end

    spinret.lines = {};
    for index, value in ipairs(aData.lines) do
        table.insert(spinret.lines, {
            lineIndex = value.line_index,
            winCoin = value.win,
            icon = value.icon,
            lineCells = self:parseGrids(value.line_cells),
        })
    end

    spinret.newFreeTime = aData.new_free_time > 0 and 1 or 0

    ret.freeSpin = spinret
    return ret;
end

function Game465Hub:parseResumeData(aEnter, aEnterData, aResume)
    local resume = nil
    if aResume then
        resume = {}

        self:parseCommonResumeData(aEnterData,aResume,resume)
        
        resume.resumedNormal = nil
        if self:checkDataValide(aResume.normal_spin_ret) then
            resume.resumedNormal = self:parseNormalSpinRet(aResume.normal_spin_ret)
        end
        
        if self:checkDataValide(aResume.free_spin_ret) then
            resume.resumedFree = self:parseFreeSpinRet(aResume.free_spin_ret)
        end

        local currentWinCoin = 0
        --状态检查
        resume.type = 0
        local spin_state = aEnter.state.Gaming.spin_state
        dump(spin_state,"spin_state!!!!!!!!!!!!!")
        if type(spin_state) == "string" and spin_state == "Normal" then
            if self:checkDataValide(resume.resumedFree) then
                --当前状态普通，并且有免费数据，代表最后一把重连
                resume.type = 3
                resume.freeType = self:parseResumeFreeSpinType(6)
                --免费最后一把结束
                aEnterData.enterMoney = resume.resumedNormal.normalSpin.slotMoney.money + aResume.free_spin_ret.total_win
                resume.resumedFree.freeSpin.slotMoney.money = aEnterData.enterMoney
                currentWinCoin = aResume.free_spin_ret.total_win + aResume.free_spin_ret.enter_win
            else
                if self:checkDataValide(resume.resumedNormal) then
                    --当前状态普通，并且没有免费数据,有普通数据，代表普通中重连
                    resume.type = 1
                    --普通重连
                    aEnterData.enterMoney = resume.resumedNormal.normalSpin.slotMoney.money
                end
            end
        elseif spin_state.Free then
            if spin_state.Free.current_count == 0 then
                --当前状态免费，并且当前已转次数为0
                if spin_state.Free.last_select_free_spin_type <= -1 then
                    --选择状态为-1代表还未选择次数
                    resume.type = 1
                    currentWinCoin = resume.resumedNormal.normalSpin.winCoin
                else
                    --选择状态大于-1代表已选择次数
                    resume.freetime = spin_state.Free.left_total_round
                    resume.freeType = self:parseResumeFreeSpinType(spin_state.Free.last_select_free_spin_type)
                    if self:checkDataValide(aResume.free_spin_ret) then
                        currentWinCoin = spin_state.Free.total_all_win + aResume.free_spin_ret.enter_win
                        resume.type = 3
                        resume.resumedFree.freeSpin.totalCount = 0
                        resume.resumedFree.freeSpin.allCount = resume.freeType.freeType.type
                    else
                        currentWinCoin = resume.resumedNormal.normalSpin.winCoin
                        resume.type = 2
                    end
                end
            else
                --当前状态免费，并且当前已转次数不为0，代表免费中重连
                resume.type = 3
                resume.freetime = spin_state.Free.left_total_round
                resume.freeType = self:parseResumeFreeSpinType(spin_state.Free.last_select_free_spin_type)
                --免费中12x3已结束
                currentWinCoin = spin_state.Free.total_all_win + aResume.free_spin_ret.enter_win
            end
            --玩家身上的钱
            aEnterData.enterMoney = resume.resumedNormal.normalSpin.slotMoney.money - resume.resumedNormal.normalSpin.winCoin
        end
        resume.currentWinCoin = currentWinCoin
    end
    return resume
end

function Game465Hub:parseGrids(aData)
    local result = {}
    for key, value in ipairs(aData) do
        result[key] = self:parseGrid(value)
    end
    return result
end

function Game465Hub:parseGrid(aData)
    return {
        index = aData.index,
        icon = aData.icon,
    }
end

return Game465Hub
