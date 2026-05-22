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

    print(FTheme.curPkgName,resName,"CommonPanel CreateObject")
    local render = FairyGUI.UIPackage.CreateObject(FTheme.curPkgName, resName)

    local width = GetFairyRoot().width
    local height = GetFairyRoot().height
    -- 竖屏只适配高度
    if APIGateway.IsDeviceOrientationPortrai() then
        width = render.width
        height = GetFairyRoot().height
    end

    local parent = FairyGUI.GComponent()
    parent.width = width
    parent.height = height
    parent.pivot = vec2(0.5, 1)
    parent.pivotAsAnchor = true
    parent.xy = vec2(GetFairyRoot().width * 0.5, GetFairyRoot().height)
    parent:SetupOverflowHidden(true)
    GetFairyRoot():AddChild(parent)
    

    -- 公共UI界面全屏居中显示
    render.pivot = vec2(0.5, 0.5)
    render.pivotAsAnchor = true
    render.width = parent.width
    render.height = parent.height
    render.xy = vec2(width * 0.5, height * 0.5)
    parent:AddChild(render)

    self.render     = render

    self.bottomPanel = BottomPanel.New(render:GetChild("bottom"))

    self.bottomEffectLayer = render:GetChild("bottom_effect_layer")
    self.effectLayer       = render:GetChild("effect_layer")
    self.topEffectLayer    = render:GetChild("top_effect_layer")

    self.bottomEffectLayer.opaque = false
    self.effectLayer.opaque = false
    self.topEffectLayer.opaque = false

    self.betMoneyScale = 1
    self.tweeners = {}

    self:Adapter()
end

function CommonPanel:Adapter()
    local viewWidth = self.render.width
    local viewHeight = self.render.height
    
    local bottomRender = self.render:GetChild("bottom")

    local bottomHeightProportion = FTheme.curThemCfg.bottomHeightProportion or 0.23
    -- 计算底部菜单栏高度
    local bottomHeight = viewHeight * bottomHeightProportion
    bottomHeight = math.max(bottomHeight, bottomRender.minHeight)
    bottomHeight = math.min(bottomHeight, self.bottomPanel:GetMaxHeight())
    print("bottomHeight:", bottomHeight, bottomRender.minHeight, self.bottomPanel:GetMaxHeight())
    print("viewWidth:", viewWidth, "viewHeight", viewHeight)

    -- 适配底部菜单栏
    bottomRender.height = bottomHeight
    bottomRender.pivot = vec2(0.5, 1)
    bottomRender.pivotAsAnchor = true
    bottomRender.xy = vec2(viewWidth * 0.5, viewHeight)

    -- 适配游戏
    local gameRender = self.render:GetChild("game")
    gameRender.pivot = vec2(0.5, 1)
    gameRender.pivotAsAnchor = true
    gameRender.xy = vec2(viewWidth * 0.5, viewHeight - bottomHeight)
    if gameRender.height < gameRender.y then
        gameRender.height = gameRender.y
    end

    if FTheme.curThemCfg.gameLoaderFillType then
        gameRender.fill = FTheme.curThemCfg.gameLoaderFillType
    end
end

function CommonPanel:__delete()
    self.bottomPanel:Delete()
    self.hoverMenu:Delete()

    for k, v in pairs(self.tweeners) do
        v:Kill(false)
    end
    self.tweeners = {}
end

-- @interface
-- @brief 数据初始化
function CommonPanel:InitData()
    self:InitBetConfig()

    -- 清空当前赢分
    self:SetWinMoney(0)
    
    self.hoverMenu = HoverMenu.New()
end

-- @interface
-- @brief 游戏界面初始化
function CommonPanel:InitGame(gameId)
    -- 加载游戏界面
    self.render:GetChild("game").url = string.format("ui://Game%d/Game", gameId)
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
    self.bottomPanel.text_bet.text = FTheme.curThemCfg.moneyTextPrefix .. gameText

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

    if index < 1 then
        index = #cfg
    elseif index > #cfg then
        index = 1
    end
    self.curBetGear = index
    self:SetBetMoney(self:GetBetMoney())
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
-- @brief 是否显示顶部UI
-- @param doAction 是否执行动画
function CommonPanel:ShowTop(visible, doAction)
    local name = "hide_top"
    if visible then name = "show_top" end
    if not doAction then name = name .. "_no_action" end

    self.render:GetTransition(name):Play()
end

-- @interface
-- @brief 是否显示底部UI
-- @param doAction 是否执行动画
function CommonPanel:ShowBottom(visible, doAction)
    local name = "hide_bottom"
    if visible then name = "show_bottom" end
    if not doAction then name = name .. "_no_action" end

    self.render:GetTransition(name):Play()
end

-- @interface
-- @brief 设置当前赢的金币
-- @param value:number
-- @param rolling 是否正在滚动中
-- @param scrollEndValue 滚动结束值
function CommonPanel:SetWinMoney(value, rolling, scrollEndValue)
    self.bottomPanel:SetWinMoney(value, rolling, scrollEndValue)
end

-- @interface
-- @brief 获取当前赢的金币
function CommonPanel:GetWinMoney()
    return self.bottomPanel.curShowWinMoney
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
    
    local tweener = FairyGUI.GTween.ToDouble(self.bottomPanel.curShowWinMoney, value, duration)
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
    self.bottomPanel:SetPlayerMoney(value, moneyType, rolling, scrollEndValue)
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
        print("玩家金币滚动:", FToolSet.FmtLogMoney(self.bottomPanel.curShowMoney), "->", FToolSet.FmtLogMoney(value))
                
        if duration <= 0 then
            self:SetPlayerMoney(value, moneyType)
            if onCompleteCallback then onCompleteCallback() end
            return
        end
        
        local tweener = FairyGUI.GTween.ToDouble(self.bottomPanel.curShowMoney, value, duration)
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
        print("玩家绑定金币滚动:", FToolSet.FmtLogMoney(self.bottomPanel.curShowBindMoney), "->", FToolSet.FmtLogMoney(value))
                
        if duration <= 0 then
            self:SetPlayerMoney(value, moneyType)
            if onCompleteCallback then onCompleteCallback() end
            return
        end
        
        local tweener = FairyGUI.GTween.ToDouble(self.bottomPanel.curShowBindMoney, value, duration)
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
    return FPlayerMoneyType.NORMAL_MONEY
end

-- @interface
-- @brief 设置当前金币类型
function CommonPanel:SetMoneyType(value)
    -- if value == FPlayerMoneyType.BIND_MONEY then
    --     if not FCasinoCtx.lobbyData.playerIsVIP then
    --         APIGateway.ShowMessageBox(APIGateway.GetLangText("fgame_3"))
    --         value = FPlayerMoneyType.NORMAL_MONEY
    --     elseif FCasinoCtx.playerBindMoney <= 0 then
    --         APIGateway.ShowMessageBox(APIGateway.GetLangText("fgame_5"))
    --         value = FPlayerMoneyType.NORMAL_MONEY
    --     end
    -- end
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

-- @brief 设置是否显示自定义面板
-- 本套公共独有的功能 
function CommonPanel:ShowCustomPanel(visible, playAnimation, callback)
    self.bottomPanel:ShowCustomPanel(visible, playAnimation, callback)
end

-- @brief 设置自定义面板内容URL
-- 本套公共独有的功能 
function CommonPanel:SetCustomPanelUrl(url)
    return self.bottomPanel:SetCustomPanelUrl(url)
end

function CommonPanel:ShowToast(url, onCreate)
    local toast_loader = self.render:GetChild("toast_loader")
    toast_loader.url = url

    local rawWidth = toast_loader.component.width

    if onCreate then onCreate(toast_loader.component, toast_loader) end

    local diffWidth = (toast_loader.component.width - rawWidth) * 0.5
    toast_loader.x = self.render.width * 0.5 - diffWidth

    local show_toast = self.render:GetTransition("show_toast")
    local hide_tocast = self.render:GetTransition("hide_tocast")
    show_toast:Stop()
    hide_tocast:Stop()

    show_toast:Play(function()
        hide_tocast:Play()
    end)
end

function CommonPanel:GetSpinButton()
    return self.bottomPanel.btn_spin
end

return CommonPanel