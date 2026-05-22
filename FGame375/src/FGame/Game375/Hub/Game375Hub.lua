local super = require("FGame.Common.Special.Creator.DataHub.GameProtocolHub")
--@class Game375Hub : GameProtocolHub
local Game375Hub = class("Game375Hub", super)

function Game375Hub:parseNormalSpinRet(aData)
    local ret = { normalSpin = {} }
    ret._msgName_ = "PB.Slots_Client.HappyLanternNormalRet"

    ret.normalSpin.bet = aData.bet;
    ret.normalSpin.winCoin = aData.win;
    ret.normalSpin.freeType = aData.free_type;
    ret.normalSpin.freetime = aData.free_time;

    ret.normalSpin.slotMoneyGift = self:convertMoneyGift(aData)
    ret.normalSpin.slotMoney = self:convertMoney(aData);

    ret.normalSpin.levelUpMoney = aData.vip_level;
    ret.normalSpin.levelUpMoneys = aData.level_ups;

    ret.normalSpin.grids = {}
    for index, cell in ipairs(aData.grid) do
        ret.normalSpin.grids[index] = self:parseCell(cell)
    end
    
    ret.normalSpin.lines = {}
    for index, line in ipairs(aData.lines) do
        ret.normalSpin.lines[index] = self:parseLine(line)
    end
    return ret;
end

function Game375Hub:parseFreeSpinRet(aData)
    local ret = {}
    local spinret = {}
    ret._msgName_ = "PB.Slots_Client.HappyLanternFreeRet"
    --dump(aData,"===parseFreeSpinRet=====")
    spinret.bet = 0;
    spinret.winCoin = aData.win
    spinret.bonusWinCoin = 0
    if spinret.totalCount == spinret.allCount then
        spinret.bonusWinCoin = aData.total_win + aData.enter_win
    end

    spinret.slotMoneyGift = self:convertMoneyGift(aData)
    spinret.slotMoney = self:convertMoney(aData);

    spinret.grids = {}
    for index, value in ipairs(aData.grid) do
        spinret.grids[index] = self:parseCell(value)
    end

    spinret.lines = {};
    for index, line in ipairs(aData.lines) do
        spinret.lines[index] = self:parseLine(line)
    end

    spinret.allCount = aData.total_count;
    spinret.totalCount = aData.current_count
    spinret.addTime = aData.new_free_time

    ret.freeSpin = spinret

    return ret;
end

function Game375Hub:parseSpecialData(aData)
    local ret = {}
    local spinret = {}
    ret._msgName_ = "PB.Slots_Client.HappyLanternSpecialRet"
    --dump(aData,"===parseSpecialData=====")
    spinret.bet = 0;
    spinret.winCoin = aData.win

    spinret.grids = {}
    local bonusNumber = 0
    for index, value in ipairs(aData.grid) do
        if self:IsJpCard(value.icon) then
            bonusNumber = bonusNumber + 1
        end
        spinret.grids[index] = self:parseCell(value)
    end
    spinret.allCount = aData.total_count
    spinret.totalCount = aData.left_special_count
    if bonusNumber >= 15 then
        spinret.totalCount = 0
    end
    spinret.bonusWinCoin = aData.total_win + aData.enter_win

    spinret.lines = {}

    spinret.slotMoneyGift = self:convertMoneyGift(aData)
    spinret.slotMoney = self:convertMoney(aData)
    ret.specialSpin = spinret
    return ret
end

function Game375Hub:parseResumeData(aEnter, aEnterData, aResume)
    local resume = nil
    if aResume then
        resume = {}

        self:parseCommonResumeData(aEnterData,aResume,resume)

        resume.cells = {}
        resume.resumedNormal = nil
        if self:checkDataValide(aResume.normal_spin_ret) then
            resume.resumedNormal = { normalSpin = {} }
            resume.resumedNormal.normalSpin = self:parseNormalSpinRet(aResume.normal_spin_ret).normalSpin
        end
        
        if self:checkDataValide(aResume.free_spin_ret) then
            resume.resumedFree = self:parseFreeSpinRet(aResume.free_spin_ret)
        end

        if self:checkDataValide(aResume.special_spin_ret)then
            resume.resumedSpecial = self:parseSpecialData(aResume.special_spin_ret)
        end

        local currentWinCoin = 0
        --状态检查
        resume.type = 0
        --刚进入游戏并且没有做任何旋转操作的时候
        if not self:checkDataValide(aEnter.state) then
            return resume
        end
        local spin_state = aEnter.state.Gaming.spin_state
        dump(spin_state,"spin_state!!!!!!!!!!!!!")
        if type(spin_state) == "string" and spin_state == "Normal" then
            if self:checkDataValide(resume.resumedFree) then
                --免费最后一把
                resume.type = 3
                aEnterData.enterMoney = resume.resumedNormal.normalSpin.slotMoney.money + aResume.free_spin_ret.total_win
                resume.resumedFree.freeSpin.slotMoney.money = aEnterData.enterMoney
                currentWinCoin = aResume.free_spin_ret.total_win + aResume.free_spin_ret.enter_win
            else
                if self:checkDataValide(resume.resumedNormal) then
                    --当前状态普通，并且没有免费数据,有普通数据，代表普通中重连
                    if self:checkDataValide(resume.resumedSpecial) then
                        --有特殊游戏数据，代表普通中特殊游戏
                        resume.type = 4
                        aEnterData.enterMoney = resume.resumedNormal.normalSpin.slotMoney.money + aResume.special_spin_ret.total_win 
                        resume.resumedSpecial.specialSpin.slotMoney.money = aEnterData.enterMoney
                        currentWinCoin = aResume.special_spin_ret.total_win + aResume.special_spin_ret.enter_win
                    else
                        --没有特殊游戏数据，代表纯普通重连
                        resume.type = 1
                        --普通重连
                        aEnterData.enterMoney = resume.resumedNormal.normalSpin.slotMoney.money
                    end
                end
            end
        elseif spin_state.Free then
            --状态为Free时可能代表进入两种游戏，免费或者落地牌(特殊)
            --is_special_game：代表正在特殊游戏中
            if spin_state.Free.is_special_game then
                --普通中的特殊游戏
                if spin_state.Free.current_special_count == 0 then
                    --当前状态特殊，并且当前已转次数为0
                    --999服务器抽风，这个游戏特殊点，currentWinCoin没有加落地牌卡牌上的钱
                    if spin_state.Free.is_select_game_type then
                        resume.type = 2
                    else
                        resume.type = 1
                    end
                    currentWinCoin = resume.resumedNormal.normalSpin.winCoin --+ self:AllBonusValue(resume.resumedNormal.normalSpin.grids)
                else
                    --当前状态特殊，并且当前已转次数不为0，代表特殊中重连
                    resume.type = 4
                    currentWinCoin = resume.resumedNormal.normalSpin.winCoin + self:AllBonusValue(resume.resumedSpecial.specialSpin.grids)
                end
            else
                --当前为免费游戏
                if spin_state.Free.current_count == 0 then
                    --当前状态免费，并且当前已转次数为0
                    if spin_state.Free.is_select_game_type then
                        resume.type = 2
                    else
                        resume.type = 1
                    end
                    currentWinCoin = resume.resumedNormal.normalSpin.winCoin
                else
                    --当前状态免费，并且当前已转次数不为0，代表免费中重连
                    resume.type = 3
                    currentWinCoin = spin_state.Free.total_all_win + aResume.free_spin_ret.enter_win
                end
            end
            --玩家身上的钱
            aEnterData.enterMoney = resume.resumedNormal.normalSpin.slotMoney.money - resume.resumedNormal.normalSpin.winCoin
        end
        resume.currentWinCoin = currentWinCoin
    end
    return resume
end

function Game375Hub:parseFreeSpinType(aData)
    local ret = {}
    
    ret._msgName_ = "PB.Slots_Client.HappyLanternFreeTypeRet"
    return ret
end

function Game375Hub:parseCell(cell)
    return {
        index = cell.index,
        icon = cell.icon,
        SymbolValue = cell.symbol_value,
        Symbolbet = cell.symbol_bet,
        SymbolType = cell.symbol_type,
    }
end

function Game375Hub:parseLine(line)
    local data = {}
    data.lineIndex = line.line_index
    data.winCoin = line.win
    data.icon = line.icon
    data.lineCells = {}
    for index, cell in ipairs(line.line_cells) do
        data.lineCells[index] = self:parseCell(cell)
    end
    return data
end

function Game375Hub:AllBonusValue(grids)
    local valuemoney = 0
    for key, value in ipairs(grids) do
        valuemoney =valuemoney + value.SymbolValue
    end
    return valuemoney
end

--是否是落地牌
function Game375Hub:IsJpCard(icon)
    return icon == 3
end

return Game375Hub
