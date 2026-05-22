local Utils             = Import(".Slot.Utils")
local BigWin            = Import(".Slot.BigWin")
local GameDefine        = Import(".GameDefine")
local NormalSlot        = Import(".Slot.NormalSlot")
local SymbolConfig      = Import(".Slot.SymbolConfig")
local TipInfoComp       = Import(".Slot.TipInfoComp")
local AwardsHistoryPanel = Import(".Slot.AwardsHistoryPanel")


local Game481 = Class("Game481", BaseGame)

function Game481:ctor(render)
    self.render = render

    self.slot = self.render:GetChild("slot")

    self.awardsHistoryPanel = AwardsHistoryPanel.New(self.render:GetChild("awardsHistory"), self)


    self.slotContainer = {}
    self.slotContainer[FGameMode.NORMAL] = NormalSlot.New(self.slot:GetChild("normal"), false)
    self.slotContainer[FGameMode.FREE] = NormalSlot.New(self.slot:GetChild("free"), true)

    self.slotEffectLayer = self.slot:GetChild("effectLayer")

    self.freeRemainCountLabel = self.render:GetChild("freeSpinsLeft"):GetChild("free-remain-count")
    self.totalMultiplierLabel = self.render:GetChild("totalMultiplier"):GetChild("multi-label")

    self.tipComp = self.render:GetChild("tipComp")
    self.tipInfo = TipInfoComp.New(self.tipComp)
    self.tipInfo:RandomNormalSpinTipAndAni()
    
    

    self:SetGameMode(FGameMode.NORMAL)

    self:ResetFreeRemainCountView()

    -- self:ResetScoreLabel()

    self.HasJpInCurSpinFirstGrids = false

    self.HasJpInCurRefillGrids = false

    self.totalMultiplierCount = 0
    
    -- TEST:
    
    --
end


function Game481:GetEffectLayerChildren()
    local res = {}
    for i = 0, self.slotEffectLayer.numChildren - 1 do
        local child = self.slotEffectLayer:GetChildAt(i)
        table.insert(res,child)
    end
    return res
end


-- function Game481:ResetScoreLabel()
    
--     self:SetScoreLabelView(0)

-- end


function Game481:PlayZeusMultiNotifyAnim()
    Utils.PlaySound("ui://Game481/multiple_"..math.random(1,10))
    local zeusMultiNotify = self.render:GetTransition("zeus-multi-notify")
    zeusMultiNotify:Play()
end

function Game481:PlayZeusMultiNotifyEndAnim()
    local zeusMultiNotify = self.render:GetTransition("zeus-multi-notify-end")
    zeusMultiNotify:Play()
end


function Game481:SetScoreLabelView(val,duration)

    Utils.ScrollBottomWinMoneyTo(val, durantion)
end


function Game481:ResetFreeRemainCountView()
    self.freeRemainCountLabel.visible = true
end

Game481.curSpinAccumulatedWin = 0
Game481.curAccumulatedWinInFree = 0


function Game481:__delete()
    self:Clear()

    for k, v in pairs(self.slotContainer) do
        v:Delete()
    end

    Utils.ClearAllTimeouts()

    if self.BigWinAnim then
        self.BigWinAnim:Delete()
    end

    if self.resultTweener then
        self.resultTweener:Kill()
        self.resultTweener = nil
    end

    if self.enterDelayTimer then
        StopTimer(self.enterDelayTimer)
        self.enterDelayTimer = nil
    end

    if self.tipInfo then
        self.tipInfo:Delete()
    end
    
end


-- @interface
-- @brief update
function Game481:Update(dt)
    Game481.super.Update(self, dt)

    for k, v in pairs(self.slotContainer) do
        v:Update(dt)
    end
end

function Game481:Clear()
    FCasinoCtx.commonPanel:ShowTop(true, false)
    self:StopDelayCallSpin()
end

function Game481:SetTotalWin(value)
    self:SetWinMoney(value,false)
end

-- 当前spin的赢钱
function Game481:ShowTotalWin(curWinCoin, multiCount, callback)

    -- if true then return end
    local lastWin = 0

    if FCasinoCtx.curGameMode == FGameMode.FREE then
        lastWin = FCasinoCtx:GetGame().curAccumulatedWinInFree
    else
        lastWin = FCasinoCtx:GetGame().curSpinAccumulatedWin
    end

    local diffScore = lastWin - curWinCoin

    local function delayNext(time)
        print("Game481:ShowTotalWin >>> delayNext >>> time >>> "..time)
        Utils.SetTimeout(function()
            if callBack then
                callBack()
            end
        end,time,self.render)
    end
    
    if multiCount >= 15 then
        if not self.BigWinAnim then
            self.BigWinAnim = BigWin.New(self)
        end

        self:FlowAniCountAdd()
        -- Utils.ScrollBottomWinMoneyTo(curWinCoin,.2,function()
            self.BigWinAnim:PlayScoreAnim(curWinCoin, function()
                print("Game481:ShowTotalWin >>> self.BigWinAnim:PlayScoreAnim >>> Complete")
                self:SetWinMoney(lastWin)
                self:FlowAniCountSub()
                delayNext(2)
            end)
        -- end)
    else
        delayNext(1)
    end

end

function Game481:SetFreeRemainCountLabel(count)
    self:ResetFreeRemainCountView()
    self.freeRemainCountLabel.text = tostring(count)
end


function Game481:UpdateFreeRemainCountLabel()
    local curRemainCount = self.remainFreeTime
    if curRemainCount > 0 then
        curRemainCount = curRemainCount - 1
    end
    self:SetFreeRemainCountLabel(curRemainCount)
end


-- @brief 弹出
function Game481:ShowEnterFreePanel(addFreeTime, isFreeInFree)
    self.frameWaitSoundHandler = Utils.PlaySound("ui://Game481/frame_wait")
    FCasinoCtx:SetSpinStatus(FSpinStatus.WAITING)

    if not self.enterFreePanel then
        self.enterFreePanel = FairyGUI.UIPackage.CreateObject("Game481", "EnterFreePanel")
        Utils.AddToTopEffectLayerAndMakeFullScreen(self.enterFreePanel)
    end

    local addFreeTimeStr = tostring(addFreeTime)
    self.enterFreePanel:GetChild("count-label").text = isFreeInFree and "+" .. addFreeTimeStr or addFreeTimeStr
    self.enterFreePanel.visible = true
    self.enterFreePanel:GetTransition("start"):Play()
    
    -- self:SetGameMode(FGameMode.FREE)

    -- self:SetFreeRemainCountLabel(addFreeTime)
    self:SetFreeRemainCountLabel(self.remainFreeTime)

    local hasClickStart = false
    local function onStartBtnClick(btn)
        if hasClickStart then return end
        if not hasClickStart then
            hasClickStart = true
        end

        Utils.PlaySound("ui://Game481/Free_Start_Button")

        Utils.ClearTimeout(self.enterFreePanel)

        Utils.StopSound(self.frameWaitSoundHandler) 
        self.enterFreePanel:GetTransition("exit"):Play(function()
            self.enterFreePanel.visible = false

            FCasinoCtx:SetSpinStatus(FSpinStatus.SPIN)
            self:SetGameMode(FGameMode.FREE)
            self:AutoClick()

        end)
    end

    local btn = self.enterFreePanel:GetChild("startBtn")
    btn.enabled = true
    Utils.AddClickEvent(btn, function()
        onStartBtnClick(btn)
    end)

    local delayTime = isFreeInFree and 3 or 5
    Utils.SetTimeout(function()
        onStartBtnClick(btn)
    end, delayTime, self.enterFreePanel)

end


function Game481:ShowFreeTotalSettlement(freeTotalWinCoin)
    self.frameWaitSoundHandler = Utils.PlaySound("ui://Game481/freegame_end")
    -- print("ShowFreeTotalSettlement")
    -- local value = FCasinoCtx:GetGame().curAccumulatedWinInFree
    local value = freeTotalWinCoin
    -- spin按钮置为等待状态
    FCasinoCtx:SetSpinStatus(FSpinStatus.WAITING)
    if not self.result then
        self.result = FairyGUI.UIPackage.CreateObject("Game481", "FreeGameResult")
        Utils.AddToTopEffectLayerAndMakeFullScreen(self.result)
    end
    
    self.result.visible = true
    self.result:GetTransition("start"):Play()
    
    local function nextStep()
        Utils.StopSound(self.frameWaitSoundHandler)
        Utils.ClearTimeout(self.result)
        
        self.slotContainer[FGameMode.FREE]:ShowAllGrids()

        self.result:GetTransition("exit"):Play(function()
            self.result.visible = false
            self:ResetFreeRemainCountView()
    
            FCasinoCtx:SyncPlayerMoneyDisplay(2)
            FCasinoCtx:SetSpinStatus(FSpinStatus.SPIN)
            self:SetGameMode(FGameMode.NORMAL)
            -- self:HideAllChildrenInEffectLayer()
            self:SetScoreLabelView(value)
            self.tipInfo:SwitchController(true)
            self.awardsHistoryPanel:ClearView()
            self.totalMultiplierLabel.text = ""
    
            FCasinoCtx:GetGame().curAccumulatedWinInFree = 0
            FCasinoCtx:GetGame().totalMultiplierCount = 0
    
            self:AutoClick()

        end)

    end

    local scoreLabel = self.result:GetChild("count-label")
    scoreLabel.text = Utils.ConvertScoreToRealVisual(value)

    if self.soundTotalWin then
        APIGateway.StopSound(self.soundTotalWin)
        self.soundTotalWin = nil
    end

    Utils.PlaySound("ui://Game481/bgm_totalwin_end")

    local hasClick = false
    Utils.AddClickEvent(self.result, function()
        if hasClick then return end
        if not hasClick then hasClick = true end
        nextStep()
    end)

    Utils.SetTimeout(function()
        nextStep()
    end,5,self.result)
    
    self.soundTotalWin = Utils.PlaySound("ui://Game481/bgm_totalwin_main")

end


function Game481:SetGameMode(mode)
    FCasinoCtx:SetGameMode(mode)
    self.curSlotType = mode

    local bgmUrl = mode == FGameMode.FREE and "ui://Game481/fg_free" or "ui://Game481/fg_normal"
    Utils.PlayBGM(bgmUrl)

    self.render:GetController("c1").selectedPage = mode == FGameMode.FREE and "free" or "normal"
    self.slot:GetController("c1").selectedPage = mode == FGameMode.FREE and "free" or "normal"
end


function Game481:SetWinMoney(value,rolling)
    FCasinoCtx.commonPanel:SetWinMoney(value,rolling)
end

-- @interface
-- @brief 在游戏中断线重连恢复游戏
-- @param msg 断线重连数据
function Game481:ReconnectRecoveryGame(msg, isInitialize)
    -- 断线重连标记
    self.isReconnect = true
    -- dump(msg,"msg",10)
    local currentWinCoin = msg.currentWinCoin
    -- print("Game481:ReconnectRecoveryGame>>>>>>>>> currentWinCoin  "..currentWinCoin)
    self:SetTotalWin(currentWinCoin)
    if msg.status == 1 then
        self.isRecoveryIntoFree = msg.resumedNormal.normalSpin.intoFree == 1
        if self.isRecoveryIntoFree then

            -- FCasinoCtx:GetGame().curAccumulatedWinInFree = FCasinoCtx:GetGame().curAccumulatedWinInFree + currentWinCoin
            FCasinoCtx:GetGame().curAccumulatedWinInFree = currentWinCoin

            self.remainFreeTime = GameDefine.INITIAL_FREE_COUNT_IN_FREE_GAME
            self:SetGameMode(FGameMode.FREE)
            -- FCasinoCtx.commonPanel:ShowCustomPanel(true)
            self.slotContainer[FGameMode.FREE]:SetReelSymbolData(msg.resumedNormal.normalSpin, true)
            FToolSet.PlayBGM("ui://Game481/bgm_fs")
            
            FCasinoCtx:SetSpinStatus(FSpinStatus.SPIN)
            self:AutoClick()
        else
            self:OnNormalSpinResult(msg.resumedNormal.normalSpin)
            FToolSet.PlayBGM("ui://Game481/bgm_mg")
        end
    elseif msg.status == 2 then

        -- if not isInitialize then self.CacheReconnectMsg = clone(msg) end
        local remainFreeTime = msg.resumedFree.freeSpin.totalFreeTime - msg.resumedFree.freeSpin.freeTime
        local accuScale = msg.resumedFree.freeSpin.AccuScale
        if isInitialize then
            FCasinoCtx:GetGame().totalMultiplierCount = accuScale
        end
        self.remainFreeTime = remainFreeTime
        local isInFree = remainFreeTime ~= 0
        if isInFree then
            FCasinoCtx:GetGame():UpdateMultiCountLabel(FCasinoCtx:GetGame().totalMultiplierCount)
            if isInitialize then
                FCasinoCtx:GetGame().curAccumulatedWinInFree = FCasinoCtx:GetGame().curAccumulatedWinInFree + currentWinCoin
            end
            self:SetGameMode(FGameMode.FREE)
            self.slotContainer[FGameMode.NORMAL]:SetReelSymbolData(msg.resumedNormal.normalSpin, true,nil,true)
            self:OnFreeSpinResult(msg.resumedFree.freeSpin)
            self:UpdateFreeRemainCountLabel()
            FToolSet.PlayBGM("ui://Game481/bgm_fs")
        else
            print(">>>>>>>>>>>>>>>>>>>>>>>> 481 断线重连恢复游戏  status == 2")
            self:SetGameMode(FGameMode.NORMAL)
            FCasinoCtx:SetSpinStatus(FSpinStatus.SPIN)
            FCasinoCtx:GetGame().curAccumulatedWinInFree = 0
            FCasinoCtx:GetGame().totalMultiplierCount = 0
            self.totalMultiplierLabel.text = ""
            self.totalMultiplierLabel.visible = true

            self:AutoClick()
        end
    end
    self.isReconnect = false
end

-- @interface
-- @brief 点击开始按钮
function Game481:OnClickSpin()

    -- Check can spin
    local canSpin = true
    local curSlotContainer = nil
    if FCasinoCtx.curGameMode == FGameMode.NORMAL then
        curSlotContainer = self.slotContainer[FGameMode.NORMAL]
    elseif FCasinoCtx.curGameMode == FGameMode.FREE then
        curSlotContainer = self.slotContainer[FGameMode.FREE]
    end

    if not curSlotContainer then return end

    local reels = curSlotContainer.reels
    for k, v in pairs(reels) do
        local isFreeState = v:IsFreeState()
        if not isFreeState then
            canSpin = false
            break
        end
    end

    if not canSpin then return end
    --

    Utils.PlaySound("ui://Game481/start")

    FCasinoCtx:GetGame().curSpinAccumulatedWin = 0
    self:ResetFlowAniData()
    -- self:HideAllChildrenInEffectLayer()
    self:StopDelayCallSpin()
    self:ResetAwardHistoryView()
    self.tipInfo:SetTipScoreView(0)
    self.tipInfo:SwitchController(true)

    if FCasinoCtx.curGameMode == FGameMode.NORMAL then
        FCasinoCtx:GetGame().totalMultiplierCount = 0
        if not FCasinoCtx:PlayerSpinConsumption() then
            return
        end

        self.slotContainer[FGameMode.NORMAL]:SpinStart()
        self.slotContainer[FGameMode.NORMAL]:ResetAllSymbols()

        self:SetTotalWin(0)
            
        
        self:SendNormalSpin("PB.Client_Slots.GatesOfOlympusNormalSpin", "PB.Slots_Client.GatesOfOlympusNormalRet", function(ok, result)
            if not ok then return end
            self:OnNormalSpinResult(result.normalSpin)
        end)
        
    elseif FCasinoCtx.curGameMode == FGameMode.FREE then
        self:UpdateFreeRemainCountLabel()

        self.slotContainer[FGameMode.FREE]:SpinStart()
        self.slotContainer[FGameMode.FREE]:ResetAllSymbols()

        local request = {
            _msgName_ = "PB.Client_Slots.GatesOfOlympusFreeSpin"
        }
        APIGateway.SendExactRequest(request, "PB.Slots_Client.GatesOfOlympusFreeRet", function(ok, result)
            if not ok then return end
            self:OnFreeSpinResult(result.freeSpin)
        end)
    end

end


function Game481:OnClickStop()
    -- 普通游戏状态点击停止按钮
    if FCasinoCtx.curGameMode == FGameMode.NORMAL then
        self.slotContainer[self.curSlotType]:QuickStop()
    elseif FCasinoCtx.curGameMode == FGameMode.FREE then
        self.slotContainer[self.curSlotType]:QuickStop()
        -- self:StopSettlement()
    end
end


-- @brief 处理普通旋转结果
function Game481:OnNormalSpinResult(spinData)

    local isReconnect = self.isReconnect
    -- 当前正在运行的数据和断线重连下发的数据一样，直接忽略
    if isReconnect and table.equals(spinData, self.curNormalSpinResult) then
        return
    end
    
    self.curNormalSpinResult = spinData

    local isIntoFree = spinData.intoFree == 1
    self.isCurNormalSpinResIntoFree = isIntoFree

    if self.isReconnect then
        isIntoFree = self.isRecoveryIntoFree
    end

    local initialFreeTime = 0
    if isIntoFree then
        initialFreeTime = GameDefine.INITIAL_FREE_COUNT_IN_FREE_GAME
        self.remainFreeTime = initialFreeTime
        self:SetFreeRemainCountLabel(initialFreeTime)
        FCasinoCtx:SetSpinStatus(FSpinStatus.WAITING)
    end

    -- 清理所有界面
    self:Clear()

    self:SetGameMode(FGameMode.NORMAL)

    -- 进免费同步普通slot图案至免费slot
    if isIntoFree then 
        self.slotContainer[FGameMode.FREE]:SetReelSymbolData(spinData, true)
    end
    
    local doWhenSetReelSymbolCompelte = function()
        -- print("doWhenSetReelSymbolCompelte>>>>>>>>>>>>>>>>>>>>>")
        Utils.ScrollBottomWinMoneyTo(spinData.winCoin,0.2)
        if isIntoFree then
            Utils.PlaySound("ui://Game481/free_spin")
            -- 显示进免费,sc动画
            -- FCasinoCtx:GetGame().curAccumulatedWinInFree = FCasinoCtx:GetGame().curAccumulatedWinInFree + FCasinoCtx:GetGame().curSpinAccumulatedWin
            FCasinoCtx:GetGame().curAccumulatedWinInFree = FCasinoCtx:GetGame().curAccumulatedWinInFree + spinData.winCoin
            self.slotContainer[self.curSlotType]:ShowIntoFreeSCAnimation()
            self.enterDelayTimer = StartOnceTimer(function()
                -- self:SetGameMode(FGameMode.FREE)
                Utils.PlaySound("ui://Game481/frame_appear")
                self:ShowEnterFreePanel(initialFreeTime)
                StopTimer(self.enterDelayTimer)
                self.enterDelayTimer = nil
            end, 2)

        else

            FCasinoCtx:SetPlayerMoneyInfo(spinData)
            FCasinoCtx:SyncPlayerMoneyDisplay(2)
            FCasinoCtx:SetSpinStatus(FSpinStatus.SPIN)
            self:AutoClick()

        end
    end

    self.slotContainer[self.curSlotType]:SetReelSymbolData(
        spinData,
        isReconnect,
        function()

            if self:DoesFlowAniPlayComplete() then
                doWhenSetReelSymbolCompelte()
            else
                self:StuckedFnTableAdd(doWhenSetReelSymbolCompelte)
            end

        end
    )

end


Game481.StuckedFnTable = {}
Game481.curFlowAniPlayingCount = 0
function Game481:DoesFlowAniPlayComplete()
    return Game481.curFlowAniPlayingCount == 0
end
function Game481:FlowAniCountAdd()
    print("Game481:FlowAniCountAdd >>> "..tostring(Game481.curFlowAniPlayingCount))
    Game481.curFlowAniPlayingCount = Game481.curFlowAniPlayingCount + 1
end
function Game481:FlowAniCountSub()
    print("Game481:FlowAniCountSub >>> "..tostring(Game481.curFlowAniPlayingCount))
    Game481.curFlowAniPlayingCount = Game481.curFlowAniPlayingCount - 1
    if Game481.curFlowAniPlayingCount < 0 then Game481.curFlowAniPlayingCount = 0 end
    if Game481.curFlowAniPlayingCount == 0 then
        self:StuckedFnTableDo()
    end
end
function Game481:StuckedFnTableAdd(fn)
    print("Game481:StuckedFnTableAdd >>>>>>> ")
    table.insert(Game481.StuckedFnTable, fn)
end
function Game481:StuckedFnTableDo()
    print("Game481:StuckedFnTableDo >>>>>>>>")
    for _, fn in ipairs(Game481.StuckedFnTable) do
        fn()
    end
end
function Game481:ResetFlowAniData()
    print("Game481:ResetFlowAniData >>>>>>>>".. tostring(#Game481.StuckedFnTable))
    for _, fn in ipairs(Game481.StuckedFnTable) do
        fn = nil
    end
    Game481.StuckedFnTable = {}
    Game481.curFlowAniPlayingCount = 0
end



-- @brief 处理免费游戏旋转结果
function Game481:OnFreeSpinResult(spinData)

    -- print("OnFreeSpinResult>>>>>>>>>>>>>")

    local isReconnect = self.isReconnect
    -- 当前正在运行的数据和断线重连下发的数据一样，直接忽略
    if isReconnect and table.equals(spinData, self.curFreeSpinResult) then
        return
    end

    self.curFreeSpinResult = spinData
    -- 清理所有界面
    self:Clear()
    self:SetGameMode(FGameMode.FREE)

    local accuScale = spinData.AccuScale
    local remainFreeTime = spinData.totalFreeTime - spinData.freeTime
    local totalFreeTime = spinData.totalFreeTime
    local isFreeInFree = spinData.newFreeTime > 0

    self.remainFreeTime = remainFreeTime
    self.totalFreeTime = totalFreeTime

    local freeTotalWinCoin = spinData.bonusWinCoin
    print("freeTotalWinCoin >>> ",freeTotalWinCoin)

    -- print(">>>>>>>>>>>>> OnFreeSpinResult >>> ",spinData.winCoin) 
    self.slotContainer[self.curSlotType]:SetReelSymbolData(spinData, isReconnect, function()
        print("Game481:OnFreeSpinResult >>> self.slotContainer[self.curSlotType]:SetReelSymbolData >>> Complete")

        function doWhenSetReelSymbolCompelte()
            print("Game481:OnFreeSpinResult >>> doWhenSetReelSymbolCompelte >>> ")

            -- if self.CacheReconnectMsg then
            --     self:ReconnectRecoveryGame(self.CacheReconnectMsg)
            --     self.CacheReconnectMsg = nil
            --     return;
            -- end

            if isFreeInFree then
                print("Game481:OnFreeSpinResult >>> isFreeInFree >>> true")
                Utils.ScrollBottomWinMoneyTo(FCasinoCtx:GetGame().curAccumulatedWinInFree,0.2)
                self.slotContainer[self.curSlotType]:ShowIntoFreeSCAnimation()
                self.enterDelayTimer = StartOnceTimer(function()
                    Utils.PlaySound("ui://Game481/frame_appear")
                    self:ShowEnterFreePanel(spinData.newFreeTime, true)
                    StopTimer(self.enterDelayTimer)
                    self.enterDelayTimer = nil
                end, 2)
                
            elseif remainFreeTime == 0 then
                print("Game481:OnFreeSpinResult >>> remainFreeTime == 0 >>> true")

                -- self.curSCGridsIndexArr = {}
                -- 免费结束
                if not isReconnect then
                    print("Game481:OnFreeSpinResult >>> remainFreeTime == 0 >>> not isReconnect >>> true")
                    StartOnceTimer(function()
                        FCasinoCtx:SetPlayerMoneyInfo(spinData)
                        Utils.PlaySound("ui://Game481/frame_appear")
                        self:ShowFreeTotalSettlement(freeTotalWinCoin)
                    end, 1)
                else
                    print("Game481:OnFreeSpinResult >>> remainFreeTime == 0 >>> isReconnect >>> true")
                    FCasinoCtx:GetGame().curAccumulatedWinInFree = 0
                    FCasinoCtx:GetGame().totalMultiplierCount = 0
                    self.totalMultiplierLabel.text = ""
                    self.totalMultiplierLabel.visible = true
                end

            else
                print("Game481:OnFreeSpinResult >>> remainFreeTime ~= 0 >>> true")
                FCasinoCtx:SetSpinStatus(FSpinStatus.SPIN)
                -- TEST:
                -- if true then return end
                self:AutoClick()
                
            end
        end

        if self:DoesFlowAniPlayComplete() then
            print("Game481:OnFreeSpinResult >>> self:DoesFlowAniPlayComplete() >>> true")
            doWhenSetReelSymbolCompelte()
        else
            print("Game481:OnFreeSpinResult >>> self:StuckedFnTableAdd(doWhenSetReelSymbolCompelte) >>> ")
            self:StuckedFnTableAdd(doWhenSetReelSymbolCompelte)
        end

    end)

end

function Game481:StopDelayCallSpin()
    if self.callSpinTimer then
        StopTimer(self.callSpinTimer)
        self.callSpinTimer = nil
    end
end

function Game481:AutoClick()
    self.curNormalSpinResult = nil
    self.curFreeSpinResult = nil
    self.curSpecialSpinResult = nil
    
    FCasinoCtx:SetSpinStatus(FSpinStatus.SPIN)

    local interval = FConfig.Common.AutoSpinInterval[FCasinoCtx.curGameMode]
    -- 普通游戏状态点击停止按钮
    if FCasinoCtx.curGameMode == FGameMode.NORMAL then
        if FCasinoCtx.isAutoSpin then
            self:DelayCallSpin(interval)
        end
    else
        -- 特殊游戏，自动点击
        self:DelayCallSpin(interval)
    end
end


function Game481:DelayCallSpin(delay)
    self:StopDelayCallSpin()
    self.callSpinTimer = StartOnceTimer(function()
        FCasinoCtx:SimulateSpinClick()
    end, delay)
end


function Game481:ResetAwardHistoryView()
    self.awardsHistoryPanel:ResetListView()
end

function Game481:PlayAwardHistoryItemAni()
    -- if true then return end
    self.awardsHistoryPanel:ShowNewItemAnimation()
end

function Game481:SetCurAwardsData(data)
    self.awardsHistoryPanel:SetCurAwardsData(data)

end

function Game481:UpdateMultiCountLabel(curTotalMultiplierCount)
    self.totalMultiplierLabel.text = tostring(curTotalMultiplierCount) == "0" and "" or tostring(curTotalMultiplierCount).."x"
end


return Game481