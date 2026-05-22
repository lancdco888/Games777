local Utils = Import(".Utils")
local Reel = Import(".Reel")
local SymbolConfig = Import(".SymbolConfig")
local BaseSlot = Import(".BaseSlot")
local GameDefine = Import("..GameDefine")
local MusicCfg = Import(".MusicCfg")
local Slot = Class("Slot", BaseSlot)

function Slot:ctor(parent)
    local x = 0
    for i = 1, FCasinoCtx.gameCfg.Reel.xCellNumber do
        local reel = Reel.New(self.bottomContainer, i, 4)
        reel:SetOnClickCallBack(self,self.OnClick)
        reel:InitSymbol(GameDefine.InitSymbolData[i])
        reel.reelContainer.x = x
        self.reels[i] = reel

        -- 单列格子宽度
        x = x + FCasinoCtx.gameCfg.Reel.reelWidth
        -- 每列间距
        x = x + FCasinoCtx.gameCfg.Reel.reelSpace
    end
    self:SetReelCilckEnabled(true)
end

function Slot:__delete()
    self:Reset()
    for _, tweenr in pairs(self.shakeTweenrs) do
        tweenr:Kill(false)
    end
    self:StopReelAudio()
    self:StopReelSpeedAudio()
end

-- 免费用
function Slot:ResetDatas(isFree,curturn, allturns, totalWinCoin)
    if isFree then
        self.curturn = curturn
        self.allturns = allturns
        self.totalWinCoin = totalWinCoin or 0
    else
        self.curturn = nil
        self.allturns = nil
        self.totalWinCoin = nil
    end

    self.isFree = isFree
end

function Slot:Reset()
    self.reelDataArrays = {}
    self.onFinishCallback = nil
    self.showIndex = 1
    self.allDropCells = {}
    self.winCoin = 0
    self.scAppearAnims = {} -- 当前已经转出来的scrender
    self.needQuestSpeed = false
    self.isIntoFree = false
    self.shakeTweenrs = {}
    -- FCasinoCtx.commonPanel:StopScrollWinMoney(nil, true)
end

-- @brief 滚动开始
function Slot:SpinStart()
    -- spin按钮置为等待状态
    FCasinoCtx:SetSpinStatus(FSpinStatus.WAITING)
    if FCasinoCtx.curGameMode ~= FGameMode.FREE then
        FCasinoCtx.commonPanel:SetWinMoney(0)
    end
    self:RemoveMoveSymbol()
    -- 转轴开始滚动
    for k, v in pairs(self.reels) do
        v.stopZoreIndexData = {}
        v:SpinForever()
    end
    if self.isFree then
        self.curturn = self.curturn - 1
        FCasinoCtx:GetGame().tips:ShowFreeTimes(self.curturn)
    end
    self:PlayReelAudio()
    self:Reset()
    self:SetReelCilckEnabled(false)
    self:HideDetails()
end


function Slot:SetReelSymbolData(spinData, isReconnect, callback)
    self:Reset()
    self:GetDatas(spinData.results.array) -- 格子中奖线处理
    self:GetAllDropCells() -- 掉落的格子
    self.onFinishCallback = callback
    self.winCoin = spinData.winCoin
    if self.isFree then
        self.totalWinCoin = self.totalWinCoin + self.winCoin
    end
    self.isIntoFree = spinData.intoFree == 1
    -- dump(spinData.results.array,"spinData.results.array ", 5)
    -- dump(self.reelDataArrays,"self.reelDataArrays ", 5)
    -- 重连恢复数据并显示
    if isReconnect then
        local lastReelData = self.reelDataArrays[#self.reelDataArrays].reelDatas
        for k, v in pairs(self.reels) do
            v.stopZoreIndexData = {}
            v:Recovery(lastReelData[k])
        end
        if self.onFinishCallback then
            self.onFinishCallback()
            self.onFinishCallback = nil
        end
        -- if self.isFree then
        --     for i = 1, 5 do
        --         self:OnReelScrollStop(i, true)
        --     end
        -- end
    else
        local reelDataArray = self.reelDataArrays[self.showIndex]
        local reelDatas = reelDataArray.reelDatas
        local zoreReelIndexDatas = self:GetZoreDropCellData()
        local scReelIndexs = reelDataArray.scReelIndexs -- 出现免费的转轴
        local needSpeedIndex = reelDataArray.needSpeedIndex -- 需要加速的列 >needSpeedIndex
        -- dump(self.allDropCells,"self.allDropCells ", 10)
        -- dump(zoreReelIndexDatas,"zoreReelIndexDatas",3)
        local count = 0
        local curScount = 0
        for k, reel in ipairs(self.reels) do
            reel.stopZoreIndexData = zoreReelIndexDatas[k]
            local timer = FConfig.Common:GetRellStopInterval(k)
            if needSpeedIndex and k > needSpeedIndex then
                timer = timer +  5 * (k - needSpeedIndex)
            end
            reel:Stop(
                reelDatas[k],
                function()
                    count = count + 1
                    self:OnReelScrollStop(count, isReconnect)
                    if scReelIndexs[count] then
                        curScount = curScount + 1 
                    end
                    if self.needQuestSpeed then
                        self:SetMaskFreeAppearAndLightPos(count)
                    end
                    if needSpeedIndex and count == needSpeedIndex then -- 需要快速旋转
                        -- 显示遮罩 
                        if not FCasinoCtx.commonPanel:IsAccelerationMode() and not self.isFree then
                            FCasinoCtx:SetSpinStatus(FSpinStatus.STOP)
                        end
                        self.needQuestSpeed = true
                        self:OnReelQuickSpeedBegin(count)
                    end
                    FToolSet.PlayFGUISound(MusicCfg.reel_stop)
                    if count >= #self.reels then
                        self:StopReelSpeedAudio(true)
                        self:StopReelAudio(true)
                        if self.needQuestSpeed then
                            self.needQuestSpeed = false
                            self:OnReelQuickSpeedEnd()
                        end
                        Utils.Delay(self.parent,self.isIntoFree and 2 or 1,function ()
                            self:OnSpinOver(isReconnect)
                        end)
                    end
                end,
                timer
            )
        end

    end

end

function Slot:OnReelQuickSpeedBegin(count)
    self.maskFreeAppear.visible = true
    self.scLightEffect.visible = true
    self:SetMaskFreeAppearAndLightPos(count)
    for _, node in pairs(self.scAppearAnims) do
        node:GetTransition("scatIn"):Stop()
        node:GetTransition("scatSpeed"):Play()
    end
end

function Slot:OnReelQuickSpeedEnd()
    self.maskFreeAppear.visible = false
    self.scLightEffect.visible = false
    for _, node in pairs(self.scAppearAnims) do
        node:GetTransition("scatIdle"):Play()
    end
end

function Slot:SetMaskFreeAppearAndLightPos(count)
    local cfg = FCasinoCtx.gameCfg.Reel
    local reelSpace = cfg.reelSpace
    local reelWidth = cfg.reelWidth
    local pos = vec2(count*(reelWidth + reelSpace),306)
    self.maskFreeAppear.xy = pos
    self.scLightEffect.xy = pos
    self:StopReelSpeedAudio(true)
    self:PlayReelSpeedAudio()
end

function Slot:OnReelScrollStop(index, quickSet)
    local reelCfg = FCasinoCtx.gameCfg.Reel
    -- 替换动画到顶层显示
    local arraySymbolDisplays = self.reels[index].arraySymbolDisplays

    local winCells = self.reelDataArrays[self.showIndex].winCells
    for i = 1, reelCfg.yCellNumber do
        local display = arraySymbolDisplays[i]
        local cfg = SymbolConfig[display.data.icon]
        local logicIndex = (i - 1) * reelCfg.xCellNumber + index
        -- movePanel 
        local render = self:GetOrCreateMoveSymbol(logicIndex,display.data)
        self:_InitSymbolRender(render,cfg,display,true) -- 一起用
        if not cfg.isSc then
            render.visible = false
        else
            table.insert(self.scAppearAnims,render)
            render.sortingOrder = 200
            if self.needQuestSpeed and index < reelCfg.xCellNumber then
                render:GetTransition("scatIn"):Stop()
                render:GetTransition("scatSpeed"):Play()
            end
        end
        if winCells[logicIndex] then
            local tRender = self:GetOrCreateTopSymbol(logicIndex)
            self:_InitSymbolRender(tRender,cfg,display)
        end
    end
end

function Slot:_InitSymbolRender(render,cfg,display,isMovePanel)
    local whiteBG = render:GetChild("whiteBG")
    local goldBG = render:GetChild("goldBG")
    local isGolden = display.data.golden == 1 
    goldBG.visible = isGolden
    whiteBG.visible = not isGolden
    local icon = render:GetChild("icon")
    local swEffect = render:GetChild("swEffect")
   
    for _, nodeName in pairs(SymbolConfig.nodes) do
        local node = render:GetChild(nodeName)
        node.visible = false
    end
    
    if cfg.icon then
        icon.url = cfg.icon
        icon.visible = true
        swEffect.visible = false
    elseif cfg.node then
        goldBG.visible = false
        whiteBG.visible = false
        local node = render:GetChild(cfg.node)
        node.visible = true
        swEffect.visible = true
        icon.visible = false
    end
    if cfg.inAnim then
        if display.data.icon == GameDefine.ICON_SCATTER then
            FToolSet.PlayFGUISound(MusicCfg.scatter_emphasize)
        end
        render:GetTransition(cfg.inAnim):Play() -- 动画时间 2 秒
        if display.render then -- movePanel 补的cell没有render
            display.render.visible = false
        end
    else
        render.visible = false
    end
end

function Slot:OnSpinOver(isReconnect)
    if isReconnect then
        if self.onFinishCallback then
            self.onFinishCallback()
            self.onFinishCallback = nil
            -- FCasinoCtx:SetSpinStatus(FSpinStatus.SPIN)
        end
        return
    end
    if self.showIndex >= #self.reelDataArrays then -- 轮次结束
        if not self.isIntoFree then
            FToolSet.PlayFGUISound(MusicCfg.not_wins[math.random(1,5)])
        else
            FToolSet.PlayFGUISound(MusicCfg.vocals_mjhl)
            FToolSet.PlayFGUISound(MusicCfg.scatter_bj)
        end
        
        -- self:RemoveMoveSymbol()
        if self.onFinishCallback then
            self.onFinishCallback()
            self.onFinishCallback = nil
            -- FCasinoCtx:SetSpinStatus(FSpinStatus.SPIN)
        end
    else
        -- 先把moveSymbol层建立起来 --[拷贝一份bottomContainer 然后在上面吧dropCell补全]
        self:CreatMovePanel()
        self:ShowMoveSymbol()
        self:PlayWinAnim()
    end
end

-- 创建移动层
function Slot:CreatMovePanel()
    local allCells = self.allDropCells.allCells
    for reelIndex, cellDatas in ipairs(allCells) do
        local iconIndex = 1
        for _, data in ipairs(cellDatas) do
            iconIndex = iconIndex - 1
            local logicIndex = Utils.GetDataIndex(reelIndex,iconIndex)
            local display = {data = data}
            local cfg = SymbolConfig[data.icon]
            local render = self:GetOrCreateMoveSymbol(logicIndex,display.data)
            self:_InitSymbolRender(render,cfg,display,true) -- 一起用
            if data.icon == GameDefine.ICON_SCATTER then
                render.sortingOrder = 200
            end
            render.visible = false
        end
    end
end

function Slot:IsNeedDrop(logicIndex)
    print("IsNeedDrop",logicIndex)
    for i = 1, 3 do
        local index = logicIndex + FCasinoCtx.gameCfg.Reel.xCellNumber * i
        if self.topSymbolRenders[index]then
            local display = self:GetDisplayFromLogicIndex(logicIndex)
            local data = display.data
            if data.golden == 0 then
                return true
            end
        end
    end
    return false
end

function Slot:GetWinIcon()
    local icons = {}
    for logicIndex, _ in pairs(self.topSymbolRenders) do
        local display = self:GetDisplayFromLogicIndex(logicIndex)
        local icon = display.data.icon
    end
    
end

function Slot:PlayWinAnim() -- 延迟 2.2 秒动画
    local reelDataArray = self.reelDataArrays[self.showIndex]
    FCasinoCtx:GetGame():ShowWin(false,reelDataArray.winCoin)
    local winIcons = reelDataArray.winCells.icons
    self.mask.visible = true
    for logicIndex, render in pairs(self.topSymbolRenders) do
        local moveRender = self.moveSymbolRenders[logicIndex]
        moveRender.visible = false 
        local display = self:GetDisplayFromLogicIndex(logicIndex)
        display.render.visible = false
        render.visible = true
        print("logicIndex ",logicIndex)
        dump(display.data,"display.data")
        if display.data.golden == 1 then --
            moveRender:GetTransition("goldWin"):Play(function ()
                moveRender.visible = true
            end)
            render:GetTransition("goldWin"):Play(function ()
                render.visible = false
            end)
            if not self:IsNeedDrop(logicIndex) then
                print("dontDropGolden ",logicIndex)
                self.moveSymbolDatas[logicIndex] = {icon = GameDefine.ICON_WILD,golden = 0}
            end
        elseif display.data.icon == GameDefine.ICON_WILD then
            render:GetTransition("wildWin"):Play(function ()
                render.visible = false
            end)
        else
            render:GetTransition("whiteWin"):Play(function ()
                render.visible = false
            end)
        end
    end
    Utils.Delay(self.parent,0.7,function ()
        FToolSet.PlayFGUISound(MusicCfg.mahjong_remove)
        if #winIcons > 2 then
            FToolSet.PlayFGUISound(MusicCfg.double_remove[math.random(1,2)])
        else
            for _, icon in ipairs(winIcons) do
                FToolSet.PlayFGUISound(MusicCfg.wins[icon])
            end
        end
        self.mask.visible = false
    end)
    local doDrop = function()
        local index = self.showIndex + 1 > 4 and 4 or self.showIndex + 1
        FCasinoCtx:GetGame():PlayTopXIndexAdd(index)
        self:ShakeNode(function () -- 开始掉落
            self:DropCells(function () -- 掉落结束 开始下一轮
                self:AddShowIndex()
                self:TestCheckMoveSymbolAndBottomSymbol()
                if self.showIndex >= #self.reelDataArrays then -- 轮次结束
                    FCasinoCtx:GetGame():PlayTopXIndexReset()
                    FCasinoCtx:GetGame():ShowWin(true,self.winCoin,function ()
                        if self.isIntoFree then
                            FToolSet.PlayFGUISound(MusicCfg.vocals_mjhl)
                            FToolSet.PlayFGUISound(MusicCfg.scatter_bj)
                            Utils.Delay(self.parent,2,function ()
                                if self.onFinishCallback then
                                    self.onFinishCallback()
                                    self.onFinishCallback = nil
                                end
                            end)
                        else
                            if self.onFinishCallback then
                                self.onFinishCallback()
                                self.onFinishCallback = nil
                            end
                        end
                    end)
                    self:ResetBottomContainer(true)
                    self:OnDropEnd()
                else
                    self:ResetBottomContainer()
                    -- 准备top数据
                    self:RemoveTopSymbol()
                    self:ResetTopContainer()
                    self:PlayWinAnim()  
                end
            end)
        end)
    end
    Utils.Delay(self.parent,2.2,function ()
        doDrop()
    end)
end

function Slot:ShakeNode(callback)
    for index, render in pairs(self.moveSymbolRenders) do
        self:Shake(index,render,GameDefine.DROP_READY_SHAKE_TIME)
    end
    Utils.Delay(self.parent,GameDefine.DROP_READY_SHAKE_TIME,function ()
        if callback then
            callback()
        end
    end)
end

function Slot:Shake(index,render,time,callback)
    local sxy = render.xy
    local startPos = sxy
    if RUNTIME_IN_UNITY then
        startPos = vec3(sxy.x,sxy.y,0)
    end
    self.shakeTweenrs = self.shakeTweenrs or {}
    self.shakeTweenrs[index] = FairyGUI.GTween.Shake(startPos,0.5, time)
    :OnUpdate(function(tweener)
        render.x = math.floor(tweener.value.x) 
        render.y = math.floor(tweener.value.y) 
    end)
    :OnComplete(function()
        self.shakeTweenrs[index] = nil
        render.xy = sxy
        if callback then
            callback()
        end
    end)
    :SetTarget(render)
end

function Slot:DropCells(callback)
    -- dump(self.moveSymbolDatas,"self.moveSymbolDatas changeStart",4)
    dump(self.topSymbolRenders,"self.topSymbolRenders")
    local curDropCells = self.allDropCells[self.showIndex].curDropCells -- 当前轮次掉落的格子数据
    local reelDropToFroms = self:GetDropByCurrentDropCells(curDropCells,true)
    local winCells = self.reelDataArrays[self.showIndex].winCells
    local needRemoveCells = {}
    for logicIndex, cell in pairs(winCells) do
        if cell.golden == 0 then
            table.insert(needRemoveCells,self.moveSymbolRenders[logicIndex])
            self.moveSymbolRenders[logicIndex].visible = false
        end
    end
    -- dump(reelDropToFroms,"reelDropToFroms",5)
    -- dump(self.moveSymbolDatas,self.showIndex.." moveSymbol_changeStart",5)
    Utils.DumpGrid(self.moveSymbolDatas,self.showIndex.." moveSymbol_changeStart",5,4)
    FToolSet.PlayFGUISound(MusicCfg.mahjong_drop)
    for reelIndex, reelDropToFrom in ipairs(reelDropToFroms) do
        if #reelDropToFrom>0 then
            local dropCount = reelDropToFrom.dropCount
            local removeCount = 0
            for i, data in ipairs(reelDropToFrom) do
                local toIndex = data.toIndex
                local fromIndex = data.fromIndex
                local toLogicIndex = Utils.GetDataIndex(reelIndex,toIndex)
                local fromLogicIndex = Utils.GetDataIndex(reelIndex,fromIndex)
                if not self.moveSymbolRenders[fromLogicIndex] then
                    local display = {data = Utils.RandomSymbolData(reelIndex,true)}
                    local cfg = SymbolConfig[display.data.icon]
                    local render = self:GetOrCreateMoveSymbol(fromLogicIndex,display.data)
                    self:_InitSymbolRender(render,cfg,display,true) 
                    render.visible = true
                end
                -- print("toLogicIndex",toLogicIndex)
                -- print("fromLogicIndex",fromLogicIndex)
                local fromXY = self.moveSymbolRenders[fromLogicIndex].xy
                local toXY = self.moveSymbolRenders[toLogicIndex].xy
                local shakeRender = self.moveSymbolRenders[fromLogicIndex]
                Utils.MoveTo(self.moveSymbolRenders[fromLogicIndex],fromXY,toXY,GameDefine.DROP_TIME)
                removeCount = removeCount + 1
                self.moveSymbolRenders[fromLogicIndex].name = toLogicIndex
                self.moveSymbolRenders[toLogicIndex] = self.moveSymbolRenders[fromLogicIndex]
                if self.topSymbolRenders[fromLogicIndex] and self.moveSymbolDatas[fromLogicIndex].golden == 1 then -- 中奖变百搭
                    self.moveSymbolDatas[toLogicIndex] = {icon = GameDefine.ICON_WILD,golden = 0}
                else
                    self.moveSymbolDatas[toLogicIndex] = clone(self.moveSymbolDatas[fromLogicIndex])
                end
                if removeCount >= #reelDropToFrom - dropCount + 1 then
                    print(" delete fromLogicIndex",fromLogicIndex)
                    self.moveSymbolRenders[fromLogicIndex] = nil
                    self.moveSymbolDatas[fromLogicIndex] = nil
                end
            end
        end
    end

    Utils.Delay(self.parent,GameDefine.DROP_TIME + 0.2,function ()
        -- dump(self.moveSymbolDatas,self.showIndex.."moveSymbol_changeEnd",5)
        Utils.DumpGrid(self.moveSymbolDatas,"moveSymbol_changeEnd",5,4)
        self:RemoveMovePanelWinCell(needRemoveCells)
        if callback then
            callback()
        end
    end)
end

function Slot:OnDropEnd()
    self:RemoveTopSymbol()
    -- self:RemoveMoveSymbol()
    self:HideMoveSymbol()
    self.bottomContainer.visible = true
    for k, v in pairs(self.reels) do
        v:OnScrollBegin()
    end
end

function Slot:TestCheckMoveSymbolAndBottomSymbol()
    local bottomReelDatas = self.reelDataArrays[self.showIndex].reelDatas
    local returnIndex = false
    for i = 1, #self.reels do
        for j = 1, 4 do
            local index = Utils.GetDataIndex(i,j)
            local moveData = self.moveSymbolDatas[index]
            local bottomData = bottomReelDatas[i][j]
            if moveData.icon ~= bottomData.icon or moveData.golden ~= bottomData.golden then
                returnIndex = true
                print("___ERROR!!!!!!!",index)
                dump(moveData,"moveData")
                dump(bottomData,"bottomData")
            end
        end
    end
    assert(not returnIndex,"TestCheckMoveSymbolAndBottomSymbol ERROR")
end
-- 刷新 bottomContainer
function Slot:ResetBottomContainer(isEnd) 
    local stopZoreIndexDatas = {}
    if isEnd then
        for i = -4, 0 do
            table.insert(stopZoreIndexDatas,self.moveSymbolDatas[i])
        end
    end
    -- local reelCfg = FCasinoCtx.gameCfg.Reel
    local reelDatas = self.reelDataArrays[self.showIndex].reelDatas
    for k, v in pairs(self.reels) do
        --  todo 最后一轮的时候要填充一个随机数据显示
        v.stopZoreIndexData = stopZoreIndexDatas[k]
        v:Recovery(reelDatas[k])
    end
end

-- 刷新 topContainer
function Slot:ResetTopContainer() 
    -- local reelCfg = FCasinoCtx.gameCfg.Reel
    local winCells = self.reelDataArrays[self.showIndex].winCells 
    -- dump(winCells,"ResetTopContainerwinCells",4)
    for logicIndex, datas in pairs(winCells) do
        if type(logicIndex) == "number" then
            local cfg = SymbolConfig[datas.icon]
            local display = {data = clone(datas)}
            local render = self:GetOrCreateTopSymbol(logicIndex)
            -- print("ResetTopContainer ",logicIndex)
            self:_InitSymbolRender(render,cfg,display)
        end
    end
end

--删除中奖格子数据
function Slot:RemoveMovePanelWinCell(needRemoveCells)
    for _, cell in pairs(needRemoveCells) do
        FTween.KillTweens(cell)
        cell:RemoveFromParent(true)
    end
end

function Slot:GetDropByCurrentDropCells(curDropCells,needDelect) -- 有bug
    local reelWinIconIndexs = self.allDropCells[self.showIndex].reelWinIconIndexs
    local reelDropToFroms = {} -- {1 = {1={toIndex,fromIndex}}}
    for reelIndex = 1, FCasinoCtx.gameCfg.Reel.xCellNumber do -- 每列顺序找
        reelDropToFroms[reelIndex] = reelDropToFroms[reelIndex] or {}
        local dropCount = curDropCells[reelIndex].count
        if dropCount > 0 then -- 有掉落
            reelDropToFroms[reelIndex].dropCount = dropCount
            -- 每格都查看一下
            local hasIcon = clone(reelWinIconIndexs[reelIndex])
            for iconIndex = FCasinoCtx.gameCfg.Reel.yCellNumber, 1, -1 do -- 从下往上数
                if not reelWinIconIndexs[reelIndex][iconIndex] then -- 格子没中奖 [没中奖的格子从下往上找中奖的位置]
                    for i = FCasinoCtx.gameCfg.Reel.yCellNumber, iconIndex, -1 do
                        if hasIcon[i] then
                            if iconIndex ~= i then
                                table.insert(reelDropToFroms[reelIndex],
                                {
                                    toIndex = i,
                                    fromIndex = iconIndex,
                                })
                            end
                            hasIcon[i] = false
                            hasIcon[iconIndex] = true
                            goto Break
                        end
                    end
                end
                ::Break::
            end
            local allCells = self.allDropCells.allCells
            local totalCount = self.allDropCells.allCells[reelIndex].count
            for i = 0, -totalCount, -1 do
                table.insert(reelDropToFroms[reelIndex],
                {
                    toIndex = i + dropCount,
                    fromIndex = i
                })
            end
            -- 掉落之后 ，待掉落数量要刷新
            if needDelect then
                self.allDropCells.allCells[reelIndex].count = self.allDropCells.allCells[reelIndex].count - dropCount
            end
        end
    end
    return reelDropToFroms
end

function Slot:GetDisplayFromLogicIndex(logicIndex)
    local logicX = Utils.GetReelIndex(logicIndex) + 1
    local logicY = Utils.GetCellIndex(logicIndex) + 1
    local arraySymbolDisplays = self.reels[logicX].arraySymbolDisplays
    return arraySymbolDisplays[logicY]
end

-----------------------------------
function Slot:GetDatas(arrays)
    self.reelDataArrays = {}
    -- dump(arrays,"arrays",10)
    for k, result in ipairs(arrays) do
        local winCoin,winCells = self:HandleWinDatas(result.lines)
        local reelDatas,scReelIndexs,needSpeedIndex = self:HandleCellDatas(result.grids)
        local data = {
                        reelDatas = clone(reelDatas), -- 格子数据
                        winCells = clone(winCells),  -- topSymbol格子（中奖格子）
                        doubled = result.doubled, -- 翻倍数。
                        winCoin = winCoin, -- 赢分
                        scReelIndexs = clone(scReelIndexs), -- 免费格子数
                        needSpeedIndex = needSpeedIndex -- 需要加速的后续转轴 false表示不需要
                    }
        table.insert(self.reelDataArrays,data)
        print("\n------------------------------------------------\n")
        Utils.DumpGrid(result.grids,"第"..k.."轮",5,4,{"index"})
        -- dump(winCells,"winCells",4)
        print("\n------------------------------------------------\n")
    end
end

-- 处理格子信息
function Slot:HandleCellDatas(grids)
    -- 整理服务器数据
    local reelDatas = {}
    local scReelIndexs = {false,false,false,false,false,scIndexs = {}}
    local needSpeedIndex
    for k, v in ipairs(grids) do
        local reelIndex = Utils.GetReelIndex(k) + 1
        local iconIndex = Utils.GetCellIndex(k) + 1
        reelDatas[reelIndex] = reelDatas[reelIndex] or {}
        reelDatas[reelIndex][iconIndex] = {
            icon = v.icon,
            golden = v.golden
        }
        if GameDefine.ICON_SCATTER == v.icon then
            scReelIndexs[reelIndex] = true
        end
    end
    local count = 0
    for reelIndex, v in ipairs(scReelIndexs) do
        if v then
            count = count + 1
        end
        if count == 2 and reelIndex < 5 then
            needSpeedIndex = reelIndex
            break
        end
    end
    return reelDatas,scReelIndexs,needSpeedIndex
end

-----处理中奖线 --------
function Slot:HandleWinDatas(lines)
    if not next(lines) then
        return 0,{}
    end
    local winCells = {} 
    winCells.icons = {}
    local winCoin = 0
    for i, line in ipairs(lines) do
        if GameDefine.FREE_WON_FREE ~= line.lineIndex then
            winCoin = winCoin + line.winCoin
            table.insert(winCells.icons,line.icon)
            for _, cell in ipairs(line.lineCells) do
                local iconIndex = cell.index + 1
                winCells[iconIndex] = {icon = cell.icon,golden = cell.golden}
            end   
        end
    end
    return winCoin,winCells
end

-------------------------------
-- spin结束格子第0行的数据
function Slot:GetZoreDropCellData()
    local zoreReelIndexDatas = {}
    local len = #self.reelDataArrays
    --todo 返回一个随机的格子（或者reel自己处理）
    for i = 1, FCasinoCtx.gameCfg.Reel.xCellNumber do
        local data = Utils.RandomSymbolData(i,true)
        zoreReelIndexDatas[i] = data
    end
    if len == 1 then 
        return zoreReelIndexDatas
    end
    local allCells = self.allDropCells.allCells
    for i = 1, FCasinoCtx.gameCfg.Reel.xCellNumber do
        if allCells[i][1] then
            local data = allCells[i][1]
            zoreReelIndexDatas[i] = data
        else
            self.allDropCells.allCells[i][1] = zoreReelIndexDatas[i]
        end
    end
    return zoreReelIndexDatas
end

--获取所有的下落格子数据
function Slot:GetAllDropCells()
    local len = #self.reelDataArrays
    if len == 1 then 
        return 
    end
    -- local reelIndexCounts = {0,0,0,0,0}

    -- [[#allDropCells = len -1 {all = all,[1]={curDropCells =dropCells,reelIndexCounts = reelIndexCounts}}
    local allDropCells = {} 
    --]]

    for i = 1, len - 1 do
        -- 本轮中奖列 格子数
        local winCells = self.reelDataArrays[i].winCells
        -- 设计是不能包含金牌的
        local reelIndexCounts,reelWinIconIndexs = self:GetReelIndexCountFromWinCell(winCells)
        -- 次轮 格子信息
        local nextReelDatas  = self.reelDataArrays[i + 1].reelDatas
        local dropCells = self:GetDropCellDatasFromNextReelDatasByCurrentWinCounts(reelIndexCounts,nextReelDatas)
        table.insert(allDropCells, {curDropCells = dropCells, reelIndexCounts = reelIndexCounts, reelWinIconIndexs = reelWinIconIndexs})

    end
    local allCells = {} -- {1,2,3,4,5}
    for _, data in ipairs(allDropCells) do -- 轮次
        local curDropCells = data.curDropCells -- 单轮数据 {1 = {data, count},2,3,4,5}
        for index, dropCells in ipairs(curDropCells) do
            allCells[index] = allCells[index] or {}
            if dropCells.count ~= #dropCells then
                print("index",index)
                dump(dropCells,"dropCells")
            end
            for i = dropCells.count, 1, -1 do
                local cellData = {golden = dropCells[i].golden, icon = dropCells[i].icon} 
                table.insert(allCells[index],cellData)
            end
            allCells[index].count = #allCells[index]
        end
    end

    allDropCells.allCells = allCells
    self.allDropCells = allDropCells
    -- dump(self.allDropCells,"self.allDropCells",10)
end

-- 本轮中奖 每列转轴中奖的格子个数
function Slot:GetReelIndexCountFromWinCell(winCells)
    local reelIndexCounts = {0,0,0,0,0}
    local reelWinIconIndexs = {} -- {1 = {3 = true,4 = nil }}
    for logicIndex, data in pairs(winCells) do
        if data.golden == 0 then -- 金色中奖格子不会消失 而是变成百搭
            local reelIndex = Utils.GetReelIndex(logicIndex) + 1
            local iconIndex = Utils.GetCellIndex(logicIndex) + 1
            reelIndexCounts[reelIndex] = reelIndexCounts[reelIndex] + 1
            reelWinIconIndexs[reelIndex] = reelWinIconIndexs[reelIndex] or {}
            reelWinIconIndexs[reelIndex][iconIndex] = true
        end
    end
    return reelIndexCounts,reelWinIconIndexs
end

-- 根据每列本轮中奖数量，从次轮的每轮格子数据 取同等数量的数据
function Slot:GetDropCellDatasFromNextReelDatasByCurrentWinCounts(reelIndexCounts,nextReelDatas)
    local dropCells = {} -- {1 = {data, count},2,3,4,5}
    for reelIndex, count in ipairs(reelIndexCounts) do
        dropCells[reelIndex] = {} 
        for j = 1, count do
            local data = nextReelDatas[reelIndex][j]
            if data.icon ~= GameDefine.ICON_WILD then -- 百搭不会掉落，去掉
                table.insert(dropCells[reelIndex],data)
            end
        end
        dropCells[reelIndex].count = #dropCells[reelIndex]
    end
    return dropCells
end

function Slot:AddShowIndex()
    self.showIndex = self.showIndex + 1
end

-- 当前赢分
function Slot:GetTotalWin()
    if self.isFree then
        return self.totalWinCoin
    else
        return self.winCoin
    end
    return nil
end

function Slot:PlayReelAudio()
    self.reelStart = FToolSet.PlayFGUISound(MusicCfg.reel_start,true)
end

function Slot:StopReelAudio(playStopAudio)
    if self.reelStart then
        APIGateway.StopSound(self.reelStart)
        self.reelStart = nil
    end
    -- if playStopAudio then
    --     FToolSet.PlayFGUISound(MusicCfg.reel_stop)
    -- end
end

function Slot:PlayReelSpeedAudio()
    self.longtime = FToolSet.PlayFGUISound(MusicCfg.longtime,true)
    FToolSet.PlayFGUISound(MusicCfg.longtime_start)
end

function Slot:StopReelSpeedAudio(playStopAudio)
    if self.longtime then
        APIGateway.StopSound(self.longtime)
        self.longtime = nil
    else
        return
    end
    if playStopAudio then
        FToolSet.PlayFGUISound(MusicCfg.longtime_end)
    end
end

function Slot:OnClick(index,icon)
    if self.detailsIndex and self.detailsIndex == index then
        self:HideDetails()
        return
    end
    local details = self:GetOrCreateDetails(index)
    self.detailsIndex = index
    local x = Utils.GetReelIndex(index)
    local isRight = x >= 3

    local icon1 = details:GetChild("icon1")
    local icon2 = details:GetChild("icon2")
    local Args1 = details:GetChild("1Args")
    local Args2 = details:GetChild("2Args")
    local desc = SymbolConfig[icon].desc

    icon1.visible = not isRight
    icon2.visible = isRight
    Args1.visible = not isRight
    Args2.visible = isRight
    if isRight then
        details:SetPivot(0.75, 0.5, true)
        self:InitIcon(icon2.component,SymbolConfig[icon])
        if icon == GameDefine.ICON_WILD or icon == GameDefine.ICON_SCATTER then
            local text = Args2:GetChild("text")
            text.text = desc
            text.visible = true
            for i = 1, 3 do
                local win = Args2:GetChild("win"..i)
                local node = Args2:GetChild(i)
                win.visible = false
                node.visible = false
            end
        else
            local text = Args2:GetChild("text")
            text.visible = false
            for i = 1, 3 do
                local win = Args2:GetChild("win"..i)
                local node = Args2:GetChild(i)
                win.text = desc[i]
                win.visible = true
                node.visible = true
            end
        end
    else
        details:SetPivot(0.25, 0.5, true)
        self:InitIcon(icon1.component,SymbolConfig[icon])
        if icon == GameDefine.ICON_WILD or icon == GameDefine.ICON_SCATTER then
            local text = Args1:GetChild("text")
            text.text = desc
            text.visible = true
            for i = 1, 3 do
                local win = Args1:GetChild("win"..i)
                local node = Args1:GetChild(i)
                win.visible = false
                node.visible = false
            end
        else
            local text = Args1:GetChild("text")
            text.visible = false
            for i = 1, 3 do
                local win = Args1:GetChild("win"..i)
                local node = Args1:GetChild(i)
                win.text = desc[i]
                win.visible = true
                node.visible = true
            end
        end
    end
end

function Slot:InitIcon(render,cfg)
    local whiteBG = render:GetChild("whiteBG")
    local goldBG = render:GetChild("goldBG")
    local isGolden = false
    goldBG.visible = isGolden
    whiteBG.visible = not isGolden
    local icon = render:GetChild("icon")
    local swEffect = render:GetChild("swEffect")
   
    for _, nodeName in pairs(SymbolConfig.nodes) do
        local node = render:GetChild(nodeName)
        node.visible = false
    end
    
    if cfg.icon then
        icon.url = cfg.icon
        icon.visible = true
        swEffect.visible = false
    elseif cfg.node then
        goldBG.visible = false
        whiteBG.visible = false
        local node = render:GetChild(cfg.node)
        node.visible = true
        swEffect.visible = true
        icon.visible = false
    end
end

function Slot:HideDetails()
    if self.details then
        self.details.visible = false
        self.detailsIndex = nil
    end
end

function Slot:SetReelCilckEnabled(enabled)
    for k, v in pairs(self.reels) do
        v:SetEnabled(enabled)
    end
end

return Slot