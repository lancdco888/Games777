local BaseSlot = Import(".BaseSlot")
local SymbolConfig = Import(".SymbolConfig")
local ConstCfg = Import(".ConstCfg")
local Tools = Import(".Tools")
local Reel = Import(".Reel")
local MusicCfg = Import(".MusicCfg")
local Help = Import(".Help")

local cls = Class("FreeNormalSlot", BaseSlot)

function cls:ctor(parent, game)
    self.game = game
    local initDatas = ConstCfg.InitUIBox
    local initSymbols = Tools.InitUIBox2Symbol(initDatas)
    local x = 0
    for i = 1, 3 do
        local reel = nil

        if i ~= 2 then
            reel = Reel.New(self.bottomContainer, i, FCasinoCtx.gameCfg.Reel.yCellNumber)
            reel.reelContainer.x = x
            -- 单列格子宽度
            x = x + FCasinoCtx.gameCfg.Reel.reelWidth
            -- 每列间距
            x = x + FCasinoCtx.gameCfg.Reel.reelSpace
            -- reel.cfg.rollSymbolMinNum = 15
        else
            reel = Reel.New(self.bottomContainer, i, 1)
            reel:IsBigSymbol(true)
            reel.cfg.xCellNumber = 1
            reel.cfg.yCellNumber = 1
            reel.cfg.reelWidth = 500
            reel.cfg.symbolWidth = 500
            reel.cfg.rollSymbolMinNum = 10
            reel.reelContainer.x = x + 3

            x = x + 506
            x = x + FCasinoCtx.gameCfg.Reel.reelSpace
        end
        reel:isFree(true)
        reel.isBouncePlay = true
        local initSymbol = nil
        if initSymbols[i] then
            initSymbol = initSymbols[i]
        end

        reel:InitSymbol(initSymbol)
        reel:SetMask(false)
        self.reels[i] = reel
    end
    self.winCoin = 0

    self:ResetDatas()
end

function cls:ResetDatas(curturn, allturns, totalWinCoin)
    self.curturn = curturn or 0
    self.allturns = allturns or 6
    self.totalWinCoin = totalWinCoin or 0
    self:RemoveTopSymbol()
end

-- @brief 滚动开始
function cls:SpinStart()
    -- spin按钮置为等待状态
    FCasinoCtx:SetSpinStatus(FSpinStatus.WAITING)
    -- 转轴开始滚动
    for k, v in pairs(self.reels) do
        v:SpinForever()
    end
    self.curturn = self.curturn + 1
    self:ResetState()
    self.game:SetMidTips("freecount", self.curturn, self.allturns)
end

function cls:ResetState()
    -- 删除顶部图案
    self:RemoveTopSymbol()
    for k, v in pairs(self.reels) do
        v:ShowSymbolDisplays()
    end

    -- 隐藏中奖线
    self.game:StopLines()
    self.reelDatas = {}
    self.drawLines, self.animIndexs, self.wild2Indexs, self.wild3Indexs, self.wildFreeShow = {}, {}, {}, {}, {}
    self.bigAnimationIndex = -1
    self.hasBouns = { false,
        false,
        false,
        false,
        false
    }
    self.isEnterTopupBouns = false
end

function cls:__delete()
end

function cls:GetCurTurn()
    return self.curturn
end

function cls:GetAllTurns()
    return self.allturns
end

function cls:SetAllTurns(allturns)
    if self.allturns == allturns then
        return
    end
    local oldaddturns = self.allturns
    self.allturns = allturns
    self.game:SetMidTips("freecount", self.curturn, self.allturns, oldaddturns)
end

function cls:HandleWinDatas(lines)
    if not next(lines) then
        return
    end

    local wildCells = {}
    local animIndexs = {}
    local drawLines = {}
    local winCoin = 0

    local bigCell = { 2, 3, 4, 7, 8, 9, 12, 13, 14 }

    local bigAnimationIndex = -1

    for i, line in ipairs(lines) do
        if not Tools.IsScLine(line.lineIndex) then
            -- 落地牌不算分
            winCoin = winCoin + line.winCoin
        end
        local hasWild = false
        for j, cell in ipairs(line.lineCells) do
            if Tools.Includes(bigCell, cell.index) and bigAnimationIndex == -1 then
                bigAnimationIndex = cell.icon
            end

            if bigAnimationIndex ~= -1 and Tools.IsWiCard(bigAnimationIndex) then
                hasWild = true
            end

            if Tools.IsWiCard(cell.icon) and not Tools.Includes(bigCell, cell.index) then
                -- 百搭
                wildCells[cell.index] = cell
                hasWild = true
            end
            if not Tools.Includes(bigCell, cell.index) then
                animIndexs[cell.index] = true
            end
        end

        local isFour = #line.lineCells >= 4
        if line.lineIndex <= 50 then
            if hasWild then
                local url = SymbolConfig[1].soundURL
                local stime = SymbolConfig[1].soundTime
                table.insert(drawLines, 1, {
                    lineCells = line.lineCells,
                    index = line.lineIndex,
                    sound = url,
                    isWild = true,
                    soundTime = stime,
                    winCoin = line.winCoin
                })
            end

            -- 普通中奖线 大于四个的且没有百搭的四连中奖
            if isFour and not hasWild then
                local url = SymbolConfig[line.lineCells[1].icon].fourSoundURL
                if Tools.IsFreeGameMode(self.game) then
                    url = nil
                end
                table.insert(drawLines, {
                    lineCells = line.lineCells,
                    index = line.lineIndex,
                    sound = url,
                    soundTime = SymbolConfig[line.lineCells[1].icon].soundTime,
                    winCoin = line.winCoin
                })
            end

            if not isFour and not hasWild then
                table.insert(drawLines, {
                    lineCells = line.lineCells,
                    index = line.lineIndex,
                    sound = nil,
                    winCoin = line.winCoin
                })
            end
        end
    end

    local wild2Indexs = {}
    local wild3Indexs = {}
    --for cellIndex, cell in pairs(wildCells) do
    --    if wildCells[cellIndex + 5] then
    --        -- 一列两个百搭
    --        animIndexs[cellIndex + 5] = nil      -- 需要把二连百搭第二行的动画取消掉
    --        if wildCells[cellIndex + 10] then
    --            -- 一列三个百搭
    --            animIndexs[cellIndex + 10] = nil -- 需要把三连百搭第三行的动画取消掉
    --            wild3Indexs[cellIndex] = true
    --        else
    --            if not wildCells[cellIndex - 5] then
    --                wild2Indexs[cellIndex] = true
    --            end
    --        end
    --    end
    --end

    self.drawLines = drawLines
    self.animIndexs = animIndexs
    self.wild2Indexs = wild2Indexs
    self.wild3Indexs = wild3Indexs
    self.bigAnimationIndex = bigAnimationIndex

    self.totalWinCoin = self.totalWinCoin + winCoin
end

function cls:SetOpen(isOpen)
    self.isOpen = isOpen
end

function cls:GetWinCoin()
    return self.totalWinCoin
end

function cls:SetIsEnterFree(isEnterFree)
    self.isEnterFree = isEnterFree
end

function cls:SetIsEnterTopupBouns(isEnterTopupBouns)
    self.isEnterTopupBouns = isEnterTopupBouns
end

-- 处理免费模式百搭数据
function cls:HandleFreeWildData(grids, lines)
    local wildIconIndex = {} --找出所有百搭牌index
    local bigWildIndex = { 2, 3, 4, 7, 8, 9, 12, 13, 14 }
    for _, val in ipairs(grids) do
        if Tools.IsWiCard(val.icon) then
            if Tools.Includes(bigWildIndex) then
                wildIconIndex[8] = 0
            else
                wildIconIndex[val.index] = 0
            end
        end
    end

    -- 找出所有中奖的列
    for _, cells in ipairs(lines) do
        for _, val in ipairs(cells.lineCells) do
            if Tools.IsWiCard(val.icon) then
                if Tools.Includes(bigWildIndex) then
                    wildIconIndex[8] = 1
                elseif wildIconIndex[val.index] then
                    wildIconIndex[val.index] = 1
                end
            end
        end
    end
end

-- 处理格子信息
function cls:HandleCellDatas(grids)
    -- 整理服务器数据
    local freeCount = 0
    local reelDatas = {}
    local bounsCount = {}

    for k, v in pairs(grids) do
        local reelIndex = self:GetReelIndex(k, true) + 1
        local iconIndex = self:GetCellIndex(k, true) + 1

        if reelIndex == 1 or reelIndex == 5 then
            if Tools.IsJpCard(v.icon) then
                if bounsCount[reelIndex] == nil then
                    bounsCount[reelIndex] = 0
                end
                bounsCount[reelIndex] = bounsCount[reelIndex] + 1
            elseif Tools.IsScCard(v.icon) then
                freeCount = freeCount + 1
            end
            if reelIndex == 5 then
                reelIndex = 3
            end
            reelDatas[reelIndex] = reelDatas[reelIndex] or {}
            reelDatas[reelIndex][iconIndex] = {
                icon = v.icon,
                value = v.SymbolValue,
                type = v.SymbolType,
            }
        elseif k == 8 then
            if Tools.IsScCard(v.icon) then
                freeCount = freeCount + 9
            end

            reelDatas[2] = reelDatas[2] or {}
            reelDatas[2][1] = {
                icon = v.icon,
                value = v.SymbolValue,
                type = v.SymbolType,
            }
        end
    end

    self.reelDatas = reelDatas
end

-- @brief 设置图案数据
-- @param finishcallback 中奖线播放一轮后的回调函数
-- @param quickSet 快速设置，跳过动画
function cls:SetReelSymbolData(callback, quickSet)
    self.onFinishCallback = callback
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

    local times = { 0, 0.8, 1 }
    -- 设置最终停止数据
    local count = 0
    for k, v in pairs(self.reels) do
        v:Stop(
            self.reelDatas[k],
            function()
                local displays = self.reels[k].arraySymbolDisplays
                for iconIndex, render in pairs(displays) do
                    render.render:GetChild("DragonCircle").visible = Tools.IsJpCard(render.data.icon)
                end
                count = count + 1
                if count >= #self.reels then
                    self:CheckEnterOtherGame(function()
                        self:OnReelScrollStop()
                    end)
                end
            end, times[k])
    end
end

function cls:OnReelScrollStop()
    local reelCfg = FCasinoCtx.gameCfg.Reel

    for index, val in ipairs({ 1, 2, 5 }) do
        if index ~= 2 then
            -- 替换动画到顶层显示
            local arraySymbolDisplays = self.reels[index].arraySymbolDisplays
            for i = 1, reelCfg.yCellNumber do
                local display = arraySymbolDisplays[i]
                local cfg = SymbolConfig[display.data.icon]

                local logicIndex = (i - 1) * 5 + val
                local isLD = cfg.LDRes
                local animShow = self.animIndexs[logicIndex]
                local wild2Show = self.wild2Indexs[logicIndex]
                local wild3Show = self.wild3Indexs[logicIndex]

                if animShow or wild2Show or wild3Show or isLD then
                    local render = self:GetOrCreateTopSymbol(logicIndex)
                    self:_InitTopSymbolRender(render, cfg, display, logicIndex)
                    local func = function()
                        if animShow or isLD then
                            -- 普通动画效果
                            self:_PlayCommonAnim(render, cfg)
                        end
                    end
                    func()
                    display.render.visible = false
                end
            end
        end
    end

    if self.bigAnimationIndex ~= -1 then
        local arraySymbolDisplays = self.reels[2].arraySymbolDisplays
        local display = arraySymbolDisplays[1]
        local render = self:GetOrCreateTopSymbol(8, true)
        local cfg = SymbolConfig[display.data.icon]
        self:_InitTopSymbolRender(render, cfg, display, 8)
        self:_PlayCommonAnim(render, cfg, true)
        display.render.visible = false
    end
end

function cls:GetReelIndex(index, conver)
    return cls.super.GetReelIndex(self, index)
end

-- @brief 获取Y轴格子下标
-- @return [0,2]
function cls:GetCellIndex(index, conver)
    return cls.super.GetCellIndex(self, index)
end

function cls:_InitTopSymbolRender(render, cfg, display, index)
    Tools.HideSymbolChildren(render)

    if cfg.icon:sub(1, 5) ~= "ui://" then
        local node = render:GetChild(cfg.icon)
        node.visible = true
    else
        local loader = render:GetChild("loader")
        loader.url = cfg.icon
        loader.visible = true
    end

    -- 数字
    local num = render:GetChild("num")
    -- 遮罩 -- todo
    local mask = render:GetChild("mask")
    mask.visible = false
    -- sprite1
    local sprite1 = render:GetChild("sprite1")
    -- sprite2
    local sprite2 = render:GetChild("sprite2")
    local wild1 = render:GetChild("wild1")
    local wild2 = render:GetChild("wild2")
    local wild3 = render:GetChild("wild3")
    wild1.visible = false
    if wild2 then
        wild2.visible = false
    end
    if wild3 then
        wild3.visible = false
    end

    local DragonExplo = render:GetChild("DragonExplo")
    DragonExplo.visible = false

    local DragonCircle = render:GetChild("DragonCircle")
    DragonCircle.visible = false

    -- 落地牌效果 [[
    if cfg.LDRes then
        local res = cfg.LDRes[display.data.type]
        num.visible = res.numShow
        sprite1.visible = res.spriteFontShow
        sprite2.visible = res.spriteFontShow
        if res.numShow then
            num.text = Tools.TopupBounsScoreToStr(display.data.value)
            local isBig = false
            if self.game.curGameType == 2 and index == 8 then
                isBig = true
            end
            Help.SetJpNumberTransform(num, isBig)
        end
        if res.sprite1Url and res.sprite1Url ~= "" then
            sprite1.url = res.sprite1Url
        end
        if res.sprite2Url and res.sprite2Url ~= "" then
            sprite2.url = res.sprite2Url
        end
    else
        num.visible = false
        sprite1.visible = false
        sprite2.visible = false
    end
    -- 落地牌效果]]
end

function cls:_PlayCommonAnim(render, cfg, isMega)
    Tools.HideSymbolChildren(render)

    local animation = cfg.animation
    local loader = render:GetChild("loader")
    local wild1 = render:GetChild("wild1")
    if animation and animation ~= "" then
        if Tools.IsNodeConfig(animation) then
            local node = render:GetChild(animation)
            node.visible = true
            loader.visible = false
        else
            loader.visible = true
            if isMega then
                animation = animation .. "_Mega"
            end
            loader.url = animation
        end
    else
        local animations = cfg.animations
        if animations then
            local animIntro = animations.animIntro
            local animLoop = animations.animLoop

            local animLoopCb = function()
                if Tools.IsNodeConfig(animLoop) then
                    local animInto = render:GetChild(animIntro)
                    animInto.visible = false
                    local node = render:GetChild(animLoop)
                    node.visible = true
                    loader.visible = false
                else
                    loader.visible = true
                    if isMega then
                        animLoop = animLoop .. "_Mega"
                    end
                    loader.url = animLoop
                end
            end

            if Tools.IsNodeConfig(animIntro) then
                local node = render:GetChild(animIntro)
                node.visible = true
                loader.visible = false
            else
                loader.visible = true
                if isMega then
                    animIntro = animIntro .. "_Mega"
                end
                loader.url = animIntro
            end
            if animLoop ~= nil and animLoop ~= "" then
                animLoopCb()
            end
        elseif cfg.wildRes then
            -- 单独的百搭
            local animIntro = cfg.wildRes[1].animIntro
            local animLoop = cfg.wildRes[1].animLoop
            wild1.visible = true

            wild1.url = animIntro
            wild1.sortingOrder = cfg.wildRes[1].zorder

            if animLoop ~= nil and animLoop ~= "" then
                wild1.movieClip:SetPlaySettings(0, -1, 1, -1, function()
                    if isMega then
                        animLoop = animLoop .. "_Mega"
                    end
                    wild1.url = animLoop
                    wild1.movieClip:SetPlaySettings(0, -1, 0, -1)
                    wild1.playing = true
                end)
            else
                wild1.movieClip:SetPlaySettings(0, -1, 0, 1)
            end
        else
            loader.url = cfg.icon
            loader.visible = true
        end
    end
end

function cls:_PlayWild2Anim(render, cfg)
    if not cfg.wildRes then
        return
    end
    local loader = render:GetChild("loader")
    local wild2 = render:GetChild("wild2")
    loader.visible = false
    local animIntro = cfg.wildRes[2].animIntro
    local animLoop = cfg.wildRes[2].animLoop
    wild2.visible = true
    wild2.url = animIntro
    wild2.sortingOrder = cfg.wildRes[2].zorder
    FTween.Start(render, FTween.Delay(1.2, function()
        wild2.url = animLoop
    end))
end

function cls:_PlayWild3Anim(render, cfg)
    if not cfg.wildRes then
        return
    end

    local wild3 = render:GetChild("wild3")
    local animIntro = cfg.wildRes[3].animIntro
    local animLoop = cfg.wildRes[3].animLoop
    wild3.visible = true
    wild3.url = animIntro
    wild3.sortingOrder = cfg.wildRes[3].zorder

    FTween.Start(
        render,
        FTween.Delay(1.2, function()
            wild3.url = animLoop
        end))
end

function cls:Show()

end

-- 先看看有没有中免费 落地牌,再执行
function cls:CheckEnterOtherGame(cb)
    if self.game == nil then
        if cb then
            cb()
        end
        return
    end
    if self.isEnterFree then
        FToolSet.PlayFGUISound(MusicCfg.feature_bell)
        self.playSoundScatterTimer = StartOnceTimer(function()
            if self.game then
                FToolSet.PlayFGUISound(MusicCfg.SND_Scatter)
                if cb then
                    cb()
                end
            end
            self.playSoundScatterTimer = nil
        end, 2)
        self.drawLineAndCollectScoresTimer = StartOnceTimer(function()
            if self.game then
                self:DrawLineAndCollectScores()
            end
            self.drawLineAndCollectScoresTimer = nil
        end, 6)
    elseif self.isEnterTopupBouns then
        FToolSet.PlayFGUISound(MusicCfg.feature_bell)
        self.checkSoundPlayTimer = StartOnceTimer(
            function()
                if self.game then
                    self:CheckSoundPlay()
                    self.checkSoundPlayTimer = nil
                end
            end, 2)
        cb()
    else
        self:CheckSoundPlay()
        cb()
    end
end

function cls:CheckSoundPlay()
    for _, line in ipairs(self.drawLines) do
        if line.sound then
            FToolSet.PlayFGUISound(line.sound)
            local time = line.soundTime
            self.drawLineAndCollectScoresTimer = StartOnceTimer(function()
                if self.game then
                    self:DrawLineAndCollectScores()
                end
                self.drawLineAndCollectScoresTimer = nil
            end, time)
            return
        end
    end
    self:DrawLineAndCollectScores()
end

-- 画线 收分
function cls:DrawLineAndCollectScores()
    self.game:PlayLines(self.drawLines)
    local second = self.game:ShowBottomWin()
    if #self.drawLines > 0 or self.isEnterFree then
        if second > 0 then
            FCasinoCtx:SetSpinStatus(FSpinStatus.STOP)
        end
    end

    if self.onFinishCallback then
        self.onFinishCallback(second)
        self.onFinishCallback = nil
    end
end

function cls:PlayBlinkByCells(lineCells)
    local index = { 2, 3, 4, 7, 8, 9, 12, 13, 14 }
    for _, cell in ipairs(lineCells) do
        local cfg = SymbolConfig[cell.icon]
        if cfg.needBlink then
            local cellIndex = cell.index
            if Tools.Includes(index, cellIndex) then
                cellIndex = 8
            end
            local render = self.topSymbolRenders[cellIndex]
            if render then
                local visible = true
                local loader = render:GetChild("loader")
                loader.visible = visible
                FTween.Start(render,
                    FTween.RepeatForever(
                        {
                            FTween.Delay(0.5, function()
                                visible = not visible
                                loader.visible = visible
                            end)
                        }
                    )
                )
            end
        end
    end
end

function cls:StopBlinkByCells(lineCells)
    for _, cell in ipairs(lineCells) do
        local cfg = SymbolConfig[cell.icon]
        if cfg.needBlink then
            local render = self.topSymbolRenders[cell.index]
            if render then
                local loader = render:GetChild("loader")
                FTween.KillTweens(render)
                loader.visible = true
            end
        end
    end
end

return cls
