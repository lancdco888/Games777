-- 老虎机普通游戏，三个格子一组转动
local Utils = Import(".Utils")
local Reel = Import(".Reel")
local SymbolConfig = Import(".SymbolConfig")
local BaseSlot = Import(".BaseSlot")

local MusicCfg = Import(".MusicCfg")

local NormalSlot = Class("NormalSlot", BaseSlot)
--自定义图形数据
local initicondata = {
    {5,9,11},
    {9,7,10},
    {7,10,6},
    {11,5,10},
    {6,12,3},
}
function NormalSlot:ctor(parent,game)
    local x = 0
    for i = 1, FCasinoCtx.gameCfg.Reel.xCellNumber do
        --初始化自定义图形
        local data = {}
        for j = 1, 3 do
            table.insert(data,{icon = initicondata[i][j],isHide = 0,type = 0,value = 0})
        end
        local reel = Reel.New(self.bottomContainer, i, FCasinoCtx.gameCfg.Reel.yCellNumber)
        reel:InitSymbol(data)
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
end
function NormalSlot:InitIcondata()
    local grids = {}
    for i = 1, 3 do
        --初始化自定义图形
        for j = 1, FCasinoCtx.gameCfg.Reel.xCellNumber do
            table.insert(grids,{icon = initicondata[j][i],lottyType = 0,lottyValue = 0})
        end
    end
    self:HandleCellDatas(grids)
    self:SetReelSymbolData(function () end,true)
end
-- @brief 滚动开始
function NormalSlot:SpinStart()
    -- spin按钮置为等待状态
    FCasinoCtx:SetSpinStatus(FSpinStatus.STOP)
    -- 转轴开始滚动
    for k, v in pairs(self.reels) do
        v:SpinForever()
    end
    -- 删除顶部图案
    self:RemoveTopSymbol()

    -- 隐藏中奖线
    self.game:StopLines() 
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
    self.isEnterFree = false
    self.isEnterTopupBouns = false
end

-- @brief 设置图案数据
-- @param quickSet 快速设置，跳过动画
function NormalSlot:SetReelSymbolData(callback, quickSet,allwinCoin)
    self.onFinishCallback = callback
    
    -- 设置最终停止数据 跳过动画
    if quickSet then
        for k, v in pairs(self.reels) do
            v:SetOpen(self.isOpen)
            v:Stop(self.reelDatas[k])
        end
        --FCasinoCtx:SetSpinStatus(FSpinStatus.SPIN)
        if self.onFinishCallback then
            self.onFinishCallback()
            self.onFinishCallback = nil
        end
        if allwinCoin then
            self.game:ShowBottomWin(true,allwinCoin)
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
                FToolSet.PlayFGUISound(MusicCfg.slots_336_reelstop)
                if self.hasBouns[k] then
                    sound = sound + 1
                    FToolSet.PlayFGUISound(MusicCfg.SND_HandSDoonk..sound)
                end
                count = count + 1
                if count >= #self.reels then
                   self:CheckEnterOtherGame()
                   --self:OnReelScrollStop(self.animIndexs,self.wild2Indexs,self.wild3Indexs)
                end
            end
        , FConfig.Common:GetRellStopInterval(k))
    end

end

-- 先看看有没有中免费 落地牌,再执行
function NormalSlot:CheckEnterOtherGame()
    FCasinoCtx:SetSpinStatus(FSpinStatus.WAITING)
    if self.onFinishCallback then
        self.onFinishCallback()
        self.onFinishCallback = nil
    end
    -- if self.game == nil then
    --     return
    -- end
    -- if self.isEnterFree then
    --     FToolSet.PlayFGUISound(MusicCfg.feature_bell)
    --     StartOnceTimer(function ()
    --         if self.game then
    --             FToolSet.PlayFGUISound(MusicCfg.SND_Scatter)
    --         end
    --     end,2)
    --     StartOnceTimer(function ()
    --         if self.game then
    --             self:DrawLineAndCollectScores()
    --         end
    --     end,6)
    -- elseif self.isEnterTopupBouns then
    --     FToolSet.PlayFGUISound(MusicCfg.feature_bell)
    --     StartOnceTimer(function ()
    --         if self.game then
    --             self:CheckSoundPlay()
    --         end
    --     end,2)
    -- else
    --     self:CheckSoundPlay()
    -- end
end
function NormalSlot:CheckSoundPlay()
    for _, line in ipairs(self.drawLines) do
        if line.sound then
            print("line.sound********,line.sound")
            FToolSet.PlayFGUISound(line.sound)
            local time = line.soundTime
            StartOnceTimer(function ()
                if self.game then
                    self:DrawLineAndCollectScores()
                end
            end,time)
            return 
        end
    end
    self:DrawLineAndCollectScores()

end
-- 画线 收分
function NormalSlot:DrawLineAndCollectScores(isfreeover)
    self.game:PlayLines(self.drawLines)
    local second = 0
    if not isfreeover then
        second = self.game:ShowBottomWin()
    end
    self:OnReelScrollStop(self.animIndexs,self.wild2Indexs,self.wild3Indexs)
    return second
    -- if #self.drawLines > 0 then
    --     FCasinoCtx:SetSpinStatus(second > 0 and FSpinStatus.STOP or FSpinStatus.SPIN)
    --     if self.onFinishCallback then
    --         self.onFinishCallback(second)
    --         self.onFinishCallback = nil
    --     end
    -- else
    --     -- 延迟防止快速点击旋转
    --     StartOnceTimer(function ()
    --         if self.game then
    --             FCasinoCtx:SetSpinStatus(self.isEnterFree and FSpinStatus.STOP or FSpinStatus.SPIN)
    --             if self.onFinishCallback then
    --                 self.onFinishCallback(second)
    --                 self.onFinishCallback = nil
    --             end
    --         end
    --     end,0.8)
    -- end
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
    local denglongcount = 0
    for k, v in pairs(grids) do
        local reelIndex = self:GetReelIndex(k) + 1
        local iconIndex = self:GetCellIndex(k) + 1
        if v.IsHide == 1 then
            self.hasHideIcon = true
        end
        --计算每一列的总灯笼个数 
        if  k <= 5 then
            for i = 1, 3 do
                if grids[k+5*(i-1)].icon == 2 then
                    denglongcount = denglongcount + 1
                end
            end
        end
        if v.icon == 2 then
            --denglongcount = denglongcount + 1
            --前三列出现灯笼响应特殊音效
            if reelIndex <= 3 then
                self.hasBouns[reelIndex] = true
            --后两列出现灯笼根据灯笼个数是否响
            elseif reelIndex == 4 then
                if denglongcount >= 3 then
                    self.hasBouns[reelIndex] = true
                end
            elseif reelIndex == 5 then
                if denglongcount >= 6 then
                    self.hasBouns[reelIndex] = true
                end
            end
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
        if line.lineIndex <= 25 and hasWild then
            local url = string.format(SymbolConfig[1].soundURL, math.random(1,5))
            table.insert(drawLines,1,{index = line.lineIndex,sound = url, isWild = true})
        end
        local isFour = false
        -- 普通中奖线 大于四个的且没有百搭的四连中奖
        if line.lineIndex <= 25 and #line.lineCells >= 4 and not hasWild then
            isFour = true
            if drawLines[1] and drawLines[1].isWild then
                table.insert(drawLines,{index = line.lineIndex,sound = nil})
            else
                table.insert(drawLines,1,{index = line.lineIndex,sound = SymbolConfig[line.lineCells[1].icon].fourSoundURL})
            end
        end
        if line.lineIndex <= 25 and not isFour and not hasWild then
            table.insert(drawLines,{index = line.lineIndex,sound = nil})
        end
    end
    local wild2Indexs = {}
    local wild3Indexs = {}
    if FCasinoCtx.curGameMode == FGameMode.NORMAL then
        for cellIndex, cell in pairs(wildCells) do
            if wildCells[cellIndex + 5] then -- 一列两个百搭
                animIndexs[cellIndex] = nil 
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
                    FToolSet.PlayFGUISound(MusicCfg.SND_EndMask)
                    FTween.Start(render,
                        FTween.Delay(1, function()
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
    if cfg.loaderScale then
        loader.scale = cfg.loaderScale
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
    local sprite3 = render:GetChild("sprite3")
    sprite3.visible = false
    local wild1 = render:GetChild("wild1")
    local wild2 = render:GetChild("wild2")
    local wild3 = render:GetChild("wild3")
    local TopupBounsbg =  render:GetChild("TopupBounsbg")
    wild1.visible = false
    wild2.visible = false
    wild3.visible = false

    local DragonExplo = render:GetChild("DragonExplo")
    DragonExplo.visible = false
    
    local DragonCircle = render:GetChild("DragonCircle")
    DragonCircle.visible = false
   

    -- local reveal = render:GetChild("reveal")
    -- reveal.visible = display.data.isHide == 1
    -- reveal:SetPlaySettings(0,-1,1,-1,
    --     function ()
    --         reveal.visible = false
    --         reveal.playing = false
    --         reveal.frame = 0
    --     end
    -- )
    -- reveal.playing = display.data.isHide == 1

    -- 落地牌效果 [[
    if cfg.LDRes then
        local res = cfg.LDRes[display.data.type]
        num.visible = res.numShow
        sprite1.visible = res.spriteFontShow
        sprite2.visible = res.spriteFontShow
        if res.numShow then
            num.text = Utils.TopupBounsScoreToStr(display.data.value)
           -- num.text = FToolSet.NumToStr(display.data.value)
        end
        if res.sprite1Url and res.sprite1Url ~= "" then
            sprite1.url = res.sprite1Url
        end
        if res.sprite2Url and res.sprite2Url ~= "" then
            sprite2.url = res.sprite2Url
        end
        TopupBounsbg.visible = true

    else
        num.visible = false
        sprite1.visible = false
        sprite2.visible = false
        TopupBounsbg.visible = false

    end
    -- 落地牌效果]]
end

function NormalSlot:_PlayCommonAnim(render,cfg)
    local animation = cfg.animation
    local loader = render:GetChild("loader")
    local wild1 = render:GetChild("wild1")
    local wildbet2 = render:GetChild("wildbet2")
    local sprite3 = render:GetChild("sprite3")
    loader.x, loader.y= 0,0
    if cfg.loaderScale then
        loader.scale = cfg.loaderScale
    else
        loader.scale = vec2(1,1)
    end
    --数字图片大小位置优化
    if cfg.index then
        loader.x = 194 * (1 - loader.scale.x) /2
        loader.y = 144 * (1 - loader.scale.y) /2
    end
    if animation ~= "" then
        loader.url = animation
        if cfg.animScale then
            loader.scale = cfg.animScale
        else
            loader.scale = vec2(1,1)
        end
        if cfg.animPosition then
            loader.x = cfg.animPosition.x
            loader.y = cfg.animPosition.y
        end
    else
        if cfg.wildRes then -- 单独的百搭
            print("播放单独的百搭")
            loader.visible = false
            local animIntro = cfg.wildRes[1].animIntro
            local animLoop = cfg.wildRes[1].animLoop
            wild1.visible = true
            wild1.url = animIntro
            wild1.sortingOrder = cfg.wildRes[1].zorder
            FTween.Start(wild1,
                FTween.Delay(2, function()
                    wild1.url = animLoop 
                end)
            )
            if FCasinoCtx.curGameMode == FGameMode.FREE then
                print("播放动画")
                sprite3.visible = false
                wildbet2.visible = true
                wildbet2.url = "ui://Game336/Wild_x2_00000"
                wildbet2.sortingOrder = 101
            end
        else
            print("播放闪烁动画")
            loader.url = cfg.icon
            local visible = true
            -- Blink 动画
            FTween.Start(loader,
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

function NormalSlot:_PlayWild2Anim(render,cfg)
    local loader = render:GetChild("loader")
    local wild2 = render:GetChild("wild2")
    loader.visible = false
    local animIntro = cfg.wildRes[2].animIntro
    local animLoop = cfg.wildRes[2].animLoop
    wild2.visible = true
    wild2.url = animIntro
    wild2.sortingOrder = cfg.wildRes[2].zorder
    FTween.Start(wild2,
        FTween.Delay(0.6, function()
            wild2.url = animLoop 
        end)
    )
end

function NormalSlot:_PlayWild3Anim(render,cfg)
    local loader = render:GetChild("loader")
    local wild3 = render:GetChild("wild3")
    loader.visible = false
    local animIntro = cfg.wildRes[3].animIntro
    local animLoop = cfg.wildRes[3].animLoop
    wild3.visible = true
    wild3.url = animIntro
    wild3.sortingOrder = cfg.wildRes[3].zorder
    FTween.Start(wild3,
        FTween.Delay(0.6, function()
            wild3.url = animLoop 
        end)
    )
end

function NormalSlot:SetOpen(isOpen)
    self.isOpen = isOpen
end

function NormalSlot:GetWinCoin()
    return self.winCoin
end
return NormalSlot