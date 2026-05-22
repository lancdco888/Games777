local CaijinPanel = Class("CaijinPanel")
function CaijinPanel:ctor(render)
    self.render = render
    if not self.render then
        print("caijin self.render == nil")
    end
    self.isShowmini = true
    self:InitUI()
   
    -- 监听彩金推送通知
    FSysEventEmitter:AddListener(FSysEvent.ON_RECV_LOTTERT_DATA, handler(self, self.OnMsg_OneGameLotteryRet), self)
    -- 监听押注值改变Text"
    FSysEventEmitter:AddListener(FSysEvent.CHANGE_BET_VALUE, handler(self, self.Update), self)
end

function CaijinPanel:__delete()
    for k, v in pairs(self.uiJackpots) do
        if v.tweener then v.tweener:Kill() end
    end

    APIGateway.RemoveAllSubscribers(self)
    FSysEventEmitter:RemoveListenersByTag(self)
end
function CaijinPanel:InitUI()

    self.grandtext = self.render:GetChild("grandText")
    self.majortext = self.render:GetChild("majorText")
    self.minortext = self.render:GetChild("minorText")
    self.minitext = self.render:GetChild("miniText")
    self.goldreeltext = self.render:GetChild("goldreelText")

    self.uiJackpots = {
        [1] = { label = self.minitext },
        [2] = { label = self.minortext},
        [3] = { label = self.majortext},
        [4] = { label = self.grandtext},
        [5] = { label = self.goldreeltext},
    }
    for k, v in pairs(self.uiJackpots) do
        v.label.text = ""
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
            -- 停止之前的动画
            if uiJackpot.tweener then
                uiJackpot.tweener:Kill()
                uiJackpot.tweener = nil
            end

            -- 固定倍数
            if info["betOrMoney"] == 0 then
                local value = info["lMinBet"] * FToolSet.GetBonusMultiplier()
                uiJackpot.label.text = FToolSet.LotteryNumToStr(value)
            else
                local value = info["lReal"]
                
                if uiJackpot.value == nil then
                    -- 直接设置
                    uiJackpot.label.text = FToolSet.LotteryNumToStr(value)
                else
                    local decimalPlaces = FToolSet.GetDecimalPlaces(FToolSet.LotteryNumToStr(value))

                    -- 动画滚动
                    uiJackpot.tweener = FairyGUI.GTween.ToDouble(uiJackpot.value, value, FConfig.Common.LotteryUpdateInterval)
                    :OnUpdate(function(tweener)
                        local text = FToolSet.LotteryNumToStr(tweener.value.d)
                        uiJackpot.label.text = FToolSet.FixedDecimalPlaces(text, decimalPlaces)
                    end)
                    :OnComplete(function()
                        uiJackpot.tweener = nil
                        uiJackpot.label.text = FToolSet.LotteryNumToStr(value)
                    end)
                end
                uiJackpot.value = value
            end
        end
    end
end

return CaijinPanel