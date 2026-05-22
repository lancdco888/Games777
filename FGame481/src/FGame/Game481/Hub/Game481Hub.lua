local super = require("FGame.Common.Special.Creator.DataHub.GameProtocolHub")
---@class Game481Hub extends GameProtocolHub
local Game481Hub = class("Game481Hub", super)

function Game481Hub:parseNormalSpinRet(aData)
    local ret = { 
        normalSpin = {
        }
    }
    ret._msgName_ = "PB.Slots_Client.GatesOfOlympusNormalRet"
    -- dump(aData,"parseNormalSpinRet::aData!!!!!!!!!")

    ret.normalSpin.slotMoneyGift = self:convertMoneyGift(aData)
    ret.normalSpin.slotMoney = self:convertMoney(aData)
    ret.normalSpin.levelUpMoney = aData.vip_level
    ret.normalSpin.levelUpMoneys = aData.level_ups

    ret.normalSpin.bet = aData.bet
    ret.normalSpin.winCoin = aData.win
    ret.normalSpin.results = self:parseResults(aData.results.array)
    ret.normalSpin.intoFree = aData.into_free

    return ret;
end


function Game481Hub:parseFreeSpinRet(aData)
    -- dump(aData,"parseFreeSpinRet",6)
    local ret = {
        freeSpin = {}
    }
    
    ret._msgName_ = "PB.Slots_Client.GatesOfOlympusFreeRet"

    ret.freeSpin.slotMoneyGift = self:convertMoneyGift(aData)
    ret.freeSpin.slotMoney = self:convertMoney(aData)

    ret.freeSpin.bet = aData.bet
    ret.freeSpin.winCoin = aData.win
    ret.freeSpin.bonusWinCoin = aData.total_win
    ret.freeSpin.totalFreeTime = aData.total_count
    ret.freeSpin.freeTime = aData.current_count
    ret.freeSpin.newFreeTime = aData.add_free_time
    ret.freeSpin.AccuScale = aData.accu_scale

    ret.freeSpin.results = self:parseResults(aData.results.array)

    return ret;
end


function Game481Hub:parseResumeData(aEnter, aEnterData, aResume)
    -- dump(aResume,"aResuuuuuuuuuuuuuuuuuume",6)
    -- dump(aResume,"aResuuuuuuuuuuuuuuuuuume")
    local resume = nil
    if aResume then
        resume = {}
        self:parseCommonResumeData(aEnterData,aResume,resume)
        
        resume.resumedNormal = nil
        if aResume.normal_spin_ret and aResume.normal_spin_ret ~= cjson.null then
            resume.resumedNormal = { normalSpin = {} }
            resume.resumedNormal.normalSpin = self:parseNormalSpinRet(aResume.normal_spin_ret).normalSpin
        end
        
        if aResume.free_spin_ret and aResume.free_spin_ret ~= cjson.null then
            resume.resumedFree = self:parseFreeSpinRet(aResume.free_spin_ret)
        end

        --[[ if aResume.last_state and aResume.last_state ~= cjson.null then
            local lastState = aResume.last_state
            if lastState and lastState.Gaming and type(lastState.Gaming.spin_state) == "table" then
                resume.accumulativeWin = lastState.Gaming.spin_state.Free.total_all_win
                resume.extraAward = aResume.extra_award
                -- dump(lastState.Gaming.spin_state.Free,"lastState.Gaming.spin_state.Freeeeeeeeeeeeeeee")
            end
        end ]]

        local currentWinCoin = 0

        local lastMsgType = 1
        if aResume.last_state and aResume.last_state ~= cjson.null then
            ---上一次状态
            local lastState = aResume.last_state.Gaming.spin_state
            ---当前状态
            local currentState = aEnter.state.Gaming.spin_state

             ---查询上一次状态
            if lastState == "Normal" then
                if currentState.Free and currentState.Free.current_count == 0 then
                    -- 进免费还未开始旋转
                    ---玩家身上的钱 start
                    -- print("!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!进免费还未开始旋转>>>>>>>>>")
                    resume.resumedNormal.normalSpin.slotMoney.money = aResume.normal_spin_ret.money - aResume.normal_spin_ret.win
                    aEnterData.enterMoney = resume.resumedNormal.normalSpin.slotMoney.money
                    currentWinCoin = aResume.normal_spin_ret.win
                    ---end  
                end
            elseif currentState.Free then
                lastMsgType  = 2
                -- 免费中
                ---显示累计的钱
                -- currentWinCoin = aResume.free_spin_ret.total_win + aResume.free_spin_ret.enter_win
                currentWinCoin = aResume.free_spin_ret.total_win
                ---玩家身上的钱
                -- aEnterData.enterMoney = resume.resumedFree.freeSpin.slotMoney.money - currentWinCoin
                aEnterData.enterMoney = aResume.free_spin_ret.money - currentWinCoin
            elseif lastState.Free and lastState.Free.total_count - lastState.Free.current_count == 1 then
                lastMsgType  = 2
                -- 免费最后一把结束
                ---显示累计的钱
                -- currentWinCoin = aResume.free_spin_ret.total_win + aResume.free_spin_ret.enter_win
                currentWinCoin = aResume.free_spin_ret.total_win
                ---玩家身上的钱
                resume.resumedFree.freeSpin.slotMoney.money = aResume.free_spin_ret.money
            end
        end
        resume.currentWinCoin = currentWinCoin
        print("currentWinCoin >>> ", currentWinCoin)
        resume.status = lastMsgType
        print("resume.status >>> ",resume.status)
    end
    -- dump(resume, "resume data")
    return resume
end


function Game481Hub:parseResults(results)
    -- dump(results,"Game481Hub:parseResults>>>>>>>>>>>>>>>>>>",6)
    local result = {
        array = {}
    }
    for key, value in ipairs(results) do
        result.array[key] = self:parseResult(value)
    end
    return result
end

function Game481Hub:parseGrids(grids)
    local res = {}

    for i, v in pairs(grids) do
        res[i] = {}

        res[i].index = v.index
        res[i].icon = v.icon
        res[i].value = v.symbol_value
    end
    
    return res
end

function Game481Hub:parseLineGrids(lineCells)
    local res = {}

    for i, v in pairs(grids) do

        res.index = v.index
    end

    return res
end

function Game481Hub:parseLines(lines)
    local res = {}

    for i, v in pairs(lines) do
        res[i] = {}

        res[i].lineIndex = v.line_index
        res[i].winCoin = v.win
        res[i].icon = v.icon
        res[i].lineCells = self:parseGrids(v.line_cells)

    end
    
    return res
end

function Game481Hub:parseResult(aData)
    return {
        grids = self:parseGrids(aData.grids),
        lines = self:parseLines(aData.lines)
    }
end

return Game481Hub
