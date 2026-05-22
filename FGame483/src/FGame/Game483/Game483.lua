local Utils             = Import(".Slot.Utils")
local BigWin            = Import(".Slot.BigWin")
local GameDefine        = Import(".GameDefine")
local Slot        = Import(".Slot.Slot")
local Tips              = Import(".Slot.Tips")
local TopX              = Import(".Slot.TopX")
local FreeLoading       = Import(".Slot.FreeLoading")
local FreeTotalWin       = Import(".Slot.FreeTotalWin")
local BigWin       = Import(".Slot.BigWin")
local FreeGetTimes       = Import(".Slot.FreeGetTimes")

local MusicCfg = Import(".Slot.MusicCfg")
local Game483 = Class("Game483", BaseGame)

function Game483:ctor(render)
    -- TEST:
    -- if cc and cc.Director then
    --     cc.Director:getInstance():setAnimationInterval(1 / 30)
    -- end
    --
    if not GameDefine.LOG_KEY then
        self.dump = dump
        dump = function()
            
        end
        self.print = print
        print = function()
            
        end
    end

    self.render = render:GetChild("gameView")

    self.slot = self.render:GetChild("slot")
    -- self.slotContainer = {}
    self.slotContainer = Slot.New(self.slot:GetChild("container"), false)
    self.tips = Tips.New(self.render:GetChild("tips"))
    self.topX = TopX.New(self.render:GetChild("topX"))
    self.freeLoading = FreeLoading.New(self.render:GetChild("freeLoading"))
    self.freeTotalWin = FreeTotalWin.New(self.render:GetChild("freeTotalWin"))
    
    self.freeTopBg = self.render:GetChild("freeTopBg")
    self.freeTopEffect = self.render:GetChild("freeTopEffect")
    self.freeBottomEffect = self.render:GetChild("freeBottomEffect")
    self.bigWin = BigWin.New(self.render:GetChild("bigWin"))
    self.freeGetTimes = FreeGetTimes.New(self.render:GetChild("freeGetTimes"))

    self:SetGameMode(FGameMode.NORMAL)

    self._winCoin = 0
end

function Game483:__delete()
    self.tips:Delete()
    self.topX:Delete()
    self.freeLoading:Delete()
    self.freeTotalWin:Delete()
    self.bigWin:Delete()
    self.freeGetTimes:Delete()
    self.slotContainer:Delete()
    self._winCoin = 0
    -- table.removeByIndexs = nil
    if not GameDefine.LOG_KEY then
        dump = self.dump
        print = self.print
    end
    FToolSet.StopBGM()
    self.soundBgm = nil
end

-- @interface
-- @brief update
function Game483:Update(dt)
    Game483.super.Update(self, dt)
    self.slotContainer:Update(dt)
end

-- @interface
-- @brief 在游戏中断线重连恢复游戏
-- @param msg 断线重连数据
function Game483:ReconnectRecoveryGame(msg, isInitialize)
    dump(msg,"ReconnectRecoveryGame",5)
    local currentWinCoin = msg.currentWinCoin
    if isInitialize then
        if currentWinCoin and currentWinCoin > 0 then
            FCasinoCtx.commonPanel:ScrollWinMoneyTo(currentWinCoin,0.01)
        end
    end
    if msg.status == 1 then -- 普通
        self:OnNormalSpinResult(msg.resumedNormal.normalSpin,true)
    elseif msg.status == 2 then -- 免费
        if msg.resumedFree.freeSpin.results.array[1].freeTime == 0 then
            msg.resumedNormal.normalSpin.intoFree = 0
            self:OnNormalSpinResult(msg.resumedNormal.normalSpin,true)
            return
        end
        self.currentWinCoin = currentWinCoin or 0
        self:OnFreeSpinResult(msg.resumedFree.freeSpin,true)
        self.freeTopBg.visible = true
        self.freeTopEffect.visible = true
        self.freeBottomEffect.visible = true
        self.tips:ShowFreeTimes(msg.resumedFree.freeSpin.results.array[1].freeTime)
        self.topX:FreeTypeAnim() 
    end
end

-- @interface
-- @brief 点击开始按钮
function Game483:OnClickSpin()
    -- if true then
    --     self.bigWin:Show(1378000,function ()
    --         self.render:GetTransition("hideBigWin"):Play()
    --     end)
    --     return
    -- end
    -- Check can spin
    local canSpin = true
    if not self.slotContainer then return end

    self:StopDelayCallSpin()

    if FCasinoCtx.curGameMode == FGameMode.NORMAL then
        if not FCasinoCtx:PlayerSpinConsumption() then
            self.spinEnd = true
            FCasinoCtx:SetSpinStatus(FSpinStatus.SPIN)
            return
        end
        self.tips:HideWin()
        self._winCoin = 0
        FCasinoCtx.commonPanel:StopScrollWinMoney(0, false)
        self.slotContainer:SpinStart()
        self:SendNormalSpin("PB.Client_Slots.MahjongWaysNormalSpin", "PB.Slots_Client.MahjongWaysNormalRet", function(ok, result)
            if not ok then return end
            dump(result.normalSpin,"result.normalSpin",5)
            self:OnNormalSpinResult(result.normalSpin)
        end)
        
    elseif FCasinoCtx.curGameMode == FGameMode.FREE then
        self.tips:HideWin()
        self.slotContainer:SpinStart()
        local request = {
            _msgName_ = "PB.Client_Slots.MahjongWaysFreeSpin"
        }
        APIGateway.SendExactRequest(request, "PB.Slots_Client.MahjongWaysFreeRet", function(ok, result)
            if not ok then return end
            self:OnFreeSpinResult(result.freeSpin)
        end)
    end
end


function Game483:OnClickStop()
    self.slotContainer:QuickStop()
end

-- @brief 处理普通旋转结果
function Game483:OnNormalSpinResult(spinData,isReconnect)
    -- dump(spinData,"spinData",10)
    -- 当前正在运行的数据和断线重连下发的数据一样，直接忽略
    if isReconnect and table.equals(spinData, self.curNormalSpinResult) then
        return
    end
    
    self.curNormalSpinResult = spinData

    local freeTime = spinData.results.array[1].freeTime
    local totalFreeTime = spinData.results.array[1].totalFreeTime
    local isIntoFree = spinData.intoFree == 1

    -- self.isCurNormalSpinResIntoFree = isIntoFree

    -- if self.isReconnect then -- 断线重连从新设置
    --     isIntoFree = self.isRecoveryIntoFree
    -- end
    
    if isIntoFree then
        -- self.remainFreeTime = freeTime
        FCasinoCtx:SetSpinStatus(FSpinStatus.WAITING)
    end
    self:SetGameMode(FGameMode.NORMAL)
    self.slotContainer:SetReelCilckEnabled(false)
    self.slotContainer:SetReelSymbolData(
        spinData,
        isReconnect,
        function()
            if isIntoFree then
                FCasinoCtx:SetSpinStatus(FSpinStatus.WAITING)
                self:EnterFree(totalFreeTime,function ()
                    self:SetGameMode(FGameMode.FREE)
                    self.slotContainer:ResetDatas(true,freeTime, totalFreeTime, spinData.winCoin)
                    FCasinoCtx:SetSpinStatus(FSpinStatus.SPIN)
                    FCasinoCtx:SimulateSpinClick()
                    FCasinoCtx:SetSpinStatus(FSpinStatus.WAITING)
                end)
                return
            end
            FCasinoCtx:SetSpinStatus(FSpinStatus.SPIN)
            self:AutoClick()
            if not isReconnect then
                FCasinoCtx:SetPlayerMoneyInfo(spinData)
                FCasinoCtx:SyncPlayerMoneyDisplay(2)
            end
        end
    )

end


-- @brief 处理免费游戏旋转结果
function Game483:OnFreeSpinResult(spinData,isReconnect)
    print("OnFreeSpinResult>>>>>>>>>>>>>")
    -- 当前正在运行的数据和断线重连下发的数据一样，直接忽略
    if isReconnect and table.equals(spinData, self.curFreeSpinResult) then
        return
    end

    self.curFreeSpinResult = spinData
    self:SetGameMode(FGameMode.FREE)
    local remainFreeTime = spinData.results.array[1].freeTime
    local totalFreeTime = spinData.results.array[1].totalFreeTime
    if isReconnect then
        self.slotContainer:ResetDatas(true,remainFreeTime, totalFreeTime,self.currentWinCoin)
        self.currentWinCoin = nil
    end
    self.slotContainer:SetReelCilckEnabled(false)
    self.slotContainer:SetReelSymbolData(
        spinData,
        isReconnect,
        function()
            if remainFreeTime == 0 then
                print("免费结算")
                self.tips:HideFreeTimes()
                self:ShowFreeTotalWinPanel(self.slotContainer:GetTotalWin(),function ()
                    FCasinoCtx:SetSpinStatus(FSpinStatus.SPIN)
                    self:AutoClick()
                    FCasinoCtx:SetPlayerMoneyInfo(spinData)
                    FCasinoCtx:SyncPlayerMoneyDisplay(2)
                end)
                return
            elseif totalFreeTime > self.slotContainer.allturns then -- 免中免
                FCasinoCtx:SetSpinStatus(FSpinStatus.WAITING)
                self:ShowFreeGetTimes(remainFreeTime,function ()
                    self.slotContainer:ResetDatas(true,remainFreeTime, totalFreeTime,self.slotContainer:GetTotalWin())
                    self:AutoClick()
                end)
                return
            end
            FCasinoCtx:SetSpinStatus(FSpinStatus.WAITING)
            self:AutoClick()
        end
    )

end

function Game483:StopDelayCallSpin()
    if self.callSpinTimer then
        StopTimer(self.callSpinTimer)
        self.callSpinTimer = nil
    end
end

function Game483:AutoClick()
    self.curNormalSpinResult = nil
    self.curFreeSpinResult = nil
    self.curSpecialSpinResult = nil
    
    -- FCasinoCtx:SetSpinStatus(FSpinStatus.SPIN)

    local interval = FConfig.Common.AutoSpinInterval[FCasinoCtx.curGameMode]
    -- 普通游戏状态点击停止按钮
    if FCasinoCtx.curGameMode == FGameMode.NORMAL then
        if FCasinoCtx.isAutoSpin then
            self:DelayCallSpin(interval)
        else
            self.slotContainer:SetReelCilckEnabled(true)
        end
    else
        -- 特殊游戏，自动点击
        self:DelayCallSpin(interval)
    end
end


function Game483:DelayCallSpin(delay)
    self:StopDelayCallSpin()
    self.callSpinTimer = StartOnceTimer(function()
        print(" SimulateSpinClick")
        FCasinoCtx:SetSpinStatus(FSpinStatus.SPIN)
        if FCasinoCtx:SimulateSpinClick() then
            if not self.spinEnd then
                FCasinoCtx:SetSpinStatus(FSpinStatus.WAITING)
            end
            self.spinEnd = nil
        end
    end, delay)
end

function Game483:SetGameMode(mode)
    local url = mode == FGameMode.FREE and MusicCfg.bgm_bonus_loop or MusicCfg.bgm_mg 
    self:ChangeBgm(url)
    FCasinoCtx:SetGameMode(mode)
    self.curSlotType = mode
    self.tips:PlayTips(mode)
end

-- 进入免费动画
function Game483:EnterFree(times,callback)
    FCasinoCtx:SetSpinStatus(FSpinStatus.WAITING)
    self.freeLoading:StartLoading(times,function () -- 免费进度条
        self.render:GetTransition("hideFreeLoading"):Play(function () --隐藏进度条
            self.freeTopBg.visible = true
            self.freeTopEffect.visible = true
            self.freeBottomEffect.visible = true
            self.tips:ShowFreeTimes(times)
            self.topX:FreeTypeAnim(function () -- 顶部x切换成免费状态
                -- 开始免费旋转
                print("开始免费旋转")
                if callback then
                    callback()
                end
            end)
        end)
    end)
end

-- 免费结算动画
function Game483:ShowFreeTotalWinPanel(win,callback)
    FCasinoCtx:SetSpinStatus(FSpinStatus.WAITING)
    self.render:GetTransition("showFreeTotalWin"):Play()
    FToolSet.StopBGM()
    self.soundBgm = nil
    self.freeTotalWin:Play(win,function ()
        self:SetGameMode(FGameMode.NORMAL)
        self.slotContainer:ResetDatas(false)
        self.freeTopBg.visible = false
        self.freeTopEffect.visible = false
        self.freeBottomEffect.visible = false
        self.topX:NormalTypeAnim()
        self.render:GetTransition("hideFreeTotalWin"):Play(function ()
            if callback then
                callback()
            end
        end)
    end)
end

-- 大奖动画
function Game483:ShowBigWin(win,callback)
    FCasinoCtx:SetSpinStatus(FSpinStatus.WAITING)
    self.bigWin:Show(win,function ()
        self.render:GetTransition("hideBigWin"):Play(function ()
            if callback then
                callback()
            end
        end)
    end)
end

--
function Game483:PlayTopXIndexAdd(index)
    self.topX:IndexAdd(index)
end

function Game483:PlayTopXIndexReset()
    self.topX:IndexReset()
end

-- 算分
function Game483:ShowWin(isTotal,num,callback)
    if isTotal then
        self:CheckBigWin(num,function (needWait)
            FToolSet.PlayFGUISound(MusicCfg.collect..math.random(1,3))
            self.tips:ShowWin(isTotal,num,function ()
                FCasinoCtx.commonPanel:ScrollWinMoneyTo(self.slotContainer:GetTotalWin(),0.3)
                if callback then
                    callback(needWait)
                end
            end)
        end)
    else
        FToolSet.PlayFGUISound(MusicCfg.collect..math.random(1,3))
        self.tips:ShowWin(isTotal,num,function ()
            if callback then
                callback(needWait)
            end
        end)
    end
end

-- 一共三级 需要改
function Game483:CheckBigWin(number,callback)
    print("number: ",number)
    local ratio = number / FCasinoCtx.commonPanel:GetBetMoney()
    if ratio < GameDefine.BIGWIN then
        if callback then
            callback(false)
        end
        return 
    end
    print("ratio ", ratio)
    self.bigWin:Show(number,function ()
        self.render:GetTransition("hideBigWin"):Play(function ()
            if callback then
                callback(true)
            end
        end)
    end)
end

function Game483:ChangeBgm(url)
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

function Game483:ShowFreeGetTimes(times,callback)
    self.freeGetTimes:Show(times - self.slotContainer.curturn,function ()
        self.tips:HideWon()
        if callback then
            callback()
        end
    end)
    -- self.tips:ShowFreeTimes(1)
    -- self.tips:WonFreeTimes(self.slotContainer.curturn or 1,times)
    if not self.slotContainer.curturn then
        print("error ShowFreeGetTimes")
        return
    end
    self.tips:WonFreeTimes(self.slotContainer.curturn,times)
end
return Game483