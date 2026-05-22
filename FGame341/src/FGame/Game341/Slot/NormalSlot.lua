-- 老虎机普通游戏，三个格子一组转动

local Reel = Import(".Reel")
local SymbolConfig = Import(".SymbolConfig")
local BaseSlot = Import(".BaseSlot")
local MusicCfg = Import(".MusicCfg")
local ConstCfg = Import(".ConstCfg")
local Tools = Import(".Tools")

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
    self.drawLines,self.animIndexs = {},{}
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
    self.drawLines,self.animIndexs = {},{}
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
                if self.hasBouns[k] then
                    sound = sound + 1
                    FToolSet.PlayFGUISound(MusicCfg.SND_JPDoonk..sound)
                end
                count = count + 1
                FToolSet.PlayFGUISound(MusicCfg.reel_clink..count)
                if count >= #self.reels then
                    self:OnReelScrollStop(self.animIndexs)
                    self:CheckEnterOtherGame()
                end
            end
        , FConfig.Common:GetRellStopInterval(k))
    end
end

-- 先看看有没有中免费 落地牌,再执行
function NormalSlot:CheckEnterOtherGame()
    FCasinoCtx:SetSpinStatus(FSpinStatus.WAITING)
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
        if v.icon == ConstCfg.TopupBounsIndex then
            self.hasBouns[reelIndex] = true
        elseif v.icon == ConstCfg.FreeIndex then
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
        if line.lineIndex ~= 102 then -- 落地牌不算分
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
        if line.lineIndex <= 88 and hasWild then -- 百搭中奖线
            local url = SymbolConfig[1].soundURL
            table.insert(drawLines,{lineCells = line.lineCells, index = line.lineIndex,sound = url, isWild = true, soundTime = SymbolConfig[1].soundTime})
        end
        local isFour = #line.lineCells >= 4
        -- 普通中奖线 大于四个的且没有百搭的四连中奖
        if line.lineIndex <= 88 and isFour and not hasWild then
            table.insert(drawLines,{lineCells = line.lineCells, index = line.lineIndex,sound = SymbolConfig[line.lineCells[1].icon].fourSoundURL, soundTime = SymbolConfig[line.lineCells[1].icon].soundTime})
        end
        if line.lineIndex <= 88 and not isFour and not hasWild then
            table.insert(drawLines,{lineCells = line.lineCells, index = line.lineIndex,sound = nil})
        end

    end
    self.winCoin = winCoin
    self.drawLines,self.animIndexs = drawLines,animIndexs
end


function NormalSlot:OnReelScrollStop(animIndexs)
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
            if animShow or isLD then
                local render = self:GetOrCreateTopSymbol(logicIndex)
                self:_InitTopSymbolRender(render,cfg,display)
                -- if animShow or isLD then -- 普通动画效果
                --     self:_PlayCommonAnim(render,cfg)
                -- end
                display.render.visible = false
            end
        end
    end
end

function NormalSlot:_InitTopSymbolRender(render,cfg,display)
    local loader = render:GetChild("loader")
    if cfg.url then
        if cfg.animUrl then
            loader.url = cfg.animUrl
            loader.playing = true
        else
            loader.url = cfg.url
        end
    else
        loader.visible = false
    end
    if cfg.scale then
        loader.scale = cfg.scale 
    else
        loader.scale = vec2(1,1)
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

    if cfg.nodeNames then
        local nodeName = cfg.nodeNames.Intro
        for _, name in pairs(SymbolConfig.name) do
            local node = render:GetChild(name)
            if nodeName and name == nodeName then
                Tools.PlayOnceAnim(node,false,function ()
                    local nodeLoop = render:GetChild(cfg.nodeNames.Loop)
                    nodeLoop.visible = true
                    nodeLoop.playing = true
                end)
            else
                node.visible = false
            end
        end
    end
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