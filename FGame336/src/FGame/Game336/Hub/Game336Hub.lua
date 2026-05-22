local super = require("FGame.Common.Special.Creator.DataHub.GameProtocolHub")
---@class Game336Hub extends GameProtocolHub
local Game336Hub = class("Game336Hub", super)

function Game336Hub:parseNormalSpinRet(aData)
    dump(aData, "parseNormalSpinRet", 10)
    local ret = { normalSpin = {} }
    ret._msgName_ = "PB.Slots_Client.DragonGiftNormalRet"


    ret.normalSpin.bet = aData.bet;
    ret.normalSpin.curWinCoin = aData.win;
    ret.normalSpin.intoFree = aData.is_into_free and 1 or 0;
    ret.normalSpin.intoSpecial = aData.is_into_special and 1 or 0;

    ret.normalSpin.wildBet = 0;

    ret.normalSpin.slotMoneyGift = self:convertMoneyGift(aData)

    ret.normalSpin.slotMoney = self:convertMoney(aData);

   -- ret.normalSpin.levelUpMoney = aData.vip_level;
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
    --进入免费的数据不结算
    if ret.normalSpin.intoFree == 1 or ret.normalSpin.intoSpecial == 1  then
        if super.MONEY_TYPE == 0 then
            ret.normalSpin.slotMoney.money = ret.normalSpin.slotMoney.money - ret.normalSpin.curWinCoin
        else
            ret.normalSpin.slotMoneyGift.money_gift = ret.normalSpin.slotMoneyGift.money_gift - ret.normalSpin.curWinCoin
        end
    end
    return ret;
end

function Game336Hub:parseSpecialData(aData)
    dump(aData, "parseSpecialData", 10)
    local result = {
        _msgName_ = "PB.Slots_Client.DragonGiftSpecialRet",
        specialSpin = {}
    }
    -- print("处包数据")
    local specialSpin = result.specialSpin


    specialSpin.bet = 0;

    specialSpin.winCoin = aData.win
    specialSpin.grids = self:parseGrids(aData.grid)
    specialSpin.AllWinCoin = aData.total_win + aData.enter_win;
    --bonusWinCoin最后一把用Allwincoin的值
    specialSpin.bonusWinCoin = specialSpin.AllWinCoin > aData.total_special_win and specialSpin.AllWinCoin or aData.total_special_win
    specialSpin.allCount = aData.total_count
    specialSpin.totalCount = aData.left_special_count
    specialSpin.lines = {}
    -- for index, value in ipairs(aData.lines) do
    --     table.insert(result.lines, {
    --         lineIndex = value.line_index,
    
    -- specialSpin.hasdl = 0;
    specialSpin.slotMoneyGift = self:convertMoneyGift(aData)
    specialSpin.slotMoney = self:convertMoney(aData)
    return result
end

function Game336Hub:parseResumeData(aEnter, aEnterData, aResume)
    -- dump(aEnter, "aEnter", 10)
    -- dump(aEnterData, "aEnterData", 10)
    -- dump(aResume, "aResume", 10)
    local resume = nil
    if aResume then
        resume = {}

        self:parseCommonResumeData(aEnterData,aResume,resume)

        resume.resumedNormal = nil

        print("aResume.normal_spin_ret")
        if self:checkDataValide(aResume.normal_spin_ret)then
            -- dump(aResume.normal_spin_ret, "aResume.normal_spin_ret", 10)
            resume.resumedNormal = { normalSpin = {} }
            resume.resumedNormal.normalSpin = self:parseNormalSpinRet(aResume.normal_spin_ret).normalSpin
        end
        if self:checkDataValide(aResume.free_spin_ret) then
            resume.resumedFree = self:parseFreeSpinRet(aResume.free_spin_ret)
        end

        if self:checkDataValide(aResume.special_spin_ret)then
            resume.resumedSpecial = self:parseSpecialData(aResume.special_spin_ret)
            dump(resume.resumedSpecial, "resume.resumedSpecial", 10)
        end

       -- resume.resumedFreeType = { freeSpinType = { freeType = 0 } };


        -- resume.MoneyB = 0
        -- resume.cells = {}
        -- if aResume.collect_indexes and aResume.collect_indexes ~= cjson.null then
        --     resume.cells = aResume.collect_indexes
        -- end



        local currentWinCoin = 0

        --状态检查
        resume.type = 0
        if self:checkDataValide(aResume.last_state) and self:checkDataValide(aEnter.state) then
            local last_state = aResume.last_state.Gaming.spin_state
            local current_state = aEnter.state.Gaming.spin_state
            --上一把是正常
            if self:IsNormalState(last_state) then
                print("上一把是正常")
                --这一波是正常
                if self:IsNormalState(current_state) then
                    resume.type = 1
                --这一把是免费或者特殊
                elseif current_state.Free then
                    print("这一把是免费或者特殊")
                    self:checkFreeState(current_state.Free,last_state.Free,resume)
                end
            --上把是免费（包括小游戏模式）    
            elseif last_state.Free then
                if self:IsNormalState(current_state) then
                    resume.type = 1
                    resume.resumedNormal.normalSpin.intoFree = 0
                    resume.resumedNormal.normalSpin.intoSpecial = 0
                    resume.resumedNormal.normalSpin.slotMoney.money = resume.enterBase.enterMoney
                elseif current_state.Free then
                    print("上把是免费 这一把是免费或者特殊")
                    self:checkFreeState(current_state.Free,last_state.Free,resume)
                end
            end
        end
    end


    dump(resume, "resume data")
    return resume
end
--判断是不是正常模式
function Game336Hub:IsNormalState(last_state)
    if type(last_state) == "string" and last_state == "Normal" then
        return true
    end
    return false
end
--判断免费情况中的特殊情况
function Game336Hub:checkFreeState(currData,LastData,resume)
    print("判断免费情况中的特殊情况")

    --设置上一轮金币
    resume.currentWinCoin = currData.total_all_win+ resume.resumedNormal.normalSpin.curWinCoin

    --免费游戏总次数大于零 和 --特殊游戏总次数大于零
    if currData.total_count > 0 and currData.special_total_count > 0  then
        --特殊游戏开始次数为零 在免费游戏中
        print("免费中奖特殊游戏",currData.current_special_count)
        if currData.current_special_count == 0 then
            resume.type = 2
        else
            resume.currentWinCoin = resume.currentWinCoin + resume.resumedSpecial.specialSpin.bonusWinCoin
            resume.type = 4
        end
        if  currData.current_count < currData.total_count then
            resume.enterBase.enterMoney = resume.resumedNormal.normalSpin.slotMoney.money
        elseif  currData.current_special_count < currData.special_total_count then
            resume.enterBase.enterMoney = resume.resumedNormal.normalSpin.slotMoney.money
        end
    --免费游戏总次数大于零
    elseif currData.total_count > 0 then
        print("免费游戏",currData.current_count)
        --如果不是免费游戏的最后一把
        if  currData.current_count < currData.total_count then
            resume.enterBase.enterMoney = resume.resumedNormal.normalSpin.slotMoney.money
        end
        if currData.current_count == 0 then
            --普通中奖免费
            resume.type = 1
        else
            resume.type = 2
            resume.resumedFree.freeSpin.intoSpecial = 0
        end
    --特殊游戏总次数大于零
    elseif currData.special_total_count > 0 then
        print("特殊游戏",currData.current_special_count)
        if  currData.current_special_count < currData.special_total_count then
            resume.enterBase.enterMoney = resume.resumedNormal.normalSpin.slotMoney.money
        end
        --特殊游戏开始次数为零
        if currData.current_special_count == 0 then
            resume.type = 1
            resume.currentWinCoin = resume.currentWinCoin + self:DenglongCountValue(resume.resumedNormal.normalSpin.grids)
        else
            resume.currentWinCoin = resume.currentWinCoin + resume.resumedSpecial.specialSpin.bonusWinCoin
            resume.type = 3
        end
        print("特殊游戏,currentWinCoin",resume.currentWinCoin)
    end
end
function Game336Hub:parseFreeSpinRet(aData)
    dump(aData, "parseFreeSpinRet data",10)
    local ret = {}
    local spinret = {}
    ret._msgName_ = "PB.Slots_Client.DragonGiftFreeRet"


    spinret.bet = 0;
    spinret.winCoin = aData.win;

    spinret.allCount = aData.total_count;
    spinret.totalCount = aData.current_count
    spinret.newFreeTime = aData.new_free_time
    spinret.intoSpecial = aData.is_into_special and 1 or 0;
    --todo:服务器没有给
    print("data win:" .. tostring(aData.win))
    --spinret.bonusWinCoin = aData.win

    spinret.slotMoneyGift =
    {
        money_gift = aData.money_gift,
        money_gift_safe = aData.money_gift_safe,
        amount_of_gift = 0,
    };

    spinret.slotMoney = {
        money = aData.money,
        money_safe = aData.money_safe,
    };


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

function Game336Hub:parseFreeSpinType(aData)
    -- dump(aData, "parseFreeSpinType")
    -- local ret = {}
    -- ret._msgName_ = "PB.Slots_Client.JinJiBaoXiFreeTypeRet"
    -- ret.freeSpinType = { freeType = aData._typeid_ }
    return ret
end

function Game336Hub:parseGrids(aData)
    local result = {}
    for key, value in ipairs(aData) do
        result[key] = self:parseGrid(value)
    end
    return result
end

function Game336Hub:parseGrid(aData)
    return {
        index = aData.index,
        icon = aData.icon,
        SymbolValue = aData.symbol_value,
        Symbolbet = aData.symbol_bet,
        SymbolType = aData.symbol_type
    }
end
function Game336Hub:DenglongCountValue(grids)
    local valuemoney = 0
    for key, value in ipairs(grids) do
        valuemoney =valuemoney + value.SymbolValue
    end
    return valuemoney
end

return Game336Hub
