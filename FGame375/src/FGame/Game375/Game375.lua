
local NormalSlot                    = Import(".Slot.NormalSlot")
local FreeSlot                      = Import(".Slot.FreeSlot")
local TopupBounsSlot_Controller     = Import(".Slot.TopupBounsSlot_Controller")
local MusicCfg                      = Import(".Slot.MusicCfg")
local WinLines                      = Import(".Slot.WinLines")
local Game375                       = Class("Game375", BaseGame)
local CaijinPanel                   = Import(".Slot.CaijinPanel")
local CoinFlyAnim                   = Import(".Slot.CoinFlyAnim")
local Tools                         = Import(".Slot.Tools")
local SelectFreeMode                = Import(".Slot.SelectFreeMode")
local Win_Car_Node                  = Import(".Slot.Win_Car_Node")
local Enter_Free_Game               = Import(".Slot.Enter_Free_Game")

Game375.Reel_Container = {
    [1] = "1x_slot_3x5",
    [2] = "2x_slot_3x5",
    [3] = "1x_slot_3x7",
    [4] = "2x_slot_3x7",
}

function Game375:ctor(render)
    self.render = render
    self.game_node = render:GetChild("Game_Node")
    local cfg = clone(FCasinoCtx.gameCfg.Reel)
    self.slotContainers = {}
    self.normal_slot_ = self.game_node:GetChild("3x5_down")
    --普通游戏(普通游戏只会是下方3x5)
    self.slotContainers[FGameMode.NORMAL] = NormalSlot.New(self.normal_slot_:GetChild("slot"),self)
    self.slotContainers[FGameMode.NORMAL]:SetVisible(false)
    --免费游戏(免费游戏只会是下方3x5)
    self.slotContainers[FGameMode.FREE] = FreeSlot.New(self.normal_slot_:GetChild("slot"),self)
    self.slotContainers[FGameMode.FREE]:SetVisible(false)
    --落地牌
    self.slotContainers[FGameMode.SPECIAL] = TopupBounsSlot_Controller.New(self.game_node, self)
    self.slotContainers[FGameMode.SPECIAL]:SetVisible(false)
    --彩金
    self.caijinPanel = CaijinPanel.New(self.render:GetChild("CaiJin_Panel"))
    --中奖线界面
    self.winline = WinLines.New(self,cfg)

    self:SetGameMode(FGameMode.NORMAL)
    self:ChangeControllerState("normal")
    self:ChangeSlotControllerState(self.Reel_Container[1])
    self:ChangeNormalSlotControllerState("normal")
    self:SetBGM("normal")

    --旋转结果
    self.datas = {
        normalPacket = nil, -- 普通旋转结果
        freeSpinPacket = nil , -- 免费旋转结果
        curSpecialSpinResult = nil, --落地牌旋转结果
    }
    self.entranceSound = FToolSet.PlayFGUISound(MusicCfg._88F_SLOT_INTRO)

    --左钻石喷口
    self.ZSFlyAnim_Left = CoinFlyAnim.New(self.render,vec2(-90,843),1/25)
    self.ZSFlyAnim_Left:SetSortingOrder(10)
    --右钻石喷口
    self.ZSFlyAnim_Right = CoinFlyAnim.New(self.render,vec2(810,843),1/25)
    self.ZSFlyAnim_Right:SetSortingOrder(10)
    --金块喷泉
    self.CoinFlyAnim = CoinFlyAnim.New(self.render,nil,1/3)
    self.CoinFlyAnim:SetSortingOrder(10)
    -- 火车动画节点
    self.Win_Car_Node = Win_Car_Node.New(self.render:GetChild("Win_Car_Node"))
    
    -- 监听旋转请求超时或者不是预期回包
    FSysEventEmitter:AddListener(FSysEvent.ON_NET_DISCONNECT, function()
        self.datas.normalPacket     = nil
        self.datas.freeSpinPacket   = nil
        self.datas.curSpecialSpinResult = nil
    end, self)

    self._winCoin = 0
end

function Game375:__delete()
    self:StopDelayCallSpin()
    for i = 1, #self.slotContainers do
        self.slotContainers[i]:Delete()
    end

    if self.soundWinCoinEffectHandle then
        APIGateway.StopSound(self.soundWinCoinEffectHandle)
        self.soundWinCoinEffectHandle = nil
    end
    if self.TakeABreaktimer then
        StopTimer(self.TakeABreaktimer)
        self.TakeABreaktimer = nil
        self.TakeABreakCallBack = nil
    end
    if self.TakeABreaktimer2 then
        StopTimer(self.TakeABreaktimer2)
        self.TakeABreaktimer2 = nil
        self.TakeABreakCallBack = nil
    end
    self.winline:Delete()
    self.Win_Car_Node:Delete()
    self.CoinFlyAnim:Delete()
    self.ZSFlyAnim_Left:Delete()
    self.ZSFlyAnim_Right:Delete()
    self.caijinPanel:Delete()
    self:StopEntranceSound()

    FTween.KillTweens(self.render)
    
    self.render = nil
end

-- @interface
-- @brief update
function Game375:Update(dt)
    Game375.super.Update(self, dt)
    for i = 1, #self.slotContainers do 
        self.slotContainers[i]:Update(dt)
    end
    if self.Win_Car_Node then
        self.Win_Car_Node:UpdateCarPos()
    end
end

--切换控制器(str_:大游戏类型，type_:1普通和2免费类型)
function Game375:ChangeControllerState(str_)
    --控制背景等
    self.render:GetController("game_state").selectedPage = str_
    local image = self.game_node:GetChild("n6")
    image.visible = (str_ == "special")
    if str_ == "free" then
       return 
    end
    self.caijinPanel:ChangeControllerState(str_)
end

--切换转盘的控制器，控制转盘显示(只有3x5down转盘需要控制)
function Game375:ChangeSlotControllerState(type_)
    self.game_node:GetController("slot_state").selectedPage = type_
end

--切换转盘框的控制器，控制转盘框的显示
function Game375:ChangeNormalSlotControllerState(type_)
    self.normal_slot_:GetController("game_state").selectedPage = type_
end

-- @interface
-- @brief 在游戏中断线重连恢复游戏
-- @param local  断线重连数据
function Game375:ReconnectRecoveryGame(data, isInitialize)
    dump(data,"ReconnectRecoveryGame",5)
    -- 断线重连标记
    self.isReconnect = true
    local lastmoney = data.currentWinCoin
    --type 1普通，中SC但还未选择，或者中落地牌但还未转动过
    --2已选择过，但还未转动
    --3免费中已经转过
    --4落地牌已经转过
    --5免费中落地牌已经转过
    if data.type == 1 then
        self._entertype = FGameMode.NORMAL
        self:SetBGM("normal")
        local resumedNormal = data.resumedNormal.normalSpin
        self:OnNormalSpinResult(resumedNormal,lastmoney)
    elseif data.type == 2 then
        self._entertype = FGameMode.NORMAL
        if isInitialize then
            self:StopEntranceSound()
        end
        local resumedNormal = data.resumedNormal.normalSpin
        local freeType = data.resumedFreetype.freetype
        if freeType.type == 2 then
            self.slotContainers[FGameMode.FREE]:SetLastReelSymbolData()
        end
        --普通和免费和特殊用的不同转盘，所以普通数据也要恢复
        self.slotContainers[FGameMode.NORMAL]:SetLastReelSymbolData(resumedNormal.grids)
        self.slotContainers[FGameMode.NORMAL]:SetWinCoin(lastmoney)
        self:ShowBottomWin(true,lastmoney)
        if  freeType.type == 1 then
            self:EnterSpecialGame(resumedNormal,true,self._entertype,self.isReconnect)
        else
            self:EnterFreeGame(resumedNormal,true, self.isReconnect)
        end
    elseif data.type == 3 then
        self._entertype = FGameMode.NORMAL
        if isInitialize then
            self:StopEntranceSound()
        end
        self:SetBGM("free")
        self:SetGameMode(FGameMode.FREE)
        self:ChangeControllerState("free")
        self:ChangeSlotControllerState(self.Reel_Container[1])
        self:ChangeNormalSlotControllerState("free")
        local resumedNormal = data.resumedNormal.normalSpin
        local resumedFree = data.resumedFree.freeSpin
        -- --普通和免费用的不同转盘，所以普通数据也要恢复
        self.slotContainers[FGameMode.NORMAL]:SetLastReelSymbolData(resumedNormal.grids)
        self:OnFreeSpinResult(resumedFree,lastmoney)
    elseif data.type == 4 then
        self._entertype = FGameMode.NORMAL
        if isInitialize then
            self:StopEntranceSound()
        end
        local resumedNormal = data.resumedNormal.normalSpin
        local resumedSpecial = data.resumedSpecial.specialSpin
        self.slotContainers[FGameMode.SPECIAL]:SetSlotType(resumedNormal.trainType)
        self:SetGameMode(FGameMode.SPECIAL)
        self:ChangeSlotControllerState(self.Reel_Container[resumedNormal.trainType])
        self:SetBGM("special")
        self.slotContainers[FGameMode.NORMAL]:SetLastReelSymbolData(resumedNormal.grids)
        self:OnSpecialSpinResult(resumedSpecial,lastmoney,0)
    elseif data.type == 5 then
        self._entertype = FGameMode.FREE
        if isInitialize then
            self:StopEntranceSound()
        end
        local resumedNormal = data.resumedNormal.normalSpin
        local resumedFree = data.resumedFree.freeSpin
        local resumedSpecial = data.resumedSpecial.specialSpin
        self.slotContainers[FGameMode.SPECIAL]:SetSlotType(resumedFree.trainType)
        self:SetGameMode(FGameMode.SPECIAL)
        self:ChangeSlotControllerState(self.Reel_Container[resumedFree.trainType])
        self:SetBGM("special")
        self.slotContainers[FGameMode.NORMAL]:SetLastReelSymbolData(resumedNormal.grids)
        local free_now_wincoin = lastmoney - resumedSpecial.bonusWinCoin
        self.slotContainers[FGameMode.FREE]:ResetDatas(resumedFree.totalCount,resumedFree.allCount,free_now_wincoin,true)
        self.slotContainers[FGameMode.FREE]:SetLastReelSymbolData(resumedFree.grids)
        self:OnSpecialSpinResult(resumedSpecial,lastmoney,0)
    end
    self.isReconnect = false
end

-- @interface
-- @brief 点击开始按钮
function Game375:OnClickSpin()
    self:StopDelayCallSpin()
    self:StopBottomWin()
    if FCasinoCtx.curGameMode == FGameMode.NORMAL then
        -- 金币不足
        if not FCasinoCtx:PlayerSpinConsumption() then
            FCasinoCtx:SetSpinStatus(FSpinStatus.SPIN)
            return
        end
        self.datas.freeSpinPacket   = nil
        self.datas.curSpecialSpinResult = nil
        self._entertype = nil
        FCasinoCtx.commonPanel:StopScrollWinMoney(0, false)
        -- 清空本轮赢分
        self._winCoin = 0
        self:SetGameMode(FGameMode.NORMAL)
        self.slotContainers[self.curGameType]:SpinStart()
    elseif FCasinoCtx.curGameMode == FGameMode.FREE then
        self:SetGameMode(FGameMode.FREE)
        self.slotContainers[self.curGameType]:SpinStart()
    elseif FCasinoCtx.curGameMode == FGameMode.SPECIAL then
        self:SetGameMode(FGameMode.SPECIAL)
        self.slotContainers[self.curGameType]:SpinStart()
    end
    self:SendPackage()
end

--发送旋转包
function Game375:SendPackage()
    FCasinoCtx:SetSpinStatus(FSpinStatus.WAITING)
    if FCasinoCtx.curGameMode == FGameMode.NORMAL then
        self:SendNormalSpin("PB.Client_Slots.EurekaTrainNormalSpin", "PB.Slots_Client.EurekaTrainNormalRet",
            function(ok, result)
                if not ok then return end
                 dump(result,"NORMAL",4)
                self:OnNormalSpinResult(result.normalSpin)
            end
        )
    elseif FCasinoCtx.curGameMode == FGameMode.FREE then
        local request = {
            _msgName_ = "PB.Client_Slots.EurekaTrainFreeSpin"
        }
        APIGateway.SendExactRequest(request, "PB.Slots_Client.EurekaTrainFreeRet",
            function(ok, result)
                if not ok then return end
                 dump(result,"FREE",4)
                self:OnFreeSpinResult(result.freeSpin)
            end
        )
    elseif FCasinoCtx.curGameMode == FGameMode.SPECIAL then
        local request = {
            _msgName_ = "PB.Client_Slots.EurekaTrainSpecialSpin"
        }
        APIGateway.SendExactRequest(
            request,
            "PB.Slots_Client.EurekaTrainSpecialRet",
            function(ok, result)
                if not ok then
                    return
                end
                 dump(result,"SPECIAL",4)
                self:OnSpecialSpinResult(result.specialSpin)
            end)
    end
end

--点击停止
function Game375:OnClickStop()
    FCasinoCtx.commonPanel:StopScrollWinMoney(nil, true)
    -- 普通游戏状态点击停止按钮
    if FCasinoCtx.curGameMode == FGameMode.NORMAL then
        self.slotContainers[FGameMode.NORMAL]:QuickStop()
    elseif FCasinoCtx.curGameMode == FGameMode.FREE then
        self.slotContainers[FGameMode.FREE]:QuickStop()
    elseif FCasinoCtx.curGameMode == FGameMode.SPECIAL then
        self.slotContainers[FGameMode.SPECIAL]:QuickStop()
    end
end

-- @brief 处理普通旋转结果
-- @param isReconnect 直接设置跳过动画(断线重连进来)
function Game375:OnNormalSpinResult(spinData,currentWinCoin,customCallback)
    local isReconnect = self.isReconnect
    -- 当前正在运行的数据和断线重连下发的数据一样，直接忽略
    if isReconnect and table.equals(spinData, self.datas.normalPacket) then
        print("当前正在运行的数据和断线重连下发的数据一样，直接忽略,OnNormalSpinResult")
        return
    end
    self.datas.normalPacket = spinData
    print("处理普通旋转结果,OnNormalSpinResult")
    self:SetGameMode(FGameMode.NORMAL)
    self:Refresh()
    if isReconnect then
        print("=======OnNormalSpinResult,重连下发的数据不一样======")
        self:ShowBottomWin(true,currentWinCoin)
    end
    --重置转盘状态
    self.slotContainers[self.curGameType]:ResetState()
    --进入二选一判断
    self.slotContainers[self.curGameType]:SetIsEnter_2to1(spinData.freeType > 0 and spinData.freeType < 3)
    --进入免费判断
    self.slotContainers[self.curGameType]:SetIsEnterFree(spinData.freeType == 1)
    --进入落地牌判断
    self.slotContainers[self.curGameType]:SetIsEnterTopupBouns(spinData.freeType == 2 or spinData.freeType == 3)
    --分析格子数据
    self.slotContainers[self.curGameType]:HandleCellDatas(spinData.grids)
    --分析中奖线数据
    self.slotContainers[self.curGameType]:HandleWinDatas(spinData.lines)
    --处理结果
    self.slotContainers[self.curGameType]:SetReelSymbolData(function()
        -- 自定义回调函数
        if customCallback then
            customCallback()
            return
        end
        if spinData.freeType == 1 then
            print("------普通SC到二选一-------------")
            self:ShowSelectFreeModePanel(spinData,FGameMode.NORMAL,isReconnect)
        elseif spinData.freeType == 2 then
            print("------普通到落地牌-------------")
            self:EnterSpecialGame(spinData,false,FGameMode.NORMAL,isReconnect)
        else
            print("------普通普通-------------")
            self:SetGameMode(FGameMode.NORMAL)
            --普通游戏逻辑
            FCasinoCtx:SetPlayerMoneyInfo(spinData)
            FCasinoCtx:SyncPlayerMoneyDisplay(2)
            self:AutoClick()
            FCasinoCtx:SetSpinStatus(FSpinStatus.SPIN)
       end
    end, isReconnect)
end

-- @brief 处理免费游戏旋转结果
-- @param isReconnect 直接设置跳过动画(断线重连进来)
function Game375:OnFreeSpinResult(spinData,currentWinCoin,callback)
    local isReconnect = self.isReconnect
    -- 当前正在运行的数据和断线重连下发的数据一样，直接忽略
    if isReconnect and table.equals(spinData, self.datas.freeSpinPacket) then
        print("当前正在运行的数据和断线重连下发的数据一样，直接忽略,OnFreeSpinResult")
        return
    end
    self.datas.freeSpinPacket = spinData
    print("处理免费游戏旋转结果,OnFreeSpinResult")
    self:SetGameMode(FGameMode.FREE)
    self:Refresh()
    if isReconnect then
        print("=======OnFreeSpinResult,重连下发的数据不一样======")
        self:ChangeControllerState("free")
        self:ChangeNormalSlotControllerState("free")
        self.slotContainers[FGameMode.FREE]:ResetDatas(spinData.totalCount,spinData.allCount,currentWinCoin,false)
        self.slotContainers[FGameMode.FREE]:ShowFreeCount()
        self:ShowBottomWin(true,currentWinCoin)
    end
    --重置转盘状态
    self.slotContainers[self.curGameType]:ResetState()
    --进入免费判断
    self.slotContainers[self.curGameType]:SetIsEnterFree(spinData.addTime >= 1)
    --进入落地牌判断
    self.slotContainers[self.curGameType]:SetIsEnterTopupBouns(spinData.freeType == 2 or spinData.freeType == 3)
    --分析格子数据
    self.slotContainers[self.curGameType]:HandleCellDatas(spinData.grids)
    --分析中奖线数据
    self.slotContainers[self.curGameType]:HandleWinDatas(spinData.lines,isReconnect)
    --处理结果
    self.slotContainers[self.curGameType]:SetReelSymbolData(function()
        if callback then
            callback()
            return
        end
        local final_check = function ()
            local isEnd = spinData.totalCount == spinData.allCount
            if not isEnd then
                print("===========免费中普通===========")
                self:AutoClick()
            else
                print("===========免费结束===========")
                local changefun = function ()
                    self:SetGameMode(FGameMode.NORMAL)
                    self:ChangeControllerState("normal")
                    self:ChangeNormalSlotControllerState("normal")
                end
                local endfunc = function ()
                    self:SetBGM("normal")
                    self:AutoClick()
                    FCasinoCtx:SetPlayerMoneyInfo(spinData)
                    FCasinoCtx:SyncPlayerMoneyDisplay(2)
                end
                if isReconnect then
                    print("===========免费结束:重连===========")
                    changefun()
                    endfunc()
                    return
                end
                print("===========免费结束:正常===========")
                self:TakeABreak(function ()
                    self:StopBGM()
                    self:StopLines()
                    --FToolSet.PlayFGUISound(MusicCfg.SND_Fea_End)
                    changefun()
                    FCasinoCtx.commonPanel:StopScrollWinMoney(0, false)
                    FCasinoCtx:SetSpinStatus(FSpinStatus.STOP)
                    --免费结算
                    self:ShowBottomWin(false,spinData.bonusWinCoin,true,false,endfunc)
                end,1) 
            end
        end
        if spinData.addTime >= 1 then
            --免费中免费
            print("===========免费到免费===========")
            self:EnterFreeGame(spinData,false,isReconnect)
        elseif spinData.trainType > 0 then
            --免费中落地牌
            print("===========免费到落地牌===========")
            self:EnterSpecialGame(spinData,false,FGameMode.FREE,isReconnect)
        else
            --免费中普通游戏逻辑
            final_check()
        end
    end, isReconnect)
end

-- @brief 处理特殊游戏旋转结果
-- @param isReconnect 直接设置跳过动画(断线重连进来)
function Game375:OnSpecialSpinResult(spinData,currentWinCoin,othercoin,callback)
    local isReconnect = self.isReconnect
    -- 当前正在运行的数据和断线重连下发的数据一样，直接忽略
    if isReconnect and table.equals(spinData, self.datas.curSpecialSpinResult) then
        print("当前正在运行的数据和断线重连下发的数据一样，直接忽略,OnSpecialSpinResult")
        return
    end
    self.datas.curSpecialSpinResult = spinData
    print("处理特殊游戏旋转结果,OnSpecialSpinResult")
    self:SetGameMode(FGameMode.SPECIAL)
    self:Refresh()
    if isReconnect then
        print("=======OnSpecialSpinResult,重连下发的数据不一样======")
        if spinData.extraSpin == 1 then
            FCasinoCtx.commonPanel:ShowTop(true)
            self:ChangeControllerState("special_frist")
            self:ChangeNormalSlotControllerState("normal")
        else
            FCasinoCtx.commonPanel:ShowTop(false)
            self:ChangeControllerState("special")
            self:ChangeNormalSlotControllerState("special")
        end
        self.slotContainers[FGameMode.SPECIAL]:ResetDatas(false,spinData.allCount - spinData.totalCount,currentWinCoin,othercoin)
        self.slotContainers[FGameMode.SPECIAL]:ShowSpinNum()
        print(currentWinCoin,"========currentWinCoin==========")
        self:ShowBottomWin(true,currentWinCoin)
    end
    --重置转盘状态
    self.slotContainers[self.curGameType]:ResetState()
    --设置剩余旋转次数
    self.slotContainers[self.curGameType]:SetSpinNum(spinData.allCount - spinData.totalCount)
    --分析格子数据
    self.slotContainers[self.curGameType]:HandleCellDatas(spinData.graphs)
    --处理结果
    self.slotContainers[self.curGameType]:SetReelSymbolData(function()
        if callback then
            callback()
            return
        end
        local isEnd = (spinData.totalCount >= spinData.allCount) or (spinData.isFull == 1)
        if not isEnd then
            --二选一进入有额外的一次旋转
            if spinData.extraSpin == 1 then
                print("===========落地牌中:普通=额外旋转==========")
                self.slotContainers[self.curGameType]:PlayEnterSpecial(spinData,isReconnect,function ()
                    self:AutoClick()
                end)
            else
                print("===========落地牌中:普通===========")
                self:AutoClick()
            end
        else
            --隐藏旋转次数
            self.slotContainers[self.curGameType]:ShowSpinNum(0)
            local outgametype = nil
            local curTurn = self.slotContainers[FGameMode.FREE]:GetCurTurn()
            local allTurns = self.slotContainers[FGameMode.FREE]:GetAllTurns()
            local isfreeend = curTurn >= allTurns
            if isfreeend then
                outgametype = FGameMode.NORMAL
            else
                outgametype = FGameMode.FREE
            end
            local changefun = function ()
                print("===========落地牌结束:状态转换===========",outgametype)
                self:SetGameMode(outgametype)
                FCasinoCtx.commonPanel:ShowTop(true)
                self:ChangeSlotControllerState(self.Reel_Container[1])
                if outgametype == FGameMode.NORMAL then
                    self:ChangeControllerState("normal")
                    self:ChangeNormalSlotControllerState("normal")
                else
                    self:ChangeControllerState("free")
                    self:ChangeNormalSlotControllerState("free")
                end
            end
            local endfunc = function ()
                if isfreeend then
                    print("===========免费结束的同时,落地牌也结束了,或者普通中落地牌结束===========")
                    self:SetBGM("normal")
                    self:AutoClick()
                    FCasinoCtx:SetPlayerMoneyInfo(spinData)
                    FCasinoCtx:SyncPlayerMoneyDisplay(2)
                else
                    print("===========免费中落地牌结束,但免费还未结束===========")
                    self:SetBGM("free")
                    local free_now_wincoin = self.slotContainers[FGameMode.FREE]:GetWinCoin()
                    self.slotContainers[FGameMode.FREE]:ResetDatas(curTurn,allTurns,spinData.bonusWinCoin + free_now_wincoin,false)
                    self.slotContainers[FGameMode.FREE]:ShowFreeCount()
                    self:AutoClick()
                end
            end
            if isReconnect then
                print("===========落地牌结束:重连===========")
                self.slotContainers[FGameMode.SPECIAL]:CleanCarAnimData()
                changefun()
                endfunc()
                return
            end
            print("===========落地牌结束:正常===========")
            self:StopBGM()
            --FToolSet.PlayFGUISound(MusicCfg.SND_Fea_End)
            self.slotContainers[self.curGameType]:SpecialOver(function ()
                self:SpecialContracture(spinData,outgametype,function ()
                    if self._entertype == FGameMode.FREE and isfreeend then
                        self:StopBGM()
                        self:StopLines()
                        FCasinoCtx.commonPanel:StopScrollWinMoney(0, false)
                        FCasinoCtx:SetSpinStatus(FSpinStatus.STOP)
                        print("===========落地牌结束的同时,免费也结束了===========")
                        self:ShowBottomWin(false,spinData.AllWinCoin,true,false,endfunc)
                    else
                        endfunc()
                    end
                end)
            end)
        end
    end, isReconnect)
end

-- @brief 进入二选一处理
function Game375:ShowSelectFreeModePanel(spinData,entertype,isReconnect)
    FCasinoCtx:SetSpinStatus(FSpinStatus.WAITING)
    local fun_ = function()
        self:SetBGM("free")
        self.SelectFreeMode = SelectFreeMode.New(self.render,self)
        self.SelectFreeMode:EnterShow(isReconnect)
        self.SelectFreeMode:SetSelectGetMsgCallback(function (type_)
            self:StopBGM()
            self.SelectFreeMode:Delete()
            self.SelectFreeMode = nil
            if type_ == 1 then
                print("------二选一到落地牌-------------")
                self:EnterSpecialGame(spinData,true,entertype,isReconnect)
            else
                print("------二选一到免费-------------")
                self:EnterFreeGame(spinData,true, isReconnect)
            end
        end)
    end
    if not isReconnect then
        --添加1秒延迟，测试说他想看收分
        self:TakeABreak(fun_,1)
    else
        fun_()
    end
end

-- @brief 进入免费处理
function Game375:EnterFreeGame(spinData,isfrist,isReconnect)
    -- spin按钮置为等待状态
    FCasinoCtx:SetSpinStatus(FSpinStatus.WAITING)
    self:SetBGM("free")
    self:SetGameMode(FGameMode.FREE)
    if isReconnect then
        print("=======进入免费:断线重连进入=======")
        self:ChangeControllerState("free")
        self:ChangeNormalSlotControllerState("free")
        --断网重连，进入免费
        self:EnterOrAddFreeData(spinData,isfrist)
        self:AutoClick(isfrist)
        return
    end
    local overfun = function ()
        print("=======进入免费:正常进入=======")
        self:ChangeControllerState("free")
        self:ChangeNormalSlotControllerState("free")
        self:EnterOrAddFreeData(spinData,isfrist)
        self:AutoClick(isfrist)
    end
    --正常进入免费
    if isfrist then
        --第一次进入免费
        self:StopLines()
        --弹出提示界面，并等待点击
        local pos = self.render:GetChild("selection_pos").xy
        local Enter_Free_Game = Enter_Free_Game.New(self.render,pos)
        Enter_Free_Game:Show(function ()
            Enter_Free_Game:Delete()
            Enter_Free_Game = nil
            overfun()
        end)
    else
        overfun()
    end
end

--进入免费或免中免数据处理
function Game375:EnterOrAddFreeData(spinData,isfrist)
    local curnumber = 0
    local allnumber = 0
    local use_wincoin_type = FGameMode.NORMAL
    local needresting = isfrist
    if isfrist then
        --固定12次
        allnumber = 12
    else
        use_wincoin_type = FGameMode.FREE
        curnumber = spinData.totalCount
        allnumber = spinData.allCount
    end
    local winCoin = self.slotContainers[use_wincoin_type]:GetWinCoin()
    self.slotContainers[FGameMode.FREE]:ResetDatas(curnumber,allnumber,winCoin,needresting)
    self.slotContainers[FGameMode.FREE]:ShowFreeCount()
end

-- @brief 进入落地牌处理(这个游戏有特殊点：二选一进入时第一把落地牌是作为普通的补充旋转need_init=true的时候)
function Game375:EnterSpecialGame(spinData,need_init,entertype,isReconnect)
    -- spin按钮置为等待状态
    FCasinoCtx:SetSpinStatus(FSpinStatus.WAITING)
    self:StopBGM()
    self._entertype = entertype
    if isReconnect then
        print("=========进入落地牌处理,断网重连==========")
        self.slotContainers[FGameMode.SPECIAL]:SetSlotType(spinData.trainType)
        self:SetGameMode(FGameMode.SPECIAL)
        FCasinoCtx.commonPanel:ShowTop(need_init)
        --断网重连，进入落地牌
        local winCoin = self.slotContainers[entertype]:GetWinCoin()
        local othercoin = 0
        if need_init then
            self:StopBGM()
            self:ChangeControllerState("special_frist")
            self:ChangeNormalSlotControllerState("normal")
            self.slotContainers[FGameMode.SPECIAL]:ResetDatas(true,6,winCoin,othercoin)   
        else
            self:SetBGM("special")
            self:ChangeControllerState("special")
            self:ChangeNormalSlotControllerState("special")
            self:ChangeSlotControllerState(self.Reel_Container[spinData.trainType])
            self.slotContainers[FGameMode.SPECIAL]:ResetDatas(true,5,winCoin,othercoin)
        end
        self.slotContainers[FGameMode.SPECIAL]:SetNeedOtherGame(need_init)
        self.slotContainers[FGameMode.SPECIAL]:SetLastReelSymbolData(spinData.grids,isReconnect,need_init)
        self.slotContainers[FGameMode.SPECIAL]:ShowSpinNum()
        self:AutoClick(true)
        return
    end
    self:StopLines()
    print("=========进入落地牌处理,正常进入==========")
    --落地牌数据初始化
    self.slotContainers[FGameMode.SPECIAL]:SetSlotType(spinData.trainType)
    local winCoin = self.slotContainers[entertype]:GetWinCoin()
    local othercoin = 0
    if need_init then
        print("=========进入落地牌,2选1进入==========")
        self:StopBGM()
        self:SetGameMode(FGameMode.SPECIAL)
        self:ChangeControllerState("special_frist")
        self:ChangeNormalSlotControllerState("normal")
        self.slotContainers[FGameMode.SPECIAL]:ResetDatas(true,6,winCoin,othercoin)
        self.slotContainers[FGameMode.SPECIAL]:SetNeedOtherGame(need_init)
        self.slotContainers[FGameMode.SPECIAL]:SetLastReelSymbolData(spinData.grids,false,need_init)
        self.slotContainers[FGameMode.SPECIAL]:ShowSpinNum()
        self:AutoClick()
    else
        print("=========进入落地牌,6落地牌进入==========")
        --不是二选一进入的才有动画，并且落地牌初始5次旋转
        self.slotContainers[FGameMode.SPECIAL]:ResetDatas(true,5,winCoin,othercoin)
        self.slotContainers[FGameMode.SPECIAL]:SetNeedOtherGame(need_init)
        self.slotContainers[FGameMode.SPECIAL]:SetLastReelSymbolData(spinData.grids,false,need_init)
        local fun_ = function ()
            --落地牌入场动画
            local Enter_Special_Node = FairyGUI.UIPackage.CreateObject("Game375", "Enter_Special_Node")
            Enter_Special_Node.visible = false
            self.render:AddChild(Enter_Special_Node)
            Enter_Special_Node.visible = true
            local str_ = "single"
            if spinData.trainType % 2 == 0 then
                str_ = "plural"
            end
            Enter_Special_Node:GetController("show_type").selectedPage = str_
            Enter_Special_Node:GetTransition("run"):Play(1,0,function ()
                Enter_Special_Node:RemoveFromParent(true)
                Enter_Special_Node = nil
            end)
            --入场动画4秒，3秒时换控制器
            self:TakeABreak(function ()
                self:SetBGM("special")
                FCasinoCtx.commonPanel:ShowTop(false)
                --入场动画结束后做转盘动画和节点转换动画，做完后才是开始旋转
                self.slotContainers[FGameMode.SPECIAL]:PlaySlotChangeAnim(function ()
                    self:AutoClick()
                end)
                self:SetGameMode(FGameMode.SPECIAL)
                self:ChangeControllerState("special")
                self:ChangeSlotControllerState(self.Reel_Container[spinData.trainType])
                self:ChangeNormalSlotControllerState("special")
                self.slotContainers[FGameMode.SPECIAL]:ShowSpinNum()
            end,3)
        end
        --先播放入场音效，长7秒，3秒后播放动画
        FToolSet.PlayFGUISound(MusicCfg.MineCartIntroSFXOnly)
        local random_ = math.random(1, 30)
        FToolSet.PlayFGUISound(MusicCfg.MineCartIntroYell..((random_ % 3) + 1))
        self:TakeABreak(fun_,1.5)
    end
end

--落地牌收分处理(这个游戏没有满屏奖所以直接收分就行)
function Game375:SpecialContracture(spinData,outgametype,endfunc)
    local enter_otherwincoin = self.slotContainers[FGameMode.SPECIAL]:GetOtherWinCoin()
    local real_bounswin = spinData.bonusWinCoin - enter_otherwincoin
    -- 落地牌内收分
    self:ShowBottomWin(false,real_bounswin,false,true,function ()
        self:TakeABreak(function ()
            self.slotContainers[FGameMode.SPECIAL]:CleanCarAnimData()
            print("=========落地牌收分处理==========",outgametype)
            self:SetGameMode(outgametype)
            self:ChangeSlotControllerState(self.Reel_Container[1])
            FCasinoCtx.commonPanel:ShowTop(true)
            FCasinoCtx:SetSpinStatus(FSpinStatus.STOP)
            if outgametype == FGameMode.NORMAL then
                self:ChangeControllerState("normal")
                self:ChangeNormalSlotControllerState("normal")
                FCasinoCtx.commonPanel:StopScrollWinMoney(0, false)
                self._winCoin = 0
                self:ShowBottomWin(false,spinData.AllWinCoin,false,true,endfunc)
            else
                self:ChangeControllerState("free")
                self:ChangeNormalSlotControllerState("free")
                endfunc()
            end
        end,2)
    end)
end

function Game375:AutoClick(isfreeStart)
    self.datas.normalPacket     = nil
    self.datas.freeSpinPacket   = nil
    self.datas.curSpecialSpinResult = nil

    FCasinoCtx:SetSpinStatus(FSpinStatus.SPIN)

    local interval = FConfig.Common.AutoSpinInterval[FCasinoCtx.curGameMode]
    -- 普通游戏状态点击停止按钮
    if FCasinoCtx.curGameMode == FGameMode.NORMAL then
        if FCasinoCtx.isAutoSpin then
            self:DelayCallSpin(interval)
        end
    else
        -- 特殊游戏，自动点击
        -- if isfreeStart then
        --     self:DelayCallSpin(0)
        -- else
            self:DelayCallSpin(interval)
        --end
    end
end

function Game375:DelayCallSpin(delay)
    self:StopDelayCallSpin()
    self.callSpinTimer = StartOnceTimer(function()
        FCasinoCtx:SimulateSpinClick()
    end, delay)
end

function Game375:StopDelayCallSpin()
    if self.callSpinTimer then
        StopTimer(self.callSpinTimer)
        self.callSpinTimer = nil
    end
end

-- 播放中奖连线
function Game375:PlayLines(lines)
    if not next(lines) then
        return
    end
    self.winline:SetAllLine(lines)
    self.winline:PlayLine()
end

-- 隐藏中奖连线
function Game375:StopLines()
    self.winline:ClearDatas()
end

-- 转换游戏类型(mode:游戏类型,bool_not_change:是否保留当前转盘显示)
function Game375:SetGameMode(mode,bool_not_change)
    if self.curGameType == mode then
        return
    end
    --真正的游戏类型只有普通和免费，落地牌等都是特殊游戏属于普通和免费内的小游戏
    if mode == FGameMode.NORMAL then
        self.PlayGameType = FGameMode.NORMAL
    elseif mode == FGameMode.FREE then
        self.PlayGameType = FGameMode.FREE
    elseif mode == FGameMode.SPECIAL then
        self.PlayGameType = FGameMode.SPECIAL
    end
    if bool_not_change then
        FCasinoCtx:SetGameMode(mode)
        return
    end
    for index, value in ipairs(self.slotContainers) do
        if mode ~= index then
            self.slotContainers[index]:SetVisible(false)
            self.slotContainers[index]:SetOpen(false)
        end
    end
    FCasinoCtx:SetGameMode(mode)
    self.curGameType = mode
    self.slotContainers[self.curGameType]:SetVisible(true)
    self.slotContainers[self.curGameType]:SetOpen(true)
end

--收分显示(isfreeover:是否是免费结算，isspecialover：是否落地牌结算)
function Game375:ShowBottomWin(isReconnect,wincoin,isfreeover,isspecialover,callback)
    if isReconnect then
        local winCoin = wincoin or self.slotContainers[self.curGameType]:GetWinCoin()
        FCasinoCtx.commonPanel:StopScrollWinMoney(winCoin, false)
        self._winCoin = winCoin
        return
    end
    --print("self.curGameType: ",self.curGameType)
    FCasinoCtx:SetSpinStatus(FSpinStatus.STOP)
    local winCoin = wincoin or self.slotContainers[self.curGameType]:GetWinCoin()
    local second = 0.01
    local lastWinCoin = self._winCoin
    if isspecialover then
        winCoin = self._winCoin + wincoin
    end
    local addCoin = winCoin - lastWinCoin
    if isfreeover then
        addCoin = winCoin
    end
    print(lastWinCoin,"========lastWinCoin============")
    print(winCoin,"========winCoin============")
    print(addCoin,"========addCoin============")
    local audioData = FConfig.Common:GetWinChipCfg(addCoin)
    if audioData and addCoin > 0 then
        self:BGM_SetSoundVolume(0)
        -- 播放收分音乐
        if self.soundWinCoinEffectHandle then
            APIGateway.StopSound(self.soundWinCoinEffectHandle)
            self.soundWinCoinEffectHandle = nil
        end
        self.soundWinCoinEffectHandle = FToolSet.PlayFGUISound(audioData.url)
        second = audioData.time 
        -- 15倍钻石+金块
        if Tools.isPlayCoinFountain(addCoin) then
            self.ZSFlyAnim_Left:PlayZS(true)
            self.ZSFlyAnim_Right:PlayZS(false)
            -- 30倍钻石+金块+炸弹
            self.CoinFlyAnim:PlayGoldBar(Tools.isPlayCoinFountain2(addCoin))
        end
    end
    -- 结算金币
    if winCoin > 0 then
        print("=====winCoin:======",winCoin)
        FCasinoCtx.commonPanel:ScrollWinMoneyTo(winCoin,second,function ()
            self:StopBottomWin()
            if callback then
                callback()
            end
        end)
    else
        self:StopBottomWin()
        if callback then
            callback()
        end
    end
    self._winCoin = winCoin
    return second
end

function Game375:StopBottomWin()
    self.CoinFlyAnim:Stop()
    self.ZSFlyAnim_Left:Stop()
    self.ZSFlyAnim_Right:Stop()
    self:BGM_SetSoundVolume(1)
    if self.soundWinCoinEffectHandle then
        APIGateway.StopSound(self.soundWinCoinEffectHandle)
        self.soundWinCoinEffectHandle = nil
    end
end

-- 初始化矿车动画层图案数据
function Game375:InitNewCar(car_type,list_info,callback,symbolnode,symbol_parent)
    self.Win_Car_Node:InitNewCar(car_type,list_info)
    self.Win_Car_Node:SetCarRunEndCallBack(callback)
    self.Win_Car_Node:SetSymbolNode(symbolnode)
    self.Win_Car_Node:SetSymbolParent(symbol_parent)
    self.Win_Car_Node:SetCarRun(true)
end

-- 初始化彩金矿车动画数据
function Game375:InitCaijinCar(car_type,caijin_data,callback)
    self.Win_Car_Node:InitCaijinCar(car_type,caijin_data,callback)
    self.Win_Car_Node:RunCaijinCar()
end

--给矿车动画层添加一个点击事件，用以控制是否开始动画
function Game375:AddClickListener_CarAinimation(callback)
    FToolSet.AddClickListener(self.Win_Car_Node.render,callback)
end

function Game375:SetTouchable_CarAinimation(bool)
    self.Win_Car_Node.render.touchable = bool
end

--设置矿车动画层清理锁定
function Game375:SetCanNotClearLock(bool)
    self.Win_Car_Node:SetCanNotClearLock(bool)
end

----------------------------------------------------------------------
-- 为保证大小，只有在单独层做抛金币效果(加在矿车动画层,需要传入宽，高)
function Game375:CreateFountainEffect2Node(width,height,pos)
    self.Win_Car_Node:CreateFountainEffect2Node(width,height,pos,self.game_node)
end
function Game375:PlayFountainEffect2Node(number)
    self.Win_Car_Node:PlayFountainEffect2Node(number)
end
function Game375:StopFountainEffect2Node()
    self.Win_Car_Node:StopFountainEffect2Node()
end
function Game375:DeleteFountainEffect2Node()
    self.Win_Car_Node:DeleteFountainEffect2Node()
end
-----------------------------------------------------------------------

---------------------------------彩金----------------------------------
function Game375:Caijin_PlayWin(index)
    self.caijinPanel:CaijinWin(index)
end

function Game375:Caijin_StopWin()
    self.caijinPanel:StopWin()
end

function Game375:CaiJin_UpdateUI()
    self.caijinPanel:UpdateUI()
end
-------------------------------------------------------------------------

-- 停止播放出场音效
function Game375:StopEntranceSound()
    if self.entranceSound then
        APIGateway.StopSound(self.entranceSound)
        self.entranceSound = nil
    end
end

function Game375:Refresh()
    -- 停止自动spin
    self:StopDelayCallSpin()
    self:StopBottomWin()
    FCasinoCtx:SetSpinStatus(FSpinStatus.STOP)
    if self.SelectFreeMode then
        self.SelectFreeMode:Delete()
        self.SelectFreeMode = nil
    end
end

function Game375:TakeABreak(callback,time)
    self.TakeABreaktimer = StartOnceTimer(function ()
        self.TakeABreaktimer = nil
        callback()
    end,time or 2)
end

function Game375:TakeABreak2(callback,time)
    self.TakeABreaktimer2 = StartOnceTimer(function ()
        self.TakeABreaktimer2 = nil
        callback()
    end,time or 2)
end

function Game375:SetBGM(type_)
    if type_ == "special" then
        self.BGM_handle = FToolSet.PlayBGM(MusicCfg.respin_)
        self:TakeABreak2(function ()
            self.BGM_handle = FToolSet.PlayBGM(MusicCfg.respin_bgm)
        end)
        return
    end
    local name = ""
    if type_ == "normal" then
        name = ""
    elseif type_ == "free" then
        name = MusicCfg.free_music
    end
    self.BGM_handle = FToolSet.PlayBGM(name)
end

function Game375:StopBGM()
    FToolSet.StopBGM()
    self.BGM_handle = nil
end

function Game375:BGM_SetSoundVolume(volume)
    if self.BGM_handle then
        APIGateway.SetSoundVolume(self.BGM_handle,volume)
    end
end

return Game375