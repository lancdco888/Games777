local super = require("FGame.Common.Special.Creator.DataHub.GameProtocolHub")
---@class Game270Hub extends GameProtocolHub
local cls = class("Game270Hub", super)
cls.transform_new = false
require("FGame.Common.Functions.GamePrintExPlugin")
if OpenDebug then OpenDebug() end

local lastFree = false

function cls:parseNormalSpinRet(aData)

    lastFree = false

    dump( aData, "--------------- cls:parseNormalSpinRet", 10 )

    local ret = {
        _msgName_ = "PB.Slots_Client.EyesOfWealthNormalRet",
        normalSpin = {
            bet = aData.bet,
            winCoin = aData.win,

            levelUpMoney = aData.vip_level,
            levelUpMoneys = aData.level_ups,

            intoFree = aData.is_into_free and 1 or 0,
            intoSpecial = aData.is_into_special and 1 or 0,


            grids = self:parseGrids(aData.grid),
            lines = self:parseLines(aData.lines),
            slotMoney = self:convertMoney(aData),
            slotMoneyGift = self:convertMoneyGift(aData),
        }
    }

    --进入免费的数据不结算
    if ret.normalSpin.intoFree == 1 or ret.normalSpin.intoSpecial == 1 then
        if super.MONEY_TYPE == 0 then
            ret.normalSpin.slotMoney.money = ret.normalSpin.slotMoney.money - ret.normalSpin.winCoin
        else
            ret.normalSpin.slotMoneyGift.money_gift = ret.normalSpin.slotMoneyGift.money_gift - ret.normalSpin.winCoin
        end
    end

    dump( ret, "--------------- cls:parseNormalSpinRet>>>>>>>>>>>>>", 10 )

    return ret;
end

function cls:parseFreeSpinRet(aData)

    lastFree = true

    dump( aData, "--------------- cls:parseFreeSpinRet", 10 )

    local ret = {
        _msgName_ = "PB.Slots_Client.EyesOfWealthFreeRet",
        freeSpin = {
            bet = 0, --aData.bet,
            winCoin = aData.win,
            allCount = aData.total_count,
            bonusWinCoin = aData.total_win + aData.enter_win,
            totalCount = aData.current_count,

            addTime = aData.new_free_time or 0,

            levelUpMoney = aData.vip_level,
            levelUpMoneys = aData.level_ups,

            intoSpecial = aData.is_into_special and 1 or 0,


            grids = self:parseGrids(aData.grid),
            lines = self:parseLines(aData.lines),
            slotMoney = self:convertMoney(aData),
            slotMoneyGift = self:convertMoneyGift(aData),
        }
    }

    dump( ret, "--------------- cls:parseFreeSpinRet>>>>>>>>>>>>>", 10 )

    return ret;
end

function cls:parseSpecialData(aData)

    dump( aData, "--------------- cls:parseSpecialData", 10 )
    
    local ret = {
        _msgName_ = "PB.Slots_Client.EyesOfWealthSpecialRet",
        specialSpin = {
            bet = 0,
            lines = {},


            winCoin = aData.win,
            allCount = aData.total_count,
            levelUpMoney = aData.vip_level,
            levelUpMoneys = aData.level_ups,
            totalCount = aData.left_special_count,


            grids = self:parseGrids(aData.grid),
            slotMoney = self:convertMoney(aData),
            slotMoneyGift = self:convertMoneyGift(aData),
        }
    }

    aData.enter_win = aData.enter_win or 0

    ret.specialSpin.AllWinCoin = aData.total_win + aData.enter_win
    --bonusWinCoin最后一把用Allwincoin的值
    ret.specialSpin.bonusWinCoin = ret.specialSpin.AllWinCoin > aData.total_special_win and ret.specialSpin.AllWinCoin or
        aData.total_special_win
    
    --is_free_to_special
    if lastFree then
        ret.specialSpin.bonusWinCoin = aData.total_special_win
    end

    -- ret.specialSpin.AllWinCoin = aData.total_win + aData.enter_win
    -- ret.specialSpin.bonusWinCoin = aData.total_win
        
    -- if 免费中? then
    --     ret.specialSpin.bonusWinCoin = aData.total_special_win
    -- end

    
    print( "aData.total_special_win:" .. aData.total_special_win )
    print( "ret.specialSpin.bonusWinCoin:" .. ret.specialSpin.bonusWinCoin )

    ret.specialSpin.grids = {}
    ret.specialSpin.lines = {}
    for k, v in ipairs(aData.grid) do
        table.insert(ret.specialSpin.grids, {
            index = v.index,
            icon = v.icon,
            SymbolType = v.symbol_type,
            SymbolValue = v.symbol_value
        })
    end

    dump( ret, "--------------- cls:parseSpecialData>>>>>>>>>>>>>", 10 )

    return ret
end

function cls:getEnter(aEnter)
    return {}
end

-- aEnter src Json Data   ->  PlayerStatusRet
-- aEnterData conver Table Data
-- aResume   -> LastSpinRet
function cls:parseResumeData(aEnter, aEnterData, aResume)

    lastFree = false

    --dump( aEnter, "--------------- cls:parseResumeData aEnter", 10 )
    --dump( aEnterData, "--------------- cls:parseResumeData aEnterData aEnterData", 10 )
    dump( aResume, "--------------- cls:parseResumeData aResume", 10 )

    local resume = nil
    if aResume then
        resume = {}

        self:parseCommonResumeData(aEnterData, aResume, resume)
        resume.resumedNormal = nil

        if self:checkDataValide(aResume.normal_spin_ret) then
            resume.resumedNormal = { normalSpin = {} }
            resume.resumedNormal.normalSpin = self:parseNormalSpinRet(aResume.normal_spin_ret).normalSpin
        end

        if self:checkDataValide(aResume.free_spin_ret) then
            resume.resumedFree = self:parseFreeSpinRet(aResume.free_spin_ret)
        end

        if self:checkDataValide(aResume.special_spin_ret) then
            resume.resumedSpecial = self:parseSpecialData(aResume.special_spin_ret)
        end

        local currentWinCoin = 0

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
                    resume.currentWinCoin = resume.resumedNormal.normalSpin.winCoin
                    --这一把是免费或者特殊
                elseif current_state.Free then
                    print("这一把是免费或者特殊")
                    self:checkFreeState(aEnter, aResume, resume)
                end
                --上把是免费（包括小游戏模式）
            elseif last_state.Free then
                if self:IsNormalState(current_state) then
                    print("免费中 1 ? ")

                    resume.type = 1

                    resume.resumedNormal.normalSpin.intoFree = 0
                    resume.resumedNormal.normalSpin.intoSpecial = 0
                    resume.resumedNormal.normalSpin.slotMoney.money = resume.enterBase.enterMoney
                    if last_state.Free.is_special_game then
                        -- resume.currentWinCoin = resume.resumedSpecial.specialSpin.AllWinCoin
                        print("免费+落地牌 结束？")
                        resume.currentWinCoin = 0
                    else
                        print("免费结束")
                        -- resume.currentWinCoin = resume.resumedNormal.normalSpin.winCoin
                        -- resume.currentWinCoin = resume.resumedFree.freeSpin.bonusWinCoin --纯免费
                        -- 免费+落地牌有问题
                        resume.currentWinCoin = 0
                    end
                elseif current_state.Free then
                    print("上把是免费 这一把是免费或者特殊")
                    self:checkFreeState(aEnter, aResume, resume)
                end
            end
        end
    end

    dump( resume, "--------------- cls:parseResumeData resume >>>>>>>>>>>>>", 10 )

    return resume
end

--判断是不是正常模式
function cls:IsNormalState(last_state)
    if type(last_state) == "string" and last_state == "Normal" then
        return true
    end
    return false
end

--判断免费情况中的特殊情况
function cls:checkFreeState(cur_state, last_state, resume)
    local playerStatusRet = cur_state.state.Gaming.spin_state.Free
    local lastData = last_state.last_state.Gaming.spin_state.Free

    --设置上一轮金币
    resume.currentWinCoin = playerStatusRet.total_all_win + resume.resumedNormal.normalSpin.winCoin

    --免费游戏总次数大于零 和 --特殊游戏总次数大于零
    if playerStatusRet.total_count > 0 and playerStatusRet.special_total_count > 0 then
        --特殊游戏开始次数为零 在免费游戏中
        print("免费中奖特殊游戏", playerStatusRet.current_special_count)
        if playerStatusRet.current_special_count == 0 then
            resume.type = 2
            -- is_free_game
            -- is_special_game
            local symbolVal = 0
            symbolVal = self:getSymbolValueByObj(resume.resumedFree.freeSpin.grids)
            resume.currentWinCoin = resume.currentWinCoin + symbolVal
        else
            local symbolVal = 0
            symbolVal = self:getSymbolValueByObj(resume.resumedSpecial.specialSpin.grids)
            resume.currentWinCoin = resume.currentWinCoin + symbolVal
            resume.type = 4
        end

        if playerStatusRet.current_count < playerStatusRet.total_count or
            playerStatusRet.current_special_count < playerStatusRet.special_total_count then
            resume.enterBase.enterMoney = resume.resumedNormal.normalSpin.slotMoney.money
        end
        --免费游戏总次数大于零
    elseif playerStatusRet.total_count > 0 then
        print("免费游戏", playerStatusRet.current_count)
        --如果不是免费游戏的最后一把
        if playerStatusRet.current_count < playerStatusRet.total_count then
            resume.enterBase.enterMoney = resume.resumedNormal.normalSpin.slotMoney.money
        end
        if playerStatusRet.current_count == 0 then
            --普通中奖免费
            resume.type = 1
        else
            resume.type = 2
            resume.resumedFree.freeSpin.intoSpecial = 0
        end
        --特殊游戏总次数大于零
    elseif playerStatusRet.special_total_count > 0 then
        print("特殊游戏", playerStatusRet.current_special_count)
        if playerStatusRet.current_special_count < playerStatusRet.special_total_count then
            resume.enterBase.enterMoney = resume.resumedNormal.normalSpin.slotMoney.money
        end
        --特殊游戏开始次数为零
        if playerStatusRet.current_special_count == 0 then
            resume.type = 1
            local symbolVal = self:getSymbolValueByObj(resume.resumedNormal.normalSpin.grids)
            resume.currentWinCoin = resume.currentWinCoin + symbolVal
        else
            local symbolVal = self:getSymbolValueByObj(resume.resumedSpecial.specialSpin.grids)
            resume.currentWinCoin = resume.currentWinCoin + symbolVal
            resume.type = 3
        end
    end
end

function cls:getSymbolValueByObj(grids)
    local val = 0
    for k, v in ipairs(grids) do
        val = val + v.SymbolValue
        print(val)
    end
    return val
end

function cls:parseLine(obj)
    return {
        lineIndex = obj.line_index,
        winCoin = obj.win,
        icon = obj.icon,
        lineCells = self:parseGrids(obj.line_cells),
    }
end

function cls:parseLines(dataObj)
    local ret = {}
    for k, val in ipairs(dataObj) do
        ret[k] = self:parseLine(val)
    end
    return ret
end

function cls:parseGrid(v)
    return {
        index = v.index,
        icon = v.icon,
        SymbolType = v.symbol_type,
        SymbolValue = v.symbol_value
    }
end

function cls:parseGrids(dataObj)
    local ret = {}
    for k, val in ipairs(dataObj) do
        ret[k] = self:parseGrid(val)
    end
    return ret
end

return cls
