
 local NormalSlot       = Import(".Slot.NormalSlot")
local FreeSlot        = Import(".Slot.FreeSlot")
local Utils          = Import(".Slot.Utils")
local MusicCfg = Import(".Slot.MusicCfg")
local CaijinPanel = Import(".CaijinPanel")
local SelectPanel = Import(".Slot.FreePanel")
local SpecialPanel = Import(".Slot.SpecialPanel")
local OtherPanel = import(".Slot.OtherPanel")
local WinLineConfigs = Import(".Cfgs.WinLineConfigs")
local WinLines = require("FGame.Common.Logic.General.WinLines") -- 引用
local Tips = import(".Slot.Tips")
local CoinFountain      = require("FGame.Common.Logic.Effect.CoinFountain")

local SlotType = {
    Normal      = 1,    -- 普通类型
    Free        = 2,    -- 免费游戏
}

local Game479 = Class("Game479", BaseGame)

function Game479:ctor(render)
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
    self.caijinPanel = CaijinPanel.New(self.render:GetChild("CaijinPanel"),self)
    self.otherPanel = OtherPanel.New(self.render:GetChild("OtherPanel"),self)
    self.selectPanel = SelectPanel.New(self.render:GetChild("SelectPanel"),self)
    self.tips =  Tips.New(self.render:GetChild("BigwinTip"),self)
    self.tips.sortingOrder = 1000
    self:ChangeGameType(SlotType.Normal)
    self.coinFountain = CoinFountain.New(self.render)
    self.coinFountain:SetSortingOrder(10)
    self.winLines = WinLines.New(self.slot:GetChild("WinLines"), WinLineConfigs.Lines)
    self.CoinFountainTimer = nil
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
    self.Jpwinicon = {}--Jp彩金图标
    self.Jpwinnumber = 0--jp彩金值
    self.wildIconInfo = {}--wildicon图标音效
    self.startReel_count = 0 --彩金预警增加格子距离音效
    self.tingpaianimarr = {}
    for i = 1, 4 do
        local anim = self.slot:GetChild("n"..12+i)
        table.insert(self.tingpaianimarr,anim)
    end
    self:Test(function ()
        -- FCasinoCtx.commonPanel.bottomPanel.render.visible = false
        -- FCasinoCtx.commonPanel.bottomPanel.render.xy = vec2(0,-60)
        -- print("FCasinoCtx.commonPanel.bottomPanel.render.x",FCasinoCtx.commonPanel.bottomPanel.render.x,FCasinoCtx.commonPanel.bottomPanel.render.y)
        -- self.otherPanel:CreateFreeEnterBoard(20)
        -- self.selectPanel:enterfreeselect({openlist = {20,15,15,20,15},ohterlist
        --  = {11,5,11,7,10,20,15,15,10,7,5,20,15,7,5,-1,15},freeTime = 15})
        -- self.otherPanel:CreateJpWinBoard(1000000000)
    end)
    -- self:ChangeBgm("ui://Game479/ngbgm")
end

function Game479:Test(fuc_)
    StartOnceTimer(fuc_,2)
end
---功能函数
--金币滚动是切换停止按钮 处理停止按钮点击回调函数
function Game479:Coin_Roll_Function(callfunc)
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
function Game479:InGameFree()
    if FCasinoCtx.curGameMode == FGameMode.FREE then
        return true
    end
    return false
end
--是否是普通游戏
function Game479:InGameNormal()
    if FCasinoCtx.curGameMode == FGameMode.NORMAL then
        return true
    end
    return false
end
function Game479:__delete()
    self:StopDelayCallSpin()
    for i = 1, 2  do -- 3  4 共用
        self.slotContainers[i]:Delete()
    end
    if self.soundBgmHandle then
        APIGateway.StopSound(self.soundBgmHandle)
        self.soundBgmHandle = nil
    end
    self.caijinPanel:Delete()
    self.otherPanel:Delete()
    self.tips:Delete()
    self.coinFountain:Delete()
    self.winLines:Delete()
    if self.CoinFountainTimer then
        StopTimer(self.CoinFountainTimer)
        self.CoinFountainTimer = nil
    end
end

-- @interface
-- @brief update
function Game479:Update(dt)
    Game479.super.Update(self, dt)
    for i = 1, 2 do -- 3  4 共用
        self.slotContainers[i]:Update(dt)
    end
end
function Game479:SetAutoSpinSecond(second)
    self._autoSpinSecond = second
end
function Game479:GetAutoSpinSecond()
    return self._autoSpinSecond 
end
-- @interface
-- @brief 在游戏中断线重连恢复游戏
-- @param local  断线重连数据
function Game479:ReconnectRecoveryGame(data, isInitialize)
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
            if self.datas.normalPacket.intoFree == 1 then
                FCasinoCtx:SetSpinStatus(FSpinStatus.WAITING)
                self:SendPackage(1) 
            end
        else
            print("断网数据是一样")
            if self.isSpined then -- 已经在特殊游戏了
                    self:SendPackage() 
                return
            end
            if self.datas.normalPacket.intoFree == 1 then
                self:SendPackage(1) 
            end
        end
        return
    elseif data.type == 2 then
        local norspinData = data.resumedNormal.normalSpin
        --免费中处理普通包中奖线
        self.slotContainers[SlotType.Normal]:HandleWinDatas(norspinData.lines)
        if not self:CheckSlotData(norspinData.girds, SlotType.Free) then
            self.datas.normalPacket = data.resumedNormal.normalSpin
            local selectdata = data.freeType.freeType
            self.datas.selectpacket = selectdata
            self:ShowBottomWin(true,data.currentWinCoin)
            if #data.cells < #self.datas.selectpacket.openlist then
                FCasinoCtx:SetSpinStatus(FSpinStatus.WAITING)
                self.selectPanel:enterfreeselect(selectdata,data.cells)
            else
                self.slotContainers[SlotType.Free]:ResetDatas(0,selectdata.freeTime,data.currentWinCoin)
                self:ChangeGameType(SlotType.Free)
                self.slotContainers[SlotType.Free]:InitIcondata()
                self:ChangeBgm(MusicCfg.SND_Fea_BGM)
                FCasinoCtx:SetSpinStatus(FSpinStatus.SPIN)
                self:DelayCallSpin(0.5)
            end
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
            self.slotContainers[SlotType.Free]:ResetDatas(freedata.totalCount,freedata.allCount,data.currentWinCoin)
            self:OnFreeSpinResult(spinData, true,function () end)
            if freedata.totalCount == freedata.allCount then
                print("断线重连免费游戏结束")
                self.otherPanel:SetCount()
                --没次数了
                self:OnNormalSpinResult(norspinData, true,function ()  end)
                return
            end
            --self.slot:GetTransition("changefree"):Play()
            self:ShowBottomWin(true,data.currentWinCoin)
            self:ChangeBgm(MusicCfg.SND_Fea_BGM)
            --恢复动画效果
            FCasinoCtx:SetSpinStatus(FSpinStatus.SPIN)
            self:DelayCallSpin(3)
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
function Game479:CheckSlotData(grids, type)
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
function Game479:StopAllcoin_sound_wincoin()
    self:StopDelayCallSpin()
    --停止播放收分音效
    if self.soundWinCoinEffectHandle then
        APIGateway.StopSound(self.soundWinCoinEffectHandle)
        self.soundWinCoinEffectHandle = nil
    end
    if self.CoinFountainTimer then
        self.coinFountain:Stop()
        StopTimer(self.CoinFountainTimer)
        self.CoinFountainTimer = nil
    end
end

-- @interface
-- @brief 点击开始按钮ftes
function Game479:OnClickSpin()
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
    FToolSet.PlayFGUISound("ui://Game479/reel_click" )
     -- 金币不足
    if FCasinoCtx.curGameMode == FGameMode.NORMAL and
     not FCasinoCtx:PlayerSpinConsumption() then
        return
    end
    self.winLines:StopBlinkLine()
    self:StopActionAndWinlines()
   if FCasinoCtx.curGameMode == FGameMode.NORMAL then
        self.datas.freeSpinPacket = nil
        self.datas.specialPacket = nil
        -- 清空本轮赢分
        FCasinoCtx.commonPanel:StopScrollWinMoney(0, false)
        self._winCoin = 0
        self:ChangeGameType(SlotType.Normal)
        self.slotContainers[SlotType.Normal]:SpinStart()
    elseif FCasinoCtx.curGameMode == FGameMode.FREE then
        self:ChangeGameType(SlotType.Free)
        self.slotContainers[SlotType.Free]:SpinStart()
        --self:ChangeBgm(MusicCfg.SND_Fea_BGM)
    end
    self.caijin_type,self.smallecaijin = 0 ,0
    --发送包数据
    self:SendPackage()
    self.isSpined = true
end
--发送包数据
function Game479:SendPackage(index)
    if index then
        print("发送免费选择包数据")
        local request = {
            _msgName_ = "PB.Client_Slots.PandaTreasuresFreeType",
        }
        APIGateway.SendExactRequest(request, "PB.Slots_Client.PandaTreasuresFreeRetType",
            function(ok, result)
                if not ok then return end
                self.datas.selectpacket = result.freeType
                dump(result,"SPECIAL",4)
                self.selectPanel:enterfreeselect(result.freeType)
            end
        )
        return
    end
    if FCasinoCtx.curGameMode == FGameMode.NORMAL then
        print("发送普通包数据")
        self:SendNormalSpin("PB.Client_Slots.PandaTreasuresNormalSpin", "PB.Slots_Client.PandaTreasuresNormalRet",
            function(ok, result)
                if not ok then return end
                -- dump(result,"NORMAL",10)
                self.datas.normalPacket = result.normalSpin
                self:OnNormalSpinResult(result.normalSpin)
            end
        )
    elseif FCasinoCtx.curGameMode == FGameMode.FREE then
        print("发送免费包数据")
        local request = {
            _msgName_ = "PB.Client_Slots.PandaTreasuresFreeSpin"
        }
        APIGateway.SendExactRequest(request, "PB.Slots_Client.PandaTreasuresFreeRet",
            function(ok, result)
                if not ok then return end
                dump(result.freeSpin)
                self.datas.freeSpinPacket = result.freeSpin
                self:OnFreeSpinResult(result.freeSpin)
            end
        )
    end
end

--点击停止按钮
function Game479:OnClickStop()
    if self.startReel_count > 0 then return end
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
        if self.soundBgm then
            FToolSet.PlayBGM(self.soundBgm,true)
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
function Game479:OnNormalSpinResult(spinData, quickSet, customCallback,allwinCount)
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
    if not quickSet  then
        self.slotContainers[self.curGameType]:AssDistance()
    end
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
function Game479:SpinEndCallFunc()
    FCasinoCtx:SetSpinStatus(FSpinStatus.WAITING)
    self.isSpined = false
    --处理免费和彩金入场音效动画
    if #self.freeIconInfo >= 3 then
        FToolSet.PlayFGUISound("ui://Game479/bonus")
        self.slotContainers[self.curGameType]:PlayTablelist(self.freeIconInfo)
        StartOnceTimer(function ()
            if self:InGameFree() then
                self.slotContainers[SlotType.Free]:SetAllTurns(self.datas.freeSpinPacket.allCount)
            end
            self:GameState_EndDraw()
        end,2)
    elseif #self.Jpwinicon >= 5 then
        FToolSet.PlayFGUISound("ui://Game479/zhayao")
        self.slotContainers[self.curGameType]:PlayTablelist(self.Jpwinicon)
        StartOnceTimer(function ()
            -- self.otherPanel:CreateJpWinBoard(self.Jpwinnumber,function ()
                if self:InGameFree() then
                    self:ChangeBgm(MusicCfg.SND_Fea_BGM)
                else
                    -- self:ChangeBgm("ui://Game479/ngbgm")
                end
                self:GameState_EndDraw()
            -- end)
        end,2)
    elseif #self.wildIconInfo > 0 then
        FToolSet.PlayFGUISound("ui://Game479/wild")
        self.slotContainers[self.curGameType]:PlayTablelist(self.wildIconInfo)
        StartOnceTimer(function ()
            self:GameState_EndDraw()
        end,2)
    else
        self:GameState_EndDraw()
    end
end
--绘制中奖线播放中奖动画 收分
function Game479:GameState_EndDraw(isfree,freecallback)
    local second = self.slotContainers[self.curGameType]:DrawLineAndCollectScores()
    self:SetAutoSpinSecond(second)
    self:GameState_HandleSpecial(isfree,freecallback)
end
--处理特殊游戏
function Game479:GameState_HandleSpecial(isfree,freecallback)
   
    self:GameState_HandleFreeTime(isfree)
end

function Game479:EnterSpecialGame(isFreeToSpecial)
    self:Coin_Roll_Function(function ()
        local freedata = self.datas.freeSpinPacket
        FCasinoCtx:SetSpinStatus(FSpinStatus.SPIN)
        if freedata.totalCount == freedata.allCount then
            self:GameState_GameOver(true)
        else
            FCasinoCtx:SetSpinStatus(FSpinStatus.SPIN)
            self:DelayCallSpin(2)
        end
    end)
end
function Game479:SpecialOver(isFreeToSpecial)
    self:Coin_Roll_Function(function ()
        FCasinoCtx:SetSpinStatus(FSpinStatus.SPIN)
        if isFreeToSpecial then
            self:ChangeBgm(MusicCfg.SND_Fea_BGM)
            local freedata = self.datas.freeSpinPacket
            if freedata.totalCount == freedata.allCount then
                self:GameState_GameOver(true)
            else
                FCasinoCtx:SetSpinStatus(FSpinStatus.SPIN)
                self:DelayCallSpin(2)
            end
        else
            self:ChangeBgm()
            if FCasinoCtx.isAutoSpin then
                self:DelayCallSpin(2)
            end
        end
    end)
    local allwin = self.specialwinnumber + self.slotContainers[self.curGameType]:GetWinCoin()
    local second = self:ShowBottomWin(false,allwin)
    self:SetAutoSpinSecond(second)
    if not isFreeToSpecial then
        print("特殊游戏回到普通游戏结算金额")
        FCasinoCtx:SetPlayerMoneyInfo(self.datas.normalPacket)
        FCasinoCtx:SyncPlayerMoneyDisplay(2)
    else
        local freedata = self.datas.freeSpinPacket
        self.slotContainers[SlotType.Free]:ResetDatas(freedata.totalCount,freedata.allCount,allwin)
    end
end
--处理免费游戏
function Game479:GameState_HandleFreeTime(isfree)
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
function Game479:FreeAddGame()
    self.slotContainers[SlotType.Free]:SetAllTurns(self.datas.freeSpinPacket.allCount)
    self:GameState_SingleRoundFreeGameOver()
end
--免费游戏单轮结束
function Game479:GameState_SingleRoundFreeGameOver()
    --有中奖线的时候
    print("单轮免费游戏结束")
    self:Coin_Roll_Function(function ()
        local freedata = self.datas.freeSpinPacket
        FCasinoCtx:SetSpinStatus(FSpinStatus.SPIN)
        if freedata.totalCount == freedata.allCount then
            FCasinoCtx:SetSpinStatus(FSpinStatus.WAITING)
            -- self.otherPanel:CreateEndWinBoard(self._winCoin,function ()
                self:GameState_GameOver(true)
            -- end)
        else
            FCasinoCtx:SetSpinStatus(FSpinStatus.SPIN)
            self:DelayCallSpin(2)
        end
    end)
end
function Game479:FreeGameOver()
    print("免费游戏结束")
    -- self.otherPanel:CreateEndWinBoard(self._winCoin,function ()
        self:GameState_GameOver(true)
    -- end)

end
 --当前游戏一此完整的旋转结束
function Game479:GameState_GameOver(isfreeover)
    local datapacket = self.datas.normalPacket
    if FCasinoCtx.curGameMode == FGameMode.FREE then
        datapacket = self.datas.freeSpinPacket
    end
    if isfreeover then
        FCasinoCtx:SetSpinStatus(FSpinStatus.WAITING)
        StartOnceTimer(function ()
            self:ChangeBgm()
            self.otherPanel:SetCount()
            local AllWinCoin = self._winCoin
            self._winCoin = 0
            FCasinoCtx.commonPanel:SetWinMoney(0)
            local second = self:ShowBottomWin(false,AllWinCoin)
            self.slotContainers[SlotType.Free]:StopShowLine()
            self.winLines:StopBlinkLine()
            self.slotContainers[SlotType.Free]:SetIsEnterFree(false)
            self:OnNormalSpinResult(self.datas.normalPacket,true,function () end)
            self.slotContainers[SlotType.Normal]:HandleWinDatas(self.datas.normalPacket.lines)
            self.slotContainers[SlotType.Normal]:DrawLineAndCollectScores(true)
            --self.slot:GetTransition("changenormal"):Play()
            self:SetAutoSpinSecond(second)
            self:Coin_Roll_Function(function ()
                FCasinoCtx:SetSpinStatus(FSpinStatus.SPIN)
                print("开始结算金额")
                FCasinoCtx:SetPlayerMoneyInfo(datapacket)
                FCasinoCtx:SyncPlayerMoneyDisplay(2)
                if FCasinoCtx.isAutoSpin then
                    self:DelayCallSpin(2)
                end
                -- self:ChangeBgm("ui://Game479/ngbgm")
            end)
        end,1)
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
function Game479:EnterFreeSelect()
    self:Coin_Roll_Function(function ()
        FCasinoCtx:SetSpinStatus(FSpinStatus.WAITING)
        self:StopAllcoin_sound_wincoin()
        self:StopActionAndWinlines()
        self:SendPackage(1)
    end)
    FCasinoCtx:SetSpinStatus(FSpinStatus.STOP)
end
function Game479:EnterFreeGame(isshowboard)
    print("开始准备免费游戏滚动")
    FCasinoCtx:SetSpinStatus(FSpinStatus.WAITING)
    self.otherPanel:CreateFreeEnterBoard(self.datas.selectpacket.freeTime,2,function ()
        self:ChangeBgm(MusicCfg.SND_Fea_BGM)
        self:ChangeGameType(SlotType.Free)
        FCasinoCtx:SetSpinStatus(FSpinStatus.SPIN)
        self:DelayCallSpin(0.1)
    end)
    local win = self.slotContainers[SlotType.Normal]:GetWinCoin()
    self.slotContainers[SlotType.Free]:ResetDatas(0,self.datas.selectpacket.freeTime,win)
    self.slotContainers[SlotType.Free]:InitIcondata(self.datas.normalPacket.grids)
end
-- @brief 处理免费游戏旋转结果
-- @param quickSet 直接设置跳过动画
function Game479:OnFreeSpinResult(spinData, quickSet, callback,allwinCount)
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
    if not quickSet  then
        self.slotContainers[self.curGameType]:AssDistance()
    end
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
function Game479:DelayCallSpin(delay,cb)
    print("kaiqi自动旋转")
    self:StopDelayCallSpin()
    self.callSpinTimer = StartOnceTimer(function()
        if cb then
            cb()
        end
        FCasinoCtx:SimulateSpinClick()
    end, delay)
end

function Game479:StopDelayCallSpin()
    if self.callSpinTimer then
        StopTimer(self.callSpinTimer)
        self.callSpinTimer = nil
    end
end
-- 转换游戏类型
function Game479:ChangeGameType(slotType,bgcolor)
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
function Game479:StopActionAndWinlines()
    if FCasinoCtx.curGameMode == FGameMode.NORMAL then
        self.slotContainers[SlotType.Normal]:StopShowLine()
        self.slotContainers[SlotType.Normal]:RemoveTopSymbol()
    elseif FCasinoCtx.curGameMode == FGameMode.FREE then
        self.slotContainers[SlotType.Free]:StopShowLine()
       self.slotContainers[SlotType.Free]:RemoveTopSymbol()
    end
end

function Game479:ShowBottomWin(quickSet,winCoin)
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
            
            self.soundWinCoinEffectHandle = FToolSet.PlayFGUISound(audioData.url)
            --滚动金币是停止背景音效
            if self.soundBgm then
                FToolSet.StopBGM()
            end
            second = audioData.time
            self.soundWinCoinEffectHandleTimer = StartOnceTimer(
                function ()
                    if self.render then
                        self.soundWinCoinEffectHandle = nil
                   end
                   self.soundWinCoinEffectHandleTimer = nil
                   if self.soundBgm then
                        FToolSet.PlayBGM(self.soundBgm,true)
                    end
                    self.tips:HideTips()
                end
            ,second)

            if multiply >= 5 then -- 较大价值奖励抛金币
                -- self.tips:ShowTips(addCoin,second,multiply)
                self.tips:ShowTips(audioData.bigWinLevel,addCoin,second)
                self.coinFountain:Play(nil,CoinFountain.Anims[2])
                self.CoinFountainTimer = StartOnceTimer(
                    function ()
                        if self.coinFountain then
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

function Game479:ChangeBgm(url)
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
return Game479