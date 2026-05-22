
local NormalSlot        = Import(".Slot.NormalSlot")
local TopupBounsSlot        = Import(".Slot.TopupBounsSlot")
local FreeSlot        = Import(".Slot.FreeSlot")
local TopupBonusAnim    = Import(".Slot.TopupBonusAnim")
local TopupBounsFlyDragon    = Import(".Slot.TopupBounsFlyDragon")
local Tips              = Import(".Slot.Tips")
local CaijinPanel              = Import(".CaijinPanel")
local MusicCfg = Import(".Slot.MusicCfg")
local WinLineConfigs = Import(".Cfgs.WinLineConfigs")
local WinLines = require("FGame.Common.Logic.General.WinLines") -- 引用
local Utils = Import(".Slot.Utils")

local CoinFountain = require("FGame.Common.Logic.Effect.CoinFountain")
local SlotType = {
    Normal      = 1,    -- 普通类型
    Free        = 2,    -- 免费游戏
    TopupBouns  = 3,    -- 落地牌类型
    FreeTopupBouns  = 4,    -- 免中落地牌类型
}

local Game475 = Class("Game475", BaseGame)

function Game475:ctor(render)
    self.render = render
    local slot = self.render:GetChild("Slot").component
    self.curGameType = 0
    self.slotContainers = {}
    self.slotContainers[SlotType.Normal] = NormalSlot.New(slot:GetChild("ReelContainer"),self)
    self.slotContainers[SlotType.Normal]:SetVisible(false)
    self.slotContainers[SlotType.TopupBouns] = TopupBounsSlot.New(slot:GetChild("ReelContainer"),self)
    self.slotContainers[SlotType.TopupBouns]:SetVisible(false)
    self.slotContainers[SlotType.FreeTopupBouns] = self.slotContainers[SlotType.TopupBouns] --3 4 共用

    self.slotContainers[SlotType.Free] = FreeSlot.New(slot:GetChild("ReelContainer"),self)
    self.slotContainers[SlotType.Free]:SetVisible(false)
    self:ChangeGameType(SlotType.Normal)

    self.caijinPanel = CaijinPanel.New(self.render:GetChild("CaijinPanel").component)
    -- 中线连线
    self.winLines = WinLines.New(slot:GetChild("WinLines"),WinLineConfigs.Lines)
    -- 落地牌动画节点
    self.topupBonusAnim = TopupBonusAnim.New(self.render:GetChild("TopupBonusAnim"))
    -- 落地牌飞龙的动画
    self.topupBounsFlyDragon = TopupBounsFlyDragon.New(self.render:GetChild("TopupBounsFlyDragon"), self.render:GetChild("CaijinPanel").component)
    
    -- 特殊游戏中间提示文字
    self.tips = Tips.New(self.render:GetChild("Tips"))

    self.box5x3 = slot:GetChild("n18")
    self.box5x3.visible = false
    self.count = slot:GetChild("count")
    self.count.visible = false

    self.datas = {
        normalPacket = nil, -- 普通旋转结果
        freeSpinPacket = nil , -- 免费旋转结果
        specialPacket = nil, -- 特殊旋转结果
    }

    self.soundBgm = nil

    self.coinFountain = CoinFountain.New()
    self.coinFountain:SetSortingOrder(10)

    self._winCoin = 0

    -- 落地牌巨奖提示
    self.bigGrand = self.render:GetChild("grand")
    self.bigGrand.visible = false
end

function Game475:__delete()
    FTween.KillTweens(self.winLines.parent)
    self:StopDelayCallSpin()
    for i = 1, 3 do -- 3  4 共用
        self.slotContainers[i]:Delete()
    end
    self.winLines:Delete()
    self.tips:Delete()
    self.topupBonusAnim:Delete()
    self.topupBounsFlyDragon:Delete()
    self.caijinPanel:Delete()

    if self.CoinFountainTimer then
        StopTimer(self.CoinFountainTimer)
        self.CoinFountainTimer = nil
    end
    if self.soundWinCoinEffectHandle then
        APIGateway.StopSound(self.soundWinCoinEffectHandle)
        self.soundWinCoinEffectHandle = nil
    end
    if self.soundWinCoinEffectHandleTimer then
        StopTimer(self.soundWinCoinEffectHandleTimer)
        self.soundWinCoinEffectHandleTimer = nil
    end

    self.soundBgm = nil
    FToolSet.StopBGM()
    self.coinFountain:Delete()

    if self.playCaijinAnimTimer then
        StopTimer(self.playCaijinAnimTimer)
        self.playCaijinAnimTimer = nil
        self.playCaijinAnimCallBack = nil
    end
    FTween.KillTweens(self.render)
    if self.delaySpin then
        StopTimer(self.delaySpin)
        self.delaySpin = nil
    end
    self.render = nil
end

-- @interface
-- @brief update
function Game475:Update(dt)
    Game475.super.Update(self, dt)
    for i = 1, 3 do -- 3  4 共用
        self.slotContainers[i]:Update(dt)
    end
end

-- @interface
-- @brief 在游戏中断线重连恢复游戏
-- @param local  断线重连数据
function Game475:ReconnectRecoveryGame(data, isInitialize)
    -- dump(data,"ReconnectRecoveryGame",5)
    -- print("isInitialize: ",isInitialize)
    -- print("断线重连 self.curGameType: ",self.curGameType)
    -- print("断线重连 self.isSpined: ",self.isSpined)
    --type 1普通 2免费 3特殊 4免费中特殊
    if data.type == 1 then
        local resumedNormal = data.resumedNormal
        local normalSpin = resumedNormal.normalSpin

        local bonusWin = data.currentWinCoin
        if normalSpin.intoSpecial == 1 then
            for _, cell in ipairs(resumedNormal.normalSpin.grids) do
                bonusWin = bonusWin - cell.SymbolValue
            end
        end
        print("bonusWin:",bonusWin)
        if bonusWin > 0 then
            self:ShowBottomWin(true,bonusWin)
        end
        print("断线重连 - 处理接收普通包")
        if not self:CheckSlotData(normalSpin.grids, SlotType.Normal) then -- 不一样
            self.datas.normalPacket = normalSpin
            if self.curGameType ~= 1 and self.isSpined then -- 已经在特殊游戏了
                self:SendPackage()
                return
            end
            if isInitialize or self.isSpined then
                self:OnNormalSpinResult(normalSpin,true)
            end
        else
            if self.isSpined then -- 已经在特殊游戏了
                self:SendPackage()
                return
            end
        end
        return
    elseif data.type == 2 then
        local resumedNormal = data.resumedNormal
        local resumedFree = data.resumedFree
        print("断线重连 - 处理接收免费")
        if not self:CheckSlotData(resumedFree.freeSpin.grids, SlotType.Free) then -- 不一样
            self.datas.normalPacket = resumedNormal.normalSpin
            self.datas.freeSpinPacket = resumedFree.freeSpin
            if resumedFree.freeSpin.intoSpecial == 0 and self.datas.freeSpinPacket.allCount <= self.datas.freeSpinPacket.totalCount then
                --没次数了
                self:OnNormalSpinResult(resumedNormal.normalSpin, true,function ()end)
                return

            end
            self:ChangeBgm(MusicCfg.SND_Fea_BGM)
            local bonusWin = data.currentWinCoin
            if resumedFree.freeSpin.intoSpecial == 1 then
                for _, cell in ipairs(resumedFree.freeSpin.grids) do
                    bonusWin = bonusWin - cell.SymbolValue
                end
            end
            self.slotContainers[SlotType.Free]:ResetDatas(self.datas.freeSpinPacket.totalCount,self.datas.freeSpinPacket.allCount,bonusWin)
            self:ShowBottomWin(true,bonusWin)
            if self.curGameType ~= 2 and self.isSpined then
                self:SendPackage()
                return
            end
            self:SetMidTips("freecount",self.datas.freeSpinPacket.totalCount,self.datas.freeSpinPacket.allCount)
            self:OnFreeSpinResult(self.datas.freeSpinPacket, true)
        else
            if self.isSpined then 
                self:SendPackage()
                return
            end
        end
        return
    elseif data.type == 3 then
        local resumedNormal = data.resumedNormal
        local resumedSpecial = data.resumedSpecial
        print("断线重连 - 处理接收落地牌")
        if not self:CheckSlotData(resumedSpecial.specialSpin.grids, SlotType.TopupBouns) then -- 不一样
            self.datas.normalPacket = resumedNormal.normalSpin
            self.datas.specialPacket = resumedSpecial.specialSpin
            --没次数了
            if self.datas.specialPacket.totalCount == 0 then
                if self.curGameType ~= 3 and self.isSpined then -- 已经在普通游戏了
                    self:SendPackage()
                    return
                end
                if isInitialize or self.isSpined then -- 杀进程直接显示
                    self:OnNormalSpinResult(resumedNormal.normalSpin, true,function ()end)
                end
                return
            end

            local bonusWin = data.currentWinCoin
            for _, cell in ipairs(resumedSpecial.specialSpin.grids) do
                bonusWin = bonusWin - cell.SymbolValue
            end
            self.slotContainers[SlotType.TopupBouns]:ResetDatas(false,self.datas.specialPacket.totalCount,bonusWin)
            self:OnSpecialSpinResult(self.datas.specialPacket, true)
            self:SetTopupBounsCount(self.slotContainers[self.curGameType]:GetTopupBounsCount())
            self:ShowBottomWin(true)
        else
            if self.isSpined then 
                self:SendPackage()
            end
        end
        return
    elseif data.type == 4 then
        local resumedNormal = data.resumedNormal
        local resumedSpecial = data.resumedSpecial
        local resumedFree = data.resumedFree
        
        if resumedSpecial.specialSpin.totalCount == 0 then -- 看看免费包
            print("断线重连 - 处理接收免中落地牌 免费")
            if not self:CheckSlotData(resumedFree.freeSpin.grids, SlotType.Free) then -- 不一样
                self.datas.normalPacket = resumedNormal.normalSpin
                self.datas.freeSpinPacket = resumedFree.freeSpin
                -- dump(self.datas.freeSpinPacket,"断线重连数据")
                if self.datas.freeSpinPacket.allCount <= self.datas.freeSpinPacket.totalCount then
                    --没次数了
                    if self.curGameType ~= 4 and self.isSpined then
                        self:ChangeGameType(SlotType.Normal)
                        self:SendPackage()
                    end
                    if isInitialize or self.isSpined then -- 杀进程直接显示
                        self:OnNormalSpinResult(resumedNormal.normalSpin, true,function ()end)
                    end
                    return
                end
                self:ChangeBgm(MusicCfg.SND_Fea_BGM)
                -- FToolSet.PlayFGUISound(MusicCfg.SND_Fea_BGM,true)
                self.slotContainers[SlotType.Free]:ResetDatas(self.datas.freeSpinPacket.totalCount,self.datas.freeSpinPacket.allCount,data.currentWinCoin)
                if isInitialize then -- 杀进程直接显示
                    self:OnFreeSpinResult(resumedFree.freeSpin, true,function ()
                        self:DelayCallSpin(2)
                        self:ShowBottomWin(true)
                    end)
                end
                self:SetMidTips("freecount",self.datas.freeSpinPacket.totalCount,self.datas.freeSpinPacket.allCount)
            else
                if self.isSpined then
                    self:ChangeGameType(SlotType.Free)
                    self:SendPackage()
                end
            end
        else
            print("断线重连 - 处理接收免中落地牌")
            if not self:CheckSlotData(resumedSpecial.specialSpin.grids, SlotType.FreeTopupBouns) then -- 不一样
                self.datas.normalPacket = resumedNormal.normalSpin
                self.datas.specialPacket = resumedSpecial.specialSpin
                self.datas.freeSpinPacket = resumedFree.freeSpin
                -- dump(self.datas.specialPacket,"断线重连数据")
                self:ChangeGameType(SlotType.FreeTopupBouns)
                local bonusWin = data.currentWinCoin
                for _, cell in ipairs(resumedSpecial.specialSpin.grids) do
                    bonusWin = bonusWin - cell.SymbolValue
                end
                self.slotContainers[SlotType.FreeTopupBouns]:ResetDatas(false,self.datas.specialPacket.totalCount,bonusWin)
                self.slotContainers[SlotType.Free]:ResetDatas(self.datas.freeSpinPacket.totalCount,self.datas.freeSpinPacket.allCount)
                if isInitialize or self.isSpined then -- 杀进程直接显示
                    self:OnSpecialSpinResult(self.datas.specialPacket, true)
                end
                self:SetTopupBounsCount(self.slotContainers[self.curGameType]:GetTopupBounsCount())
                self:ShowBottomWin(true)
            else
                if self.isSpined then
                    self:SendPackage()
                end
            end
        end
        return
    end
end


-- 检查普通包跟当前包是否一样
function Game475:CheckSlotData(grids, type)
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
        print("error: CheckSlotData type:",type)
        return
    end
    
    for i = 1, #grids do
        local icon = grids[i].icon
        local bonusType = grids[i].SymbolType
        local bonusValue = grids[i].SymbolValue
        local IsHide = grids[i].IsHide

        local lastIcon = localGrids[i].icon
        local lastbonusType = grids[i].SymbolType
        local lastbonusValue = grids[i].SymbolValue
        local lastIsHide = grids[i].IsHide

        if icon ~= lastIcon or
         bonusType ~= lastbonusType or
         bonusValue ~= lastbonusValue or
         IsHide ~= lastIsHide then
            return false
        end
    end
    return true
end


-- @interface
-- @brief 点击开始按钮
function Game475:OnClickSpin()
    self:StopDelayCallSpin()
    if self.CoinFountainTimer then
        self.coinFountain:Stop()
        StopTimer(self.CoinFountainTimer)
        self.CoinFountainTimer = nil
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
        self.tips:HideTips()
        self:ChangeGameType(SlotType.Normal)
        self.slotContainers[SlotType.Normal]:SpinStart()
    elseif FCasinoCtx.curGameMode == FGameMode.FREE then
        self:ChangeGameType(SlotType.Free)
        self.slotContainers[SlotType.Free]:SpinStart()
        self:ChangeBgm(MusicCfg.SND_Fea_BGM)
    elseif FCasinoCtx.curGameMode == FGameMode.SPECIAL then
        FToolSet.PlayFGUISound(MusicCfg.Luodi_start_spin)
        if self.curGameType == SlotType.FreeTopupBouns then
            self:ChangeGameType(SlotType.FreeTopupBouns)
        else
            self:ChangeGameType(SlotType.TopupBouns)
        end
        self.slotContainers[SlotType.TopupBouns]:SpinStart()
    end
    self:SendPackage()
    self.isSpined = true
end

function Game475:SendPackage()
    FCasinoCtx:SetSpinStatus(FSpinStatus.WAITING)
    if FCasinoCtx.curGameMode == FGameMode.NORMAL then
        self:SendNormalSpin("PB.Client_Slots.EyesOfWealthNormalSpin", "PB.Slots_Client.EyesOfWealthNormalRet",
            function(ok, result)
                if not ok then return end
                -- dump(result,"NORMAL",4)
                self.datas.normalPacket = result.normalSpin
                self:OnNormalSpinResult(result.normalSpin)
            end
        )
    elseif FCasinoCtx.curGameMode == FGameMode.FREE then
        local request = {
            _msgName_ = "PB.Client_Slots.EyesOfWealthFreeSpin"
        }
        APIGateway.SendExactRequest(request, "PB.Slots_Client.EyesOfWealthFreeRet",
            function(ok, result)
                if not ok then return end
                -- dump(result,"FREE",4)
                self.datas.freeSpinPacket = result.freeSpin
                self:OnFreeSpinResult(result.freeSpin)
            end
        )
    elseif FCasinoCtx.curGameMode == FGameMode.SPECIAL then
        local request = {
            _msgName_ = "PB.Client_Slots.EyesOfWealthSpecialSpin"
        }
        APIGateway.SendExactRequest(request, "PB.Slots_Client.EyesOfWealthSpecialRet",
            function(ok, result)
                if not ok then return end
                self.datas.specialPacket = result.specialPacket
                -- dump(result,"SPECIAL",4)
                self:OnSpecialSpinResult(result.specialSpin)
            end
        )
    end
end


function Game475:OnClickStop()
    if self.CoinFountainTimer then
        self.coinFountain:Stop()
        StopTimer(self.CoinFountainTimer)
        self.CoinFountainTimer = nil
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
        self:ShowBottomWin(true,self._winCoin)
        return
    end
    -- 普通游戏状态点击停止按钮
    if FCasinoCtx.curGameMode == FGameMode.NORMAL then
        self.slotContainers[SlotType.Normal]:QuickStop()
    elseif FCasinoCtx.curGameMode == FGameMode.FREE then
        self.slotContainers[SlotType.Free]:QuickStop()
    elseif FCasinoCtx.curGameMode == FGameMode.SPECIAL then
        self.slotContainers[SlotType.TopupBouns]:QuickStop()
        -- self.slotContainers[SlotType.FreeTopupBouns]:QuickStop()
    end
end

-- @brief 处理普通旋转结果
-- @param quickSet 直接设置跳过动画
function Game475:OnNormalSpinResult(spinData, quickSet, customCallback)
    self.isSpined = false
    self:ChangeGameType(SlotType.Normal)
    self.slotContainers[self.curGameType]:ResetState()
    self:setPlayGetFreeSymbolStrengthAudio(spinData.grids)
    if quickSet then
        self.slotContainers[self.curGameType]:SetOpen(true)
    end
    self.slotContainers[self.curGameType]:HandleWinDatas(spinData.lines)
    self.slotContainers[self.curGameType]:HandleCellDatas(spinData.grids)
    self.slotContainers[self.curGameType]:SetIsEnterFree(spinData.intoFree == 1)
    self.slotContainers[self.curGameType]:SetIsEnterTopupBouns(spinData.intoSpecial == 1)
    self.slotContainers[SlotType.Normal]:SetReelSymbolData(function(second)
        -- 自定义回调函数
        if customCallback then
            customCallback()
            return
        end
        self.playCaijinAnimCallBack = function ()
            if spinData.intoFree == 1 then
                local winCoin = self.slotContainers[SlotType.Normal]:GetWinCoin()
                self.slotContainers[SlotType.Free]:ResetDatas(0,6,winCoin)
                self:SetMidTips("tbStart")
                FCasinoCtx:SetGameMode(FGameMode.FREE)
                FCasinoCtx:SetSpinStatus(FSpinStatus.SPIN)
                self:DelayCallSpin(2,
                function ()
                    self:ChangeGameType(SlotType.Free)
                    self:StopNormalAction()
                    self:SetMidTips("freecount",1,6,1)
                end)
                return
            elseif spinData.intoSpecial == 1 then
                local winCoin = self.slotContainers[SlotType.Normal]:GetWinCoin()
                self:ChangeGameType(SlotType.TopupBouns)
                self:StopNormalAction()
                self.slotContainers[self.curGameType]:ResetDatas(true,3,winCoin)
                self.slotContainers[self.curGameType]:SetReelSymbolData(spinData.grids, 
                    function ()
                        FCasinoCtx:SetSpinStatus(FSpinStatus.WAITING)
                    end
                , true)
                self:SetTopupBounsCount(self.slotContainers[self.curGameType]:GetTopupBounsCount())
                self.topupBonusAnim:PlayTopupBonusAnim(function ()
                    self:SetMidTips("tbStart")
                    StartOnceTimer(function()
                        self:SetMidTips("tb3")
                        FCasinoCtx:SetSpinStatus(FSpinStatus.SPIN)
                        -- 计时器自动旋转 落地牌
                        self:DelayCallSpin(2)
                    end,1)
                    FCasinoCtx:SetSpinStatus(FSpinStatus.WAITING)
                end)
                return
            else
                FCasinoCtx:SetPlayerMoneyInfo(spinData)
                FCasinoCtx:SyncPlayerMoneyDisplay(2)
                if FCasinoCtx.isAutoSpin then
                    self:DelayCallSpin(2)
                end
                self.delaySpin = StartOnceTimer(
                    function ()
                        FCasinoCtx:SetSpinStatus(FSpinStatus.SPIN)
                        self.delaySpin = nil
                    end,
                1)
            end
        end
        self.playCaijinAnimTimer = StartOnceTimer(
            function ()
                self.playCaijinAnimTimer = nil
                if self.playCaijinAnimCallBack then
                    self.playCaijinAnimCallBack()
                    self.playCaijinAnimCallBack = nil
                end
                return
            end,
        second)
    end,quickSet)
end

-- @brief 处理免费游戏旋转结果
-- @param quickSet 直接设置跳过动画
function Game475:OnFreeSpinResult(spinData, quickSet, callback)
    self.isSpined = false
    self:ChangeGameType(SlotType.Free)
    self.slotContainers[self.curGameType]:ResetState()
    self:setPlayGetFreeSymbolStrengthAudio(spinData.grids)
    if quickSet then
        self.slotContainers[self.curGameType]:SetOpen(true)
    else
        self.slotContainers[self.curGameType]:HandleWinDatas(spinData.lines)
        self.slotContainers[self.curGameType]:SetIsEnterFree(spinData.intoFree == 1)
        self.slotContainers[self.curGameType]:SetIsEnterTopupBouns(spinData.intoSpecial == 1)
    end
    self.slotContainers[self.curGameType]:HandleCellDatas(spinData.grids)
    self.slotContainers[self.curGameType]:SetReelSymbolData(function(second)
        if callback then
            callback()
            return
        end
        -- 免费结束
        self.slotContainers[self.curGameType]:SetAllTurns(spinData.allCount)
        local isEnd = spinData.totalCount >= spinData.allCount
        if isEnd then
            print("免费结束")
            self:SetMidTips("freeendbg")
        end
        self.playCaijinAnimCallBack = function ()
            if isEnd then
                if spinData.intoSpecial == 0 then
                    FTween.Start(self.render,
                        FTween.Delay(2, function()
                            self:StopNormalAction()
                            self.slotContainers[SlotType.Normal]:HandleCellDatas(self.datas.normalPacket.grids)
                            self.slotContainers[SlotType.Normal]:SetReelSymbolData(
                                function ()
                                    FCasinoCtx:SetSpinStatus(FSpinStatus.WAITING)
                                end
                            , true)
                            self:ChangeGameType(SlotType.Normal)
                            FCasinoCtx:SetSpinStatus(FSpinStatus.STOP)
                            self._winCoin = 0
                            FCasinoCtx.commonPanel:SetWinMoney(0)
                            local second = self:ShowBottomWin(false,spinData.bonusWinCoin)
                            self.playCaijinAnimCallBack = function ()
                                if FCasinoCtx.isAutoSpin then
                                    self:DelayCallSpin(2)
                                end
                                FCasinoCtx:SetSpinStatus(FSpinStatus.SPIN)
                                FCasinoCtx.commonPanel:StopScrollMoney(nil, true)
                            end
                            self.playCaijinAnimTimer = StartOnceTimer(
                                function ()
                                    self.playCaijinAnimTimer = nil
                                    if self.playCaijinAnimCallBack then
                                        self.playCaijinAnimCallBack()
                                        self.playCaijinAnimCallBack = nil
                                    end
                                    return
                                end,
                            second)
                            FCasinoCtx:SetPlayerMoneyInfo(spinData)
                            FCasinoCtx:SyncPlayerMoneyDisplay(second)
                        end)
                    )
                end
                self:ChangeBgm()
            else
                if spinData.intoSpecial == 0 then
                    self:DelayCallSpin(2)
                    FCasinoCtx:SetSpinStatus(FSpinStatus.SPIN)
                end
            end
            if spinData.intoSpecial == 1 then -- 免中落地牌
                FCasinoCtx:SetSpinStatus(FSpinStatus.WAITING)
                self.tips:HideTips()
                self:ChangeGameType(SlotType.FreeTopupBouns)
                -- self:ChangeGameType(isEnd and SlotType.TopupBouns or SlotType.FreeTopupBouns)
                self:StopFreeAction()
                self.slotContainers[self.curGameType]:ResetDatas(true,3,self.slotContainers[SlotType.Free]:GetWinCoin())
                self.slotContainers[self.curGameType]:SetReelSymbolData(spinData.grids, 
                    function ()
                        FCasinoCtx:SetSpinStatus(FSpinStatus.WAITING)
                    end
                , true)
                self:SetTopupBounsCount(self.slotContainers[self.curGameType]:GetTopupBounsCount())
                self.topupBonusAnim:PlayTopupBonusAnim(function ()
                    self:SetMidTips("tbStart")
                    FTween.Start(self.render,
                        FTween.Delay(1, function()
                            self:SetMidTips("tb3")
                            FCasinoCtx:SetSpinStatus(FSpinStatus.SPIN)
                            -- 计时器自动旋转 落地牌
                            self:DelayCallSpin(2)
                        end)
                    )
                    FCasinoCtx:SetSpinStatus(FSpinStatus.WAITING)
                    
                end)
            end
        end
        self.playCaijinAnimTimer = StartOnceTimer(
            function ()
                self.playCaijinAnimTimer = nil
                if self.playCaijinAnimCallBack then
                    self.playCaijinAnimCallBack()
                    self.playCaijinAnimCallBack = nil
                end
                return
            end,
        second)
    end, quickSet)
end

-- @brief 处理特殊游戏旋转结果
-- @param quickSet 直接设置跳过动画
function Game475:OnSpecialSpinResult(spinData, quickSet, customCallback)
    self.isSpined = false
    -- 使用落地牌模式的转轴来展示
    if self.curGameType == SlotType.FreeTopupBouns then
        self:ChangeGameType(SlotType.FreeTopupBouns)
    else
        self:ChangeGameType(SlotType.TopupBouns)
    end
    self.slotContainers[self.curGameType]:SetReelSymbolData(spinData.grids, function()
        self.isSpined = false
        -- 自定义回调函数
        if customCallback then
            customCallback()
            return
        end
        local topupBounsCount = self.slotContainers[self.curGameType]:GetTopupBounsCount()
        self:SetTopupBounsCount(topupBounsCount)
        local num = self.slotContainers[self.curGameType]:GetSpinNum()
        if topupBounsCount == 15 then
            FToolSet.PlayFGUISound(MusicCfg.SND_GrandBell)
            num = 0
            local bigGrandWin = spinData.AllWinCoin
            local winCoin = self.slotContainers[self.curGameType]:GetWinCoin()
            bigGrandWin = bigGrandWin - winCoin
            for _, cell in ipairs(spinData.grids) do
                bigGrandWin = bigGrandWin - cell.SymbolValue
            end
            self:PlayBigGrandWin(bigGrandWin,function () -- 3 秒
                self.tips:PlayTopAnim(nil,bigGrandWin)
            end)
        end
        if num > 0 then
            FCasinoCtx:SetSpinStatus(FSpinStatus.SPIN)
            self:DelayCallSpin(2)
        else
            -- 落地牌游戏结束
            self:SetMidTips("tbEnd")
            
            FCasinoCtx:SetSpinStatus(FSpinStatus.WAITING)
            FTween.Start(self.render,
                FTween.Delay(topupBounsCount == 15 and 2 or 0.01, function()
                    FTween.KillTweens(self.render)
                    self:SetMidTips("win")
                    local tbIndexs = self.slotContainers[self.curGameType]:GetTopupBounsIndexs()
                    FToolSet.PlayFGUISound(MusicCfg.SND_Rumble)
                    self:ChangeBgm()
                    FTween.Start(self.render,
                        FTween.Delay(2, function()
                            FTween.KillTweens(self.render)
                            self.topupBounsFlyDragon:Play(tbIndexs,self.slotContainers[self.curGameType],self.tips,function ()
                                print("落地牌游戏结束")
                                FToolSet.PlayFGUISound(MusicCfg.SND_Fea_End)
                                print("spinData.AllWinCoin ",spinData.AllWinCoin)
        
                                local second = self:ShowBottomWin(false,spinData.AllWinCoin)
                                self:SetTopupBounsCount(0)
                                self.playCaijinAnimCallBack = function ()
                                    local curTurn = self.slotContainers[SlotType.Free]:GetCurTurn()
                                    local allTurns = self.slotContainers[SlotType.Free]:GetAllTurns()
                                    if self.curGameType == SlotType.FreeTopupBouns and curTurn ~= allTurns then
                                        -- FCasinoCtx:SetGameMode(FGameMode.FREE)
                                        self.slotContainers[SlotType.Free]:ResetDatas(curTurn,allTurns,spinData.AllWinCoin)
                                        self.tips:HideTips()
                                        self:SetMidTips("freecount",curTurn,allTurns)
                                        
                                        self:DelayCallSpin(2)
                                        self:ChangeBgm(MusicCfg.SND_Fea_BGM)
                                        self:StopFreeAction()
                                        self.slotContainers[SlotType.Free]:HandleCellDatas(self.datas.freeSpinPacket.grids)
                                        self.slotContainers[SlotType.Free]:SetOpen(true)
                                        self.slotContainers[SlotType.Free]:SetReelSymbolData(nil, true)
                                        self:ChangeGameType(SlotType.Free)
                                        FCasinoCtx:SetSpinStatus(FSpinStatus.SPIN)
                                    elseif self.curGameType == SlotType.FreeTopupBouns and curTurn == allTurns then
                                        print(" 免中落地牌最后一把结算 抛金币")
                                        self.tips:HideTips()
                                        -- FCasinoCtx:SetGameMode(FGameMode.NORMAL)
                                        FTween.Start(self.render,
                                            FTween.Delay(0.1, function()
                                                self._winCoin = 0
                                                FCasinoCtx.commonPanel:SetWinMoney(0)
                                                local second2 = self:ShowBottomWin(false,spinData.AllWinCoin)
                                                self.playCaijinAnimCallBack = function ()
                                                    if FCasinoCtx.isAutoSpin then
                                                        self:DelayCallSpin(2)
                                                    end
                                                    FCasinoCtx:SetSpinStatus(FSpinStatus.SPIN)
                                                end
                                                self.playCaijinAnimTimer = StartOnceTimer(
                                                    function ()
                                                        self.playCaijinAnimTimer = nil
                                                        if self.playCaijinAnimCallBack then
                                                            self.playCaijinAnimCallBack()
                                                            self.playCaijinAnimCallBack = nil
                                                        end
                                                    end,second2
                                                )
                                                self:StopNormalAction()
                                                self.slotContainers[SlotType.Normal]:SetOpen(true)
                                                self.slotContainers[SlotType.Normal]:HandleCellDatas(self.datas.normalPacket.grids)
                                                self.slotContainers[SlotType.Normal]:SetReelSymbolData(nil, true)
                                                self:ChangeGameType(SlotType.Normal)
                                                FCasinoCtx:SetPlayerMoneyInfo(spinData)
                                                FCasinoCtx:SyncPlayerMoneyDisplay(second2)
                                                FCasinoCtx:SetSpinStatus(FSpinStatus.STOP)
                                            end)
                                        )
                                    else
                                        self.tips:HideTips()
                                        FCasinoCtx:SetPlayerMoneyInfo(spinData)
                                        FCasinoCtx:SyncPlayerMoneyDisplay(2)
                                        -- FCasinoCtx:SetGameMode(FGameMode.NORMAL)
                                        if FCasinoCtx.isAutoSpin then
                                            self:DelayCallSpin(2)
                                        end
                                        FCasinoCtx:SetSpinStatus(FSpinStatus.SPIN)
                                        self:StopNormalAction()
                                        self.slotContainers[SlotType.Normal]:SetOpen(true)
                                        self.slotContainers[SlotType.Normal]:HandleCellDatas(self.datas.normalPacket.grids)
                                        self.slotContainers[SlotType.Normal]:SetReelSymbolData(nil, true)
                                        self:ChangeGameType(SlotType.Normal)
                                    end
                                end
                                self.playCaijinAnimTimer = StartOnceTimer(
                                    function ()
                                        self.playCaijinAnimTimer = nil
                                        if self.playCaijinAnimCallBack then
                                            self.playCaijinAnimCallBack()
                                            self.playCaijinAnimCallBack = nil
                                        end
                                    end,second
                                )
                                FCasinoCtx:SetSpinStatus(FSpinStatus.STOP)
                            end)
                        end)
                    )
                end)
            )
            return
        end

    end, quickSet)
end

-- 自动旋转 --自动旋转时间取消 delay 作废 
function Game475:DelayCallSpin(delay,cb)
    self:StopDelayCallSpin()
    local interval = FConfig.Common.AutoSpinInterval[FCasinoCtx.curGameMode]
    self.callSpinTimer = StartOnceTimer(function()
        if cb then
            cb()
        end
        FCasinoCtx:SimulateSpinClick()
    end, interval)
end

function Game475:StopDelayCallSpin()
    if self.callSpinTimer then
        StopTimer(self.callSpinTimer)
        self.callSpinTimer = nil
    end
end

-- 播放中奖连线
function Game475:PlayLines(lines)
    if not next(lines) then
        return
    end
    local index = 1
    self.winLines:BlinkLine(lines[index].index)
    self.slotContainers[self.curGameType]:PlayBlinkByCells(lines[index].lineCells)
        
    FTween.Start(self.winLines.parent,
        FTween.RepeatForever(
            {
                FTween.Delay(2, function()
                    if index ~= 0 then
                        self.winLines:StopBlinkLine(lines[index])
                        self.slotContainers[self.curGameType]:StopBlinkByCells(lines[index].lineCells)
                    end
                    index = index + 1
                    if index > #lines then
                        index = 1
                    end
                    self.winLines:BlinkLine(lines[index].index)
                    self.slotContainers[self.curGameType]:PlayBlinkByCells(lines[index].lineCells)
                end)
            }    
        )
    )
end

-- 隐藏中奖连线
function Game475:StopLines()
    FTween.KillTweens(self.winLines.parent)
    for i = 1, 50 do
        self.winLines:StopBlinkLine(i)
    end
end

-- 特殊游戏中间提示
function Game475:SetMidTips(imageUrl,curturn,allturns,oldturns)
    self.tips:ShowTips(imageUrl,curturn,allturns,oldturns)
end

-- 转换游戏类型
function Game475:ChangeGameType(slotType)
    if self.curGameType == slotType then
        return
    end
    if self.slotContainers[self.curGameType] then
        self.slotContainers[self.curGameType]:SetVisible(false)
    end
    self.curGameType = slotType
    if SlotType.Normal == slotType then
        FCasinoCtx:SetGameMode(FGameMode.NORMAL)
    elseif SlotType.Free == slotType then
        FCasinoCtx:SetGameMode(FGameMode.FREE)
    elseif SlotType.TopupBouns == slotType then
        FCasinoCtx:SetGameMode(FGameMode.SPECIAL)
    elseif SlotType.FreeTopupBouns == slotType then
        FCasinoCtx:SetGameMode(FGameMode.SPECIAL)
    end
    self.slotContainers[self.curGameType]:SetVisible(true)
end

-- 停止普通游戏的动画和中奖线
function Game475:StopNormalAction()
    self.slotContainers[SlotType.Normal]:RemoveTopSymbol()
    self:StopLines()
end

-- 停止免费游戏的动画和中奖线
function Game475:StopFreeAction()
    self.slotContainers[SlotType.Free]:RemoveTopSymbol()
    self:StopLines()
end

-- 落地牌拥有数量
function Game475:SetTopupBounsCount(count)
    if count == 0 then
        self.count.visible = false
        self.box5x3.visible = false
        return
    end
    if count<13 then
        self:ChangeBgm(MusicCfg.SND_FreeSpin_BGM)
    else
        self:ChangeBgm(MusicCfg.SND_FreeSpin_BGMFast)
    end
    self.count.visible = true
    self.box5x3.visible = true
    local text = self.count:GetChild("count")
    text.text = count
end

function Game475:ShowBottomWin(quickSet,winCoin)
    -- print("self.curGameType: ",self.curGameType)
    local winCoin = winCoin or self.slotContainers[self.curGameType]:GetWinCoin()
    local second = 0.01
    if not quickSet then
        local lastWinCoin = self._winCoin
        local addCoin = winCoin - lastWinCoin
        local audioData = FConfig.Common:GetFaFaFaAudioData(addCoin)
        if audioData then -- 播放收分音乐
            -- dump(audioData,"audioData")
            if self.soundWinCoinEffectHandle then
                APIGateway.StopSound(self.soundWinCoinEffectHandle)
                self.soundWinCoinEffectHandle = nil
            end
            if self.soundWinCoinEffectHandleTimer then
                StopTimer(self.soundWinCoinEffectHandleTimer)
                self.soundWinCoinEffectHandleTimer = nil
            end
            self.soundWinCoinEffectHandle = FToolSet.PlayFGUISound(audioData.url)
            second = audioData.time
            self.soundWinCoinEffectHandleTimer = StartOnceTimer(
                function ()
                    if self.render then
                        self.soundWinCoinEffectHandle = nil
                    end
                end
            ,second)

            if audioData.isOpenFire then -- 较大价值奖励抛金币
                self.coinFountain:Play(nil,CoinFountain.Anims[2])
                self.CoinFountainTimer = StartOnceTimer(
                    function ()
                        if self.render then
                            self.coinFountain:Stop()
                        end
                    end
                ,second)
            end
        end
    end
    -- 结算金币
    if winCoin > 0 then
        print("winCoin:",winCoin)
        FCasinoCtx.commonPanel:ScrollWinMoneyTo(winCoin,second)
        self._winCoin = winCoin
    end
    return second
end

function Game475:ChangeBgm(url)
    if self.soundBgm == url then
        return
    end
    FToolSet.StopBGM()
    self.soundBgm = nil
    if not url then
        return
    end
    FToolSet.PlayBGM(url)
    self.soundBgm = url
end

function Game475:PlayBigGrandWin(winNum,cb)
    self.bigGrand.visible = true
    -- self.bigGrand.scale = vec2(0,0)
    local caijin = self.bigGrand:GetChild("caijin")
    caijin.text = FToolSet.NumToStr(winNum)
    self.bigGrand:GetTransition("t0"):Play(function()
        if cb then
            cb()
        end
    end)
end

function Game475:setPlayGetFreeSymbolStrengthAudio(grids)
    self.reelerIdxsShouldPlayScatterAudio = {}
    --播放scatter音效 1,2,3列/4列且1,2,3列存在至少一个/5列且1,2,3,4列至少两个
    local reelerIdxsMaybePlayScatterAudioDic = {};
    local getScatterColumnDic = function(grids) 
        local res = {};
        for i,item in ipairs(grids) do
            local icon = item.icon
            local column = (i - 1) % 5 + 1;
            if res[column] == nil then res[column] = 0 end
            if icon == 2 then
                reelerIdxsMaybePlayScatterAudioDic[column] = true;
                res[column] = res[column] +1;
            end
        end
        return res;
    end
    local scatterColumnDic = getScatterColumnDic(grids)
    -- 前4列中奖情况
    local scatterColumnDic0123 = {scatterColumnDic[1], scatterColumnDic[2], scatterColumnDic[3], scatterColumnDic[4]}
    -- dump(scatterColumnDic0123,"scatterColumnDic0123>>>>>>>>")
    local dic0123Count = 0
    for _, value in pairs(scatterColumnDic0123) do
        if value ~= 0 then
            dic0123Count = dic0123Count + 1
        end
    end
    -- print("dic0123Count>>>>>>>>>",dic0123Count)
    if scatterColumnDic[1] ~= 0 then
        table.insert(self.reelerIdxsShouldPlayScatterAudio, 1)
    end
    if scatterColumnDic[2] ~= 0 then
        table.insert(self.reelerIdxsShouldPlayScatterAudio, 2)
    end
    if scatterColumnDic[3] ~= 0 then
        table.insert(self.reelerIdxsShouldPlayScatterAudio, 3)
    end

    if scatterColumnDic[4] ~= 0 and (scatterColumnDic[1] ~= 0 or scatterColumnDic[2] ~= 0 or scatterColumnDic[3] ~= 0) then
        table.insert(self.reelerIdxsShouldPlayScatterAudio, 4)
    end
    if scatterColumnDic[5] ~= 0 and dic0123Count >= 2 then
        table.insert(self.reelerIdxsShouldPlayScatterAudio, 5)
    end
    -- dump(self.reelerIdxsShouldPlayScatterAudio,"self.reelerIdxsShouldPlayScatterAudio>>>>>>>>>>>>")
end

return Game475