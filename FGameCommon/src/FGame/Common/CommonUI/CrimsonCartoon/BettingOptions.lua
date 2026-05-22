-- 游戏押注选项界面

local BettingOptions = Class("BettingOptions")

local PickerViewType = {
    BetBase  = 1,
    Level    = 2,
    Line     = 3,
    BetValue = 4,
}

function BettingOptions:ctor()
    if APIGateway.IsDeviceOrientationPortrai() then
        self.render = FairyGUI.UIPackage.CreateObject(FTheme.curPkgName, "BettingOptions_V")
    else
        self.render = FairyGUI.UIPackage.CreateObject(FTheme.curPkgName, "BettingOptions")
    end
    self.render:MakeFullScreen()
    self.render:GetTransition("open"):Play(function()
        self.bOpenFinish = true
        self:OnOpenFinish()
    end)
    GetFairyRoot():AddChild(self.render)
end

function BettingOptions:OnOpenFinish()
    local frame = self.render:GetChild("frame")
    self.frame = frame

    self:InitText()    
    self:InitData()

    self.render:GetTransition("fadein"):Play()

    self.btn_close = frame:GetChild("btn_close")
    self.btn_confirm = frame:GetChild("btn_confirm")
    self.btn_max_bet = frame:GetChild("btn_max_bet")
    
    -- 关闭回调
    FToolSet.AddClickListener(self.btn_close, handler(self, self.OnClickClose))
    FToolSet.AddClickListener(self.render:GetChild("mask"), handler(self, self.OnClickClose))
    FToolSet.AddClickListener(self.btn_confirm, handler(self, self.OnClickConfirm))
    FToolSet.AddClickListener(self.btn_max_bet, handler(self, self.OnClickMaxBet))
    
    FSysEventEmitter:AddListener(FSysEvent.ON_LOGIC_UPDATE, handler(self, self.OnUpdate), self)
end

function BettingOptions:InitText()
    local frame = self.frame

    local title           = frame:GetChild("title")
    local title_bet       = frame:GetChild("title_bet")
    local title_level     = frame:GetChild("title_level")
    local title_line      = frame:GetChild("title_line")
    local title_bet_value = frame:GetChild("title_bet_value")
    local btn_max_bet     = frame:GetChild("btn_max_bet")
    local btn_confirm     = frame:GetChild("btn_confirm")
    local text_game_money = frame:GetChild("text_game_money")
    local text_bet        = frame:GetChild("text_bet")
    local text_win        = frame:GetChild("text_win")

    -- 文本设置
    title.text           = APIGateway.GetLangText("fgame_crimson_cartoon_title_3")
    title_bet.text       = APIGateway.GetLangText("fgame_crimson_cartoon_title_4")
    title_level.text     = APIGateway.GetLangText("fgame_crimson_cartoon_title_5")
    title_line.text      = APIGateway.GetLangText("fgame_crimson_cartoon_title_6")
    title_bet_value.text = APIGateway.GetLangText("fgame_crimson_cartoon_title_7")
    btn_max_bet.text     = APIGateway.GetLangText("fgame_crimson_cartoon_title_8")
    btn_confirm.text     = APIGateway.GetLangText("fgame_crimson_cartoon_title_9")

    -- 变色
    title_bet_value.color = FTheme.curThemCfg.textColor
    btn_max_bet:GetChild("title").color     = FTheme.curThemCfg.textColor
    btn_max_bet:GetChild("icon").color      = FTheme.curThemCfg.textColor
    btn_confirm:GetChild("icon").color      = FTheme.curThemCfg.textColor
    text_game_money:GetChild("icon").color  = FTheme.curThemCfg.textColor
    text_bet:GetChild("icon").color         = FTheme.curThemCfg.textColor
    text_win:GetChild("icon").color         = FTheme.curThemCfg.textColor
    
    text_game_money.text = FCasinoCtx.commonPanel.bottomPanel.text_game_money.text
    text_bet.text = FCasinoCtx.commonPanel.bottomPanel.text_bet.text
    text_win.text = FCasinoCtx.commonPanel.bottomPanel.text_win.text
end

function BettingOptions:InitData()
    local currentBetCfg = FCasinoCtx.commonPanel:GetCurrentBetConfig()
    local betCfg = FCasinoCtx.commonPanel.betCfg
    self.pickerDatas = {}

    local betValueIndex = 1


    -- 押注线，每个押注倍率一样  不能切换
    local lineNum = betCfg[1][1].betLine

    -- 数据初始化
    for k, v in pairs(PickerViewType) do
        self.pickerDatas[v] = {}
    end
    
    -- 计算基础押注值
    for k, cfg in pairs(betCfg) do
        local value = cfg[1].betMoney / lineNum

        table.insert(self.pickerDatas[PickerViewType.BetBase], {
            text = FTheme.curThemCfg.moneyTextPrefix .. FToolSet.NumToStr(value),
            value = value,
            index = k
        })
    end

    -- 档位值
    for level, levelCfg in pairs(betCfg[1]) do
        local value = levelCfg.betMoney / levelCfg.betLine / self.pickerDatas[PickerViewType.BetBase][1].value
        table.insert(self.pickerDatas[PickerViewType.Level], {
            text = string.format("%d", value),
            value = value,
            index = level
        })
    end

    -- 押线列表
    table.insert(self.pickerDatas[PickerViewType.Line], {
        text = string.format("%d", lineNum),
        value = lineNum
    })

    -- 计算所有结果
    local betValueMap = {}
    local index = 1
    for _, cfg in pairs(betCfg) do
        local baseData = self.pickerDatas[PickerViewType.BetBase][index]
        for level, levelCfg in pairs(cfg) do
            -- 校验配置
            local levelVal = self.pickerDatas[PickerViewType.Level][level].value
            if baseData.value * levelVal * lineNum ~= levelCfg.betMoney then
                dump(betCfg)
                dump(levelCfg, "出错配置")
                print("baseData.value", baseData.value, "level", level, "lineNum", lineNum)
                error("服务器配置错误")
            end
            betValueMap[levelCfg.betMoney] = true
        end
        index = index + 1
    end

    local betValues = {}
    for k, v in pairs(betValueMap) do
        table.insert(betValues, k)
    end
    table.sort(betValues, function(a, b) return a < b end)

    -- 结果列表
    for k, v in pairs(betValues) do
        table.insert(self.pickerDatas[PickerViewType.BetValue], {
            text = FTheme.curThemCfg.moneyTextPrefix .. FToolSet.NumToStr(v),
            value = v
        })

        if currentBetCfg.betMoney == v then
            betValueIndex = #self.pickerDatas[PickerViewType.BetValue]
        end
    end

    
    self.pickerViews = {}
    -- 列表初始化
    self:CreatePickerView("list_bet", PickerViewType.BetBase)
    self:CreatePickerView("list_level", PickerViewType.Level)
    self:CreatePickerView("list_line", PickerViewType.Line)
    self:CreatePickerView("list_bet_value", PickerViewType.BetValue, FTheme.curThemCfg.textColor)

    -- 滚动到对应的值
    self:JumpToCenter(self.pickerViews[PickerViewType.BetBase], FCasinoCtx.commonPanel:GetCurCValueIndex())
    self:JumpToCenter(self.pickerViews[PickerViewType.Level], FCasinoCtx.commonPanel:GetCurBetGear())
    self:JumpToCenter(self.pickerViews[PickerViewType.BetValue], betValueIndex)
end


function BettingOptions:CreatePickerView(name, pickerType, textColor)
    local itemHeight = 60

    -- 默认在两端添加符号-
    local appendEmptyIndex = 1
    local padding = itemHeight
    -- 只有一个元素时，不添加符号-
    if #self.pickerDatas[pickerType] <= 1 then
        appendEmptyIndex = 0
        padding = itemHeight * 2
    end

    local view = require("FGame.Common.Logic.General.PickerView").New(self.frame:GetChild(name))
    view.topPadding = padding
    view.bottomPadding = padding
    view.appendEmptyIndex = appendEmptyIndex

    view.onCellSizeCallback = function(pickerView, index)
        return pickerView.render.width, itemHeight
    end

    view.onLoadCellCallback = function(pickerView, index)
        local cell = FairyGUI.UIPackage.CreateObjectFromURL("ui://Theme_CrimsonCartoon/BettingOptionsItem_V")
        if textColor then
            cell:GetChild("title").color = textColor
        end

        index = index - appendEmptyIndex
        local data = self.pickerDatas[pickerType][index]
        if data then
            cell.text = data.text
        else
            cell.text = "-"
        end
        return cell
    end
    
    -- 同一时间只允许一个列表触摸
    view.onTouchPreJudgment = function()
        for k, v in pairs(self.pickerViews) do
            if v:IsTouching() or v:IsAutoRolling() then
                if view == v and not v:IsTouching() then
                    -- pass
                else
                    return false
                end
            end
        end
        return true
    end

    view.onScrollEndCallback = function()
        self:OnPickerScrllEnd(pickerType)
    end
    view:Reload(#self.pickerDatas[pickerType] + appendEmptyIndex * 2)

    self.pickerViews[pickerType] = view
end

function BettingOptions:GetPickerIndex(pickerType)
    local pickerView = self.pickerViews[pickerType]
    return pickerView:GetCurIndex() - pickerView.appendEmptyIndex
end

function BettingOptions:JumpToCenter(pickerView, index)
    pickerView:ScrollToCenter(pickerView.appendEmptyIndex + index)
end

function BettingOptions:ScrollToCenter(pickerType, index)
    local pickerView = self.pickerViews[pickerType]
    return pickerView:ScrollToCenter(index + pickerView.appendEmptyIndex, 600, 0.5)
end

function BettingOptions:OnPickerScrllEnd(pickerType)
    local baseIndex = self:GetPickerIndex(PickerViewType.BetBase)
    local levelIndex = self:GetPickerIndex(PickerViewType.Level)
    local lineIndex = self:GetPickerIndex(PickerViewType.Line)
    local betValueIndex = self:GetPickerIndex(PickerViewType.BetValue)

    -- print("baseIndex", baseIndex, "levelIndex", levelIndex, "lineIndex", lineIndex, "betValueIndex", betValueIndex)

    local base = self.pickerDatas[PickerViewType.BetBase][baseIndex].value
    local level = self.pickerDatas[PickerViewType.Level][levelIndex].value
    local line = self.pickerDatas[PickerViewType.Line][lineIndex].value
    local betValue = self.pickerDatas[PickerViewType.BetValue][betValueIndex].value
    
    -- print("base", base, "level", level, "line", line, "betValue", betValue)
    
    if pickerType == PickerViewType.BetValue then
        if base * level * line == betValue then
            return
        end

        for i, baseData in pairs(self.pickerDatas[PickerViewType.BetBase]) do
            for j, levelData in pairs(self.pickerDatas[PickerViewType.Level]) do
                for k, lineData in pairs(self.pickerDatas[PickerViewType.Line]) do
                    if baseData.value * levelData.value * lineData.value == betValue then
                        self:ScrollToCenter(PickerViewType.BetBase, i)
                        self:ScrollToCenter(PickerViewType.Level, j)
                        self:ScrollToCenter(PickerViewType.Line, k)
                        return
                    end
                end
            end
        end

    else
        betValue = base * level * line
        for k, v in pairs(self.pickerDatas[PickerViewType.BetValue]) do
            if v.value == betValue then
                self:ScrollToCenter(PickerViewType.BetValue, k)
                return
            end
        end
    end
end

function BettingOptions:IsBusy()
    for k, v in pairs(self.pickerViews) do
        if v:IsTouching() or v:IsAutoRolling() or v:IsAnimatedScroll() then
            return true
        end
    end
    return false
end

function BettingOptions:__delete()
    FSysEventEmitter:RemoveListenersByTag(self)
    for k, v in pairs(self.pickerViews or {}) do
        v:Delete()
    end
    self.render:RemoveFromParent(true)
end

-- @brief 点击关闭按钮
function BettingOptions:OnClickClose()
    if not self.bOpenFinish then return end
    if self:IsBusy() or self.bPlayClose then return end
    self.bPlayClose = true
    self.render:GetTransition("close"):Play(self.onDestroyCallback)
end

function BettingOptions:OnClickConfirm()
    if self:IsBusy() or self.bPlayClose then return end

    local baseIndex = self:GetPickerIndex(PickerViewType.BetBase)
    local levelIndex = self:GetPickerIndex(PickerViewType.Level)
    local lineIndex = self:GetPickerIndex(PickerViewType.Line)
    local betValueIndex = self:GetPickerIndex(PickerViewType.BetValue)

    local baseData = self.pickerDatas[PickerViewType.BetBase][baseIndex]
    local levelData = self.pickerDatas[PickerViewType.Level][levelIndex]
    local lineData = self.pickerDatas[PickerViewType.Line][lineIndex]
    local betValueData = self.pickerDatas[PickerViewType.BetValue][betValueIndex]

    local betCfg = FCasinoCtx.commonPanel.betCfg
    local cfg = betCfg[baseData.index][levelData.index]

    -- 校验一下值
    if cfg.betLine == lineData.value and cfg.betMoney == betValueData.value then
        FCasinoCtx.commonPanel:SetCurCValueIndex(baseIndex, levelIndex)
        FCasinoCtx.commonPanel.bottomPanel:UpdateBetChangeBtn()
        self:OnClickClose()
    else
        print("配置出错!!!!!!!!!!!!!!!!!!!!!")
    end
end

function BettingOptions:OnClickMaxBet()
    if self:IsBusy() or self.bPlayClose then return end

    self:ScrollToCenter(PickerViewType.BetBase, #self.pickerDatas[PickerViewType.BetBase])
    self:ScrollToCenter(PickerViewType.Level, #self.pickerDatas[PickerViewType.Level])
    self:ScrollToCenter(PickerViewType.Line, #self.pickerDatas[PickerViewType.Line])
    self:ScrollToCenter(PickerViewType.BetValue, #self.pickerDatas[PickerViewType.BetValue])
end

function BettingOptions:SetDestroyCallback(cb)
    self.onDestroyCallback = cb
end

function BettingOptions:OnUpdate(dt)
    local busy = self:IsBusy()
    self.btn_close.grayed = busy
    self.btn_confirm.grayed = busy
    self.btn_max_bet.grayed = busy
end

return BettingOptions