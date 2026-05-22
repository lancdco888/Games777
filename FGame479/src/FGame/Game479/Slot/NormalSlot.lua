-- 老虎机普通游戏，三个格子一组转动
local Utils = Import(".Utils")
local Reel = Import(".Reel")
local SymbolConfig = Import(".SymbolConfig")
local BaseSlot = Import(".BaseSlot")

local MusicCfg = Import(".MusicCfg")

local NormalSlot = Class("NormalSlot", BaseSlot)
--自定义图形数据
local initicondata = {
    { 3, 8, 4},
    { 1, 2, 11 },
    { 3, 2, 3 },
    { 8, 2, 2 }, -- {8,7,1},
    { 4, 1, 2 }, --{2,7,5},
}
local freeicon,wildicon,jpicon = 11,10,12
function NormalSlot:ctor(parent, game)
    Reel.isspecial = false
    local x = 0
    for i = 1, FCasinoCtx.gameCfg.Reel.xCellNumber do
        --初始化自定义图形
        local data = {}
        for j = 1, FCasinoCtx.gameCfg.Reel.yCellNumber do
            table.insert(data, { icon = initicondata[i][j], type = 0, lottyValue = 0 })
        end
        local reel = Reel.New(self.bottomContainer, i, FCasinoCtx.gameCfg.Reel.yCellNumber)
        reel:InitSymbol(data)
        reel:SetMask(false)
        reel.reelContainer.x = x
        self.reels[i] = reel

        -- 单列格子宽度
        x = x + reel.cfg.reelWidth
        -- 每列间距
        x = x + reel.cfg.reelSpace
    end

    self.reelDatas = {}
    self.hasHideIcon = false
    self.hasBouns = {
        false,
        false,
        false,
        false,
        false,
    }
    self.topupBounsCount = 0
    --全列播放动画类型
    self.allwildanimtype = {}
    --第2列和第3列是否有免费图标 有则加速旋转
    self.addForueDelayTime = 0
    
    --得到大图展现数据
    self._freeGameBigIconWinData =  { {}, {}, {},  {}, {}, }
    self._freeGameIconType = 0
    self.blickanimlist = {}
end

function NormalSlot:__delete()
    self:StopShowLine()
end

function NormalSlot:InitIcondata()
    local grids = {}
    for i = 1, FCasinoCtx.gameCfg.Reel.yCellNumber do
        --初始化自定义图形
        for j = 1, FCasinoCtx.gameCfg.Reel.xCellNumber do
            table.insert(grids, { icon = initicondata[j][i], backinfos = 0, index = (i-1)*5 + j })
        end
    end
    self:HandleCellDatas(grids)
    self:SetReelSymbolData(function() end, true)
end

-- @brief 滚动开始
function NormalSlot:SpinStart()
    Reel.isspecial = false
    -- spin按钮置为等待状态
    FCasinoCtx:SetSpinStatus(FSpinStatus.WAITING)
    -- 转轴开始滚动
    for k, v in pairs(self.reels) do
        v:SpinForever()
    end
    -- 删除顶部图案
    self:RemoveTopSymbol()

    -- 隐藏中奖线
    self.reelDatas = {}
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
    
    self:StopShowLine()
    Reel.iswildtype = 0
end

-- @brief 设置图案数据
-- @param quickSet 快速设置，跳过动画
function NormalSlot:SetReelSymbolData(callback, quickSet, allwinCoin)
    self.onFinishCallback = callback

    -- 设置最终停止数据 跳过动画
    if quickSet then
        Reel.isspecial = false
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
            self.game:ShowBottomWin(true, allwinCoin)
        end
        return
    end
    --收到回包切换按钮状态
    FCasinoCtx:SetSpinStatus(FSpinStatus.STOP)
    -- 设置最终停止数据
    local count = 0
    local jpsound = 0
    local addtime = 1.6
    for k, v in pairs(self.reels) do
        local delaytime = 0.5 * (k - 1)
        if self.game.startReel_count > 0 and k >= self.game.startReel_count then
            delaytime = delaytime + addtime
            addtime = addtime +1.6
        end
        print("delaytime", delaytime)
        v:Stop(self.reelDatas[k],
            function()
                if self:ExistFreeIcon(k) then
                    FToolSet.PlayFGUISound(MusicCfg.slots_479_reelFreestop)
                elseif self:ExistJpIcon(k) > 0 then
                    FToolSet.PlayFGUISound(string.format(MusicCfg.slots_479_reelJp,(k)))
                else
                    FToolSet.PlayFGUISound(MusicCfg.slots_479_reelstop)
                end
                count = count + 1
                --彩金预警弹窗动画
                if self.game.startReel_count > 0 and k >= self.game.startReel_count - 1  then
                    for _, value in pairs(self.game.tingpaianimarr) do
                        value.visible = false
                    end
                    if k < 5 then
                        FToolSet.PlayFGUISound(MusicCfg.slots_479_reelfast)
                        self.game.tingpaianimarr[k].visible = true
                    end
                end
                if count >= #self.reels then
                    self.game.startReel_count = 0
                    self:SpinEndCallFunc()
                end
            end
            , delaytime)
    end
end
--是否播放音效
function NormalSlot:can_playmusic(index,musicData)
	local isplay = false
	if index < 4 then
		isplay = true
	elseif musicData >= 2 and index == 4 then
		isplay = true
	elseif index == 5 and musicData >= 3 then
		isplay = true
	end
    if self.isEnterFree then
        isplay = true
        if musicData <= 1 and index == 5  then
            isplay = false
        end  
    end
	return isplay
end

-- 旋转结束处理
function NormalSlot:SpinEndCallFunc()
    print("所有格子旋转结束")
    FCasinoCtx:SetSpinStatus(FSpinStatus.WAITING)
    local func = function ()
        if self.onFinishCallback then
            self.onFinishCallback()
            self.onFinishCallback = nil
        end
    end
    func()
end


-- 画线 收分
function NormalSlot:DrawLineAndCollectScores(isfreeover)
    --显示下方滚动收分
    local second = 0
    self:ShowLines()
    if not isfreeover then
        second = self.game:ShowBottomWin()
    end
    --（依次闪烁的动画）
    return second
end

function NormalSlot:SetIsEnterFree(isEnterFree)
    self.isEnterFree = isEnterFree
    Reel.isInfree = isEnterFree
end

function NormalSlot:SetFreeIconType(freeicotype)
    self.game.freetype = freeicotype
    Reel.freeicotype = freeicotype == 0 and 0 or freeicotype + 13
end
-- 处理格子信息
function NormalSlot:HandleCellDatas(grids)
    local freeCount = 0
    self.topupBounsCount = 0
    self.allwildanimtype = {}
    self.addForueDelayTime = 0
    self.game.Jpwinicon = {}
    self.game.freeIconInfo = {}
    
    local bigcount = {{},{},{},{},{}}
    -- 整理服务器数据
    local reelDatas = {}
    local freeaddtime = 0
    for k, v in pairs(grids) do
        local reelIndex = self:GetReelIndex(k) + 1
        local iconIndex = self:GetCellIndex(k) + 1
        reelDatas[reelIndex] = reelDatas[reelIndex] or {}
        if v.icon == freeicon then
            table.insert(self.game.freeIconInfo,{index = v.index,icon = v.icon})
        end
        if v.icon == jpicon then
            table.insert(self.game.Jpwinicon,{index = v.index,icon = v.icon})
        end
        reelDatas[reelIndex][iconIndex] = {
            icon = v.icon,
            index = v.index,
            type = v.backinfos
        }
    end
    if freeCount >= 3 then
        self.isEnterFree = true
    end
    self.reelDatas = reelDatas
end
function NormalSlot:AssDistance()
    self.game.startReel_count = 0--从第几个转轮开始加距离
    local jpcount = 0
    for i = 1, FCasinoCtx.gameCfg.Reel.xCellNumber do
        jpcount = jpcount + self:ExistJpIcon(i) 
        if jpcount >= 3 then
            self.game.startReel_count = i + 1
            break 
        end
    end
end
-----处理中奖线 --------
--- animIndexs: 播放anim的 index
--- wild2Indexs:百搭二连线
--- wild3Indexs:百搭三连线
--- 忽略
function NormalSlot:HandleWinDatas(lines)
    self.winCoin = 0
    self.spinResult_lines = {}
    self.game.wildIconInfo = {}
    if not next(lines) then
        return
    end
    self.game.Jpwinnumber = 0
    self.spinResult_lines = lines
    local winCoin = 0
    for i, line in ipairs(lines) do
        if line.lineIndex < 10000 then -- 落地牌不算分
            winCoin = winCoin + line.winCoin
            for _, cell in pairs(line.lineCells) do
               if (cell.icon == wildicon) and  not self:Findindex(cell.index)  then
                    table.insert(self.game.wildIconInfo,{index =cell.index,icon = cell.icon })
               end
            end
            if line.lineIndex >= 203 then
                self.game.Jpwinnumber = line.winCoin
            end
        end
    end
    self.winCoin = winCoin
end
function NormalSlot:_PlayCommonAnim(render, cfg,data)
    local animation = cfg.animation
    local loader = render:GetChild("loader")
    local anim = render:GetChild("anim")
    if animation ~= "" then
        loader.visible = false
        anim.visible = true
        anim.url = animation
    else
        loader.url = cfg.icon
        render:GetTransition("t0"):Play()
    end
end

function NormalSlot:SetOpen(isOpen)
    self.isOpen = isOpen
end

function NormalSlot:GetWinCoin()
    print("获取值self.winCoin",self.winCoin)
    return self.winCoin
end

function NormalSlot:SetWinCoin(winCoin)
    self.winCoin = winCoin
end





-- @brief 中奖线展示
function NormalSlot:ShowLines()
    local lines = {}
    local winCoin = 0
    local allLine = {
        lineCells = {},
        winCoin = 0
    }
    local linescount = 0
    -- dump(self.spinResult_lines,"self.spinResult_lines",10)
    -- 中奖线数据整理
    for k, line in pairs(self.spinResult_lines or {}) do
        if line.lineIndex < 10000 then
            linescount = linescount + 1
            table.insert(lines, line)
            winCoin = winCoin + line.winCoin

            for _, cell in pairs(line.lineCells) do
                -- 去重
                local contain = false
                for __, v in pairs(allLine) do
                    if table.equals(cell, v) then
                        contain = true
                        break
                    end
                end

                if not contain then
                    table.insert(allLine.lineCells, cell)
                end
            end
            allLine.winCoin = line.winCoin
        end
      
    end
    if #lines <= 0 then
        return
    end
    --第一次闪烁全部中奖线
    table.insert(lines, 1, allLine)
    local showIndex = 0
    local function ShowLine(visible, isfirst)
         --清理动画的时候不需要计数增加
        if  visible then
            showIndex = showIndex + 1
            if showIndex > #lines then showIndex = 1 end
        end
        local lineCells = lines[showIndex].lineCells
        for k, cell in pairs(lineCells) do
            local index = cell.index 
            local logicX = Utils.GetReelIndex(index) +1
            local logicY = Utils.GetCellIndex(index) +1
            if visible then
                self:DrawWinIcon(logicX,logicY)
            else
                self:ClearWinIcon(logicX,logicY)
            end
        end
        if not isfirst then
            if visible and lines[showIndex].lineIndex and  lines[showIndex].lineIndex> 0 and lines[showIndex].lineIndex <= 50 then
                self.game.winLines:BlinkLine(lines[showIndex].lineIndex )
            else
                self.game.winLines:StopBlinkLine()
            end
        else
            self.game.winLines:StopBlinkLine()
        end
        return lines[showIndex].lineIndex 
    end
    ShowLine(true,#lines)
    self.tweensnor =  FTween.Start(self.bottomContainer,
    FTween.RepeatForever({
        FTween.Delay(2, function() 
            ShowLine(false)--清理中奖线动画 
            ShowLine(true)
        end),
    })
)
end
function NormalSlot:Findindex(index)
    for key, value in pairs(self.game.wildIconInfo) do
        if index == value.index  then
            return true
        end
    end
    return false
end
function  NormalSlot:InitIconvisible(isvisible)
    isvisible = isvisible or false
    for index = 1,  FCasinoCtx.gameCfg.Reel.xCellNumber do
        for indexy = 1,  FCasinoCtx.gameCfg.Reel.yCellNumber do
            local arraySymbolDisplays = self.reels[index].arraySymbolDisplays
            local display = arraySymbolDisplays[indexy]
            display.render.visible = isvisible
        end
    end
end
function NormalSlot:StopShowLine()
    if self.tweensnor then
        self.tweensnor.Kill()
        self.tweensnor = nil
    end
    self:RemoveTopSymbol()
    self:InitIconvisible(true)
end
function NormalSlot:HideIcon(index,isshow)
    isshow = isshow or false
    -- 替换动画到顶层显示
    local logicX = Utils.GetReelIndex(index) +1
            local logicY = Utils.GetCellIndex(index) +1
    local arraySymbolDisplays = self.reels[logicX].arraySymbolDisplays
    local display = arraySymbolDisplays[logicY]
    display.render.visible = isshow
end
function NormalSlot:HideColumn(column,isshow)
    isshow = isshow or false
    for i = 1, FCasinoCtx.gameCfg.Reel.yCellNumber do
        self:HideIcon(column+(i-1)*5,isshow)
    end
end

function NormalSlot:DrawWinIcon(logicX,logicY,isShowWinNumber,isWildIcon)
    local reelCfg = FCasinoCtx.gameCfg.Reel
    -- 替换动画到顶层显示
    local arraySymbolDisplays = self.reels[logicX].arraySymbolDisplays
    local display = arraySymbolDisplays[logicY]
    local cfg = SymbolConfig[display.data.icon]
    local logicIndex = (logicY - 1) * reelCfg.xCellNumber + logicX
    local render = self:GetOrCreateTopSymbol(logicIndex, self.reelcfgdata)
    if display.data.icon == freeicon or display.data.icon == wildicon  then
        render.sortingOrder = 20
    else
        render.sortingOrder = 1
    end
    local data = self.reelDatas[logicX][logicY]
    self:_PlayCommonAnim(render,cfg,data)
    display.render.visible = false
end
function NormalSlot:ClearWinIcon(logicX,logicY)
    local arraySymbolDisplays = self.reels[logicX].arraySymbolDisplays
    local display = arraySymbolDisplays[logicY]
   
    
    local reelCfg = FCasinoCtx.gameCfg.Reel
    local logicIndex = (logicY - 1) * reelCfg.xCellNumber + logicX
    local render = self:GetOrCreateTopSymbol(logicIndex, self.reelcfgdata)
    render.visible = false
    display.render.visible = true
end
function NormalSlot:ExistFreeIcon(index)
    -- if index == 1 or index == 5 then
    --     return false
    -- end
    for i = 1, FCasinoCtx.gameCfg.Reel.yCellNumber do
		if self.reelDatas[index][i].icon == freeicon then
			return true
		end
	end
	return false
end
function NormalSlot:ExistJpIcon(index)
    local jpcount = 0
    for i = 1, FCasinoCtx.gameCfg.Reel.yCellNumber do
		if self.reelDatas[index][i].icon == jpicon then
			jpcount = jpcount + 1
		end
	end
	return jpcount
end
-- function NormalSlot:ExistWildIcon(index)
--     for i = 1, 3 do
-- 		if self.reelDatas[index][i].icon == 1 or self.reelDatas[index][i].icon == 2 then
-- 			return true
-- 		end
-- 	end
-- 	return false
-- end
--获取图标所在位置
function NormalSlot:GetIndePos(index)
    local logicX = Utils.GetReelIndex(index) +1
    local logicY = Utils.GetCellIndex(index) +1
    local arraySymbolDisplays = self.reels[logicX].arraySymbolDisplays
    local render = arraySymbolDisplays[logicY].render
    local xy = render:LocalToRoot(vec2(0,0))
    local container =  FCasinoCtx.commonPanel.topEffectLayer
    local posT = container:RootToLocal(xy)
    return posT
end
function NormalSlot:PlayTablelist(temptable)
    if #temptable == 0 then return end
    for _, value in ipairs(temptable) do
        local cellIndex = Utils.GetReelIndex(value.index) +1
        local iconIndex = Utils.GetCellIndex(value.index) +1
        self:DrawWinIcon(cellIndex,iconIndex)
    end
   
end
function NormalSlot:CleanTablelist(temptable)
    if #temptable == 0 then return end
    for _, value in ipairs(temptable) do
        local cellIndex = Utils.GetReelIndex(value.index) +1
        local iconIndex = Utils.GetCellIndex(value.index) +1
        self:ClearWinIcon(cellIndex,iconIndex)
    end
    temptable = {}
end
return NormalSlot
