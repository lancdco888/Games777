-- 老虎机落地牌游戏，三个格子一组转动
local Reel              = Import(".Reel")
local SymbolConfig      = Import(".SymbolConfig")
local BaseSlot          = Import(".BaseSlot")
local MusicCfg          = Import(".MusicCfg")
local Tools             = Import(".Tools")
local ConstCfg          = Import(".ConstCfg")
local SymbolCarAnim     = Import(".SymbolCarAnim")
local TopupBounsSlot    = Class("TopupBounsSlot", BaseSlot)

function TopupBounsSlot:ctor(parent, game,yCellNumber,xCellNumber)
    --需先修改cfg数据然后再克隆
    FCasinoCtx.gameCfg.Reel.yCellNumber = yCellNumber
    FCasinoCtx.gameCfg.Reel.xCellNumber = xCellNumber
    self._str_symbol = "3x5"
    if xCellNumber == 7 then
        self._str_symbol = "3x7"
        FCasinoCtx.gameCfg.Reel.reelWidth = 92
        FCasinoCtx.gameCfg.Reel.reelHeight = 249
        FCasinoCtx.gameCfg.Reel.reelSpace = 5
    else
        FCasinoCtx.gameCfg.Reel.reelWidth = 128
        FCasinoCtx.gameCfg.Reel.reelHeight = 348
        FCasinoCtx.gameCfg.Reel.reelSpace = 8
    end
    
    self._reelcfg = clone(FCasinoCtx.gameCfg.Reel)
    local reelCfg = self._reelcfg
    local xNum = reelCfg.xCellNumber -- 5
    local yNum = reelCfg.yCellNumber -- 3

    local index = 0
    for i = 1, yNum do
        for j = 1, xNum do
            index = index + 1
            local reel = Reel.New(self.bottomContainer, j, 1)
            -- 修改转轴配置高度
            reel.cfg.reelHeight = reel.cfg.reelHeight / yNum
            reel:SetGame(game)
            reel:Set_Str_Symbol(self._str_symbol)
            reel:SetMask(true)
            reel:InitSymbol()
            reel.reelContainer:SetupOverflowHidden(true)
            reel.reelContainer.x = (j - 1) * (reelCfg.reelWidth + reelCfg.reelSpace)
            reel.reelContainer.y = (i - 1) * reel.cfg.symbolHeight
            self.reels[index] = reel
        end
    end

    --格子上的火车动画节点
    self.symbol_car_anim = SymbolCarAnim.New(parent, self._reelcfg, self)
end

function TopupBounsSlot:__delete()
    self.symbol_car_anim:Delete()
end

--清理状态
function TopupBounsSlot:ResetState()
    self.reelDatas = {}
    self.grids = {}
    self.initgrids = {}
    self.old_bouns_list = {}
    self.new_bouns_list = {}
    self.drawLines = {}
    self.playindex = 0
    self.topupBounsCount = 0
    self.hasNewTopupBonus = false
    self.needcomeanim = false
    self.needothergame = false
    self.OverWinCarFun = nil
    self.symbol_car_anim:ResetState()
    self:CleanTimers()
end

-- 游戏开始之前重置参数
function TopupBounsSlot:ResetDatas(isNewGame, hasSpinNum, winCoin,other_wincoin)
    self.hasSpinNum = hasSpinNum or 3
    self.winCoin = winCoin or 0
    self.other_wincoin = other_wincoin or 0
    self.needothergame = false      --第一把是否为额外的普通游戏
    if isNewGame then
        self:RemoveTopSymbol()
        self:ResetState()
    end
end

function TopupBounsSlot:SetSpinNum(hasSpinNum)
    self.hasSpinNum = hasSpinNum or 3
end

function TopupBounsSlot:GetSpinNum()
    return self.hasSpinNum
end

function TopupBounsSlot:GetTopupBounsCount()
    return self.topupBounsCount
end

--获取所有落地牌节点
function TopupBounsSlot:GetWinNodeList()
    return self.new_bouns_list
end

-- @brief 滚动开始
function TopupBounsSlot:SpinStart()
    if self:IsAllBounsCount() and (not self.hasNewTopupBonus) then
        return
    end
    -- 转轴开始滚动
    for k, v in pairs(self.reels) do
        if not self.new_bouns_list[k] then
            v:SpinForever()
        end
    end
end

-- 处理格子信息:reconnect:断网重连和第一次进入都为true
function TopupBounsSlot:HandleCellDatas(grids,reconnect,needchangekg)
    -- 整理服务器数据
    local reelDatas = {}
    local topupBounsCount = 0
    local hasNewTopupBonus = false
    local initDatas = {}
    local reelCfg = self._reelcfg
    if reelCfg.xCellNumber == 5 then
        initDatas = ConstCfg.TopupBounsUIBox
    else
        initDatas = ConstCfg.TopupBounsUIBox_2
    end
    local initSymbols = Tools.InitUIBox2Symbol_Bouns(initDatas,reelCfg.xCellNumber)
    if not grids then
        grids = initSymbols
    end
    self.old_bouns_list = self:GetTopSymbolList()   --旧落地牌上层表
    for k, v in ipairs(grids) do
        local cell = nil
        local reelIndex = self:GetReelIndex(k) + 1
        local iconIndex = self:GetCellIndex(k) + 1
        --正常处理
        cell = v
        local reel_icon = cell.icon
        if Tools.IsJpCard_3x7(reel_icon) or Tools.IsJpCard_Double(reel_icon) then
            reel_icon = Tools.BounsIconID
        end
        if Tools.IsJpCard(reel_icon) then
            if (not self.needothergame) then
                -- 落地牌
                topupBounsCount = topupBounsCount + 1
                -- 上层表中，对应格子不存在，并且不是在断网重连的情况下,才代表这次有中新的落地牌
                if (not self.old_bouns_list[k]) and (not reconnect) then
                    hasNewTopupBonus = true
                end
            end
        else
            --特殊情况下，除落地牌，其他牌都为矿工
            if needchangekg then
                reel_icon = 1
            end
        end
        reelDatas[k] = {{
            icon = reel_icon,
            value = cell.SymbolValue or 0,
            type = cell.SymbolType or 0,
        }}
    end
    self.reelDatas = reelDatas
    self.grids = grids          --矿车动画用
    self:ChangeGridsForCarAnim()
    self.hasNewTopupBonus = hasNewTopupBonus
    self.topupBounsCount = topupBounsCount
end

-- 分析格子数据，在动画层双倍图和3x7图统一视为单倍落地牌，所以数据需要修改后才能传入
function TopupBounsSlot:ChangeGridsForCarAnim()
    for i,v in ipairs(self.grids) do
        if Tools.IsJpCard_3x7(v.icon) or Tools.IsJpCard_Double(v.icon) then
            v.icon = Tools.BounsIconID
        end
    end
end

-- 中奖线处理
function TopupBounsSlot:HandleWinDatas(lines)
    if not next(lines) then
        return
    end
    local drawLines = {}        --中奖线
    for i, line in ipairs(lines) do
        --dump(line,"========line========")
        --dump(line.lineCells,"========" .. tostring(line.lineIndex).."========")
        --只有火车中奖线才需要处理
        if line.trainType <= 12 then
            drawLines = self:SplitWinningData(line,drawLines)
        end
    end
    self.drawLines = drawLines
end

-- 拆分火车中奖线数据,并重组中间线数据
function TopupBounsSlot:SplitWinningData(line,outlist)
    local lineCells = line.lineCells
    --检测最后一个中奖数据是否是彩金奖
    local data_ = lineCells[#lineCells]
    local real_line_data = {}
    if data_.SymbolType >= 3 then
        --有中大巨彩金的，把前部分重组为一部分
        local car_data = {}
        for i = 1, (#lineCells - 1) do
            local data = lineCells[i]
            car_data[i] = data
        end
        local line_data = {}
        line_data.lineCells = car_data
        line_data.trainType = line.trainType
        line_data.trainStart = line.trainStart
        table.insert(real_line_data,line_data)
        --后半彩金数据的部分重组为一部分
        local caijin_data = {}
        caijin_data[1] = data_
        local caijin_line_data = {}
        caijin_line_data.lineCells = caijin_data
        caijin_line_data.trainType = line.trainType
        caijin_line_data.trainStart = 0
        table.insert(real_line_data,caijin_line_data)
    else
        local line_data = {}
        line_data.lineCells = lineCells
        line_data.trainType = line.trainType
        line_data.trainStart = line.trainStart
        table.insert(real_line_data,line_data)
    end
    table.insert(outlist,real_line_data)
    return outlist
end

--结算中奖矿车完毕后回调
function TopupBounsSlot:SetOverWinCarFun(callback)
    self.OverWinCarFun = callback
end

--结算中奖矿车
function TopupBounsSlot:CompletionWinCar()
    self.playindex = self.playindex + 1
    if self.playindex > #self.drawLines then
        --中奖矿车都播放完毕后，进行下一步结算
        self.OverWinCarFun()
        self.OverWinCarFun = nil
        return
    end
    --根据中奖矿车类型，播放对应的动画
    local run_data = self.drawLines[self.playindex]
    self.symbol_car_anim:RunOverOfCarAnim(run_data,function ()
        self:CompletionWinCar()
    end)
end

--额外旋转进入快速设置
function TopupBounsSlot:OtherGameSetLastReelSymbolData(grids)
    self:HandleCellDatas(grids,false,false)
    self:OnReelScrollStopCreate()
    for k, v in pairs(self.reels) do
        v:SetOpen(self.isOpen)
        v:Recovery(self.reelDatas[k])
    end
    for index, value in pairs(self.new_bouns_list) do
        self:Play_StopAnim(index)
    end
end

--额外旋转转变图案为矿工
function TopupBounsSlot:OtherGameChangeKG()
    for index, value in pairs(self.reels) do
        local display = value.arraySymbolDisplays
        local data = value.arraySymbolDatas[1]
        local render = display[1].render
        if not Tools.IsJpCard(data.icon) then
            value.arraySymbolDatas[1].icon = 1
            data.icon = 1
            local icon = render:GetChild("icon")
            local upcfg = SymbolConfig.Icon[data.icon]
            icon.url = upcfg.icon
            value.upcfg = upcfg
        end
    end
end

function TopupBounsSlot:SetNeedOtherGame(bool)
    self.needothergame = bool
end

--设置是否需要落地牌特殊停止动画
function TopupBounsSlot:SetNeedComeAnim(bool)
    self.needcomeanim = bool
end

--恢复图案或者说快速设置图案
function TopupBounsSlot:SetLastReelSymbolData(grids,needchangekg,isReconnect)
    self:HandleCellDatas(grids,true,needchangekg)
    self:OnReelScrollStopCreate()
    for k, v in pairs(self.reels) do
        v:SetOpen(self.isOpen)
        v:Recovery(self.reelDatas[k])
    end
    for index, value in pairs(self.new_bouns_list) do
        self:Play_StopAnim(index)
    end
    if isReconnect then
        self.symbol_car_anim:ReconnectAddNewBounsSymbol(self.grids)
    end
end

-- 特殊操作，在进入动画完毕后播放之前所有的停止动画
function TopupBounsSlot:Play_All_StopAnim()
    for index, value in pairs(self.new_bouns_list) do
        self:Play_StopAnim(index,true)
    end
end

-- @brief 设置图案数据
-- @param finishcallback 中奖线播放一轮后的回调函数
-- @param reconnect 快速设置，跳过动画(断线重连回来)
-- function TopupBounsSlot:SetReelSymbolData(callback, reconnect)
--     self.onFinishCallback = callback
--     -- 设置最终停止数据 跳过动画
--     if reconnect then
--         self:OnReelScrollStopCreate()
--         for k, v in pairs(self.reels) do
--             v:SetOpen(self.isOpen)
--             v:Recovery(self.reelDatas[k])
--         end
--         for index, value in pairs(self.new_bouns_list) do
--             self:Play_StopAnim(index)
--         end
--         FCasinoCtx:SetSpinStatus(FSpinStatus.SPIN)
--         if self.onFinishCallback then
--             self.onFinishCallback()
--             self.onFinishCallback = nil
--         end
--         return
--     end
--     FCasinoCtx:SetSpinStatus(FSpinStatus.WAITING)
--     --先创建停止所需要显示上层图案
--     self:OnReelScrollStopCreate()
--     self:_StopSReelsSpin()
-- end

--可能会有多个转盘同时转动，所以需要单独设置转完之后的回调函数
function TopupBounsSlot:SetOnFinishCallback(callback)
    if self:IsAllBounsCount() and (not self.hasNewTopupBonus) then
        self.onFinishCallback = nil
        callback()
        return
    end
    self.onFinishCallback = callback
end

function TopupBounsSlot:ReconnectSetReelSymbolData()
    self:OnReelScrollStopCreate()
    for k, v in pairs(self.reels) do
        v:SetOpen(self.isOpen)
        v:Recovery(self.reelDatas[k])
    end
    for index, value in pairs(self.new_bouns_list) do
        self:Play_StopAnim(index)
    end
end

function TopupBounsSlot:NotReconnectSetReelSymbolData()
    if self:IsAllBounsCount() and (not self.hasNewTopupBonus) then
        return
    end
    --先创建停止所需要显示上层图案
    self:OnReelScrollStopCreate()
    self:_StopSReelsSpin()
end

--最终转轴层图案状态先创建
function TopupBounsSlot:OnReelScrollStopCreate()
    self.new_bouns_list = {}    --新落地牌上层表
    local reelCfg = self._reelcfg
    for index = 1, reelCfg.xCellNumber do
        for i = 1, reelCfg.yCellNumber do
            local xy_ = (i - 1) * reelCfg.xCellNumber + index
            local data = self.reelDatas[xy_][1]
            local upcfg = SymbolConfig.Icon[data.icon]
            if Tools.IsJpCard(data.icon) and (not self.needothergame) then
                local data_show = {}
                if not self.old_bouns_list[xy_] then
                    data_show.render_ = self:NewCreateTopSymbol(data,upcfg,xy_)
                    data_show.needshowlinghting = true
                else
                    data_show.render_ = self.old_bouns_list[xy_]
                    data_show.needshowlinghting = false
                end
                data_show.data = data
                data_show.upcfg = upcfg
                data_show.xIndex = index
                data_show.yIndex = i
                self.new_bouns_list[xy_] = data_show
            end
        end
    end
    --dump(self.new_bouns_list,"=======self.new_bouns_list========")
    --dump(self.old_bouns_list,"=====self.old_bouns_list========")
end

--停止转动
function TopupBounsSlot:_StopSReelsSpin()
    -- 筛选需要刷新图案的格子
    local needUpdateReels = {}
    for k, v in ipairs(self.reels) do
        if not self.old_bouns_list[k] then
            table.insert(needUpdateReels, {index = k, reel = v})
        end
    end
    local count = 0
    for k, v in ipairs(needUpdateReels) do
        local xIndex = self:GetReelIndex(v.index) + 1
        local yIndex = self:GetCellIndex(v.index) + 1
        if not self.old_bouns_list[v.index] then
            v.reel = self.reels[v.index]
            v.reel:Stop(self.reelDatas[v.index],function ()
                count = count + 1
                --落地牌停止特殊效果
                if self.new_bouns_list[v.index] then
                    if self.new_bouns_list[v.index].needshowlinghting then
                        self:Play_StopAnim(v.index,true and self.needcomeanim)
                        --落地牌强调音效
                        FToolSet.PlayFGUISound(MusicCfg.pearl_stop_sound .. count)
                    end
                end
                FToolSet.PlayFGUISound(MusicCfg.reel_stop)
                if count >= #needUpdateReels then
                    self:TakeABreak(function ()
                        self.onFinishCallback()
                        self.onFinishCallback = nil
                    end,0.5)
                end
            end,FConfig.Common:GetRellStopInterval(xIndex))
        end
    end
end

--播放停止效果
function TopupBounsSlot:Play_StopAnim(index,needcomeanim)
    local display = self.reels[index].arraySymbolDisplays
    local render = display[1].render
    render.visible = false
    local top_render = self.new_bouns_list[index].render_
    top_render.visible = true
    local node = top_render:GetChild("node")
    local real_render = top_render
    --3x7格子用的node作为主节点
    if node then
        real_render = node
    end
    if self.new_bouns_list[index].upcfg.animations then
        if needcomeanim then
            real_render:GetTransition(self.new_bouns_list[index].upcfg.animations.come):Play(1,0,function () 
                real_render:GetTransition(self.new_bouns_list[index].upcfg.animations.loop):Play(-1,0,function () end)
            end)
        else
            real_render:GetTransition(self.new_bouns_list[index].upcfg.animations.loop):Play(-1,0,function () end)
        end
    end
    self.new_bouns_list[index].needshowlinghting = false
end

--创建上层图案
function TopupBounsSlot:NewCreateTopSymbol(data,upcfg,logicIndex)
    local render_ = self:GetOrCreateTopSymbol(upcfg.topzorder,logicIndex,self._str_symbol)
    render_.visible = false
    local node = render_:GetChild("node")
    local real_render = render_
    --3x7格子用的node作为主节点
    if node then
        real_render = node
    end
    local image = real_render:GetChild("icon")
    image.visible = true
    image.url = upcfg.icon
    if upcfg.Scale then
        image.scale = upcfg.Scale
    end
    if upcfg.Pos then
        image.xy = upcfg.Pos
    end
    -- 遮罩(只有落地牌并且不是心的时候才显示遮罩)
    local mask = real_render:GetChild("mask")
    if not Tools.IsJpCard(data.icon) then
        mask.visible = self.showMask or false
    end
    return render_
end

--设置初始化矿车动画层图案数据
function TopupBounsSlot:InitCarAnimSymbol(grids)
    local initgrids = {}
    for i,v in ipairs(grids) do
        local real_SymbolType = v.SymbolType
        if Tools.IsJpCard(v.icon) then
            real_SymbolType = 15
        end
        initgrids[i] = {
            SymbolType = real_SymbolType,
            SymbolValue = v.SymbolValue,
            icon = v.icon,
            index = v.index,
        }
    end
    self.initgrids = initgrids
end

--正常流程转变落地牌为矿车
function TopupBounsSlot:RunOverOfChangeBounsSlotToCar(callback)
    self.symbol_car_anim:AddNewBounsSymbol(self.grids)
    self.symbol_car_anim:SetOnFinishCallback(callback)
    self.symbol_car_anim:RunChangeNode()
end

function TopupBounsSlot:ReconnectRunOverOfChangeBounsSlotToCar()
    self.symbol_car_anim:ReconnectAddNewBounsSymbol(self.grids)
end

function TopupBounsSlot:GetIndexOffSymbol(index)
    local top_render = self.new_bouns_list[index].render_
    return top_render
end

function TopupBounsSlot:GetWinCoin()
    return self.winCoin
end

function TopupBounsSlot:GetOtherWinCoin()
    return self.other_wincoin
end

--返回是否中全屏
function TopupBounsSlot:IsAllBounsCount()
    return self.topupBounsCount >= self._reelcfg.xCellNumber * self._reelcfg.yCellNumber
end

function TopupBounsSlot:SetOpen(isOpen)
    self.isOpen = isOpen
end

function TopupBounsSlot:SetSpecifyReelVisible(xindex,bool)
    for index, value in ipairs(self.reels) do
        local reel_index = self:GetReelIndex(index) + 1
        if xindex == reel_index then
            value:SetReelVisible(bool)
        end
    end
end

--清除格子上的火车动画节点数据
function TopupBounsSlot:CleanCarAnimData()
    self.symbol_car_anim:Clean()
end

--停2秒再继续
function TopupBounsSlot:TakeABreak(callback,time)
    self.TakeABreaktimer = StartOnceTimer(function ()
        self.TakeABreaktimer = nil
        callback()
    end,time or 2)
end

function TopupBounsSlot:CleanTimers()
    if self.TakeABreaktimer then
        StopTimer(self.TakeABreaktimer)
        self.TakeABreaktimer = nil
    end
end
return TopupBounsSlot
