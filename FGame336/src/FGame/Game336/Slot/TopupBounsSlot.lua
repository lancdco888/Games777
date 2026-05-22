-- 老虎机落地牌游戏，三个格子一组转动
local Utils = Import(".Utils")
local Reel = Import(".Reel")
local SymbolConfig = Import(".SymbolConfig")
local BaseSlot = Import(".BaseSlot")
local TopupBounsSlot = Class("TopupBounsSlot", BaseSlot)
local MusicCfg = Import(".MusicCfg")

function TopupBounsSlot:ctor(parent,game)
    local x = 0
    for i = 1, FCasinoCtx.gameCfg.Reel.xCellNumber do
        local reel = Reel.New(self.bottomContainer, i, FCasinoCtx.gameCfg.Reel.yCellNumber)
        reel:InitSymbol()
        reel:SetMask(true)
        reel.reelContainer.x = x
        self.reels[i] = reel

        -- 单列格子宽度
        x = x + FCasinoCtx.gameCfg.Reel.reelWidth
        -- 每列间距
        x = x + FCasinoCtx.gameCfg.Reel.reelSpace
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
        v:SpinForever()
    end
    self.hasSpinNum = self.hasSpinNum - 1
    if self.hasSpinNum == 1 then
        self.game:SetMidTips("tb1")
    elseif self.hasSpinNum == 2 then
        self.game:SetMidTips("tb2")
    elseif self.hasSpinNum == 3 then
        self.game:SetMidTips("tb3")
    end
end

-- @brief 设置图案数据
-- @param quickSet 快速设置，跳过动画
-- 新增 返回落地牌 数量 topupBounsCount
function TopupBounsSlot:SetReelSymbolData(grids, callback, quickSet)
    self.onFinishCallback = callback
    FCasinoCtx:SetSpinStatus(FSpinStatus.WAITING)
    local topupBounsCount = 0
    -- 整理服务器数据
    local reelDatas = {}
    local hasNewTopupBonus = false
    for k, v in pairs(grids) do
        local reelIndex = self:GetReelIndex(k) + 1
        local iconIndex = self:GetCellIndex(k) + 1
        if v.icon == 2 then -- 落地牌
            topupBounsCount = topupBounsCount + 1
            if not self.topupBonusIndexs[k] then
                self.topupBonusIndexs[k] = {SymbolType = v.SymbolType, SymbolValue = v.SymbolValue} 
                if not quickSet then
                    hasNewTopupBonus = true
                end
            end
        end
        reelDatas[reelIndex] = reelDatas[reelIndex] or {}
        reelDatas[reelIndex][iconIndex] = {
            icon = v.icon,
            value = v.SymbolValue,
            --isHide = v.IsHide,
            type = v.SymbolType,
        }
    end
    if hasNewTopupBonus then
        self.hasSpinNum = 3
    end
    self.topupBounsCount = topupBounsCount
    -- 设置最终停止数据 --跳过动画
    if quickSet then
        for k, v in pairs(self.reels) do
            v:Stop(reelDatas[k],
            function ()
                self:OnReelScrollStop(k)
            end
            )
        end
        --FCasinoCtx:SetSpinStatus(FSpinStatus.SPIN)
        if self.onFinishCallback then
            self.onFinishCallback()
            self.onFinishCallback = nil
        end
        return
    end
    -- 设置最终停止数据
    local count = 0
    for k, v in ipairs(self.reels) do
        v:Stop(reelDatas[k], 
            function ()
                FToolSet.PlayFGUISound(MusicCfg.slots_336_reelstop)
                self:OnReelScrollStop(k)
                count = count + 1
                if k >= #self.reels then
                    FCasinoCtx:SetSpinStatus(FSpinStatus.SPIN)
                    if self.onFinishCallback then
                        self.onFinishCallback()
                        self.onFinishCallback = nil
                    end
                end
            end
        , FConfig.Common:GetRellStopInterval(k))
    end
end

function TopupBounsSlot:OnReelScrollStop(index)
    if index ~= nil then
        local arraySymbolDisplays = self.reels[index].arraySymbolDisplays
        for i = 1, 3 do
            local data = arraySymbolDisplays[i].data
            -- 是否需要在落地牌中常驻
            local keepInTopupBouns = SymbolConfig[data.icon].keepInTopupBouns
            arraySymbolDisplays[i].render.visible = not keepInTopupBouns
            local logicIndex = (i - 1) * #self.reels + index
            if keepInTopupBouns and not self.topSymbolRenders[logicIndex] then
                local res = SymbolConfig[data.icon].LDRes[data.type]
                local render = self:GetOrCreateTopSymbol(logicIndex)
                self:_InitTopSymbolRender(render,res,data)
                FToolSet.PlayFGUISound(MusicCfg.SND_HandSDoonk .. index)
            end
            if not keepInTopupBouns then
                local render = arraySymbolDisplays[i].render
                render:GetChild("mask").sortingOrder = 50-i
                render:GetChild("mask").visible = true
            end
        end
    end
end

function TopupBounsSlot:_InitTopSymbolRender(render,res,data)
    local loader = render:GetChild("loader")
    loader.scale = vec2(1,1)
    loader.x,loader.y = 0,0
    loader.visible = true
    render.sortingOrder = SymbolConfig[data.icon].zorder
    loader.url = SymbolConfig[data.icon].animation
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
    local sprite3 = render:GetChild("sprite3")
    sprite3.visible = false
    local wild1 = render:GetChild("wild1")
    local wild2 = render:GetChild("wild2")
    local wild3 = render:GetChild("wild3")
    wild1.visible = false
    wild2.visible = false
    wild3.visible = false

    local DragonExplo = render:GetChild("DragonExplo")
    DragonExplo:SetPlaySettings(0,-1,1,-1,
        function ()
            DragonExplo.visible = false
            DragonExplo.playing = false
            DragonExplo.frame = 0
        end
    ) 
    DragonExplo.playing = true
    DragonExplo.visible = true
    local DragonCircle = render:GetChild("DragonCircle")
    DragonCircle.visible = true
    DragonCircle.playing = true
    -- 落地牌效果 [[
    num.visible = res.numShow
    sprite1.visible = res.spriteFontShow
    sprite2.visible = res.spriteFontShow
    if res.numShow then
        num.text = Utils.TopupBounsScoreToStr(data.value)
        --num.text = FToolSet.NumToStr(data.value)
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