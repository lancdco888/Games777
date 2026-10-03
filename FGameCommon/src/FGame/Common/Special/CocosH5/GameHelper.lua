local EventEmitter = require("FGame.Common.Utils.EventEmitter")
local DataDecoder = require("FGame.Common.Special.CocosH5.Creator.DataDecoder")
local GameHelper = Class("GameHelper", EventEmitter)

local DEBUG_ENABLE = false
local dumpMsg = dump
if not DEBUG_ENABLE then 
    dumpMsg = function() end
end

local function sendRequestAndRetry(msg)
    local result = gNetMgr:sendRequestPostToGame(msg)

    -- 模拟请求失败
    if SIMULATION_REQUEST_FAILED then
        SIMULATION_REQUEST_FAILED = false
        return
    end

    if result then
        -- 打印错误信息
        if result.func == "GeneralError" then
            dump(result)
        end
        return result 
    else
        dump(msg, "请求失败")
    end
end

function GameHelper:ctor()
    local gameView = gViewManager:getCurView()

    self.serverStatus = gameView.serverStatus
    self.gameConfigData = gameView.gameConfigData
    self.styleConfigData = gameView.styleConfigData

    self.isFirstNormalSpin = gameView.lastResumeData == nil
    gameView.lastResumeData = nil
    
    self:requestLotteryData()

    gNetMgr.gameSession:on("message", function(msg)
        GameHub:ParseNetwork({
            getOriginJsonString = function()
                return msg.data
            end
        })
    end, self)
    
    gSysEventEmitter:on(SysEvent.ON_MSG_LOGIN_SUCCESS, function()
        if self.showExitWhenLoginSuccess then
            local info = self.showExitWhenLoginSuccess
            self.showExitWhenLoginSuccess = nil
            go(function()
                print("自动退出游戏：", info.title)
                DestroyCasino()
                sleep(0.5)
                Utils:showToastText(info.title)
            end)
            return
        end

        if self.autoReconnectWhenLoginSuccess then
            self.autoReconnectWhenLoginSuccess = false
            go(function() self:doReconnect(true) end)
        end
    end, self)
    gSysEventEmitter:on(SysEvent.ON_MSG_SHOW_SERVICE_RED_DOT, function(visible)
        FSysEventEmitter:Emit(FSysEvent.ON_UPDATE_SERVICE_RED_DOT, visible)
    end, self)
end

-- @brief 请求彩金数据
function GameHelper:requestLotteryData()
    local msg = {
        func = "GetLotteryInfo",
        context = {}
    }

    self.lotteryTask = go(function()
        repeat
            local result = gNetMgr:sendRequestPostToGame(msg)

            if result then
                result = GameHub:ParseNetwork(DataDecoder:parseData(msg, result))
                if result then
                    self:Emit(result._msgName_, result)
                end
                sleep(5)
            else
                sleep(1)
            end
        until (FCasinoCtx == nil)
    end)
end

function GameHelper:__delete()
    gNetMgr.gameSession:offByTag(self)
    gSysEventEmitter:offByTag(self)
    kill(self.lotteryTask)
end

function GameHelper:sendRequest(pbMsg, callback)
    if self.isReconnecting or self.stopAllRequest then
        print("Status:", self.stopAllRequest, self.isReconnecting)
        dump(pbMsg, "发送失败-正在重连中")
        return
    end
    go(function()
        dumpMsg(pbMsg, "[发送]-原始数据")
        local msg = GameHub:transformToServer(pbMsg)
        dumpMsg(msg, "[发送]-转换后的数据")

        if not msg then
            dump(msg, "协议转换失败")
            return
        end

        -- 如果第一次普通旋转失败了,在重连成功后重新发送消息
        if self.isFirstNormalSpin and string.endsWith(string.lower(pbMsg._msgName_), "normalspin") then
            self.onReconnectCallback = function()
                -- 游戏已销毁
                if FCasinoCtx == nil then return end

                print("重新发送AAA")
                self:sendRequest(pbMsg, callback)
            end
        else
            self.onReconnectCallback = nil
            self.isFirstNormalSpin = false
        end
        
        local result = self:sendPackage(msg)
        dumpMsg(result, "[收到]-原始结果")
        if result then
            self.isFirstNormalSpin = false
            self.onReconnectCallback = nil
            result = GameHub:ParseNetwork(DataDecoder:parseData(msg, result))
            dumpMsg(result, "[收到]-转换后的结果")
        end

        if self.onReconnectCallback == nil then
            if FCasinoCtx and callback then
                callback(result ~= nil, result)
            end
        end
    end)
end

function GameHelper:sendPackage(msg)
    -- 十二选三消息单独处理
    if msg and msg.func == "CollectClick" then
        return self:sendCollects(msg)
    end

    -- 等待十二选三完成
    while self.isSendingCollect do
        sleep(0.1)
    end

    if self.isReconnecting or self.stopAllRequest then
        print("Status:", self.stopAllRequest, self.isReconnecting)
        dump(pbMsg, "发送失败-正在重连中2")
        return
    end

    local result = sendRequestAndRetry(msg)
    
    -- 退出游戏消息无论是否请求成功都返回成功
    if msg and msg.func == "Leave" then
        return {
            func = "Success",
            context = {},
        }
    end

    if self:checkNetworkData(result) then
        self:onNetworkError(result)
    end
    return result
end

-- @brief 十二选三
function GameHelper:sendCollects(msg)
    local willSend = msg.context.index
    if type(willSend) ~= "table" then
        willSend = { willSend }
    end
    if #willSend <= 0 then
        print("12x3发送了无效数据")
        return
    end

    self.isSendingCollect = true
    local newMsg = clone(msg)
    while true do
        if #willSend <= 0 then break end
        if self.stopAllRequest then break end

        newMsg.context = {}
        newMsg.context.index = table.remove(willSend, 1)
        dumpMsg(newMsg, "[发送]-转换后的12x3数据")

        local result = sendRequestAndRetry(newMsg)
        -- 网络出错
        if self:checkNetworkData(result) then
            self.isSendingCollect = false
            self:onNetworkError(result)
            dump(result, "12x3出错")
            return
        end
    end
    self.isSendingCollect = false

    -- 模拟一个假的结果
    return {
        func = "Success",
        context = {}
    }
end

function GameHelper:checkNetworkData(result)
    if result == nil then return true end

    if result.func then
        if result.func == "GeneralError" then
            dump(result)
            return true
        end
    end

    return false
end

-- @brief 网络请求出错
function GameHelper:onNetworkError(result)
    -- token无效了,直接返回大厅
    if Utils:isTokenError(result) then
        print("token无效了,返回大厅")
        self.stopAllRequest = true
        -- 服务器内部错误,请返回大厅重新进入
        APIGateway.ShowMessageBox(TR("lobby_29"), DestroyCasino)
        self.showExitWhenLoginSuccess = {
            title = TR("lobby_29")
        }
        killSelf()
        return
    end
    
    -- 金币不足,返回大厅
    -- result.context.msg = "not enough money"
    if result and result.context and result.context.msg == "not enough money" then
        dump(result, "金币不足,返回大厅")
        self.stopAllRequest = true
        APIGateway.ShowMessageBox(TR("fgame_1"), DestroyCasino)
        self.showExitWhenLoginSuccess = {
            title = TR("fgame_1")
        }
        killSelf()
        return result
    end

    if result and result.context and result.context.error_id then
        dump(result, "服务器报错")
        -- 游戏错误,请返回大厅重新进入
        local tipStr = TR("lobby_28")
        
        -- {"error_id":-1000001,"msg":"error:not found account:35860324 info"}
        if result.context.error_id == -1000001 and type(result.context.msg) == "string" and string.find(result.context.msg, "not found account") then
            -- 账号被封提示
            tipStr = TR("lobby_36")
        end

        self.stopAllRequest = true
        APIGateway.ShowMessageBox(tipStr, DestroyCasino)
        self.showExitWhenLoginSuccess = {
            title = tipStr
        }
        killSelf()
        return result
    end

    go(function()
        -- 开始重连游戏
        self:doReconnect()
    end)
end

-- @brief 获取当前玩家状态
function GameHelper:sendGetCurrentStatus()
    local playerStatus = sendRequestAndRetry({
        func = "GetCurrentStatus"
    })

    if playerStatus and playerStatus.func == "PlayerStatusRet" then
        playerStatus = playerStatus.context
        local state = playerStatus.state
        
        if type(state) == 'table' then
            -- 在游戏中
            if state.Gaming then
                self.serverStatus = playerStatus
                return true
            else
                self.isTokenError = true
                dump(state, "未知状态")
                return
            end
        end
    end
    self.isTokenError = Utils:isTokenError(playerStatus)
    dump(playerStatus, "玩家状态获取失败")
end

-- @brief 获取最后spin状态
function GameHelper:sendGetLastSpinResult()
    local result = sendRequestAndRetry({
        func = "GetLastSpinResult"
    })

    if result and result.func == "LastSpinRet" then
        self.lastSpinResult = result.context
        return true
    end
    self.isTokenError = Utils:isTokenError(result)
    dump(result, "Spin结果获取失败")
end

function GameHelper:doReconnect(isRetry)
    if FCasinoCtx == nil then return end

    if self.isReconnecting then return end
    self.isReconnecting = true
    self.stopAllRequest = true

    if not isRetry then
        FSysEventEmitter:Emit(FSysEvent.ON_NET_DISCONNECT)
    end

    self.isTokenError = false
    print("重连开始")
    if self:sendGetCurrentStatus() and self:sendGetLastSpinResult() then
        self.isReconnecting = false
        self.stopAllRequest = false
        print("重连成功")
        if self.onReconnectCallback then
            -- 第一次普通spine重试，当做没有断线重连
            self.lastSpinResult = nil
            self.onReconnectCallback()
        end
        return
    end
    print("重连失败")
    self.isReconnecting = false

    -- token无效了,直接返回大厅
    if self.isTokenError then
        print("token无效了,返回大厅")
        -- 服务器内部错误,请返回大厅重新进入
        APIGateway.ShowMessageBox(TR("lobby_29"), DestroyCasino)
        self.showExitWhenLoginSuccess = {
            title = TR("lobby_29")
        }
        return
    end

    print("网络连接失败,返回大厅")

    -- 网络连接失败，是否重试
    local isSelect = false
    local msgBox = APIGateway.ShowMessageBox(TR("lobby_27"), function()
        isSelect = true
        go(function() self:doReconnect(true) end)
    end, 
    function()
        isSelect = true
        DestroyCasino()
    end)

    if msgBox then
        msgBox:eventOn(SysEvent.UI_WILL_DESTROY, function()
            if not isSelect then
                self.autoReconnectWhenLoginSuccess = true
            end
        end, self)
    end
end

-- @brief 是否开启绑定金
function GameHelper:bindGoldCoinEnabled()
    return self.styleConfigData.website_switch and self.styleConfigData.website_switch.bind_money
end

-- @brief 当前玩家是否是VIP
function GameHelper:isVIP()
    return self.serverStatus.account_info.vip_level > 0
end

-- @brief 大厅汇率
function GameHelper:getExchangerate()
    return self.serverStatus.account_info.money_exchange_coin
end

-- @brief 游戏汇率
function GameHelper:getGameExchangerate()
    return self.serverStatus.game_levels[1].c_value
end

-- @brief 彩金显示模式 根据押注
function GameHelper:isLotteryBetMode()
    return self.gameConfigData.slots_bet_lottery_mode == 0
end

-- @brief 大厅界面选择的押注(C位)信息
function GameHelper:getCurSlotsLevel()
end

-- @brief 洗码模式 0=常规洗码 1=必须有压住的金币才能洗码
function GameHelper:getWashCodeMode()
    return self.serverStatus.account_info.wash_code_mode
end

function GameHelper:getGameReconnectData()
    if self.lastSpinResult == nil then return end
    
    local enterData, resumeData = GameHub:ConvertEnterData(self.serverStatus, self.lastSpinResult)
    self.lastSpinResult = nil

    return resumeData
end

return GameHelper
