-- 彩金面板

local LotteryPanel = Class("LotteryPanel")

function LotteryPanel:ctor(render)
    self.render = render

    self.mini        = render:GetChild("label_mini") 
    self.minor       = render:GetChild("label_minor")
    self.maxi       = render:GetChild("label_maxi")
    self.major       = render:GetChild("label_major")
    self.grand       = render:GetChild("label_grand")
    self.lob_mini    = render:GetChild("label_lob_mini") 
    self.lob_minor   = render:GetChild("label_lob_minor")
    self.lob_maxi   = render:GetChild("label_lob_maxi")
    self.lob_major   = render:GetChild("label_lob_major")
    self.lob_grand   = render:GetChild("label_lob_grand")

    self.uiJackpots = {
        [1] = { label = self.mini , lobby_label = self.lob_mini},
        [2] = { label = self.minor, lobby_label = self.lob_minor},
        [3] = { label = self.maxi, lobby_label = self.lob_maxi},
        [4] = { label = self.major, lobby_label = self.lob_major},
        [5] = { label = self.grand, lobby_label = self.lob_grand},
    }
    for k, v in pairs(self.uiJackpots) do
        v.label.text = ""
        v.lobby_label.text = ""

        v.label.visible = not FCasinoCtx.commonPanel:DisplayHallExchangeRate()
        v.lobby_label.visible = FCasinoCtx.commonPanel:DisplayHallExchangeRate()
    end

    -- 监听彩金推送通知
    FSysEventEmitter:AddListener(FSysEvent.ON_RECV_LOTTERT_DATA, handler(self, self.OnMsg_OneGameLotteryRet), self)
    -- 监听押注值改变
    FSysEventEmitter:AddListener(FSysEvent.CHANGE_BET_VALUE, handler(self, self.Update), self)
    FSysEventEmitter:AddListener(FSysEvent.CHANGE_DISPLAY_EXCHANGERATE, function(useLobby)
        for k, v in pairs(self.uiJackpots) do
            v.label.visible = not useLobby
            v.lobby_label.visible = useLobby
        end
    end, self)
end

function LotteryPanel:__delete()
    for k, v in pairs(self.uiJackpots) do
        if v.tweener then v.tweener:Kill() end
        FTween.KillTweens(v.label)
    end
    FTween.KillTweens(self.render)
    APIGateway.RemoveAllSubscribers(self)
    FSysEventEmitter:RemoveListenersByTag(self)
end

function LotteryPanel:OnMsg_OneGameLotteryRet(msg)
    -- dump(msg,"LoooooooooooooooooooooooooootteryPanel")
    self.jackpotInfos = msg.infos
    self:Update()
end

function LotteryPanel:Update()
    if not self.jackpotInfos then return end
    
    for k, info in pairs(self.jackpotInfos) do
        local uiJackpot = self.uiJackpots[info.lType]
        if uiJackpot then
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
    end
end

return LotteryPanel
