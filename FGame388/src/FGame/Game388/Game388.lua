local NormalSlot = require("FGame.Game388.Slot.NormalSlot")
local TopupBounsSlot = require("FGame.Game388.Slot.TopupBounsSlot")
local FreeSlot = require("FGame.Game388.Slot.FreeSlot")
local LotteryPanel = require("FGame.Game388.LotteryPanel")
local MusicCfg = require("FGame.Game388.Slot.MusicCfg")
local LuodiAddPanel = require("FGame.Game388.Slot.LuodiAddPanel")
local CoinFountain = require("FGame.Common.Logic.Effect.FountainPool")
local Tools = require("FGame.Game388.Slot.Tools")
local ConstCfg = require("FGame.Game388.Slot.ConstCfg")


local SlotType = {
    Normal = 1,        -- 普通类型
    Free = 2,          -- 免费游戏
    TopupBouns = 3,    -- 落地牌类型
    FreeTopupBouns = 4 -- 免中落地牌类型
}

local Game388 = Class("Game388", BaseGame)

function Game388:ctor(render)
    Tools.game = self
    self.render = render
    local slot = self.render:GetChild("slot")
    self.slot = slot
    local normalContainer = slot:GetChild("normal-container")
    local luodiAddPanelObj = self.render:GetChild("luodiAddPanel")
    self.freeGameCounter = self.render:GetChild("free-game-counter")
    self.freeGameCounter.visible = false
    self.luodiGameCollector = self.render:GetChild("luodi-game-collector")
    self.luodiGameCollector.visible = false

    self.luodiAddPanel = LuodiAddPanel.New(luodiAddPanelObj)

    self.curGameType = 0
    self.slotContainers = {}
    self.slotContainers[SlotType.Normal] = NormalSlot.New(normalContainer, self)
    self.slotContainers[SlotType.Normal]:SetVisible(false)

    self.slotContainers[SlotType.TopupBouns] = TopupBounsSlot.New(normalContainer, self)
    self.slotContainers[SlotType.FreeTopupBouns] = self.slotContainers[SlotType.TopupBouns] --3 4 共用
    self.slotContainers[SlotType.TopupBouns]:SetVisible(false)

    self.slotContainers[SlotType.Free] = FreeSlot.New(normalContainer, self)
    self.slotContainers[SlotType.Free]:SetVisible(false)
    self:ChangeGameType(SlotType.Normal)

    self.lotteryPanel = LotteryPanel.New(self.render:GetChild("lottery"))
    self.datas = {
        normalPacket = nil,   -- 普通旋转结果
        freeSpinPacket = nil, -- 免费旋转结果
        specialPacket = nil   -- 特殊旋转结果
    }

    self.soundBgmHandle = nil
    self.soundBgm = nil

    self.coinFountain = CoinFountain.New()
    self.coinFountain:SetSortingOrder(10)

    self._winCoin = 0

    -- 落地牌巨奖提示
    self.fullLuodix2 = self.render:GetChild("fullLuodix2")
    self.fullLuodix2.visible = false

    self.bigGrand = self.render:GetChild("grandJackpot")
    self.bigGrand.visible = false

    -- self.topupBounsFlyFire = TopupBounsFlyFire.New(self.render:GetChild("TopupBounsFlyFire"), self)
end

function Game388:__delete()
    self:StopDelayCallSpin()
    for i = 1, 3 do
        -- 3  4 共用
        if self.slotContainers[i] then self.slotContainers[i]:Delete() end
    end
    self.lotteryPanel:Delete()

    if self.CoinFountainTimer then
        StopTimer(self.CoinFountainTimer)
        self.CoinFountainTimer = nil
    end
    if self.LuodiCollectTimer then
        StopTimer(self.LuodiCollectTimer)
        self.LuodiCollectTimer = nil
        if self.callAfterCollectScore then
            self.callAfterCollectScore = nil
        end
    end
    if self.soundWinCoinEffectHandle then
        APIGateway.StopSound(self.soundWinCoinEffectHandle)
        self.soundWinCoinEffectHandle = nil
    end
    if self.soundWinCoinEffectHandleTimer then
        StopTimer(self.soundWinCoinEffectHandleTimer)
        self.soundWinCoinEffectHandleTimer = nil
    end

    if self.soundBgmHandle then
        APIGateway.StopSound(self.soundBgmHandle)
        self.soundBgmHandle = nil
    end
    self.coinFountain:Delete()

    if self.playCaijinAnimTimer then
        StopTimer(self.playCaijinAnimTimer)
        self.playCaijinAnimTimer = nil
        self.playCaijinAnimCallBack = nil
    end
    FTween.KillTweens(self.render)

    self.render = nil
end

function Game388:IsInLuodiMode()
    return self.curGameType == SlotType.TopupBouns or self.curGameType == SlotType.FreeTopupBouns
end
function Game388:IsInFreeLuodiMode()
    return self.curGameType == SlotType.FreeTopupBouns
end

-- @interface
-- @brief update
function Game388:Update(dt)
    Game388.super.Update(self, dt)
    for i = 1, 3 do
        -- 3  4 共用
        if self.slotContainers[i] then
            self.slotContainers[i]:Update(dt)
        end
    end
end

function Game388:SetIntoLuodiSymbolCount(grids)
    self.intoLuodiSymbolCount = 0
    for _,v in pairs(grids) do
        if v.icon == ConstCfg.LuodiSymbolId then
            self.intoLuodiSymbolCount =  self.intoLuodiSymbolCount + 1         
        end
    end
end

-- @interface
-- @brief 在游戏中断线重连恢复游戏
-- @param local  断线重连数据
function Game388:ReconnectRecoveryGame(data, isInitialize)

    self.disanbleSpinWhenReconnect = true
    StartOnceTimer(function()
        self.disanbleSpinWhenReconnect = false
    end,1)

    -- data.type 1 普通 2 免费 3 落地 4 落地免费
    if data.type == 1 then
        -- 普通
        local resumedNormal = data.resumedNormal
        local normalSpin = resumedNormal.normalSpin

        local bonusWin = data.currentWinCoin
        if normalSpin.intoSpecial ~= 0 then
            for _, cell in ipairs(resumedNormal.normalSpin.grids) do
                bonusWin = bonusWin - cell.SymbolValue
            end
        end

        if bonusWin > 0 then
            self:ShowBottomWin(true, bonusWin)
        end
        --print("断线重连 - 处理接收普通包")
        if not self:CheckSlotData(normalSpin.grids, SlotType.Normal) then
            -- 不一样
            self.datas.normalPacket = normalSpin
            if self.curGameType ~= 1 and self.isInSpecial then
                -- 已经在特殊游戏了
                self:SendPackage()
                return
            end
            if isInitialize or self.isInSpecial then
                self:OnNormalSpinResult(normalSpin, true)
            end
        else
            if self.isInSpecial then
                -- 已经在特殊游戏了
                self:SendPackage()
                return
            end
        end
        return
    elseif data.type == 2 then
        -- 免费
        local resumedNormal = data.resumedNormal
        local resumedFree = data.resumedFree
        --print("断线重连 - 处理接收免费")
        if not self:CheckSlotData(resumedFree.freeSpin.grids, SlotType.Free) then
            -- 不一样
            self.datas.normalPacket = resumedNormal.normalSpin
            self.datas.freeSpinPacket = resumedFree.freeSpin
            if
                resumedFree.freeSpin.intoSpecial == 0 and
                self.datas.freeSpinPacket.allCount <= self.datas.freeSpinPacket.totalCount
            then
                --没次数了
                self:OnNormalSpinResult(resumedNormal.normalSpin, true, function() end)
                return
            end

            self:ChangeBgm(MusicCfg.FREE_BG_MUSIC)
            local bonusWin = data.currentWinCoin
            if resumedFree.freeSpin.intoSpecial ~= 0 then
                for _, cell in ipairs(resumedFree.freeSpin.grids) do
                    bonusWin = bonusWin - cell.SymbolValue
                end
            end

            self.slotContainers[SlotType.Free]:ResetDatas(
                self.datas.freeSpinPacket.totalCount,
                self.datas.freeSpinPacket.allCount,
                bonusWin
            )
            self:ShowBottomWin(true, bonusWin)
            if self.curGameType ~= 2 and self.isInSpecial then
                self:SendPackage()
                return
            end
            self:OnFreeSpinResult(self.datas.freeSpinPacket, true)
        else
            if self.isInSpecial then
                self:SendPackage()
                return
            end
        end
        return
    elseif data.type == 3 then
        -- 落地
        local resumedNormal = data.resumedNormal
        local resumedSpecial = data.resumedSpecial
        self:SetIntoLuodiSymbolCount(resumedNormal.normalSpin.grids)

        -- 计算进入落地牌的线分  
        if resumedNormal.normalSpin.intoSpecial ~= 0 then
            local winCoin = resumedNormal.normalSpin.winCoin
            for _,line in pairs(resumedNormal.normalSpin.lines) do
                if line.lineIndex == 103 then winCoin = winCoin - line.winCoin end
            end 
            Game388.enterLuodiWinCoin = winCoin
        end
        --

        --print("断线重连 - 处理接收落地牌")
        if not self:CheckSlotData(resumedSpecial.specialSpin.grids, SlotType.TopupBouns) then
            -- 不一样
            self.datas.normalPacket = resumedNormal.normalSpin
            self.datas.specialPacket = resumedSpecial.specialSpin
            --没次数了
            if self.datas.specialPacket.totalCount == 0 then
                if self.curGameType ~= 3 and self.isInSpecial then
                    -- 已经在普通游戏了
                    self:SendPackage()
                    return
                end
                if isInitialize or self.isInSpecial then
                    -- 杀进程直接显示
                    self:OnNormalSpinResult(resumedNormal.normalSpin, true, function()
                    end)
                end
                return
            end

            local bonusWin = data.currentWinCoin
            for _, cell in ipairs(resumedSpecial.specialSpin.grids) do
                bonusWin = bonusWin - cell.SymbolValue
            end
            self.slotContainers[SlotType.TopupBouns]:ResetDatas(false, bonusWin, resumedSpecial.specialSpin.totalCount, resumedSpecial.specialSpin.allCount)
            self:OnSpecialSpinResult(self.datas.specialPacket, true)
            self:SetLuodiSlotFrameAndBGMByCount(self.slotContainers[self.curGameType]:GetTopupBounsCount())
            self:ShowBottomWin(true)
        else
            if self.isInSpecial then
                self:SendPackage()
            end
        end
        return
    elseif data.type == 4 then
        -- 免费落地
        local resumedNormal = data.resumedNormal
        local resumedSpecial = data.resumedSpecial
        local resumedFree = data.resumedFree

        -- 计算进入落地牌的线分  
        if resumedNormal.normalSpin.intoSpecial ~= 0 then
            local winCoin = resumedNormal.normalSpin.winCoin
            for _,line in pairs(resumedNormal.normalSpin.lines) do
                if line.lineIndex == 103 then winCoin = winCoin - line.winCoin end
            end 
            Game388.enterLuodiWinCoin = winCoin
        end
        --

        self:SetIntoLuodiSymbolCount(resumedFree.freeSpin.grids)
        if resumedSpecial.specialSpin.totalCount == 0 then
            -- 看看免费包
            --print("断线重连 - 处理接收免中落地牌 免费")
            if not self:CheckSlotData(resumedFree.freeSpin.grids, SlotType.Free) then
                -- 不一样
                self.datas.normalPacket = resumedNormal.normalSpin
                self.datas.freeSpinPacket = resumedFree.freeSpin
                -- dump(self.datas.freeSpinPacket,"断线重连数据")
                if self.datas.freeSpinPacket.allCount <= self.datas.freeSpinPacket.totalCount then
                    --没次数了
                    if self.curGameType ~= 4 and self.isInSpecial then
                        self:ChangeGameType(SlotType.Normal)
                        self:SendPackage()
                    end
                    if isInitialize or self.isInSpecial then
                        -- 杀进程直接显示
                        self:OnNormalSpinResult(resumedNormal.normalSpin, true, function()
                        end)
                    end
                    return
                end
                self:ChangeBgm(MusicCfg.FREE_BG_MUSIC)
                self.slotContainers[SlotType.Free]:ResetDatas(
                    self.datas.freeSpinPacket.totalCount,
                    self.datas.freeSpinPacket.allCount,
                    data.currentWinCoin
                )
                if isInitialize then
                    -- 杀进程直接显示
                    self:OnFreeSpinResult(resumedFree.freeSpin, true, function()
                        self:DelayCallSpin(2)
                        self:ShowBottomWin(true)
                    end)
                end
            else
                if self.isInSpecial then
                    self:ChangeGameType(SlotType.Free)
                    self:SendPackage()
                end
            end
        else
            --print("断线重连 - 处理接收免中落地牌")
            if not self:CheckSlotData(resumedSpecial.specialSpin.grids, SlotType.FreeTopupBouns) then
                -- 不一样
                self.datas.normalPacket = resumedNormal.normalSpin
                self.datas.specialPacket = resumedSpecial.specialSpin
                self.datas.freeSpinPacket = resumedFree.freeSpin
                -- dump(self.datas.specialPacket,"断线重连数据")
                self:ChangeGameType(SlotType.FreeTopupBouns)
                local bonusWin = data.currentWinCoin
                for _, cell in ipairs(resumedSpecial.specialSpin.grids) do
                    bonusWin = bonusWin - cell.SymbolValue
                end
                self.slotContainers[SlotType.FreeTopupBouns]:ResetDatas(
                    false,
                    bonusWin,
                    self.datas.specialPacket.totalCount,
                    self.datas.specialPacket.allCount
                )
                self.slotContainers[SlotType.Free]:ResetDatas(
                    self.datas.freeSpinPacket.totalCount,
                    self.datas.freeSpinPacket.allCount
                )
                if isInitialize or self.isInSpecial then
                    -- 杀进程直接显示
                    self:OnSpecialSpinResult(self.datas.specialPacket, true)
                end
                self:SetLuodiSlotFrameAndBGMByCount(self.slotContainers[self.curGameType]:GetTopupBounsCount())
                self:ShowBottomWin(true)
            else
                if self.isInSpecial then
                    self:SendPackage()
                end
            end
        end
        return
    end
end

-- 检查普通包跟当前包是否一样
function Game388:CheckSlotData(grids, type)
    local localGrids = nil
    if type == SlotType.Normal then
        if not self.datas.normalPacket or next(self.datas.normalPacket.grids) == nil then
            return false
        end
        localGrids = self.datas.normalPacket.grids
    elseif type == SlotType.Free then
        if not self.datas.freeSpinPacket or next(self.datas.freeSpinPacket.grids) == nil then
            return false
        end
        localGrids = self.datas.freeSpinPacket.grids
    elseif type == SlotType.TopupBouns then
        if not self.datas.specialPacket or next(self.datas.specialPacket.grids) == nil then
            return false
        end
        localGrids = self.datas.specialPacket.grids
    elseif type == SlotType.FreeTopupBouns then
        if not self.datas.specialPacket or next(self.datas.specialPacket.grids) == nil then
            return false
        end
        localGrids = self.datas.specialPacket.grids
    else
        print("error: CheckSlotData type:", type)
        return
    end

    for i = 1, #grids do
        local icon = grids[i].icon
        local bonusType = grids[i].SymbolType
        local bonusValue = grids[i].SymbolValue

        local lastIcon = localGrids[i].icon
        local lastbonusType = grids[i].SymbolType
        local lastbonusValue = grids[i].SymbolValue
        if icon ~= lastIcon or bonusType ~= lastbonusType or bonusValue ~= lastbonusValue then
            return false
        end
    end
    return true
end

Game388.mainVolumeDecreaseTimer = nil
-- @interface
-- @brief 点击开始按钮
function Game388:OnClickSpin(isSimulate)
    
    if self.disanbleSpinWhenReconnect and not isSimulate then return end

    if self.mainVolumeDecreaseTimer then
        StopTimer(self.mainVolumeDecreaseTimer) 
    end
    self:StopDelayCallSpin()
    if self.CoinFountainTimer then
        self.coinFountain:Stop()
        StopTimer(self.CoinFountainTimer)
        self.CoinFountainTimer = nil
    end
    if self.LuodiCollectTimer then
        self.coinFountain:Stop()
        StopTimer(self.LuodiCollectTimer)
        self.LuodiCollectTimer = nil

        if self.callAfterCollectScore then
            self.callAfterCollectScore()
            self.callAfterCollectScore = nil
        end
        self:ShowBottomWin(true, self._winCoin)
    end

    if self.soundWinCoinEffectHandle then
        APIGateway.StopSound(self.soundWinCoinEffectHandle)
        self.soundWinCoinEffectHandle = nil
    end


    if self.soundWinCoinEffectHandleTimer then
        StopTimer(self.soundWinCoinEffectHandleTimer)
        self.soundWinCoinEffectHandleTimer = nil
    end

    if FCasinoCtx.curGameMode == FGameMode.NORMAL then
        self.datas.freeSpinPacket = nil
        self.datas.specialPacket = nil
        -- 金币不足
        if not FCasinoCtx:PlayerSpinConsumption() then
            self.isSpin = false
            return
        end
        FCasinoCtx.commonPanel:StopScrollWinMoney(0, false)
        -- 清空本轮赢分
        self._winCoin = 0
        -- self.tips:HideTips()
        self:ChangeGameType(SlotType.Normal)
        self.slotContainers[SlotType.Normal]:SpinStart()
        self.slotContainers[SlotType.Normal]:StopAllScaleAnims()
        if not FCasinoCtx.isAutoSpin then
            -- 普通模式 且 手动, 播放背景音乐
            self:PlayNormalBgm()
        end
    elseif FCasinoCtx.curGameMode == FGameMode.FREE then
        self:ChangeGameType(SlotType.Free)
        FCasinoCtx.commonPanel:StopScrollWinMoney(nil, true)
        self.slotContainers[SlotType.Free]:SpinStart()
        self.slotContainers[SlotType.Free]:StopAllScaleAnims()
        self:ChangeBgm(MusicCfg.FREE_BG_MUSIC)
    elseif FCasinoCtx.curGameMode == FGameMode.SPECIAL then
        if self.curGameType == SlotType.FreeTopupBouns then
            self:ChangeGameType(SlotType.FreeTopupBouns)
        else
            self:ChangeGameType(SlotType.TopupBouns)
        end
        self.slotContainers[SlotType.TopupBouns]:SpinStart()
        -- self.slotContainers[SlotType.TopupBouns]:StopAllScaleAnims()
    end
    self:SendPackage()
    self.isInSpecial = true
end

function Game388:SendPackage()
    FCasinoCtx:SetSpinStatus(FSpinStatus.WAITING)
    if FCasinoCtx.curGameMode == FGameMode.NORMAL then
        print("SendPackage::FGameMode.NORMAL")
        self:SendNormalSpin(
            "PB.Client_Slots.NvXiaNormalSpin",
            "PB.Slots_Client.NvXiaNormalRet",
            function(ok, result)
                if not ok then
                    return
                end
                self.datas.normalPacket = result.normalSpin
                self:OnNormalSpinResult(result.normalSpin)
            end
        )
    elseif FCasinoCtx.curGameMode == FGameMode.FREE then
        print("SendPackage::FGameMode.FREE")
        local request = {
            _msgName_ = "PB.Client_Slots.NvXiaFreeSpin"
        }
        APIGateway.SendExactRequest(request,
            "PB.Slots_Client.NvXiaFreeRet",
            function(ok, result)
                if not ok then
                    return
                end
                -- dump(result,"FREE",4)
                self.datas.freeSpinPacket = result.freeSpin
                self:OnFreeSpinResult(result.freeSpin)
            end
        )
    elseif FCasinoCtx.curGameMode == FGameMode.SPECIAL then
        print("SendPackage::FGameMode.SPECIAL")
        local request = {
            _msgName_ = "PB.Client_Slots.NvXiaSpecialSpin"
        }
        APIGateway.SendExactRequest(
            request,
            "PB.Slots_Client.NvXiaSpecialRet",
            function(ok, result)
                if not ok then
                    return
                end
                self.datas.specialPacket = result.specialPacket
                -- dump(result,"SPECIAL",4)
                self:OnSpecialSpinResult(result.specialSpin)
            end
        )
    end
end

function Game388:OnClickStop()

    for _, v in pairs(self.slotContainers) do
        if v and v.StopPlaySoundScatterTimer then v:StopPlaySoundScatterTimer() end
    end

    if self.tweenLuodiScoreScroll then
        self.tweenLuodiScoreScroll:Kill(true)
        self.tweenLuodiScoreScroll = nil
    end

    if self.CoinFountainTimer then
        self.coinFountain:Stop()
        StopTimer(self.CoinFountainTimer)
        self.CoinFountainTimer = nil
    end
    if self.LuodiCollectTimer then
        self.coinFountain:Stop()
        StopTimer(self.LuodiCollectTimer)
        self.LuodiCollectTimer = nil
        if self.callAfterCollectScore then
            self.callAfterCollectScore()
            self.callAfterCollectScore = nil
        end
        self:ShowBottomWin(true, self._winCoin)
    end
    if self.soundWinCoinEffectHandle then
        APIGateway.StopSound(self.soundWinCoinEffectHandle)
        self.soundWinCoinEffectHandle = nil
    end
    if self.soundWinCoinEffectHandleTimer then
        StopTimer(self.soundWinCoinEffectHandleTimer)
        self.soundWinCoinEffectHandleTimer = nil
    end
    -- 还在播放彩金的话 直接显示彩金结果
    if self.playCaijinAnimTimer then
        StopTimer(self.playCaijinAnimTimer)
        self.playCaijinAnimTimer = nil
        if self.playCaijinAnimCallBack then
            self.playCaijinAnimCallBack()
            self.playCaijinAnimCallBack = nil
        end
        self:ShowBottomWin(true, self._winCoin)
        return
    end
    FCasinoCtx.commonPanel:StopScrollWinMoney(nil, true)
    -- 普通游戏状态点击停止按钮
    if FCasinoCtx.curGameMode == FGameMode.NORMAL then
        self.slotContainers[SlotType.Normal]:QuickStop()
    elseif FCasinoCtx.curGameMode == FGameMode.FREE then
        self.slotContainers[SlotType.Free]:QuickStop()
    elseif FCasinoCtx.curGameMode == FGameMode.SPECIAL  then
        self.slotContainers[SlotType.TopupBouns]:QuickStop()
    end
end

Game388._intoFreeGameCount = 0
function Game388:SetIntoFreeGameCount(count)
    Game388._intoFreeGameCount = count
end

function Game388:GetIntoFreeGameCount(count)
    return Game388._intoFreeGameCount
end

function Game388:ShowIntoFreeOrLuodiAni(cb)
    self.render:GetTransition("bigwin"):Play(function()
        if cb then cb() end
    end)
    FToolSet.PlayFGUISound(MusicCfg.FREE_AWARD_SYMBOL_ANI)
end


function Game388:SwitchAllSymbolsToLuodiMode()
    self.slotContainers[SlotType.TopupBouns]:SwitchAllSymbolsToLuodiMode()
end

Game388.enterFreeWinCoin = nil
Game388.enterLuodiWinCoin = nil
-- @brief 处理普通旋转结果
-- @param quickSet 直接设置跳过动画
function Game388:OnNormalSpinResult(spinData, quickSet, customCallback)
    self.isInSpecial = false
    local curSlotContainer = self.slotContainers[self.curGameType]
    self:ChangeGameType(SlotType.Normal)
    curSlotContainer:ResetState()
    self:setPlayGetFreeSymbolStrengthAudio(spinData.grids)
    if quickSet then
        curSlotContainer:SetOpen(true)
    end

    curSlotContainer:HandleWinDatas(spinData.lines)
    curSlotContainer:HandleCellDatas(spinData.grids)
    curSlotContainer:SetIsEnterFree(spinData.intoFree ~= 0)
    curSlotContainer:SetIsEnterTopupBouns(spinData.intoSpecial ~= 0)
    self:SetIntoLuodiSymbolCount(spinData.grids)
    self:SetIntoFreeGameCount(spinData.intoFree)


    local winCoin = spinData.winCoin
    print("Game388:OnNormalSpinResult:winCoin>>>>>>>>>>>>>>"..tostring(winCoin))
    if spinData.intoFree ~= 0 or spinData.intoSpecial ~= 0 then
        if spinData.intoFree ~= 0 then
            self.slotContainers[SlotType.Free]:ResetDatas(0, spinData.intoFree, winCoin)
            Game388.enterFreeWinCoin = winCoin
        elseif spinData.intoSpecial ~= 0 then
            for _,line in pairs(spinData.lines) do
                if line.lineIndex == 103 then winCoin = winCoin - line.winCoin end
            end 
            Game388.enterLuodiWinCoin = winCoin
            self.slotContainers[SlotType.TopupBouns]:ResetDatas(true, winCoin, spinData.intoSpecial, spinData.intoSpecial)
        end
    end


    local setReelSymbolData = function()
        self.slotContainers[SlotType.Normal]:SetReelSymbolData(
            function(second)
                -- 自定义回调函数
                if customCallback then
                    customCallback()
                    return
                end
                self.playCaijinAnimCallBack = function()
                    if spinData.intoFree ~= 0 then
                        self:ChangeBgm(MusicCfg.FREE_BG_MUSIC)
                        FCasinoCtx:SetGameMode(FGameMode.FREE)
                        self:ChangeGameType(SlotType.Free)
                        self:RefreshFreeGameCounter()
                        self.freeGameCounter.visible = true
                        FCasinoCtx:SetSpinStatus(FSpinStatus.SPIN)
                        self:DelayCallSpin(2, function()
                            self:StopNormalAction()
                        end)
                        return
                    elseif spinData.intoSpecial ~= 0 then
                        -- local winCoin = self.slotContainers[SlotType.Normal]:GetWinCoin()
                        self:ChangeGameType(SlotType.TopupBouns)
                        local luodiSlot = self.slotContainers[SlotType.TopupBouns]
                        luodiSlot:SetAllTurns(spinData.intoSpecial)
                        self:StopNormalAction()

                        luodiSlot:SetReelSymbolData(spinData.grids, function()
                            self:SetLuodiSlotFrameAndBGMByCount(luodiSlot:GetTopupBounsCount())
                            -- 进入落地牌弹窗
                            local callAfterBeginLuodiShowAni = function()
                                -- FToolSet.PlayFGUISound(MusicCfg.LUODI_BEGIN)
                                StartOnceTimer(function()
                                    self.render:GetTransition("luodi-begin-hide"):Play(function()
                                        self:SwitchAllSymbolsToLuodiMode()
                                        self:ChangeBgm(MusicCfg.LUODI_BG)
                                        self:RefreshFreeGameCounter()
                                        self.freeGameCounter.visible = true
                                        FCasinoCtx:SetSpinStatus(FSpinStatus.SPIN)
                                        -- 计时器自动旋转 落地牌
                                        self:DelayCallSpin(2)
                                    end)
                                end, 2)
                            end
                            FToolSet.PlayFGUISound(MusicCfg.LUODI_ADDITIONAL_TIME_IN)
                            self.luodiAddPanel:DisableQuesBtns()
                            self.render:GetTransition("luodi-begin-show"):Play(function()
                                callAfterBeginLuodiShowAni()
                            end)
                            -- FCasinoCtx:SetSpinStatus(FSpinStatus.WAITING)
                        end, true)
                        
                        FCasinoCtx:SetSpinStatus(FSpinStatus.WAITING)
                        return
                    else
                        FCasinoCtx:SetPlayerMoneyInfo(spinData)
                        FCasinoCtx:SyncPlayerMoneyDisplay(2)
                        if FCasinoCtx.isAutoSpin then
                            self:DelayCallSpin(2)
                        end
                        FCasinoCtx:SetSpinStatus(FSpinStatus.SPIN)
                    end
                end
                self.playCaijinAnimTimer = StartOnceTimer(function()
                    self.playCaijinAnimTimer = nil
                    if self.playCaijinAnimCallBack then
                        self.playCaijinAnimCallBack()
                    end
                    return
                end, second)
            end,
            quickSet
        )
    end

    if (spinData.intoFree ~= 0 or spinData.intoSpecial ~= 0) and not quickSet then
        -- 进免费或落地之前,显示一个前摇动画
        local shouldPlayIntoFreeOrLuodiAni = math.random() > 0.5
        if shouldPlayIntoFreeOrLuodiAni then
            self:ShowIntoFreeOrLuodiAni(function()
                setReelSymbolData()
            end)
            return
        end
    end
    setReelSymbolData()
end

Game388.isFreeInFree = false
-- @brief 处理免费游戏旋转结果
-- @param quickSet 直接设置跳过动画
function Game388:OnFreeSpinResult(spinData, quickSet, callback)
    self.isInSpecial = false
    self.isFreeInFree = false
    print("Game388:OnFreeSpinResult::winCoin>>>>>>>>>>>" .. tostring(spinData.winCoin))
    self:ChangeGameType(SlotType.Free)
    local curSlotContainer = self.slotContainers[SlotType.Free]
    curSlotContainer:ResetState()
    -- if quickSet then
    --     curSlotContainer:SetOpen(true)
    -- else
    self:setPlayGetFreeSymbolStrengthAudio(spinData.grids)
    if not quickSet then
        curSlotContainer:HandleWinDatas(spinData.lines)
    end
    curSlotContainer:SetIsEnterFree(false)
    curSlotContainer:SetIsEnterTopupBouns(spinData.intoSpecial ~= 0)
    if spinData.intoSpecial ~= 0 then 
        local winCoin = spinData.winCoin
        for _,line in pairs(spinData.lines) do
            if line.lineIndex == 103 then winCoin = winCoin - line.winCoin end
        end 
        Game388.enterLuodiWinCoin = winCoin
    end
    self:SetIntoLuodiSymbolCount(spinData.grids)

    -- end

    if spinData.addTime ~= nil and spinData.addTime ~= 0 then
        self:SetIntoFreeGameCount(spinData.addTime)
        Game388.enterFreeWinCoin = spinData.winCoin
        self.isFreeInFree = true
    end

    self:RefreshFreeGameCounter()
    self.freeGameCounter.visible = true
    curSlotContainer:HandleCellDatas(spinData.grids)
    
    curSlotContainer:SetReelSymbolData(
        function(second)
            if callback then
                callback()
                return
            end
            -- 免费结束
            curSlotContainer:SetAllTurns(spinData.allCount)
            local isEnd = spinData.totalCount >= spinData.allCount

            local callAfterFreeWinPanel = function()
                self:ChangeGameType(SlotType.Normal)
                self:StopCurBgm()

                StartOnceTimer(
                    function()
                        FCasinoCtx:SetSpinStatus(FSpinStatus.STOP)
                        self.playCaijinAnimCallBack = function()
                            if FCasinoCtx.isAutoSpin then
                                self:DelayCallSpin(2)
                            end
                            FCasinoCtx:SetSpinStatus(FSpinStatus.SPIN)
                            FCasinoCtx.commonPanel:StopScrollMoney(nil, true)
                        end

                        FCasinoCtx:SetPlayerMoneyInfo(spinData)
                        FCasinoCtx:SyncPlayerMoneyDisplay(0)

                        FCasinoCtx.commonPanel:SetWinMoney(0)
                        -- 免费总得分
                            -- 没落地时  bonusWinCoin
                            -- 有落地时  AllWinCoin
                        local freeAndLuodiWinCoin = 0
                        if spinData.AllWinCoin ~= nil then
                            freeAndLuodiWinCoin = spinData.bonusWinCoin > spinData.AllWinCoin and spinData.bonusWinCoin or spinData.AllWinCoin   
                        else
                            freeAndLuodiWinCoin = spinData.bonusWinCoin
                        end 
                        local audioData = self:GetAudioData(freeAndLuodiWinCoin)
                        local time = audioData and audioData.time or 2
                        local soundUrl = audioData.url
                
                        -- 播放收分音乐
                        if self.soundWinCoinEffectHandle then
                            APIGateway.StopSound(self.soundWinCoinEffectHandle)
                            self.soundWinCoinEffectHandle = nil
                        end

                        if self.soundWinCoinEffectHandleTimer then
                            StopTimer(self.soundWinCoinEffectHandleTimer)
                            self.soundWinCoinEffectHandleTimer = nil
                        end

                        if soundUrl then
                            self.soundWinCoinEffectHandle = FToolSet.PlayFGUISound(soundUrl)
                            self.soundWinCoinEffectHandleTimer = StartOnceTimer(function()
                                if self.soundWinCoinEffectHandle then
                                    APIGateway.StopSound(self.soundWinCoinEffectHandle)
                                    if self.render then
                                        self.soundWinCoinEffectHandle = nil
                                    end
                                end
                                -- FToolSet.PlayFGUISound(MusicCfg.FREE_AWARD_OUT)
                            end, time)
                        end
                        --

                        self.coinFountain:Play({{url = "ui://Game388/coin_382"}})
                        self.CoinFountainTimer = StartOnceTimer(function()
                            if self.render then
                                self.coinFountain:Stop()
                            end
                        end, time)

                        FCasinoCtx.commonPanel:ScrollWinMoneyTo(freeAndLuodiWinCoin, time, function()
                            if self.playCaijinAnimCallBack then
                                self.playCaijinAnimCallBack()
                                self.playCaijinAnimCallBack = nil
                            end
                        end)
                        
                    end
                , 0.01)
            end

            self.playCaijinAnimCallBack = function()
                if isEnd then
                    print("免费游戏全部结束")
                    -- 免费结束,没有进落地牌
                    if spinData.intoSpecial == 0 then

                        self.slotContainers[SlotType.Free]:ResetDatas()
                        
                        self:StopCurBgm()
                        FToolSet.PlayFGUISound(MusicCfg.FREE_END_MUSIC)
                        FTween.Start(self.render,
                            FTween.Delay(2, function()
                                self:StopNormalAction()
                                if self.CoinFountainTimer then
                                    self.coinFountain:Stop()
                                    StopTimer(self.CoinFountainTimer)
                                    self.CoinFountainTimer = nil
                                end
                                if self.soundWinCoinEffectHandle then
                                    APIGateway.StopSound(self.soundWinCoinEffectHandle)
                                    self.soundWinCoinEffectHandle = nil
                                end
                                FCasinoCtx.commonPanel:StopScrollWinMoney(self._winCoin)
                                -- FCasinoCtx.commonPanel:SetWinMoney(self._winCoin)
                                self.slotContainers[SlotType.Normal]:HandleCellDatas(self.datas.normalPacket.grids)
                                self.slotContainers[SlotType.Normal]:SetReelSymbolData(function()
                                    FCasinoCtx:SetSpinStatus(FSpinStatus.WAITING)
                                    -- 显示免费总赢分弹窗

                                    -- 免费总得分
                                    -- 没落地时  bonusWinCoin
                                    -- 有落地时  AllWinCoin

                                    local freeAndLuodiWinCoin = 0
                                    if spinData.AllWinCoin ~= nil then
                                        freeAndLuodiWinCoin = spinData.bonusWinCoin > spinData.AllWinCoin and spinData.bonusWinCoin or spinData.AllWinCoin   
                                    else
                                        freeAndLuodiWinCoin = spinData.bonusWinCoin
                                    end

                                    self:ShowFreeWinPanel(freeAndLuodiWinCoin, function()
                                        callAfterFreeWinPanel()
                                    end)
                                end, true)
                            end)
                        )
                    end
                    self:ChangeBgm()
                else
                    if spinData.intoSpecial == 0 then
                        FCasinoCtx:SetSpinStatus(FSpinStatus.SPIN)
                        self:DelayCallSpin(2)
                    end
                end
                if spinData.intoSpecial ~= 0 then
                    -- 免中落地牌
                    FCasinoCtx:SetSpinStatus(FSpinStatus.WAITING)
                    self:ChangeGameType(isEnd and SlotType.TopupBouns or SlotType.FreeTopupBouns)
                    self:StopFreeAction()
                    self.slotContainers[self.curGameType]:ResetDatas(
                        true,
                        self.slotContainers[SlotType.Free]:GetWinCoin(),
                        spinData.intoSpecial,
                        spinData.intoSpecial
                    )
                    self.slotContainers[self.curGameType]:SetReelSymbolData(
                        spinData.grids,
                        function()
                            self:SetLuodiSlotFrameAndBGMByCount(self.slotContainers[self.curGameType]:GetTopupBounsCount())

                            -- 进入落地牌弹窗
                            local callAfterBeginLuodiShowAni = function()
                                -- FToolSet.PlayFGUISound(MusicCfg.LUODI_BEGIN)
                                StartOnceTimer(function()
                                    self.render:GetTransition("luodi-begin-hide"):Play(function()
                                        self:SwitchAllSymbolsToLuodiMode()
                                        self:ChangeBgm(MusicCfg.LUODI_BG)
                                        self:RefreshFreeGameCounter()
                                        FCasinoCtx:SetSpinStatus(FSpinStatus.SPIN)
                                        -- 计时器自动旋转 落地牌
                                        self:DelayCallSpin(2)
                                    end)
                                end, 2)
                            end

                            FToolSet.PlayFGUISound(MusicCfg.LUODI_ADDITIONAL_TIME_IN)
                            self.render:GetTransition("luodi-begin-show"):Play(function()
                                callAfterBeginLuodiShowAni()
                            end)
                            
                            FCasinoCtx:SetSpinStatus(FSpinStatus.WAITING)
                        end,
                        true
                    )
                end
            end

            self.playCaijinAnimTimer = StartOnceTimer(
                function()
                    self.playCaijinAnimTimer = nil
                    if self.playCaijinAnimCallBack then
                        self.playCaijinAnimCallBack()
                    end
                    return
                end,
                second
            )
        end,
        quickSet
    )
end

function Game388:ShowFreeWinPanel(winCount, callback)
    local freeWinPanel = self.render:GetChild("freeWinPanel")
    local labelCount = freeWinPanel:GetChild("lable-count")
    local collectBtn = freeWinPanel:GetChild("collect-btn")

    APIGateway.RemoveEventListeners(collectBtn, FGUIEventKey.onClick)

    collectBtn:AddEventListener(FGUIEventKey.onClick,function()
        if self.timerFreeWin then 
            StopTimer(self.timerFreeWin) 
            self.timerFreeWin = nil
        end

        FToolSet.PlayFGUISound(MusicCfg.FREE_SETTLEMENT_OUT)
        freeWinPanel:GetTransition("hide"):Play(function()
            labelCount.visible = false
            freeWinPanel.visible = false
            if callback then callback() end
        end)
    end)

    labelCount.text = tostring(FToolSet.NumToStr(winCount))
    labelCount.visible = true
    local callAfterBeginShowAni = function()
        -- 显示弹窗中的免费次数
        self.timerFreeWin = StartOnceTimer(function()
            FToolSet.PlayFGUISound(MusicCfg.FREE_SETTLEMENT_OUT)
            freeWinPanel:GetTransition("hide"):Play(function()
                labelCount.visible = false
                freeWinPanel.visible = false
                if callback then callback() end
            end)
        end, 6)
    end

    FToolSet.PlayFGUISound(MusicCfg.FREE_SETTLEMENT_IN)
    freeWinPanel.visible = true
    -- 显示免费开始弹窗(弹窗内容为当前免费次数)
    freeWinPanel:GetTransition("start"):Play(function() callAfterBeginShowAni() end)
end

-- @brief 处理特殊游戏旋转结果
-- @param quickSet 直接设置跳过动画
function Game388:OnSpecialSpinResult(spinData, quickSet, customCallback)
    self.isInSpecial = false
    -- 使用落地牌模式的转轴来展示
    if self.curGameType == SlotType.FreeTopupBouns then
        self:ChangeGameType(SlotType.FreeTopupBouns)
    else
        self:ChangeGameType(SlotType.TopupBouns)
    end

    local remainCount = spinData.totalCount
    local allCount = spinData.allCount

    self.slotContainers[self.curGameType]:SetReelSymbolData(spinData.grids,
        function()
            self.isInSpecial = false
            -- 自定义回调函数
            if customCallback then
                customCallback()
                return
            end

            local callAfterCheckIsAddSpecialTime = function()
                self.slotContainers[self.curGameType]:SetAllTurns(allCount)
                self:RefreshFreeGameCounter()
                self.freeGameCounter.visible = true
                local topupBounsCount = self.slotContainers[self.curGameType]:GetTopupBounsCount()
                self:SetLuodiSlotFrameAndBGMByCount(topupBounsCount)
                local hasSpecialEnd = remainCount == 0 or topupBounsCount == 15


                local delayTime = 0.01
                if hasSpecialEnd then
                    local isFullLuodi = topupBounsCount == 15

                    function showFullLuodi()
                        FToolSet.PlayFGUISound(MusicCfg.LUODI_FULL)
                        hasSpecialEnd = true
                        
                        -- 382 grandWin 为双倍收分
                        self.fullLuodix2.visible = true
                        StartOnceTimer(function()
                            self.fullLuodix2.visible = false
                        end, 2)
                    end

                    -- check has grand jackpot
                    local hasGrand = false
                    local grandValue = 0
                    local topupBonusIndexs = self.slotContainers[self.curGameType].topupBonusIndexs
                    for _, v in pairs(topupBonusIndexs) do
                        if v.SymbolType == 5 then
                            hasGrand = true
                            grandValue = v.SymbolValue
                            break
                        end
                    end
                     
                    if isFullLuodi then
                        delayTime = delayTime + 2
                    end

                    if hasGrand then 
                        delayTime = delayTime + 2
                    end

                    if hasGrand then
                        self.bigGrand:GetChild("score-label").text = FToolSet.NumToStr(grandValue)
                        self.bigGrand.visible = true

                        StartOnceTimer(function()
                            self.bigGrand.visible = false
                            if isFullLuodi then showFullLuodi() end
                        end, 2)
                    else
                        if isFullLuodi then showFullLuodi() end
                    end
                end


                
                if not hasSpecialEnd then
                    FCasinoCtx:SetSpinStatus(FSpinStatus.SPIN)
                    self:DelayCallSpin(2)
                else
                    -- 落地牌游戏结束
                    FToolSet.PlayFGUISound(MusicCfg.FREE_END_MUSIC)
                    local tbIndexs = self.slotContainers[self.curGameType]:GetTopupBounsIndexs()
                    FCasinoCtx:SetSpinStatus(FSpinStatus.WAITING)
                    FTween.Start(
                        self.render,
                        FTween.Delay(
                            delayTime,
                            function()
                                FTween.KillTweens(self.render)
                                FToolSet.PlayFGUISound(MusicCfg.SND_Rumble)
                                -- self:ChangeBgm()
                                self:StopCurBgm()

                                -- 开始收分动画
                                FTween.KillTweens(self.render)                                        
                                self.luodiGameCollector.visible = true
                                local callAfterCollectScore = function()
                                    self:SetLuodiSlotFrameAndBGMByCount(0)

                                    local curTurn = self.slotContainers[SlotType.Free]:GetCurTurn()
                                    local allTurns = self.slotContainers[SlotType.Free]:GetAllTurns()
                                    if
                                        self.curGameType == SlotType.FreeTopupBouns and
                                        curTurn ~= allTurns
                                    then
                                        -- 免费落地,落地牌结束,继续免费游戏
                                        print("免费落地,落地牌结束,继续免费游戏")
                                        self.slotContainers[SlotType.Free]:ResetDatas(
                                            curTurn,
                                            allTurns,
                                            spinData.AllWinCoin
                                        )

                                        self:DelayCallSpin(2)
                                        self:ChangeBgm(MusicCfg.FREE_BG_MUSIC)
                                        self:StopFreeAction()
                                        self.slotContainers[SlotType.Free]:HandleCellDatas(
                                            self.datas.freeSpinPacket.grids
                                        )


                                        self.slotContainers[SlotType.Free]:SetOpen(true)
                                        self.slotContainers[SlotType.Free]:SetReelSymbolData(nil, true)
                                        self:ChangeGameType(SlotType.Free)
                                        self:RefreshFreeGameCounter()

                                        self.slotContainers[SlotType.TopupBouns]:SwitchAllSymbolsToNormalMode()
                                        FCasinoCtx:SetSpinStatus(FSpinStatus.SPIN)

                                    elseif
                                        -- self.curGameType == SlotType.FreeTopupBouns and
                                        curTurn ~= nil and curTurn ~= 0 and
                                        curTurn == allTurns
                                    then
                                        -- 免费结束
                                        self:StopCurBgm()
                                        FToolSet.PlayFGUISound(MusicCfg.FREE_END_MUSIC)
                                        FTween.Start(self.render,
                                            FTween.Delay(2, function()
                                                self:StopNormalAction()
                                                if self.CoinFountainTimer then
                                                    self.coinFountain:Stop()
                                                    StopTimer(self.CoinFountainTimer)
                                                    self.CoinFountainTimer = nil
                                                end
                                                if self.soundWinCoinEffectHandle then
                                                    APIGateway.StopSound(self.soundWinCoinEffectHandle)
                                                    self.soundWinCoinEffectHandle = nil
                                                end
                                                FCasinoCtx.commonPanel:StopScrollWinMoney(self._winCoin)
                                                -- FCasinoCtx.commonPanel:SetWinMoney(self._winCoin)
                                                self.slotContainers[SlotType.Normal]:HandleCellDatas(self.datas.normalPacket.grids)
                                                self.slotContainers[SlotType.Normal]:SetReelSymbolData(function()
                                                    FCasinoCtx:SetSpinStatus(FSpinStatus.WAITING)
                                                    -- 显示免费总赢分弹窗

                                                    local freeAndLuodiWinCoin = 0
                                                    if spinData.AllWinCoin ~= nil then
                                                        freeAndLuodiWinCoin = spinData.bonusWinCoin > spinData.AllWinCoin and spinData.bonusWinCoin or spinData.AllWinCoin   
                                                    else
                                                        freeAndLuodiWinCoin = spinData.bonusWinCoin
                                                    end 

                                                    self:ShowFreeWinPanel(freeAndLuodiWinCoin, function()
                                                        self:ChangeGameType(SlotType.Normal)
                                                        self:StopCurBgm()
                                        
                                                        StartOnceTimer(
                                                            function()
                                                                FCasinoCtx:SetSpinStatus(FSpinStatus.STOP)
                                                                self.playCaijinAnimCallBack = function()
                                                                    if FCasinoCtx.isAutoSpin then
                                                                        self:DelayCallSpin(2)
                                                                    end
                                                                    FCasinoCtx:SetSpinStatus(FSpinStatus.SPIN)
                                                                    FCasinoCtx.commonPanel:StopScrollMoney(nil, true)
                                                                end
                                        
                                                                FCasinoCtx:SetPlayerMoneyInfo(spinData)
                                                                FCasinoCtx:SyncPlayerMoneyDisplay(0)

                                                                FCasinoCtx.commonPanel:SetWinMoney(0)

                                                                local audioData = self:GetAudioData(freeAndLuodiWinCoin)
                                                                local time = audioData and audioData.time or 2

                                                                self.coinFountain:Play({{url = "ui://Game388/coin_382"}})
                                                                self.CoinFountainTimer = StartOnceTimer(function()
                                                                    if self.render then
                                                                        self.coinFountain:Stop()
                                                                    end
                                                                end, time)

                                                                FCasinoCtx.commonPanel:ScrollWinMoneyTo(freeAndLuodiWinCoin, time, function()
                                                                    if self.playCaijinAnimCallBack then
                                                                        self.playCaijinAnimCallBack()
                                                                        self.playCaijinAnimCallBack = nil
                                                                    end
                                                                end)
                                        
                                                            end
                                                        , 0.01)
                                                    end)
                                                end, true)
                                            end)
                                        )
                                    else
                                        -- 普通中落地,落地结束
                                        print("普通中落地,落地结束")
                                        self:StopCurBgm()
                                        -- FToolSet.PlayFGUISound(MusicCfg.FREE_END_MUSIC)
                                        FCasinoCtx:SetPlayerMoneyInfo(spinData)
                                        FCasinoCtx:SyncPlayerMoneyDisplay(2)
                                        if FCasinoCtx.isAutoSpin then
                                            self:DelayCallSpin(2)
                                        end
                                        self:StopNormalAction()
                                        self.slotContainers[SlotType.Normal]:SetOpen(true)
                                        self.slotContainers[SlotType.Normal]:HandleCellDatas(
                                            self.datas.normalPacket.grids
                                        )
                                        self.slotContainers[SlotType.Normal]:SetReelSymbolData(
                                            nil,
                                            true
                                        )
                                        self:ChangeGameType(SlotType.Normal)

                                        self.slotContainers[SlotType.TopupBouns]:SwitchAllSymbolsToNormalMode()
                                        FCasinoCtx:SetSpinStatus(FSpinStatus.SPIN)
                                    end
                                    self.slotContainers[SlotType.TopupBouns]:ResetTopupBounsCurCount()
                                    -- 收分动画
                                    self.luodiGameCollector.visible = false
                                    -- FCasinoCtx:SetSpinStatus(FSpinStatus.SPIN)
                                end

                                -- local winCoinToShow = spinData.AllWinCoin + (self.enterLuodiWinCoin or 0)
                                local winCoinToShow = spinData.AllWinCoin
                                local showWinCoinTime = self:ShowBottomWin(quickSet, winCoinToShow)

                                -- local luodiWinScore = spinData.bonusWinCoin - (Game388.enterLuodiWinCoin or 0)

                                local luodiWinScore
                                if RUNTIME_USE_H5_PROTO then
                                    local curTurn = self.slotContainers[SlotType.Free]:GetCurTurn()
                                    local allTurns = self.slotContainers[SlotType.Free]:GetAllTurns()
                                    if
                                        self.curGameType == SlotType.FreeTopupBouns and
                                        curTurn ~= allTurns
                                    then
                                        -- 免费落地,落地牌结束
                                        luodiWinScore = spinData.bonusWinCoin
                                    elseif
                                        curTurn ~= nil and curTurn ~= 0 and
                                        curTurn == allTurns
                                    then
                                        -- 免费结束
                                        luodiWinScore = spinData.bonusWinCoin
                                    else
                                        -- 普通中落地,落地结束
                                        luodiWinScore = spinData.bonusWinCoin - (Game388.enterLuodiWinCoin or 0)
                                    end
                                else
                                    luodiWinScore = spinData.bonusWinCoin - (Game388.enterLuodiWinCoin or 0)
                                end

                                self.soundLuodiScoreScrollHandler = FToolSet.PlayFGUISound(MusicCfg.LUODI_SCORE_SCROLL)
                                self.tweenLuodiScoreScroll = FairyGUI.GTween.ToDouble(0, luodiWinScore, showWinCoinTime)
                                :OnUpdate(function(tweener)
                                    self.luodiGameCollector:GetChild("label-score").text = FToolSet.NumToStr(tweener.value.d)
                                end)
                                :OnComplete(function()
                                    if self.soundLuodiScoreScrollHandler then 
                                        APIGateway.StopSound(self.soundLuodiScoreScrollHandler)
                                        self.soundLuodiScoreScrollHandler = nil
                                    end

                                    self.tweenLuodiScoreScroll = nil
                                    if callAfterCollectScore then 
                                        callAfterCollectScore()
                                        callAfterCollectScore = nil
                                    end
                                end)

                                FCasinoCtx:SetSpinStatus(FSpinStatus.STOP)
                            end
                        )
                    )
                    return
                end
            end

            -- 是否增加落地牌次数
            local specialAddTime = spinData.addTime
            if specialAddTime ~= 0 then
                self.luodiAddPanel:ResetView()
                FToolSet.PlayFGUISound(MusicCfg.LUODI_ADDITIONAL_TIME_IN)
                self.render:GetTransition("luodi-add-show"):Play(function()
                    self.luodiAddPanel:SetData(
                        specialAddTime, 
                        function()
                            if self.luodiAddAutoSelectTimer ~= nil then
                                StopTimer(self.luodiAddAutoSelectTimer)
                                self.luodiAddAutoSelectTimer = nil
                            end
                            -- 停留2秒,隐藏落地添加次数弹窗
                            StartOnceTimer(function()
                                FToolSet.PlayFGUISound(MusicCfg.LUODI_ADDITIONAL_TIME_IN)
                                self.render:GetTransition("luodi-add-hide"):Play(function()
                                    StartOnceTimer(function()
                                        callAfterCheckIsAddSpecialTime()
                                    end,1)
                                end)
                            end,2)
                        end,
                        self.intoLuodiSymbolCount
                    )

                    self.luodiAddAutoSelectTimer = StartOnceTimer(function()
                        self.luodiAddPanel:ShowRandomRes()
                        self.luodiAddAutoSelectTimer = nil
                    end, 10)
                end)
                FCasinoCtx:SetSpinStatus(FSpinStatus.WAITING)
            else
                StartOnceTimer(function()
                    callAfterCheckIsAddSpecialTime()
                end,1)
            end
        end
        , quickSet
    )
end

-- 自动旋转 --自动旋转时间取消 delay 作废
function Game388:DelayCallSpin(delay, cb)
    self:StopDelayCallSpin()
    local interval = FConfig.Common.AutoSpinInterval[FCasinoCtx.curGameMode]
    self.callSpinTimer = StartOnceTimer(
        function()
            if cb then
                cb()
            end
            FCasinoCtx:SimulateSpinClick()
        end,
        interval
    )
end

function Game388:StopDelayCallSpin()
    if self.callSpinTimer then
        StopTimer(self.callSpinTimer)
        self.callSpinTimer = nil
    end
end

function Game388:RefreshFreeGameCounter()
    local labelCount = self.freeGameCounter:GetChild("label-count")
    local labelTotal = self.freeGameCounter:GetChild("label-total")

    if self.curGameType == SlotType.Free then
        labelCount.text = tostring(self.slotContainers[SlotType.Free]:GetCurTurn())
        labelTotal.text = tostring(self.slotContainers[SlotType.Free]:GetAllTurns())
    elseif self.curGameType == SlotType.TopupBouns or self.curGameType == SlotType.FreeTopupBouns then
        labelCount.text = tostring(self.slotContainers[SlotType.TopupBouns]:GetCurTurn())
        labelTotal.text = tostring(self.slotContainers[SlotType.TopupBouns]:GetAllTurns())
    end
end

function Game388:HideFreeGameCounter()
    self.freeGameCounter.visible = false
end

-- 转换游戏类型
function Game388:ChangeGameType(slotType)
    if self.curGameType == slotType then
        return
    end
    if self.slotContainers[self.curGameType] then
        self.slotContainers[self.curGameType]:SetVisible(false)
    end
    self.curGameType = slotType
    if slotType == SlotType.Normal then
        self:HideFreeGameCounter()
        FCasinoCtx:SetGameMode(FGameMode.NORMAL)
    elseif slotType == SlotType.Free then
        FCasinoCtx:SetGameMode(FGameMode.FREE)
        self.slotContainers[SlotType.Free]:ShowAllSymbolDisplays()
    elseif slotType == SlotType.TopupBouns then
        FCasinoCtx:SetGameMode(FGameMode.SPECIAL)
    elseif slotType == SlotType.FreeTopupBouns then
        FCasinoCtx:SetGameMode(FGameMode.SPECIAL)
    end
    self.slotContainers[self.curGameType]:SetVisible(true)
end

-- 停止普通游戏的动画和中奖线
function Game388:StopNormalAction()
    self.slotContainers[SlotType.Normal]:RemoveTopSymbol()
    -- self:StopLines()
end

-- 停止免费游戏的动画和中奖线
function Game388:StopFreeAction()
    self.slotContainers[SlotType.Free]:RemoveTopSymbol()
    -- self:StopLines()
end

-- 落地牌拥有数量
function Game388:SetLuodiSlotFrameAndBGMByCount(count)
    if count == 0 then
        self.slot:GetController("c1").selectedPage = "normal"
        return
    end
    self:ChangeBgm(MusicCfg.LUODI_BG)
    self.slot:GetController("c1").selectedPage = "luodi"
end


function Game388:GetAudioData(winMoney)
    if winMoney == 0 then
        return nil
    end
    local ratio = winMoney / FCasinoCtx.commonPanel:GetBetMoney()

    local len = #MusicCfg.AudioData
    for i = 1, len - 1 do
        local curCfg  = MusicCfg.AudioData[i]
        local nextCfg = MusicCfg.AudioData[i + 1]
        if ratio >= curCfg.ratio and ratio < nextCfg.ratio then
            return curCfg
        end
    end

    return MusicCfg.AudioData[len]
end


function Game388:ShowBottomWin(quickSet, winCoin)
    local winCoin = winCoin or self.slotContainers[self.curGameType]:GetWinCoin()
    -- print("Game388:ShowBottomWin>>>>>>>>>> showWinCoin>>>>>>" .. tostring(winCoin))
    local second = 0.01
    if not quickSet then
        local lastWinCoin = self._winCoin
        local addCoin = winCoin - lastWinCoin
        local audioData = self:GetAudioData(addCoin)
        if audioData then
            -- 播放收分音乐
            if self.soundWinCoinEffectHandle then
                APIGateway.StopSound(self.soundWinCoinEffectHandle)
                self.soundWinCoinEffectHandle = nil
            end
    
            if self.soundWinCoinEffectHandleTimer then
                StopTimer(self.soundWinCoinEffectHandleTimer)
                self.soundWinCoinEffectHandleTimer = nil
            end
            if self.curGameType == SlotType.Free then
                -- self.soundWinCoinEffectHandle = FToolSet.PlayFGUISound(MusicCfg.FREE_AWARD)
                self.soundWinCoinEffectHandle = FToolSet.PlayFGUISound(audioData.url)
                if audioData ~= nil then second = audioData.time end
                self.soundWinCoinEffectHandleTimer = StartOnceTimer(function()
                    if self.soundWinCoinEffectHandle then
                        APIGateway.StopSound(self.soundWinCoinEffectHandle)
                        if self.render then
                            self.soundWinCoinEffectHandle = nil
                        end
                    end
                    FToolSet.PlayFGUISound(MusicCfg.FREE_AWARD_OUT)
                end, second)
            else
                if audioData then
                    self.soundWinCoinEffectHandle = FToolSet.PlayFGUISound(audioData.url)
                    second = audioData.time
                    self.soundWinCoinEffectHandleTimer = StartOnceTimer(function()
                        if self.render then
                            self.soundWinCoinEffectHandle = nil
                        end
                    end, second)
                end
            end
    
            if audioData ~= nil and audioData.isOpenFire then
                -- 较大价值奖励抛金币
                self.coinFountain:Play({{url = "ui://Game388/coin_382"}})
                self.CoinFountainTimer = StartOnceTimer(function()
                    if self.render then
                        self.coinFountain:Stop()
                    end
                end, second)
            end
        end
    end
    -- 结算金币
    if winCoin > 0 then
        -- print("winCoin:", winCoin)
        FCasinoCtx.commonPanel:ScrollWinMoneyTo(winCoin, second)
        -- print("ScrollWinMoneyTo::second>>>>>>>>>>>>>"..tostring(second))
        self._winCoin = winCoin
    end
    return second
end

function Game388:ChangeBgm(url)
    if self.soundBgm == url then
        return
    end
    self:StopCurBgm()
    if not url then
        return
    end
    FToolSet.PlayBGM(url)
    self.soundBgm = url
end

function Game388:PlayNormalBgm()
    --[[ local url = MusicCfg.MAIN_MUSIC
    if self.soundBgm == url then
        APIGateway.SetSoundVolume(self.soundBgmHandle,1)
        return
    end
    self:StopCurBgm()
    self.soundBgmHandle = FToolSet.PlayBGM(url)
    self.soundBgm = url ]]
end

function Game388:StopCurBgm()
    APIGateway.StopBGM()
    self.soundBgm = nil
end

-- 设置播放中免费强调音效
function Game388:setPlayGetFreeSymbolStrengthAudio(grids)
    self.reelerIdxsShouldPlayScatterAudio = {}
    -- 播放中免费音效
    -- 查找连续scatter
    local getScatterColumnDic = function(grids)
        local res = {}
        for i = 1, #grids do
            local icon = grids[i].icon
            local column = i % 5
            if column == 0 then 
                column = 5
            end
            if not res[column] then res[column] = 0 end
            if icon == 3 then
                res[column] = res[column] + 1
            end
        end
        return res
    end
    local scatterColumnDic = getScatterColumnDic(grids)
    if scatterColumnDic[1] ~= 0 then
        for reelerIdx, scatterCount in pairs(scatterColumnDic) do
            if scatterCount ~= 0 then
                table.insert(self.reelerIdxsShouldPlayScatterAudio, reelerIdx)
            elseif #self.reelerIdxsShouldPlayScatterAudio ~= 0 then
                break
            end
        end
    end
    -- dump(self.reelerIdxsShouldPlayScatterAudio,"self.reelerIdxsShouldPlayScatterAudio>>>>>>>>>>>")
end

return Game388
