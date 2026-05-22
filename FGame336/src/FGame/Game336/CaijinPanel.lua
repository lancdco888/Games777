local CaijinPanel = Class("CaijinPanel")
function CaijinPanel:ctor(render)
    self.render = render
    if not self.render then
        print("caijin self.render == nil")
    end
    self:InitUI()
    
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

function CaijinPanel:__delete()
    for k, v in pairs(self.uiJackpots) do
        if v.tweener then v.tweener:Kill() end
        FTween.KillTweens(v.label)
    end
    APIGateway.RemoveAllSubscribers(self)
    FSysEventEmitter:RemoveListenersByTag(self)
end

function CaijinPanel:InitUI()
    self.grand = self.render:GetChild("grand")
    self.major = self.render:GetChild("major")
    self.minor = self.render:GetChild("minor")
    self.mini = self.render:GetChild("mini")

    self.uiJackpots = {
        [2] = { label = self.mini ,lobby_label =self.render:GetChild("mini_label")},
        [3] = { label = self.minor,lobby_label =self.render:GetChild("minor_label")},
        [4] = { label = self.major,lobby_label =self.render:GetChild("major_label")},
        [5] = { label = self.grand,lobby_label =self.render:GetChild("grand_label")},
    }
    for k, v in pairs(self.uiJackpots) do
        v.label.text = ""
        v.lobby_label.text = ""
        v.label.visible = not FCasinoCtx.commonPanel:DisplayHallExchangeRate()
        v.lobby_label.visible = FCasinoCtx.commonPanel:DisplayHallExchangeRate()
    end


end
function CaijinPanel:OnMsg_OneGameLotteryRet(msg)
    self.jackpotInfos = msg.infos
    self:Update()
end

function CaijinPanel:Update()
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

return CaijinPanel