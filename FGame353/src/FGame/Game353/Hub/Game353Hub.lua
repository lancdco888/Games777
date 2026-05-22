local super = require("FGame.Common.Special.Creator.DataHub.GameProtocolHub")
---@class Game353Hub : GameProtocolHub
local Game353Hub = class("Game353Hub", super)

function Game353Hub:parseNormalSpinRet(aData,collect_indexes)
    local ret = { normalSpin = {} }
    dump(aData, "parseNormalSpinRet", 10)
    ret._msgName_ = "PB.Slots_Client.BuffaloNormalRet"
    
    ret.normalSpin.bet = aData.bet
    ret.normalSpin.winCoin = aData.win
    ret.normalSpin.intoFree = aData.is_into_free and 1 or 0

    ret.normalSpin.slotMoneyGift = self:convertMoneyGift(aData)

    ret.normalSpin.slotMoney = self:convertMoney(aData)

    ret.normalSpin.levelUpMoney = aData.vip_level;
    ret.normalSpin.levelUpMoneys = aData.level_ups;


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
    -- dump(ret,">>>>>>>>>>>>>>>>>>>>>Game353NormalSpinRes")
    return ret;
end
function Game353Hub:parseFreeSpinType(aData,isrecover)
    --断线重连不清空点击列表isrecover
    if not isrecover then
        print("发送免费类型包时清空点击列表*****")
        self:setRestore12X3Data({})
    end
    dump(aData, "parseFreeSpinType")
    local ret = {}
    ret._msgName_ = "PB.Slots_Client.BuffaloFreeRetType"
    ret.freeType = { 
        freeTime =aData.context.free_time  ,
        ohterlist =aData.context.other_list  ,
        openlist =aData.context.open_list  ,
    }
    return ret
end
function Game353Hub:parseFreeSpinRet(aData,collect_indexes)
    dump(aData,"Game353Hub:parseFreeSpinRet:aData",10)
    local ret = {}
    local spinret = {}
    ret._msgName_ = "PB.Slots_Client.BuffaloFreeRet"
    spinret.bet = 0;
    spinret.winCoin = aData.win;

    spinret.allCount = aData.total_count;
    spinret.totalCount = aData.current_count
    --todo:服务器没有给
    spinret.bonusWinCoin = aData.win
    spinret.addTime = aData.new_free_time
    spinret.slotMoneyGift = self:convertMoneyGift(aData)

    spinret.slotMoney = self:convertMoney(aData)
    print("freespinret.slotMoney>>>>>>>>>>>>>>>!!!!!!!!!!::"..spinret.slotMoney.money)

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
    ret.freeSpin = spinret
    return ret;
end
--判断是不是正常模式
function Game353Hub:IsNormalState(last_state)
    if type(last_state) == "string" and last_state == "Normal" then
        return true
    end
    return false
end
function Game353Hub:parseResumeData(aEnter, aEnterData, aResume)
     dump(aResume,"Game353Hub:parseResumeData::aResume",6)
         dump(aEnter,"Game353Hub:parseResumeData::aEnter",6)
    -- dump(aEnterData,"Game353Hub:parseResumeData::aEnterData",3)
    local resumeData = nil
    print("断线重连判断")
    if aResume then
        resumeData = {}
        self:parseCommonResumeData(aEnterData,aResume,resumeData)
        resumeData.cells = {}
        if self:checkDataValide(aResume.collect_indexes) then
            resumeData.cells = aResume.collect_indexes
            self:setRestore12X3Data(aResume.collect_indexes)
        end
        resumeData.resumedNormal = nil
        if self:checkDataValide(aResume.normal_spin_ret) then
            resumeData.resumedNormal = { normalSpin = {} }
            resumeData.resumedNormal.normalSpin = self:parseNormalSpinRet(aResume.normal_spin_ret,aResume.collect_indexes).normalSpin
        end
        
        if self:checkDataValide(aResume.free_spin_ret) then
            resumeData.resumedFree = self:parseFreeSpinRet(aResume.free_spin_ret,aResume.collect_indexes)
        end

        local currentWinCoin = 0
        
        --状态检查
        resumeData.type = 0
        if self:checkDataValide(aResume.last_state) and self:checkDataValide(aEnter.state) then
            print("状态检查********")
            local last_state = aResume.last_state.Gaming.spin_state
            local current_state = aEnter.state.Gaming.spin_state
            --上一把是正常
            if self:IsNormalState(last_state) then
                --这一波是正常
                if self:IsNormalState(current_state) then
                    print("currentState == Normal >>>>正常模式不做处理")
                    resumeData.type = 1
                --这一把是免费或者特殊
                elseif current_state.Free then
                    print("普通进入免费状态检查********")
                    self:checkFreeState(current_state.Free,aResume,resumeData)
                end
            --上把是免费（包括小游戏模式）    
            elseif last_state.Free then
                if self:IsNormalState(current_state) then
                    resumeData.type = 1
                    resumeData.resumedNormal.normalSpin.intoFree = 0
                    resumeData.resumedNormal.normalSpin.slotMoney.money = resumeData.enterBase.enterMoney
                elseif current_state.Free then
                    self:checkFreeState(current_state.Free,aResume,resumeData)
                end
            end
        end
        print("resumeData.currentWinCoin>>>>>>>>>>>>>>!!!!!!!!!",resumeData.currentWinCoin)
    end
    return resumeData
end
--判断免费情况中的特殊情况
function Game353Hub:checkFreeState(currData,LastData,resume)
    print("判断免费情况中的特殊情况")
    --设置上一轮金币
    resume.currentWinCoin = currData.total_all_win +  currData.enter_win
    print("resume.currentWinCoin",resume.currentWinCoin)
    --免费游戏总次数大于零
    --免费游戏总次数等于0 选择类型没有发送
    print("currData.total_count",currData.total_count)
    if currData.total_count == 0 then
        print("断线重连进入免费选择界面")
        resume.type = 1
        resume.enterBase.enterMoney = resume.resumedNormal.normalSpin.slotMoney.money -  currData.enter_win
    --免费游戏总次数大于零
    elseif currData.total_count > 0 then
        print("免费游戏总次数大于零")
        resume.freeType =  self:parseFreeSpinType({context = LastData.free_spin_type_ret},true)
        --如果不是免费游戏的最后一把
        if  currData.current_count < currData.total_count then
            resume.enterBase.enterMoney = resume.resumedNormal.normalSpin.slotMoney.money-  currData.enter_win
        end
        if currData.current_count == 0 then
            --普通中奖免费
            resume.type = 2
        else
            resume.resumedNormal.normalSpin.intoFree = 0
            resume.type = 3
            if resume.resumedFree.freeSpin.intoCollect == 1 then
                --resume.currentWinCoin = resume.currentWinCoin + self:GetSpecialWin(resume.resumedFree.freeSpin.lines)
                print("免费中中奖特殊游戏 currentWinCoin",resume.currentWinCoin)
            end
        end
    end
end
function Game353Hub:parseGrids(aData)
    local result = {}
    for key, value in ipairs(aData) do
        result[key] = self:parseGrid(value)
    end
    return result
end

function Game353Hub:parseGrid(aData)
    return {
        index = aData.index,
        icon = aData.icon,
    }
end
return Game353Hub
