
local TopPanel = Class("TopPanel")

local function SwapPos(label1, label2)
    local xy1 = label1.xy
    local xy2 = label2.xy
    label1.xy = xy2
    label2.xy = xy1
end

function TopPanel:ctor(render)
    self.render = render

    self.btn_back = render:GetChild("btn_back")
    self.btn_menu = render:GetChild("btn_menu")

    -- 返回按钮
    FToolSet.AddClickListener(self.btn_back, function()
        if FCasinoCtx then
            FCasinoCtx:GetGame():OnClickBack()
        end
    end)

    -- 菜单按钮
    FToolSet.AddClickListener(self.btn_menu, function()
        APIGateway.OpenSettingPanel()
    end)

    -- 玩家金币
    self.text_game_money = render:GetChild("text_game_money")
    self.text_lobby_money = render:GetChild("text_lobby_money")

    -- 玩家绑定金币
    self.text_game_bind_money = render:GetChild("text_game_bind_money")
    self.text_lobby_bind_money = render:GetChild("text_lobby_bind_money")
    
    self.moneyMaxWitdh = self.text_lobby_money.width
    self.bindMoneyMaxWitdh = self.text_lobby_bind_money.width

    -- 玩家当前押注
    self.text_game_bet = render:GetChild("text_game_bet")
    self.text_lobby_bet = render:GetChild("text_lobby_bet")
    -- 玩家本局赢的金币
    self.text_game_win = render:GetChild("text_game_win")
    self.text_lobby_win = render:GetChild("text_lobby_win")

    -- 强制显示分
    if FToolSet.IsForceShowGameScore() then
        self.text_lobby_money.visible = false
        self.text_lobby_bind_money.visible = false

        self.text_lobby_bet.visible = false
        self.text_lobby_win.visible = false

        self.text_game_money.y      = self.text_game_money.y + 12
        self.text_game_bind_money.y = self.text_game_bind_money.y + 12
        self.text_game_bet.y        = self.text_game_bet.y + 12
        self.text_game_win.y        = self.text_game_win.y + 12
    else
        -- 汇率相同时只显示大厅汇率
        local lobbyData = FCasinoCtx.lobbyData
        if lobbyData.gameExchangeRate == lobbyData.lobbyExchangeRate then
            -- 交换label
            SwapPos(self.text_lobby_money, self.text_game_money)
            SwapPos(self.text_lobby_bind_money, self.text_game_bind_money)
            self.text_lobby_money, self.text_game_money = self.text_game_money, self.text_lobby_money
            self.text_lobby_bind_money, self.text_game_bind_money = self.text_game_bind_money, self.text_lobby_bind_money
    
            self.text_game_money.visible = false
            self.text_game_bind_money.visible = false
            self.text_game_bet.visible = false
            self.text_game_win.visible = false

            self.text_lobby_money.y      = self.text_lobby_money.y - 16
            self.text_lobby_bind_money.y = self.text_lobby_bind_money.y - 16
            self.text_lobby_bet.y        = self.text_lobby_bet.y   - 16
            self.text_lobby_win.y        = self.text_lobby_win.y   - 16
        end
    end

    -- 当前显示的金币信息值
    self.curShowMoney = 0
    self.curShowBindMoney = 0
    self.curShowWinMoney = 0
end

function TopPanel:__delete()
end

-- @brief 获取当前金币类型
function TopPanel:GetMoneyType()
    return self.render:GetController("c_money_type").selectedIndex
end

-- @brief 设置当前金币类型
function TopPanel:SetMoneyType(value)
    self.render:GetController("c_money_type").selectedIndex = value
end

-- @brief 设置当前玩家金币
-- @param value:number
-- @param moneyType 金币类型
-- @param rolling 是否正在滚动中
-- @param scrollEndValue 滚动结束值
function TopPanel:SetPlayerMoney(value, moneyType, rolling, scrollEndValue)
    local gameText = FToolSet.NumToStr(value)
    local lobbyText = FToolSet.NumToStr(value, false, true, 3)

    if string.find(lobbyText, "%.") then
        -- 去除尾部0
        -- 1.230 -> 1.23
        lobbyText = string.gsub(lobbyText, "0+$", "")
        -- 去除尾部.
        -- 0. -> 0
        lobbyText = string.gsub(lobbyText, "%.$", "")
    end

    -- 停止时显示实际数量
    if rolling then
        -- 如果知道滚动结果值，则按照结束值位数来保留
        if scrollEndValue then
            local endText = FToolSet.NumToStr(scrollEndValue)
            -- 去除尾部0
            endText = FToolSet:TrimNumStrTailZero(endText)
            gameText = FToolSet.FixedDecimalPlaces(gameText, FToolSet.GetDecimalPlaces(endText))

            endText = FToolSet.NumToStr(scrollEndValue, false, true, 3)
            -- 去除尾部0
            endText = FToolSet:TrimNumStrTailZero(endText)
            lobbyText = FToolSet.FixedDecimalPlaces(lobbyText, FToolSet.GetDecimalPlaces(endText))
        -- 滚动中强制保留两位小数，防止晃动
        else
            if not FToolSet.IsForceShowGameScore() then
                gameText = FToolSet.FixedDecimalPlaces(gameText, 2)
            end
            lobbyText = FToolSet.FixedDecimalPlaces(lobbyText, 2)
        end
    end

    lobbyText = "$" .. lobbyText

    if moneyType == FPlayerMoneyType.NORMAL_MONEY then
        self.text_game_money.text = gameText
        self.text_lobby_money.text = lobbyText
        self.curShowMoney = value

        self:LimitTextSize(self.text_game_money, self.moneyMaxWitdh)
        self:LimitTextSize(self.text_lobby_money, self.moneyMaxWitdh)
    else
        self.text_game_bind_money.text = gameText
        self.text_lobby_bind_money.text = lobbyText
        self.curShowBindMoney = value

        self:LimitTextSize(self.text_game_bind_money, self.bindMoneyMaxWitdh)
        self:LimitTextSize(self.text_lobby_bind_money, self.bindMoneyMaxWitdh)
    end
end

function TopPanel:LimitTextSize(label, maxWidth)
    if label.width > maxWidth then
        local scaleValue = maxWidth / label.width
        label.scale = vec2(scaleValue, scaleValue)
    else
        label.scale = vec2(1, 1)
    end
end

-- @brief 设置当前赢的金币
-- @param value:number
-- @param rolling 是否正在滚动中
-- @param scrollEndValue 滚动结束值
function TopPanel:SetWinMoney(value, rolling, scrollEndValue)
    local gameText = FToolSet.NumToStr(value)
    local lobbyText = FToolSet.NumToStr(value, false, true, FConfig.Common.TopLobbyRateTextDecimalPlaces)

    if rolling then
        -- 如果知道滚动结果值，则按照结束值位数来保留
        if scrollEndValue then
            local endText = FToolSet.NumToStr(scrollEndValue)
            endText = FToolSet:TrimNumStrTailZero(endText)
            gameText = FToolSet.FixedDecimalPlaces(gameText, FToolSet.GetDecimalPlaces(endText))

            endText = FToolSet.NumToStr(scrollEndValue, false, true, FConfig.Common.TopLobbyRateTextDecimalPlaces)
            endText = FToolSet:TrimNumStrTailZero(endText)
            lobbyText = FToolSet.FixedDecimalPlaces(lobbyText, FToolSet.GetDecimalPlaces(endText))
        else
            -- 滚动中强制保留两位小数，防止晃动
            if not FToolSet.IsForceShowGameScore() then
                gameText = FToolSet.FixedDecimalPlaces(gameText, FConfig.Common.TopLobbyRateTextDecimalPlaces)
            end
            lobbyText = FToolSet.FixedDecimalPlaces(lobbyText, FConfig.Common.TopLobbyRateTextDecimalPlaces)
        end
    end
    if not rolling then
        gameText = FToolSet:TrimNumStrTailZero(gameText)
        lobbyText = FToolSet:TrimNumStrTailZero(lobbyText)
    end

    lobbyText = "$" .. lobbyText

    self.text_game_win.text = gameText
    self.text_lobby_win.text = lobbyText
    self.curShowWinMoney = value
end

return TopPanel