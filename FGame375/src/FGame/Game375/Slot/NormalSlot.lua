-- 老虎机普通游戏，三个格子一组转动
local Reel              = Import(".Reel")
local SymbolConfig      = Import(".SymbolConfig")
local MusicCfg          = Import(".MusicCfg")
local BaseSlot          = Import(".BaseSlot")
local ConstCfg          = Import(".ConstCfg")
local Tools             = Import(".Tools")
local NormalSlot        = Class("NormalSlot", BaseSlot)

function NormalSlot:ctor(parent,game)
    local initDatas = ConstCfg.InitUIBox
    local initSymbols = Tools.InitUIBox2Symbol(initDatas)
    self._reelcfg = clone(FCasinoCtx.gameCfg.Reel)
    local x = self._reelcfg.offx
    local y = self._reelcfg.offy
    for i = 1, self._reelcfg.xCellNumber do
        local reel = Reel.New(self.bottomContainer, i, self._reelcfg.yCellNumber)
        local initSymbol = nil
        if initSymbols[i] then
            initSymbol = initSymbols[i]
        end
        reel:SetGame(game)
        reel:Set_Str_Symbol("3x5")
        reel:InitSymbol(initSymbol)
        reel:SetMask(false)
        reel.reelContainer.x = x
        reel.reelContainer.y = y
        self.reels[i] = reel

        -- 单列格子宽度
        x = x + self._reelcfg.reelWidth
        -- 每列间距
        x = x + self._reelcfg.reelSpace
    end
    self.reelDatas = {}
    self.drawLines = {}
end

function NormalSlot:__delete()
    self:CleanTimers()
    FTween.KillTweens(self.parent)
end

-- @brief 滚动开始
function NormalSlot:SpinStart()
    --切换彩金显示
    self.game:CaiJin_UpdateUI()
    -- spin按钮置为等待状态
    FCasinoCtx:SetSpinStatus(FSpinStatus.WAITING)
    self:ResetState()
    -- 转轴开始滚动
    for k, v in pairs(self.reels) do
        v:SpinForever()
    end
end

function NormalSlot:StopTopAndShowSymbol()
    -- 删除顶部图案
    self:RemoveTopSymbol()
    -- 显示转轴层图案
    for k, v in pairs(self.reels) do
        v:ShowSymbolDisplays()
    end
end

--清理状态
function NormalSlot:ResetState()
    self.game:StopLines()
    self:StopTopAndShowSymbol()
    self.reelDatas = {}
    self.drawLines,self.SCanimlist,self.toplist = {},{},{}
    self.winlist,self.bouns_anim_list = {},{}
    self.is_2to1 = false
    self.isEnterFree = false
    self.isEnterTopupBouns = false
    self:CleanTimers()
end

--是否中2选1
function NormalSlot:SetIsEnter_2to1(is_2to1)
    self.is_2to1 = is_2to1
end

--是否中免费
function NormalSlot:SetIsEnterFree(isEnterFree)
    self.isEnterFree = isEnterFree
end

--是否中落地牌
function NormalSlot:SetIsEnterTopupBouns(isEnterTopupBouns)
    self.isEnterTopupBouns = isEnterTopupBouns
end

-- 处理格子信息:将1维数组转换为2维数组
function NormalSlot:HandleCellDatas(grids)
    -- 整理服务器数据
    local reelDatas = {}
    local reelCfg = self._reelcfg
    local initDatas = ConstCfg.InitUIBox
    local initSymbols = Tools.InitUIBox2Symbol(initDatas)
    for reelIndex = 1, reelCfg.xCellNumber do
        for iconIndex = 1, reelCfg.yCellNumber do
            local xy_ = (iconIndex - 1) * reelCfg.xCellNumber + reelIndex
            local cell = nil
            if not grids then
                --没有格子信息代表没有旋转过的断网重连
                cell = initSymbols[reelIndex][iconIndex]
            else
                --正常处理
                cell = grids[xy_]
            end
            --普通图标
            local reel_icon = cell.icon
            local down_icon = nil
            local winShow = false
            reelDatas[reelIndex] = reelDatas[reelIndex] or {}
            reelDatas[reelIndex][iconIndex] = {
                icon = reel_icon,
                down_icon = down_icon,
                winShow = winShow,
                value = cell.SymbolValue or 0,
                type = cell.SymbolType or 0,
                lines_idx = {},
            }
        end
    end
    self.reelDatas = reelDatas
end

-----处理中奖线 --------
function NormalSlot:HandleWinDatas(lines,isReconnect)
    self.winCoin = 0
    if not next(lines) then
        return
    end
    local drawLines = {}        --中奖线(特殊效果，显示白框)
    local havewildwin = false   --是否有Wild(替代)参与中奖
    local winCoin = 0
    for i, line in ipairs(lines) do
        --dump(line,"========line========")
        --dump(line.lineCells,"========" .. tostring(line.lineIndex).."========")
        --中奖线（除了中SC其他中奖线数据都一起处理）
        winCoin = winCoin + line.winCoin
        for j, cell in ipairs(line.lineCells) do
            local reallyidx = cell.index
            local reelIndex = self:GetReelIndex(reallyidx) + 1
            local iconIndex = self:GetCellIndex(reallyidx) + 1
            self.reelDatas[reelIndex][iconIndex]["winShow"] = true
            table.insert(self.reelDatas[reelIndex][iconIndex]["lines_idx"],line.lineIndex)
            if Tools.IsWildCard(cell.icon) then
                havewildwin = true
            end
        end
        --SC中奖线不加入集体线动画
        if line.lineIndex ~= Tools.FreeLineID then
            table.insert(drawLines,{lineIndex = line.lineIndex,winCoin = line.winCoin})
        end
    end
    if isReconnect then
        return
    end
    --dump(drawLines,"---------drawLines=============")
    --print(winCoin,"----------winCoin---------------")
    self.winCoin = winCoin
    self.drawLines = drawLines
    self.havewildwin = havewildwin
end

--断线重连时，恢复图案(免费里面重连时用)
function NormalSlot:SetLastReelSymbolData(grids)
    self:HandleCellDatas(grids)
    for k, v in pairs(self.reels) do
        v:SetOpen(self.isOpen)
        v:Recovery(self.reelDatas[k])
    end
    self.SCanimlist = {}            --sc上层表
    self.bouns_anim_list = {}       --bonus上层表
    self.toplist = {}               --所有上层表
    self.winlist = {}               --除了sc以外的中奖图标列表
    for index, value in ipairs(self.reelDatas) do
        self:OnReelScrollStopCreate(index)
        self:Play_StopAnim(index,self.bouns_anim_list,"anim")
    end
end

-- @brief 设置图案数据
-- @param finishcallback 中奖线播放一轮后的回调函数
-- @param reconnect 快速设置，跳过动画(断线重连回来)
function NormalSlot:SetReelSymbolData(callback, reconnect)
    self.onFinishCallback = callback
    -- 设置最终停止数据 跳过动画
    if reconnect then
        for k, v in pairs(self.reels) do
            v:SetOpen(self.isOpen)
            v:Recovery(self.reelDatas[k])
        end
        for index, value in ipairs(self.reelDatas) do
            self:OnReelScrollStopCreate(index)
            self:Play_StopAnim(index,self.bouns_anim_list,"anim")
        end
        FCasinoCtx:SetSpinStatus(FSpinStatus.SPIN)
        if self.onFinishCallback then
            self.onFinishCallback()
            self.onFinishCallback = nil
        end
        return
    end
    --FCasinoCtx:SetSpinStatus(FSpinStatus.WAITING)
    FCasinoCtx:SetSpinStatus(FSpinStatus.STOP)
    self:_StopSReelsSpin()
end

--最终转轴层图案状态先创建
function NormalSlot:OnReelScrollStopCreate(index)
    local reelCfg = self._reelcfg
    for i = 1, reelCfg.yCellNumber do
        local data = self.reelDatas[index][i] --最终显示数据
        local upcfg = SymbolConfig.Icon[data.icon]
        local dowcfg = nil
        if data.down_icon then
            dowcfg = SymbolConfig.Icon[data.down_icon]
        end
        local logicIndex = (i - 1) * reelCfg.xCellNumber + index
        --不管中不中奖都创建个上层图标
        local data_show = {}
        local render_list = self:NewCreateTopSymbol(data,upcfg,dowcfg,logicIndex)
        data_show.render_list = render_list
        data_show.upcfg = upcfg
        data_show.data = data
        data_show.ischecked = false
        data_show.notneedTopcontrol = false
        data_show.xIndex = index
        data_show.yIndex = i
        if data.winShow then
            --中奖的图案
            if Tools.IsSCCard(data.icon) then
                --SC图案动画播放
                table.insert(self.SCanimlist,data_show)
            else
                table.insert(self.winlist,data_show)
            end
            --中奖线，SC中奖也加进去
            if #data.lines_idx > 0 then
                for _, line_idx in pairs(data.lines_idx) do
                    self.game.winline:SetShowIndexAndCell(line_idx,data_show)
                end
            end
        end
        --落地牌有特殊效果
        if Tools.IsJpCard(data.icon) or Tools.IsJpCard_3x7(data.icon) or Tools.IsJpCard_Double(data.icon) then
            data_show.notneedTopcontrol = true
            --落地牌图案动画播放
            table.insert(self.bouns_anim_list,data_show)
        end
        table.insert(self.toplist,data_show)
    end
    --dump(self.reelDatas,"=======self.reelDatas==========")
    --dump(self.toplist,"==========self.toplist==========")
end

--停止转动
function NormalSlot:_StopSReelsSpin()
    self.SCanimlist = {}            --sc上层表
    self.bouns_anim_list = {}       --bonus上层表
    self.toplist = {}               --所有上层表
    self.winlist = {}               --除了sc以外的中奖图标列表
    -- 获取SC强调音效播放表
    local scsoundlist = self:CheckEmphasizeStopPlay(Tools.SCIconID)
    local islong_scstop,scstop_pos = self:CheckEmphasizeStart(scsoundlist)
    -- 获取落地牌强调音效播放表
    local bounssoundlist = self:CheckEmphasizeStopPlay({Tools.BounsIconID,Tools.BounsIconID_3x7,Tools.BounsIconID_Double})
    -- 延时音效播放列表
    local delayedplaylist = {}
    for i = 1, 5, 1 do
        table.insert(delayedplaylist,{needplay = false})
    end
    -- 设置最终停止数据
    local stoptime = self.stoptime or 0
    self.stoptime = 0
    local count = 0
    for index, value in ipairs(self.reelDatas) do
        local reel = self.reels[index]
        if index ~= 1 then
            stoptime = stoptime + FConfig.Common:GetRellStopInterval()
        end
        -- --延时滚动
        -- if (islong_scstop and scstop_pos + 1 <= index) then
        --     --加速模式不播放
        --     if not reel:IsQuickMode() then
        --         delayedplaylist[index - 1].needplay = true
        --         stoptime = stoptime + 1.5
        --     end
        -- end
        reel:Stop(self.reelDatas[index], 
            function ()
                count = count + 1
                self:OnReelScrollStopCreate(count)
                if scsoundlist[count].needplay then
                    --SC强调音效
                    FToolSet.PlayFGUISound(MusicCfg.fx_scatter_ .. scsoundlist[count].order)
                elseif bounssoundlist[count].needplay then
                    --落地牌强调音效
                    FToolSet.PlayFGUISound(MusicCfg.normal_pearl_sound .. bounssoundlist[count].order)
                    --落地牌强调动画
                    if next(self.bouns_anim_list) then
                        self:Play_StopAnim(count,self.bouns_anim_list,"anim")
                    end
                else
                    --转轮停止音效
                    FToolSet.PlayFGUISound(MusicCfg.reel_stop)
                end
                -- --延时音效
                -- if delayedplaylist[count].needplay then
                --     delayedplaylist[count].sound = FToolSet.PlayFGUISound(MusicCfg.speed_reel)
                -- end
                if count >= #self.reels then
                    if reel.isclickStop then
                        -- for _, data_ in ipairs(delayedplaylist) do
                        --     APIGateway.StopSound(data_.sound)
                        --     data_.sound = nil
                        -- end
                    end
                    --显示上层
                    self:StopSymbolAndShowTop(true)
                    --检测是否需要显示SC中奖和打铃
                    self:_CheckSCWin()
                end
            end
        ,stoptime)
    end
end

--播放停止效果(动画类型的)
function NormalSlot:Play_StopAnim(x_index,list,type_)
    for index, value in ipairs(list) do
        if value.xIndex == x_index then
            local display = self.reels[value.xIndex].arraySymbolDisplays[value.yIndex]
            display.render.visible = false
            local top_render = value.render_list[1]
            top_render.visible = true
            if type_ == "anim" then
                if value.upcfg.animations then
                    top_render:GetTransition(value.upcfg.animations.loop):Play(-1,0,function () end)
                end
            else
                local particle_bouns_come = top_render:GetChild("particle_bouns_come")
                particle_bouns_come.visible = true
                local particle_ = APIGateway.PlayParticleEffect("Game368/particle/367_icon_dd2",particle_bouns_come)
            end
        end
    end
end

--设置顶层图标上的各种效果
function NormalSlot:_InitSymbolRender(render,cfg,data)
    render.visible = false
    local image = render:GetChild("icon")
    image.visible = true
    image.url = cfg.icon
    if cfg.Scale then
        image.scale = cfg.Scale
    end
    if cfg.Pos then
        image.xy = cfg.Pos
    end
end

--创建上层图案
function NormalSlot:NewCreateTopSymbol(data,upcfg,downcfg,logicIndex)
    local temp = {}
    if downcfg then
        --被覆盖
        local render = self:GetOrCreateMiddleSymbol(downcfg.topzorder,logicIndex,"3x5")
        self:_InitSymbolRender(render,downcfg,data)
        table.insert(temp,render)
        local render_2 = self:GetOrCreateTopSymbol(upcfg.topzorder,logicIndex,"3x5")
        self:_InitSymbolRender(render_2,upcfg,data)
        table.insert(temp,render_2)
    else
        --没有被覆盖
        local render = self:GetOrCreateMiddleSymbol(upcfg.topzorder,logicIndex,"3x5")
        self:_InitSymbolRender(render,upcfg,data)
        table.insert(temp,render)
    end
    return temp
end

--检测是否需要强调播放，返回播放表(出现就强调逻辑)
function NormalSlot:CheckEmphasizeStopPlay(icon_index)
    local list = {}
    local reelCfg = self._reelcfg
    for i = 1, reelCfg.xCellNumber do
        local temp = {}
        temp.needplay = false
        table.insert(list,temp)
    end
    if type(icon_index) == "table" then
        --多个不同图标但代表同一内容的
        local needplay_order = 0
        for index = 1, reelCfg.xCellNumber do
            local needplay = false
            for i = 1, reelCfg.yCellNumber do
                local data = self.reelDatas[index][i]
                local bool_is = false
                for i = 1, #icon_index do
                    if data.icon == icon_index[i] then
                        bool_is = true
                        break
                    end
                end
                if bool_is then
                    needplay = true
                    break
                end
            end
            if needplay then
                needplay_order = needplay_order + 1
                list[index].needplay = true
                list[index].order = needplay_order
            end
        end
    else
        --单个图标
        local needplay_order = 0
        for index = 1, reelCfg.xCellNumber do
            local needplay = false
            for i = 1, reelCfg.yCellNumber do
                local data = self.reelDatas[index][i]
                if data.icon == icon_index then
                    needplay = true
                    break
                end
            end
            if needplay then
                needplay_order = needplay_order + 1
                list[index].needplay = true
                list[index].order = needplay_order
            end
        end
    end
    
    return list
end

--检测是否需要强调播放，返回检测结果以及强调开始x轴
function NormalSlot:CheckEmphasizeStart(list_)
    local number = 0
    local lastpos = 0
    for index, value in ipairs(list_) do
        if value.needplay then
            number = number + 1
            lastpos = index
            if number >= 2 then
                break
            end
        end
    end
    if (number >= 2) and (lastpos ~= 5) then
        return true,lastpos
    end
    return false,lastpos
end

--停2秒再继续
function NormalSlot:TakeABreak(callback,time)
    self.TakeABreaktimer = StartOnceTimer(function ()
        self.TakeABreaktimer = nil
        callback()
    end,time or 2)
end

--显示上层并隐藏下层true:覆盖后的，false:覆盖前的
function NormalSlot:StopSymbolAndShowTop(showcoverage)
    for _, value in ipairs(self.toplist) do
        local display = self.reels[value.xIndex].arraySymbolDisplays[value.yIndex]
        display.render.visible = true
        local top_render = value.render_list[1]
        if value.render_list[2] then
            top_render = value.render_list[2]
        end
        if value.data.winShow or value.notneedTopcontrol then
            if not Tools.IsWildCard(value.data.icon) then
                top_render.visible = true
            end
        else
            top_render.visible = false
        end
    end
end

--检查是否中免费
function NormalSlot:_CheckSCWin()
    FCasinoCtx:SetSpinStatus(FSpinStatus.WAITING)
    if not self.isEnterFree then
        self:_CheckBounsWin()
        return
    end
    if not next(self.SCanimlist) then
        self:_CheckBounsWin()
        return
    end
    for index, value in ipairs(self.SCanimlist) do
        local display = self.reels[value.xIndex].arraySymbolDisplays[value.yIndex]
        display.render.visible = false
        local render = value.render_list[1]
        render.visible = true
        local cfg = SymbolConfig.Icon[display.data.icon]
        render:GetChild("icon").visible = false
        --SC动画
        if cfg.isplist then
            local anim_name = cfg.animation
            local anim = render:GetChild(anim_name)
            Tools.AnimNodeSet(anim,true)
            anim:SetPlaySettings(0,-1,0,-1,function ()
            end)
        else
            render:GetTransition(cfg.animation):Play(-1,0,function ()
            end)
        end
    end
    FToolSet.PlayFGUISound(MusicCfg.win_feature)
    self:TakeABreak(function ()
        self:_CheckBounsWin()
    end,2)
end

--检查是否中落地牌
function NormalSlot:_CheckBounsWin()
    FCasinoCtx:SetSpinStatus(FSpinStatus.WAITING)
    if not self.isEnterTopupBouns then
        self:_PlayAllSymbolAnim()
        return
    end
    if not next(self.bouns_anim_list) then
        self:_CheckBounsWin()
        return
    end
    for index, value in ipairs(self.bouns_anim_list) do
        local display = self.reels[value.xIndex].arraySymbolDisplays[value.yIndex]
        display.render.visible = false
        local render = value.render_list[1]
        render.visible = true
        local cfg = SymbolConfig.Icon[display.data.icon]
        render:GetChild("icon").visible = false
        --落地牌中奖动画
        if cfg.isplist then
            local anim_name = cfg.animation
            local anim = render:GetChild(anim_name)
            Tools.AnimNodeSet(anim,true)
            anim:SetPlaySettings(0,-1,0,-1,function ()
            end)
        else
            render:GetTransition(cfg.animations.loop):Stop()
            render:GetTransition(cfg.animations.win):Play(-1,0,function()
            end)
        end
    end
    FToolSet.PlayFGUISound(MusicCfg.win_feature_2)
    self:TakeABreak(function ()
        --切换会循环动画
        for index, value in ipairs(self.bouns_anim_list) do
            local display = self.reels[value.xIndex].arraySymbolDisplays[value.yIndex]
            display.render.visible = false
            local render = value.render_list[1]
            render.visible = true
            local cfg = SymbolConfig.Icon[display.data.icon]
            render:GetChild("icon").visible = false
            --SC动画
            if cfg.isplist then
                local anim_name = cfg.animation
                local anim = render:GetChild(anim_name)
                Tools.AnimNodeSet(anim,true)
                anim:SetPlaySettings(0,-1,0,-1,function ()
                end)
            else
                render:GetTransition(cfg.animations.win):Stop()
                render:GetTransition(cfg.animations.loop):Play(-1,0,function()
                end)
            end
        end
        self:_PlayAllSymbolAnim()
    end,3)
end

--播放除SC外所有动画的中奖图标
function NormalSlot:_PlayAllSymbolAnim()
    if not next(self.winlist) then
        self:CollectScores()
        self:DrawLine()
        return
    end
    for index, value in ipairs(self.winlist) do
        local display = self.reels[value.xIndex].arraySymbolDisplays[value.yIndex]
        display.render.visible = false
        local render = value.render_list[1]
        render.visible = true
        local cfg = SymbolConfig.Icon[value.data.icon]
        render:GetChild("icon").visible = false
        if cfg.isplist then
            if cfg.animation then
                local anim_name = cfg.animation
                local anim = render:GetChild(anim_name)
                Tools.AnimNodeSet(anim,true)
                anim:SetPlaySettings(0,-1,0,-1,function ()
                end)
            end
        else
            --有些中奖的没有动画效果，有效果的才放
            if cfg.animation then
                render:GetTransition(cfg.animation):Play(1,0,function ()
                end)
            end
            if cfg.animation_n then
                render:GetTransition(cfg.animation_n):Play(1,0,function ()
                end)
            end
            if cfg.free_animation then
                render:GetTransition(cfg.free_animation):Play(1,0,function ()
                end)
            end
        end
    end
    if self.havewildwin then
        --FToolSet.PlayFGUISound(MusicCfg.shot_wild)
    end
    --所有中奖图动画显示一遍后进入收分流程
    self:TakeABreak(function ()
        --检测是否是序列帧动画，并停止序列帧动画
        self:_PlayAllSymbolAnimEnd_Plist()
        self:CollectScores()
        self:DrawLine()
    end,2)
end

function NormalSlot:_PlayAllSymbolAnimEnd_Plist()
    for index, value in ipairs(self.winlist) do
        local render = value.render_list[1]
        local cfg = SymbolConfig.Icon[value.data.icon]
        if cfg.isplist then
            if cfg.animation then
                local anim_name = cfg.animation
                local anim = render:GetChild(anim_name)
                Tools.AnimNodeStop(anim)
            end
        end
    end
end

--12x3奖励被排除在外，结束时需要重新加入
function NormalSlot:AddWinCoin(addwin)
    self.winCoin = self.winCoin + addwin
end

-- 画线
function NormalSlot:DrawLine()
    self.game:PlayLines(self.drawLines)
end

--收分
function NormalSlot:CollectScores()
    if #self.drawLines > 0 or self.is_2to1 or self.isEnterFree then
        local second = self.game:ShowBottomWin(false,false,false,false,self.onFinishCallback)
        self.onFinishCallback = nil
        if second > 0 then
            FCasinoCtx:SetSpinStatus(FSpinStatus.STOP)
        end
    else
        self.onFinishCallback()
        self.onFinishCallback = nil
    end
end

function NormalSlot:SetOpen(isOpen)
    self.isOpen = isOpen
end

--断线重连时才会使用
function NormalSlot:SetWinCoin(number)
    self.winCoin = number
end

function NormalSlot:GetWinCoin()
    return self.winCoin
end

--清除所有倒计时
function NormalSlot:CleanTimers()
    if self.TakeABreaktimer then
        StopTimer(self.TakeABreaktimer)
        self.TakeABreaktimer = nil
    end
end

return NormalSlot