local GameBetListPanel = Import(".GameBetListPanel")
local BettingOptions = Import("..BettingOptions")
local AutoSpinListPanel = Import(".AutoSpinListPanel")
local SpinButtonCfg = Import("..Cfg.SpinButtonCfg")

local BottomPanel = Class("BottomPanel")

function BottomPanel:ctor(render)
    self.render = render
    -- 玩家本局赢的金币
    self.text_win = render:GetChild("text_win")
    -- 玩家本局赢的金币(大厅汇率)
    self.text_lobby_win = render:GetChild("text_lobby_win")
    self.text_lobby_win.visible = false
    -- 玩家当前押注
    self.text_bet = render:GetChild("text_bet")
    -- 玩家当前押注(大厅汇率)
    self.text_lobby_bet = render:GetChild("text_lobby_bet")
    self.text_lobby_bet.visible = false

    -- 押注调节按钮(-)
    self.btn_bet_pre = render:GetChild("btn_bet_pre")
    -- 押注调节按钮(+)
    self.btn_bet_next = render:GetChild("btn_bet_next")

    -- 最大押注按钮
    self.btn_max = render:GetChild("btn_max")
    --  加速按钮
    self.btn_accelerate = render:GetChild("btn_accelerate")
    -- spin
    self.btn_spin = render:GetChild("btn_spin")
    -- 选C按钮
    self.btn_betlvID = render:GetChild("btn_betlvID")
    -- 规则按钮
    self.btn_rule = render:GetChild("btn_rule")
    -- 面额切换按钮
    self.btn_changeDenomination = render:GetChild("btn_changeDenomination")
    -- 打开自动spin列表按钮
    self.btn_openAutoList = render:GetChild("btn_openAutoList")

    -- spin按钮上显示的自动次数
    self.auto_spin_num = self.btn_spin:GetChild("auto_spin_num")
    self.auto_spin_num.visible = false

    -- text_debug
    local text_debug = render:GetChild("text_debug")
    if text_debug then
        text_debug.visible = false
        if RUNTIME_IN_COCOS and isShowDebugInfo and isShowDebugInfo() and FTheme.curThemCfg and FTheme.curThemCfg.version then
            text_debug.text = "version:" .. tostring(FTheme.curThemCfg.version)
            text_debug.visible = true
        end
    end

    FToolSet.AddClickListener(self.btn_bet_pre,    handler(self, self.OnClickBetReduce), false)
    FToolSet.AddClickListener(self.btn_bet_next,   handler(self, self.OnClickBetIncrease), false)
    FToolSet.AddClickListener(self.btn_max,        handler(self, self.OnClickBetMax), false)
    FToolSet.AddClickListener(self.btn_betlvID,    handler(self, self.OnClickBetLvID), false)
    FToolSet.AddClickListener(self.btn_accelerate, handler(self, self.OnClickAccelerate), false)
    FToolSet.AddClickListener(self.btn_changeDenomination, handler(self, self.OnClickBetLvID), false)
    FToolSet.AddClickListener(self.btn_openAutoList, handler(self, self.OnClickOpenAutoList), false)

    
    FToolSet.AddClickListener(render:GetChild("btn_click_win"), handler(self, self.OnClickWinMoney), false)
    FToolSet.AddClickListener(render:GetChild("btn_click_bet"), handler(self, self.OnClickBetMoney), false)

    self.btn_spin:AddEventListener(FGUIEventKey.onTouchBegin, handler(self, self.OnTouchSpinBegin))
    self.btn_spin:AddEventListener(FGUIEventKey.onTouchEnd, handler(self, self.OnTouchSpinEnd))
    self.btn_spin:AddEventListener(FGUIEventKey.onClick, function()
        if FCasinoCtx then
            FCasinoCtx:GetGame():PlaySpinButtonClickSound()
        end
    end)

    --调试 模拟点击
    if DebugSlots then
        DebugSlots:BottomPanelSpin( self, 
            handler(self, self.OnTouchSpinBegin), handler(self, self.OnTouchSpinEnd)
        )
    end

    -- 游戏规则按钮
    FToolSet.AddClickListener(self.btn_rule, function()
        FCasinoCtx:GetGame():OnShowGameRule()
    end, false)

    if FConfig.Common.IsReviewVersion then
        self.btn_openAutoList.visible = false
        if not APIGateway.IsDeviceOrientationPortrai() then
            self.btn_max.x = self.btn_max.x + 60
            self.btn_changeDenomination.x = self.btn_changeDenomination.x + 60
        end
    end

    -- 进入游戏自动弹出自动Spin和选C列表
    if not FCasinoCtx.reconnectData and not RUNTIME_USE_H5_PROTO then
        if FConfig.Common.IsReviewVersion then
            return
        end

        self.delayShowAutoSpinListPanelTimer = StartOnceTimer(function()
            self.delayShowAutoSpinListPanelTimer = nil
            self:ShowAutoSpinListPanel()
            if self.btn_betlvID.visible then
                self:ShowBetListPanel()
                self.betListPanel:disableBlankClick()
            end

            StartOnceTimer(function()
                self:CloseBetListPanel()
                self:CloseAutoSpinListPanel()
            end, 4)
        end, 0)
    end
end

function BottomPanel:__delete()
    self:StopPressTimer()
    self:CloseBetListPanel()
end

-- @brief 点击减少押注按钮
function BottomPanel:OnClickBetReduce()
    -- 在公共面板中处理
    FCasinoCtx.commonPanel:OnBetStep(-1)
end

-- @brief 点击增加押注按钮
function BottomPanel:OnClickBetIncrease()
    FCasinoCtx.commonPanel:OnBetStep(1)
end

-- @brief 点击最大押注按钮
function BottomPanel:OnClickBetMax()
    FCasinoCtx.commonPanel:OnBetMax()
end

-- @brief 点击旋转按钮
function BottomPanel:OnClickSpin(isSimulation)
    if FCasinoCtx == nil then return end
    self:StopPressTimer()

    -- 等待状态，不允许按钮响应
    if not self.curSpinBtnCfg then
        return
    end

    -- 可以退出自动模式
    if not isSimulation and self.curSpinBtnCfg.can_exit_auto_mode then
        self:ExitAutoSpinMode()
        return
    end

    if FCasinoCtx.curSpinStatus == FSpinStatus.SPIN then
        if not FCasinoCtx:GetGame():SpinFaultToleranceProtection() then
            FCasinoCtx:GetGame():OnClickSpin(isSimulation)
        end
    elseif FCasinoCtx.curSpinStatus == FSpinStatus.STOP then
        if FConfig.Common.IsReviewVersion then
            -- 审核版本不允许点击停止按钮
            return
        end
        FCasinoCtx:GetGame():OnClickStop()
    end
end

function BottomPanel:StopPressTimer()
    if self.longPressTimer then
        StopTimer(self.longPressTimer)
        self.longPressTimer = nil
    end
end

-- @brief 打开自动spin次数选择列表
function BottomPanel:OnClickOpenAutoList()    
    self:StopPressTimer()
    self.clickStartTag = false
    self:ShowAutoSpinListPanel()
end

-- @brief spin触摸开始,用于检测长按事件
function BottomPanel:OnTouchSpinBegin()
    self:StopPressTimer()

    if FCasinoCtx.curSpinStatus == FSpinStatus.WAITING or not self.curSpinBtnCfg then 
        self.clickStartTag = false
        return
    end
    self.clickStartTag = true

    -- 当前状态可以进入自动spin模式
    if self.curSpinBtnCfg.can_enter_auto_mode then
        self.longPressTimer = StartTimer(function()
            -- 等待状态，不允许按钮响应
            if not self.curSpinBtnCfg then return end
            -- 当前模式不能进入自动模式
            if not self.curSpinBtnCfg.can_enter_auto_mode then return end

            if FCasinoCtx.curSpinStatus == FSpinStatus.SPIN then
                self:StopPressTimer()
                self.clickStartTag = false
                self:ShowAutoSpinListPanel()
            end
        end, 0.75)
    end
end

-- @brief spin触摸结束
function BottomPanel:OnTouchSpinEnd()
    self:StopPressTimer()

    if self.clickStartTag then
        self.clickStartTag = false

        -- 当前按钮处于置灰状态
        if self.btn_spin.grayed then return end
        self:OnClickSpin(false)
    end
end

-- @brief
function BottomPanel:OnClickBetLvID()
    self:ShowBetListPanel()
end

function BottomPanel:OnClickWinMoney()
    if FToolSet.IsForceShowGameScore() then
        return
    end
    self.text_win.visible = not self.text_win.visible
    self.text_lobby_win.visible = not self.text_win.visible
    self.text_bet.visible = not self.text_bet.visible
    self.text_lobby_bet.visible = not self.text_bet.visible
    
    FSysEventEmitter:Emit(FSysEvent.CHANGE_DISPLAY_EXCHANGERATE, self:DisplayHallExchangeRate())
end

function BottomPanel:OnClickBetMoney()
    self:OnClickWinMoney()
end

function BottomPanel:DisplayHallExchangeRate()
    return self.text_lobby_win.visible
end

-- @brief 弹出选C菜单栏
function BottomPanel:ShowBetListPanel()
    if #FCasinoCtx.commonPanel.betCValues <= 1 then return end
    if self.betListPanel then return end
    self.betListPanel = GameBetListPanel.New()
    -- self.betListPanel = BettingOptions.New()
    self.betListPanel:SetDestroyCallback(handler(self, self.CloseBetListPanel))
end

-- @brief 关闭选C菜单栏
function BottomPanel:CloseBetListPanel()
    if self.betListPanel then
        self.betListPanel:Delete()
        self.betListPanel = nil
    end
end

-- @brief 点击加速
function BottomPanel:OnClickAccelerate()
    self:SetAccelerationMode(not self:IsAccelerationMode())
end

-- @brief 当前是否处于加速模式
function BottomPanel:IsAccelerationMode()
    return self.btn_accelerate:GetController("c_dot").selectedIndex == 1
end

-- @brief 设置当前是否加速
function BottomPanel:SetAccelerationMode(value)
    if value then
        self.btn_accelerate:GetController("c_dot").selectedIndex = 1
    else
        self.btn_accelerate:GetController("c_dot").selectedIndex = 0
    end
end

-- @brief 刷新spin按钮状态
function BottomPanel:UpdateSpinButton()
    local gameMode = FCasinoCtx.curGameMode
    local spinStatus = FCasinoCtx.curSpinStatus
    local isAutoSpin = FCasinoCtx.isAutoSpin

    local spinCfg = SpinButtonCfg.NormalSpinCfg[gameMode]
    if isAutoSpin then
        spinCfg = SpinButtonCfg.AutoSpinCfg[gameMode]
    end

    local cfg = spinCfg[spinStatus]
    self.curSpinBtnCfg = cfg
    -- 等待状态，使用普通状态配置
    if spinStatus == FSpinStatus.WAITING then
        cfg = spinCfg[FSpinStatus.SPIN]
    end

    self.btn_spin:GetController("c_status").selectedPage = cfg.pageName

    -- 等待状态，将按钮置灰
    self.btn_spin.grayed = spinStatus == FSpinStatus.WAITING
    self.btn_spin.touchable = not self.btn_spin.grayed

    self:UpdateAutoSpinNum()
end

function BottomPanel:ShowAutoSpinListPanel()
    if self.autoSpinListPanel then return end

    if FConfig.Common.IsReviewVersion then
        -- 审核版本不允许点击自动spin
        return
    end

    self.autoSpinListPanel = AutoSpinListPanel.New()
    self.autoSpinListPanel:SetDestroyCallback(handler(self, self.CloseAutoSpinListPanel))
    self.autoSpinListPanel:SetSelectCallback(function(mode)
        if FCasinoCtx.curSpinStatus ~= FSpinStatus.SPIN then
            print("当前状态不允许设置自动spin模式")
            return
        end
        self:SetAutoMode(mode)
    end)
end

function BottomPanel:CloseAutoSpinListPanel()
    if self.autoSpinListPanel then
        self.autoSpinListPanel:Delete()
        self.autoSpinListPanel = nil
    end
    if self.delayShowAutoSpinListPanelTimer then
        StopTimer(self.delayShowAutoSpinListPanelTimer)
        self.delayShowAutoSpinListPanelTimer = nil
    end
end

function BottomPanel:SetAutoMode(mode)
    self.autoMode = clone(mode)

    -- 开启加速模式
    self:SetAccelerationMode(mode.mode == "inf_fast")

    self:UpdateAutoSpinNum()
    FCasinoCtx:GetGame():OnClickSpin(true)
    -- 状态变化了才切为自动
    FCasinoCtx:SetAutoSpin(FCasinoCtx.curSpinStatus ~= FSpinStatus.SPIN)
end

-- @brief 是否是自动模式
function BottomPanel:IsAutoMode()
    if not self.autoMode then return false end

    if self.autoMode.mode == "num" then
        return self.autoMode.num > 0
    end
    return true    
end

-- @brief 刷新spin次数
function BottomPanel:UpdateAutoSpinNum()
    -- 自动未开启/免费/特殊游戏不显示自动次数
    if not self.autoMode or FCasinoCtx.curGameMode ~= FGameMode.NORMAL then
        self.auto_spin_num.visible = false
        return
    end

    self.auto_spin_num.visible = true
    if self.autoMode.mode == "num" then
        if self.autoMode.num <= 0 then
            self.auto_spin_num.visible = false
        end
        self.auto_spin_num.text = tostring(math.floor(self.autoMode.num))
    else
        self.auto_spin_num.text = "i"
    end
end

-- @brief 消耗一次自动旋转次数
function BottomPanel:ConsumptionAutoSpinNum()
    if not self.autoMode then return true end

    if self.autoMode.mode == "num" then
        self.autoMode.num = self.autoMode.num - 1
        -- 次数用完
        if self.autoMode.num == 0 then
            self:ExitAutoSpinMode()
            return true
        end
        -- 次数用完
        if self.autoMode.num < 0 then
            self:ExitAutoSpinMode()
            return false
        end
    end
    return true
end

-- @brief 退出自动spin
function BottomPanel:ExitAutoSpinMode()
    self.autoMode = nil
    FCasinoCtx:SetAutoSpin(false)
    -- 关闭加速模式
    self:SetAccelerationMode(false)
    self:UpdateAutoSpinNum()
end

function BottomPanel:SetBtnCLevelVisible(value)
    self.btn_betlvID.visible = value
    if value then
        self.render:GetController("c_show_c_btn").selectedIndex = 0
    else
        self.render:GetController("c_show_c_btn").selectedIndex = 1
    end
end

function BottomPanel:ShowWithCValues(betCValues)
    if FConfig.Common.ShowBetCLevelMenu then
        self:SetBtnCLevelVisible(#betCValues > 1)
    else
        self:SetBtnCLevelVisible(false)
    end
end

return BottomPanel