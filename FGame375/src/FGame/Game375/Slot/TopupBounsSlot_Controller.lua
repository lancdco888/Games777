-- 老虎机落地牌游戏，三个格子一组转动
local SymbolConfig                  = Import(".SymbolConfig")
local MusicCfg                      = Import(".MusicCfg")
local Tools                         = Import(".Tools")
local ConstCfg                      = Import(".ConstCfg")
local CarTypeCfg                    = Import(".CarTypeCfg")
local TopupBounsSlot_Controller     = Class("TopupBounsSlot_Controller")
local TopupBounsSlot                = Import(".TopupBounsSlot")

TopupBounsSlot_Controller.PlayTypeWithSlot = {
    [1] = {true,false,false,false},
    [2] = {true,true,false,false},
    [3] = {false,false,true,false},
    [4] = {false,false,true,true},
}
--该游戏落地牌有4种转盘，外界通过调用总控制，间接调用4种转盘
function TopupBounsSlot_Controller:ctor(parent, game)
    self.game = game
    self.render = parent --(Game_Node节点)
    self.slotContainers = {}
    --下方3x5转盘
    self.slotContainers[1] = TopupBounsSlot.New(self.game.normal_slot_:GetChild("slot"), self.game,3,5)
    --上方3x5转盘
    self.slotContainers[2] = TopupBounsSlot.New(self.render:GetChild("3x5_up"):GetChild("slot"), self.game,3,5)
    --下方3x7转盘
    self.slotContainers[3] = TopupBounsSlot.New(self.render:GetChild("3x7_down"):GetChild("slot"), self.game,3,7)
    --上方3x7转盘
    self.slotContainers[4] = TopupBounsSlot.New(self.render:GetChild("3x7_up"):GetChild("slot"), self.game,3,7)
    --剩余旋转次数
    self.SpinNum_node = self.game.render:GetChild("special_spin_number")
    --3x5变3x7时显示的提示节点
    self.change_info_node = self.game.render:GetChild("add_reel_node")
    --转盘类型(默认单个3x5)
    self._slottype = 1
    --真实运转的转盘
    self.real_running_slots = {
        [1] = {
            [1] = {
                slot = self.slotContainers[1],
                node = self.game.normal_slot_,
                bg = self.game.normal_slot_:GetChild("bg"),
            }
        },
        [2] = {
            [1] = {
                slot = self.slotContainers[1],
                node = self.game.normal_slot_,
                bg = self.game.normal_slot_:GetChild("bg"),
            },
            [2] = {
                slot = self.slotContainers[2],
                node = self.render:GetChild("3x5_up"),
                bg = self.render:GetChild("3x5_up"):GetChild("bg"),
            },
        },
        [3] = {
            [1] = {
                slot = self.slotContainers[3],
                node = self.render:GetChild("3x7_down"),
                bg = self.render:GetChild("3x7_down"):GetChild("bg"),
            },
        },
        [4] = {
            [1] = {
                slot = self.slotContainers[3],
                node = self.render:GetChild("3x7_down"),
                bg = self.render:GetChild("3x7_down"):GetChild("bg"),
            },
            [2] = {
                slot = self.slotContainers[4],
                node = self.render:GetChild("3x7_up"),
                bg = self.render:GetChild("3x7_up"):GetChild("bg"),
            },
        },
    }
end

function TopupBounsSlot_Controller:__delete()
    for i = 1, #self.slotContainers do
        self.slotContainers[i]:Delete()
    end

    self:CleanTimers()
    FTween.KillTweens(self.render)
    
    self.render = nil
end

--清理状态
function TopupBounsSlot_Controller:ResetState()
    local run_list = self.real_running_slots[self._slottype]
    for index, value in ipairs(run_list) do
        value.slot:ResetState()
    end
    self.run_end_number = 0
    self.car_anim_run_end_number = 0
    self.car_anim_normal_run_end_number = 0
end

--清理状态
function TopupBounsSlot_Controller:RemoveTopSymbol()
    local run_list = self.real_running_slots[self._slottype]
    for index, value in ipairs(run_list) do
        value.slot:RemoveTopSymbol()
    end
end

-- 游戏开始之前重置参数
function TopupBounsSlot_Controller:ResetDatas(isNewGame, hasSpinNum, winCoin,other_wincoin)
    self.hasSpinNum = hasSpinNum 
    self.winCoin = winCoin or 0
    self.other_wincoin = other_wincoin or 0
    if isNewGame then
        self:RemoveTopSymbol()
        self:ResetState()
    end
end

function TopupBounsSlot_Controller:SetSpinNum(hasSpinNum)
    self.hasSpinNum = hasSpinNum 
    if self.hasSpinNum <= 4 then
        local run_list = self.real_running_slots[self._slottype]
        for index, value in ipairs(run_list) do
            value.slot:SetNeedComeAnim(true)
        end
    end  
end

function TopupBounsSlot_Controller:GetSpinNum()
    return self.hasSpinNum
end

--设置是否为额外的普通游戏
function TopupBounsSlot_Controller:SetNeedOtherGame(bool)
    local run_list = self.real_running_slots[self._slottype]
    for index, value in ipairs(run_list) do
        value.slot:SetNeedOtherGame(bool)
    end
end

-- @brief 滚动开始
function TopupBounsSlot_Controller:SpinStart()
    -- spin按钮置为等待状态
    FCasinoCtx:SetSpinStatus(FSpinStatus.WAITING)
    local run_list = self.real_running_slots[self._slottype]
    for index, value in ipairs(run_list) do
        value.slot:SpinStart()
    end
    self.hasSpinNum = self.hasSpinNum - 1
    self:ShowSpinNum()
end

function TopupBounsSlot_Controller:Update(dt)
    for i = 1, #self.slotContainers do 
        self.slotContainers[i]:Update(dt)
    end
end

function TopupBounsSlot_Controller:QuickStop()
    local run_list = self.real_running_slots[self._slottype]
    for index, value in ipairs(run_list) do
        value.slot:QuickStop()
    end
end

--设置转盘类型
function TopupBounsSlot_Controller:SetSlotType(type_)
    self._slottype = type_
    if type_ == 0 then
        self._slottype = 1
    end
end

-- 处理格子信息:reconnect:断网重连和第一次进入都为true
function TopupBounsSlot_Controller:HandleCellDatas(graphs,reconnect)
    local run_list = self.real_running_slots[self._slottype]
    for index, value in ipairs(run_list) do
        --dump(graphs[index].grids,"==========graphs[index].grids============")
        value.slot:HandleCellDatas(graphs[index].grids,reconnect)
        --dump(graphs[index].grids,"==========graphs[index].lines============")
        value.slot:HandleWinDatas(graphs[index].lines)
    end
end

--进入时需先设置格子数据，用以做动画使用(只会传入普通或者免费的grids)
function TopupBounsSlot_Controller:SetLastReelSymbolData(grids,isReconnect,isothergame,needchangekg)
    local run_list = self.real_running_slots[self._slottype]
    local bool = false
    if self.hasSpinNum == 5 then
        bool = true
    end
    local newGrids = {}
    if self._slottype >= 3 then
        --普通和免费进入需要根据需要补足3x7的格子
        local rowSize = 5 -- 原始矩阵的列数
        -- 新建一个数组，长度为原数组长度加上两边新增的列
        for i = 1, #grids + 3 * 2 do
            newGrids[i] = {} 
        end

        -- 将原有数据复制到新数组中
        local index = 1
        for row = 1, 3 do
            -- 添加左侧的新列
            newGrids[index] = {
                SymbolType  = 0,
                SymbolValue = 0,
                icon        = 1,
                trainStart  = 0,
                index       = index,
            }
            index = index + 1

            -- 复制原有数据
            for col = 1, 5 do
                local data = grids[(row - 1) * rowSize + col]
                newGrids[index].SymbolType = data.SymbolType
                newGrids[index].SymbolValue = data.SymbolValue
                newGrids[index].icon = data.icon
                newGrids[index].index = index
                --trainStart是矿车在原来的格子中的起始点，需要重新计算在新格子中的起始点
                if not newGrids[index].trainStart then
                    if newGrids[index].SymbolType ~= 0 then
                        self:SetNodeForType(data.SymbolType,index,index,newGrids)
                    else
                        newGrids[index].trainStart = 0
                    end
                end
                index = index + 1
            end

            -- 添加右侧的新列
            newGrids[index] = {
                SymbolType  = 0,
                SymbolValue = 0,
                icon        = 1,
                trainStart  = 0,
                index       = index,
            }
            index = index + 1
        end
    else
        if needchangekg then
            local initDatas = ConstCfg.TopupBounsUIBox
            local initSymbols = Tools.InitUIBox2Symbol_Bouns(initDatas,5)
            newGrids = initSymbols
        else
            newGrids = grids
        end
    end
    if isothergame then
        for index, value in ipairs(run_list) do
            value.slot:OtherGameSetLastReelSymbolData(newGrids)
        end
    else
        for index, value in ipairs(run_list) do
            value.slot:SetLastReelSymbolData(newGrids,bool,isReconnect)
        end
        if self._slottype >= 3 and (not isReconnect) then
            for index, value in ipairs(run_list) do
                value.slot:SetSpecifyReelVisible(1,false)
                value.slot:SetSpecifyReelVisible(7,false)
                value.bg:GetTransition("enter"):Play()
            end
        end
    end
end

function TopupBounsSlot_Controller:SetNodeForType(type_,index,trainStart,newGrids)
    local carCfg = CarTypeCfg[type_]
    local real_x = self:GetReelIndex(index) + 1
    local real_y = self:GetCellIndex(index) + 1
    for x = real_x, real_x + carCfg.x_lenth - 1 do
        for y = real_y, real_y + carCfg.y_lenth - 1 do
            local xy = (y - 1) * 7 + x
            --新表后续矩形范围不让创建,并将数据都填充为当前数据
            newGrids[xy].trainStart = trainStart
        end
    end
end

-- @brief 获取转轴下标
-- @return [0,4]
function TopupBounsSlot_Controller:GetReelIndex(index)
    return (index - 1) % 7
end

-- @brief 获取Y轴格子下标
-- @return [0,2]
function TopupBounsSlot_Controller:GetCellIndex(index)
    local reelCfg = self.cfg
    return math.floor((index - 1) / 7)
end

-- @brief 设置图案数据
-- @param finishcallback 中奖线播放一轮后的回调函数
-- @param reconnect 快速设置，跳过动画(断线重连回来)
function TopupBounsSlot_Controller:SetReelSymbolData(callback, reconnect)
    self.onFinishCallback = callback
    local run_list = self.real_running_slots[self._slottype]
    -- 设置最终停止数据 跳过动画
    if reconnect then
        for index, value in ipairs(run_list) do
            value.slot:ReconnectSetReelSymbolData()
            value.slot:ReconnectRunOverOfChangeBounsSlotToCar()
        end
        FCasinoCtx:SetSpinStatus(FSpinStatus.SPIN)
        if self.onFinishCallback then
            self.onFinishCallback()
            self.onFinishCallback = nil
        end
        return
    end
    FCasinoCtx:SetSpinStatus(FSpinStatus.WAITING)
    for index, value in ipairs(run_list) do
        value.slot:NotReconnectSetReelSymbolData()
        value.slot:SetOnFinishCallback(function ()
            self.run_end_number = self.run_end_number + 1
            if self.run_end_number >= #run_list then
                --先转变落地牌为矿车再进行下一步
                self:RunOverOfChangeBounsSlotToCar()
            end
        end)
    end
end

--正常流程转变落地牌为矿车
function TopupBounsSlot_Controller:RunOverOfChangeBounsSlotToCar()
    if self.hasSpinNum >= 5 then
        self.onFinishCallback()
        self.onFinishCallback = nil
        return
    end
    local run_list = self.real_running_slots[self._slottype]
    self:ManipulateChildChangeBounsSlotToCar(run_list,function ()
        self.onFinishCallback()
        self.onFinishCallback = nil
    end)
end

--转盘转化动画
function TopupBounsSlot_Controller:ManipulateChildChangeBounsSlotToCar(run_list,callback)
    for index, value in ipairs(run_list) do
        value.slot:RunOverOfChangeBounsSlotToCar(function ()
            self.car_anim_run_end_number = self.car_anim_run_end_number + 1
            if self.car_anim_run_end_number >= #run_list then
                if callback then
                    callback()
                end
            end
        end)
    end
end

--转盘进入动画和格子转化动画
function TopupBounsSlot_Controller:PlaySlotChangeAnim(callback)
    --单倍3x7,2倍3x5和2倍3x7会有额外的进入动画(转盘变化动画)
    local run_list = self.real_running_slots[self._slottype]
    if self._slottype <= 1 then
        print("========单转盘3x5==========")
        --格子转化动画
        self:ManipulateChildChangeBounsSlotToCar(run_list,callback)
    elseif self._slottype <= 2 then
        print("========双转盘3x5==========")
        --2倍3x5
        for index, value in ipairs(run_list) do
            value.node:GetTransition("reseting"):Play()
            value.node:GetTransition("enter"):Play()
        end
        --格子转化动画
        self:TakeABreak(function ()
            self:ManipulateChildChangeBounsSlotToCar(run_list,callback)
        end,3)
    elseif self._slottype <= 3 then
        print("========单转盘3x7==========")
        --单倍3x7
        --先显示进入提示
        self.change_info_node.visible = true
        self.change_info_node:GetTransition("enter"):Play(1,0,function ()
            --再进行单倍转盘转化
            for index, value in ipairs(run_list) do
                value.node:GetTransition("reseting"):Play()
                value.node:GetTransition("change_reels_down"):Play()
            end
            self:TakeABreak(function ()
                self.change_info_node:GetTransition("out"):Play(1,0,function ()
                    self.change_info_node.visible = false
                end)
                for index, value in ipairs(run_list) do
                    value.slot:SetSpecifyReelVisible(1,true)
                    value.slot:SetSpecifyReelVisible(7,true)
                end
                self:TakeABreak(function ()
                    --格子转化动画
                    self:TakeABreak(function ()
                        self:ManipulateChildChangeBounsSlotToCar(run_list,callback)
                    end,1.5)
                end,0.5)
            end,1.5)
        end)
    else
        print("========双转盘3x7==========")
        --2倍3x7
        --双倍进入提示
        for index, value in ipairs(run_list) do
            value.node:GetTransition("reseting"):Play()
            value.node:GetTransition("enter"):Play()
        end
        self:TakeABreak(function ()
            self.change_info_node.visible = true
            self.change_info_node:GetTransition("enter"):Play(1,0,function ()
                for index, value in ipairs(run_list) do
                    local name = "change_reels_down"
                    if index ~= 1 then
                        name = "change_reels_up"
                    end
                    value.node:GetTransition(name):Play()
                end
                self:TakeABreak(function ()
                    self.change_info_node:GetTransition("out"):Play(1,0,function ()
                        self.change_info_node.visible = false
                    end)
                    for index, value in ipairs(run_list) do
                        value.slot:SetSpecifyReelVisible(1,true)
                        value.slot:SetSpecifyReelVisible(7,true)
                    end
                    self:TakeABreak(function ()
                        --格子转化动画
                        self:TakeABreak(function ()
                            self:ManipulateChildChangeBounsSlotToCar(run_list,callback)
                        end,1.5)
                    end,0.5)
                end,1.5)
            end)
        end,3)
    end
end

--额外的旋转结束进入落地牌效果的动画
function TopupBounsSlot_Controller:PlayEnterSpecial(spinData,isReconnect,callback)
    FCasinoCtx:SetSpinStatus(FSpinStatus.WAITING)
    self.game:StopBGM()
    if isReconnect then
        print("=========落地牌额外旋转处理,断网重连==========")
        self:SetSlotType(spinData.trainType)
        self.game:SetGameMode(FGameMode.SPECIAL)
        FCasinoCtx.commonPanel:ShowTop(false)
        --断网重连，进入落地牌
        local winCoin = self.game.slotContainers[self.game._entertype]:GetWinCoin()
        local othercoin = 0
        self.game:ChangeControllerState("special")
        self.game:ChangeNormalSlotControllerState("special")
        self.game:ChangeSlotControllerState(self.game.Reel_Container[spinData.trainType])
        self:ResetDatas(true,5,winCoin,othercoin)
        self:SetLastReelSymbolData(spinData.graphs[1].grids,isReconnect,true)
        self:ShowSpinNum()
        self.game:SetBGM("special")
        self.game:AutoClick(true)
        return
    end
    print("=========落地牌额外旋转处理,正常进入==========")
    self.game:StopLines()
    self:SetSlotType(spinData.trainType)
    local winCoin = self.game.slotContainers[self.game._entertype]:GetWinCoin()
    local othercoin = 0
    self:ResetDatas(true,5,winCoin,othercoin)
    self:SetLastReelSymbolData(spinData.graphs[1].grids,isReconnect,true)
    local fun_ = function (...)
        --落地牌入场动画
        local Enter_Special_Node = FairyGUI.UIPackage.CreateObject("Game375", "Enter_Special_Node")
        Enter_Special_Node.visible = false
        self.game.render:AddChild(Enter_Special_Node)
        Enter_Special_Node.visible = true
        local str_ = "single"
        if spinData.trainType % 2 == 0 then
            str_ = "plural"
        end
        Enter_Special_Node:GetController("show_type").selectedPage = str_
        Enter_Special_Node:GetTransition("run"):Play(1,0,function ()
            Enter_Special_Node:RemoveFromParent(true)
            Enter_Special_Node = nil
            self.game:SetBGM("special")
            FCasinoCtx.commonPanel:ShowTop(false)
            --入场动画结束后做转盘动画和节点转换动画，做完后才是开始旋转
            self:PlaySlotChangeAnim(function ()
                callback()
            end)
        end)
        --入场动画4秒，3秒时换控制器
        self:TakeABreak(function ()
            self.game:SetGameMode(FGameMode.SPECIAL)
            self.game:ChangeControllerState("special")
            self.game:ChangeSlotControllerState(self.game.Reel_Container[spinData.trainType])
            self.game:ChangeNormalSlotControllerState("special")
            self:SlotChangeKG()
            self:ShowSpinNum()
        end,3)
    end
    --先播放入场音效，长7秒，3秒后播放动画
    FToolSet.PlayFGUISound(MusicCfg.MineCartIntroSFXOnly)
    local random_ = math.random(1, 30)
    FToolSet.PlayFGUISound(MusicCfg.MineCartIntroYell..((random_ % 3) + 1))
    self:TakeABreak(fun_,1.5)
end

--额外游戏转盘转换矿工
function TopupBounsSlot_Controller:SlotChangeKG()
    local run_list = self.real_running_slots[self._slottype]
    for index, value in ipairs(run_list) do
        value.slot:OtherGameChangeKG()
    end
end

--转盘结算(跑火车)
function TopupBounsSlot_Controller:SpecialOver(callback)
    local run_list = self.real_running_slots[self._slottype]
    --先所有转盘播放雷管爆炸效果,播放3秒
    for index, value in ipairs(run_list) do
        value.slot.symbol_car_anim:RunOverBoomAnim()
    end
    self:TakeABreak(function ()
        --根据当前状态的转盘数量决定是否要播放转盘交替动画
        if #run_list < 2 then
            print("=====单转盘结算=========")
            --单个转盘结算就无需播放交替动画，直接结算
            run_list[1].slot:SetOverWinCarFun(callback)
            run_list[1].slot:CompletionWinCar()
            return 
        end
        --结算要一个转盘一个转盘结算，从下方转盘到上方转盘
        --上方转盘移出
        print("=====双转盘结算=========")
        self.render:GetTransition("out_up_slot"):Play(1,0,function ()
            --下方转盘开始结算
            run_list[1].slot:SetOverWinCarFun(function ()
                --下方转盘结算完毕，切换成上方转盘
                self.render:GetTransition("changeto_up_slot"):Play(1,0,function ()
                    --上方转盘开始结算
                    run_list[2].slot:SetOverWinCarFun(function ()
                        --上方转盘结算完毕，重置转盘位置
                        self.render:GetTransition("reseting"):Play(1,0,callback)
                    end)
                    run_list[2].slot:CompletionWinCar()
                end)
            end)
            run_list[1].slot:CompletionWinCar()
        end)
    end,3)
end

--清除格子上的火车动画节点数据
function TopupBounsSlot_Controller:CleanCarAnimData()
    local run_list = self.real_running_slots[self._slottype]
    for index, value in ipairs(run_list) do
        value.slot:CleanCarAnimData()
    end
end

function TopupBounsSlot_Controller:GetWinCoin()
    return self.winCoin
end

function TopupBounsSlot_Controller:GetOtherWinCoin()
    return self.other_wincoin
end

--显示剩余旋转次数
function TopupBounsSlot_Controller:ShowSpinNum(number)
    local realnumber = number or self.hasSpinNum
    self.SpinNum_node.visible = realnumber >= 1
    local txt = self.game.render:GetChild("n19")
    txt.text = realnumber
end
function TopupBounsSlot_Controller:SetOpen(isOpen)
    self.isOpen = isOpen
end

function TopupBounsSlot_Controller:SetVisible(bool)
    if bool then
        local show_type = TopupBounsSlot_Controller.PlayTypeWithSlot[self._slottype]
        for k, slot in ipairs(self.slotContainers) do
            slot:SetVisible(show_type[k])
            slot:SetOpen(show_type[k])
        end
    else
        for k, slot in ipairs(self.slotContainers) do
            slot:SetVisible(bool)
            slot:SetOpen(bool)
        end
    end
end

--停2秒再继续
function TopupBounsSlot_Controller:TakeABreak(callback,time)
    self.TakeABreaktimer = StartOnceTimer(function ()
        self.TakeABreaktimer = nil
        callback()
    end,time or 2)
end

function TopupBounsSlot_Controller:CleanTimers()
    if self.TakeABreaktimer then
        StopTimer(self.TakeABreaktimer)
        self.TakeABreaktimer = nil
    end
end
return TopupBounsSlot_Controller
