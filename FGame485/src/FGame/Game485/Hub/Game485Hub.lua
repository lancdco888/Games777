local super = require("FGame.Common.Special.Creator.DataHub.GameProtocolHub")
---@class Game485Hub extends GameProtocolHub
local Game485Hub = class("Game485Hub", super)

function Game485Hub:parseGrid(aData)
    return {
        index = aData.index,
        icon = aData.icon,
        symbolType = aData.symbol_type,
        symbolValue = aData.symbol_value,
        ishide = aData.is_hide,
    }
end

function Game485Hub:parseGrids(aData)
    local result = {}
    for key, value in ipairs(aData) do
        result[key] = self:parseGrid(value)
    end 
    return result
end

function Game485Hub:parseLine(aData)
    return {
        icon = aData.icon,
        winCoin = aData.win,
        lineIndex = aData.line_index,
        lineCells = self:parseGrids(aData.line_cells),
    }
end

function Game485Hub:parseNormalSpinRet(aData)
    local ret = {
        _msgName_ = "PB.Slots_Client.FireLinkNormalRet",
        normalSpin = {}
    }

    ret.normalSpin.bet = aData.bet;
    ret.normalSpin.winCoin = aData.win;
    ret.normalSpin.intoFree = aData.into_free~=0 and 1 or 0
    ret.normalSpin.intoSpecial = aData.into_special~=0 and 3 or 0

    ret.normalSpin.slotMoneyGift = self:convertMoneyGift(aData)
    ret.normalSpin.slotMoney = self:convertMoney(aData)

    ret.normalSpin.levelUpMoney = aData.vip_level
    ret.normalSpin.levelUpMoneys = aData.level_ups

    ret.normalSpin.grids = {}
    for index, value in ipairs(aData.grid) do
        ret.normalSpin.grids[index] = self:parseGrid(value)
    end

    ret.normalSpin.lines = {};
    for _, value in ipairs(aData.lines) do
        table.insert(ret.normalSpin.lines, self:parseLine(value))
    end

    if ret.normalSpin.intoFree == 1 then
        if super.MONEY_TYPE == 0 then
            ret.normalSpin.slotMoney.money = ret.normalSpin.slotMoney.money - ret.normalSpin.winCoin
        else
            ret.normalSpin.slotMoneyGift.money = ret.normalSpin.slotMoneyGift.money - ret.normalSpin.winCoin
        end
    end

    --普通
    --{"_msgName_":"PB.Slots_Client.FireLinkNormalRet","normalSpin":{"grids":[{"index":0,"symbolType":0,"symbolValue":0,"icon":1},{"index":1,"symbolType":0,"symbolValue":0,"icon":10},{"index":2,"symbolType":0,"symbolValue":0,"icon":1},{"index":3,"symbolType":1,"symbolValue":1000000,"icon":9},{"index":4,"symbolType":0,"symbolValue":0,"icon":10},{"index":5,"symbolType":0,"symbolValue":0,"icon":4},{"index":6,"symbolType":0,"symbolValue":0,"icon":10},{"index":7,"symbolType":0,"symbolValue":0,"icon":5},{"index":8,"symbolType":0,"symbolValue":0,"icon":2},{"index":9,"symbolType":0,"symbolValue":0,"icon":10},{"index":10,"symbolType":0,"symbolValue":0,"icon":8},{"index":11,"symbolType":0,"symbolValue":0,"icon":10},{"index":12,"symbolType":0,"symbolValue":0,"icon":4},{"index":13,"symbolType":0,"symbolValue":0,"icon":5},{"index":14,"symbolType":0,"symbolValue":0,"icon":10},{"index":15,"symbolType":0,"symbolValue":0,"icon":0},{"index":16,"symbolType":0,"symbolValue":0,"icon":8},{"index":17,"symbolType":0,"symbolValue":0,"icon":1},{"index":18,"symbolType":0,"symbolValue":0,"icon":3},{"index":19,"symbolType":0,"symbolValue":0,"icon":0}],"levelUpMoney":0,"slotMoney":{"money":135477808592000,"money_safe":285067290000},"levelUpMoneys":{},"intoSpecial":0,"slotMoneyGift":{"money_gift_safe":0,"amount_of_gift":3523261454640,"money_gift":3370858788390},"betMoney":0,"lines":[{"winCoin":150000,"lineCells":[{"index":0,"symbolType":0,"symbolValue":0,"icon":1},{"index":1,"symbolType":0,"symbolValue":0,"icon":10},{"index":2,"symbolType":0,"symbolValue":0,"icon":1}],"lineIndex":2,"icon":0},{"winCoin":50000,"lineCells":[{"index":5,"symbolType":0,"symbolValue":0,"icon":4},{"index":6,"symbolType":0,"symbolValue":0,"icon":10},{"index":12,"symbolType":0,"symbolValue":0,"icon":4}],"lineIndex":10,"icon":0},{"winCoin":50000,"lineCells":[{"index":5,"symbolType":0,"symbolValue":0,"icon":4},{"index":11,"symbolType":0,"symbolValue":0,"icon":10},{"index":12,"symbolType":0,"symbolValue":0,"icon":4}],"lineIndex":17,"icon":0},{"winCoin":50000,"lineCells":[{"index":5,"symbolType":0,"symbolValue":0,"icon":4},{"index":11,"symbolType":0,"symbolValue":0,"icon":10},{"index":12,"symbolType":0,"symbolValue":0,"icon":4}],"lineIndex":18,"icon":0},{"winCoin":150000,"lineCells":[{"index":0,"symbolType":0,"symbolValue":0,"icon":1},{"index":6,"symbolType":0,"symbolValue":0,"icon":10},{"index":2,"symbolType":0,"symbolValue":0,"icon":1}],"lineIndex":22,"icon":0},{"winCoin":50000,"lineCells":[{"index":5,"symbolType":0,"symbolValue":0,"icon":4},{"index":6,"symbolType":0,"symbolValue":0,"icon":10},{"index":12,"symbolType":0,"symbolValue":0,"icon":4}],"lineIndex":26,"icon":0},{"winCoin":150000,"lineCells":[{"index":0,"symbolType":0,"symbolValue":0,"icon":1},{"index":1,"symbolType":0,"symbolValue":0,"icon":10},{"index":2,"symbolType":0,"symbolValue":0,"icon":1}],"lineIndex":42,"icon":0},{"winCoin":50000,"lineCells":[{"index":5,"symbolType":0,"symbolValue":0,"icon":4},{"index":11,"symbolType":0,"symbolValue":0,"icon":10},{"index":12,"symbolType":0,"symbolValue":0,"icon":4}],"lineIndex":46,"icon":0},{"winCoin":150000,"lineCells":[{"index":0,"symbolType":0,"symbolValue":0,"icon":1},{"index":6,"symbolType":0,"symbolValue":0,"icon":10},{"index":2,"symbolType":0,"symbolValue":0,"icon":1}],"lineIndex":48,"icon":0}],"intoFree":0,"winCoin":850000}}   
    --免费
    -- {"_msgName_":"PB.Slots_Client.FireLinkNormalRet","normalSpin":{"betMoney":0,"lines":[{"lineCells":[{"index":2,"symbolValue":0,"icon":11,"symbolType":0},{"index":16,"symbolValue":0,"icon":11,"symbolType":0},{"index":18,"symbolValue":0,"icon":11,"symbolType":0}],"lineIndex":1001,"winCoin":1000000,"icon":0}],"levelUpMoney":0,"grids":[{"index":0,"symbolValue":0,"icon":5,"symbolType":0},{"index":1,"symbolValue":0,"icon":0,"symbolType":0},{"index":2,"symbolValue":0,"icon":11,"symbolType":0},{"index":3,"symbolValue":0,"icon":7,"symbolType":0},{"index":4,"symbolValue":0,"icon":4,"symbolType":0},{"index":5,"symbolValue":0,"icon":0,"symbolType":0},{"index":6,"symbolValue":0,"icon":1,"symbolType":0},{"index":7,"symbolValue":0,"icon":4,"symbolType":0},{"index":8,"symbolValue":0,"icon":6,"symbolType":0},{"index":9,"symbolValue":0,"icon":6,"symbolType":0},{"index":10,"symbolValue":5000000,"icon":9,"symbolType":1},{"index":11,"symbolValue":0,"icon":3,"symbolType":0},{"index":12,"symbolValue":0,"icon":3,"symbolType":0},{"index":13,"symbolValue":0,"icon":2,"symbolType":0},{"index":14,"symbolValue":1500000,"icon":9,"symbolType":1},{"index":15,"symbolValue":0,"icon":8,"symbolType":0},{"index":16,"symbolValue":0,"icon":11,"symbolType":0},{"index":17,"symbolValue":0,"icon":7,"symbolType":0},{"index":18,"symbolValue":0,"icon":11,"symbolType":0},{"index":19,"symbolValue":1000000,"icon":9,"symbolType":1}],"levelUpMoneys":{},"slotMoney":{"money":136842267006160,"money_safe":285067290000},"intoSpecial":0,"slotMoneyGift":{"money_gift_safe":0,"money_gift":3370858788390,"amount_of_gift":3523261454640},"winCoin":1000000,"intoFree":1}}
    --落地牌
    -- {"normalSpin":{"levelUpMoney":0,"grids":[{"symbolType":0,"symbolValue":0,"index":0,"icon":2},{"symbolType":0,"symbolValue":0,"index":1,"icon":5},{"symbolType":0,"symbolValue":0,"index":2,"icon":8},{"symbolType":0,"symbolValue":0,"index":3,"icon":5},{"symbolType":0,"symbolValue":0,"index":4,"icon":2},{"symbolType":0,"symbolValue":0,"index":5,"icon":5},{"symbolType":0,"symbolValue":0,"index":6,"icon":6},{"symbolType":0,"symbolValue":0,"index":7,"icon":1},{"symbolType":0,"symbolValue":0,"index":8,"icon":3},{"symbolType":0,"symbolValue":0,"index":9,"icon":7},{"symbolType":1,"symbolValue":500000,"index":10,"icon":9},{"symbolType":1,"symbolValue":1000000,"index":11,"icon":9},{"symbolType":0,"symbolValue":0,"index":12,"icon":11},{"symbolType":1,"symbolValue":1500000,"index":13,"icon":9},{"symbolType":0,"symbolValue":0,"index":14,"icon":5},{"symbolType":0,"symbolValue":0,"index":15,"icon":6},{"symbolType":1,"symbolValue":500000,"index":16,"icon":9},{"symbolType":0,"symbolValue":0,"index":17,"icon":7},{"symbolType":0,"symbolValue":0,"index":18,"icon":8},{"symbolType":0,"symbolValue":0,"index":19,"icon":2}],"intoSpecial":3,"slotMoneyGift":{"money_gift_safe":0,"money_gift":3370858788390,"amount_of_gift":3523261454640},"slotMoney":{"money_safe":285067290000,"money":136436814896560},"intoFree":0,"winCoin":0,"lines":[{"lineCells":[{"symbolType":1,"symbolValue":500000,"index":10,"icon":9},{"symbolType":1,"symbolValue":1000000,"index":11,"icon":9},{"symbolType":1,"symbolValue":1500000,"index":13,"icon":9},{"symbolType":1,"symbolValue":500000,"index":16,"icon":9}],"winCoin":0,"lineIndex":1002,"icon":0}],"betMoney":0,"levelUpMoneys":{}},"_msgName_":"PB.Slots_Client.FireLinkNormalRet"}
    if DebugHubMsg then
        local target = cjson.decode(
            '{"normalSpin":{"levelUpMoney":0,"grids":[{"symbolType":0,"symbolValue":0,"index":0,"icon":2},{"symbolType":0,"symbolValue":0,"index":1,"icon":5},{"symbolType":0,"symbolValue":0,"index":2,"icon":8},{"symbolType":0,"symbolValue":0,"index":3,"icon":5},{"symbolType":0,"symbolValue":0,"index":4,"icon":2},{"symbolType":0,"symbolValue":0,"index":5,"icon":5},{"symbolType":0,"symbolValue":0,"index":6,"icon":6},{"symbolType":0,"symbolValue":0,"index":7,"icon":1},{"symbolType":0,"symbolValue":0,"index":8,"icon":3},{"symbolType":0,"symbolValue":0,"index":9,"icon":7},{"symbolType":1,"symbolValue":500000,"index":10,"icon":9},{"symbolType":1,"symbolValue":1000000,"index":11,"icon":9},{"symbolType":0,"symbolValue":0,"index":12,"icon":11},{"symbolType":1,"symbolValue":1500000,"index":13,"icon":9},{"symbolType":0,"symbolValue":0,"index":14,"icon":5},{"symbolType":0,"symbolValue":0,"index":15,"icon":6},{"symbolType":1,"symbolValue":500000,"index":16,"icon":9},{"symbolType":0,"symbolValue":0,"index":17,"icon":7},{"symbolType":0,"symbolValue":0,"index":18,"icon":8},{"symbolType":0,"symbolValue":0,"index":19,"icon":2}],"intoSpecial":3,"slotMoneyGift":{"money_gift_safe":0,"money_gift":3370858788390,"amount_of_gift":3523261454640},"slotMoney":{"money_safe":285067290000,"money":136436814896560},"intoFree":0,"winCoin":0,"lines":[{"lineCells":[{"symbolType":1,"symbolValue":500000,"index":10,"icon":9},{"symbolType":1,"symbolValue":1000000,"index":11,"icon":9},{"symbolType":1,"symbolValue":1500000,"index":13,"icon":9},{"symbolType":1,"symbolValue":500000,"index":16,"icon":9}],"winCoin":0,"lineIndex":1002,"icon":0}],"betMoney":0,"levelUpMoneys":{}},"_msgName_":"PB.Slots_Client.FireLinkNormalRet"}'
        )
        DebugHubMsg:PrintCompareHubMsg( ret, target, aData )
    end

    return ret;
end

function Game485Hub:parseFreeSpinRet(aData)
    local ret = {
        _msgName_ = "PB.Slots_Client.FireLinkFreeRet",
        freeSpin = {},
    }

    ret.freeSpin.bet = aData.bet;
    ret.freeSpin.winCoin = aData.win;
    ret.freeSpin.freeGameTotalCount = aData.total_count
    ret.freeSpin.freeGameCurCount = aData.current_count
    ret.freeSpin.intoFree = aData.into_free
    ret.freeSpin.totalWinCoin = aData.total_win + aData.enter_win
    ret.freeSpin.scale = aData.scale

    ret.freeSpin.slotMoneyGift = self:convertMoneyGift(aData)
    ret.freeSpin.slotMoney = self:convertMoney(aData)

    ret.freeSpin.grids = {}
    for index, value in ipairs(aData.grid) do
        ret.freeSpin.grids[index] = self:parseGrid(value)
    end

    ret.freeSpin.lines = {};
    for _, value in ipairs(aData.lines) do
        table.insert(ret.freeSpin.lines, self:parseLine(value))
    end


    if DebugHubMsg then
        local target = cjson.decode(
            '{"_msgName_":"PB.Slots_Client.FireLinkFreeRet","freeSpin":{"betMoney":500000,"lines":[{"lineCells":[{"index":0,"symbolValue":0,"icon":8,"symbolType":0},{"index":6,"symbolValue":0,"icon":10,"symbolType":0},{"index":7,"symbolValue":0,"icon":8,"symbolType":0}],"lineIndex":13,"winCoin":500000,"icon":0},{"lineCells":[{"index":5,"symbolValue":0,"icon":7,"symbolType":0},{"index":1,"symbolValue":0,"icon":10,"symbolType":0},{"index":2,"symbolValue":0,"icon":7,"symbolType":0}],"lineIndex":16,"winCoin":500000,"icon":0},{"lineCells":[{"index":5,"symbolValue":0,"icon":7,"symbolType":0},{"index":6,"symbolValue":0,"icon":10,"symbolType":0},{"index":2,"symbolValue":0,"icon":7,"symbolType":0}],"lineIndex":21,"winCoin":500000,"icon":0},{"lineCells":[{"index":0,"symbolValue":0,"icon":8,"symbolType":0},{"index":1,"symbolValue":0,"icon":10,"symbolType":0},{"index":7,"symbolValue":0,"icon":8,"symbolType":0}],"lineIndex":24,"winCoin":500000,"icon":0},{"lineCells":[{"index":0,"symbolValue":0,"icon":8,"symbolType":0},{"index":1,"symbolValue":0,"icon":10,"symbolType":0},{"index":7,"symbolValue":0,"icon":8,"symbolType":0},{"index":13,"symbolValue":0,"icon":8,"symbolType":0}],"lineIndex":28,"winCoin":1000000,"icon":0},{"lineCells":[{"index":5,"symbolValue":0,"icon":7,"symbolType":0},{"index":1,"symbolValue":0,"icon":10,"symbolType":0},{"index":2,"symbolValue":0,"icon":7,"symbolType":0}],"lineIndex":34,"winCoin":500000,"icon":0},{"lineCells":[{"index":0,"symbolValue":0,"icon":8,"symbolType":0},{"index":6,"symbolValue":0,"icon":10,"symbolType":0},{"index":7,"symbolValue":0,"icon":8,"symbolType":0},{"index":13,"symbolValue":0,"icon":8,"symbolType":0}],"lineIndex":45,"winCoin":1000000,"icon":0}],"freeGameCurCount":5,"grids":[{"index":0,"symbolValue":0,"icon":8,"symbolType":0},{"index":1,"symbolValue":0,"icon":10,"symbolType":0},{"index":2,"symbolValue":0,"icon":7,"symbolType":0},{"index":3,"symbolValue":0,"icon":4,"symbolType":0},{"index":4,"symbolValue":0,"icon":4,"symbolType":0},{"index":5,"symbolValue":0,"icon":7,"symbolType":0},{"index":6,"symbolValue":0,"icon":10,"symbolType":0},{"index":7,"symbolValue":0,"icon":8,"symbolType":0},{"index":8,"symbolValue":0,"icon":6,"symbolType":0},{"index":9,"symbolValue":0,"icon":7,"symbolType":0},{"index":10,"symbolValue":0,"icon":0,"symbolType":0},{"index":11,"symbolValue":0,"icon":10,"symbolType":0},{"index":12,"symbolValue":0,"icon":2,"symbolType":0},{"index":13,"symbolValue":0,"icon":8,"symbolType":0},{"index":14,"symbolValue":0,"icon":4,"symbolType":0},{"index":15,"symbolValue":0,"icon":6,"symbolType":0},{"index":16,"symbolValue":0,"icon":10,"symbolType":0},{"index":17,"symbolValue":0,"icon":3,"symbolType":0},{"index":18,"symbolValue":0,"icon":11,"symbolType":0},{"index":19,"symbolValue":0,"icon":3,"symbolType":0}],"slotMoney":{"money":136842266986160,"money_safe":285067290000},"freeGameTotalCount":10,"totalWinCoin":6500000,"scale":10,"slotMoneyGift":{"money_gift_safe":0,"money_gift":3370858788390,"amount_of_gift":3523261454640},"winCoin":4500000,"intoFree":0}}'
        )
        DebugHubMsg:PrintCompareHubMsg( ret, target, aData )
    end

    return ret
end

function Game485Hub:parseSpecialData(aData)
    local ret = {
        _msgName_ = "PB.Slots_Client.FireLinkSpecialRet",
        specialSpin = {},
    }

    ret.specialSpin.bet = aData.bet or 0;
    ret.specialSpin.winCoin = aData.win or 0;
    ret.specialSpin.lottyGameRestCount = aData.lotty_game_rest_count or 0
    ret.specialSpin.totalWinCoin = aData.total_win + aData.enter_win

    ret.specialSpin.slotMoneyGift = self:convertMoneyGift(aData)
    ret.specialSpin.slotMoney = self:convertMoney(aData)

    ret.specialSpin.grids = {}
    for index, value in ipairs(aData.grid) do
        ret.specialSpin.grids[index] = self:parseGrid(value)
    end

    ret.specialSpin.lines = {};
    if self:checkDataValide(aData.lines) then
        for _, value in ipairs(aData.lines) do
            table.insert(ret.specialSpin.lines, self:parseLine(value))
        end
    end

    if DebugHubMsg then
        local target = cjson.decode(
            '{"specialSpin":{"slotMoneyGift":{"money_gift_safe":0,"money_gift":3370858788390,"amount_of_gift":3523261454640},"lines":{},"slotMoney":{"money_safe":285067290000,"money":136436814896560},"totalWinCoin":0,"grids":[{"symbolType":0,"symbolValue":0,"index":0,"icon":0},{"symbolType":0,"symbolValue":0,"index":1,"icon":8},{"symbolType":0,"symbolValue":0,"index":2,"icon":3},{"symbolType":1,"symbolValue":1500000,"index":3,"icon":9},{"symbolType":0,"symbolValue":0,"index":4,"icon":5},{"symbolType":0,"symbolValue":0,"index":5,"icon":4},{"symbolType":1,"symbolValue":2000000,"index":6,"icon":9},{"symbolType":1,"symbolValue":50000000,"index":7,"icon":9},{"symbolType":1,"symbolValue":1000000,"index":8,"icon":9},{"symbolType":0,"symbolValue":0,"index":9,"icon":0},{"symbolType":0,"symbolValue":0,"index":10,"icon":10},{"symbolType":1,"symbolValue":500000,"index":11,"icon":9},{"symbolType":1,"symbolValue":2000000,"index":12,"icon":9},{"symbolType":0,"symbolValue":0,"index":13,"icon":10},{"symbolType":0,"symbolValue":0,"index":14,"icon":3},{"symbolType":1,"symbolValue":500000,"index":15,"icon":9},{"symbolType":0,"symbolValue":0,"index":16,"icon":0},{"symbolType":0,"symbolValue":0,"index":17,"icon":7},{"symbolType":1,"symbolValue":1000000,"index":18,"icon":9},{"symbolType":1,"symbolValue":1500000,"index":19,"icon":9},{"symbolType":0,"symbolValue":0,"index":20,"icon":4},{"symbolType":1,"symbolValue":500000,"index":21,"icon":9},{"symbolType":0,"symbolValue":0,"index":22,"icon":3},{"symbolType":0,"symbolValue":0,"index":23,"icon":2},{"symbolType":0,"symbolValue":0,"index":24,"icon":0},{"symbolType":0,"symbolValue":0,"index":25,"icon":4},{"symbolType":0,"symbolValue":0,"index":26,"icon":4},{"symbolType":1,"symbolValue":500000,"index":27,"icon":9},{"symbolType":0,"symbolValue":0,"index":28,"icon":6},{"symbolType":0,"symbolValue":0,"index":29,"icon":2},{"symbolType":1,"symbolValue":500000,"index":30,"icon":9},{"symbolType":1,"symbolValue":1000000,"index":31,"icon":9},{"symbolType":0,"symbolValue":0,"index":32,"icon":7},{"symbolType":1,"symbolValue":1500000,"index":33,"icon":9},{"symbolType":1,"symbolValue":500000,"index":34,"icon":9},{"symbolType":0,"symbolValue":0,"index":35,"icon":6},{"symbolType":1,"symbolValue":500000,"index":36,"icon":9},{"symbolType":1,"symbolValue":500000,"index":37,"icon":9},{"symbolType":1,"symbolValue":1000000,"index":38,"icon":9},{"symbolType":0,"symbolValue":0,"index":39,"icon":0}],"lottyGameRestCount":3,"betMoney":500000,"winCoin":0},"_msgName_":"PB.Slots_Client.FireLinkSpecialRet"}'
        )
        DebugHubMsg:PrintCompareHubMsg( ret, target, aData )
    end

    return ret
end

function Game485Hub:parseResumeData(aEnter, aEnterData, aResume)
    local resume = nil
    dump(aEnter, "Game485Hub:parseResumeData aEnter", 10)
    dump(aEnterData, "Game485Hub:parseResumeData aEnterData", 10)
    dump(aResume, "Game485Hub:parseResumeData aResume", 10)

    if aResume then
        resume = {}
        resume.currentWinCoin = 0

        self:parseCommonResumeData(aEnterData,aResume,resume)
        resume.resumedNormal = nil
        if self:checkDataValide(aResume.normal_spin_ret) then
            resume.resumedNormal = self:parseNormalSpinRet(aResume.normal_spin_ret)
        end

        if self:checkDataValide(aResume.free_spin_ret) then
            resume.resumedFree = self:parseFreeSpinRet(aResume.free_spin_ret)
        end

        if self:checkDataValide(aResume.special_spin_ret) then
            resume.resumedSpecial = self:parseSpecialData(aResume.special_spin_ret)
        end

        --todo
        -- lastMsgType
        -- 最后一次回复玩家的消息类型
        -- 0 玩家刚进入房间时的默认状态。resumedXXX系列数据都为空
        -- 1 normal游戏状态
        -- 2 已发送类型选择包，但是还没发送FreeSpin或SpecialSpin来获取结果
        -- 3 免费游戏
        -- 4 落地牌游戏


        --状态检查
        resume.lastMsgType = 0
        if self:checkDataValide(aResume.last_state) and self:checkDataValide(aEnter.state) then
            local last_state = aResume.last_state.Gaming.spin_state
            local current_state = aEnter.state.Gaming.spin_state

            --上一把是正常
            if self:IsNormalState(last_state) then
                --这一波是正常
                if self:IsNormalState(current_state) then
                    resume.lastMsgType = 1
                    
                --这一把是 免费/落地牌
                elseif current_state.Free then
                    if current_state.Free.is_special_game then
                        --刚中中落地牌
                        resume.lastMsgType = 1
                        aEnterData.enterMoney = resume.resumedNormal.normalSpin.slotMoney.money - resume.resumedNormal.normalSpin.winCoin
                    else
                        --免费
                        self:checkFreeState(current_state.Free,resume,aEnterData,aResume)
                    end
                end
            --上把是免费/落地牌
            elseif last_state.Free then
                if self:IsNormalState(current_state) then
                    resume.lastMsgType = 1
                    resume.resumedNormal.normalSpin.intoFree = 0
                    resume.resumedNormal.normalSpin.intoSpecial = 0
                    --免费结算 这个时候需要换
                    resume.resumedNormal.normalSpin.slotMoney.money = resume.enterBase.enterMoney
                elseif current_state.Free then
                    if current_state.Free.is_special_game then
                        --中落地牌中
                        resume.lastMsgType = 4
                        aEnterData.enterMoney = resume.resumedNormal.normalSpin.slotMoney.money  - resume.resumedNormal.normalSpin.winCoin
                    else
                        self:checkFreeState(current_state.Free,resume,aEnterData,aResume)                        
                    end
                end
            end
        end
        print("get resume status:" .. tostring(resume.status))
    end

    dump(resume, "resume data")
    return resume
end

--发包 解释免选类型选择协议
function Game485Hub:transformFreeType(aMsg)
    if string.endsWith(aMsg._msgName_, "SelectType") then
        local msg =
        {
            _h5MsgName_ = "func",
            func = "FreeSpinType",

            context = {
                free_type = aMsg.type
            }
        }
        return msg
    end
end

--收包 解释免选类型选择协议
function Game485Hub:parseFreeSpinType(aData)
    dump(aData, "-----------------Game485Hub:parseFreeSpinType")
    local ret = {}
    ret._msgName_ = "PB.Slots_Client.FireLinkSelectRet"
    ret.selectType = {
        type = aData.context.free_type,
        times = aData.context.times,
        scales = aData.context.scales,
    }
    dump(ret, "-----------------Game485Hub:parseFreeSpinType ret")
    return ret
end

--判断是不是正常模式
function Game485Hub:IsNormalState(last_state)
    if type(last_state) == "string" and last_state == "Normal" then
        return true
    end
    return false
end

--判断免费情况中的特殊情况
function Game485Hub:checkFreeState(currData,resume,aEnterData,aResume)
    --特殊游戏
    if currData.is_special_game then
        print("in free, no specital")
        -- --刚进入落地牌
        -- if currData.current_special_count == 0 then
        --     resume.lastMsgType = 1
        --     resume.currentWinCoin = currData.enter_win + self:getBonusChangeScore(resume.resumedNormal.normalSpin.grids)
        -- else
        --     resume.lastMsgType = 4
        --     --结算
        --     if currData.lotty_game_rest_count ~= 0 then
        --         aEnterData.enterMoney = resume.resumedNormal.normalSpin.slotMoney.money
        --     else
        --         resume.resumedNormal.normalSpin.intoSpecial = 0
        --     end
        --     -- resume.currentWinCoin = currData.enter_win + self:getBonusChangeScore(resume.resumedSpecial.specialSpin.grids)
        --     resume.currentWinCoin = currData.enter_win
        -- end
    elseif currData.is_free_game then
        if currData.last_select_spin_type == -1 then
            --还未选择
            resume.lastMsgType = 1
            aEnterData.enterMoney = resume.resumedNormal.normalSpin.slotMoney.money
        elseif currData.last_select_spin_type ~= -1 and currData.current_count == 0 then
            --已发送类型选择包，但是还没发送FreeSpin或SpecialSpin来获取结果
            resume.lastMsgType = 2
            resume.resumedSelect = self:parseFreeSpinType({context = aResume.free_spin_type_ret},true)
        else
            resume.lastMsgType = 3
            resume.resumedSelect = self:parseFreeSpinType({context = aResume.free_spin_type_ret},true)
            --结算
            if currData.current_count ~= currData.total_count then
                aEnterData.enterMoney = resume.resumedNormal.normalSpin.slotMoney.money
            else
                resume.resumedNormal.normalSpin.intoFree = 0
            end
        end
        resume.currentWinCoin = currData.total_all_win + currData.enter_win
    end
end

--这里的钱 999 是在currentWinCoin中  而h5 没有包含 所以这里也要加上
function Game485Hub:getBonusChangeScore(grids)
    local s_total_win = 0
    for _, value in ipairs(grids) do
        if value.icon == 2 then
            s_total_win = s_total_win + value.symbolValue
        end
    end
    return s_total_win
end

return Game485Hub
