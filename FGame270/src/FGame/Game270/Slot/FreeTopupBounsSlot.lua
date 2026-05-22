local Reel = Import(".Reel")
local SymbolConfig = Import(".SymbolConfig")
local TopupBounsSlot = Import(".TopupBounsSlot")
local MusicCfg = Import(".MusicCfg")
local Tools = Import(".Tools")
local ConstCfg = Import(".ConstCfg")

local cls = Class("FreeTopupBounsSlot", TopupBounsSlot)
function cls:ctor(parent, game)
end

function cls:InitReel()
    local reelCfg = FCasinoCtx.gameCfg.Reel
    local yIndex = reelCfg.yCellNumber -- 3
    local isBigSymbol = false
    self.reels = {}
    for k, v in pairs(ConstCfg.FreeAnimIndexs) do
        local reel = Reel.New(self.bottomContainer, v, 1)
        reel:isSpecial(true)
        reel:isFree(true)
        local logicX = self:GetReelIndex(v) + 1 -- 位于x轴的下标 [0,4]
        local logicY = self:GetCellIndex(v) + 1 -- 位于Y轴的下标 [0,2]
        if v == 8 then
            isBigSymbol = false
            reel.cfg.reelHeight, reel.cfg.reelWidth = 405, 500
            logicX = 2
            logicY = 1
            reel:IsBigSymbol(true)
        else
            reel.cfg.reelHeight = reel.cfg.reelHeight / yIndex
        end

        -- 修改转轴配置高度
        reel.cfg.rollSymbolMinNum = 5
        reel:SetMask(true)
        reel:InitSymbol()
        reel.cfg.bounceDuration = 0.18
        reel.cfg.bounceDistance = 100
        reel.reelContainer:SetupOverflowHidden(true)

        reel.reelContainer.x = (logicX - 1) * (reelCfg.reelWidth + reelCfg.reelSpace)
        reel.reelContainer.y = (logicY - 1) * reel.cfg.symbolHeight
        self.reels[v] = reel
    end
    self:ResetDatas()
end

-- @brief 设置图案数据
-- @param quickSet 快速设置，跳过动画
-- 新增 返回落地牌 数量 topupBounsCount
function cls:SetReelSymbolData(grids, callback, quickSet)
    self.onFinishCallback = callback
    local topupBounsCount = 0
    -- 整理服务器数据
    local reelDatas = {}
    local hasNewTopupBonus = false
    for k, v in pairs(ConstCfg.FreeAnimIndexs) do
        local cell = grids[v]
        if Tools.IsJpCard(cell.icon) then
            if v == 8 then
                topupBounsCount = topupBounsCount + 9
            else
                topupBounsCount = topupBounsCount + 1
            end

            if not self.topupBonusIndexs[v] then
                self.topupBonusIndexs[v] = { SymbolType = cell.SymbolType, SymbolValue = cell.SymbolValue }
                if not quickSet then
                    hasNewTopupBonus = true
                end
            end
        end
        reelDatas[v] = {
            {
                icon = cell.icon,
                value = cell.SymbolValue,
                type = cell.SymbolType
            }
        }
    end

    if hasNewTopupBonus then
        self.hasSpinNum = 3
    end
    self.topupBounsCount = topupBounsCount
    -- 设置最终停止数据 --跳过动画
    if quickSet then
        for k, v in pairs(self.reels) do
            v:Recovery(reelDatas[k])
            self:OnReelScrollStop(k, quickSet)
        end
        FCasinoCtx:SetSpinStatus(FSpinStatus.SPIN)
        if self.onFinishCallback then
            self.onFinishCallback()
            self.onFinishCallback = nil
        end
        return
    end
    FCasinoCtx:SetSpinStatus(FSpinStatus.WAITING)
    -- 设置最终停止数据
    local count = 0
    local yCellNumber = FCasinoCtx.gameCfg.Reel.yCellNumber
    local xCellNumber = FCasinoCtx.gameCfg.Reel.xCellNumber
    local timerIndex = 0
    local topSymbolRenderLens = Tools.CheckTabCount(self.topSymbolRenders)
    local reelsCount = 0
    for k, v in pairs(self.reels) do
        reelsCount = reelsCount + 1
    end

    for k, v in pairs(ConstCfg.FreeAnimIndexs) do
        if not self.topSymbolRenders[v] then
            -- 没有落地牌的旋转
            local reel = self.reels[v]
            timerIndex = timerIndex + 1

            reel:Stop(
                    reelDatas[v],
                    function()
                        count = count + 1
                        local hasNewBoun = self:OnReelScrollStop(v, quickSet)
                        local curYIndex = v % yCellNumber
                        local playSound = function()
                            FToolSet.PlayFGUISound(MusicCfg.slots_321_reelstop)
                            if hasNewBoun then
                                FToolSet.PlayFGUISound(
                                        MusicCfg.SND_HandSDoonk .. (v % xCellNumber == 0 and 5 or v % xCellNumber)
                                )
                            end
                        end
                        if curYIndex == 1 then
                            -- 第一排
                            if self.topSymbolRenders[v + 5] and
                                    self.topSymbolRenders[v + 10]
                            then
                                -- 下面没有转轴了
                                playSound()
                            end
                        elseif curYIndex == 2 then
                            -- 第二排
                            if self.topSymbolRenders[v + 5] then
                                -- 下面没有转轴了
                                playSound()
                            end
                        else
                            playSound()
                        end

                        if count + topSymbolRenderLens >= reelsCount then
                            if self.onFinishCallback then
                                self.onFinishCallback()
                                self.onFinishCallback = nil
                            end
                        end
                    end,
                    FConfig.Common:GetRellStopInterval(timerIndex)
            )
        end
    end
end

function cls:OnReelScrollStop(index, quickSet)
    local arraySymbolDisplays = self.reels[index].arraySymbolDisplays
    local hasBouns = 0
    local hasNewBoun = false
    local data = arraySymbolDisplays[1].data
    local render = arraySymbolDisplays[1].render
    -- 是否需要在落地牌中常驻
    local keepInTopupBouns = SymbolConfig[data.icon].keepInTopupBouns
    render.visible = not keepInTopupBouns
    local logicIndex = index
    if keepInTopupBouns and not self.topSymbolRenders[logicIndex] then
        local res = SymbolConfig[data.icon].LDRes[data.type]
        local render = self:GetOrCreateTopSymbol(logicIndex)
        self:_InitTopSymbolRender(render, res, data, logicIndex)
        hasNewBoun = true
    end
    if not keepInTopupBouns then
        render:GetChild("mask").visible = true
    else
        hasBouns = hasBouns + 1
    end
    if hasNewBoun and not quickSet then
        -- 有新的bouns
        if not self.hasPlayTips then
            self.game:SetMidTips("tb3")
            self.hasPlayTips = true
        end
    end
    return hasNewBoun
end

function cls:GetOrCreateTopSymbol(logicIndex)
    return cls.super.GetOrCreateTopSymbol(self, logicIndex, logicIndex == 8)
end

return cls
