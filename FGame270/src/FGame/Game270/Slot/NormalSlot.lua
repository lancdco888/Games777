-- 老虎机普通游戏，三个格子一组转动
local Reel = Import(".Reel")
local SymbolConfig = Import(".SymbolConfig")
local BaseSlot = Import(".BaseSlot")
local MusicCfg = Import(".MusicCfg")
local ConstCfg = Import(".ConstCfg")
local Tools = Import(".Tools")
local Help = Import(".Help")

local cls = Class("NormalSlot", BaseSlot)

function cls:ctor(parent, game)
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
    self.drawLines, self.animIndexs, self.wild2Indexs, self.wild3Indexs = {}, {}, {}, {}
    self.wildFreeShow = {}
    self.hasBouns = {
        false,
        false,
        false,
        false,
        false
    }
end

function cls:__delete()
    self:CleanTimers()
end

-- @brief 滚动开始
function cls:SpinStart()
    -- spin按钮置为等待状态
    FCasinoCtx:SetSpinStatus(FSpinStatus.WAITING)
    -- 转轴开始滚动
    for k, v in pairs(self.reels) do
        v:SpinForever()
    end
    self:ResetState()
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
    self.hasBouns = {
        false,
        false,
        false,
        false,
        false
    }
    self.isEnterFree = false
    self.isEnterTopupBouns = false
    self:CleanTimers()
end

-- @brief 设置图案数据
-- @param finishcallback 中奖线播放一轮后的回调函数
-- @param quickSet 快速设置，跳过动画
function cls:SetReelSymbolData(callback, quickSet)
    self.onFinishCallback = callback
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
    local sound = 0
    for k, v in pairs(self.reels) do
        v.OnBounceStartCallBack = function()
            if self.hasBouns[k] then
                sound = sound + 1
                if quickSet then
                    if #self.reels == sound then
                        FToolSet.PlayFGUISound(MusicCfg.SND_JPDoonk .. sound)
                    end
                else
                    FToolSet.PlayFGUISound(MusicCfg.SND_JPDoonk .. sound)
                end
            end
        end

        v:Stop(self.reelDatas[k], function()
            local displays = self.reels[k].arraySymbolDisplays
            for iconIndex, render in pairs(displays) do
                render.render:GetChild("DragonCircle").visible = Tools.IsJpCard(render.data.icon)
            end

            count = count + 1
            if count >= #self.reels then
                self:CheckEnterOtherGame(function()
                    self:OnReelScrollStop(self.animIndexs, self.wild2Indexs, self.wild3Indexs)
                end)
            end
        end, FConfig.Common:GetRellStopInterval(k))
    end
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
    local wildPlay = {}
    --  FToolSet.PlayFGUISound(SymbolConfig[1].soundURLNoWin)
    if Tools.IsFreeGameMode(self.game) then
        for _, v in pairs(self.wildFreeShow) do
            wildPlay[v.val + 1] = true
        end

        if wildPlay[1] ~= nil then
            FToolSet.PlayFGUISound(SymbolConfig[1].soundURLNoWin)
        end
        if wildPlay[2] ~= nil then
            FToolSet.PlayFGUISound(SymbolConfig[1].soundURLWin)
        end
    end

    for _, line in ipairs(self.drawLines) do
        if line.sound then
            FToolSet.PlayFGUISound(line.sound)
            local time = line.soundTime
            self.drawLineAndCollectScoresTimer = StartOnceTimer(
                function()
                    if self.game then
                        self:DrawLineAndCollectScores()
                    end
                    self.drawLineAndCollectScoresTimer = nil
                end,
                time
            )
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

function cls:SetIsEnterFree(isEnterFree)
    self.isEnterFree = isEnterFree
end

function cls:SetIsEnterTopupBouns(isEnterTopupBouns)
    self.isEnterTopupBouns = isEnterTopupBouns
end

-- 处理格子信息
function cls:HandleCellDatas(grids)
    local freeCount = 0
    -- 整理服务器数据
    local reelDatas = {}

    local bounsCount = {}
    for k, v in pairs(grids) do
        local reelIndex = self:GetReelIndex(k) + 1
        local iconIndex = self:GetCellIndex(k) + 1

        if v.icon == 3 then
            if bounsCount[reelIndex] == nil then
                bounsCount[reelIndex] = 0
            end
            bounsCount[reelIndex] = bounsCount[reelIndex] + 1
        elseif v.icon == 2 then
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
                self.hasBouns[reelIndex] = true
            end
        end
    end
    self.reelDatas = reelDatas
end

-----处理中奖线 --------
--- drawLines: 中奖线id集合
--- animIndexs: 播放anim的 index
--- wild2Indexs:百搭二连线
--- wild3Indexs:百搭三连线
--- 忽略
function cls:HandleWinDatas(lines)
    self.winCoin = 0
    if not next(lines) then
        return
    end

    local drawLines = {}
    local wildCells = {}
    local animIndexs = {}
    local winCoin = 0
    for i, line in ipairs(lines) do
        if not Tools.IsScLine(line.lineIndex) then
            -- 落地牌不算分
            winCoin = winCoin + line.winCoin
        end

        local hasWild = false

        for j, cell in ipairs(line.lineCells) do
            if cell.icon == 1 then
                -- 百搭
                wildCells[cell.index] = cell
                hasWild = true
            end
            animIndexs[cell.index] = true
        end

        if line.lineIndex <= 50 and hasWild then
            local url = SymbolConfig[1].soundURL
            local stime = SymbolConfig[1].soundTime
            table.insert(drawLines,
                { lineCells = line.lineCells, index = line.lineIndex, sound = url, isWild = true, soundTime = stime })
        end

        local isFour = #line.lineCells >= 4
        -- 普通中奖线 大于四个的且没有百搭的四连中奖
        if line.lineIndex <= 50 and isFour and not hasWild then
            local url = SymbolConfig[line.lineCells[1].icon].fourSoundURL
            if Tools.IsFreeGameMode(self.game) then
                url = nil
            end
            table.insert(drawLines, {
                lineCells = line.lineCells,
                index = line.lineIndex,
                sound = url,
                soundTime = SymbolConfig[line.lineCells[1].icon].soundTime
            })
        end
        if line.lineIndex <= 50 and not isFour and not hasWild then
            table.insert(drawLines, { lineCells = line.lineCells, index = line.lineIndex, sound = nil })
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
    --dump(drawLines, "处理中奖线:drawLines")
    -- dump(animIndexs,"处理中奖线:animIndexs")
    -- dump(wild2Indexs,"处理中奖线:wild2Indexs")
    -- dump(wild3Indexs,"处理中奖线:wild3Indexs")
    self.winCoin = winCoin
    self.drawLines, self.animIndexs, self.wild2Indexs, self.wild3Indexs = drawLines, animIndexs, wild2Indexs, wild3Indexs
end

-- 处理免费模式百搭数据
function cls:HandleFreeWildData(grids, lines)
    local wildIconIndex = {} --找出所有百搭牌index
    for _, val in ipairs(grids) do
        if val.icon == 1 then
            wildIconIndex[val.index] = 0
        end
    end


    -- 找出所有中奖的列
    for _, cells in ipairs(lines) do
        for _, val in ipairs(cells.lineCells) do
            if val.icon == 1 and wildIconIndex[val.index] then
                wildIconIndex[val.index] = 1
            end
        end
    end
    local lineIndex = {}

    for key, val in pairs(wildIconIndex) do
        local v = key % 5
        if v == 0 then
            v = 5
        end
        if lineIndex[v] ~= nil then
            if lineIndex[v] ~= 1 then
                lineIndex[v].val = val
            end
        else
            lineIndex[v] = {
                pos = math.floor((key - 1) / 5),
                val = val
            }
        end
    end
    self.wildFreeShow = lineIndex
end

function cls:OnReelScrollStop(animIndexs, wild2Indexs, wild3Indexs)
    local reelCfg = FCasinoCtx.gameCfg.Reel
    for index = 1, reelCfg.xCellNumber do
        -- 替换动画到顶层显示
        local arraySymbolDisplays = self.reels[index].arraySymbolDisplays
        for i = 1, reelCfg.yCellNumber do
            local display = arraySymbolDisplays[i]
            local cfg = SymbolConfig[display.data.icon]

            local logicIndex = (i - 1) * reelCfg.xCellNumber + index
            local animShow = animIndexs[logicIndex]
            local isLD = cfg.LDRes
            local wild2Show = wild2Indexs[logicIndex]
            local wild3Show = wild3Indexs[logicIndex]
            local wildFreeShow = nil
            if self.wildFreeShow[logicIndex] ~= nil then
                wildFreeShow = self.wildFreeShow[logicIndex]
            end
            local cell = (logicIndex - 1) % 5 + 1

            if self.wildFreeShow[cell] ~= nil and Tools.IsFreeGameMode(self.game) then
                if wildFreeShow then
                    local render = self:GetOrCreateTopSymbol(logicIndex)
                    self:_InitTopSymbolRender(render, cfg, display, logicIndex)
                    wildFreeShow.use = true
                    self:_PlayWildFree(render, wildFreeShow)
                end
            else
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
end

function cls:_InitTopSymbolRender(render, cfg, display, index)
    Tools.HideSymbolChildren(render)

    if cfg.icon:sub(1, 5) ~= "ui://" then
        local node = render:GetChild(cfg.icon)
        node.visible = true
    else
        local loader = render:GetChild("loader")
        loader.visible = true
        loader.url = cfg.icon
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
    wild2.visible = false
    wild3.visible = false

    local DragonExplo = render:GetChild("DragonExplo")
    DragonExplo.visible = false

    local DragonCircle = render:GetChild("DragonCircle")
    local TopupBounsbg = render:GetChild("TopupBounsbg")

    DragonCircle.visible = Tools.IsJpCard(display.data.icon)
    TopupBounsbg.visible = Tools.IsJpCard(display.data.icon)

    -- 落地牌效果 [[
    if cfg.LDRes then
        local res = cfg.LDRes[display.data.type]
        num.visible = res.numShow
        sprite1.visible = res.spriteFontShow
        sprite2.visible = res.spriteFontShow

        if res.numShow then
            num.text = Tools.TopupBounsScoreToStr(display.data.value)
            local isBig = false
            if Tools.IsFreeGameMode(self.game) and index == 8 then
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

function cls:_PlayCommonAnim(render, cfg)
    Tools.HideSymbolChildren(render)

    local animation = cfg.animation
    local loader = render:GetChild("loader")
    local wild1 = render:GetChild("wild1")

    print("play Animation ", cfg.animation)
    if animation and animation ~= "" then
        if Tools.IsNodeConfig(animation) then
            local node = render:GetChild(animation)
            node.visible = true
            loader.visible = false
        else
            loader.visible = true
            loader.url = animation
        end
    else
        local animations = cfg.animations
        if animations then
            local animIntro = animations.animIntro
            local animLoop = animations.animLoop

            local animLoopCb = function()
                if Tools.IsNodeConfig(animLoop) then
                    local animIntro = render:GetChild(animIntro)
                    animIntro.visible = false
                    local node = render:GetChild(animLoop)
                    node.visible = true
                    loader.visible = false
                else
                    loader.visible = true
                    loader.url = animLoop
                end
            end

            if Tools.IsNodeConfig(animIntro) then
                local node = render:GetChild(animIntro)
                node.visible = true
                loader.visible = false
            else
                loader.visible = true
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
                FTween.Start(render, FTween.Delay(1, function()
                    wild1.url = animLoop
                end))
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

function cls:_PlayWildFree(render, cfg)
    local loader = render:GetChild("loader")
    local wild3 = render:GetChild("wild3")
    loader.visible = false

    local dict = { "Top", "Middle", "Bottom" }
    local intro = "ui://Game346/Wild_3UP_"

    intro = intro .. dict[cfg.pos + 1]

    if cfg.val == 0 then
        intro = intro .. "_NoWin"
    end

    wild3.playing = true
    wild3.frame = 0
    wild3.visible = true
    wild3.url = intro
    wild3.sortingOrder = 199

    if cfg.val == 1 then
        wild3.movieClip:SetPlaySettings(0, -1, 1, -1, function()
            wild3.url = "ui://Game346/Wild3UP_Loop"
            wild3.movieClip:SetPlaySettings(0, -1, 0, -1)
            wild3.playing = true
        end)
    else
        wild3.movieClip:SetPlaySettings(0, -1, 1, -1, function()
            wild3.playing = false
            wild3.frame = 30
        end)
    end
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
    wild3.playing = true

    wild3.movieClip:SetPlaySettings(0, -1, 1, -1, function()
        wild3.url = animLoop
        wild3.movieClip:SetPlaySettings(0, -1, 0, -1)
        wild3.playing = true
    end)
end

function cls:SetOpen(isOpen)
    self.isOpen = isOpen
end

function cls:GetWinCoin()
    return self.winCoin
end

function cls:CleanTimers()
    if self.checkEnterOtherGameTimer then
        StopTimer(self.checkEnterOtherGameTimer)
        self.checkEnterOtherGameTimer = nil
    end

    if self.playSoundScatterTimer then
        StopTimer(self.playSoundScatterTimer)
        self.playSoundScatterTimer = nil
    end

    if self.drawLineAndCollectScoresTimer then
        StopTimer(self.drawLineAndCollectScoresTimer)
        self.drawLineAndCollectScoresTimer = nil
    end

    if self.checkSoundPlayTimer then
        StopTimer(self.checkSoundPlayTimer)
        self.checkSoundPlayTimer = nil
    end
end

function cls:PlayBlinkByCells(lineCells)
    for _, cell in ipairs(lineCells) do
        local cfg = SymbolConfig[cell.icon]
        if cfg.needBlink then
            local render = self.topSymbolRenders[cell.index]
            if render then
                local visible = true
                local loader = render:GetChild("loader")
                loader.visible = visible
                FTween.Start(render, FTween.RepeatForever({
                    FTween.Delay(0.5, function()
                        visible = not visible
                        loader.visible = visible
                    end)
                }))
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
