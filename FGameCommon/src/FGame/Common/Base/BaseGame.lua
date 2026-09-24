--[[
    游戏基类
]]
---@class BaseGame
local BaseGame = Class("BaseGame")

function BaseGame:ctor()
    self.bExiting = false

    -- 监听网络断开事件
    FSysEventEmitter:AddListener(FSysEvent.ON_NET_DISCONNECT, function()
        self.curNormalSpinResult = nil
        self.curFreeSpinResult = nil
        self.curSpecialSpinResult = nil
    end, self)

    -- 游戏转轴状态错误事件
    FSysEventEmitter:AddListener(FSysEvent.ON_GAME_REEL_STATE_ERROR, function()
        APIGateway.ShowMessageBox(APIGateway.GetLangText("fgame_6"), function()
            self:DoExitGame()
        end)
    end, self)
end

function BaseGame:__delete()
    if self.gameRulePanel then
        self.gameRulePanel:Delete()
        self.gameRulePanel = nil
    end
    if not APIGateway.IsInvalidObject(self.fadeoutPanel) then
        self.fadeoutPanel:RemoveFromParent(true)
        self.fadeoutPanel = nil
    end
    FSysEventEmitter:RemoveListenersByTag(self)
end

-- @interface
-- @brief 点击返回按钮
function BaseGame:OnClickBack()
    if FCasinoCtx == nil then return end
    if FTheme.curPkgName == "Theme_CrimsonCartoon" then
        FCasinoCtx.commonPanel.bottomPanel:OnClickExitGame()
    else
        APIGateway.ShowMessageBox(APIGateway.GetLangText("fgame_2"), handler(self, self.DoExitGame), function() end)
    end
end

function BaseGame:DoExitGame()
    if FCasinoCtx == nil then return end
    if self.bExiting then return end
    self.bExiting = true

    if self.fadeoutPanel then
        self.fadeoutPanel:RemoveFromParent(true)
        self.fadeoutPanel = nil
    end

    self.fadeoutPanel = FairyGUI.UIPackage.CreateObjectFromURL("ui://Basics/FadeoutPanel")
    self.fadeoutPanel:MakeFullScreen()
    GetFairyRoot():AddChild(self.fadeoutPanel)
    self.fadeoutPanel.sortingOrder = 0xffff
    
    APIGateway.SendExactRequest({ _msgName_ = "PB.Client_Slots.Leave" }, "PB.Slots_Client.Leave_Success", function(ok, result)
        self.bExiting = false
        if ok then
            if RUNTIME_IN_COCOS and ax and not RUNTIME_IN_COCOS_H5 and not RUNTIME_IN_COCOS_NEONARCADE then
                if asyncSendEnterLobbyRequest then
                    asyncSendEnterLobbyRequest(nil, true)
                end
                
                -- 防止动画播放失败
                StartOnceTimer(function() DestroyCasino() end, 1)
                
                -- 播放过渡动画
                if APIGateway.IsInvalidObject(self.fadeoutPanel) then
                    DestroyCasino()
                else
                    self.fadeoutPanel:GetTransition("t0"):Play(function()
                        print("手动退出游戏返回大厅")
                        DestroyCasino()
                    end)
                end
            else
                print("手动退出游戏返回大厅")
                DestroyCasino()
            end
        else
            if not APIGateway.IsInvalidObject(self.fadeoutPanel) then
                self.fadeoutPanel:RemoveFromParent(true)
                self.fadeoutPanel = nil
            end
        end
    end)
end

-- @interface
-- @brief 点击开始按钮
function BaseGame:OnClickSpin()
    assert(false, "not implemented")
end

-- @interface
-- @brief 点击停止按钮
function BaseGame:OnClickStop()
    assert(false, "not implemented")
end

-- @interface
-- @brief 显示游戏规则
function BaseGame:OnShowGameRule()
    if self.gameRulePanel then return end

    self.gameRulePanel = FTheme.Require("GameRulePanel").New()
    self.gameRulePanel:SetDestroyCallback(function()
        self.gameRulePanel:Delete()
        self.gameRulePanel = nil
    end)
end

-- @interface
-- @brief update
function BaseGame:Update(dt)
end

-- @interface
-- @brief 在游戏中断线重连恢复游戏
-- @param msg 断线重连数据
-- @param isInitialize 
function BaseGame:ReconnectRecoveryGame(msg, isInitialize)
end

-- @brief 发送普通旋转请求
-- @param msgName
-- @param call 结果回调
function BaseGame:SendNormalSpin(msgName, resultMsgName, call)
    local msg = {
        _msgName_ = msgName,
        betMoney = FCasinoCtx.commonPanel:GetBetMoney(),
        moneyType = FCasinoCtx.commonPanel:GetMoneyType(),
        lvID = FCasinoCtx.commonPanel:GetCurrentBetConfig().rawLvId,
    }
    APIGateway.SendExactRequest(msg, resultMsgName, function(ok, result)
        self.lastNormalSpinResult = clone(result)
        if call then call(ok, result) end
    end)
end

-- @brief 旋转容错保护,是否阻断 OnClickSpin 函数调用
function BaseGame:SpinFaultToleranceProtection()
    if FCasinoCtx.curGameMode ~= FGameMode.NORMAL then
        return false
    end
    
    if BaseReel.IsAllInNoneState() then
        -- 正常状态，不阻断
        self.lastFaultToleranceTime = nil
        return false
    end

    if self.lastFaultToleranceTime == nil then
        -- 阻断
        self.lastFaultToleranceTime = FCasinoCtx.runningTime
        print("阻断 OnClickSpin 函数调用(1)")
        return true
    else
        if FCasinoCtx.runningTime - self.lastFaultToleranceTime > 5 then
            -- 阻断超时
            self.lastFaultToleranceTime = nil
            return false
        end
        -- 阻断
        print("阻断 OnClickSpin 函数调用(2)")
        return true
    end
end

-- @brief 播放Spin按钮点击音效
function BaseGame:PlaySpinButtonClickSound()
    local url = string.format("ui://%s/dafu_common_click", FTheme.curPkgName)
    FToolSet.PlayFGUISound(url, false)
end

return BaseGame