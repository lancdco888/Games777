-- 老虎机落地牌游戏，三个格子一组转动

local Reel = Import(".Reel")
local SymbolConfig = Import(".SymbolConfig")
local BaseSlot = Import(".BaseSlot")
local TopupBounsSlot = Class("TopupBounsSlot", BaseSlot)
local MusicCfg = Import(".MusicCfg")
local Tools = Import(".Tools")
local ConstCfg = Import(".ConstCfg")
function TopupBounsSlot:ctor(parent,game)
    local reelCfg = FCasinoCtx.gameCfg.Reel
    local xNum = reelCfg.xCellNumber    -- 5
    local yNum = reelCfg.yCellNumber    -- 3

    local index = 0
    for i = 1, yNum do
        for j = 1, xNum do
            index = index + 1

            local reel = Reel.New(self.bottomContainer, j, 1)
            -- 修改转轴配置高度
            reel.cfg.reelHeight = reel.cfg.reelHeight / yNum
            reel.cfg.rollSymbolMinNum = 5
            reel:SetMask(true)
            reel:InitSymbol()
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

-- 游戏开始之前重置参数
function TopupBounsSlot:ResetDatas(isNewGame,hasSpinNum,winCoin)
    self.hasSpinNum = hasSpinNum or 3
    self.topupBonusIndexs = {} -- value = SymbolType
    self.topupBounsCount = 0
    self.winCoin = winCoin or 0
    if isNewGame then
        self:RemoveTopSymbol()
    end
end

function TopupBounsSlot:GetSpinNum()
    return self.hasSpinNum
end

function TopupBounsSlot:GetTopupBounsCount()
    return self.topupBounsCount
end

function TopupBounsSlot:GetTopupBounsIndexs()
    return self.topupBonusIndexs
end
-- @brief 滚动开始
function TopupBounsSlot:SpinStart()
    -- spin按钮置为等待状态
    FCasinoCtx:SetSpinStatus(FSpinStatus.WAITING)
    -- 转轴开始滚动
    for k, v in pairs(self.reels) do
        if not self.topSymbolRenders[k] then
            v:SpinForever()
        end
    end
    self.hasSpinNum = self.hasSpinNum - 1
    if self.hasSpinNum == 1 then
        self.game:SetMidTips("tb1")
    elseif self.hasSpinNum == 2 then
        self.game:SetMidTips("tb2")
    elseif self.hasSpinNum == 3 then
        self.game:SetMidTips("tb3")
    elseif self.hasSpinNum == 0 then
        self.game.tips:HideTips()
    end
    self.hasPlayTips = false
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
        if v.icon == ConstCfg.TopupBounsIndex then -- 落地牌
            topupBounsCount = topupBounsCount + 1
            if not self.topupBonusIndexs[k] then
                self.topupBonusIndexs[k] = {SymbolType = v.SymbolType, SymbolValue = v.SymbolValue} 
                if not quickSet then
                    hasNewTopupBonus = true
                end
            end
        end
        reelDatas[k] = {{
            icon = v.icon,
            value = v.SymbolValue,
            isHide = v.IsHide,
            type = v.SymbolType,
        }}
    end
    if hasNewTopupBonus then
        self.hasSpinNum = 3
    end
    self.topupBounsCount = topupBounsCount
    -- 设置最终停止数据 --跳过动画
    if quickSet then
        for k, v in pairs(self.reels) do
            v:Recovery(reelDatas[k])
            self:OnReelScrollStop(k,quickSet)
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
            reel:Stop(reelDatas[v], 
                function ()
                    count = count + 1

                    local hasNewBoun = self:OnReelScrollStop(v,quickSet)
                    local curYIndex = index%yCellNumber
                    local playSound = function ()
                        FToolSet.PlayFGUISound(MusicCfg.reel_clink..(index%xCellNumber == 0 and 5 or index%xCellNumber))
                        -- FToolSet.PlayFGUISound(MusicCfg.slots_341_reelstop)
                        if hasNewBoun then
                            FToolSet.PlayFGUISound(MusicCfg.SND_HandSDoonk .. (index%xCellNumber == 0 and 5 or index%xCellNumber))
                        end
                    end
                    if curYIndex == 1 then -- 第一排
                        if self.topSymbolRenders[ConstCfg.AnimIndexs[index]+5]
                        and self.topSymbolRenders[ConstCfg.AnimIndexs[index]+10] then -- 下面没有转轴了
                            playSound()
                        end
                    elseif curYIndex == 2 then -- 第二排
                        if self.topSymbolRenders[ConstCfg.AnimIndexs[index]+5] then -- 下面没有转轴了
                            playSound()
                        end
                    else
                        playSound()
                    end

                    if count + topSymbolRenderLens >= #self.reels then
                        if self.onFinishCallback then
                            self.onFinishCallback()
                            self.onFinishCallback = nil
                        end
                    end
                end
            , FConfig.Common:GetRellStopInterval(timerIndex))
        end
    end
end

function TopupBounsSlot:OnReelScrollStop(index,quickSet)
    if index ~= nil then
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
            self:_InitTopSymbolRender(render,res,data)
            hasNewBoun = true
        end
        if not keepInTopupBouns then
            render:GetChild("mask").visible = true
        else
            hasBouns = hasBouns + 1
        end
        if hasNewBoun and not quickSet then -- 有新的bouns
            if not self.hasPlayTips then
                self.game:SetMidTips("tb3")
                self.hasPlayTips = true
            end
        end
        return hasNewBoun
    end
    return false
end

function TopupBounsSlot:_InitTopSymbolRender(render,res,data)
    local loader = render:GetChild("loader")
    loader.visible = true
    render.sortingOrder = SymbolConfig[data.icon].zorder
    loader.url = SymbolConfig[data.icon].animUrl
    loader.playing = true
    -- 数字
    local num = render:GetChild("num")
    -- 遮罩 -- todo
    local mask = render:GetChild("mask")
    mask.visible = false

    local TopupBounsbg = render:GetChild("TopupBounsbg")
    TopupBounsbg.visible = true

    -- sprite1 
    local sprite1 = render:GetChild("sprite1")
    -- sprite2 
    local sprite2 = render:GetChild("sprite2")

    local DragonExplo = render:GetChild("DragonExplo")
    DragonExplo:SetPlaySettings(0,-1,1,-1,
        function ()
            DragonExplo.visible = false
            DragonExplo.playing = false
            DragonExplo.frame = 0
        end
    )
    DragonExplo.playing = true
    local DragonCircle = render:GetChild("DragonCircle")
    DragonCircle.visible = true
    DragonCircle.playing = true
    -- 落地牌效果 [[
    num.visible = res.numShow
    sprite1.visible = res.spriteFontShow
    sprite2.visible = res.spriteFontShow
    if res.numShow then
        num.text = Tools.TopupBounsScoreToStr(data.value)
    end
    if res.sprite1Url and res.sprite1Url ~= "" then
        sprite1.url = res.sprite1Url
    end
    if res.sprite2Url and res.sprite2Url ~= "" then
        sprite2.url = res.sprite2Url
    end
    -- 落地牌效果]]
end

function TopupBounsSlot:GetWinCoin()
    return self.winCoin
end
return TopupBounsSlot