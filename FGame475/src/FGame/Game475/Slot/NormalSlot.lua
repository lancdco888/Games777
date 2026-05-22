-- 老虎机普通游戏，三个格子一组转动

local Reel = Import(".Reel")
local SymbolConfig = Import(".SymbolConfig")
local BaseSlot = Import(".BaseSlot")
local MusicCfg = Import(".MusicCfg")
local ConstCfg = Import(".ConstCfg")
local Tools = Import(".Tools")
local Utils = Import(".Utils")

local NormalSlot = Class("NormalSlot", BaseSlot)


function NormalSlot:ctor(parent,game)
    local initDatas = ConstCfg.InitUIBox
    local initSymbols = Tools.InitUIBox2Symbol(initDatas)
    local x = 0
    for i = 1, FCasinoCtx.gameCfg.Reel.xCellNumber do
        local reel = Reel.New(self.bottomContainer, i, FCasinoCtx.gameCfg.Reel.yCellNumber)
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
    self.drawLines,self.animIndexs,self.wild2Indexs,self.wild3Indexs = {},{},{},{}
    self.hasHideIcon = false
    self.hasBouns = {
        false,
        false,
        false,
        false,
        false,
    }
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
    self.game:StopLines() 
    self.reelDatas = {}
    self.drawLines,self.animIndexs,self.wild2Indexs,self.wild3Indexs = {},{},{},{}
    self.hasHideIcon = false
    self.playMaskMusic = false
    self.hasBouns = {
        false,
        false,
        false,
        false,
        false,
    }
    self.isEnterFree = false
    self.isEnterTopupBouns = false
    self:CleanTimers()
end

-- @brief 设置图案数据
-- @param finishcallback 中奖线播放一轮后的回调函数
-- @param quickSet 快速设置，跳过动画
function NormalSlot:SetReelSymbolData(callback, quickSet)
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
        v:Stop(self.reelDatas[k], 
            function ()

                -- [[ 落地牌
                for i, symbolData in ipairs(self.reelDatas[k]) do
                    local cfg = SymbolConfig[symbolData.icon]
                    if cfg.LDRes then
                        local render = self.reels[k].arraySymbolDisplays[i].render
                        local DragonCircle = render:GetChild("DragonCircle")
                        if symbolData.isHide ~= 1 then
                            DragonCircle.visible = true
                            DragonCircle.playing = true
                        end
                        -- DragonCircle.visible = true
                        -- DragonCircle.playing = true
                    end
                end
                -- 落地牌 ]]
                
                if FCasinoCtx:GetGame().reelerIdxsShouldPlayScatterAudio ~= nil and Utils.itemExists(FCasinoCtx:GetGame().reelerIdxsShouldPlayScatterAudio,k) then
                    Utils.PlaySound(MusicCfg.reel_sc_stop)
                else
                    FToolSet.PlayFGUISound(MusicCfg.slots_475_reelstop)
                end
                if self.hasBouns[k] then
                    sound = sound + 1
                    FToolSet.PlayFGUISound(MusicCfg.SND_JPDoonk_normal..sound)
                end
                count = count + 1
                if count >= #self.reels then
                    self:OnReelScrollStop(self.animIndexs,self.wild2Indexs,self.wild3Indexs)
                    self:CheckHasHideIcon()
                end
            end
        , FConfig.Common:GetRellStopInterval(k))
    end

end

-- 有没有隐藏的【门】
function NormalSlot:CheckHasHideIcon()
    FCasinoCtx:SetSpinStatus(FSpinStatus.WAITING)
    if self.hasHideIcon then
        self.checkEnterOtherGameTimer = StartOnceTimer(
            function ()
                self:CheckEnterOtherGame()
                self.checkEnterOtherGameTimer = nil
            end,
            1
        )
    else
        self:CheckEnterOtherGame()
    end
end

-- 先看看有没有中免费 落地牌,再执行
function NormalSlot:CheckEnterOtherGame()
    if self.game == nil then
        return
    end
    if self.isEnterFree then
        FToolSet.PlayFGUISound(MusicCfg.feature_bell)
        self.playSoundScatterTimer = StartOnceTimer(function ()
            if self.game then
                FToolSet.PlayFGUISound(MusicCfg.SND_Scatter)
            end
            self.playSoundScatterTimer = nil
        end,2)
        self.drawLineAndCollectScoresTimer = StartOnceTimer(function ()
            if self.game then
                self:DrawLineAndCollectScores()
            end
            self.drawLineAndCollectScoresTimer = nil
        end,6)
    elseif self.isEnterTopupBouns then
        FToolSet.PlayFGUISound(MusicCfg.feature_bell)
        self.checkSoundPlayTimer = StartOnceTimer(function ()
            if self.game then
                self:CheckSoundPlay()
                self.checkSoundPlayTimer = nil
            end
        end,2)
    else
        self:CheckSoundPlay()
    end
end

function NormalSlot:CheckSoundPlay()
    local sound,time
    for _, line in ipairs(self.drawLines) do
        if line.isWild then
            sound = line.sound
            time = line.soundTime
            break
        end
        if line.sound and not sound then
            sound = line.sound
            time = line.soundTime
        end
    end
    if sound then
        FToolSet.PlayFGUISound(sound)
        self.drawLineAndCollectScoresTimer = StartOnceTimer(function ()
            if self.game then
                self:DrawLineAndCollectScores()
            end
            self.drawLineAndCollectScoresTimer = nil
        end,time)
    else
        self:DrawLineAndCollectScores()
    end
end

-- 画线 收分
function NormalSlot:DrawLineAndCollectScores()
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

function NormalSlot:SetIsEnterFree(isEnterFree)
    self.isEnterFree = isEnterFree
end

function NormalSlot:SetIsEnterTopupBouns(isEnterTopupBouns)
    self.isEnterTopupBouns = isEnterTopupBouns
end

-- 处理格子信息
function NormalSlot:HandleCellDatas(grids)
    local freeCount = 0
    -- 整理服务器数据
    local reelDatas = {}
    for k, v in pairs(grids) do
        local reelIndex = self:GetReelIndex(k) + 1
        local iconIndex = self:GetCellIndex(k) + 1
        if v.IsHide == 1 then
            self.hasHideIcon = true
        end
        if v.icon == 2 then
            self.hasBouns[reelIndex] = true
        elseif v.icon == 3 then
            freeCount = freeCount + 1
        end
        reelDatas[reelIndex] = reelDatas[reelIndex] or {}
        reelDatas[reelIndex][iconIndex] = {
            icon = v.icon,
            value = v.SymbolValue,
            isHide = v.IsHide, -- 1 是增加一个门
            type = v.SymbolType,
        }
    end
    if freeCount >= 3 then
        self.isEnterFree = true
    end
    self.reelDatas = reelDatas
end
-----处理中奖线 --------
--- drawLines: 中奖线id集合
--- animIndexs: 播放anim的 index 
--- wild2Indexs:百搭二连线 
--- wild3Indexs:百搭三连线 
--- 忽略
function NormalSlot:HandleWinDatas(lines)
    self.winCoin = 0
    if not next(lines) then
        return
    end
    local drawLines = {}
    local wildCells = {}
    local animIndexs = {}
    local winCoin = 0
    for i, line in ipairs(lines) do
        if line.lineIndex ~= 103 then -- 落地牌不算分
            winCoin = winCoin + line.winCoin
        end
        local hasWild = false
        for j, cell in ipairs(line.lineCells) do
            if cell.icon == 1 then -- 百搭 
                wildCells[cell.index] = cell
                hasWild = true
            end
            animIndexs[cell.index] = true
        end
        if line.lineIndex <= 50 and hasWild then -- 百搭中奖线
            local url = string.format(SymbolConfig[1].soundURL, math.random(1,5))
            table.insert(drawLines,{lineCells = line.lineCells, index = line.lineIndex,sound = url, isWild = true, soundTime = SymbolConfig[1].soundTime})
        end
        local isFour = #line.lineCells >= 4
        -- 普通中奖线 大于四个的且没有百搭的四连中奖
        if line.lineIndex <= 50 and isFour and not hasWild then
            table.insert(drawLines,{lineCells = line.lineCells, index = line.lineIndex,sound = SymbolConfig[line.lineCells[1].icon].fourSoundURL, soundTime = SymbolConfig[line.lineCells[1].icon].soundTime})
        end
        if line.lineIndex <= 50 and not isFour and not hasWild then
            table.insert(drawLines,{lineCells = line.lineCells, index = line.lineIndex,sound = nil})
        end
    end
    table.sort(drawLines,function (a,b)
        return a.index < b.index
    end)
    local wild2Indexs = {}
    local wild3Indexs = {}
    for cellIndex, cell in pairs(wildCells) do
        if wildCells[cellIndex + 5] then -- 一列两个百搭
            animIndexs[cellIndex + 5] = nil -- 需要把二连百搭第二行的动画取消掉
            if wildCells[cellIndex + 10] then -- 一列三个百搭
                animIndexs[cellIndex + 10] = nil -- 需要把三连百搭第三行的动画取消掉
                wild3Indexs[cellIndex] = true
            else
                if not wildCells[cellIndex - 5] then
                    wild2Indexs[cellIndex] = true
                end
            end
        end 
    end
    -- dump(drawLines,"处理中奖线:drawLines")
    -- dump(animIndexs,"处理中奖线:animIndexs")
    -- dump(wild2Indexs,"处理中奖线:wild2Indexs")
    -- dump(wild3Indexs,"处理中奖线:wild3Indexs")
    self.winCoin = winCoin
    self.drawLines,self.animIndexs,self.wild2Indexs,self.wild3Indexs = drawLines,animIndexs,wild2Indexs,wild3Indexs
end


function NormalSlot:OnReelScrollStop(animIndexs, wild2Indexs, wild3Indexs)
    local reelCfg = FCasinoCtx.gameCfg.Reel
    for index = 1, reelCfg.xCellNumber do
        -- 替换动画到顶层显示
        local arraySymbolDisplays = self.reels[index].arraySymbolDisplays
        for i = 1, reelCfg.yCellNumber do
            local display = arraySymbolDisplays[i]
            local cfg = SymbolConfig[display.data.icon]

            local logicIndex = (i - 1) * reelCfg.xCellNumber + index
            local animShow = animIndexs[logicIndex]
            local wild2Show = wild2Indexs[logicIndex]
            local wild3Show = wild3Indexs[logicIndex]
            local isLD = cfg.LDRes
            if animShow or wild2Show or wild3Show or isLD or display.data.isHide == 1 then
                local render = self:GetOrCreateTopSymbol(logicIndex)
                self:_InitTopSymbolRender(render,cfg,display)
                local func = function ()
                    if animShow or isLD then -- 普通动画效果
                        self:_PlayCommonAnim(render,cfg)
                    end
                    if wild2Show then -- 二连百搭
                        self:_PlayWild2Anim(render,cfg)
                    end
                    if wild3Show then -- 三连百搭
                        self:_PlayWild3Anim(render,cfg)
                    end
                end
                if self.hasHideIcon then
                    if not self.playMaskMusic then
                        FToolSet.PlayFGUISound(MusicCfg.SND_EndMask)
                        self.playMaskMusic = true
                    end
                    FTween.Start(render,
                        FTween.Delay(1.5, function()
                            func()
                        end)
                    )
                else
                    func()
                end
                display.render.visible = false
            end
        end
    end
end

function NormalSlot:_InitTopSymbolRender(render,cfg,display)
    local loader = render:GetChild("loader")
    loader.visible = true
    loader.url = cfg.icon
    local luodi = render:GetChild("luodi")
    luodi.visible = false
    local sc_ani_loader = render:GetChild("sc-ani-loader")
    sc_ani_loader.visible = false
    -- 数字
    local num = render:GetChild("num")
    -- 遮罩 -- todo
    local mask = render:GetChild("mask")
    mask.visible = false
    -- sprite1 
    local sprite1 = render:GetChild("sprite1")
    -- sprite2 
    -- local sprite2 = render:GetChild("sprite2")
    local wild1 = render:GetChild("wild1")
    local wild2 = render:GetChild("wild2")
    local wild3 = render:GetChild("wild3")
    wild1.visible = false
    wild2.visible = false
    wild3.visible = false
    local wild1Loop = render:GetChild("wild1_loop")
    local wild2Loop = render:GetChild("wild2_loop")
    local wild3Loop = render:GetChild("wild3_loop")
    wild1Loop.visible = false
    wild2Loop.visible = false
    wild3Loop.visible = false

    -- local DragonExplo = render:GetChild("DragonExplo")
    -- DragonExplo.visible = false
    
    local DragonCircle = render:GetChild("DragonCircle")
    DragonCircle.visible = false

    local shouldHide = display.data.isHide == 1
    local reveal = render:GetChild("reveal")
    reveal.visible = shouldHide
    if shouldHide then
        if cfg.LDRes then
            DragonCircle.visible = false
            DragonCircle.playing = false
        end
        reveal:SetPlaySettings(0,-1,1,-1,
            function ()
                reveal.visible = false
                reveal.playing = false
                reveal.frame = 0
                if cfg.LDRes then
                    DragonCircle.visible = true
                    DragonCircle.playing = true
                end
            end
        )
    end
    reveal.playing = shouldHide
    local TopupBounsbg = render:GetChild("TopupBounsbg")
    -- 落地牌效果 [[
    if cfg.LDRes then
        if shouldHide then
            DragonCircle.visible = false
            DragonCircle.playing = false
        else
            DragonCircle.visible = true
            DragonCircle.playing = true
        end

        luodi.visible = true
        local res = cfg.LDRes[display.data.type]
        num.visible = res.numShow
        sprite1.visible = res.spriteFontShow
        -- sprite2.visible = res.spriteFontShow
        if res.numShow then
            num.text = Tools.TopupBounsScoreToStr(display.data.value) 
        end
        if res.sprite1Url and res.sprite1Url ~= "" then
            sprite1.url = res.sprite1Url
        end
        TopupBounsbg.visible = true
    else
        num.visible = false
        sprite1.visible = false
        -- sprite2.visible = false
        TopupBounsbg.visible = false
    end
    -- 落地牌效果]]
end

function NormalSlot:_PlayCommonAnim(render,cfg)
    local animation = cfg.animation
    local loader = render:GetChild("loader")
    local sc_ani_loader = render:GetChild("sc-ani-loader")
    local wild1 = render:GetChild("wild1")
    local wild1Loop = render:GetChild("wild1_loop")

    if cfg.isSC then
        sc_ani_loader.visible = true
        sc_ani_loader.url = animation
    elseif animation and animation ~= "" then
        loader.url = animation
    else
        local animations = cfg.animations
        if animations then
            local animIntro = animations.animIntro
            local animLoop = animations.animLoop
            local animTime = animations.time
            loader.visible = true
            loader.url = animIntro
            FTween.Start(render,
                FTween.Delay(animTime, function()
                    loader.url = animLoop 
                end)
            )
        elseif cfg.wildRes then -- 单独的百搭
            FToolSet.PlayFGUISound(MusicCfg.SND_Wild)
            loader.visible = false
            local animIntro = cfg.wildRes[1].animIntro
            local animLoop = cfg.wildRes[1].animLoop
            wild1.visible = true
            wild1.url = animIntro
            wild1.sortingOrder = cfg.wildRes[1].zorder
            wild1Loop.visible = true
            wild1Loop.sortingOrder = cfg.wildRes[1].zorder
            FTween.Start(render,
                FTween.Delay(2, function()
                    wild1.visible = false
                    -- wild1.url = animLoop 
                    wild1Loop.url = animLoop
                end)
            )
        else
            loader.url = cfg.icon
        end
    end
end

function NormalSlot:_PlayWild2Anim(render,cfg)
    if not cfg.wildRes then
        return
    end
    FToolSet.PlayFGUISound(MusicCfg.SND_Wild)
    local loader = render:GetChild("loader")
    local wild2 = render:GetChild("wild2")
    local wild2Loop = render:GetChild("wild2_loop")
    loader.visible = false

    local animIntro = cfg.wildRes[2].animIntro
    local animLoop = cfg.wildRes[2].animLoop
    wild2.visible = true
    wild2Loop.visible = true
    wild2.url = animIntro
    wild2.sortingOrder = cfg.wildRes[2].zorder
    wild2Loop.sortingOrder = cfg.wildRes[2].zorder
    FTween.Start(render,
        FTween.Delay(2.9, function()
            wild2.visible = false
            -- wild2.url = animLoop 
            wild2Loop.url = animLoop
        end)
    )
end

function NormalSlot:_PlayWild3Anim(render,cfg)
    if not cfg.wildRes then
        return
    end
    FToolSet.PlayFGUISound(MusicCfg.SND_Wild)
    local loader = render:GetChild("loader")
    local wild3 = render:GetChild("wild3")
    local wild3Loop = render:GetChild("wild3_loop")
    loader.visible = false
    local animIntro = cfg.wildRes[3].animIntro
    local animLoop = cfg.wildRes[3].animLoop
    wild3.visible = true
    wild3Loop.visible = true
    wild3.url = animIntro
    wild3.sortingOrder = cfg.wildRes[3].zorder
    wild3Loop.sortingOrder = cfg.wildRes[3].zorder
    FTween.Start(render,
        FTween.Delay(2.9, function()
            wild3.visible = false
            -- wild3.url = animLoop 
            wild3Loop.url = animLoop
        end)
    )
end

function NormalSlot:SetOpen(isOpen)
    self.isOpen = isOpen
end

function NormalSlot:GetWinCoin()
    return self.winCoin
end

function NormalSlot:CleanTimers()
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

function NormalSlot:PlayBlinkByCells(lineCells)
    for _, cell in ipairs(lineCells) do
        local cfg = SymbolConfig[cell.icon]
        if cfg.needBlink then
            local render = self.topSymbolRenders[cell.index]
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

function NormalSlot:StopBlinkByCells(lineCells)
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
return NormalSlot