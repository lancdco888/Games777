local super = require("FGame.Common.Special.Creator.DataHub.GameProtocolHub")
---@class Game475Hub extends GameProtocolHub
local Game475Hub = class("Game475Hub", super)
-- Game475Hub.ResumeState = {
--     Normal = 1,
--     Free = 2,
--     Special = 3,
-- }
function Game475Hub:parseNormalSpinRet(aData)
    local ret = { normalSpin = {} }
    ret._msgName_ = "PB.Slots_Client.EyesOfWealthNormalRet"


    ret.normalSpin.bet = aData.bet;
    ret.normalSpin.winCoin = aData.win;
    ret.normalSpin.intoFree = aData.is_into_free and 1 or 0;
    ret.normalSpin.intoSpecial = aData.is_into_special and 1 or 0;

    ret.normalSpin.slotMoneyGift = self:convertMoneyGift(aData)

    ret.normalSpin.slotMoney = self:convertMoney(aData);

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
    return ret;
end

function Game475Hub:parseSpecialData(aData)
    -- dump(aData,"parseSpecialData",5)
    local result = {
        _msgName_ = "PB.Slots_Client.EyesOfWealthSpecialRet",
        specialSpin = {}
    }

    local specialSpin = result.specialSpin


    specialSpin.bet = 0;

    specialSpin.winCoin = aData.total_special_win + aData.enter_win
    specialSpin.grids = self:parseGrids(aData.grid)
    specialSpin.bonusWinCoin = aData.total_win + aData.enter_win
    specialSpin.AllWinCoin = aData.total_win + aData.enter_win
    specialSpin.allCount = aData.total_count
    specialSpin.totalCount = aData.left_special_count
    specialSpin.addTime = aData.new_time
    
    specialSpin.slotMoneyGift = self:convertMoneyGift(aData)
    specialSpin.slotMoney = self:convertMoney(aData)
    -- dump(result,"parseSpecialData ret",5)
    return result
end

function Game475Hub:parseResumeData(aEnter, aEnterData, aResume)
    -- dump(aEnter,"aEnter",5)
    -- dump(aResume,"aResume",5)
    local resume = nil
    if aResume then
        resume = {}
        self:parseCommonResumeData(aEnterData,aResume,resume)
        resume.resumedNormal = nil

        local hasNormalRet = aResume.normal_spin_ret and aResume.normal_spin_ret ~= cjson.null
        local hasFreeRet = aResume.free_spin_ret and aResume.free_spin_ret ~= cjson.null
        local hasSpecialRet = aResume.special_spin_ret and aResume.special_spin_ret ~= cjson.null
        local cur_spin_state = aEnter.state.Gaming.spin_state
        local last_spin_state = aResume.last_state ~= cjson.null and aResume.last_state.Gaming.spin_state or {}
        local last_spin = self:parseSpin(last_spin_state)
        local cur_spin = self:parseSpin(cur_spin_state)
        -- dump(last_spin,"last_spin")
        -- dump(cur_spin,"cur_spin")
        local intoSpecial,intoFree = 0,0

        if last_spin.NormalState and cur_spin.FreeState then
            intoFree = 1
        end
        if (last_spin.NormalState or last_spin.FreeState) and cur_spin.SpecialState then
            intoSpecial = 1
        end
        if hasNormalRet then
            resume.resumedNormal = { normalSpin = {} }
            resume.resumedNormal.normalSpin = self:parseNormalSpinRet(aResume.normal_spin_ret).normalSpin

            resume.resumedNormal.normalSpin.intoFree = intoFree
            resume.resumedNormal.normalSpin.intoSpecial = intoSpecial
        end
        if hasFreeRet and cur_spin.FreeState then
            resume.resumedFree = self:parseFreeSpinRet(aResume.free_spin_ret)
            resume.resumedFree.freeSpin.intoSpecial = intoSpecial
        end

        local currentWinCoin = 0
        if hasSpecialRet and cur_spin.SpecialState then
            resume.resumedSpecial = self:parseSpecialData(aResume.special_spin_ret)
        end
        if not (hasFreeRet or hasSpecialRet or hasNormalRet) then
            resume.type = 0
        elseif cur_spin.FreeState and cur_spin.SpecialState and last_spin.FreeState and last_spin.SpecialState then -- 免中落地牌
            resume.type = 4
            ---玩家身上的钱
            aEnterData.enterMoney = aResume.normal_spin_ret.money - aResume.normal_spin_ret.win
            aEnterData.enterMoney = self:calcLevelUpMoney(aEnterData.enterMoney,aResume.normal_spin_ret.level_ups)
            ---显示累计的钱
            currentWinCoin = aResume.free_spin_ret.total_win + aResume.free_spin_ret.enter_win
            for _, cell in pairs(aResume.special_spin_ret.grid) do
                currentWinCoin = currentWinCoin + cell.symbol_value
            end
        elseif cur_spin.SpecialState and last_spin.SpecialState then -- 落地牌
            resume.type = 3
            resume.resumedNormal.normalSpin.slotMoney.money = aResume.normal_spin_ret.money - aResume.normal_spin_ret.win
            resume.resumedNormal.normalSpin.slotMoney.money = self:calcLevelUpMoney(resume.resumedNormal.normalSpin.slotMoney.money,aResume.normal_spin_ret.level_ups)
            aEnterData.enterMoney = resume.resumedNormal.normalSpin.slotMoney.money
            currentWinCoin = aResume.special_spin_ret.total_special_win + aResume.special_spin_ret.enter_win
        elseif cur_spin.FreeState and last_spin.FreeState then -- 免费
            resume.type = 2
            if cur_spin.FreeState and last_spin.SpecialState then
                ---显示累计的钱
                currentWinCoin = aResume.special_spin_ret.total_win + aResume.special_spin_ret.enter_win
                ---玩家身上的钱
                resume.resumedNormal.normalSpin.slotMoney.money = aResume.special_spin_ret.money - currentWinCoin
                resume.resumedNormal.normalSpin.slotMoney.money = self:calcLevelUpMoney(resume.resumedNormal.normalSpin.slotMoney.money,aResume.normal_spin_ret.level_ups)
                aEnterData.enterMoney = resume.resumedNormal.normalSpin.slotMoney.money
            else
                ---玩家身上的钱
                resume.resumedNormal.normalSpin.slotMoney.money = aResume.normal_spin_ret.money - aResume.normal_spin_ret.win
                resume.resumedNormal.normalSpin.slotMoney.money = self:calcLevelUpMoney(resume.resumedNormal.normalSpin.slotMoney.money,aResume.normal_spin_ret.level_ups)
                aEnterData.enterMoney = resume.resumedNormal.normalSpin.slotMoney.money
                ---显示累计的钱
                currentWinCoin = aResume.free_spin_ret.total_win + aResume.free_spin_ret.enter_win
                if aResume.free_spin_ret.is_into_special then
                    for _, cell in pairs(aResume.free_spin_ret.grid) do
                        currentWinCoin = currentWinCoin + cell.symbol_value
                    end
                end
            end
        elseif last_spin.NormalState or cur_spin.NormalState then
            resume.type = 1
            if intoFree == 1 then
                resume.resumedNormal.normalSpin.slotMoney.money = aResume.normal_spin_ret.money - aResume.normal_spin_ret.win
                resume.resumedNormal.normalSpin.slotMoney.money = self:calcLevelUpMoney(resume.resumedNormal.normalSpin.slotMoney.money,aResume.normal_spin_ret.level_ups)
                aEnterData.enterMoney = resume.resumedNormal.normalSpin.slotMoney.money
                currentWinCoin = aResume.normal_spin_ret.win
            elseif intoSpecial == 1 then
                resume.resumedNormal.normalSpin.slotMoney.money = aResume.normal_spin_ret.money - aResume.normal_spin_ret.win
                resume.resumedNormal.normalSpin.slotMoney.money = self:calcLevelUpMoney(resume.resumedNormal.normalSpin.slotMoney.money,aResume.normal_spin_ret.level_ups)
                aEnterData.enterMoney = resume.resumedNormal.normalSpin.slotMoney.money
                currentWinCoin = aResume.normal_spin_ret.win
                if aResume.normal_spin_ret.is_into_special then
                    for _, cell in pairs(aResume.normal_spin_ret.grid) do
                        currentWinCoin = currentWinCoin + cell.symbol_value
                    end
                end
            end
        else
            resume.type = 0
        end
        if cur_spin.NormalState and last_spin.FreeState then
            ---显示累计的钱
            currentWinCoin = aResume.free_spin_ret.total_win + aResume.free_spin_ret.enter_win
            ---玩家身上的钱
            resume.resumedNormal.normalSpin.slotMoney.money = aResume.free_spin_ret.money
        end
        if cur_spin.NormalState and last_spin.SpecialState then
            ---显示累计的钱
            currentWinCoin = aResume.special_spin_ret.total_win + aResume.special_spin_ret.enter_win
            ---玩家身上的钱
            resume.resumedNormal.normalSpin.slotMoney.money = aResume.special_spin_ret.money
        end

        resume.currentWinCoin = currentWinCoin
    end

    -- dump(resume, "resume data")
    return resume
end

function Game475Hub:parseFreeSpinRet(aData)
    -- dump(aData,"parseFreeSpinRet aData")
    local ret = {}
    local spinret = {}
    ret._msgName_ = "PB.Slots_Client.EyesOfWealthFreeRet"

    spinret.bet = 0;
    spinret.winCoin = aData.win;

    spinret.allCount = aData.total_count;
    spinret.totalCount = aData.current_count
    spinret.addTime = aData.new_free_time
    
    spinret.bonusWinCoin = aData.total_win + aData.enter_win
    spinret.intoSpecial = aData.is_into_special and 1 or 0;
    
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
    -- dump(ret,"parseFreeSpinRet - lua")
    return ret;
end

-- function Game475Hub:parseFreeSpinType(aData)
--     dump(aData, "parseFreeSpinType")
--     local ret = {}
--     ret._msgName_ = "PB.Slots_Client.EyesOfWealthFreeRet"
--     ret.freeSpinType = { freeType = aData._typeid_ }
--     return ret
-- end

function Game475Hub:parseGrids(aData)
    local result = {}
    for key, value in ipairs(aData) do
        result[key] = self:parseGrid(value)
    end
    return result
end

function Game475Hub:parseGrid(aData)
    return {
        index = aData.index,
        icon = aData.icon,
        SymbolValue = aData.symbol_value,
        SymbolType = aData.symbol_type,
        IsHide = aData.is_hide
    }
end

function Game475Hub:parseSpin(aData)
    local spin = {
        NormalState = type(aData) == "string" and aData == "Normal",
        FreeState = false,
        SpecialState = false,
        current_count = 0,
        current_special_count = 0,
        left_special_count = 0,
        special_total_count = 0,
        total_all_win = 0,
        total_count = 0,
    }
    if type(aData) == "table" and aData.Free then
        local free = aData.Free
        spin.FreeState = free.is_free_game
        spin.SpecialState = free.is_special_game
        spin.current_count = free.current_count
        spin.current_special_count = free.current_special_count
        spin.left_special_count = free.left_special_count
        spin.special_total_count = free.special_total_count
        spin.total_all_win = free.total_all_win
        spin.total_count = free.total_count
    end
    return spin
end

function Game475Hub:calcLevelUpMoney(money,level_ups)
    for _, value in pairs(level_ups) do
        money = money - value
    end
    return money
end
return Game475Hub
