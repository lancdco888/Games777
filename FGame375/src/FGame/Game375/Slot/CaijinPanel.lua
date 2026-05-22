local CaijinPanel = Class("CaijinPanel")
function CaijinPanel:ctor(render)
    self.render = render
    self.bigorsmall = false
    self.addnumber = 0
    self:InitUI()

    -- 监听彩金推送通知
    FSysEventEmitter:AddListener(FSysEvent.ON_RECV_LOTTERT_DATA, handler(self, self.OnMsg_OneGameLotteryRet), self)
    -- 监听押注值改变
    FSysEventEmitter:AddListener(FSysEvent.CHANGE_BET_VALUE, handler(self, self.Update), self)
    -- 监听分和钱切换
    FSysEventEmitter:AddListener(FSysEvent.CHANGE_DISPLAY_EXCHANGERATE, function(useLobby)
        for k, v in pairs(self.uiJackpots_normal) do
            v.label.visible = not useLobby
            v.lobby_label.visible = useLobby
        end
        for k, v in pairs(self.uiJackpots_special) do
            v.label.visible = not useLobby
            v.lobby_label.visible = useLobby
        end
    end, self)
end

function CaijinPanel:__delete()
    for k, v in pairs(self.uiJackpots_normal) do
        if v.tweener then v.tweener:Kill() end
        FTween.KillTweens(v.label)
    end
    for k, v in pairs(self.uiJackpots_special) do
        if v.tweener then v.tweener:Kill() end
        FTween.KillTweens(v.label)
    end
    FTween.KillTweens(self.render)
    APIGateway.RemoveAllSubscribers(self)
    FSysEventEmitter:RemoveListenersByTag(self)
end

function CaijinPanel:ChangeControllerState(str_)
    self.render:GetController("game_state").selectedPage = str_
end

function CaijinPanel:InitUI()
    local list_ = {
        [1] = "mini",
        [2] = "minor",
        [3] = "major",
        [4] = "grand",
    }
    --普通节点
    self.uiJackpots_normal = {}
    local normal_node = self.render:GetChild("normal")
    for index, value in ipairs(list_) do
        local node = normal_node:GetChild(value)
        self.uiJackpots_normal[index + 1] = {
            label = node:GetChild("number"),
            lobby_label = node:GetChild("number_lobby")
        }
        self.uiJackpots_normal[index + 1].label.text = ""
        self.uiJackpots_normal[index + 1].lobby_label.text = ""
        self.uiJackpots_normal[index + 1].node = node
        self.uiJackpots_normal[index + 1].name = value

        self.uiJackpots_normal[index + 1].label.visible = not FCasinoCtx.commonPanel:DisplayHallExchangeRate()
        self.uiJackpots_normal[index + 1].lobby_label.visible = FCasinoCtx.commonPanel:DisplayHallExchangeRate()
    end
    --特殊节点
    self.uiJackpots_special = {}
    local special_node = self.render:GetChild("special")
    for index, value in ipairs(list_) do
        local node = special_node:GetChild(value)
        self.uiJackpots_special[index + 1] = {
            label = node:GetChild("number"),
            lobby_label = node:GetChild("number_lobby")
        }
        self.uiJackpots_special[index + 1].label.text = ""
        self.uiJackpots_special[index + 1].lobby_label.text = ""
        self.uiJackpots_special[index + 1].node = node
        self.uiJackpots_special[index + 1].name = value

        self.uiJackpots_special[index + 1].label.visible = not FCasinoCtx.commonPanel:DisplayHallExchangeRate()
        self.uiJackpots_special[index + 1].lobby_label.visible = FCasinoCtx.commonPanel:DisplayHallExchangeRate()
    end
    --正常显示
    self:ChangeNormal()
    self:ChangeNowShow()
end

--正常显示
function CaijinPanel:ChangeNormal()
    for i = 2, 5 do
        local data_1 = self.uiJackpots_normal[i]
        data_1.node:GetTransition(data_1.name .. "_normal"):Play()
        local data_2 = self.uiJackpots_special[i]
        data_2.node:GetTransition(data_2.name .. "_normal"):Play()
    end
end

--中奖显示
function CaijinPanel:CaijinWin(add_index)
    for i = 2, 5 do
        if add_index + 2 == i then
            local data_1 = self.uiJackpots_normal[i]
            data_1.node:GetTransition(data_1.name .. "_win"):Play(-1,0,function ()
            end)
            local data_2 = self.uiJackpots_special[i]
            data_2.node:GetTransition(data_2.name .. "_win"):Play(-1,0,function ()
            end)
        end
    end
end

--停止中奖显示
function CaijinPanel:StopWin()
    for i = 2, 5 do
        local data_1 = self.uiJackpots_normal[i]
        data_1.node:GetTransition(data_1.name .. "_win"):Stop()
        local data_2 = self.uiJackpots_special[i]
        data_2.node:GetTransition(data_2.name .. "_win"):Stop()
    end
    self:ChangeNormal()
end

--切换彩金显示
function CaijinPanel:ChangeNowShow()
    self.bigorsmall = not self.bigorsmall
    for i = 2, 5 do
        local data_1 = self.uiJackpots_normal[i]
        if i <= 3 then
            data_1.node.visible = not self.bigorsmall
        else
            data_1.node.visible = self.bigorsmall
        end
    end
end

function CaijinPanel:UpdateUI()
    self.addnumber = self.addnumber + 1
    if self.addnumber >= 3 then
        self.addnumber = 0
        self:ChangeNowShow()
    end
end

function CaijinPanel:OnMsg_OneGameLotteryRet(msg)
    self.jackpotInfos = msg.infos
    self:Update()
end

function CaijinPanel:NumberChange(info,uiJackpot)
    -- 固定倍数
    if info["betOrMoney"] == 0 then
        local value = info["lMinBet"] * FToolSet.GetBonusMultiplier()
        uiJackpot.label.text = FToolSet.LotteryNumToStr(value)
        uiJackpot.lobby_label.text = FConfig.Common.LotteryLobbyRateTextPrefix .. FToolSet.LotteryNumToStr(value, FConfig.Common.LotteryLobbyRateConvertInt, true)
    else
        local value = info["lReal"]

        if uiJackpot.current == nil then
            uiJackpot.current = value - info["setp"]
        end

        if uiJackpot.value ~= value then
            -- 停止之前的动画
            if uiJackpot.tweener then
                uiJackpot.tweener:Kill()
                uiJackpot.tweener = nil
            end

            local decimalPlaces = FToolSet.GetDecimalPlaces(FToolSet.LotteryNumToStr(value))
            local decimalPlacesLobby = FToolSet.GetDecimalPlaces(FToolSet.LotteryNumToStr(value, FConfig.Common.LotteryLobbyRateConvertInt, true))

            -- 动画滚动
            uiJackpot.tweener = FairyGUI.GTween.ToDouble(uiJackpot.current, value, FConfig.Common.LotteryUpdateInterval)
            :OnUpdate(function(tweener)
                uiJackpot.current = tweener.value.d

                local text = FToolSet.LotteryNumToStr(uiJackpot.current)
                uiJackpot.label.text = FToolSet.FixedDecimalPlaces(text, decimalPlaces)

                text = FToolSet.LotteryNumToStr(uiJackpot.current, FConfig.Common.LotteryLobbyRateConvertInt, true)
                uiJackpot.lobby_label.text = FConfig.Common.LotteryLobbyRateTextPrefix .. FToolSet.FixedDecimalPlaces(text, decimalPlacesLobby)
            end)
            :OnComplete(function()
                uiJackpot.tweener = nil
            end)
        end
        uiJackpot.value = value
    end
end

function CaijinPanel:Update()
    if not self.jackpotInfos then return end
    for k, info in pairs(self.jackpotInfos) do
        --普通
        local uiJackpot_normal = self.uiJackpots_normal[info.lType]
        if uiJackpot_normal then
            self:NumberChange(info,uiJackpot_normal)
        end
        --特殊
        local uiJackpots_special = self.uiJackpots_special[info.lType]
        if uiJackpots_special then
            self:NumberChange(info,uiJackpots_special)
        end
    end
end

return CaijinPanel