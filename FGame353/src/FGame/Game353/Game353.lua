
 local NormalSlot       = Import(".Slot.NormalSlot")
local FreeSlot        = Import(".Slot.FreeSlot")
local Utils          = Import(".Slot.Utils")
local MusicCfg = Import(".Slot.MusicCfg")
local CaijinPanel = Import(".CaijinPanel")
local SelectPanel = Import(".Slot.FreePanel")
local SpecialPanel = Import(".Slot.SpecialPanel")
local OtherPanel = import(".Slot.OtherPanel")
local TrainPanel = import(".Slot.TrainPanel")
local Tips = import(".Slot.Tips")
local CoinFountain      = require("FGame.Common.Logic.Effect.CoinFountain")

local SlotType = {
    Normal      = 1,    -- 普通类型
    Free        = 2,    -- 免费游戏
}

local Game353 = Class("Game353", BaseGame)

function Game353:ctor(render)
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
    self.trainPanel = TrainPanel.New(self.render:GetChild("TrainPanel"),self)
    self.selectPanel = SelectPanel.New(self.render:GetChild("SelectPanel"),self)
    self.coinFountain = CoinFountain.New()
    self.coinFountain:SetSortingOrder(10)
    -- self.tips =  Tips.New(self.render:GetChild("BigwinTip"),self)
    -- self.tips.sortingOrder = 1000
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
    self.Jpwinicon = {}--Jp彩金图标
    self.Jpwinnumber = 0--jp彩金值
    self.TrainAnimCount = {}
    self.startReel_count = 0 --彩金预警增加格子距离音效
    self.tingpaianimarr = {}
    self.freeselectType = 0--免费游戏选择类型
    for i = 1, 4 do
        local anim = self.slot:GetChild("n"..12+i)
        table.insert(self.tingpaianimarr,anim)
    end
    self.redlightpanel = self.slot:GetChild("redlightpanel")
    self.leftcrossing =  self.redlightpanel:GetChild("leftcrossing")
    self.rightcrossing =  self.redlightpanel:GetChild("rightcrossing")
    self.lefthandrail =  self.leftcrossing:GetChild("lefthandrail")
    self.righthandrail =  self.rightcrossing:GetChild("righthandrail")
    self.PlaytrainanimCount = 1 -- 小火车播放次数
    self.wildbetarr = {}--免费游戏wildbet 显示参数
    self.wildbetindex = 1--免费游戏wildbet 显示下标
    self.freewildinfor = {}
    self:Test(function ()
        
        -- self.trainPanel:ShowBigwinAnim(3,1234560000)
        -- self:PlayFireWheelAnim(1)
        -- self:exitcrossing()
        -- self:entercrossing()
        -- self.trainPanel:EnterTrainAnim(4)
        -- StartOnceTimer(function ()
        -- self.trainPanel:EnterTrainAnim(2,nil,nil,math.random(1,8))
        --     self.redlightpanel.visible = false
        --     self.slot:GetTransition("signin"):Play()
        --     self.trainPanel:EnterTrainAnim(5)
           
        -- end,36)
        -- self.selectPanel:enterfreeselect(4)
        -- self.otherPanel:CreateJpWinBoard(1000000000)
        -- self.slotContainers[SlotType.Normal]:DrawWinIcon(1,1,true)
        -- self.slot:GetTransition("fadeout"):Play()
    end)
    self:ChangeBgm("ui://Game353/ngbgm")
end
--wildbetHandle
function Game353:wildbetHandle(number)
    self.wildbetarr = {}
    local tempwildarr = {}
    if number <= 1 then return end
    if number < 10 then
        table.insert(tempwildarr,number)
        self.wildbetarr[self.freewildinfor[1].index] = number
        return
    end
    local data = 100
    for i = 1, 2 do
        local value = math.floor(number / data)
        if value > 0 then
            table.insert(tempwildarr,value)
            number = number - (value*data)
            if number < 10 then
                break
            end
        end
        data = math.floor(data / 10)
    end
    table.insert(tempwildarr,number)
    --让wildbet根据wild所在的位置进行赋值
    for i = 1, #tempwildarr do
        self.wildbetarr[self.freewildinfor[i].index] = tempwildarr[i]
    end
    -- dump(self.wildbetarr)

end
--火车游戏进入前的入场动画
function Game353:entercrossing(iscover,callback)
    print("火车杆杆显示！！！！！！！！！！")
    callback = callback or function() end
    self.redlightpanel.visible = true
    if iscover then
        self.leftcrossing.visible = true
        self.rightcrossing.visible = true
        self.redlightpanel:GetTransition("t2"):Play() 
        return
    end
    self.slot:GetTransition("signout"):Play()
    self.redlightpanel:GetTransition("t0"):Play()
    self.leftcrossing:GetTransition("t0"):Play()
    self.rightcrossing:GetTransition("t0"):Play()
    self.lefthandrail:GetTransition("t0"):Play()
    self.righthandrail:GetTransition("t0"):Play(callback)
end
function Game353:exitcrossing()
    self:ChangeBgm()
    FToolSet.PlayFGUISound("ui://Game353/TrainMusicEnd" )
    self.redlightpanel.visible = true
    self.redlightpanel:GetTransition("t1"):Play()
    self.leftcrossing:GetTransition("t1"):Play()
    self.rightcrossing:GetTransition("t1"):Play()
    self.lefthandrail:GetTransition("t0"):Play()
    self.righthandrail:GetTransition("t0"):Play(function ()
        self.slot:GetTransition("signin"):Play()
        self.redlightpanel.visible = false
    end)
end
--播放烟雾动画
function Game353:PlaySmogAnim(callback)
    FToolSet.PlayFGUISound("ui://Game353/PreAnticipation")
    self.slot:GetChild("smogbg").visible = true
    local smoganim = self.slot:GetChild("smoganim")
    Utils.PlayWebm({render = smoganim,timer = 1,callback = function()
        self.slot:GetChild("smogbg").visible = false
        callback()
    end})
end
--播放火轮动画
function Game353:PlayFireWheelAnim(index)
   -- if self.startReel_count ~= 1 then return end
    self:StopFireWheelAnim()
    if index > 5 then return end
    self.whirring_reel = FToolSet.PlayFGUISound(MusicCfg.slots_353_reelfast)
    local firewheel = self.slot:GetChild("firewheel"..index)
    Utils.PlayWebm({render = firewheel,timer = 2,callback = function()
    end})
end
--停止火轮动画
function Game353:StopFireWheelAnim()
    for i = 1, 5 do
        self.slot:GetChild("firewheel"..i).visible = false
    end
    if self.whirring_reel then
        APIGateway.StopSound(self.whirring_reel)
        self.whirring_reel = nil
    end
end
function Game353:PlayLastWheelAnim()
    self.slot:GetChild("n31").visible = true
    local startanim = self.slot:GetChild("startanim")
    Utils.PlayWebm({render = startanim,timer = 0.5,callback = function()
    end})
end
function Game353:Test(fuc_)
    StartOnceTimer(fuc_,2)
end
---功能函数
--金币滚动是切换停止按钮 处理停止按钮点击回调函数
function Game353:Coin_Roll_Function(callfunc,time)
    local temptime = time or self:GetAutoSpinSecond()
    FCasinoCtx:SetSpinStatus(FSpinStatus.STOP)
    self.rollanimcallback = callfunc
    self.rollanimcallbacktimer = StartOnceTimer(function ()
        self.rollanimcallbacktimer = nil
        if self.rollanimcallback then
            self.rollanimcallback()
            self.rollanimcallback = nil
        end
    end,temptime)
end
--是否是免费游戏
function Game353:InGameFree()
    if FCasinoCtx.curGameMode == FGameMode.FREE then
        return true
    end
    return false
end
--是否是普通游戏
function Game353:InGameNormal()
    if FCasinoCtx.curGameMode == FGameMode.NORMAL then
        return true
    end
    return false
end
function Game353:__delete()
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
    self.trainPanel:Delete()
    self.selectPanel:Delete()
    self.coinFountain:Delete()
    -- self.tips:Delete()
end

-- @interface
-- @brief update
function Game353:Update(dt)
    Game353.super.Update(self, dt)
    for i = 1, 2 do -- 3  4 共用
        self.slotContainers[i]:Update(dt)
    end
end
function Game353:SetAutoSpinSecond(second)
    self._autoSpinSecond = second
end
function Game353:GetAutoSpinSecond()
    return self._autoSpinSecond 
end
-- @interface
-- @brief 在游戏中断线重连恢复游戏
-- @param local  断线重连数据
function Game353:ReconnectRecoveryGame(data, isInitialize)
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
            self.slotContainers[SlotType.Normal]:HandleCellDatas(spinData.grids)
            self.slotContainers[SlotType.Normal]:HandleWinDatas(spinData.lines)
            self:OnNormalSpinResult(spinData, true,function ()  end,data.currentWinCoin)
            dump(self.TrainAnimCount,"self.TrainAnimCount",10)
            local isRunningTrain = false
            if #self.TrainAnimCount > 0 then
                FCasinoCtx:SetSpinStatus(FSpinStatus.WAITING)
               -- self:ShowBottomWin(true,self.datas.normalPacket.winCoin)
                --再免费落地牌模式中如果没有跑火车数据则开始跑火车动画
                if #data.cells == 0  then
                    self:entercrossing(true)
                    self:startTrain(#self.TrainAnimCount,1,function ()
                        self:exitcrossing()
                        self:GameState_EndDraw()
                    end)
                    isRunningTrain = true
                elseif  data.cells[1] == 9999 then--服务器9999表示结束字段跳出
                    isRunningTrain = false
                else
                    --火车动画开始回包数据中的火车车身节数小于火车总长度 则继续跑动
                    local trainindex = data.cells[1] % 1000
                    local playCount = math.floor(data.cells[1] / 1000)
                    print("trainindex,playCount",trainindex,playCount)
                    if trainindex < #self.TrainAnimCount[playCount].traindata then
                        if playCount > 1 then
                            self.trainPanel.isshowlasttraindata = playCount-1
                        end
                        self:entercrossing(true)
                        self:startTrain(#self.TrainAnimCount,playCount,function ()
                            self:exitcrossing()
                            self:GameState_EndDraw()
                        end,trainindex)
                        isRunningTrain = true
                    else--第一轮火车跑完 看看是否有第二轮火车游戏
                        if  playCount < #self.TrainAnimCount then
                            self.slotContainers[self.curGameType]:ShowLoaderNumber(self.TrainAnimCount[playCount].traintypeindex,
                            self.TrainAnimCount[playCount].allwinCoin)
                            self.trainPanel.isshowlasttraindata = playCount
                            self:entercrossing(true)
                            self:startTrain(#self.TrainAnimCount,playCount + 1,function ()
                                self:exitcrossing()
                                self:GameState_EndDraw()
                            end,0)
                            isRunningTrain = true
                        end
                    end
                    if isRunningTrain then
                        if playCount > 1 then
                            for i = 1, playCount -1 do
                                for key, value_ in pairs(self.TrainAnimCount[i].traindata) do
                                    if value_.type-10 > 2 then
                                        self:ShowBottomWin(true,data.currentWinCoin + value_.value)
                                    end
                                end
                            end
                        end
                        if trainindex == #self.TrainAnimCount[playCount].traindata then
                            for i = 1, playCount do
                                for key, value_ in pairs(self.TrainAnimCount[i].traindata) do
                                    if value_.type-10 > 2 then
                                        self:ShowBottomWin(true,data.currentWinCoin + value_.value)
                                    end
                                end
                            end
                        end
                    end
                    
                end
                for i = 1, #self.TrainAnimCount do
                    self.slotContainers[self.curGameType]:ShowLoaderNumber(self.TrainAnimCount[i].traintypeindex,
                    self.TrainAnimCount[i].allwinCoin)
                end
            end
            if isRunningTrain then  return  end
            FCasinoCtx:SetSpinStatus(FSpinStatus.SPIN)
            --self:OnNormalSpinResult(spinData, true,function ()  end,data.currentWinCoin)
            -- self.slotContainers[SlotType.Normal]:SetWinCoin(data.currentWinCoin)
            if self.datas.normalPacket.intoFree > 0 then
                FCasinoCtx:SetSpinStatus(FSpinStatus.WAITING)
                self.selectPanel:enterfreeselect(self.datas.normalPacket.intoFree)
            end
        else
            print("断网数据是一样")
            if self.isSpined then -- 已经在特殊游戏了
                    self:SendPackage() 
                return
            end
            if self.datas.normalPacket.intoFree > 0  then
                self.selectPanel:enterfreeselect(self.datas.normalPacket.intoFree)
            end
        end
        return
    elseif data.type == 2 then
        local norspinData = data.resumedNormal.normalSpin
        local selectData = data.resumedFreeType
        --免费中处理普通包中奖线
        self.slotContainers[SlotType.Normal]:HandleWinDatas(norspinData.lines)
        if not self:CheckSlotData(norspinData.girds, SlotType.Free) then
            self.datas.normalPacket = data.resumedNormal.normalSpin
            local selectdata = selectData.freetype.type
            self.datas.selectpacket = selectdata
            self:ShowBottomWin(true,data.currentWinCoin)
            self:EnterFreeGame(selectdata)
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
                --特殊落地牌跑火车断线重连
                if data.resumedFreeType.freetype.type == 2 then
                    self.freeselectType = 2
                    self.slotContainers[self.curGameType]:HandleWinDatas(freedata.lines)
                    self.otherPanel:SetCount()
                    local isRunningTrain = false
                    if #self.TrainAnimCount > 0 then
                        dump(self.TrainAnimCount,"self.TrainAnimCount")
                        FCasinoCtx:SetSpinStatus(FSpinStatus.WAITING)

                        --
                        --再免费落地牌模式中如果没有跑火车数据则开始跑火车动画
                        if #data.cells == 0  then
                            self:entercrossing(true)
                            self:startTrain(#self.TrainAnimCount,1,function ()
                                self:exitcrossing()
                                self:GameState_EndDraw()
                            end)
                            isRunningTrain = true
                        elseif data.cells[1] == 9999 then
                            isRunningTrain = false
                        else
                            --火车动画开始回包数据中的火车车身节数小于火车总长度 则继续跑动
                            local trainindex = data.cells[1] % 1000
                            local playCount = math.floor(data.cells[1] / 1000)
                            print("trainindex,playCount",trainindex,playCount)
                            if trainindex < #self.TrainAnimCount[playCount].traindata then
                                if playCount > 1 then
                                    self.trainPanel.isshowlasttraindata = playCount-1
                                end
                                self:entercrossing(true)
                                self:startTrain(#self.TrainAnimCount,playCount,function ()
                                    self:exitcrossing()
                                    self:GameState_EndDraw()
                                end,trainindex)
                                isRunningTrain = true
                            else--第一轮火车跑完 看看是否有第二轮火车游戏
                                if  playCount < #self.TrainAnimCount then
                                    self.slotContainers[self.curGameType]:ShowLoaderNumber(self.TrainAnimCount[playCount].traintypeindex,
                                    self.TrainAnimCount[playCount].allwinCoin)
                                    self.trainPanel.isshowlasttraindata = playCount
                                    self:entercrossing(true)
                                    self:startTrain(#self.TrainAnimCount,playCount + 1,function ()
                                        self:exitcrossing()
                                        self:GameState_EndDraw()
                                    end,0)
                                    isRunningTrain = true
                                end
                            end
                            
                        end
                        for i = 1, #self.TrainAnimCount do
                            self.slotContainers[self.curGameType]:ShowLoaderNumber(self.TrainAnimCount[i].traintypeindex,
                            self.TrainAnimCount[i].allwinCoin)
                        end
                    end
                    if isRunningTrain then
                        self:ShowBottomWin(true,self.datas.normalPacket.winCoin)
                        return
                    end
                end
                FCasinoCtx:SetSpinStatus(FSpinStatus.SPIN)
                print("断线重连免费游戏结束")
                self.otherPanel:SetCount()
                --没次数了
                self:OnNormalSpinResult(norspinData, true,function ()  end)
                return
            end
            self.slotContainers[self.curGameType]:SetIsEnterFree(true)
            self.slot:GetTransition("changefree"):Play()
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
function Game353:CheckSlotData(grids, type)
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
function Game353:StopAllcoin_sound_wincoin()
    self:StopDelayCallSpin()
    --停止播放收分音效
    if self.soundWinCoinEffectHandle then
        APIGateway.StopSound(self.soundWinCoinEffectHandle)
        self.soundWinCoinEffectHandle = nil
    end
end

-- @interface
-- @brief 点击开始按钮ftes
function Game353:OnClickSpin()
    print("点击开始按钮")
    -- self.tips:HideTips()
    self:StopAllcoin_sound_wincoin()
   
    --停止收分计时器
    if self.soundWinCoinEffectHandleTimer then
        StopTimer(self.soundWinCoinEffectHandleTimer)
        self.soundWinCoinEffectHandleTimer = nil
        self:ShowBottomWin(true,self._winCoin)
        return
    end
    FToolSet.PlayFGUISound("ui://Game353/reel_click" )
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
    elseif FCasinoCtx.curGameMode == FGameMode.FREE then
        self:ChangeGameType(SlotType.Free)
        self.slotContainers[SlotType.Free]:SpinStart()
        --self:ChangeBgm(MusicCfg.SND_Fea_BGM)
    end
    self.caijin_type,self.smallecaijin = 0 ,0
    --发送包数据
    self:SendPackage()
    self.isSpined = true
    self.slot:GetChild("n31").visible = false
end
--发送包数据
function Game353: SendPackage(index)
    -- if index then
    --     print("发送免费选择包数据")
    --     local request = {
    --         _msgName_ = "PB.Client_Slots.BuffaloFreeType",
    --     }
    --     APIGateway.SendExactRequest(request, "PB.Slots_Client.BuffaloFreeRetType",
    --         function(ok, result)
    --             if not ok then return end
    --             self.datas.selectpacket = result.freeType
    --             dump(result,"SPECIAL",4)
    --             self.selectPanel:enterfreeselect(result.freeType)
    --         end
    --     )
    --     return
    -- end
    if FCasinoCtx.curGameMode == FGameMode.NORMAL then
        print("发送普通包数据")
        self:SendNormalSpin("PB.Client_Slots.BuffaloNormalSpin", "PB.Slots_Client.BuffaloNormalRet",
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
            _msgName_ = "PB.Client_Slots.BuffaloFreeSpin"
        }
        APIGateway.SendExactRequest(request, "PB.Slots_Client.BuffaloFreeRet",
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
function Game353:OnClickStop()
    if self.startReel_count > 0 then 
        self:StopFireWheelAnim()
        self.startReel_count = 0 
    end
    print("点击停止按钮")
    -- self.tips:HideTips()
    self:StopAllcoin_sound_wincoin()
    if self.CoinFountainTimer then
        StopTimer(self.CoinFountainTimer)
        self.coinFountain:Stop()
        self.CoinFountainTimer = nil
    end
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
function Game353:OnNormalSpinResult(spinData, quickSet, customCallback,allwinCount)
    print("处理普通包数据")
    Utils.printLine(spinData.grids,4)
    self:ChangeGameType(SlotType.Normal)
    
    --处理格子数据
    self.slotContainers[self.curGameType]:HandleCellDatas(spinData.grids)
    if quickSet then
        self.slotContainers[self.curGameType]:SetOpen(true)
    else
        --处理中奖线数据
        self.slotContainers[self.curGameType]:HandleWinDatas(spinData.lines)
    end
    -- --设置时候中奖免费游戏
    self.slotContainers[self.curGameType]:SetIsEnterFree(false)
    if not quickSet  then
        self.slotContainers[self.curGameType]:AssDistance()
    end
    self.slotContainers[SlotType.Normal]:SetReelSymbolData(function ()
        -- 快速设定图形数据 不进行免费特殊判断
        if customCallback then
            customCallback()
            return
        end
        self:SpinEndCallFunc()
    end,quickSet,allwinCount)
end
--旋转结束播放中奖线前特殊处理
function Game353:SpinEndCallFunc()
    print("旋转结束播放中奖线前特殊处理SpinEndCallFunc",#self.TrainAnimCount)
    FCasinoCtx:SetSpinStatus(FSpinStatus.WAITING)
    self.isSpined = false
    self.PlaytrainanimCount = 1
    local wildfunc = function ()
        if #self.freewildinfor > 0 then
            FToolSet.PlayFGUISound("ui://Game353/SND_ST_Wild")
            self.wildbetindex  = 1
            self.slotContainers[self.curGameType]:PlayTablelist(self.freewildinfor,"intro")
            StartOnceTimer(function ()
                self:GameState_EndDraw()
            end,2)
        else
            self:GameState_EndDraw()
        end
    end
    --处理免费和彩金入场音效动画
    if #self.freeIconInfo >= 3 or (self:InGameFree() and #self.freeIconInfo >= 2 and self.freeselectType ~= 2) then

        if self:InGameFree() then
            FToolSet.PlayFGUISound("ui://Game353/feature_bell_double_short")
        else
            FToolSet.PlayFGUISound(MusicCfg.feature_bell)
        end
        self.slotContainers[self.curGameType]:PlayTablelist(self.freeIconInfo)
        StartOnceTimer(function ()
            if self:InGameFree() then
                local freearr = {5,5,8,15,20}
                self.otherPanel:ExtraFreeBoard(freearr[#self.freeIconInfo],function ()
                    self.slotContainers[SlotType.Free]:SetAllTurns(self.datas.freeSpinPacket.allCount)
                    wildfunc()
                end)
            else
                self:GameState_EndDraw()
            end
        end,2)
    elseif #self.TrainAnimCount > 0 then
        FToolSet.PlayFGUISound(MusicCfg.feature_bell)
        StartOnceTimer(function ()
            self.crossloop = FToolSet.PlayFGUISound("ui://Game353/CrossingLoop")
            self:entercrossing(false,function ()
                dump(self.TrainAnimCount,"self.TrainAnimCount")
                self:startTrain(#self.TrainAnimCount,1,function ()
                    self:exitcrossing()
                    self:GameState_EndDraw()
                end)
            end)
        end,2)
    else
        wildfunc()
    end
end
function Game353:startTrain(allcount,trainindex,overfunc,isrecoverTrainindex)
    self.PlaytrainanimCount = trainindex
    local timer = 0
    --金火车游戏前开始弹窗面板累计算分
    print("isrecoverTrainindex",isrecoverTrainindex)
    if self.TrainAnimCount[trainindex].traintype == 5 and (isrecoverTrainindex == 0
    or not isrecoverTrainindex) then
        timer = 2
        self.otherPanel:GoldTrainBoard(0)
        local temptime = 0
        local grids = self.datas.normalPacket.grids
        if self:InGameFree() then
            grids = self.datas.freeSpinPacket.grids
        end
        local loopway = {1,6,11,16,2,7,12,17,3,8,13,18,4,9,14,19}
        local goldwin = 0
        for i = 1, #loopway do
            if  grids[loopway[i]].SymbolType > 0 then
                temptime = temptime + 1
                StartOnceTimer(function ()
                    goldwin = goldwin + grids[loopway[i]].SymbolValue 
                    self.otherPanel:GoldTrainBoard(goldwin)
                    self.slotContainers[self.curGameType]:PlayIndexAnim(0,0,loopway[i],true)
                end,temptime)
                timer = timer + 1
            end
        end
    end
    if self.crossloop then
        APIGateway.StopSound(self.crossloop)
        self.crossloop = nil
    end
    StartOnceTimer(function ()
        self.otherPanel.GoldPanel.visible = false
        self.trainPanel:EnterTrainAnim(self.TrainAnimCount[trainindex].traintype,
        self.TrainAnimCount[trainindex].traindata,function ()
            self.slotContainers[self.curGameType]:ShowLoaderNumber(self.TrainAnimCount[trainindex].traintypeindex,
            self.TrainAnimCount[trainindex].allwinCoin)
            trainindex = trainindex + 1
            if trainindex > allcount then
                overfunc()
            else
                self.trainPanel.isshowlasttraindata = trainindex-1
                self:startTrain(allcount,trainindex,overfunc)
            end
        end,isrecoverTrainindex,trainindex)
    end,timer)

end
--绘制中奖线播放中奖动画 收分
function Game353:GameState_EndDraw(isfree,freecallback)
    local second = self.slotContainers[self.curGameType]:DrawLineAndCollectScores()
    self:SetAutoSpinSecond(second)
    self:GameState_HandleSpecial(isfree,freecallback)
end
--处理特殊游戏
function Game353:GameState_HandleSpecial(isfree,freecallback)
   
    self:GameState_HandleFreeTime(isfree)
end

function Game353:EnterSpecialGame(isFreeToSpecial)
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
function Game353:SpecialOver(isFreeToSpecial)
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
function Game353:GameState_HandleFreeTime(isfree)
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
function Game353:FreeAddGame()
    self.slotContainers[SlotType.Free]:SetAllTurns(self.datas.freeSpinPacket.allCount)
    self:GameState_SingleRoundFreeGameOver()
end
--免费游戏单轮结束
function Game353:GameState_SingleRoundFreeGameOver()
    --有中奖线的时候
    print("单轮免费游戏结束")
    self:Coin_Roll_Function(function ()
        local freedata = self.datas.freeSpinPacket
        FCasinoCtx:SetSpinStatus(FSpinStatus.SPIN)
        if freedata.totalCount == freedata.allCount then
            FCasinoCtx:SetSpinStatus(FSpinStatus.WAITING)
            --免费包总次数等于1 是特殊落地牌模式
            if self.freeselectType == 2 then
                self:GameState_GameOver(true)
            else
                self.otherPanel:CreateEndWinBoard(freedata.bonusWinCoin,function ()
                    self:GameState_GameOver(true)
                end)
            end
        else
            FCasinoCtx:SetSpinStatus(FSpinStatus.SPIN)
            self:DelayCallSpin(2)
        end
    end)
end
function Game353:FreeGameOver()
    print("免费游戏结束")
    self.otherPanel:CreateEndWinBoard(self.datas.freeSpinPacket.bonusWinCoin,function ()
        self:GameState_GameOver(true)
    end)

end
 --当前游戏一此完整的旋转结束
function Game353:GameState_GameOver(isfreeover)
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
            self.slotContainers[SlotType.Free]:SetIsEnterFree(false)
            self.slotContainers[SlotType.Normal]:SetIsSpecialgame(false)
            self.slot:GetChild("n31").visible = false
            self:OnNormalSpinResult(self.datas.normalPacket,true,function () end)
            self.slotContainers[SlotType.Normal]:HandleWinDatas(self.datas.normalPacket.lines)
            self.slotContainers[SlotType.Normal]:DrawLineAndCollectScores(true)
            self.slot:GetTransition("changenormal"):Play()
            self:SetAutoSpinSecond(second)
            self:Coin_Roll_Function(function ()
                FCasinoCtx:SetSpinStatus(FSpinStatus.SPIN)
                print("开始结算金额")
                FCasinoCtx:SetPlayerMoneyInfo(datapacket)
                FCasinoCtx:SyncPlayerMoneyDisplay(2)
                if FCasinoCtx.isAutoSpin then
                    self:DelayCallSpin(2)
                end
                self:ChangeBgm("ui://Game353/ngbgm")
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
function Game353:EnterFreeSelect()
    self:Coin_Roll_Function(function ()
        FCasinoCtx:SetSpinStatus(FSpinStatus.WAITING)
        self:StopAllcoin_sound_wincoin()
        self:StopActionAndWinlines()
        -- self:SendPackage(1)
        self.selectPanel:enterfreeselect(self.datas.normalPacket.intoFree)
        
    end)
    FCasinoCtx:SetSpinStatus(FSpinStatus.STOP)
end
function Game353:EnterFreeGame(selecttype)
    self.freeselectType = selecttype
    print("开始准备免费游戏滚动",self.freeselectType)
    FCasinoCtx:SetSpinStatus(FSpinStatus.WAITING)
    self:ChangeBgm(MusicCfg.SND_Fea_BGM)
    self:ChangeGameType(SlotType.Free)
    FCasinoCtx:SetSpinStatus(FSpinStatus.SPIN)
    self:DelayCallSpin(0.5)
    local win = self.slotContainers[SlotType.Normal]:GetWinCoin()
    if self.freeselectType == 1 then
        self.slotContainers[self.curGameType]:SetIsEnterFree(true)
        self.slot:GetTransition("changefree"):Play()
        self.slotContainers[SlotType.Free]:ResetDatas(0,self.datas.normalPacket.intoFree,win)
        self.slotContainers[SlotType.Free]:InitIcondata()
    else
        self.slotContainers[self.curGameType]:SetIsEnterFree(false)
        self.slotContainers[SlotType.Free]:SetIsSpecialgame(true)
        self.slotContainers[SlotType.Free]:ResetDatas(0,1,win)
        self.slotContainers[SlotType.Free]:InitIcondata(true)
    end
end
-- @brief 处理免费游戏旋转结果
-- @param quickSet 直接设置跳过动画
function Game353:OnFreeSpinResult(spinData, quickSet, callback,allwinCount)
    print("处理free包数据")
    Utils.printLine(spinData.grids)
    self:ChangeGameType(SlotType.Free)
    self._wildchange = spinData.changeWilds
    self._changeBacks = spinData.changeBacks
    --处理格子数据
    self.slotContainers[self.curGameType]:HandleCellDatas(spinData.grids,true)
    if quickSet then
        self.slotContainers[self.curGameType]:SetOpen(true)
    else
        --处理中奖线数据
        self.slotContainers[self.curGameType]:HandleWinDatas(spinData.lines)
    end
    if not quickSet  then
        self.slotContainers[self.curGameType]:AssDistance()
        self:wildbetHandle(spinData.wildType)
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
function Game353:DelayCallSpin(delay,cb)
    print("kaiqi自动旋转")
    self:StopDelayCallSpin()
    self.callSpinTimer = StartOnceTimer(function()
        if cb then
            cb()
        end
        FCasinoCtx:SimulateSpinClick()
    end, delay)
end

function Game353:StopDelayCallSpin()
    if self.callSpinTimer then
        StopTimer(self.callSpinTimer)
        self.callSpinTimer = nil
    end
end
-- 转换游戏类型
function Game353:ChangeGameType(slotType,bgcolor)
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
function Game353:StopActionAndWinlines()
    if FCasinoCtx.curGameMode == FGameMode.NORMAL then
        self.slotContainers[SlotType.Normal]:StopShowLine()
        self.slotContainers[SlotType.Normal]:RemoveTopSymbol()
    elseif FCasinoCtx.curGameMode == FGameMode.FREE then
        self.slotContainers[SlotType.Free]:StopShowLine()
       self.slotContainers[SlotType.Free]:RemoveTopSymbol()
    end
end

function Game353:ShowBottomWin(quickSet,winCoin)
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
            if multiply >= 100 then 
                self.soundWinCoinEffectHandle = FToolSet.PlayFGUISound(string.format(MusicCfg.slots_353_March,math.random(1,3)))
            else
                self.soundWinCoinEffectHandle = FToolSet.PlayFGUISound(audioData.url)
            end
            --滚动金币是停止背景音效
            if self.soundBgm then
                FToolSet.StopBGM()
            end
            second = audioData.time
            self.soundWinCoinEffectHandleTimer = StartOnceTimer(
                function ()
                    if self.render then
                        APIGateway.StopSound(self.soundWinCoinEffectHandle)
                        self.soundWinCoinEffectHandle = nil
                   end
                   self.soundWinCoinEffectHandleTimer = nil
                   if self.soundBgm then
                        FToolSet.PlayBGM(self.soundBgm,true)
                    end
                    -- self.tips:HideTips()
                end
            ,second)

            if multiply >= 5 then -- 较大价值奖励抛金币
                self.coinFountain:Play(nil,CoinFountain.Anims[2])
                self.CoinFountainTimer = StartOnceTimer(
                    function ()
                        if self.render then
                            self.coinFountain:Stop()
                         end
                         self.CoinFountainTimer = nil
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

function Game353:ChangeBgm(url)
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
return Game353