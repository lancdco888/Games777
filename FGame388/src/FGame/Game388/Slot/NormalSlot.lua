-- 老虎机普通游戏，三个格子一组转动
local Reel = Import(".Reel")
local SymbolConfig = Import(".SymbolConfig")
local BaseSlot = Import(".BaseSlot")
local MusicCfg = Import(".MusicCfg")
local ConstCfg = Import(".ConstCfg")
local Tools = Import(".Tools")
local LuodiSymbolItem = Import(".LuodiSymbolItem")

local NormalSlot = Class("NormalSlot", BaseSlot)


function NormalSlot:ctor(parent, game)
    local initDatas = ConstCfg.InitUIBox
    local initSymbols = Tools.InitUIBox2Symbol(initDatas)
    local x = 0
    for i = 1, FCasinoCtx.gameCfg.Reel.xCellNumber do
        local reel = Reel.New(self.bottomContainer, i, FCasinoCtx.gameCfg.Reel.yCellNumber)
        reel.isBouncePlay = true
        local initSymbol = nil
        if initSymbols[i] then
            initSymbol = initSymbols[i]
        end
        reel:InitSymbol(initSymbol)
        reel:SetMask(false)
        reel.reelContainer.x = x
        self.reels[i] = reel

        -- 单列格子宽度
        x = x + FCasinoCtx.gameCfg.Reel.reelWidth
        -- 每列间距
        x = x + FCasinoCtx.gameCfg.Reel.reelSpace
    end
    self.reelDatas = {}
    self.animIndexs =  {}
end

function NormalSlot:__delete()
    self:CleanTimers()
end

-- @brief 滚动开始
function NormalSlot:SpinStart()
    -- spin按钮置为等待状态
    FCasinoCtx:SetSpinStatus(FSpinStatus.WAITING)
    -- 转轴开始滚动
    for k, v in pairs(self.reels) do
        v:SpinForever()
    end
    self:ResetState()
end

function NormalSlot:ResetState()
    -- 删除顶部图案
    self:RemoveTopSymbol()
    for k, v in pairs(self.reels) do
        v:ShowSymbolDisplays()
    end
    -- 隐藏中奖线
    -- self.game:StopLines()
    self.reelDatas = {}
    self.animIndexs = {}
    self.isEnterFree = false
    self.isEnterTopupBouns = false
    self:CleanTimers()
end

-- @brief 设置图案数据
-- @param finishcallback 中奖线播放一轮后的回调函数
-- @param quickSet 快速设置，跳过动画
function NormalSlot:SetReelSymbolData(callback, quickSet)
    self.onFinishCallback = callback
    NormalSlot.isLinesHasScatter = false
    -- 设置最终停止数据 跳过动画
    if quickSet then
        for k, v in pairs(self.reels) do
            v:SetOpen(self.isOpen)
            v:Recovery(self.reelDatas[k])
        end
        FCasinoCtx:SetSpinStatus(FSpinStatus.SPIN)
        if self.onFinishCallback then
            self.onFinishCallback(0)
            self.onFinishCallback = nil
        end
        return
    end
    FCasinoCtx:SetSpinStatus(FSpinStatus.STOP)
    -- 设置最终停止数据
    local count = 0
    for k, v in pairs(self.reels) do
        local addReelTime = 0
        if self.delayReelerBeginIdx ~= nil and k >= self.delayReelerBeginIdx then
            addReelTime = 2 * (k - self.delayReelerBeginIdx+1)
        end

        v:Stop(
            self.reelDatas[k],
            function()
                print("current")
                -- dump(FCasinoCtx:GetGame().reelerIdxsShouldPlayScatterAudio,"FCasinoCtx:GetGame().reelerIdxsShouldPlayScatterAudio>>>>>>>>>>>>")
                if  FCasinoCtx:GetGame().reelerIdxsShouldPlayScatterAudio ~= nil and Tools.itemExists(FCasinoCtx:GetGame().reelerIdxsShouldPlayScatterAudio,k) then
                    FToolSet.PlayFGUISound(MusicCfg.REELSTOP_SC)
                end

                count = count + 1
                if self.delayReelerBeginIdx ~= nil and k == self.delayReelerBeginIdx - 1 then
                    self.delayReelSoundHandler = FToolSet.PlayFGUISound(MusicCfg.DELAY_REEL)
                end 
                if count >= #self.reels then
                    self:OnReelScrollStop(k, self.animIndexs)
                end
            end,
            FConfig.Common:GetRellStopInterval(k) + addReelTime
        )
    end
end


function NormalSlot:ShowFreeBeginPanel(callback)
    local freeBeginPanel = self.game.render:GetChild("freeBeginPanel")
    local labelCount = freeBeginPanel:GetChild("lable-count")
    local startBtn = freeBeginPanel:GetChild("start-btn")
    local showTime = 6
    if self.game.isFreeInFree then
        freeBeginPanel:GetController("c1").selectedPage = "add"
        showTime = 2
    else
        freeBeginPanel:GetController("c1").selectedPage = "normal"
    end

    -- APIGateway.RemoveEventListeners(startBtn, FGUIEventKey.onClick)

    startBtn:AddEventListener(FGUIEventKey.onClick,function()
        if self.timerHideFreeBeginPanel then
            StopTimer(self.timerHideFreeBeginPanel)
            self.timerHideFreeBeginPanel = nil
        end

        freeBeginPanel:GetTransition("hide"):Play(function()
            -- FToolSet.PlayFGUISound(MusicCfg.FREE_NEW_OUT)
            labelCount.visible = false
            freeBeginPanel.visible = false
            if callback then callback() end 
        end)
    end)
    
    labelCount.text = tostring(self.game.GetIntoFreeGameCount())
    labelCount.visible = true
    local callAfterBeginShowAni = function()
        -- 显示弹窗中的免费次数
        self.timerHideFreeBeginPanel = StartOnceTimer(function()
            freeBeginPanel:GetTransition("hide"):Play(function()
                -- FToolSet.PlayFGUISound(MusicCfg.FREE_NEW_OUT)
                labelCount.visible = false
                freeBeginPanel.visible = false
                if callback then callback() end 
            end)        
        end, showTime)
    end

    FToolSet.PlayFGUISound(MusicCfg.FREE_NEW_IN)
    freeBeginPanel.visible = true
    -- 显示免费开始弹窗(弹窗内容为当前免费次数)
    freeBeginPanel:GetTransition("start"):Play(function() callAfterBeginShowAni() end)
end

-- 先看看有没有中免费 落地牌,再执行
function NormalSlot:CheckEnterOtherGame()
    if self.game == nil then
        return
    end
    if self.isEnterFree or self.game.isFreeInFree then
        FToolSet.PlayFGUISound(MusicCfg.FREE_TRIGGER)
        -- 延迟显示进入特殊模式弹窗
        -- 免中免
        local bottomWin = 0
        if self.game.isFreeInFree then
            -- bottomWin = self.game.enterFreeWinCoin + self.game.slotContainers[SlotType.Free]:GetWinCoin()
            bottomWin = self.game.slotContainers[2]:GetWinCoin()
        else
            bottomWin = self.game.enterFreeWinCoin
        end
        local soundTime = self.game:ShowBottomWin(false,bottomWin)
        self.doAfterIntoFreeSoundPlay = function()

            FToolSet.PlayFGUISound(MusicCfg.FREE_SC_AWARD)

            StartOnceTimer(function()

                self:ShowFreeBeginPanel(function()
                    APIGateway.RemoveEventListeners(startBtn, FGUIEventKey.onClick)
                    if self.game then
                        -- self:CheckSoundPlay(self.game.enterFreeWinCoin)
                        -- self.checkSoundPlayTimer = nil
                        if self.onFinishCallback then
                            self.onFinishCallback(second)
                            self.onFinishCallback = nil
                        end
                    end
                end)

            end, 2)

            self.playSoundScatterTimer = nil
        end

        self.playSoundScatterTimer = StartOnceTimer(function()
            self.doAfterIntoFreeSoundPlay()
        end, soundTime + 1)
    elseif self.isEnterTopupBouns then
        FToolSet.PlayFGUISound(MusicCfg.FREE_TRIGGER)
        -- 延迟显示进入特殊模式弹窗
        local bottomWinToShow = 0
        if self.game._winCoin ~= nil then
            bottomWinToShow = self.game._winCoin + self.game.enterLuodiWinCoin
        else
            bottomWinToShow = self.game.enterLuodiWinCoin
        end
        local soundTime = self.game:ShowBottomWin(false,bottomWinToShow)
        FToolSet.PlayFGUISound(MusicCfg.win_feature)
        self.checkSoundPlayTimer = StartOnceTimer(
            function()
                if self.game then
                    self:CheckSoundPlay(self.game.enterLuodiWinCoin)
                    self.checkSoundPlayTimer = nil
                end
            end, soundTime + 1)
    else
        self:CheckSoundPlay()
        self.game:ShowBottomWin()
    end
end

function NormalSlot:CheckSoundPlay(winCoin)
    local curWin = winCoin or self.game.slotContainers[self.game.curGameType]:GetWinCoin()
    local lastWinCoin = self.game._winCoin
    local addCoin = winCoin or (curWin - lastWinCoin)
    local audioData = self.game:GetAudioData(addCoin)

    local second = 0
    if audioData then
        second = audioData.time
    end
    
    if self.isEnterFree then
        if second > 0 then
            FCasinoCtx:SetSpinStatus(FSpinStatus.STOP)
        end
    end

    if self.onFinishCallback then
        self.onFinishCallback(second)
        self.onFinishCallback = nil
    end
end

function NormalSlot:SetIsEnterFree(isEnterFree)
    self.isEnterFree = isEnterFree
end

function NormalSlot:SetIsEnterTopupBouns(isEnterTopupBouns)
    self.isEnterTopupBouns = isEnterTopupBouns
end

-- 处理格子信息
function NormalSlot:HandleCellDatas(grids)
    local freeCount = 0
    self:CheckSCSymbol(grids)
    -- 整理服务器数据
    local reelDatas = {}
    local bounsCount = {}
    for k, v in pairs(grids) do
        local reelIndex = self:GetReelIndex(k) + 1
        local iconIndex = self:GetCellIndex(k) + 1

        if v.icon == 2 then
            if bounsCount[reelIndex] == nil then
                bounsCount[reelIndex] = 0
            end
            bounsCount[reelIndex] = bounsCount[reelIndex] + 1
        elseif v.icon == 3 then
            freeCount = freeCount + 1
        end
        reelDatas[reelIndex] = reelDatas[reelIndex] or {}
        reelDatas[reelIndex][iconIndex] = {
            icon = v.icon,
            value = v.SymbolValue,
            type = v.SymbolType
        }
    end
    if freeCount >= 3 then
        self.isEnterFree = true
    end

    local total = 0
    for reelIndex, jpCount in pairs(bounsCount) do
        local residue = math.abs(reelIndex - FCasinoCtx.gameCfg.Reel.xCellNumber) * 3
        if jpCount > 0 then
            if total + jpCount + residue >= 6 then
                total = total + jpCount
            end
        end
    end
    self.reelDatas = reelDatas
end

function NormalSlot:CheckSCSymbol(grids)
    self.delayReelerBeginIdx = nil
    local scatterColumnDic = {}
    for i=1,#grids do
        local icon = grids[i].icon
        local column = i%5 == 0 and 5 or i%5 
        if scatterColumnDic[column] == nil then 
            scatterColumnDic[column] = 0
        end
        if icon == ConstCfg.FreeSymbolId then
            scatterColumnDic[column] = scatterColumnDic[column] + 1 
        end
    end

    local delayReelerBeginIdx = 0
    local scatterReelerCount = 0
    -- dump(scatterColumnDic,"CheckSCSymbol::scatterColumnDic>>>>>>>>>>>>>")
    for reelerIdx,scCount in pairs(scatterColumnDic) do
        if scCount ~= 0 then
            scatterReelerCount = scatterReelerCount + 1 
        end
        if scatterReelerCount == 2 then
            delayReelerBeginIdx = reelerIdx + 1
            delayReelerBeginIdx = delayReelerBeginIdx < 5 and delayReelerBeginIdx or 0
            break
        end
    end
    -- print("CheckSCSymbol::self.delayReelerBeginIdx>>>>>>>>"..tostring(delayReelerBeginIdx))

    if delayReelerBeginIdx ~= 0 then
        self.delayReelerBeginIdx = delayReelerBeginIdx
    end
end

-----处理中奖线 --------
--- drawLines: 中奖线id集合
--- animIndexs: 播放anim的 index
--- 忽略
function NormalSlot:HandleWinDatas(lines)
    self.winCoin = 0
    if not next(lines) then
        return
    end

    local animIndexs = {}
    local winCoin = 0
    for i, line in ipairs(lines) do
        if not Tools.IsScLine(line.lineIndex) then
            -- 落地牌不算分
            winCoin = winCoin + line.winCoin
        end

        for j, cell in ipairs(line.lineCells) do
            animIndexs[cell.index] = true
        end
    end

    self.winCoin = winCoin
    self.animIndexs = animIndexs
end

NormalSlot.isLinesHasScatter = false
function NormalSlot:DecreaseMainVolume()
    if FCasinoCtx.curGameMode == FGameMode.NORMAL and not FCasinoCtx.isAutoSpin then
        local volume = 1
        self.game.mainVolumeDecreaseTimer = StartTimer(function()
            volume = volume - 0.01
            if volume > 0 and self.game.soundBgmHandle ~= nil then
                APIGateway.SetSoundVolume(self.game.soundBgmHandle,volume)
            else
                -- self.game:StopCurBgm()
                if self.game.mainVolumeDecreaseTimer then 
                    StopTimer(self.game.mainVolumeDecreaseTimer)
                    self.game.mainVolumeDecreaseTimer = nil
                end
            end
        end,0.02)
    end
end

--[[ function NormalSlot:SwitchAllSymbolsToLuodiMode()
    for index = 1, 5 do
        -- 替换动画到顶层显示
        local arraySymbolDisplays = self.reels[index].arraySymbolDisplays
        for i = 1, 3 do
            local data = arraySymbolDisplays[i].data
            local display = arraySymbolDisplays[i]
            display.render:GetController("c1").selectedPage = "luodi"
        end
    end
end

function NormalSlot:SwitchAllSymbolsToNormalMode()
    for index = 1, reelCfg.xCellNumber do
        -- 替换动画到顶层显示
        local arraySymbolDisplays = self.reels[index].arraySymbolDisplays
        for i = 1, reelCfg.yCellNumber do
            local data = arraySymbolDisplays[i].data
            local display = arraySymbolDisplays[i]
            display.render:GetController("c1").selectedPage = "normal"
        end
    end
end ]]


-- 所有转轴停止转动
function NormalSlot:OnReelScrollStop(reelIndex,animIndexs)
    self:DecreaseMainVolume()
    local reelCfg = FCasinoCtx.gameCfg.Reel
    -- 遍历所有图案节点
    for index = 1, reelCfg.xCellNumber do
        -- 替换动画到顶层显示
        local arraySymbolDisplays = self.reels[index].arraySymbolDisplays
        for i = 1, reelCfg.yCellNumber do
            local data = arraySymbolDisplays[i].data
            local display = arraySymbolDisplays[i]
            local icon = display.data.icon
            if icon == ConstCfg.FreeSymbolId then
                NormalSlot.isLinesHasScatter = true
            end
            local cfg = SymbolConfig[icon]
            local logicIndex = (i - 1) * reelCfg.xCellNumber + index
            local animShow = animIndexs[logicIndex]
            
            local logicIndex = (i - 1) * reelCfg.xCellNumber + index

            if animShow then
                -- print("NormalSlot:OnReelScrollStop>>>>>>>>>self:GetOrCreateTopSymbol")
                if icon == 2 then
                    local render = self:GetOrCreateTopSymbol(logicIndex)
                    self:_InitTopSymbolRender(render, data)
                    display.render.visible = false
                else
                    -- 统一播放所有中奖线动画
                    self:_PlayCommonAnim(display.render, cfg, icon)
                end
            end
        end
    end
    if self.delayReelSoundHandler ~= nil then
        APIGateway.StopSound(self.delayReelSoundHandler)
        self.delayReelSoundHandler = nil
    end
    self:CheckEnterOtherGame()
end

function NormalSlot:ShowAllSymbolDisplays()
    local reelCfg = FCasinoCtx.gameCfg.Reel
    for index = 1, reelCfg.xCellNumber do
        -- 替换动画到顶层显示
        local arraySymbolDisplays = self.reels[index].arraySymbolDisplays
        for i = 1, reelCfg.yCellNumber do
            local display = arraySymbolDisplays[i]
            display.render.visible = true
        end
    end
end

function NormalSlot:_InitTopSymbolRender(render, data)
    local luodiItemObj = render:GetChild("luodi")
    local luodiItemComp = LuodiSymbolItem.New(luodiItemObj)
    luodiItemComp:StopClassTracking()
    local luodiType = data.type
    local shouldShowLight = data.shouldShowLight
    if luodiType  == 10 then
        local val = data.value
        luodiItemComp:showNormal(val, shouldShowLight)
    else
        luodiItemComp:showJackPot(luodiType, shouldShowLight)
    end
    luodiItemObj.visible = true
end

function NormalSlot:_PlayCommonAnim(render, cfg, icon)
    -- print("NormalSlot:_PlayCommonAnim>>>>>>>>>>")
    local loader_normal = render:GetChild("loader-normal")
    local loader_special = render:GetChild("loader-special")
    local loader_sc = render:GetChild("loader-sc")
    local loader_nvxia = render:GetChild("loader-nvxia")
    local ani_free = render:GetChild("ani-free")
    local luodiItemObj = render:GetChild("luodi")

    luodiItemObj.visible = false
    loader_normal.visible = false
    loader_special.visible = false
    loader_nvxia.visible = false
    loader_sc.visible = false
    ani_free.visible = false

    if icon == 2 then
        luodiItemObj.visible = true
    elseif icon == 3 then
        loader_sc.visible = true
        ani_free.visible = true
        render:GetTransition("sc-scale"):Play()
    else
        if icon >= 9 then
            loader_normal.visible = true
            loader_normal.url = cfg.icon
        elseif icon == 4 then
            loader_nvxia.visible = true
        else
            -- 免费和花牌
            loader_special.visible = true
            loader_special.url = cfg.icon
        end
        -- scale 动画
        self:PlaySymbolScale(cfg,render,icon)
    end
end

function NormalSlot:SetOpen(isOpen)
    self.isOpen = isOpen
end

function NormalSlot:GetWinCoin()
    return self.winCoin
end

function NormalSlot:StopPlaySoundScatterTimer()
    if self.playSoundScatterTimer then
        StopTimer(self.playSoundScatterTimer)
        self.doAfterIntoFreeSoundPlay()
        self.playSoundScatterTimer = nil
    end
end

function NormalSlot:CleanTimers()
    self:StopPlaySoundScatterTimer()

    if self.drawLineAndCollectScoresTimer then
        StopTimer(self.drawLineAndCollectScoresTimer)
        self.drawLineAndCollectScoresTimer = nil
    end

    if self.checkSoundPlayTimer then
        StopTimer(self.checkSoundPlayTimer)
        self.checkSoundPlayTimer = nil
    end
end

--[[ function NormalSlot:PlayScaleByCells(lineCells)
    for _, cell in ipairs(lineCells) do
        local icon = cell.icon
        local index = cell.index
        local cfg = SymbolConfig[icon]
        local render = self.topSymbolRenders[index]
        self:PlaySymbolScale(cfg,render,icon)
    end
end ]]

function NormalSlot:PlaySymbolScale(cfg,render,icon)
    if cfg.needScale then
        local transitionName
        if render then
            render:SetScale(1,1)
            if icon == 4 then transitionName = "nvxia-scale" 
            else
                if icon >= 9 then transitionName = "normal-scale"
                else transitionName = "special-scale" end
            end
            local transition = render:GetTransition(transitionName) 
            -- transition:Play(-1, function()end)
            transition:Play(-1, 0, function()end)
        end
    end
end

function NormalSlot:StopAllScaleAnims()
    for index = 1, 5 do
        -- 替换动画到顶层显示
        local arraySymbolDisplays = self.reels[index].arraySymbolDisplays
        for i = 1, 3 do
            -- local data = arraySymbolDisplays[i].data
            local v = arraySymbolDisplays[i].render
            local transition_nvxia = v:GetTransition("nvxia-scale")
            local transition_normal = v:GetTransition("normal-scale")
            local transition_special = v:GetTransition("special-scale")
            transition_nvxia:Stop()
            transition_normal:Stop()
            transition_special:Stop()
        end
    end

    -- for i, v in pairs(self.topSymbolRenders) do
    --     if v then
    --         local transition_nvxia = v:GetTransition("nvxia-scale")
    --         local transition_normal = v:GetTransition("normal-scale")
    --         local transition_special = v:GetTransition("special-scale")
    --         transition_nvxia:Stop()
    --         transition_normal:Stop()
    --         transition_special:Stop()
    --     end
    -- end
end

return NormalSlot
