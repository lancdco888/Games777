-- 老虎机落地牌游戏，三个格子一组转动
local Reel = Import(".Reel")
local SymbolConfig = Import(".SymbolConfig")
local MusicCfg = Import(".MusicCfg")
local Tools = Import(".Tools")
local ConstCfg = Import(".ConstCfg")
local LuodiSymbolItem = Import(".LuodiSymbolItem")
local BaseSlot = Import(".BaseSlot")

local TopupBounsSlot = Class("TopupBounsSlot", BaseSlot)


function TopupBounsSlot:ctor(parent, game)
    local reelCfg = FCasinoCtx.gameCfg.Reel
    local xNum = reelCfg.xCellNumber -- 5
    local yNum = reelCfg.yCellNumber -- 3

    local index = 0
    for i = 1, yNum do
        for j = 1, xNum do
            index = index + 1
            local reel = Reel.New(self.bottomContainer, j, 1, true)
            reel.isLuodiReel = true
            -- 修改转轴配置高度
            reel.cfg.reelHeight = reel.cfg.reelHeight / yNum
            reel.cfg.rollSymbolMinNum = 5
            reel:SetMask(true)
            reel:InitSymbol()
            reel.cfg.bounceDuration = 0.18
            reel.cfg.bounceDistance = 100
            reel.reelContainer:SetupOverflowHidden(true)
            reel.reelContainer.x = (j - 1) * (reelCfg.reelWidth + reelCfg.reelSpace)
            reel.reelContainer.y = (i - 1) * reel.cfg.symbolHeight
            self.reels[index] = reel
        end
    end
    self:ResetDatas()
end

function TopupBounsSlot:__delete()
end

function TopupBounsSlot:GetCurTurn()
    if self.curturn == 0 then return 1 
    else return self.curturn end 
end

function TopupBounsSlot:GetAllTurns()
    return self.allturns
end

-- 游戏开始之前重置参数
function TopupBounsSlot:ResetDatas(isNewGame, winCoin, remainCount, allturns)
    self.topupBonusIndexs = {} -- value = SymbolType
    self.topupBounsCount = 0
    self.winCoin = winCoin or 0
    remainCount = remainCount or 0
    allturns = allturns or 0
    self.curturn = allturns - remainCount
    self.allturns = allturns
    self:ResetCollectScore()
    if isNewGame then
        self:RemoveTopSymbol()
    end
end

function TopupBounsSlot:ResetTopupBounsCurCount()
    self.curturn = 1
end

function TopupBounsSlot:GetTopupBounsCount()
    return self.topupBounsCount
end

function TopupBounsSlot:SetAllTurns(allturns)
    if self.allturns == allturns then
        return
    end
    self.allturns = allturns
    self.game:RefreshFreeGameCounter()
end

function TopupBounsSlot:GetTopupBounsIndexs()
    return self.topupBonusIndexs
end

-- @brief 滚动开始
function TopupBounsSlot:SpinStart()
    -- self.luodiReelingSoundHandler  = FToolSet.PlayFGUISound(MusicCfg.LUODI_REEL)
    -- spin按钮置为等待状态
    FCasinoCtx:SetSpinStatus(FSpinStatus.WAITING)
    -- 转轴开始滚动
    for k, v in pairs(self.reels) do
        if not self.topSymbolRenders[k] then
            v:SpinForever()
        end
    end
    self.curturn = self.curturn + 1
    self.game:RefreshFreeGameCounter()
end

-- @brief 设置图案数据
-- @param quickSet 快速设置，跳过动画
-- 新增 返回落地牌 数量 topupBounsCount
function TopupBounsSlot:SetReelSymbolData(grids, callback, quickSet)
    self.onFinishCallback = callback
    local topupBounsCount = 0
    -- 整理服务器数据
    local reelDatas = {}
    local hasNewTopupBonus = false
    for k, v in pairs(grids) do
        if v.icon == ConstCfg.LuodiSymbolId then -- 落地牌
            topupBounsCount = topupBounsCount + 1
            if not self.topupBonusIndexs[k] then
                self.topupBonusIndexs[k] = { SymbolType = v.SymbolType, SymbolValue = v.SymbolValue }
                if not quickSet then
                    hasNewTopupBonus = true
                end
            end
        end
        reelDatas[k] = {
            {
                icon = v.icon,
                value = v.SymbolValue,
                type = v.SymbolType
            }
        }
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
    for k, v in ipairs(ConstCfg.AnimIndexs) do
        if not self.topSymbolRenders[v] then -- 没有落地牌的旋转
            local reel = self.reels[v]
            local index = k
            timerIndex = timerIndex + 1

            reel:Stop(
                reelDatas[v],
                function ()
                    FToolSet.PlayFGUISound(MusicCfg.LUODI_REEL_END)
                    print("Reel Stop >>>>>>>>>>>>>>>>>>>>>>>>>>> play reel stop")
                    -- 如果是落地牌,且当前该位置不存在落地牌节点
                    local arraySymbolDisplays = self.reels[v].arraySymbolDisplays
                    local display = arraySymbolDisplays[1]
                    local data = arraySymbolDisplays[1].data
                    local render = arraySymbolDisplays[1].render
                    local keepInTopupBouns = SymbolConfig[data.icon].keepInTopupBouns
                    if keepInTopupBouns and not self.topSymbolRenders[v] then
                        FToolSet.PlayFGUISound(MusicCfg.LUODI_NEW_ITEM)
                        local render = self:GetOrCreateTopSymbol(v)
                        self:_InitTopSymbolRender(render, data)
                        display.render.visible = false
                    end 


                    count = count + 1
                    if count + topSymbolRenderLens >= #self.reels then
                        if self.onFinishCallback then
                            self.onFinishCallback()
                            self.onFinishCallback = nil
                        end
                        -- if self.luodiReelingSoundHandler ~= nil then
                        --     APIGateway.StopSound(self.luodiReelingSoundHandler)
                        -- end
                    end
                end,
                FConfig.Common:GetRellStopInterval(timerIndex)
            )
        end
    end
end

function TopupBounsSlot:OnReelScrollStop(index, quickSet)
    if index ~= nil then
        local arraySymbolDisplays = self.reels[index].arraySymbolDisplays
        local hasNewBoun = false
        local display = arraySymbolDisplays[1]
        local data = arraySymbolDisplays[1].data
        local render = arraySymbolDisplays[1].render
        -- 是否需要在落地牌中常驻
        local keepInTopupBouns = SymbolConfig[data.icon].keepInTopupBouns
        render.visible = not keepInTopupBouns
        local logicIndex = index
        -- 如果是落地牌,且当前该位置不存在落地牌节点
        if keepInTopupBouns and not self.topSymbolRenders[logicIndex] then
            local render = self:GetOrCreateTopSymbol(logicIndex)
            self:_InitTopSymbolRender(render, data)
            hasNewBoun = true
            display.render.visible = false
        end
        return hasNewBoun
    end
    return false
end

function TopupBounsSlot:_InitTopSymbolRender(render, data)
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
    local loader_normal = render:GetChild("loader-normal")
    local loader_special = render:GetChild("loader-special")
    local loader_sc = render:GetChild("loader-sc")
    local loader_nvxia = render:GetChild("loader-nvxia")
    local ani_free = render:GetChild("ani-free")
    loader_normal.visible = false
    loader_special.visible = false
    loader_sc.visible = false
    loader_nvxia.visible = false
    ani_free.visible = false
    luodiItemObj.visible = true
end

function TopupBounsSlot:ShowCollectScore(score)
    self.game.luodiGameCollector:GetChild("label-score")
    self.game.luodiGameCollector.text = FToolSet.NumToStr(score)
end
function TopupBounsSlot:ResetCollectScore(score)
    self.game.luodiGameCollector:GetChild("label-score")
    self.game.luodiGameCollector.text = ""
end

function TopupBounsSlot:GetWinCoin()
    return self.winCoin
end


function TopupBounsSlot:SwitchAllSymbolsToLuodiMode()
    for index = 1, 15 do
        -- 替换动画到顶层显示
        local arraySymbolDisplays = self.reels[index].arraySymbolDisplays
        for i = 0, 2 do
            local data = arraySymbolDisplays[i].data
            local display = arraySymbolDisplays[i]
            display.render:GetController("c1").selectedPage = "luodi"
        end
    end
end


function TopupBounsSlot:SwitchAllSymbolsToNormalMode()
    for index = 1, 15 do
        -- 替换动画到顶层显示
        local arraySymbolDisplays = self.reels[index].arraySymbolDisplays
        for i = 0, 2 do
            local data = arraySymbolDisplays[i].data
            local display = arraySymbolDisplays[i]
            display.render:GetController("c1").selectedPage = "normal"
        end
    end
end


--[[ function TopupBounsSlot:StopAllScaleAnims()
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
end
 ]]

return TopupBounsSlot
