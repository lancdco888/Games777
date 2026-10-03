---@class GameProtocolHub 转换web端 json->protobuffer 基础
local GameProtocolHub = class("GameProtocolHub")


---最后一次接收到的金币change消息
GameProtocolHub.LAST_MONEY_CHANGE_DATA = nil
---@field 金币类型 number
GameProtocolHub.MONEY_TYPE = 0

local function IsInvalidObject(t)
    return t == nil or t == cjson.null
end

---存储上一次12选3恢复数据,再次中12选3时需要清空
function GameProtocolHub:setRestore12X3Data(aData)
    self.restoreCollectData = {}
    table.merge(self.restoreCollectData,aData)
end

function GameProtocolHub:ParseNetwork(aData)
    if aData then
        local jsonDataStr = aData.getOriginJsonString()
        local jsonData = cjson.decode(jsonDataStr)
        if jsonData then
            if jsonData.func == "NormalSpinRet" then
                local ret = self:parseNormalSpinRet(jsonData.context)
                ---处理12选3
                self:checkNormalCollectData(ret, jsonData.context)
                self:checkAndResetCollectData(jsonData.context)
                return ret
            elseif jsonData.func == "FreeSpinRet" then
                self:checkAndResetCollectData(jsonData.context)
                return self:parseFreeSpinRet(jsonData.context)
            elseif jsonData.func == "SpecialSpinRet" then
                self:checkAndResetCollectData(jsonData.context)
                return self:parseSpecialData(jsonData.context)
            elseif jsonData.func == "LotteryInfoRet" then
                return self:parseLotteryData(jsonData.context)
            elseif jsonData.func == "MoneyChanged" then
                return self:parseMoneyChangeData(jsonData.context)
            elseif jsonData.func == "CollectWinRet" then
                return self:parseCollectData(jsonData.context)
            elseif jsonData._h5Func_ == "Leave" then
                if jsonData.func == "Success" then
                    return { _msgName_ = "PB.Slots_Client.Leave_Success" }
                end
            elseif jsonData._h5Func_ == "FreeSpinType" then
                return self:parseFreeSpinType(jsonData)
            end
        end
    end
end

function GameProtocolHub:ConvertEnterData(aEnter, aResume)
    local enterData              = {}
    enterData.accountId          = aEnter.account_info.account_id
    enterData.userName           = "";
    enterData.nickName           = aEnter.account_info.nickname;
    enterData.avatarId           = aEnter.account_info.avatar_id;
    enterData.enterMoney         = aEnter.account_info.money;
    enterData.enterMoneySalfe    = aEnter.account_info.money_safe;
    enterData.enterMoneyGift     = aEnter.account_info.money_gift;
    enterData.enterMoneyGiftSafe = aEnter.account_info.money_gift_safe;
    enterData.tableSize          = aEnter.table_size;
    enterData.chairSize          = aEnter.seat_size;
    enterData.tableId            = -1;
    enterData.chairId            = -1;
    enterData.moneyType          = aEnter.last_money_type;
    enterData.players            = {}

    GameProtocolHub.MONEY_TYPE   = enterData.moneyType


    enterData.betRatios = {}
    for key, value in ipairs(aEnter.bet_ratios) do
        table.insert(enterData.betRatios, {
            lvID = value.level_id,
            betMoney = value.bet_money,
            betLine = value.bet_line,
        })
    end

    enterData.entryConditions = {}

    for index, value in ipairs(aEnter.game_levels) do
        table.insert(enterData.entryConditions, {
            id = value.level_id,
            spinMinMoney = value.spin_min_money,
            spinMaxMoney = value.spin_max_money,
            enterMinMoney = value.enter_min_money,
            desc = value.level_desc,
            c_value = value.c_value,
            c_lottery_value = value.c_lottery_value,
        })
    end

    enterData.enterSlotMoneyGift = {
        money_gift = aEnter.account_info.money_gift,
        money_gift_safe = aEnter.account_info.money_gift_safe,
        amount_of_gift = 0,
    }

    enterData.enterSlotMoney = {
        money = aEnter.account_info.money,
        money_safe = aEnter.account_info.money_safe,
    }


    if self:checkDataValide(aResume) then
        if not self:checkDataValide(aResume.last_state) then
            aResume = nil
        elseif self:checkDataValide(aResume.normal_spin_ret) then
            ---在普通中查询是否有12选3,并保存上一次12选3数据
            if self:checkIsIntoCollect(aResume.normal_spin_ret) then
                self:setRestore12X3Data(aResume.collect_indexes)
            end
        end
    end


    local resumeData = self:parseResumeData(aEnter, enterData, aResume)
    if self:checkDataValide(aResume) and
        self:checkDataValide(aResume.normal_spin_ret) then            
        self:checkResumeCollectData(aResume.normal_spin_ret, resumeData)
    end    


    return enterData, resumeData;
end

function GameProtocolHub:convertMoneyGift(aData)
    return {
        money_gift = aData.money_gift,
        money_gift_safe = aData.money_gift_safe,
        amount_of_gift = 0,
    }
end

function GameProtocolHub:convertMoney(aData)
    return {
        money = aData.money,
        money_safe = aData.money_safe,
    }
end

---重置12选3数据
function GameProtocolHub:checkAndResetCollectData(aJson)
    if self:checkIsIntoCollect(aJson) then
        self.restoreCollectData = {}
    end
end

---如果进入12选3 ,服务器没有下发中奖后的数据
---这里需要把数据修改成pb服务器下发的数据
---@param aNromalData table 已经转成pb的数据,
---@param aNormalJson table rust下发的json数据
function GameProtocolHub:checkNormalCollectData(aNromalData, aNormalJson)
    if self:checkIsIntoCollect(aNormalJson) then
        local winCoin = 0
        for index, value in ipairs(aNormalJson.lines) do
            if self:checkDataValide(value.winCoin) then
                winCoin = winCoin + value.winCoin
            elseif self:checkDataValide(value.win) then
                winCoin = winCoin + value.win
            else
                print("12选3 line的字段不是wincoin或者win.")
            end
        end
        aNromalData.normalSpin.winCoin = winCoin

        if type(aNormalJson.slotMoney) == "table" then
            local win = 0
            if self:checkDataValide(aNormalJson.winCoin) then
                win = aNormalJson.winCoin
            else
                win = aNormalJson.win
            end
            aNromalData.normalSpin.slotMoney.money = aNormalJson.slotMoney.money - win + winCoin
        else
            aNromalData.normalSpin.slotMoney.money = aNormalJson.money - aNormalJson.win + winCoin
        end
    end
end

---如果进入12选3 ,服务器没有下发中奖后的数据
---这里需要把数据修改成pb服务器下发的数据
---@param aEnterData table 已经转成pb的数据,
---@param aResumeNormalJson table rust下发的json数据
---@param aResumeData table 已转成pb的数据
function GameProtocolHub:checkResumeCollectData(aResumeNormalJson, aResumeData)
    if self:checkIsIntoCollect(aResumeNormalJson) then
        if aResumeData.resumedNormal and aResumeData.resumedNormal.normalSpin then
            local winCoin = 0
            for index, value in ipairs(aResumeNormalJson.lines) do
                if self:checkDataValide(value.winCoin) then
                    winCoin = winCoin + value.winCoin
                elseif self:checkDataValide(value.win) then
                    winCoin = winCoin + value.win
                else
                    print("12选3 line的字段不是wincoin或者win.")
                end
            end

            aResumeData.resumedNormal.normalSpin.winCoin = winCoin
            aResumeData.resumedNormal.normalSpin.slotMoney.money = aResumeNormalJson.money - aResumeNormalJson.win +
                winCoin
        else
            print("进入12选3 ,但是恢复数据里面pb没有找到resumedNormal.normalSpin")
        end
    end
end

function GameProtocolHub:checkIsIntoCollect(aData)
    return self:checkDataValide(aData.is_collect) and aData.is_collect
end

function GameProtocolHub:parseLotteryData(aContext)
    local result = {}
    result._msgName_ = "PB.Support_Other.OneGameLotteryRet"
    result.infos = {}
    for index, value in ipairs(aContext.info) do
        result.infos[index] = {
            --[Desc("彩金ID")]
            lotteryID = value.lottery_id,

            --[Desc("大厅展示 0不展示  1,是基本展示,101-福树 102-冒火 103-闪电")]
            hallShow = value.hall_show,

            --[Desc("彩金类型 0为常规 其他为有奖 1普通奖励 2小奖分值 3中奖分值 4大奖分值 5巨奖分值")]
            lType = value.lottery_type,

            --[Desc("彩金的属性:0倍数还是 1钱")]
            betOrMoney = value.bet_or_money,

            --[Desc("当前的彩金值/彩金倍数")]
            lReal = value.lottery_real,

            --[Desc("彩金属性为倍数时,彩金最小倍数")]
            lMinBet = value.lottery_min_bet,

            --[Desc("彩金属性为倍数时,彩金最大倍数")]
            lMaxBet = value.lottery_max_bet,

            --[Desc("该彩金最小的押注,超过该值才能影响彩金的变动")]
            coinMin = value.coin_min,

            --[Desc("该彩金的增量 ,用于客服端模拟自增")]LotteryInfo
            setp = 0,

            --[Desc("该彩金关联的游戏")]
            gameIDs = value.game_ids,
        }
    end
    return result
end

---返回cjson转换的字段是否是空
---@param aData any
function GameProtocolHub:checkDataValide(aData)
    return not IsInvalidObject(aData)
end

function GameProtocolHub:parseCollectData(aContext)
  
end

function GameProtocolHub:parseMoneyChangeData(aContext)
    --{"money":75659772286,"money_safe":0,"money_gift":0,"money_gift_safe":0,"total_refund":0,"total_recharge":0,"vip_level":-1}
    local result = {}
    result._msgName_ = "MoneyChanged"
    result.slotMoney = self:convertMoney(aContext);
    result.slotMoneyGift = self:convertMoneyGift(aContext);
    GameProtocolHub.LAST_MONEY_CHANGE_DATA = result
    return result
end

---转换恢复数据,
---公共解析了pb中的enterBase,currentBetMoney,lvID
---如果是pb协议不一致,需要重新覆盖
function GameProtocolHub:parseCommonResumeData(aEnterData, aResumeJson, aResumeData)
    aResumeData.enterBase = aEnterData
    aResumeData.lvID = aResumeJson.last_level_id
    if not aResumeData.lvID or aResumeData.lvID <= 0 then
        aResumeData.lvID = aEnterData.betRatios[1].lvID
    end
    aResumeData.currentBetMoney = aResumeJson.last_bet_money or 0
end

function GameProtocolHub:parseResumeData(aEnterJson, aEnterData, aResumeJson)
    print("parseResumeData 需要子类覆盖")
end

function GameProtocolHub:parseSpecialData(aContext)
    print("parseSpecialData 需要子类覆盖")
end

function GameProtocolHub:parseNormalSpinRet(aContext)
    print("parseNormalSpinRet 需要子类覆盖")
end

function GameProtocolHub:parseFreeSpinRet(aContext)
    print("parseFreeSpinRet 需要子类覆盖")
end

function GameProtocolHub:parseFreeSpinType(aContext)
    print("ParseFreeSpinType 需要子类覆盖")
end

---返回服务器下发的是否是使用绑定金
---@param aEnterJson table   服务器下发的json数据
function GameProtocolHub:getIsUseBindMoney(aEnterJson)
    return aEnterJson.last_money_type == 1
end

-----------------------------------network transfrom ------------------------------------

local _transfromPipline = nil
function GameProtocolHub:getTransfrom2ServerPipline()
    if not _transfromPipline then
        _transfromPipline = {}
        _transfromPipline[1] = self.transformNormalSpin
        _transfromPipline[2] = self.transformFreeType
        _transfromPipline[3] = self.transformFreeSpin
        _transfromPipline[4] = self.transformSpecialSpin
        _transfromPipline[5] = self.transformCoinInfo
        _transfromPipline[6] = self.transformLeave
    end
    return _transfromPipline
end

function GameProtocolHub:transformToServer(aMsg)
    local pipes = self:getTransfrom2ServerPipline()
    for index, pip in ipairs(pipes) do
        local msg = pip(self, aMsg)
        if msg then
            return msg
        end
    end
end

---解释普通旋转协议
function GameProtocolHub:transformNormalSpin(aMsg)
    if string.endsWith(aMsg._msgName_, "NormalSpin") then
        local msg =
        {
            _h5MsgName_ = "func",
            func = "NormalSpin",

            context = {
                bet_money = aMsg.betMoney,
                money_type = aMsg.moneyType,
                game_level_id = aMsg.lvID
            }
        }
        return msg
    end
end

---解释免选类型选择协议
function GameProtocolHub:transformFreeType(aMsg)
    if string.endsWith(aMsg._msgName_, "FreeType") then
        local msg =
        {
            _h5MsgName_ = "func",
            func = "FreeSpinType",

            context = {
                free_type = aMsg.index
            }
        }
        return msg
    end
end

---解释免费旋转协议
function GameProtocolHub:transformFreeSpin(aMsg)
    if string.endsWith(aMsg._msgName_, "FreeSpin") then
        local msg =
        {
            _h5MsgName_ = "func",
            func = "FreeSpin",
            context = {

            }
        }
        return msg
    end
end

---解释特殊旋转(落地牌)
function GameProtocolHub:transformSpecialSpin(aMsg)
    if string.endsWith(aMsg._msgName_, "SpecialSpin") then
        local msg =
        {
            _h5MsgName_ = "func",
            func = "SpecialSpin",

            context = {
            }
        }
        return msg
    end
end

---解释12选3协议
---H5服务器和c++不同.一次只接收一次新增数据,需要
---找到新增的再发给TS
function GameProtocolHub:transformCoinInfo(aMsg)
    if string.endsWith(aMsg._msgName_, "CionInfo") then
        
        local tempCells = {}
    
        table.merge(tempCells,aMsg.cells)
        local sendCells = {}
        
        if self.restoreCollectData then
            for i = #self.restoreCollectData + 1, #aMsg.cells do
                table.insert(sendCells,aMsg.cells[i])
            end
        else
            table.merge(sendCells,aMsg.cells)
        end
    
        ---存储新12X3数据
        self.restoreCollectData = tempCells

        local msg =
        {
            _h5MsgName_ = "func",
            func = "CollectClick",
            complete = true,
            context = {
                index = sendCells
            }
        }
        return msg
    end
end

---解释离开协议
function GameProtocolHub:transformLeave(aMsg)
    if string.endsWith(aMsg._msgName_, "Leave") then
        local msg =
        {
            _h5MsgName_ = "func",
            func = "Leave",

            context = {
            }
        }
        return msg
    end
end

return GameProtocolHub
