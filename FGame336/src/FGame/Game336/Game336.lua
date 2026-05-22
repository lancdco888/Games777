
 local NormalSlot        = Import(".Slot.NormalSlot")
local TopupBounsSlot        = Import(".Slot.TopupBounsSlot")
local FreeSlot        = Import(".Slot.FreeSlot")
local WinLines          = Import(".Slot.WinLines")
local TopupBonusAnim    = Import(".Slot.TopupBonusAnim")
local TopupBounsFlyDragon    = Import(".Slot.TopupBounsFlyDragon")
 local Tips              = Import(".Slot.Tips")
local CaijinPanel              = Import(".CaijinPanel")
 local MusicCfg = Import(".Slot.MusicCfg")

local CoinFountain = require("FGame.Common.Logic.Effect.CoinFountain")
local SlotType = {
    Normal      = 1,    -- 普通类型
    Free        = 2,    -- 免费游戏
    TopupBouns  = 3,    -- 落地牌类型
    FreeTopupBouns  = 4,    -- 免中落地牌类型
}

local Game336 = Class("Game336", BaseGame)

function Game336:ctor(render)
    self.render = render
    if not self.render  then
        print("render 为 nil")
    end
    --加载界面
    local slot = self.render:GetChild("Slot").component
    self.curGameType = 0
    self.slotContainers = {}
    self.slotContainers[SlotType.Normal] = NormalSlot.New(slot:GetChild("ReelContainer"),self)
    self.slotContainers[SlotType.Normal]:SetVisible(false)
    self.slotContainers[SlotType.TopupBouns] = TopupBounsSlot.New(slot:GetChild("ReelContainer"),self)
    self.slotContainers[SlotType.TopupBouns]:SetVisible(false)
    
    self.slotContainers[SlotType.Free] = FreeSlot.New(slot:GetChild("ReelContainer"),self)
    self.slotContainers[SlotType.Free]:SetVisible(false)
    self.slotContainers[SlotType.FreeTopupBouns] = self.slotContainers[SlotType.TopupBouns] --3 4 共用
     self:ChangeGameType(SlotType.Normal)

    -- -- 中线连线
    self.winLines = WinLines.New(slot:GetChild("WinLines"))
    -- 落地牌动画节点
    self.topupBonusAnim = TopupBonusAnim.New(self.render:GetChild("TopupBonusAnim"))
    -- 落地牌飞龙的动画
    self.topupBounsFlyDragon = TopupBounsFlyDragon.New(self.render:GetChild("TopupBounsFlyDragon"))
    
    -- -- 特殊游戏中间提示文字
    self.tips = Tips.New(self.render:GetChild("Tips"))

    self.box5x3 = slot:GetChild("n18")
    self.box5x3.visible = false
    self.count = slot:GetChild("count")
    self.count.visible = false
    local caijin = self.render:GetChild("CaijinPanel").component
    self.caijinPanel = CaijinPanel.New(caijin)
    self.datas = {
        normalPacket = nil, -- 普通旋转结果
        freeSpinPacket = nil , -- 免费旋转结果
        specialPacket = nil, -- 特殊旋转结果
    }

    self.soundBgmHandle = nil
    self.soundBgm = nil
    --创建喷射金币效果
    self.coinFountain = CoinFountain.New()
    self.coinFountain:SetSortingOrder(10)

    self._winCoin = 0
    -- 落地牌巨奖提示
    self.bigGrand = self.render:GetChild("grand")
    self.bigGrand.visible = false
    self._autoSpinSecond = 1
    self.wildeffect = nil
    self.is_inFreegame = false
    self.isToFreeEffect,self.inTospecialEffect = false,false
end

function Game336:__delete()
    FTween.KillTweens(self.winLines.parent)
    self:StopDelayCallSpin()
    for i = 1, 3  do -- 3  4 共用
        self.slotContainers[i]:Delete()
    end
    self.winLines:Delete()
    self.tips:Delete()
    self.topupBonusAnim:Delete()
    self.topupBounsFlyDragon:Delete()
    self.caijinPanel:Delete()

    if self.soundBgmHandle then
        APIGateway.StopSound(self.soundBgmHandle)
        self.soundBgmHandle = nil
    end
    if self.playCaijinAnimTimer then
        StopTimer(self.playCaijinAnimTimer)
        self.playCaijinAnimTimer = nil
    end
    self.coinFountain:Delete()
end
--是否是免费游戏
function Game336:InGameFree()
    if FCasinoCtx.curGameMode == FGameMode.FREE then
        return true
    end
    return false
end
function Game336:InGameNormal()
    if FCasinoCtx.curGameMode == FGameMode.NORMAL then
        return true
    end
    return false
end
function Game336:InGameSpecial()
    if FCasinoCtx.curGameMode == FGameMode.SPECIAL then
        return true
    end
    return false
end
-- @interface
-- @brief update
function Game336:Update(dt)
    Game336.super.Update(self, dt)
    for i = 1, 4 do -- 3  4 共用
        self.slotContainers[i]:Update(dt)
    end
end
function Game336:SetAutoSpinSecond(second)
    self._autoSpinSecond = second
end
function Game336:GetAutoSpinSecond()
    return self._autoSpinSecond 
end

-- @interface
-- @brief 在游戏中断线重连恢复游戏
-- @param local  断线重连数据
function Game336:ReconnectRecoveryGame(data, isInitialize)
    dump(data,"ReconnectRecoveryGame",5)
    print("isInitialize: ",isInitialize)
    print("断线重连 self.curGameType: ",self.curGameType)
    print("断线重连 self.isSpined: ",self.isSpined)
    --type 1普通 2免费 3特殊 4免费中特殊
    if data.type == 1 then
        local resumedNormal = data.resumedNormal
        local normalSpin = resumedNormal.normalSpin
        local bonusWin = data.currentWinCoin
        if normalSpin.intoSpecial == 1 then
            for _, cell in ipairs(resumedNormal.normalSpin.grids) do
                bonusWin = bonusWin - cell.SymbolValue
            end
            print("bonusWin:",bonusWin)
            if bonusWin > 0 then
                self:ShowBottomWin(true,bonusWin)
            end
        end
        print("断线重连 - 处理接收普通包")
        if not self:CheckSlotData(normalSpin.grids, SlotType.Normal) then -- 不一样
            self.datas.normalPacket = normalSpin
            if self.curGameType ~= 1 and self.isSpined then -- 已经在特殊游戏了
                self:SendPackage()
                return
            end
            if isInitialize then
                if  normalSpin.intoSpecial == 1 then
                     --处理进入中奖赢钱
                    self.slotContainers[SlotType.Normal]:HandleWinDatas(normalSpin.lines)
                    self:ShowBottomWin(true,bonusWin)
                    self:EnterSpecialGame(true,self.datas.normalPacket)
                elseif normalSpin.intoFree > 0 then
                     --处理进入中奖赢钱
                    self.slotContainers[SlotType.Normal]:HandleWinDatas(normalSpin.lines)
                    self:ShowBottomWin(true,bonusWin)
                    self:EnterFreeGame()
                else
                    self:OnNormalSpinResult(normalSpin,true,function () end)
                end
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
            if self.datas.freeSpinPacket.allCount <= self.datas.freeSpinPacket.totalCount and 
            self.datas.freeSpinPacket.intoSpecial == 0 then
                --没次数了
                self:OnNormalSpinResult(resumedFree.freeSpin, true,function ()
                    
                end)
                return
            end
            self:ChangeBgm(MusicCfg.SND_Fea_BGM)
            self.slotContainers[SlotType.Free]:ResetDatas(self.datas.freeSpinPacket.totalCount,self.datas.freeSpinPacket.allCount,data.currentWinCoin)
            self:ShowBottomWin(true,data.currentWinCoin)
            if self.curGameType ~= 2 and self.isSpined then -- 已经在落地牌游戏了
                self:SendPackage()
                return
            end
            self:SetMidTips("freecount",self.datas.freeSpinPacket.totalCount,self.datas.freeSpinPacket.allCount)
            self:OnFreeSpinResult(self.datas.freeSpinPacket, true,function ()
                --self:DelayCallSpin(3)
            end)
            self:GameState_HandleSpecial()
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
                if isInitialize then -- 杀进程直接显示
                    self:OnNormalSpinResult(resumedSpecial.specialSpin, true,function ()
                        
                    end)
                    --特殊游戏结束断线重连回到普通游戏界面
                    self.slotContainers[SlotType.Normal]:SetOpen(true)
                    self.slotContainers[SlotType.Normal]:HandleCellDatas(self.datas.normalPacket.grids)
                    self.slotContainers[SlotType.Normal]:SetReelSymbolData(nil, true)
                    self:ChangeGameType(SlotType.Normal)
                    self:ShowBottomWin(true,resumedSpecial.specialSpin.AllWinCoin)
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
        self.datas.normalPacket = resumedNormal.normalSpin
        self.is_inFreegame = true
        if resumedSpecial.specialSpin.totalCount == 0 then -- 看看免费包
            print("断线重连 - 处理接收免中落地牌 免费")
            if not self:CheckSlotData(resumedFree.freeSpin.grids, SlotType.Free) then -- 不一样
                self.datas.normalPacket = resumedNormal.normalSpin
                self.datas.freeSpinPacket = resumedFree.freeSpin
                -- dump(self.datas.freeSpinPacket,"断线重连数据")
                print("-- 不一样")
                if self.datas.freeSpinPacket.allCount <= self.datas.freeSpinPacket.totalCount then
                    --没次数了
                    if self.curGameType ~= 4 and self.isSpined then
                        self:SendPackage()
                    end
                    if isInitialize then -- 杀进程直接显示
                        self:OnNormalSpinResult(resumedSpecial.specialSpin, true,function ()end)
                    end
                    return
                end
                print("免费次数旋转没转完")
                self:ChangeBgm(MusicCfg.SND_Fea_BGM)
                -- FToolSet.PlayFGUISound(MusicCfg.SND_Fea_BGM,true)
                self.slotContainers[SlotType.Free]:ResetDatas(self.datas.freeSpinPacket.totalCount,self.datas.freeSpinPacket.allCount,data.currentWinCoin)
                if isInitialize then -- 杀进程直接显示
                    self:OnFreeSpinResult(resumedSpecial.specialSpin, true,function ()
                        self:DelayCallSpin(1)
                    end)
                    self:ShowBottomWin(true,data.currentWinCoin)
                end
                -- self:OnFreeSpinResult(resumedSpecial.specialSpin, true,function ()
                --     self:DelayCallSpin(4)
                -- end)
                self:SetMidTips("freecount",self.datas.freeSpinPacket.totalCount,self.datas.freeSpinPacket.allCount)
            else
                print("数据一样")
                if self.isSpined then
                    self:SendPackage()
                end
            end
        else
            print("断线重连 - 处理接收免中落地牌")
            if not self:CheckSlotData(resumedSpecial.specialSpin.grids, SlotType.FreeTopupBouns) then -- 不一样
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
function Game336:CheckSlotData(grids, type)
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
        local SymbolBet = grids[i].SymbolBet

        local lastIcon = localGrids[i].icon
        local lastbonusType = grids[i].SymbolType
        local lastbonusValue = grids[i].SymbolValue
        local lastSymbolBet = grids[i].SymbolBet

        if icon ~= lastIcon or
         bonusType ~= lastbonusType or
         bonusValue ~= lastbonusValue or
         SymbolBet ~= lastSymbolBet then
            return false
        end
    end
    return true
end
function Game336:StopAllcoin_sound_wincoin()
    if self.wildeffect then
        APIGateway.StopSound(self.wildeffect)
        self.wildeffect = nil
    end
    self:StopDelayCallSpin()
    --停止播放金币喷射动画
    self.coinFountain:Stop()
    --停止播放收分音效
    if self.soundWinCoinEffectHandle then
        APIGateway.StopSound(self.soundWinCoinEffectHandle)
        self.soundWinCoinEffectHandle = nil
    end
end

-- @interface
-- @brief 点击开始按钮
function Game336:OnClickSpin()
    print("点击开始按钮")
    self:StopAllcoin_sound_wincoin()
    --停止收分计时器
    if self.soundWinCoinEffectHandleTimer then
        StopTimer(self.soundWinCoinEffectHandleTimer)
        self.soundWinCoinEffectHandleTimer = nil
        self:ShowBottomWin(true,self._winCoin)
        if FCasinoCtx.curGameMode ~= FGameMode.NORMAL then
            self:DelayCallSpin(1)
        end
        return
    end
    self.is_inFreegame = false
    if FCasinoCtx.curGameMode == FGameMode.NORMAL then
        self.datas.freeSpinPacket = nil
        self.datas.specialPacket = nil
        -- 金币不足
        if not FCasinoCtx:PlayerSpinConsumption() then
            --金币不足退出自动旋转状态
            if FCasinoCtx.isAutoSpin then
                FCasinoCtx:SetAutoSpin(false) 
            end
            return
        end
        self:StopActionAndWinlines()
        FCasinoCtx.commonPanel:StopScrollWinMoney(0, false)
        -- 清空本轮赢分
        self._winCoin = 0
        self.tips:HideTips()
        self:ChangeGameType(SlotType.Normal)
        self.slotContainers[SlotType.Normal]:SpinStart()
    elseif FCasinoCtx.curGameMode == FGameMode.FREE then
        self:StopActionAndWinlines()
        self.is_inFreegame = true
        self:ChangeGameType(SlotType.Free)
        self.slotContainers[SlotType.Free]:SpinStart()
    elseif FCasinoCtx.curGameMode == FGameMode.SPECIAL then
        self:StopActionAndWinlines()
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

function Game336:SendPackage()
    if FCasinoCtx.curGameMode == FGameMode.NORMAL then
        print("发送普通包数据")
        self:SendNormalSpin("PB.Client_Slots.DragonGiftNormalSpin", "PB.Slots_Client.DragonGiftNormalRet",
            function(ok, result)
                if not ok then return end
                print("接受普通回包数据")
                dump(result,"NORMAL",4)
                self.datas.normalPacket = result.normalSpin
                self:OnNormalSpinResult(result.normalSpin)
            end
        )
    elseif FCasinoCtx.curGameMode == FGameMode.FREE then
        print("发送免费包数据")
        local request = {
            _msgName_ = "PB.Client_Slots.DragonGiftFreeSpin"
        }
        APIGateway.SendExactRequest(request, "PB.Slots_Client.DragonGiftFreeRet",
            function(ok, result)
                if not ok then return end
                dump(result,"FREE",4)
                self.datas.freeSpinPacket = result.freeSpin
                self:OnFreeSpinResult(result.freeSpin)
            end
        )
    elseif FCasinoCtx.curGameMode == FGameMode.SPECIAL then
        print("发送特殊包数据")
        local request = {
            _msgName_ = "PB.Client_Slots.DragonGiftSpecialSpin"
        }
        APIGateway.SendExactRequest(request, "PB.Slots_Client.DragonGiftSpecialRet",
            function(ok, result)
                if not ok then return end
                self.datas.specialPacket = result.specialPacket
                dump(result,"SPECIAL",4)
                self:OnSpecialSpinResult(result.specialSpin)
            end
        )
    end
end


function Game336:OnClickStop()
    if self.free_playCaijinAnimTimer then
        StopTimer(self.free_playCaijinAnimTimer)
        self.free_playCaijinAnimTimer = nil
        if self.free_playCaijinAnimCallBack then
            self.free_playCaijinAnimCallBack()
            self.free_playCaijinAnimCallBack = nil
        end
        return
    end
    self:StopAllcoin_sound_wincoin()
    if self.playCaijinAnimTimer then
        StopTimer(self.playCaijinAnimTimer)
        self.playCaijinAnimTimer = nil
        if self.playCaijinAnimCallBack then
            self.playCaijinAnimCallBack()
            self.playCaijinAnimCallBack = nil
        end
    end
     --停止收分计时器
     if self.soundWinCoinEffectHandleTimer then
        StopTimer(self.soundWinCoinEffectHandleTimer)
        self.soundWinCoinEffectHandleTimer = nil
        self:ShowBottomWin(true,self._winCoin)
    end
     --如果停止旋转状态跳出
     if not self.isSpined then return end
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
function Game336:OnNormalSpinResult(spinData, quickSet, customCallback,AllWinCoin)
    print("处理普通旋转结果")
    self:ChangeGameType(SlotType.Normal)
    if quickSet then
        self.slotContainers[self.curGameType]:SetOpen(true)
    end
    self.slotContainers[self.curGameType]:HandleWinDatas(spinData.lines)
    self.slotContainers[self.curGameType]:HandleCellDatas(spinData.grids)
    self.slotContainers[SlotType.Normal]:SetReelSymbolData(function(second)
        self.isSpined = false
        -- 自定义回调函数
        if customCallback then
            customCallback()
            return
        end
        StartOnceTimer(function ()
            self:SpinEndCallFunc()
        end,0.5)
    end, quickSet,AllWinCoin)
end
--旋转结束播放中奖线前特殊处理
function Game336:SpinEndCallFunc()
    FCasinoCtx:SetSpinStatus(FSpinStatus.WAITING)
    self.isSpined = false
    
    local fuc = function ()
        self:GameState_EndDraw()
    end
    self.isToFreeEffect,self.inTospecialEffect = false,false
    if self:InGameFree() then
        if self.datas.freeSpinPacket.newFreeTime > 0 then
            self.isToFreeEffect = true
        elseif self.datas.freeSpinPacket.intoSpecial == 1 then
            self.inTospecialEffect = true
        end
    elseif self:InGameNormal() then
        if self.datas.normalPacket.intoFree > 0 then
            self.isToFreeEffect = true
        elseif self.datas.normalPacket.intoSpecial == 1 then
            self.inTospecialEffect = true
        end
    end
    --普通中奖免费  免费中奖免费播放音效
    if self.isToFreeEffect then
        FToolSet.PlayFGUISound(MusicCfg.feature_bell)
            StartOnceTimer(function ()
                FToolSet.PlayFGUISound(MusicCfg.SND_Scatter)
                fuc()
            end,2)
    elseif self.inTospecialEffect then
        FToolSet.PlayFGUISound(MusicCfg.feature_bell)
        StartOnceTimer(function ()
            fuc()
        end,2)
    else
        fuc()
    end
end
--绘制中奖线播放中奖动画 收分
function Game336:GameState_EndDraw()
    local second = self.slotContainers[self.curGameType]:DrawLineAndCollectScores()
    local intospecial_second = second > 2 and 2 or second 
   -- second = second < 2 and 1 or second
    --设置自动选择时间
    if FCasinoCtx.isAutoSpin or FCasinoCtx.curGameMode == FGameMode.FREE then
        print("设置自动延迟时间",second)
        self:SetAutoSpinSecond(second)
    end
    --进入特殊游戏前先收分2秒
    if self.inTospecialEffect then
        StartOnceTimer(function ()
            self:GameState_HandleSpecial()
        end,intospecial_second)
    else
        self:GameState_HandleSpecial()
    end
end
--处理特殊游戏
function Game336:GameState_HandleSpecial()
    --todo
    if FCasinoCtx.curGameMode == FGameMode.NORMAL then
        if self.datas.normalPacket.intoSpecial == 1 then
            self:EnterSpecialGame(true,self.datas.normalPacket)
            return
        end
    elseif FCasinoCtx.curGameMode == FGameMode.FREE then
        if self.datas.freeSpinPacket.intoSpecial == 1 then
            self:EnterSpecialGame(false,self.datas.freeSpinPacket)
            return
        end
    end
    self:GameState_HandleFreeTime()
end
function Game336:EnterSpecialGame(isNoramlType,spinData)
    FCasinoCtx:SetSpinStatus(FSpinStatus.SPIN)
    print("进入特殊游戏+++++++++++++++++++++++")
    local gametype = SlotType.Normal
    if not isNoramlType then
        self.tips:HideTips()
        gametype = SlotType.Free
    end
    local winCoin = self.slotContainers[gametype]:GetWinCoin()
    self:ChangeGameType(SlotType.TopupBouns)
        --停止中奖线动画 中奖线展示
    self:StopActionAndWinlines()
    self:StopAllcoin_sound_wincoin()
    --停止收分计时器
    if self.soundWinCoinEffectHandleTimer then
        StopTimer(self.soundWinCoinEffectHandleTimer)
        self.soundWinCoinEffectHandleTimer = nil
        self:ShowBottomWin(false,self._winCoin)
    end
    self.slotContainers[self.curGameType]:ResetDatas(true,3,winCoin)
    self.slotContainers[self.curGameType]:SetReelSymbolData(spinData.grids, 
                    function ()
                    end
                , true)
    self:SetTopupBounsCount(self.slotContainers[self.curGameType]:GetTopupBounsCount())
    self.topupBonusAnim:PlayTopupBonusAnim(function ()
            self:SetMidTips("tbStart")
            StartOnceTimer(function()
                self:SetMidTips("tb3")
                FCasinoCtx:SetSpinStatus(FSpinStatus.SPIN)
            end,1)
            self:DelayCallSpin(3)
    end)
end

--处理免费游戏
function Game336:GameState_HandleFreeTime()
    if FCasinoCtx.curGameMode == FGameMode.NORMAL then
        if self.datas.normalPacket.intoFree > 0 then
            StartOnceTimer(function ()
                self:EnterFreeGame()
            end,3)
            return
        end
        self:GameState_GameOver()
    elseif FCasinoCtx.curGameMode == FGameMode.FREE then
        local freedata = self.datas.freeSpinPacket
        if freedata and freedata.newFreeTime > 0 then
            self:AddFreeGame()
            return
        elseif freedata and freedata.totalCount >= freedata.allCount then
            print("免费游戏结束")
            self:SetMidTips("freeendbg")
            print("FCasinoCtx.curSpinStatus11",FCasinoCtx.curSpinStatus)
            self:GameState_GameOver(true)
            
            return
        end
        print("跳转免费游戏单轮结束FreeTime")
        self:GameState_SingleRoundFreeGameOver()
    end
    
end
--进入免费游戏
function Game336:EnterFreeGame()
    print("开始准备免费游戏滚动")
    self:ChangeBgm(MusicCfg.SND_Fea_BGM)
    --停止中奖线动画 中奖线展示
    self:StopActionAndWinlines()
    local winCoin = self.slotContainers[SlotType.Normal]:GetWinCoin()
    self.slotContainers[SlotType.Free]:InitIcondata()
    self.slotContainers[SlotType.Free]:ResetDatas(0,6,winCoin)
    self:SetMidTips("tbStart")
    FCasinoCtx:SetGameMode(FGameMode.FREE)
    FCasinoCtx:SetSpinStatus(FSpinStatus.SPIN)
    self:ChangeGameType(SlotType.Free)
    self:SetMidTips("freecount",1,6,1)
    self:DelayCallSpin(1)
end
--
function Game336:AddFreeGame()
    local allcount_ = self.datas.freeSpinPacket.allCount
    self:SetMidTips("freecount",self.datas.freeSpinPacket.totalCount, allcount_,allcount_ - 6)
    StartOnceTimer(function ()
        print("跳转免费游戏单轮结束AddFreeGa")
        self:GameState_SingleRoundFreeGameOver()
    end,1)
end
--免费游戏单轮结束
function Game336:GameState_SingleRoundFreeGameOver()
    print("免费游戏单轮结束")
    --StartOnceTimer(function ()
        FCasinoCtx:SetSpinStatus(FSpinStatus.SPIN)
        self:DelayCallSpin(self:GetAutoSpinSecond()+1)
    --end,1)
end
function Game336:GameState_FreeGameOver()
    local datapacket = self.datas.freeSpinPacket
    FCasinoCtx:SetPlayerMoneyInfo(datapacket)
    FCasinoCtx:SyncPlayerMoneyDisplay(2)
    StartOnceTimer(function ()
        self.tips:HideTips()
        self:ChangeBgm()
        --停止中奖线动画 中奖线展示
        self:StopActionAndWinlines()
        self:StopAllcoin_sound_wincoin()
        --停止收分计时器
        if self.soundWinCoinEffectHandleTimer then
            StopTimer(self.soundWinCoinEffectHandleTimer)
            self.soundWinCoinEffectHandleTimer = nil
            self:ShowBottomWin(false,self._winCoin)
        end
        local AllWinCoin = self._winCoin
        self._winCoin = 0
        FCasinoCtx.commonPanel:SetWinMoney(0)
        local second = self:ShowBottomWin(false,AllWinCoin)
        self:SetAutoSpinSecond(second)
        self:OnNormalSpinResult(self.datas.normalPacket,true,function () end)
        self.slotContainers[self.curGameType]:DrawLineAndCollectScores(true)
        FCasinoCtx:SetSpinStatus(FSpinStatus.SPIN)
        if FCasinoCtx.isAutoSpin then
            self:DelayCallSpin(self:GetAutoSpinSecond() + 1)
        end
    end,2)
end
--当前游戏一此完整的旋转结束
function Game336:GameState_GameOver(isfreeover)
    local datapacket = self.datas.normalPacket
    if FCasinoCtx.curGameMode == FGameMode.FREE then
        datapacket = self.datas.freeSpinPacket
    end
    
    if isfreeover then
        print("FCasinoCtx.curSpinStatus22",FCasinoCtx.curSpinStatus)
        FCasinoCtx:SetSpinStatus(FSpinStatus.STOP)
        self.free_playCaijinAnimCallBack = function ()
            datapacket = self.datas.freeSpinPacket
            self.tips:HideTips()
            self:ChangeBgm()
            --停止中奖线动画 中奖线展示
            self:StopActionAndWinlines()
            self:StopAllcoin_sound_wincoin()
            --停止收分计时器
            if self.soundWinCoinEffectHandleTimer then
                StopTimer(self.soundWinCoinEffectHandleTimer)
                self.soundWinCoinEffectHandleTimer = nil
                self:ShowBottomWin(false,self._winCoin)
            end
            local AllWinCoin = self._winCoin
            self._winCoin = 0
            FCasinoCtx.commonPanel:SetWinMoney(0)
            print("FCasinoCtx.curSpinStatus333",FCasinoCtx.curSpinStatus)
            local second = self:ShowBottomWin(false,AllWinCoin)
            self:SetAutoSpinSecond(second)
            print("FCasinoCtx.curSpinStatus444",FCasinoCtx.curSpinStatus)
            self:OnNormalSpinResult(self.datas.normalPacket,true,function () end)
            print("FCasinoCtx.curSpinStatus555",FCasinoCtx.curSpinStatus)
            self.slotContainers[self.curGameType]:DrawLineAndCollectScores(true)
            FCasinoCtx:SetPlayerMoneyInfo(datapacket)
            FCasinoCtx:SyncPlayerMoneyDisplay(2)
            FCasinoCtx:SetSpinStatus(FSpinStatus.SPIN)
            StartOnceTimer(function ()
                if FCasinoCtx.isAutoSpin then
                    self:DelayCallSpin(self:GetAutoSpinSecond() + 1)
                end
            end,1)
        end
        self.free_playCaijinAnimTimer =  StartOnceTimer(function ()
            self.free_playCaijinAnimTimer = nil
            self.free_playCaijinAnimCallBack()
            self.free_playCaijinAnimCallBack = nil
            return
        end,self:GetAutoSpinSecond()+0.2)

    else
        FCasinoCtx:SetPlayerMoneyInfo(datapacket)
        FCasinoCtx:SyncPlayerMoneyDisplay(2)
        FCasinoCtx:SetSpinStatus(FSpinStatus.WAITING)
        if FCasinoCtx.isAutoSpin then
            FCasinoCtx:SetSpinStatus(FSpinStatus.SPIN)
            print("self:GetAutoSpinSecond() ",self:GetAutoSpinSecond() )
            self:DelayCallSpin(self:GetAutoSpinSecond() + 1)
        else
            StartOnceTimer(function ()
                FCasinoCtx:SetSpinStatus(FSpinStatus.SPIN)
            end,1)
        end
    end
end
-- @brief 处理免费游戏旋转结果
-- @param quickSet 直接设置跳过动画
function Game336:OnFreeSpinResult(spinData, quickSet, callback)
    self:ChangeGameType(SlotType.Free)
    dump(spinData,"spinData")
    if quickSet then
        self.slotContainers[self.curGameType]:SetOpen(true)
    else
        self.slotContainers[self.curGameType]:HandleWinDatas(spinData.lines)
        self.slotContainers[self.curGameType]:SetIsEnterFree(spinData.newFreeTime > 0)
        self.slotContainers[self.curGameType]:SetIsEnterTopupBouns(spinData.intoSpecial == 1)
    end
    self.slotContainers[self.curGameType]:HandleCellDatas(spinData.grids)
    self.slotContainers[self.curGameType]:SetReelSymbolData(function(second)
        self.isSpined = false
        if callback then
            callback()
            return
        end
        print("免费游戏次数",self.datas.freeSpinPacket.totalCount," ",self.datas.freeSpinPacket.allCount)
        print("免费游戏newFreeTime",self.datas.freeSpinPacket.newFreeTime)
        --self:SetMidTips("freecount",self.datas.freeSpinPacket.totalCount,
        --self.datas.freeSpinPacket.allCount - self.datas.freeSpinPacket.newFreeTime)
        self.slotContainers[self.curGameType]:SetAllTurns(spinData.allCount)
        StartOnceTimer(function ()
            self:SpinEndCallFunc()
        end,0.5)
        -- 免费结束
    --     local isEnd = spinData.totalCount >= spinData.allCount
    --     if isEnd then
    --         print("免费结束")
    --         self:SetMidTips("freeendbg")
    --     end
    --     --FCasinoCtx:SetSpinStatus(FSpinStatus.SPIN)
    --     self.playCaijinAnimCallBack = function ()
    --         if isEnd then
    --             if spinData.intoSpecial == 0 then
    --                 self:StopNormalAction()
    --                 self.slotContainers[SlotType.Normal]:HandleCellDatas(self.datas.normalPacket.grids)
    --                 self.slotContainers[SlotType.Normal]:SetReelSymbolData(
    --                     function ()
    --                         FCasinoCtx:SetSpinStatus(FSpinStatus.WAITING)
    --                     end
    --                 , true)
    --                 self:ChangeGameType(SlotType.Normal)
    --                 StartOnceTimer(
    --                     function ()
    --                         FCasinoCtx:SetSpinStatus(FSpinStatus.STOP)
    --                         self._winCoin = 0
    --                         FCasinoCtx.commonPanel:SetWinMoney(0)
    --                         local second = self:ShowBottomWin(false,spinData.bonusWinCoin)
    --                         self.playCaijinAnimCallBack = function ()
    --                             if FCasinoCtx.isAutoSpin then
    --                                 self:DelayCallSpin(4)
    --                             end
    --                             FCasinoCtx:SetSpinStatus(FSpinStatus.SPIN)
    --                             FCasinoCtx.commonPanel:StopScrollMoney(nil, true)
    --                         end
    --                         self.playCaijinAnimTimer = StartOnceTimer(
    --                             function ()
    --                                 self.playCaijinAnimTimer = nil
    --                                 if self.playCaijinAnimCallBack then
    --                                     self.playCaijinAnimCallBack()
    --                                     self.playCaijinAnimCallBack = nil
    --                                 end
    --                                 return
    --                             end,
    --                         second)
    --                         FCasinoCtx:SetPlayerMoneyInfo(spinData)
    --                         FCasinoCtx:SyncPlayerMoneyDisplay(second)
    --                     end,
    --                 0.01)
    --             end
    --             self:ChangeBgm()
    --         else
    --             if spinData.intoSpecial == 0 then
    --                 self:DelayCallSpin(4)
    --                 FCasinoCtx:SetSpinStatus(FSpinStatus.SPIN)
    --             end
    --         end
    --         if spinData.intoSpecial == 1 then -- 免中落地牌
    --             FToolSet.PlayFGUISound(MusicCfg.feature_bell)
    --             self.tips:HideTips()
    --             self:ChangeGameType(isEnd and SlotType.TopupBouns or SlotType.FreeTopupBouns)
    --             self:StopFreeAction()
    --             self.slotContainers[self.curGameType]:ResetDatas(true,3,self.slotContainers[self.curGameType]:GetWinCoin())
    --             self.slotContainers[self.curGameType]:SetReelSymbolData(spinData.grids, 
    --                 function ()
    --                     FCasinoCtx:SetSpinStatus(FSpinStatus.WAITING)
    --                 end
    --             , true)
    --             self:SetTopupBounsCount(self.slotContainers[self.curGameType]:GetTopupBounsCount())
    --             --StartOnceTimer(function()
    --                 self.topupBonusAnim:PlayTopupBonusAnim(function ()
    --                     self:SetMidTips("tbStart")
    --                     StartOnceTimer(function()
    --                         self:SetMidTips("tb3")
    --                         FCasinoCtx:SetSpinStatus(FSpinStatus.SPIN)
    --                     end,1)
    --                     -- 计时器自动旋转 落地牌
    --                     FCasinoCtx:SetSpinStatus(FSpinStatus.WAITING)
    --                     self:DelayCallSpin(4)
    --                 end)
    --            -- end, 2)
    --         end
    --     end
    --     self.playCaijinAnimTimer = StartOnceTimer(
    --         function ()
    --             self.playCaijinAnimTimer = nil
    --             self.playCaijinAnimCallBack()
    --             self.playCaijinAnimCallBack = nil
    --             return
    --         end,
    --     second)
    end, quickSet)
end

-- @brief 处理特殊游戏旋转结果
-- @param quickSet 直接设置跳过动画
function Game336:OnSpecialSpinResult(spinData, quickSet, customCallback)
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
            --新加巨奖弹窗
            local bigGrandWin = spinData.bonusWinCoin
            local winCoin = self.slotContainers[self.curGameType]:GetWinCoin()
            bigGrandWin = bigGrandWin - winCoin
            for _, cell in ipairs(spinData.grids) do
                bigGrandWin = bigGrandWin - cell.SymbolValue
            end
            self:PlayBigGrandWin(bigGrandWin,function () -- 3 秒
                self.tips:PlayTopAnim(nil,FToolSet.NumToStr(bigGrandWin))
            end)
        end
        if num > 0 then
            FCasinoCtx:SetSpinStatus(FSpinStatus.SPIN)
            self:DelayCallSpin(5)
            self:SetMidTips("tb"..num)
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
                               -- FToolSet.PlayFGUISound(MusicCfg.SND_Fea_End)
                                print("spinData.AllWinCoin ",spinData.AllWinCoin)
        
                                local second = self:ShowBottomWin(false,spinData.AllWinCoin)
                                self:SetTopupBounsCount(0)
                                self.playCaijinAnimCallBack = function ()
                                    local curTurn = self.slotContainers[SlotType.Free]:GetCurTurn()
                                    local allTurns = self.slotContainers[SlotType.Free]:GetAllTurns()
                                    print("curTurn",curTurn , " allTurns ",allTurns , "  self.curGameType ",self.curGameType)
                                    if curTurn ~= allTurns then
                                        -- FCasinoCtx:SetGameMode(FGameMode.FREE)
                                        print("特殊游戏切换到免费游戏")
                                        self.slotContainers[SlotType.Free]:ResetDatas(curTurn,allTurns,spinData.AllWinCoin)
                                        self.tips:HideTips()
                                        self:SetMidTips("freecount",curTurn,allTurns)
                                        self:OnFreeSpinResult(self.datas.freeSpinPacket, true, function () end)
                                        self.slotContainers[SlotType.Free]:DrawLineAndCollectScores(true)
                                        self:DelayCallSpin(1.5)
                                        self:ChangeBgm(MusicCfg.SND_Fea_BGM)
                                        -- self:StopFreeAction()
                                        -- self.slotContainers[SlotType.Free]:HandleCellDatas(self.datas.freeSpinPacket.grids)
                                        -- self.slotContainers[SlotType.Free]:SetOpen(true)
                                        -- self.slotContainers[SlotType.Free]:SetReelSymbolData(nil, true)
                                        -- self:ChangeGameType(SlotType.Free)
                                    else
                                        print("特殊游戏切换到普通游戏")
                                        FCasinoCtx:SetPlayerMoneyInfo(spinData)
                                        FCasinoCtx:SyncPlayerMoneyDisplay(2)
                                        -- FCasinoCtx:SetGameMode(FGameMode.NORMAL)
                                        if FCasinoCtx.isAutoSpin then
                                            self:DelayCallSpin(1.5)
                                        end
                                        self:OnNormalSpinResult(self.datas.normalPacket, true, function () end,spinData.AllWinCoin)
                                        self.slotContainers[SlotType.Normal]:DrawLineAndCollectScores(true)
                                        -- self:StopNormalAction()
                                        -- self.slotContainers[SlotType.Normal]:SetOpen(true)
                                        -- self.slotContainers[SlotType.Normal]:HandleCellDatas(self.datas.normalPacket.grids)
                                        -- self.slotContainers[SlotType.Normal]:SetReelSymbolData(nil, true,spinData.AllWinCoin)
                                        -- self:ChangeGameType(SlotType.Normal)
                                        self.tips:HideTips()
                                    end
                                    StartOnceTimer(function ()
                                        FCasinoCtx:SetSpinStatus(FSpinStatus.SPIN)
                                    end,1)
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

-- 自动旋转
function Game336:DelayCallSpin(delay,cb)
    print("自动旋转延迟",delay)
    self:StopDelayCallSpin()
    self.callSpinTimer = StartOnceTimer(function()
        if cb then
            cb()
        end
        FCasinoCtx:SimulateSpinClick()
    end, delay)
end

function Game336:StopDelayCallSpin()
    if self.callSpinTimer then
        StopTimer(self.callSpinTimer)
        self.callSpinTimer = nil
    end
end

-- 播放中奖连线
function Game336:PlayLines(lines)
    if not next(lines) then
        return
    end
    local index = 1
    self.wildeffect = nil
    
    self.winLines:PlayLine(lines[1])
    for _, line in ipairs(lines) do
        if line.sound then
            self.wildeffect = FToolSet.PlayFGUISound(line.sound)
            break
        end
    end
    FTween.Start(self.winLines.parent,
        FTween.RepeatForever(
            {
                FTween.Delay(2, function()
                    if index ~= 0 then
                        self.winLines:StopLine(lines[index])
                    end
                    index = index + 1
                    if index > #lines then
                        index = 1
                    end
                    self.winLines:PlayLine(lines[index])
                end)
            }    
        )
    )
    self.lineTimer = StartTimer(
        function ()

        end
    , 2)
end

-- 隐藏中奖连线
function Game336:StopLines()
    if self.lineTimer then
        StopTimer(self.lineTimer)
        self.lineTimer = nil
    end
    FTween.KillTweens(self.winLines.parent)
    for i = 1, 25 do
        self.winLines:StopLine(i)
    end
end

-- 特殊游戏中间提示
function Game336:SetMidTips(imageUrl,curturn,allturns,oldturns)
    self.tips:ShowTips(imageUrl,curturn,allturns,oldturns)
end

-- 转换游戏类型
function Game336:ChangeGameType(slotType)
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
function Game336:StopActionAndWinlines()
    if FCasinoCtx.curGameMode == FGameMode.NORMAL then
        self.slotContainers[SlotType.Normal]:RemoveTopSymbol()
    elseif FCasinoCtx.curGameMode == FGameMode.FREE then
        self.slotContainers[SlotType.Free]:RemoveTopSymbol()
    end
    self:StopLines()
end
-- 停止普通游戏的动画和中奖线
function Game336:StopNormalAction()
    self.slotContainers[SlotType.Normal]:RemoveTopSymbol()
    self:StopLines()
end

-- 停止免费游戏的动画和中奖线
function Game336:StopFreeAction()
    self.slotContainers[SlotType.Free]:RemoveTopSymbol()
    self:StopLines()
    
end

-- 落地牌拥有数量
function Game336:SetTopupBounsCount(count)
    if count == 0 then
        self:ChangeBgm()
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

function Game336:ShowBottomWin(quickSet,winCoin)
     -- print("self.curGameType: ",self.curGameType)
     local winCoin = winCoin or self.slotContainers[self.curGameType]:GetWinCoin()
     local second = 0.01
     if not quickSet then
         local lastWinCoin = self._winCoin
         local addCoin = winCoin - lastWinCoin
         local multiply = string.format("%.5f", (addCoin / FCasinoCtx.commonPanel:GetBetMoney()))
         multiply = tonumber(multiply)
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
                    print("赢分音效播放结束") 
                     self.soundWinCoinEffectHandleTimer = nil
                 end
             ,second)
 
             if multiply >= 10 then -- 较大价值奖励抛金币
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

function Game336:ChangeBgm(url)
    if self.soundBgm == url then
        return
    end
    if self.soundBgmHandle then
        APIGateway.StopSound(self.soundBgmHandle)
        self.soundBgmHandle = nil
        self.soundBgm = nil
    end
    if not url then
        return
    end
    self.soundBgmHandle = FToolSet.PlayFGUISound(url,true)
    self.soundBgm = url
end

function Game336:PlayBigGrandWin(winNum,cb)
    self.bigGrand.visible = true
    local caijin = self.bigGrand:GetChild("caijin")
    caijin.text = FToolSet.NumToStr(winNum)
    self.bigGrand:GetTransition("t0"):Play(function()
        if cb then
            cb()
        end
    end)
end 
return Game336