local TopPanel = Import(".General.TopPanel")
local BottomPanel = Import(".General.BottomPanel")
local HoverMenu = Import(".General.HoverMenu")
local BetConfigParser = Import("..BetConfigParser")

-- 缓动类型
local TweenerType = {
    SCROLL_WIN_MONEY = 1,
    SCROLL_PLAYER_MONEY = 2,
    SCROLL_PLAYER_BIND_MONEY = 3,
}

local CommonPanel = Class("CommonPanel")

function CommonPanel:ctor(ctx)
    local resName = "CommonPanel"
    if APIGateway.IsDeviceOrientationPortrai() then
        resName = "CommonPanel_V"
    end

    -- 添加背景层
    if FTheme.curThemCfg.blurBgUrl then
        local blur_bg_loader = FairyGUI.GLoader()
        blur_bg_loader:MakeFullScreen()
        blur_bg_loader.fill = FairyGUI.FillType.ScaleNoBorder
        blur_bg_loader.align = FairyGUI.AlignType.Center
        blur_bg_loader.verticalAlign = FairyGUI.VertAlignType.Middle
        blur_bg_loader.url = FTheme.curThemCfg.blurBgUrl
        GetFairyRoot():AddChild(blur_bg_loader)
    end

    local render = FairyGUI.UIPackage.CreateObject(FTheme.curPkgName, resName)
    self.renderRawHeight = render.height

    render:MakeFullScreen()
    render.pivot = vec2(0.5, 0.5)
    render.pivotAsAnchor = true
    render.xy = vec2(GetFairyRoot().width * 0.5, GetFairyRoot().height * 0.5)
    GetFairyRoot():AddChild(render)

    self.render     = render
    self.topPanel    = TopPanel.New(render:GetChild("top").component)
    self.bottomPanel = BottomPanel.New(render:GetChild("bottom").component)

    self.bottomEffectLayer = render:GetChild("bottom_effect_layer")
    self.effectLayer       = render:GetChild("effect_layer")
    self.topEffectLayer    = render:GetChild("top_effect_layer")
    
    self.bottomEffectLayer.opaque = false
    self.effectLayer.opaque = false
    self.topEffectLayer.opaque = false

    self.betMoneyScale = 1
    self.tweeners = {}

    -- 游戏转轴状态错误事件
    FSysEventEmitter:AddListener(FSysEvent.ON_GAME_REEL_STATE_ERROR, function()
        self.topPanel.btn_back.touchable = true
        self.topPanel.btn_back.grayed = false
    end, self)
end

function CommonPanel:__delete()
    self.topPanel:Delete()
    self.bottomPanel:Delete()
    self.hoverMenu:Delete()

    for k, v in pairs(self.tweeners) do
        v:Kill(false)
    end
    self.tweeners = {}

    FSysEventEmitter:RemoveListenersByTag(self)
end

-- @interface
-- @brief 数据初始化
function CommonPanel:InitData()
    self:InitBetConfig()

    -- 只有一个C位时，不显示选C按钮
    self.bottomPanel:ShowWithCValues(self.betCValues)

    -- 清空当前赢分
    self:SetWinMoney(0)
    
    self.hoverMenu = HoverMenu.New()
end

-- @interface
-- @brief 游戏界面初始化
function CommonPanel:InitGame(gameId)
    self.bottomPanel:UpdateSpinButton()

    local gameLoader = self.render:GetChild("game")

    -- 剩余高度
    local remainingHeight = GetFairyRoot().height - self.renderRawHeight
    -- 顶部高度
    local topHeight = self.render:GetChild("top").height
    -- 底部高度
    local bottomHeight = self.render:GetChild("bottom").height


    local topFactor, bottomFactor = 1, 1
    if FTheme.curThemCfg.adapterIgnoreTopPanel and FTheme.curThemCfg.adapterIgnoreBottomPanel then
        topFactor = topHeight / (topHeight + bottomHeight)
        bottomFactor = bottomHeight / (topHeight + bottomHeight)
    end

    if FTheme.curThemCfg.adapterIgnoreTopPanel then
        local value = math.min(remainingHeight * topFactor, topHeight)
        gameLoader.y = value
        gameLoader.height = gameLoader.height - value
    end
    
    if FTheme.curThemCfg.adapterIgnoreBottomPanel then
        local value = math.min(remainingHeight * bottomFactor, bottomHeight)
        gameLoader.height = gameLoader.height - value
    end

    -- 加载游戏界面
    gameLoader.url = string.format("ui://Game%d/Game", gameId)
end

function CommonPanel:InitBetConfig()
    local parser = BetConfigParser.New()

    -- 当前C位下标
    self.curCIndex = parser.curCIndex
    -- 当前押注档位
    self.curBetGear = parser.curBetGear
    -- 当前游戏押注档位配置
    self.betCfg = parser.betCfg
    -- C值
    self.betCValues = parser.betCValues

    parser:Delete()

    -- 刷新当前押注值
    self:OnBetStep(0)
end

-- @brief 获取当前押注配置
function CommonPanel:GetCurrentBetConfig()
    return self:GetCurCConfigList()[self.curBetGear]
end

-- @brief 获取押注总配置
function CommonPanel:GetBetConfig()
    return self.betCfg
end

-- @brief 获取当前C位配置
function CommonPanel:GetCurCConfigList()
    return self.betCfg[self:GetCurCValueIndex()]
end

-- @brief 获取当前C位下标
function CommonPanel:GetCurCValueIndex()
    return self.curCIndex
end

-- @brief 获取当前C位押注具体档位
function CommonPanel:GetCurBetGear()
    return self.curBetGear
end

-- @brief 通过C位下标和押注值设置
function CommonPanel:SetBetByCIndexAndValue(cIndex, betValue)
    local cfgList = self.betCfg[cIndex]
    if not cfgList then
        print("[CommonPanel][SetBetByCIndexAndValue] invalid cIndex:", cIndex)
        return
    end

    for i, cfg in pairs(cfgList) do
        if cfg.betMoney == betValue then
            self:SetCurCValueIndex(cIndex, i)
            return
        end
    end

    print("[CommonPanel][SetBetByCIndexAndValue] invalid betValue:", betValue, "for cIndex:", cIndex)
end

-- @brief 获取当前押注C位值
function CommonPanel:GetCurBetCValue()
    return self.betCValues[self:GetCurCValueIndex()]
end

-- @brief 设置当前C位下标
function CommonPanel:SetCurCValueIndex(index, betGear)
    if self.isLockBetStatus then
        return
    end
    self.curCIndex = index
    self.curBetGear = betGear or 1
    self:OnBetStep(0)
end

-- @interface
-- @brief 获取游戏界面组件
function CommonPanel:GetGameRender()
    return self.render:GetChild("game").component
end

-- @interface
-- @brief 设置当前押注
-- @param value:number
function CommonPanel:SetBetMoney(value)
    local gameText = FToolSet.NumToStr(value * self.betMoneyScale)
    local lobbyText = FToolSet.NumToStr(value, false, true, FConfig.Common.TopLobbyRateTextDecimalPlaces)
    
    gameText = FToolSet:TrimNumStrTailZero(gameText)
    lobbyText = FToolSet:TrimNumStrTailZero(lobbyText)
    
    lobbyText = "$" .. lobbyText

    self.topPanel.text_game_bet.text = gameText
    self.topPanel.text_lobby_bet.text = lobbyText
    self.bottomPanel.text_bet.text = gameText
    self.bottomPanel.text_lobby_bet.text = lobbyText

    FSysEventEmitter:Emit(FSysEvent.CHANGE_BET_VALUE, value)
end

-- @interface
-- @brief 设置当前押注显示缩放倍数
-- @param value:number
function CommonPanel:SetBetMoneyShowScale(value)
    self.betMoneyScale = value
    self:SetBetMoney(self:GetBetMoney())
end

-- @brief 获取押注值缩放
function CommonPanel:GetBetMoneyScale()
    return self.betMoneyScale
end

-- @interface
-- @brief 获取当前押注值
function CommonPanel:GetBetMoney()
    return self:GetCurrentBetConfig().betMoney
end

-- @brief 押注值改变
-- @param value 步进值
function CommonPanel:OnBetStep(value)
    local index = self.curBetGear + value
    local cfg = self:GetCurCConfigList()

    if FConfig.Common.BetStepChangeCLevel then
        if index < 1 then
            if self.curCIndex <= 1 then
                self.curCIndex = #self.betCfg
            else
                self.curCIndex = self.curCIndex - 1
            end
            cfg = self.betCfg[self.curCIndex]
            index = #cfg
        elseif index > #cfg then
            if self.curCIndex >= #self.betCfg then
                self.curCIndex = 1
            else
                self.curCIndex = self.curCIndex + 1
            end
            cfg = self.betCfg[self.curCIndex]
            index = 1
        end
    else
        if index < 1 then
            index = #cfg
        elseif index > #cfg then
            index = 1
        end
    end
    
    self.curBetGear = index
    self:SetBetMoney(self:GetBetMoney())
    self.bottomPanel.btn_betlvID.text = self:GetCurBetCValue() .. "C"
end

-- @brief 最大押注
function CommonPanel:OnBetMax()
    for k, cfgs in pairs(self.betCfg) do
        if cfgs[1].enabled then
            self.curCIndex = k
        end
    end
    self.curBetGear = #self:GetCurCConfigList()
    self:OnBetStep(0)
end

-- @interface
-- @brief 当前是否处于加速模式
function CommonPanel:IsAccelerationMode()
    return self.bottomPanel:IsAccelerationMode()
end

-- @interface
-- @brief 当前显示是否使用大厅汇率
function CommonPanel:DisplayHallExchangeRate()
    return self.bottomPanel:DisplayHallExchangeRate()
end


-- @interface
-- @brief 是否显示顶部UI
-- @param doAction 是否执行动画
function CommonPanel:ShowTop(visible, doAction)
    local name = "hide_top"
    if visible then name = "show_top" end
    if not doAction then name = name .. "_no_action" end

    self.render:GetTransition("hide_top"):Stop()
    self.render:GetTransition("show_top"):Stop()
    self.render:GetTransition("hide_top_no_action"):Stop()
    self.render:GetTransition("show_top_no_action"):Stop()
    self.render:GetTransition(name):Play()
end

-- @interface
-- @brief 是否显示底部UI
-- @param doAction 是否执行动画
function CommonPanel:ShowBottom(visible, doAction)
    local name = "hide_bottom"
    if visible then name = "show_bottom" end
    if not doAction then name = name .. "_no_action" end

    self.render:GetTransition("hide_bottom"):Stop()
    self.render:GetTransition("show_bottom"):Stop()
    self.render:GetTransition("hide_bottom_no_action"):Stop()
    self.render:GetTransition("show_bottom_no_action"):Stop()
    self.render:GetTransition(name):Play()
end

-- @interface
-- @brief 设置当前赢的金币
-- @param value:number
-- @param rolling 是否正在滚动中
-- @param scrollEndValue 滚动结束值
function CommonPanel:SetWinMoney(value, rolling, scrollEndValue)
    self.topPanel:SetWinMoney(value, rolling, scrollEndValue)
    -- 底部赢分如果为0则不显示
    if value <= 0 then
        self.bottomPanel.text_win.text = ""
        self.bottomPanel.text_lobby_win.text = ""
    else
        self.bottomPanel.text_win.text = self.topPanel.text_game_win.text
        self.bottomPanel.text_lobby_win.text = self.topPanel.text_lobby_win.text
    end
end

-- @interface
-- @brief 获取当前赢的金币
function CommonPanel:GetWinMoney()
    return self.topPanel.curShowWinMoney
end

-- @interface
-- @brief 将赢分滚动到某个值
function CommonPanel:ScrollWinMoneyTo(value, duration, onCompleteCallback)
    duration = duration or 1
    self:StopScrollWinMoney()

    if duration <= 0 then
        self:SetWinMoney(value)
        if onCompleteCallback then onCompleteCallback() end
        return
    end

    local tweener = FairyGUI.GTween.ToDouble(self.topPanel.curShowWinMoney, value, duration)
    :OnUpdate(function(tweener)
        self:SetWinMoney(tweener.value.d, true, value)
    end)
    :OnComplete(function()        
        self.tweeners[TweenerType.SCROLL_WIN_MONEY] = nil
        self:SetWinMoney(value)
        if onCompleteCallback then
            onCompleteCallback()
        end
    end)

    self.tweeners[TweenerType.SCROLL_WIN_MONEY] = tweener
end

-- @interface
-- @brief 停止赢分滚动并将赢分设置为value
-- @param complete 是否将动作快速完成（会触发 OnComplete 回调函数）
function CommonPanel:StopScrollWinMoney(value, complete)
    if complete == nil then complete = false end

    self:KillTweener(TweenerType.SCROLL_WIN_MONEY, complete)

    if value ~= nil then
        self:SetWinMoney(value)
    end
end

-- @interface
-- @brief 设置当前玩家金币
-- @param value:number
-- @param moneyType 金币类型
-- @param rolling 是否正在滚动中
-- @param scrollEndValue 滚动结束值
function CommonPanel:SetPlayerMoney(value, moneyType, rolling, scrollEndValue)
    self.topPanel:SetPlayerMoney(value, moneyType, rolling, scrollEndValue)
end

-- @interface
-- @brief 将金币滚动到某个值
-- @param moneyType 金币类型,不传则使用当前押注金币类型
function CommonPanel:ScrollMoneyTo(value, duration, onCompleteCallback, moneyType)
    duration = duration or 1
    if moneyType == nil then
        moneyType = self:GetMoneyType()
    end
    self:StopScrollMoney(moneyType)

    if moneyType == FPlayerMoneyType.NORMAL_MONEY then
        print("玩家金币滚动:", FToolSet.FmtLogMoney(self.topPanel.curShowMoney), "->", FToolSet.FmtLogMoney(value))
        
        if duration <= 0 then
            self:SetPlayerMoney(value, moneyType)
            if onCompleteCallback then onCompleteCallback() end
            return
        end

        local tweener = FairyGUI.GTween.ToDouble(self.topPanel.curShowMoney, value, duration)
        :OnUpdate(function(tweener)
            self:SetPlayerMoney(tweener.value.d, moneyType, true, value)
        end)
        :OnComplete(function()
            self.tweeners[TweenerType.SCROLL_PLAYER_MONEY] = nil
            self:SetPlayerMoney(value, moneyType)
            if onCompleteCallback then
                onCompleteCallback()
            end
        end)
        
        self.tweeners[TweenerType.SCROLL_PLAYER_MONEY] = tweener
    else
        print("玩家绑定金币滚动:", FToolSet.FmtLogMoney(self.topPanel.curShowBindMoney), "->", FToolSet.FmtLogMoney(value))
        
        if duration <= 0 then
            self:SetPlayerMoney(value, moneyType)
            if onCompleteCallback then onCompleteCallback() end
            return
        end
        
        local tweener = FairyGUI.GTween.ToDouble(self.topPanel.curShowBindMoney, value, duration)
        :SetTarget(self.topPanel.text_game_bind_money)
        :OnUpdate(function(tweener)
            self:SetPlayerMoney(tweener.value.d, moneyType, true, value)
        end)
        :OnComplete(function()
            self.tweeners[TweenerType.SCROLL_PLAYER_BIND_MONEY] = nil
            self:SetPlayerMoney(value, moneyType)
            if onCompleteCallback then
                onCompleteCallback()
            end
        end)

        self.tweeners[TweenerType.SCROLL_PLAYER_BIND_MONEY] = tweener
    end
end

-- @interface
-- @brief 停止金币滚动
function CommonPanel:StopScrollMoney(moneyType, complete)
    if moneyType == nil then moneyType = self:GetMoneyType() end
    if complete == nil then complete = false end

    if moneyType == FPlayerMoneyType.NORMAL_MONEY then
        self:KillTweener(TweenerType.SCROLL_PLAYER_MONEY, complete)
    else
        self:KillTweener(TweenerType.SCROLL_PLAYER_BIND_MONEY, complete)
    end
end

-- @brief 检查金币是否正在滚动
function CommonPanel:CheckMoneyRolling(moneyType)
    if moneyType == nil then moneyType = self:GetMoneyType() end

    if moneyType == FPlayerMoneyType.NORMAL_MONEY then
        return self.tweeners[TweenerType.SCROLL_PLAYER_MONEY] ~= nil
    else
        return self.tweeners[TweenerType.SCROLL_PLAYER_BIND_MONEY] ~= nil
    end
end

function CommonPanel:KillTweener(tweenerType, complete)
    local tweener = self.tweeners[tweenerType]
    if tweener then
        self.tweeners[tweenerType] = nil
        tweener:Kill(complete)
    end
end

-- @interface
-- @brief 获取当前金币类型
function CommonPanel:GetMoneyType()
    return self.topPanel:GetMoneyType()
end

-- @interface
-- @brief 设置当前金币类型
function CommonPanel:SetMoneyType(value)
    if value == FPlayerMoneyType.BIND_MONEY then
        if not FCasinoCtx.lobbyData.playerIsVIP then
            APIGateway.ShowMessageBox(APIGateway.GetLangText("fgame_3"))
            value = FPlayerMoneyType.NORMAL_MONEY
        elseif FCasinoCtx.playerBindMoney <= 0 then
            APIGateway.ShowMessageBox(APIGateway.GetLangText("fgame_5"))
            value = FPlayerMoneyType.NORMAL_MONEY
        end
    end
    self.topPanel:SetMoneyType(value)
end

-- @interface
-- @brief 获取顶层特效层
function CommonPanel:GetTopEffectLayer()
    return self.topEffectLayer
end

-- @interface
-- @brief 获取特效层
function CommonPanel:GetEffectLayer()
    return self.effectLayer
end

-- @interface
-- @brief 获取底层特效层
function CommonPanel:GetBottomEffectLayer()
    return self.bottomEffectLayer
end

-- @interface 
-- @brief 设置自动模式
function CommonPanel:SetAutoMode(mode)
    self.bottomPanel:SetAutoMode(mode)
end

-- @interface 
-- @brief 是否是自动模式
function CommonPanel:IsAutoMode()
    return self.bottomPanel:IsAutoMode()
end

-- @interface
-- @brief spin状态切换
function CommonPanel:OnChangeSpinStatus(value)
    self.bottomPanel:UpdateSpinButton()

    -- 等待状态，将按钮置灰
    local grayed = (value == FSpinStatus.WAITING or value == FSpinStatus.STOP)

    -- 只要是开启自动都将按钮置灰
    if FCasinoCtx.isAutoSpin then grayed = true end

    if not grayed then
        -- 处于特殊游戏模式或免费游戏模式也要置灰按钮
        if FCasinoCtx.curGameMode == FGameMode.FREE or FCasinoCtx.curGameMode == FGameMode.SPECIAL then
            grayed = true
        end
    end

    self.bottomPanel.btn_bet_pre.grayed    = grayed
    self.bottomPanel.btn_bet_next.grayed   = grayed
    self.bottomPanel.btn_max.grayed        = grayed
    self.bottomPanel.btn_betlvID.grayed    = grayed
    self.bottomPanel.btn_accelerate.grayed = grayed
    self.bottomPanel.btn_rule.grayed       = grayed
    self.bottomPanel.btn_changeDenomination.grayed = grayed
    self.bottomPanel.btn_openAutoList.grayed = grayed
    self.topPanel.btn_back.grayed          = grayed
    self.topPanel.btn_menu.grayed          = grayed

    self.bottomPanel.btn_bet_pre.touchable    = not grayed
    self.bottomPanel.btn_bet_next.touchable   = not grayed
    self.bottomPanel.btn_max.touchable        = not grayed
    self.bottomPanel.btn_betlvID.touchable    = not grayed
    self.bottomPanel.btn_accelerate.touchable = not grayed
    self.bottomPanel.btn_rule.touchable       = not grayed
    self.bottomPanel.btn_changeDenomination.touchable = not grayed
    self.bottomPanel.btn_openAutoList.touchable = not grayed
    self.topPanel.btn_back.touchable          = not grayed
    self.topPanel.btn_menu.touchable          = not grayed

    self.isLockBetStatus = grayed

    self.bottomPanel:CloseBetListPanel()
    self.bottomPanel:CloseAutoSpinListPanel()
end

-- @interface 
-- @brief 模拟点击spin
function CommonPanel:OnSimulateSpinClick()
    self.bottomPanel:OnClickSpin(true)
end

-- @interface 
-- @brief 新的一次spin开始，消耗一次自动旋转次数
-- @return bool 返回是否还有剩余自动旋转次数
function CommonPanel:OnConsumptionAutoSpinNum()
    return self.bottomPanel:ConsumptionAutoSpinNum()
end

-- @interface 
-- @brief 金币不足时调用
function CommonPanel:OnInsufficientMoney(moneyType)
    if moneyType == FPlayerMoneyType.NORMAL_MONEY then
        APIGateway.ShowMessageBox(APIGateway.GetLangText("fgame_1"))
    elseif moneyType == FPlayerMoneyType.BIND_MONEY then
        APIGateway.ShowMessageBox(APIGateway.GetLangText("fgame_5"))
    end
    self.bottomPanel:ExitAutoSpinMode()
end

return CommonPanel