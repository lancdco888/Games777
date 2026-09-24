local Utils = Import("..Utils")
local SpinButton = Import(".SpinButton")
local MessageBox = Import("..MessageBox")
local BottomPanel = Class("BottomPanel")


function BottomPanel:ctor(render)
    self.render = render
    self.bCustomPanelVisible = false

    -- 玩家本局赢的金币
    self.text_win = render:GetChild("text_win")
    -- 玩家当前押注
    self.text_bet = render:GetChild("text_bet")
    -- 玩家金币值
    self.text_game_money = render:GetChild("text_game_money")
    
    Utils.SetChildColor(self.text_win)
    Utils.SetChildColor(self.text_bet)
    Utils.SetChildColor(self.text_game_money)

    self.loader_bg = render:GetChild("loader_bg")
    self.loader_bg.url = FTheme.curThemCfg.comUIFloorBg

    self:InitMenuPanel1(render:GetChild("menu_panel_1"))
    self:InitMenuPanel2(render:GetChild("menu_panel_2"))
    
    FToolSet.AddClickListener(self.text_bet, handler(self, self.OnClickTextBet), false)

    
    -- 游戏转轴状态错误事件
    FSysEventEmitter:AddListener(FSysEvent.ON_GAME_REEL_STATE_ERROR, function()
        self.btn_menu.touchable = true
        self.btn_menu.grayed = false
        
        self.btn_exit.touchable = true
        self.btn_exit.grayed = false
    end, self)
end

function BottomPanel:GetMaxHeight()
    return self.loader_bg.component.height
end

function BottomPanel:InitMenuPanel1(render)
    render.opaque = false

    self.btn_exit = render:GetChild("btn_exit")
    self.btn_audio = render:GetChild("btn_audio")
    self.btn_odds_table = render:GetChild("btn_odds_table")
    self.btn_rule = render:GetChild("btn_rule")
    self.btn_close_menu = render:GetChild("btn_close_menu")

    local function SetIconAndTextColor(obj)
        obj:GetChild("icon").color = FTheme.curThemCfg.iconColor
        obj:GetChild("title").color = FTheme.curThemCfg.textColor
    end
    SetIconAndTextColor(self.btn_exit)
    SetIconAndTextColor(self.btn_audio)
    SetIconAndTextColor(self.btn_odds_table)
    SetIconAndTextColor(self.btn_rule)
    self.btn_close_menu:GetChild("title").color = FTheme.curThemCfg.textColor

    FToolSet.AddClickListener(self.btn_exit,       handler(self, self.OnClickExitGame), false)
    FToolSet.AddClickListener(self.btn_audio,      handler(self, self.OnClickAudio), false)
    FToolSet.AddClickListener(self.btn_odds_table, handler(self, self.OnClickOddsTable), false)
    FToolSet.AddClickListener(self.btn_rule,       handler(self, self.OnClickGameRule), false)
    FToolSet.AddClickListener(self.btn_close_menu, function()
        self.render:GetController("c1").selectedIndex = 0
    end, false)

    self.btn_exit.text          = APIGateway.GetLangText("fgame_crimson_cartoon_menu_1")
    self.btn_audio.text         = APIGateway.GetLangText("fgame_crimson_cartoon_menu_2")
    self.btn_odds_table.text    = APIGateway.GetLangText("fgame_crimson_cartoon_menu_3")
    self.btn_rule.text          = APIGateway.GetLangText("fgame_crimson_cartoon_menu_4")
    self.btn_close_menu.text    = APIGateway.GetLangText("fgame_crimson_cartoon_menu_5")

    self:UpdateAudioBtn()
end

function BottomPanel:InitMenuPanel2(render)
    self.menu_panel_2 = render
    render.opaque = false
    
    self.btn_bet_pre = render:GetChild("btn_bet_pre")
    self.btn_bet_next = render:GetChild("btn_bet_next")
    self.btn_accelerate = render:GetChild("btn_accelerate")
    self.btn_auto = render:GetChild("btn_auto")
    self.btn_menu = render:GetChild("btn_menu")
    
    Utils.SetChildColor(self.btn_bet_pre)
    Utils.SetChildColor(self.btn_bet_next)
    Utils.SetChildColor(self.btn_accelerate)
    Utils.SetChildColor(self.btn_auto)
    
    FToolSet.AddClickListener(self.btn_bet_pre,    handler(self, self.OnClickBetReduce), false)
    FToolSet.AddClickListener(self.btn_bet_next,   handler(self, self.OnClickBetIncrease), false)
    FToolSet.AddClickListener(self.btn_accelerate, handler(self, self.OnClickAccelerate), false)
    FToolSet.AddClickListener(self.btn_auto,       handler(self, self.OnClickAuto), false)
    FToolSet.AddClickListener(self.btn_menu,       function()
        self.render:GetController("c1").selectedIndex = 1
    end, false)

    -- spin按钮
    self.btn_spin = SpinButton.New(render:GetChild("loader_spin"))

    -- 自动游戏次数
    local loader_auto_num = render:GetChild("loader_auto_num")
    loader_auto_num.url = FTheme.curThemCfg.autoNumUrl
    self.auto_spin_num = loader_auto_num.component
    FToolSet.AddClickListener(self.auto_spin_num, function()
        self:ExitAutoSpinMode()
    end, false)
end

function BottomPanel:__delete()
    self.btn_spin:Delete()
    
    if self.bettingOptions then
        self.bettingOptions:Delete()
    end
    
    if self.autoSpin then
        self.autoSpin:Delete()
    end

    if self.exitMsgBox then
        self.exitMsgBox:Delete()
        self.exitMsgBox = nil
    end

    if self.gameRulePanel then
        self.gameRulePanel:Delete()
        self.gameRulePanel = nil
    end

    FSysEventEmitter:RemoveListenersByTag(self)
end

-- @brief 点击减少押注按钮
function BottomPanel:OnClickBetReduce()
    -- 在公共面板中处理
    FCasinoCtx.commonPanel:OnBetStep(-1)
    self:UpdateBetChangeBtn()
end

-- @brief 点击增加押注按钮
function BottomPanel:OnClickBetIncrease()
    FCasinoCtx.commonPanel:OnBetStep(1)
    self:UpdateBetChangeBtn()
end

-- @brief 点击最大押注按钮
function BottomPanel:OnClickBetMax()
    FCasinoCtx.commonPanel:OnBetMax()
end

-- @brief 退出游戏按钮
function BottomPanel:OnClickExitGame()
    -- 退出弹窗已存在
    if self.exitMsgBox then return end

    local title = APIGateway.GetLangText("fgame_crimson_cartoon_title_15")
    local content = APIGateway.GetLangText("fgame_crimson_cartoon_title_16")
    
    self.exitMsgBox = MessageBox.New(title, content, function()
        FCasinoCtx:GetGame():DoExitGame()
    end, function() end)
    
    self.exitMsgBox:SetDestroyCallback(function()
        self.exitMsgBox:Delete()
        self.exitMsgBox = nil
    end)
end

function BottomPanel:OnClickAudio()
    APIGateway.SetSoundEnable(not APIGateway.IsSoundEnable())
    self:UpdateAudioBtn()
end

-- @brief 自动游戏按钮
function BottomPanel:OnClickAuto()
    self.autoSpin = FTheme.Require("AutoSpin").New()
    self.autoSpin:SetDestroyCallback(function()
        if self.autoSpin then
            self.autoSpin:Delete()
            self.autoSpin = nil
        end
    end)
    self.autoSpin:SetSelectCallback(function(mode)
        self:SetAutoMode(mode)
    end)
end

function BottomPanel:SetAutoMode(mode)
    self.autoMode = clone(mode)

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

-- @brief 点击当前押注金额
function BottomPanel:OnClickTextBet()
    if self.autoMode then return end

    self.bettingOptions = FTheme.Require("BettingOptions").New()
    self.bettingOptions:SetDestroyCallback(function()
        self.bettingOptions:Delete()
        self.bettingOptions = nil
    end)
end

-- @brief 查看游戏赔率
function BottomPanel:OnClickOddsTable()
    local cfg = FCasinoCtx.gameCfg.Rule
    self.gameRulePanel = FTheme.Require("GameRulePanel").New(cfg.frame, cfg.oddsItems or {}, true)
    self.gameRulePanel:SetDestroyCallback(function()
        self.gameRulePanel:Delete()
        self.gameRulePanel = nil
    end)
end

-- @brief 查看游戏规则
function BottomPanel:OnClickGameRule()
    FCasinoCtx:GetGame():OnShowGameRule()
end

-- @brief 点击旋转按钮
function BottomPanel:OnClickSpin(isSimulation)
    if FCasinoCtx == nil then return end
    self.btn_spin:OnClickSpin(isSimulation)
end

-- @brief 点击加速
function BottomPanel:OnClickAccelerate()
    self:SetAccelerationMode(not self:IsAccelerationMode_UI())
    if self:IsAccelerationMode_UI() then
        FCasinoCtx.commonPanel:ShowToast("ui://Theme_CrimsonCartoon/Toast_TurboSpinEnabled", function(render)
            render.text = APIGateway.GetLangText("fgame_crimson_cartoon_title_17")
            render:GetChild("icon").color  = FTheme.curThemCfg.textColor
        end)
    else
        FCasinoCtx.commonPanel:ShowToast("ui://Theme_CrimsonCartoon/Toast_TurboSpinDisabled", function(render)
            render.text = APIGateway.GetLangText("fgame_crimson_cartoon_title_18")
            render:GetChild("icon").color  = FTheme.curThemCfg.textColor
        end)
    end
end

-- @brief 当前是否处于加速模式
function BottomPanel:IsAccelerationMode_UI()
    return self.btn_accelerate:GetController("c1").selectedIndex == 1
end

-- @brief 当前是否处于加速模式
function BottomPanel:IsAccelerationMode()
    if self.cacheAccelerationMode == nil then
        return self:IsAccelerationMode_UI()
    end
    return self.cacheAccelerationMode
end

-- @brief 设置当前是否加速
function BottomPanel:SetAccelerationMode(value)
    if value then
        self.btn_accelerate:GetController("c1").selectedIndex = 1
    else
        self.btn_accelerate:GetController("c1").selectedIndex = 2
    end
end

-- @brief 刷新spin按钮状态
function BottomPanel:UpdateSpinButton()
    local spinStatus = FCasinoCtx.curSpinStatus
    
    -- 等待状态，将按钮置灰
    local grayed = (spinStatus == FSpinStatus.WAITING or spinStatus == FSpinStatus.STOP)
    
    -- 只要是开启自动都将按钮置灰
    if self.autoMode then grayed = true end

    if not grayed then
        -- 处于特殊游戏模式或免费游戏模式也要置灰按钮
        if FCasinoCtx.curGameMode == FGameMode.FREE or FCasinoCtx.curGameMode == FGameMode.SPECIAL then
            grayed = true
        end
    end
    
    self.btn_auto.grayed              = grayed
    self.btn_menu.grayed              = grayed
    self.btn_exit.grayed              = grayed
    

    self.btn_auto.touchable           = not grayed
    self.text_bet.touchable           = not grayed
    self.btn_menu.touchable           = not grayed
    self.btn_exit.touchable           = not grayed

    self.betChangeTouchable = not grayed
    self:UpdateBetChangeBtn()
    
    -- spin按钮状态
    self.btn_spin:EnableAcceleration(spinStatus == FSpinStatus.STOP)
    self.btn_spin:SetFreeze(spinStatus == FSpinStatus.WAITING)
    self.btn_spin:SetGrey(spinStatus == FSpinStatus.WAITING)

    -- 加速按钮
    -- 需求：随时可以开启/关闭   但是在旋转中不生效，下次旋转生效
    if spinStatus == FSpinStatus.SPIN then
        self.cacheAccelerationMode = nil
    else
        if self.cacheAccelerationMode == nil then
            -- 缓存当前状态
            self.cacheAccelerationMode = self:IsAccelerationMode_UI()
        end
    end

    self:UpdateAutoSpinNum()

    -- 关闭押注选项界面
    if self.bettingOptions then
        self.bettingOptions:Delete()
    end
    if self.autoSpin then
        self.autoSpin:Delete()
        self.autoSpin = nil
    end
end

-- @brief 刷新spin次数
function BottomPanel:UpdateAutoSpinNum()
    if self.autoMode then
        self.menu_panel_2:GetController("c1").selectedIndex = 1
    else
        self.menu_panel_2:GetController("c1").selectedIndex = 0
        return
    end

    if self.autoMode.mode == "num" then
        if self.autoMode.num <= 0 then
            self.autoMode.num = 0
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
    self:UpdateAutoSpinNum()
end

-- @brief 设置当前赢的金币
-- @param value:number
-- @param rolling 是否正在滚动中
-- @param scrollEndValue 滚动结束值
function BottomPanel:SetWinMoney(value, rolling, scrollEndValue)
    local gameText = FToolSet.NumToStr(value)

    if rolling then
        -- 如果知道滚动结果值，则按照结束值位数来保留
        if scrollEndValue then
            local endText = FToolSet.NumToStr(scrollEndValue)
            gameText = FToolSet.FixedDecimalPlaces(gameText, FToolSet.GetDecimalPlaces(endText))
        else
            -- 滚动中强制保留两位小数，防止晃动
            gameText = FToolSet.FixedDecimalPlaces(gameText, 2)
        end
    end

    self.text_win.text = FTheme.curThemCfg.moneyTextPrefix .. gameText
    self.curShowWinMoney = value
end

-- @brief 设置当前玩家金币
-- @param value:number
-- @param moneyType 金币类型
-- @param rolling 是否正在滚动中
-- @param scrollEndValue 滚动结束值
function BottomPanel:SetPlayerMoney(value, moneyType, rolling, scrollEndValue)
    local gameText = FToolSet.NumToStr(value)

    -- 停止时显示实际数量
    if rolling then
        -- 如果知道滚动结果值，则按照结束值位数来保留
        if scrollEndValue then
            local endText = FToolSet.NumToStr(scrollEndValue)
            gameText = FToolSet.FixedDecimalPlaces(gameText, FToolSet.GetDecimalPlaces(endText))
        -- 滚动中强制保留两位小数，防止晃动
        else
            gameText = FToolSet.FixedDecimalPlaces(gameText, 2)
        end
    end

    if moneyType == FPlayerMoneyType.NORMAL_MONEY then
        self.text_game_money.text = FTheme.curThemCfg.moneyTextPrefix .. gameText
        self.curShowMoney = value
    else
        self.curShowBindMoney = value
    end
end

-- @brief 设置是否显示自定义面板
-- 本套公共独有的功能 
function BottomPanel:ShowCustomPanel(visible, playAnimation, callback)
    if self.bCustomPanelVisible == visible then return end
    self.bCustomPanelVisible = visible

    local show_custom_panel = self.render:GetTransition("show_custom_panel")
    local hide_custom_panel = self.render:GetTransition("hide_custom_panel")
    show_custom_panel:Stop()
    hide_custom_panel:Stop()

    if playAnimation then
        if visible then
            show_custom_panel:Play(function()
                if callback then callback() end
            end)
        else
            hide_custom_panel:Play(function()
                if callback then callback() end
            end)
        end
    else
        local loader_custom = self.render:GetChild("loader_custom")
        loader_custom.visible = visible

        local menu_panel_2 = self.render:GetChild("menu_panel_2")
        menu_panel_2.visible = not visible
        menu_panel_2.alpha = 1
    end
end

-- @brief 设置自定义面板内容URL
-- 本套公共独有的功能 
function BottomPanel:SetCustomPanelUrl(url)
    local loader_custom = self.render:GetChild("loader_custom")
    loader_custom.url = url
    return loader_custom.component
end

function BottomPanel:UpdateBetChangeBtn()
    -- 押注-按钮，最小档置为不可点击状态
    local touchable = self.betChangeTouchable and FCasinoCtx.commonPanel:GetCurBetGear() > 1
    self.btn_bet_pre.grayed           = not touchable
    self.btn_bet_pre.touchable        = touchable

    -- 押注+按钮，最大档置为不可点击状态
    local touchable = self.betChangeTouchable and FCasinoCtx.commonPanel:GetCurBetGear() < #FCasinoCtx.commonPanel:GetCurCConfigList()
    self.btn_bet_next.grayed          = not touchable
    self.btn_bet_next.touchable       = touchable
end

function BottomPanel:UpdateAudioBtn()
    if APIGateway.IsSoundEnable() then
        self.btn_audio:GetController("c1").selectedIndex = 0
    else
        self.btn_audio:GetController("c1").selectedIndex = 1
    end
end

return BottomPanel