-- 老虎机普通/免费游戏，三个格子一组转动
local Utils = Import(".Utils")
local Reel = Import(".Reel")
local SymbolConfig = Import(".SymbolConfig")
local BaseSlot = Import(".BaseSlot")
local GameDefine = Import("..GameDefine")
local NormalSlot = Class("NormalSlot", BaseSlot)


NormalSlot.curMatchSequenceNum = 0
NormalSlot.downMoveUnitDistance = 120
NormalSlot.reelCount = 6
function NormalSlot:ctor(parent, isFree)
    self.render = parent
    self.isFree = isFree

    -- self.effectLayer = self.render.parent:GetChild("effectLayer")
    self.reels = {
        Reel.New(parent:GetChild("reel1")),
        Reel.New(parent:GetChild("reel2")),
        Reel.New(parent:GetChild("reel3")),
        Reel.New(parent:GetChild("reel4")),
        Reel.New(parent:GetChild("reel5")),
        Reel.New(parent:GetChild("reel6"))
    }
    local reelCount = NormalSlot.reelCount

    for i = 1, reelCount do
        local reel = self.reels[i]
        local reelRenders = reel.renders
        for symbolIdx,symbolRender in pairs(reelRenders) do
            reel:UpdateSymbol(symbolRender, GameDefine.InitSymbolData[i][symbolIdx],symbolIdx)
        end
    end
end

function NormalSlot:__delete()
    self:Reset()
end

function NormalSlot:Reset()
    self.curSpinTotalWinCoinExcludeSCLine = 0
    self.toBeClearedPatterns = {}
    -- 停止金币滚动
    self.onFinishCallback = nil
    FCasinoCtx.commonPanel:StopScrollWinMoney(nil, true)
end

-- @brief 滚动开始
function NormalSlot:SpinStart(delayTime)
    FCasinoCtx:GetGame().tipComp:GetChild("label-multiply").text = "0"
    self.curMatchSequenceNum = 0
    -- spin按钮置为等待状态
    FCasinoCtx:SetSpinStatus(FSpinStatus.WAITING)
    if FCasinoCtx.curGameMode ~= FGameMode.FREE then
        FCasinoCtx.commonPanel:SetWinMoney(0)
    end
    self:Reset()
end


function NormalSlot:DispatchFinishCallback(isReconnect)
    print("NormalSlot:DispatchFinishCallback >>> ")
    if self.onFinishCallback then
        if self.curSpinTotalWinCoinExcludeSCLine ~= nil and self.curSpinTotalWinCoinExcludeSCLine ~= 0 and not isReconnect then
            local multiCount = math.floor(self.curSpinTotalWinCoinExcludeSCLine / FCasinoCtx.commonPanel:GetBetMoney())
            FCasinoCtx:GetGame():ShowTotalWin(self.curSpinTotalWinCoinExcludeSCLine, multiCount)
        end
        print("NormalSlot:DispatchFinishCallback >>> self.onFinishCallback >>> ")
        self.onFinishCallback()
        self.onFinishCallback = nil
    end
end

function NormalSlot:ShowIntoFreeSCAnimation()
    for k, reel in pairs(self.reels) do
        for _, symbolRender in ipairs(reel.renders) do
            if symbolRender["isSC"] == true then
                symbolRender:GetTransition("sc-ani-win"):Play()
            end
        end
    end
end

function NormalSlot:ShowJPMultiCountAnimation(callback)
    local tipComp = FCasinoCtx:GetGame().tipComp
    local tipInfo = FCasinoCtx:GetGame().tipInfo

    local oldMultiplierCount = FCasinoCtx:GetGame().totalMultiplierCount

    local multiCountRenders = {}
    for k, reel in pairs(self.reels) do
        for _, symbolRender in ipairs(reel.renders) do
            if symbolRender["jpType"] ~= -1 then
                table.insert(multiCountRenders, symbolRender)
                FCasinoCtx:GetGame().totalMultiplierCount = FCasinoCtx:GetGame().totalMultiplierCount + symbolRender["value"]
            end
        end
    end


    local multiCountRenderCount = #multiCountRenders

    if multiCountRenderCount == 0 then
        if callback then
            callback(0)
        end
        return
    end

    local moveDuration = 1
    local movedCount = 0
    
    tipComp:GetChild("label-multiply").visible = true
    tipComp:GetChild("label-x").visible = true
    tipComp:GetController("c1").selectedPage = "score-in-multiply"
    
    local hasPlayedTotalMultiCountAnimation = false
    function showMultiCountAnimation()
        local multiValue
        local multiLabel = FCasinoCtx:GetGame().totalMultiplierLabel
        local delayTime = 0
        if FCasinoCtx.curGameMode == FGameMode.FREE and multiLabel.text ~= "" and multiLabel.text ~= "0" and not hasPlayedTotalMultiCountAnimation then
            multiCountRenderCount = multiCountRenderCount + 1
            hasPlayedTotalMultiCountAnimation = true 
            -- multiValue = tonumber(multiLabel.text)
            -- multiValue = FCasinoCtx:GetGame().totalMultiplierCount
            multiValue = oldMultiplierCount
        else
            delayTime = 1.5
            local symbolRender = table.remove(multiCountRenders, 1) 
            Utils.PlaySound("ui://Game481/multiple_win")
            symbolRender:GetTransition("jp-ani-award-"..symbolRender["jpType"]):Play()
            multiLabel = symbolRender:GetChild("multiCount")
            multiValue = symbolRender["value"]
        end
        local fromTargetPosObj = multiLabel

        local multiCountCompToMove = FairyGUI.UIPackage.CreateObject("Game481", "multiCountComp")
        multiCountCompToMove.visible = false
        FCasinoCtx.commonPanel:GetEffectLayer():AddChild(multiCountCompToMove)

        local fromPos = fromTargetPosObj:LocalToRoot(vec2(0,0))
        multiCountCompToMove.x = fromPos.x
        multiCountCompToMove.y = fromPos.y

        local tipCompMultiLabel = tipComp:GetChild("label-multiply") 
        local tipCompMultiLabelForPos = tipComp:GetChild("label-multiply-for-pos") 
        local toPos = tipCompMultiLabelForPos:LocalToRoot(vec2(0,0))
        multiCountCompToMove:GetChild("multiCount").text = multiLabel.text

        Utils.SetTimeout(function()
            multiCountCompToMove.visible = true
            if FCasinoCtx:GetGame().totalMultiplierLabel ~= fromTargetPosObj then fromTargetPosObj.visible = false end
            FTween.Start(multiCountCompToMove,
                FTween.To(FairyGUI.TweenPropType.Scale,vec2(1, 1), vec2(1.26, 1.26), 0.2),
                FTween.To(FairyGUI.TweenPropType.Position, fromPos, toPos, moveDuration),
                FTween.CallFunc(function()
                    FCasinoCtx.commonPanel:GetEffectLayer():RemoveChild(multiCountCompToMove)
    
                    tipCompMultiLabel.text = tostring(tonumber(tipCompMultiLabel.text) + multiValue)
                    -- FCasinoCtx:GetGame().totalMultiplierCount = FCasinoCtx:GetGame().totalMultiplierCount + multiValue
                    movedCount = movedCount + 1
                    if movedCount >= multiCountRenderCount then
    
                        if FCasinoCtx.curGameMode == FGameMode.FREE then
                            FCasinoCtx:GetGame():UpdateMultiCountLabel(FCasinoCtx:GetGame().totalMultiplierCount)
                        end
                        
                        Utils.SetTimeout(function()
                            tipComp:GetTransition("merge-score-multiply"):Play(function()
    
                                -- local addScoreMulti = FCasinoCtx:GetGame().totalMultiplierCount - 1
                                -- local addScore = self.curSpinTotalWinCoinExcludeSCLine * addScoreMulti
                                local addScore = self.curSpinTotalWinCoinExcludeSCLine / FCasinoCtx:GetGame().totalMultiplierCount * (FCasinoCtx:GetGame().totalMultiplierCount - 1)
    
                                tipInfo:SetTipScoreView(tonumber(tipComp:GetChild("label-score").text) * FCasinoCtx:GetGame().totalMultiplierCount)
                                tipComp:GetController("c1").selectedPage = "score"
                                tipComp:GetTransition("merge-score-end"):Play(
                                    function()
                                        if callback then
                                            callback(addScore)
                                        end
                                    end
                                )
                            end)
                        end, 1, self.render)
                    else 
                        showMultiCountAnimation()
                    end
                end),
                FTween.RemoveSelf()
            )
        end, delayTime, self.render)
        
    end

    showMultiCountAnimation()
end

function NormalSlot:CheckCurSpinFirstResSCPossibleReelIdxs(reelDatas)
    local idxs = {}
    local scHasShownCount = 0
    for reelIdx, reelData in pairs(reelDatas) do
        for _, itemData in pairs(reelData) do
            if itemData.icon == GameDefine.ICON_SCATTER then
                if NormalSlot.reelCount - reelIdx + scHasShownCount >= 3 then
                    table.insert(idxs,reelIdx)
                end
                scHasShownCount = scHasShownCount + 1
                break
            end
        end
    end
    return idxs
end


function NormalSlot:SetReelSymbolData(spinData, isReconnect, callback, shouldnotSetAwardHistory)

    self:Reset()

    self.gridsArr = {}
    self.linesArr = {}

    self.onFinishCallback = callback
    self.isInFree = FCasinoCtx.curGameMode == FGameMode.FREE

    self.curSpinTotalWinCoinExcludeSCLine = spinData.winCoin
    self.curSpinSCLineCoin = 0

    if #spinData.results.array == 0 then
        self:DispatchFinishCallback(true)
        print("!!!!!!!!!!!!!!!!!!!!!!!!!!! spinData.results.array == 0")
        return
    end

    for k, result in ipairs(spinData.results.array) do

        local grids = {}
        for k, v in pairs(result.grids) do
            table.insert(grids, v)
        end
        table.insert(self.gridsArr, grids)
        
        local lines = {}
        -- dump(result.lines,"lines",6)
        for k, line in pairs(result.lines or {}) do
            table.insert(lines, line)
            if line.lineIndex == GameDefine.ICON_SCATTER then
                self.curSpinSCLineCoin = self.curSpinSCLineCoin + line.winCoin
            end
        end
        self.curSpinTotalWinCoinExcludeSCLine = self.curSpinTotalWinCoinExcludeSCLine - self.curSpinSCLineCoin
        if #lines ~= 0 then
            -- 倍数
            -- print("NormalSlot:SetReelSymbolData>>>  index  "..k.." result.doubled>>>"..result.doubled)
            table.insert(self.linesArr, lines)
        end

    end
    
    local reelDatasArr = self:HandleDataReelSymbolsData(self.gridsArr)
    if #self.linesArr ~= 0 then
        -- local eachResWinCoin = self:GetEachResWinCoin(self.linesArr)
        self:HandleDataLinesData(self.linesArr, shouldnotSetAwardHistory)
        self:GetSymbolInLines(self.linesArr, reelDatasArr)
    end

    -- 重连恢复数据并显示
    if isReconnect then

        local lastReelData = reelDatasArr[#reelDatasArr]
        for k, v in pairs(self.reels) do
            v:Recovery(lastReelData[k])
        end

        if self.isInFree and self.isFree then
            -- show effect sc node when recovery free mode
            for i = 1, 6 do
                self:OnReelScrollStop(i, true)
            end
        end

        self:OnSpinOver(spinData, isReconnect)

    else

        local reelDatas = self:GetNextReelDataGroup()

        self:CheckAndShowZesusAnimInCurSpinRes(reelDatas)
        local audioSCReelIdxs = self:CheckCurSpinFirstResSCPossibleReelIdxs(reelDatas)
        if reelDatas == nil then return end

        local isQuickMode = self.reels[1]:IsQuickMode()
        function beginShowResult()
            for k, reel in pairs(self.reels) do
                local delayTime = isQuickMode and 0 or (k-1) * 0.1
                Utils.SetTimeout(function()
                    reel:ShowSymbols(k)
                end, delayTime, self.render)
            end
        end

        local countHasBeenHidden = 0
        local countHasBeenShown = 0
        for k, reel in pairs(self.reels) do
            local reelData = reelDatas[k]

            reel:SetShowResultData(
                reelData,
                audioSCReelIdxs,
                function()
                    countHasBeenHidden = countHasBeenHidden + 1
                    if countHasBeenHidden >= NormalSlot.reelCount then
                        beginShowResult()
                    end
                end,
                function()
                    countHasBeenShown = countHasBeenShown + 1
                    self:OnReelScrollStop(k, isReconnect)

                    if countHasBeenShown >= NormalSlot.reelCount then

                        self:OnSpinOver(spinData, isReconnect)

                    end
                end
            )
            local delayTime = isQuickMode and 0 or (k-1) * 0.1
            Utils.SetTimeout(function()
                reel:HideSymbols()
            end, delayTime, self.render)
        end

    end

end


function NormalSlot:ResetReelDataGroup()

    self.reelDatasArr = {}
    self.reelDatasArr["curShownIdx"] = nil

    return self.reelDatasArr

end


-- 获取下一组图案数据
function NormalSlot:GetNextReelDataGroup()

    local reelDatasArr = self.reelDatasArr
    if reelDatasArr["curShownIdx"] == nil then
        reelDatasArr["curShownIdx"] = 1
    else
        reelDatasArr["curShownIdx"] = reelDatasArr["curShownIdx"] + 1
    end

    local curIdx = reelDatasArr["curShownIdx"]
    return self.reelDatasArr[curIdx]

end


-- 整理服务器数据
function NormalSlot:HandleDataReelSymbolsData(gridsArr)

    self.reelDatasArr = self:ResetReelDataGroup() -- 多组图案数据

    for kgridsArr, grids in ipairs(gridsArr) do

        local reelDatas = {}

        -- dump(grids,"grids>>>>>>>>>>>>>>>>>>>>    ")
        for kgrids, cell in pairs(grids) do

            local icon = cell.icon or 0
            local index = cell.index or 0
            local value = cell.value or 0
            
            local reelIndex = Utils.GetReelIndex(index) + 1
            local rowIndex = Utils.GetCellIndex(index) + 1
            
            reelDatas[reelIndex] = reelDatas[reelIndex] or {}
            reelDatas[reelIndex][rowIndex] = {icon = icon, value = value}

        end

        table.insert(self.reelDatasArr, reelDatas)

    end

    return self.reelDatasArr

end


function NormalSlot:HandleDataLinesData(linesArr, shouldnotSetAwardHistory)

    local eachResWinCoins, eachResWinCoinsByIcon = self:GetEachResWinCoin(linesArr)

    self.toBeClearedPatterns = {}
    
    local lineIdx = 1
    local awardsHistoryData = {}
    for _, lines in ipairs(linesArr) do
        local wildHasCollected = {}
        local pattern = {}
        local lineSymbolWinDataTable = {}
        for _, line in ipairs(lines) do
            if line.lineIndex ~= GameDefine.ICON_SCATTER or ( line.lineIndex == GameDefine.ICON_SCATTER and line.winCoin ~= 0 )then -- exclude free sc line
                local count = 0
                for _, cell in ipairs(line.lineCells) do
                    count = count + 1
                    table.insert(pattern, {icon = cell.icon, index = cell.index})
                end
                lineSymbolWinDataTable[line.lineIndex] = {winCoin = line.winCoin, count = count}
            end
        end
        if #pattern ~= 0 then
            local patternExcludeSC = {}
            for _, v in ipairs(pattern) do
                if v.icon ~= GameDefine.ICON_SCATTER then
                    table.insert(patternExcludeSC, v)
                end
            end
            if #patternExcludeSC ~= 0 then 
                table.insert(self.toBeClearedPatterns, patternExcludeSC)
            end

            --中奖记录
            awardsHistoryData[lineIdx] = {}
            for icon, winData in pairs(lineSymbolWinDataTable) do
                if icon ~= GameDefine.ICON_SCATTER then -- 排除免费小游戏中的sc线
                    table.insert(awardsHistoryData[lineIdx], {
                        icon = icon,
                        iconUrl = SymbolConfig[icon].icon,
                        count = winData.count,
                        score = Utils.ConvertScoreToRealVisual(winData.winCoin),
                    })
                end
            end

            lineIdx = lineIdx + 1
        end
    end

    if not shouldnotSetAwardHistory then FCasinoCtx:GetGame():SetCurAwardsData(awardsHistoryData) end

end


function NormalSlot:GetEachResWinCoin(linesArr)
    
    self.eachResWinCoins = {}
    self.eachResWinCoinsByIcon = {}

    for _, lines in ipairs(linesArr) do

        local resWinCoins = 0 
        local resWinCoinsByIcon = {}
        for _, line in ipairs(lines) do
            local winIcon = line.lineIndex
            local winScore = line.winCoin
            resWinCoins = resWinCoins + winScore
            resWinCoinsByIcon[winIcon] = winScore
        end
        table.insert(self.eachResWinCoinsByIcon,resWinCoinsByIcon)
        table.insert(self.eachResWinCoins, resWinCoins)

    end

    return self.eachResWinCoins, self.eachResWinCoinsByIcon

end


function NormalSlot:GetSymbolInLines(linesArr, reelDatasArr)

    -- 中奖的图案下标
    self.linesIndexSetArr = {}
    for _, lines in ipairs(linesArr) do
        local linesIndexSet = {}
        for _, line in ipairs(lines) do
            for _, cell in ipairs(line.lineCells) do
                linesIndexSet[cell.index + 1] = true
            end
        end
        table.insert(self.linesIndexSetArr, linesIndexSet)
    end

end


function NormalSlot:ShowAllGrids()
    for k, reel in pairs(self.reels) do
        for _, v in ipairs(self.reels[k].renders) do
            v.visible = true
        end
    end

end

function NormalSlot:OnReelScrollStop(index, isReconnect)


    local reel = self.reels[index]
    local reelSymbolDisplays = reel.renders
    local reelSymbolDatas = reel.arraySymbolDatas

end


-- 所有转轴转动完毕
function NormalSlot:OnSpinOver(spinData, isReconnect)
    print("NormalSlot:OnSpinOver >>> ")
    self.matchIdx = 1
    local isIntoFree = spinData.intoFree == 1

    local shouldDoMatch = self.toBeClearedPatterns ~= nil and next(self.toBeClearedPatterns)
    -- print("shouldDoMatch>>>>>>>>>>>>>>   ", tostring(shouldDoMatch))

    if isReconnect then
        self:DispatchFinishCallback(true)
    else
        if shouldDoMatch then
            if isReconnect == nil or isReconnect == false then
                self:DoMatch()
            end
        else
            self:DispatchFinishCallback()
        end

        for _, reel in pairs(self.reels) do
            reel:PlayJPThunderAnims()
        end
    end

    if FCasinoCtx:GetGame().HasJpInCurSpinFirstGrids then
        Utils.SetTimeout(function()
            FCasinoCtx:GetGame():PlayZeusMultiNotifyEndAnim()
        end, .5, self.render)
    end

end


function NormalSlot:DoMatch()

    print("NormalSlot:DoMatch >>>>>>>>>>")

    self.curMatchSequenceNum = self.curMatchSequenceNum + 1
    local sequenceNum = self.curMatchSequenceNum
    -- 消除匹配图案(中奖线图案)
    local shouldDoMatch = self.toBeClearedPatterns ~= nil and next(self.toBeClearedPatterns)

    -- 消除完毕
    if not shouldDoMatch then
        -- 查找jp,播放jp倍数动画
        self:ShowJPMultiCountAnimation(function(addScore)
            print("ShowJPMultiCountAnimation >>> callback")
            -- 收分
            if addScore > 0 then
                local scrollScore
                if FCasinoCtx.curGameMode == FGameMode.FREE then
                    FCasinoCtx:GetGame().curAccumulatedWinInFree = FCasinoCtx:GetGame().curAccumulatedWinInFree + addScore
                    scrollScore = FCasinoCtx:GetGame().curAccumulatedWinInFree
                else
                    FCasinoCtx:GetGame().curSpinAccumulatedWin = FCasinoCtx:GetGame().curSpinAccumulatedWin + addScore
                    scrollScore = FCasinoCtx:GetGame().curSpinAccumulatedWin
                end
                Utils.ScrollBottomWinMoneyTo(scrollScore, 0.2, function()
                    self:DispatchFinishCallback()
                    if FCasinoCtx.curGameMode == FGameMode.FREE then
                        FCasinoCtx:GetGame().curAccumulatedWinInFree = FCasinoCtx:GetGame().curAccumulatedWinInFree + self.curSpinSCLineCoin
                    end
                end)
            else
                -- may trigger intoFree
                if FCasinoCtx.curGameMode == FGameMode.FREE then
                    FCasinoCtx:GetGame().curAccumulatedWinInFree = FCasinoCtx:GetGame().curAccumulatedWinInFree + self.curSpinSCLineCoin
                end
                self:DispatchFinishCallback()
            end
        end)
    else
        
        local curResWinScore = self.eachResWinCoins[sequenceNum]
        FCasinoCtx:GetGame().curSpinAccumulatedWin = FCasinoCtx:GetGame().curSpinAccumulatedWin + curResWinScore
        local curBottomWinCoin = FCasinoCtx:GetGame().curSpinAccumulatedWin
        if FCasinoCtx.curGameMode == FGameMode.FREE then
            FCasinoCtx:GetGame().curAccumulatedWinInFree = FCasinoCtx:GetGame().curAccumulatedWinInFree + curResWinScore
            curBottomWinCoin = FCasinoCtx:GetGame().curAccumulatedWinInFree
        end

        local scoreRate = math.floor(curResWinScore / FCasinoCtx.commonPanel:GetBetMoney())
        local winAudioName
        local winAudioEndName
        local audioData = Utils:GetAudioData(curResWinScore)
        -- local winAudioDuration = audioData.time and audioData.time or 0.2
        local winAudioDuration = 0.2

        if scoreRate >= 5 then
            winAudioName = "win_5"
            winAudioEndName = "win_5_end"
            winAudioDuration = 3
        end

        if winAudioName then 
            self.scoreSoundHandler = Utils.PlaySound("ui://Game481/"..winAudioName)
        end
        Utils.ScrollBottomWinMoneyTo(curBottomWinCoin, winAudioDuration,function()
            if winAudioEndName then 
                Utils.PlaySound("ui://Game481/"..winAudioEndName)
            end
            Utils.StopSound(self.scoreSoundHandler)
        end)
        FCasinoCtx:GetGame().tipInfo:SwitchController(false)
        self:MatchLines(function()
            print("NormalSlot:DoMatch >>> MatchLines >>> callback")
            self:DropAndRefill(sequenceNum)
        end)

    end

end


function NormalSlot:DropAndRefill(sequenceNum)
    print("NormalSlot:DropAndRefill >>> ")
    local nextReelDatas = self:GetNextReelDataGroup()

    if nextReelDatas == nil then
        print("NormalSlot:DropAndRefill >>> nextReelDatas is nil")
        self:RefillGrids(nextReelDatas)
    else
        print("NormalSlot:DropAndRefill >>> nextReelDatas is not nil")
        self:DropDownSymbols(sequenceNum, function()
            self:RefillGrids(nextReelDatas)
        end)
    end

end


function NormalSlot:CheckAndShowZesusAnimInCurSpinRes(reelDatas)
    -- 检查当前结果数据是否存在jp类型
    FCasinoCtx:GetGame().HasJpInCurSpinFirstGrids = false
    for k, reelData in pairs(reelDatas) do
        for _, symbolData in ipairs(reelData) do
            if symbolData.icon == GameDefine.ICON_JP then
                FCasinoCtx:GetGame().HasJpInCurSpinFirstGrids = true
                break
            end
        end
    end

    if FCasinoCtx:GetGame().HasJpInCurSpinFirstGrids then
        FCasinoCtx:GetGame():PlayZeusMultiNotifyAnim()
    end
end


function NormalSlot:DropDownSymbols(sequenceNum, callback)

    if self.linesIndexSetArr == nil then return end

    local emptyIndexData = self.linesIndexSetArr[sequenceNum]

    local shouldDropCount = 0
    local hadDropCount = 0

    local reelsLen = NormalSlot.reelCount
    local reelRenderCount = Reel.renderCount

    for columnIndex = 1, reelsLen do
        local reelSymbolDisplays = self.reels[columnIndex].renders

        local shouldDropSymbolsTable = {}
        for rowIndex = 1, reelRenderCount do
            local index = (rowIndex - 1) * reelsLen + columnIndex
            
            if emptyIndexData[index] == nil then -- 当前格子图案不为空,可能需要下落

                local emptyGridsBelowCount = 0

                for belowRowIndex = rowIndex, reelRenderCount do
                    local belowIndex = (belowRowIndex - 1) * reelsLen + columnIndex
                    if emptyIndexData[belowIndex] == true then
                        emptyGridsBelowCount = emptyGridsBelowCount + 1
                    end
                end

                local shouldDrop = emptyGridsBelowCount ~= 0
                if shouldDrop then
                    shouldDropCount = shouldDropCount + 1
                    table.insert(shouldDropSymbolsTable,{rowIndex=rowIndex,emptyGridsBelowCount=emptyGridsBelowCount})
                end
            end
        end


        if #shouldDropSymbolsTable ~= 0 then
            for i, data in pairs(shouldDropSymbolsTable) do

                local posFromY
                local posToY
                local aniDuration
                local moveDistance

                local rowIndex = data.rowIndex
                local curDisplay = reelSymbolDisplays[rowIndex]
                local emptyGridsBelowCount = data.emptyGridsBelowCount

                posFromY = curDisplay.y
    
                moveDistance = emptyGridsBelowCount * self.downMoveUnitDistance
    
                posToY = curDisplay.y + moveDistance
                aniDuration = moveDistance / Reel.DropDownSpeed
    
                Reel.TweenChildDown(curDisplay,0, posFromY, posToY, aniDuration, function()
                    hadDropCount = hadDropCount + 1
    
                    if hadDropCount == shouldDropCount then
                        if columnIndex then Utils.PlaySound("ui://Game481/elasticity_"..columnIndex) end
                        callback()
                    end
                end)

            end
        end

    end

    if shouldDropCount == 0 then callback() end

end


function NormalSlot:RefillGrids(reelDatas)
    print("NormalSlot:RefillGrids >>> ")
    function doAfterDropDown()
        print("doAfterDropDown >>> ")
        if FCasinoCtx:GetGame().HasJpInCurRefillGrids then
            FCasinoCtx:GetGame():PlayZeusMultiNotifyEndAnim()
        end
        Utils.PlaySound("ui://Game481/Falling_into")
        if reelDatas ~= nil then
            -- 动画结束后, 刷新当前格子视图
            for k, reel in pairs(self.reels) do
                local reelData = reelDatas[k]
                reel:Recovery(reelData)
            end
            self:ShowAllGrids()
        end
        self:DoMatch()
    end

    if reelDatas == nil then
        doAfterDropDown()
        return
    end
    -- 获取已经隐藏的grid节点, 作为从顶部下落的动画视图节点
    local shouldDropCount = #self.curClearedIndexs
    local tobeDropGridNodesData = {}
    for i,v in ipairs(self.curClearedIndexs) do
        local reelIndex = Utils.GetReelIndex(v) + 1
        local rowIndex = Utils.GetCellIndex(v) + 1
        local reelSymbolDisplays = self.reels[reelIndex].renders
        local renderDisplay = reelSymbolDisplays[rowIndex]

        tobeDropGridNodesData[reelIndex] = tobeDropGridNodesData[reelIndex] or {} 
        table.insert(tobeDropGridNodesData[reelIndex],renderDisplay) 
    end

    local hadDropCount = 0
    FCasinoCtx:GetGame().HasJpInCurRefillGrids = false
    for reelIdx, tobeDropRenderDisplays in pairs(tobeDropGridNodesData) do
        local curReel = self.reels[reelIdx]
        local baseBeginY = - NormalSlot.downMoveUnitDistance / 2
        
        local dropCount = #tobeDropRenderDisplays
        local aniDuration = dropCount * NormalSlot.downMoveUnitDistance / Reel.DropDownSpeed

        local newJPRenders = {}
        function doAfterTweenAni()
            hadDropCount = hadDropCount + 1
            if hadDropCount == shouldDropCount then
                if reelIdx then Utils.PlaySound("ui://Game481/elasticity_"..reelIdx) end
                doAfterDropDown()
            end
        end

        local posToY
        local posFromY = baseBeginY - NormalSlot.downMoveUnitDistance
        local hasPlayZeusNotifyAnim = false
        for i = 1, dropCount do
            local curDisplay = tobeDropRenderDisplays[i]
            local dropDistanceCount = dropCount - i + 1
            -- 显示下一组中奖结果图案
            local rowIdx = dropDistanceCount
            local symbolData = reelDatas[reelIdx][rowIdx]
            curReel:UpdateSymbol(curDisplay, symbolData, rowIdx)
            if symbolData.icon == GameDefine.ICON_JP then
                table.insert(newJPRenders,curDisplay) 
                FCasinoCtx:GetGame().HasJpInCurRefillGrids = true
                if not hasPlayZeusNotifyAnim then
                    hasPlayZeusNotifyAnim = true
                    FCasinoCtx:GetGame():PlayZeusMultiNotifyAnim()
                end
            end

            local topOffDistance = (i - 1) * NormalSlot.downMoveUnitDistance
            posToY = Reel.BasePosYTable[rowIdx]
            posFromY = baseBeginY - topOffDistance
            curDisplay.y = posFromY
            curDisplay.visible = true

            Reel.TweenChildDown(curDisplay, 0, posFromY, posToY, aniDuration, doAfterTweenAni, true)
        end
    end
end


-- 中奖线图案消除
function NormalSlot:MatchLines(callback)
    print("NormalSlot:MatchLines >>> ")
    local toBeClearedPattern = table.remove(self.toBeClearedPatterns, 1)
    local curResWinCoinsByIcon = table.remove(self.eachResWinCoinsByIcon, 1)

    if #toBeClearedPattern == 0 then -- sc中将线不需要消除
        callback()
        return
    end

    self.curClearedIndexs = {}
    for _,v in ipairs(toBeClearedPattern) do 
        table.insert(self.curClearedIndexs,v.index)
    end
    
    local toClearCount = #toBeClearedPattern
    local playedCount = 0
    
    local resetTransTalbe = {}

    FCasinoCtx:GetGame():PlayAwardHistoryItemAni()

    -- Divide toBeClearedPatterns by icon type
    local patternsByIcon = {}
    for _, pattern in ipairs(toBeClearedPattern) do
        local icon = pattern.icon
        if not patternsByIcon[icon] then
            patternsByIcon[icon] = {}
        end
        table.insert(patternsByIcon[icon], pattern)
    end

    local middlePatternIdxs = {}
    for icon, patterns in pairs(patternsByIcon) do
        -- find pattern in the middle reel to show score animation
        local reelsWithPattern = {}
        for _, v in ipairs(patterns) do
            local index = v.index
            local reelIndex = Utils.GetReelIndex(index) + 1
            reelsWithPattern[reelIndex] = true
        end
        
        local reelIndices = {}
        for reelIndex in pairs(reelsWithPattern) do
            table.insert(reelIndices, reelIndex)
        end
        table.sort(reelIndices)
        
        local middleReelIndex = reelIndices[math.ceil(#reelIndices / 2)]
        local rowOrder = {3, 2, 4, 1, 5}
        local middlePatternIdx
        for _, rowIndex in ipairs(rowOrder) do
            for _, v in ipairs(patterns) do
                local index = v.index
                local reelIndex = Utils.GetReelIndex(index) + 1
                local patternRowIndex = Utils.GetCellIndex(index) + 1
                if reelIndex == middleReelIndex and patternRowIndex == rowIndex then
                    middlePatternIdx = v.index
                    break
                end
            end
            if middlePatternIdx then
                table.insert(middlePatternIdxs, middlePatternIdx)
                break 
            end
        end
    end

    if #toBeClearedPattern ~= 0 then
        Utils.PlaySound("ui://Game481/win_frame")
    end

    for _, v in ipairs(toBeClearedPattern) do
        local index = v.index
        local icon = v.icon

        local isScoreAniSymbol = Utils.itemExists(middlePatternIdxs, index) ~= -1

        local reelIndex = Utils.GetReelIndex(index) + 1
        local rowIndex = Utils.GetCellIndex(index) + 1
        
        local reelSymbolDisplays = self.reels[reelIndex].renders
        local renderDisplay = reelSymbolDisplays[rowIndex]

        if renderDisplay:GetTransition("icon-ani-"..icon) then
            renderDisplay:GetTransition("icon-ani-"..icon):Play()
        end

        if isScoreAniSymbol then
            local iconWinScore = curResWinCoinsByIcon[icon]
            local iconScoreText = iconWinScore and tostring(Utils.ConvertScoreToRealVisual(iconWinScore)) or "0"
            renderDisplay:GetChild("lineScore").text = iconScoreText 
            renderDisplay:GetTransition("line-score"):Play()
        end

        renderDisplay:GetTransition("award-effect"):Play(function()
            playedCount = playedCount + 1
            if playedCount == toClearCount then
                callback()
            end
        end)
    end

    local lineWinScore = 0
    for _, score in pairs(curResWinCoinsByIcon) do
        lineWinScore = lineWinScore + score
    end
    FCasinoCtx:GetGame().tipInfo:AddScrollTipScoreViewTo(lineWinScore, 0.2)
    
    if #toBeClearedPattern ~= 0 then
        Utils.SetTimeout(function()
            if self.matchIdx == nil  then self.matchIdx = 1 end
            Utils.PlaySound("ui://Game481/remove_"..self.matchIdx)
            self.matchIdx = self.matchIdx + 1
            if self.matchIdx > 10 then self.matchIdx = 1 end
        end, 1.6)
    end

end

function NormalSlot:ResetAllSymbols()
    for k, reel in pairs(self.reels) do
       reel:ResetChildren()
    end
end


return NormalSlot