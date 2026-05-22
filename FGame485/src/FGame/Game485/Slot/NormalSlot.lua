-- 老虎机普通游戏，三个格子一组转动
local Reel = Import(".Reel")
local Utils = Import(".Utils")
local BaseSlot = Import(".BaseSlot")
local GameDefine = Import("..GameDefine")

local NormalSlot = Class("NormalSlot", BaseSlot)

function NormalSlot:ctor(parent,bFree)
    self.bFreeMode = bFree
    local x = FCasinoCtx.gameCfg.Reel.reelOffsetX
    for i = 1, FCasinoCtx.gameCfg.Reel.xCellNumber do
        local reel = Reel.New(self.bottomContainer, i, FCasinoCtx.gameCfg.Reel.yCellNumber)
        reel:InitSymbol(GameDefine.InitSymbolData[i])
        reel.reelContainer.x = x
        self.reels[i] = reel
        -- 单列格子宽度
        x = x + FCasinoCtx.gameCfg.Reel.reelWidth
        -- 每列间距
        x = x + FCasinoCtx.gameCfg.Reel.reelSpace
    end
    self.bottomSymbol = {}
end

function NormalSlot:__delete()
end

function NormalSlot:Reset()
    -- 移除所有顶部图案
    self:KillTopSymbol()
    self:ShowAllTopSymbolRenders()
    -- 停止金币滚动
    self.onFinishCallback = nil
    FCasinoCtx.commonPanel:StopScrollWinMoney(nil, true)

    self.bCreateTop = false
end


-- @brief 滚动开始
function NormalSlot:SpinStart()
    -- spin按钮置为等待状态
    FCasinoCtx:SetSpinStatus(FSpinStatus.WAITING)
    -- 转轴开始滚动
    for k, v in pairs(self.reels) do
        --快速按钮一起停止效果
        if v:IsQuickMode() then
            v:SpinForever()
        else
            -- local dalay = 0.1 * (k-1)
            -- v:SpinForever(nil,dalay)
            v:SpinForever(nil,0)
        end
    end
    -- 移除所有顶部图案
    self:Reset()
end

function NormalSlot:SetAllReelStopCall( callback )
    self.onAllReelStopCall = callback
end

-- @brief 设置图案数据
function NormalSlot:SetReelSymbolData(spinData, callback, isReconnect)
    self.isReconnect = isReconnect
    self:Reset()
    self.spinData     = spinData
    self.curWinCoin = spinData.winCoin
    self.lines = spinData.lines
    self.grids = spinData.grids
    self.onFinishCallback = callback

    FCasinoCtx:SetSpinStatus(FSpinStatus.STOP)

    self.bHaveWild = false
    self.bHaveBoob = false
    -- 整理服务器数据
    local reelDatas = {}
    for k, v in pairs(self.grids) do
        local reelIndex = Utils.GetReelIndex(k) + 1
        local iconIndex = Utils.GetCellIndex(k) + 1

        reelDatas[reelIndex] = reelDatas[reelIndex] or {}
        reelDatas[reelIndex][iconIndex] = {
            icon = Utils.GetIconIndex(v.icon),
            value = v.symbolValue,
            type = v.symbolType,
            ishide = 0,             --v.ishide
        }
        if v.ishide == 1 then
            self.bHaveBoob = true
        end
        if Utils.IsWild( reelDatas[reelIndex][iconIndex].icon) then
            self.bHaveWild = true
        end
    end

    self.reelBonusCount = 0

    self.scatterCountInfo = {}

    self.scatterTopSymbols = {}
    self.scatterStopSounds = {}

    --中奖预警 免费
    local freeCount = 0
    local warning = {0,0,0,0,0}
    local reelCfg = FCasinoCtx.gameCfg.Reel
    for k, v in pairs( reelDatas ) do
        local reel = reelDatas[k]
        for i = 1, reelCfg.yCellNumber do
            local data = reel[i]
            if Utils.IsScatter(data.icon) and k<=3 then
                freeCount = freeCount + 1
            end
        end
        if k == 4 and freeCount >= 2 then
            warning[4] = 1.5
            break
        end
    end

    -- 断线重连
    if isReconnect then
        -- 直接设置图案
        for k, v in pairs(self.reels) do
            v.isReconnect = true
            v:Recovery(reelDatas[k])
            v.isReconnect = false
            self:OnReelScrollStop(k, k >= #self.reels, isReconnect)
        end
    else
        -- 设置最终停止数据
        local count = 0
        local delayWarning = 0
        for k, v in pairs(self.reels) do
            delayWarning = delayWarning + warning[k]
            v:Stop(reelDatas[k], function()
                count = count + 1
                self:OnReelScrollStop(k, count >= #self.reels)
            end, FConfig.Common:GetRellStopInterval(k)+delayWarning)
        end
    end
end

local _CfgBonusStopSound = {
    [1] = "ui://Game485/UFCS_BG_Fireball_Ant1",
    [2] = "ui://Game485/UFCS_BG_Fireball_Ant2",
    [3] = "ui://Game485/UFCS_BG_Fireball_Ant3",
    [4] = "ui://Game485/UFCS_BG_Fireball_Ant4",
    [5] = "ui://Game485/UFCS_BG_Fireball_Ant5",
}

local _CfgScatterStopSound = {
    [2] = "ui://Game485/QHR_JP_Antic_1",
    [3] = "ui://Game485/QHR_JP_Antic_2",
    [4] = "ui://Game485/QHR_JP_Antic_3",
}

function NormalSlot:OnReelScrollStop(index, finish, isReconnect)

    local soundStopUrl = "ui://Game485/reelstop"

    -- 替换动画到顶层显示
    local arraySymbolDisplays = self.reels[index].arraySymbolDisplays

    local reelCfg = FCasinoCtx.gameCfg.Reel
    local clickBonus = false
    for i = 1, reelCfg.yCellNumber do
        local display = arraySymbolDisplays[i]
        local data    = display.data
        local logicIndex = (i - 1) * reelCfg.xCellNumber + index
        local topSymbol = self:GetOrCreateTopSymbol(logicIndex)
        local cfgIcon, isReconnect = topSymbol:SetIcon(index, data, false,self.isReconnect)
        topSymbol:SetVisible(false)
        display.render.visible = true

        --Bonus声音
        if not clickBonus and Utils.IsBonus(data.icon) then
            self.reelBonusCount = self.reelBonusCount + 1
            soundStopUrl = _CfgBonusStopSound[self.reelBonusCount]
            clickBonus = true
        end

        --免费wild声音
        if not isReconnect and self.bFreeMode and Utils.IsWild(data.icon) then
            soundStopUrl = "ui://Game485/UFCS_FG_Wild"
        end

        --免费 停下动画
        if not isReconnect and index >= 2 and index <= 4 and cfgIcon.stopPlayName 
           and Utils.IsScatter(data.icon) then
            local _isPlay = false
            if index == 2 then
                _isPlay = true
            elseif self.scatterCountInfo[index-1] then
                _isPlay = true
            end
            if _isPlay then
                self.scatterCountInfo[index] = true
                topSymbol:SetVisible( true )
                display.render.visible = false
                topSymbol.loader_icon.component:GetTransition( cfgIcon.stopPlayName ):Play(function() end)
                self.scatterStopSounds[index] = FToolSet.PlayFGUISound( _CfgScatterStopSound[index] )
                table.insert( self.scatterTopSymbols, topSymbol )
            end
        end
    end

    --停下播放声音
    if not isReconnect then
        FToolSet.PlayFGUISound( soundStopUrl )
    end

    local delay = 0.1

    if finish then
        self.bottomSymbol = {}
        for x = 1,FCasinoCtx.gameCfg.Reel.xCellNumber do
            for y = 1,FCasinoCtx.gameCfg.Reel.yCellNumber do
                local logicIndex = (y - 1) * reelCfg.xCellNumber + x
                self.bottomSymbol[logicIndex] = self.reels[x].arraySymbolDisplays[y].render
            end
        end
        self.bCreateTop = true

        --中scatter动画声音
        if not self.isReconnect then
            if self.spinData.intoFree and self.spinData.intoFree > 0 then
                FCasinoCtx:GetGame():DelayFunc( 0.5, function ()
                    FToolSet.PlayFGUISound("ui://Game485/scatrwin")
                    for _,topSymbol in ipairs( self.scatterTopSymbols ) do
                        topSymbol.loader_icon.component:GetTransition("win"):Play(function() end)
                    end
                end)
                delay = 3
                FCasinoCtx:SetSpinStatus(FSpinStatus.WAITING)
            elseif self.spinData.intoSpecial and self.spinData.intoSpecial >= 1 then
                FCasinoCtx:GetGame():DelayFunc( 0.5, function ()
                    FToolSet.PlayFGUISound("ui://Game485/scatrwin")
                end)
                delay = 3
                FCasinoCtx:SetSpinStatus(FSpinStatus.WAITING)
            end
        end

        for _,sound in pairs( self.scatterStopSounds ) do
            APIGateway.StopSound( sound )
        end
    end

    -- 全部滚动完毕
    if finish then
        if self.isReconnect then
            self:OnFinish()
        else
            FCasinoCtx:GetGame():DelayFunc( delay, function ()
                self:CheckLines()
                FCasinoCtx:GetGame():DelayFunc( delay, function ()
                    if self.onAllReelStopCall then
                        self.onAllReelStopCall()
                    end
                end)
            end)
        end
    end

end
-- @brief 中奖线展示
function NormalSlot:CheckLines()
    FCasinoCtx:SetSpinStatus(FSpinStatus.WAITING)
    local lines = {}
    self.BonusValue = 0
    for _, line in pairs(self.lines or {}) do
        if line.lineIndex < GameDefine.NORMAL_LINE_INDEX or Utils.IsScatterLine(line.lineIndex) then
            table.insert(lines, line)
        end
        if Utils.IsBonusLine(line.lineIndex) then
            self.BonusValue = line.winCoin
        end
    end

    if self.bHaveBoob then
        self:ShowBoom(lines)
    else
        self:ShowLines(lines)
    end
end
--偷梁换柱 2
function NormalSlot:ShowBoom(lines)
    for index = 1,15 do
        local data = self:GetItemCfg(index)
        if data.ishide == 1 then
            local tRender = self.topSymbols[index]
            local bRender = self.bottomSymbol[index]
            Utils.SetIcon(bRender,data)
            tRender:ShowBoom()
            tRender:SetVisible(true)
            bRender.visible = false
        end
    end
    FTween.Start(self.bottomContainer,
        FTween.Delay(1.2,function ()
            self:ShowLines(lines)
        end)
    )
end

function NormalSlot:GetItemCfg(index)
    local logicX = Utils.GetReelIndex(index) + 1
    local logicY = Utils.GetCellIndex(index) + 1
    local display = self.reels[logicX].arraySymbolDisplays[logicY]
    return display.data
end

function NormalSlot:ShowLines(lines)
    if #lines == 0 then
        self:OnFinish()
        return
    end

    local grids = {}
    local allLineIndexs = {}
    for _, cell in pairs(lines) do
        for _, data in pairs(cell.lineCells) do
            if not grids[data.index] then
                grids[data.index] = clone(data)
            end
        end
        if not allLineIndexs[cell.lineIndex] then
            allLineIndexs[cell.lineIndex] = cell.lineIndex
        end
    end

    local allLine = {
        lineCells = grids,
        lineIndex = allLineIndexs,
        winCoin = 0
    }

    table.insert(lines, 1, allLine)

    local showIndex = 1
    local function ShowLine(_, stepNext)
        if not self.bCreateTop then
            print("不应该进来了 动画被清除了")
            return
        end
        -- 停止闪烁
        self:ShowAllTopSymbolRenders()

        local lineCells = lines[showIndex].lineCells
        for _, cell in pairs(lineCells) do
            local index = cell.index + 1
            local tRender = self.topSymbols[index]
            local bRender = self.bottomSymbol[index]
            tRender:ShowAnim()
            tRender:SetVisible(true)
            if not Utils.IsScatter(cell.icon) then
                tRender:ShowLine()
            end
            bRender.visible = false
        end

        if stepNext then
            showIndex = showIndex + 1
            if showIndex > #lines then showIndex = 2 end
        end
    end
    ShowLine(true, true)
    FCasinoCtx:GetGame():PlaySettlementAnimation(self.curWinCoin - self.BonusValue,function ()
        self:OnFinish()
    end)
    FTween.Start(self.bottomContainer,
        FTween.RepeatForever({
            FTween.Delay(2, function() ShowLine(true, true) end),
        })
    )
end

function NormalSlot:ShowAllTopSymbolRenders()
    for _, render in pairs(self.topSymbols) do
        render:SetVisible(false)
        render:ClearLine()
    end
    if next(self.bottomSymbol) then
        for _, render in pairs(self.bottomSymbol) do
            render.visible = true
        end
    end
end

function NormalSlot:StopShowLine()
    FTween.KillTweens(self.bottomContainer)
    self:ShowAllTopSymbolRenders()
end

function NormalSlot:OnFinish()
    if self.onFinishCallback then
        self.onFinishCallback()
        self.onFinishCallback = nil
    end
end

return NormalSlot