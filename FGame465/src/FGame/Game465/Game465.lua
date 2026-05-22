
 local NormalSlot       = Import(".Slot.NormalSlot")
local FreeSlot        = Import(".Slot.FreeSlot")
local Utils          = Import(".Slot.Utils")
local MusicCfg = Import(".Slot.MusicCfg")
local SelectPanel = Import(".Slot.FreePanel")
local OtherPanel = import(".Slot.OtherPanel")
local Tips = import(".Slot.Tips")
local CoinFountain      = require("FGame.Common.Logic.Effect.CoinFountain")

local SlotType = {
    Normal      = 1,    -- 普通类型
    Free        = 2,    -- 免费游戏
}

local Game465 = Class("Game465", BaseGame)

function Game465:ctor(render)
    self.render = render
    if not self.render  then
        print("render 为 nil")
    end
    --加载界面
    self.slot = self.render:GetChild("Slot").component
    self.curGameType = 0
    self.slotContainers = {}
    self.slotContainers[SlotType.Normal] = NormalSlot.New(self.slot:GetChild("ReelContainer"),self)
    self.slotContainers[SlotType.Normal]:SetVisible(false)
    
    self.slotContainers[SlotType.Free] = FreeSlot.New(self.slot:GetChild("ReelContainer"),self)
    self.slotContainers[SlotType.Free]:SetVisible(false)
    self.otherPanel = OtherPanel.New(self.render:GetChild("OtherPanel"),self)
    self.selectPanel = SelectPanel.New(self.render:GetChild("SelectPanel"),self)
    self.tips =  Tips.New(self.render:GetChild("BigwinTip"),self)
    self.tips.sortingOrder = 1000
    self:ChangeGameType(SlotType.Normal)
    self.datas = {
        normalPacket = nil, -- 普通旋转结果
        freeSpinPacket = nil , -- 免费旋转结果
        specialPacket = nil, -- 特殊旋转结果
    }
    
    self.soundBgmHandle = nil
    self.soundBgm = nil
    --创建喷射金币效果
    self._winCoin = 0
    --自动旋转倒计时时间
    self._autoSpinSecond  = 1
    self.specialwinnumber = 0
    self.specialtypedata = {}
    self.curGameType = 1
    self.freeIconInfo = {}--免费图标
    self.startReel_count = 0 --彩金预警增加格子距离音效
    self.tingpaianimarr = {}
    self._infree = false
    for i = 1, 4 do
        local anim = self.slot:GetChild("n"..12+i)
        table.insert(self.tingpaianimarr,anim)
    end
    self.wildbetanim = false
    self.silkbaganim = false
    self.silkbagwildbet = 1
    self:Test(function ()
        -- self.otherPanel:CreateJpWinBoard(1000000000)
        -- self.otherPanel:showsilkbagpanel(2)
        -- self.otherPanel:showflowerpanel(2)
        -- self.otherPanel:showredbagPanel(2)
    end)
end

function Game465:Test(fuc_)
    StartOnceTimer(fuc_,2)
end
---功能函数
--金币滚动是切换停止按钮 处理停止按钮点击回调函数
function Game465:Coin_Roll_Function(callfunc)
    print("金币滚动是切换停止按钮",self:GetAutoSpinSecond())
    FCasinoCtx:SetSpinStatus(FSpinStatus.STOP)
    self.rollanimcallback = callfunc
    self.rollanimcallbacktimer = StartOnceTimer(function ()
        self.rollanimcallbacktimer = nil
        if self.rollanimcallback then
            self.rollanimcallback()
            self.rollanimcallback = nil
        end
    end,self:GetAutoSpinSecond())
end
--是否是免费游戏
function Game465:InGameFree()
    if FCasinoCtx.curGameMode == FGameMode.FREE then
        return true
    end
    return false
end
--是否是普通游戏
function Game465:InGameNormal()
    if FCasinoCtx.curGameMode == FGameMode.NORMAL then
        return true
    end
    return false
end
function Game465:__delete()
    self:StopDelayCallSpin()
    for i = 1, 2  do -- 3  4 共用
        self.slotContainers[i]:Delete()
    end
    if self.soundBgmHandle then
        APIGateway.StopSound(self.soundBgmHandle)
        self.soundBgmHandle = nil
    end
    self.otherPanel:Delete()
    self.tips:Delete()
end

-- @interface
-- @brief update
function Game465:Update(dt)
    Game465.super.Update(self, dt)
    for i = 1, 2 do -- 3  4 共用
        self.slotContainers[i]:Update(dt)
    end
end
function Game465:SetAutoSpinSecond(second)
    self._autoSpinSecond = second
end
function Game465:GetAutoSpinSecond()
    return self._autoSpinSecond 
end
-- @interface
-- @brief 在游戏中断线重连恢复游戏
-- @param local  断线重连数据
function Game465:ReconnectRecoveryGame(data, isInitialize)
    dump(data,"ReconnectRecoveryGame",10)
    print("isInitialize: ",isInitialize)
    print("断线重连 self.curGameType: ",self.curGameType)
    print("断线重连 self.isSpined: ",self.isSpined)
    --type 1普通 2免费 3特殊 4免费中特殊
    if data.type == 1 then
        local resumedNormal = data.resumedNormal
        local normalSpin = resumedNormal.normalSpin
        local spinData = normalSpin
        if not self:CheckSlotData(normalSpin.grids, SlotType.Normal) then
            print("断网数据和本地数据不一样")
            self.datas.normalPacket = data.resumedNormal.normalSpin
            if self.curGameType ~= 1 and self.isSpined then -- 已经在特殊游戏了
                self:SendPackage()
                return
            end
            self:OnNormalSpinResult(spinData, true,function ()  end,data.currentWinCoin)
            self.slotContainers[SlotType.Normal]:SetWinCoin(data.currentWinCoin)
            if spinData.intoFree == 1 then
                FCasinoCtx:SetSpinStatus(FSpinStatus.WAITING)
                self.selectPanel:enterfreeselect(true)
            end
        else
            print("断网数据是一样")
            if self.isSpined then -- 已经在特殊游戏了
                    self:SendPackage() 
                return
            end
            if normalSpin.intoFree == 1 then
                self.selectPanel:RecoverSelectPanel()
            end
        end
        return
    elseif (data.type == 3 and #data.resumedFree.freeSpin.grids == 0) or data.type == 2  then
        local norspinData = data.resumedNormal.normalSpin
        --免费中处理普通包中奖线
        self.slotContainers[SlotType.Normal]:HandleWinDatas(norspinData.lines)
        if not self:CheckSlotData(norspinData.girds, SlotType.Free) then
            self.datas.normalPacket = data.resumedNormal.normalSpin
            self.datas.selectpacket = data.freeType.freeType
            local freeiconarr = {[25] = 1,[20] = 2,[15] = 3,[13] = 4,[10] = 5,[0] = 0}
            self.slotContainers[SlotType.Free]:SetFreeIconType(freeiconarr[self.datas.selectpacket.type]) 
            self.slotContainers[SlotType.Free]:ResetDatas(0,self.datas.selectpacket.type,data.currentWinCoin)
            self:ChangeGameType(SlotType.Free)
            self.slotContainers[SlotType.Free]:InitIcondata()
            self:ShowBottomWin(true,data.currentWinCoin)
            self:ChangeBgm(MusicCfg.SND_Fea_BGM)
            FCasinoCtx:SetSpinStatus(FSpinStatus.SPIN)
            self:DelayCallSpin(0.5)
            self._infree = true
        else
            if self.isSpined then -- 已经在特殊游戏了
                self:SendPackage()
                return
            end
        end
    elseif data.type == 3 then
        print("断线重连 - 处理接收免费")
        local resumedNormal = data.resumedNormal
        local resumedFree = data.resumedFree
        local norspinData = resumedNormal.normalSpin
        local spinData = resumedFree.freeSpin
        if not self:CheckSlotData(resumedFree.freeSpin.grids, SlotType.Free) then
            print("断网数据和本地数据不一样")
            self.datas.normalPacket = resumedNormal.normalSpin
            self.datas.freeSpinPacket = resumedFree.freeSpin
            local freedata = resumedFree.freeSpin
            self.datas.selectpacket = data.freeType.freeType
            local freeiconarr = {[25] = 1,[20] = 2,[15] = 3,[13] = 4,[10] = 5,[0] = 0}
            self.slotContainers[SlotType.Free]:SetFreeIconType(freeiconarr[self.datas.selectpacket.type]) 
            self.slotContainers[SlotType.Free]:ResetDatas(freedata.totalCount,freedata.allCount,data.currentWinCoin)
            self:OnFreeSpinResult(spinData, true,function () end)
            if freedata.totalCount == freedata.allCount and freedata.addTime == 0 then
                print("断线重连免费游戏结束")
                self.otherPanel:SetCount()
                --没次数了
                self:OnNormalSpinResult(norspinData, true,function ()  end)
                return
            end
            self:ShowBottomWin(true,data.currentWinCoin)
            if freedata.addTime > 0 and freedata.totalCount == freedata.allCount then
                self.otherPanel:SetCount()
                self:EnterFreeSelect(true,true)
            else
                if freedata.addTime > 0 then
                    self.otherPanel:showredbagPanel(freedata.addTime,nil,true)
                    
                end
                self:ChangeBgm(MusicCfg.SND_Fea_BGM)
                --恢复动画效果
                FCasinoCtx:SetSpinStatus(FSpinStatus.SPIN)
                self:DelayCallSpin(3)
            end
            self._infree = true
            return
        else
            print("断网数据是一样")
            if self.isSpined then -- 已经在特殊游戏了
                self:SendPackage()
                return
            end
        end
        return
    end
    
end

-- 检查普通包跟当前包是否一样
function Game465:CheckSlotData(grids, type)
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
    elseif type == SlotType.TopupBouns1 then
        if not self.datas.specialPacket or next(self.datas.specialPacket.grids) == nil then
            return false
        end
        localGrids = self.datas.specialPacket.grids
    elseif type == SlotType.FreeTopupBouns1 then
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
        local bonusType = grids[i].lottyType
        local bonusValue = grids[i].lottyValue

        local lastIcon = localGrids[i].icon
        local lastbonusType = grids[i].lottyType
        local lastbonusValue = grids[i].lottyValue

        if icon ~= lastIcon or
         bonusType ~= lastbonusType or
         bonusValue ~= lastbonusValue then
            return false
        end
    end
    return true
end
function Game465:StopAllcoin_sound_wincoin()
    self:StopDelayCallSpin()
    --停止播放收分音效
    if self.soundWinCoinEffectHandle then
        APIGateway.StopSound(self.soundWinCoinEffectHandle)
        self.soundWinCoinEffectHandle = nil
    end
end

-- @interface
-- @brief 点击开始按钮ftes
function Game465:OnClickSpin()
    print("点击开始按钮")
    self.tips:HideTips()
    self:StopAllcoin_sound_wincoin()
   
    --停止收分计时器
    if self.soundWinCoinEffectHandleTimer then
        StopTimer(self.soundWinCoinEffectHandleTimer)
        self.soundWinCoinEffectHandleTimer = nil
        self:ShowBottomWin(true,self._winCoin)
        return
    end
    FToolSet.PlayFGUISound("ui://Game465/reel_click" )
     -- 金币不足
    if FCasinoCtx.curGameMode == FGameMode.NORMAL and
     not FCasinoCtx:PlayerSpinConsumption() then
        return
    end
    self:StopActionAndWinlines()
   if FCasinoCtx.curGameMode == FGameMode.NORMAL then
        self.datas.freeSpinPacket = nil
        self.datas.specialPacket = nil
        -- 清空本轮赢分
        FCasinoCtx.commonPanel:StopScrollWinMoney(0, false)
        self._winCoin = 0
        self:ChangeGameType(SlotType.Normal)
        self.slotContainers[SlotType.Normal]:SpinStart()
        self._infree = false
    elseif FCasinoCtx.curGameMode == FGameMode.FREE then
        self._infree = true
        self:ChangeGameType(SlotType.Free)
        self.slotContainers[SlotType.Free]:SpinStart()
        --self:ChangeBgm(MusicCfg.SND_Fea_BGM)
    end
    self.caijin_type,self.smallecaijin = 0 ,0
    self.otherPanel:showsilkbagpanel()
    self.otherPanel:showflowerpanel()
    self.silkbaganim = false
    self.wildbetanim = false
    --发送包数据
    
    self:SendPackage()
    self.isSpined = true
end
--发送包数据
function Game465:SendPackage(index)
    if index then
        print("发送免费选择包数据")
        local request = {
            _msgName_ = "PB.Client_Slots.dragons5FreeType",
            type = index-1
        }
        if RUNTIME_USE_H5_PROTO then
            request.index = index 
            request.type = nil
        end
        APIGateway.SendExactRequest(request, "PB.Slots_Client.dragons5FreeRetType",
            function(ok, result)
                if not ok then return end
                self.datas.selectpacket = result.freeType
                dump(result,"SPECIAL",4)
                self.selectPanel:ShowSelectResult(index)
            end
        )
        return
    end
    if FCasinoCtx.curGameMode == FGameMode.NORMAL then
        print("发送普通包数据")
        self:SendNormalSpin("PB.Client_Slots.dragons5NormalSpin", "PB.Slots_Client.dragons5NormalRet",
            function(ok, result)
                if not ok then return end
                dump(result,"NORMAL",10)
                self.datas.normalPacket = result.normalSpin
                self:OnNormalSpinResult(result.normalSpin)
            end
        )
    elseif FCasinoCtx.curGameMode == FGameMode.FREE then
        print("发送免费包数据")
        local request = {
            _msgName_ = "PB.Client_Slots.dragons5FreeSpin"
        }
        APIGateway.SendExactRequest(request, "PB.Slots_Client.dragons5FreeRet",
            function(ok, result)
                if not ok then return end
                dump(result,"FREE")
                dump(result.freeSpin)
                self.datas.freeSpinPacket = result.freeSpin
                self:OnFreeSpinResult(result.freeSpin)
            end
        )
    end
end

--点击停止按钮
function Game465:OnClickStop()
    if #self.freeIconInfo >= 2 then return end
    print("点击停止按钮")
    self.tips:HideTips()
    self:StopAllcoin_sound_wincoin()
    if FCasinoCtx.isAutoSpin then
        self:DelayCallSpin(2)
    end
    --免费游戏结束按键状态切换
    if self.rollanimcallbacktimer then
        StopTimer(self.rollanimcallbacktimer)
        self.rollanimcallbacktimer = nil
        if self.rollanimcallback then
            self.rollanimcallback()
            self.rollanimcallback = nil
        end
    end
    --停止收分计时器
    if self.soundWinCoinEffectHandleTimer then
        StopTimer(self.soundWinCoinEffectHandleTimer)
        self.soundWinCoinEffectHandleTimer = nil
        self:ShowBottomWin(true,self._winCoin)
        self:ChangeBgm()
        if self._infree then
            print("OnClickStop恢复bg音效")
            FToolSet.PlayBGM(MusicCfg.SND_Fea_BGM,true)
            if not self.silkbaganim  then
                FToolSet.PlayFGUISound("ui://Game465/BonusRollupTerm")
            end
        end
        return
    end
    self:StopActionAndWinlines()
    if not self.isSpined then return end
    
    -- 普通游戏状态点击停止按钮
    if FCasinoCtx.curGameMode == FGameMode.NORMAL then
        self.slotContainers[SlotType.Normal]:QuickStop()
    elseif FCasinoCtx.curGameMode == FGameMode.FREE then
        self.slotContainers[SlotType.Free]:QuickStop()
    end
end

-- @brief 处理普通旋转结果
-- @param quickSet 直接设置跳过动画
function Game465:OnNormalSpinResult(spinData, quickSet, customCallback,allwinCount)
    print("处理普通包数据")
    Utils.printLine(spinData.grids)
    self:ChangeGameType(SlotType.Normal)
    
    if quickSet then
        self.slotContainers[self.curGameType]:SetOpen(true)
    else
        --处理中奖线数据
        self.slotContainers[self.curGameType]:HandleWinDatas(spinData.lines)
    end
    -- --设置时候中奖免费游戏
    self.slotContainers[self.curGameType]:SetIsEnterFree(spinData.intoFree == 1)
    --处理格子数据
    self.slotContainers[self.curGameType]:HandleCellDatas(spinData.grids)
    self.slotContainers[SlotType.Normal]:SetReelSymbolData(function ()
        -- 快速设定图形数据 不进行免费特殊判断
        self.isSpined = false
        if customCallback then
            customCallback()
            return
        end
        self:SpinEndCallFunc()
    end,quickSet,allwinCount)
end
--旋转结束播放中奖线前特殊处理
function Game465:SpinEndCallFunc()
    print("旋转结束播放中奖线前特殊处理")
    FCasinoCtx:SetSpinStatus(FSpinStatus.WAITING)
    self.isSpined = false
    local func = function ()
        if self:InGameFree() then
            if self.datas.freeSpinPacket.wildBet ~= 1 or self.silkbaganim then
               if self.wildbetanim and self.silkbaganim  then--2
                    self.otherPanel:showsilkbagpanel(self.silkbagwildbet,function ()
                        self:GameState_EndDraw()
                    end)
                    self.otherPanel:showflowerpanel(self.datas.freeSpinPacket.wildBet)
                elseif self.silkbaganim  then--1
                    self.otherPanel:showsilkbagpanel(self.silkbagwildbet,function ()
                        self:GameState_EndDraw()
                    end)
                elseif self.wildbetanim then--1
                    self.otherPanel:showflowerpanel(self.datas.freeSpinPacket.wildBet,function ()
                        self:GameState_EndDraw()
                    end)
                else
                    self:GameState_EndDraw()
                end
            else
                self:GameState_EndDraw()
            end
        else
            self:GameState_EndDraw()
        end
    end
    --处理免费和彩金入场音效动画
    print("#self.freeIconInfo",#self.freeIconInfo)
    if #self.freeIconInfo >= 3 then
        if self:InGameFree()  then
            self.otherPanel:showredbagPanel(self.datas.freeSpinPacket.addTime)
        end
        FToolSet.PlayFGUISound("ui://Game465/triggering")
        self.slotContainers[self.curGameType]:PlayTablelist(self.freeIconInfo)
        StartOnceTimer(function ()
            FToolSet.PlayFGUISound("ui://Game465/scatrwin")
            StartOnceTimer(function ()
                self.freeIconInfo = {}
                func()
            end,2)
        end,2)
    else
        func()
    end
end
--绘制中奖线播放中奖动画 收分
function Game465:GameState_EndDraw(isfree,freecallback)
    local second = self.slotContainers[self.curGameType]:DrawLineAndCollectScores()
    self:SetAutoSpinSecond(second)
    print("设置滚动时常",second)
    self:GameState_HandleSpecial(isfree,freecallback)
end
--处理特殊游戏
function Game465:GameState_HandleSpecial(isfree,freecallback)
   
    self:GameState_HandleFreeTime(isfree)
end
--处理免费游戏
function Game465:GameState_HandleFreeTime(isfree)
    if FCasinoCtx.curGameMode == FGameMode.NORMAL then
        if self.datas.normalPacket.intoFree > 0 and not isfree then
            self:EnterFreeSelect()
            return
        end
        self:GameState_GameOver()
    elseif FCasinoCtx.curGameMode == FGameMode.FREE then
        if self.datas.freeSpinPacket.addTime > 0 then
            self:FreeAddGame()
            return
        end
        self:GameState_SingleRoundFreeGameOver()
    end
end
function Game465:FreeAddGame()
    self.slotContainers[SlotType.Free]:SetAllTurns(self.datas.freeSpinPacket.allCount)
    self:GameState_SingleRoundFreeGameOver()
end
--免费游戏单轮结束
function Game465:GameState_SingleRoundFreeGameOver()
    --有中奖线的时候
    print("单轮免费游戏结束")
    self:Coin_Roll_Function(function ()
        local freedata = self.datas.freeSpinPacket
        if freedata.totalCount == freedata.allCount then
            FCasinoCtx:SetSpinStatus(FSpinStatus.WAITING)
            if freedata.addTime > 0 then
                self:EnterFreeSelect(true)
            else
                self:GameState_GameOver(true)
            end
        else
            print("免费继续旋转 切换按钮状态")
            FCasinoCtx:SetSpinStatus(FSpinStatus.SPIN)
            self:DelayCallSpin(2)
        end
    end)
end
function Game465:FreeGameOver()
    print("免费游戏结束")
end
 --当前游戏一此完整的旋转结束
function Game465:GameState_GameOver(isfreeover)
    self._infree = false
    local datapacket = self.datas.normalPacket
    if FCasinoCtx.curGameMode == FGameMode.FREE then
        datapacket = self.datas.freeSpinPacket
    end
    if isfreeover then
        FCasinoCtx:SetSpinStatus(FSpinStatus.WAITING)
        FToolSet.StopBGM()
        FToolSet.PlayFGUISound("ui://Game465/fgend")
        StartOnceTimer(function ()
            self.otherPanel:SetCount()
            local AllWinCoin = self._winCoin
            self._winCoin = 0
            FCasinoCtx.commonPanel:SetWinMoney(0)
            local second = self:ShowBottomWin(false,AllWinCoin)
            self.slotContainers[SlotType.Free]:StopShowLine()
            self.slotContainers[SlotType.Free]:SetFreeIconType(0)
            self.slotContainers[SlotType.Free]:SetIsEnterFree(false)
            self.otherPanel:showsilkbagpanel()
            self.otherPanel:showflowerpanel()
            self:OnNormalSpinResult(self.datas.normalPacket,true,function () end)
            self.slotContainers[SlotType.Normal]:HandleWinDatas(self.datas.normalPacket.lines)
            self.freeIconInfo = {}--免费图标
            self.slotContainers[SlotType.Normal]:DrawLineAndCollectScores(true)
            self:SetAutoSpinSecond(second)
            self:Coin_Roll_Function(function ()
                FCasinoCtx:SetSpinStatus(FSpinStatus.SPIN)
                print("开始结算金额")
                FCasinoCtx:SetPlayerMoneyInfo(datapacket)
                FCasinoCtx:SyncPlayerMoneyDisplay(2)
                if FCasinoCtx.isAutoSpin then
                    self:DelayCallSpin(2)
                end
            end)
        end,2)
    else
        local winCoin = self.slotContainers[SlotType.Normal]:GetWinCoin()
        if FCasinoCtx.isAutoSpin then
            FCasinoCtx:SetSpinStatus(FSpinStatus.SPIN)
            self:DelayCallSpin( self:GetAutoSpinSecond()+1)
        else
            if winCoin > 0 then
                self:Coin_Roll_Function(function ()
                    FCasinoCtx:SetSpinStatus(FSpinStatus.SPIN)
                    if FCasinoCtx.isAutoSpin then
                        self:DelayCallSpin(2)
                    end
                end)
            else
                FCasinoCtx:SetSpinStatus(FSpinStatus.SPIN)
            end
        end
        FCasinoCtx:SetPlayerMoneyInfo(datapacket)
        FCasinoCtx:SyncPlayerMoneyDisplay(2)
    end
end
function Game465:EnterFreeSelect(freeintofree,recover)
    local func = function ()
        FCasinoCtx:SetSpinStatus(FSpinStatus.WAITING)
        self:StopAllcoin_sound_wincoin()
        self:StopActionAndWinlines()
        if recover then
            self.selectPanel:enterfreeselect(true)
        else  
            self.slot:GetTransition("fadeout"):Play(function ()
                self.selectPanel:enterfreeselect()
                --免费中奖免费清除红包标志 只有一次
                if freeintofree then
                    self.otherPanel:SetCount()
                    self.otherPanel:showredbagPanel()
                end
            end)
        end
    end
    if freeintofree then
        func()
        return
    end
    self:Coin_Roll_Function(function ()
        func()
    end)
    FCasinoCtx:SetSpinStatus(FSpinStatus.STOP)
end
function Game465:EnterFreeGame()
    print("开始准备免费游戏滚动")
    self:ChangeBgm(MusicCfg.SND_Fea_BGM)
    FCasinoCtx:SetSpinStatus(FSpinStatus.WAITING)
    self.slot:GetTransition("fadein"):Play(function ()
        FCasinoCtx:SetSpinStatus(FSpinStatus.SPIN)
        self:DelayCallSpin(0.1)
    end)
    self:ChangeGameType(SlotType.Free)
    local win = self.slotContainers[SlotType.Normal]:GetWinCoin()
    if self._infree then
        win = self.slotContainers[SlotType.Free]:GetWinCoin()
    end
    local freeiconarr = {[25] = 1,[20] = 2,[15] = 3,[13] = 4,[10] = 5,[0] = 0}
    self.slotContainers[SlotType.Free]:SetFreeIconType(freeiconarr[self.datas.selectpacket.type]) 
    self.slotContainers[SlotType.Free]:ResetDatas(0,self.datas.selectpacket.type,win)
    self.slotContainers[SlotType.Free]:InitIcondata()
end
-- @brief 处理免费游戏旋转结果
-- @param quickSet 直接设置跳过动画
function Game465:OnFreeSpinResult(spinData, quickSet, callback,allwinCount)
    print("处理free包数据")
    Utils.printLine(spinData.grids)
    self:ChangeGameType(SlotType.Free)
    self._wildchange = spinData.changeWilds
    self._changeBacks = spinData.changeBacks
    if quickSet then
        self.slotContainers[self.curGameType]:SetOpen(true)
    else
        --处理中奖线数据
        self.slotContainers[self.curGameType]:HandleWinDatas(spinData.lines)
    end
    --处理格子数据
    self.slotContainers[self.curGameType]:HandleCellDatas(spinData.grids,true)
    --根据服务器格子数据设置最终停止数据,设置旋转结束回调函数
    self.slotContainers[self.curGameType]:SetReelSymbolData(function ()
        self.isSpined = false
        -- 快速设定图形数据 不进行免费特殊判断
        if callback then
            callback()
            return
        end
        self:SpinEndCallFunc()
    end,quickSet,allwinCount)
end
-- 自动旋转
function Game465:DelayCallSpin(delay,cb)
    print("kaiqi自动旋转")
    self:StopDelayCallSpin()
    self.callSpinTimer = StartOnceTimer(function()
        if cb then
            cb()
        end
        FCasinoCtx:SimulateSpinClick()
    end, delay)
end

function Game465:StopDelayCallSpin()
    if self.callSpinTimer then
        StopTimer(self.callSpinTimer)
        self.callSpinTimer = nil
    end
end
-- 转换游戏类型
function Game465:ChangeGameType(slotType,bgcolor)
    print('转换游戏类型',slotType,"  self.curGameType",self.curGameType)
    if self.curGameType == slotType then return end
    if self.slotContainers[self.curGameType] then
        self.slotContainers[self.curGameType]:SetVisible(false)
       
    end
    self.curGameType = slotType
    if SlotType.Normal == slotType then
        FCasinoCtx:SetGameMode(FGameMode.NORMAL)
    elseif SlotType.Free == slotType then
        FCasinoCtx:SetGameMode(FGameMode.FREE)
    end
    self.slotContainers[self.curGameType]:SetVisible(true)
end

-- 停止普通游戏的动画和中奖线
function Game465:StopActionAndWinlines()
    if FCasinoCtx.curGameMode == FGameMode.NORMAL then
        self.slotContainers[SlotType.Normal]:StopShowLine()
        self.slotContainers[SlotType.Normal]:RemoveTopSymbol()
    elseif FCasinoCtx.curGameMode == FGameMode.FREE then
        self.slotContainers[SlotType.Free]:StopShowLine()
       self.slotContainers[SlotType.Free]:RemoveTopSymbol()
    end
end

function Game465:ShowBottomWin(quickSet,winCoin)
    local winCoin = winCoin or self.slotContainers[self.curGameType]:GetWinCoin()
    print("开始滚动金币",winCoin)
    local second = 0.01
    if not quickSet then
        local lastWinCoin = self._winCoin
        local addCoin = winCoin - lastWinCoin
        print("从self._winCoin，",self._winCoin," zengji ",addCoin)
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
            --滚动金币是停止背景音效
            if self.soundBgm then
                FToolSet.StopBGM()
            end
            if not self._infree then
                self.soundWinCoinEffectHandle = FToolSet.PlayFGUISound(audioData.url)
            else
                if self.silkbaganim then
                    FToolSet.PlayFGUISound("ui://Game465/bonusprize")
                else
                    self:ChangeBgm("ui://Game465/BonusRollup")
                end
            end
            second = audioData.time
            self.soundWinCoinEffectHandleTimer = StartOnceTimer(
                function ()
                    if self.render then
                        self.soundWinCoinEffectHandle = nil
                   end
                   self.soundWinCoinEffectHandleTimer = nil
                    -- if self.soundBgm then
                    --     FToolSet.PlayBGM(self.soundBgm,true)
                    -- end
                    self.tips:HideTips()
                    self:ChangeBgm()
                    if self._infree then
                        FToolSet.PlayBGM(MusicCfg.SND_Fea_BGM,true)
                        if not self.silkbaganim  then
                            FToolSet.PlayFGUISound("ui://Game465/BonusRollupTerm")
                        end
                    end
                end
            ,second)

            if multiply >= 5 then -- 较大价值奖励抛金币
                self.tips:ShowTips(addCoin,second,multiply)
                -- self.coinFountain:Play(nil,CoinFountain.Anims[2])
                -- self.CoinFountainTimer = StartOnceTimer(
                --     function ()
                --         self.coinFire.visible = false
                --     end
                -- ,second)
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

function Game465:ChangeBgm(url)
    print("播放背景音效",url , " self.soundBgm",self.soundBgm)
    if self.soundBgm == url then
        return
    end
    if self.soundBgm then
        FToolSet.StopBGM()
        self.soundBgm = nil
    end
    if not url then
        return
    end
    FToolSet.PlayBGM(url,true)
    self.soundBgm = url
end
return Game465