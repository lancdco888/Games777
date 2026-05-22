-- 彩金面板

local LotteryPanel = Class("LotteryPanel")

function LotteryPanel:ctor(render)
    self.render = render

    self.jpAnims = {}
    do
        -- 4:mega - 1:mini
        self.CfgPlayList = { "mega", "major", "minor", "mini" }
        for i = 1, 4 do
            self.jpAnims[i] = {}
            self.jpAnims[i].render = self.render:GetChild("jp"..i)
            self.jpAnims[i].uiPanel = self.jpAnims[i].render:GetChild("panel_1")
            self.jpAnims[i].uiNum = self.jpAnims[i].uiPanel:GetChild("num")
            self.jpAnims[i].uiNumLobby = self.jpAnims[i].uiPanel:GetChild("num_lobby")
            self.jpAnims[i].uiPanel:GetController("mode").selectedPage=(self.CfgPlayList[i])
            self.jpAnims[i].uiNum.text = 0
            self.jpAnims[i].uiNumLobby.text = 0
            self.jpAnims[i].render.visible = false
            self.jpAnims[i].animIndex = 1
        end
    
        local orderAnims = { {name="show_1"}, {name="show_2"}, {name=""}, {name="show_3"}, }
        local runDelay = 10
    
        local function _playNext( jpIndex, animIndex )
            -- print("_playNext:",jpIndex,animIndex)
            animIndex = orderAnims[animIndex] and animIndex or 1
            local playName = orderAnims[animIndex].name
            local jpRender = self.jpAnims[jpIndex].render
            jpRender.visible = #playName > 0
            if #playName > 0 then
                if animIndex == 1 then
                    jpRender.sortingOrder = jpRender.sortingOrder + 1
                end    
                jpRender:GetTransition( orderAnims[animIndex].name ):Play(function() end)
            else
                jpRender.sortingOrder = jpRender.sortingOrder>10 and 1 or jpRender.sortingOrder
            end
            StartOnceTimer( function()
                animIndex = animIndex + 1
                self.playNext( jpIndex, animIndex )
            end, runDelay )
        end
        self.playNext = _playNext
    
        self.jpAnims[1].render.visible = true
        self.jpAnims[1].render:GetTransition("show_1_2"):Play(function() end)
        self.jpAnims[2].render.visible = true
        self.jpAnims[2].render:GetTransition("show_3_2"):Play(function() end)
        StartOnceTimer( function()
            self.playNext( 1, 2 )
            self.playNext( 2, 1 )
            self.playNext( 3, 4 )
            self.playNext( 4, 3 )
        end, runDelay )
    end

    self.uiJackpots = {
        -- [2] = { label = self.render:GetChild("j1"), lobby_label = self.render:GetChild("j1_lobby")},
        -- [3] = { label = self.render:GetChild("j2"), lobby_label = self.render:GetChild("j2_lobby")},
        -- [4] = { label = self.render:GetChild("j3"), lobby_label = self.render:GetChild("j3_lobby")},
        -- [5] = { label = self.render:GetChild("j4"), lobby_label = self.render:GetChild("j4_lobby")},
        [2] = { label = self.jpAnims[4].uiNum, lobby_label = self.jpAnims[4].uiNumLobby},
        [3] = { label = self.jpAnims[3].uiNum, lobby_label = self.jpAnims[3].uiNumLobby},
        [4] = { label = self.jpAnims[2].uiNum, lobby_label = self.jpAnims[2].uiNumLobby},
        [5] = { label = self.jpAnims[1].uiNum, lobby_label = self.jpAnims[1].uiNumLobby},
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
    -- dump(msg,"msg",10)
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
