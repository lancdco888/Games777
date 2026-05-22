local Utils = Import(".Utils")
local TopSymbol = Import(".TopSymbol")
local BaseSlot = Class("BaseSlot")

function BaseSlot:ctor(parent)
    -- 底层转轴容器
    self.bottomContainer = FairyGUI.GComponent()
    self.bottomContainer.width = parent.width
    self.bottomContainer.height = parent.height
    self.bottomContainer:SetupOverflowHidden(false)
    self.bottomContainer.name = "bottomContainer"
    parent:AddChild(self.bottomContainer)

    -- 顶层转轴容器 -- 翻牌层
    self.topContainer = FairyGUI.GComponent()
    self.topContainer.width = parent.width
    self.topContainer.height = parent.height
    self.topContainer.name = "topContainer"
    parent:AddChild(self.topContainer)

    -- move动画转轴容器
    self.moveContainer = FairyGUI.GComponent()
    self.moveContainer.width = parent.width
    self.moveContainer.height = parent.height
    self.moveContainer.name = "moveContainer"
    parent:AddChild(self.moveContainer)

    self.mask = parent:GetChild("mask")
    self.maskFreeAppear = parent:GetChild("maskFreeAppear") -- free 出现加速旋转遮罩
    self.scLightEffect = parent:GetChild("scLightEffect") -- free 出现加速旋转光效
    
    self.bottomContainer.sortingOrder = 1
    self.maskFreeAppear.sortingOrder = 2
    self.moveContainer.sortingOrder = 3
    self.scLightEffect.sortingOrder = 4
    self.mask.sortingOrder = 5
    self.topContainer.sortingOrder = 6
    self.parent = parent
    -- 转轴
    self.reels = {}

    -- 顶部显示的图案
    self.topSymbolRenders = {}

    -- 移动显示的图案
    self.moveSymbolRenders = {}
    self.moveSymbolDatas = {}
end

function BaseSlot:__delete()
    for k, v in pairs(self.reels) do
        v:Delete()
    end
    self:StopDelayCall()
    self:RemoveTopSymbol()
    self:RemoveMoveSymbol()
    self.bottomContainer:RemoveFromParent(true)
    self.topContainer:RemoveFromParent(true)
    self.moveContainer:RemoveFromParent(true)
    self.details = nil
end

function BaseSlot:QuickStop()
    for k, v in pairs(self.reels) do
        v:QuickStop()
    end
    FCasinoCtx.commonPanel:StopScrollWinMoney(nil, true)
end

function BaseSlot:Update(dt)
    for k, v in pairs(self.reels) do
        v:Update(dt)
    end
end

function BaseSlot:SetVisible(value)
    self.parent.visible = value
end

function BaseSlot:GetOrCreateTopSymbol(index)
    local render = self.topSymbolRenders[index]
    if not render then
        local reelCfg = FCasinoCtx.gameCfg.Reel

        -- 位于x轴的下标 [0,4]
        local logicX = Utils.GetReelIndex(index)
        -- 位于Y轴的下标 [0,2]
        local logicY = Utils.GetCellIndex(index)

        render = FairyGUI.UIPackage.CreateObject("Game483", "Symbol")
        render:SetPivot(0.5, 0.5, true)
        render.x = (logicX ) * (reelCfg.reelWidth + reelCfg.reelSpace) + 0.5 * reelCfg.reelWidth
        render.y = (logicY + 0.5) * (reelCfg.reelHeight / reelCfg.yCellNumber) 
        self.topContainer:AddChild(render)
        self.topSymbolRenders[index] = render
    end

    render.sortingOrder = index
    render.visible = true

    return render
end

-- @brief 删除顶层图案
function BaseSlot:RemoveTopSymbol()
    for k, render in pairs(self.topSymbolRenders) do
        FTween.KillTweens(render)
        render:RemoveFromParent(true)
    end
    self.topSymbolRenders = {}
end

function BaseSlot:GetOrCreateMoveSymbol(index, data)
    local render = self.moveSymbolRenders[index]
    if not render then
        local reelCfg = FCasinoCtx.gameCfg.Reel

        -- 位于x轴的下标 [0,4]
        local logicX = Utils.GetReelIndex(index)
        -- 位于Y轴的下标 [0,2]
        local logicY = Utils.GetCellIndex(index)

        render = FairyGUI.UIPackage.CreateObject("Game483", "Symbol")
        render:SetPivot(0.5, 0.5, true)
        render.x = (logicX ) * (reelCfg.reelWidth + reelCfg.reelSpace) + 0.5 * reelCfg.reelWidth
        render.y = (logicY + 0.5) * (reelCfg.reelHeight / reelCfg.yCellNumber) 
        self.moveContainer:AddChild(render)
        render.name = index
        self.moveSymbolRenders[index] = render
        self.moveSymbolDatas[index] = data
    end

    render.sortingOrder = index + 100
    render.visible = true
    
    return render
end

-- @brief 删除顶层图案
function BaseSlot:RemoveMoveSymbol(index)
    if index then
        if self.moveSymbolRenders[index] then
            local render = self.moveSymbolRenders[index]
            FTween.KillTweens(render)
            render:RemoveFromParent(true)
            self.moveSymbolRenders[index] = nil
            self.moveSymbolDatas[index] = nil
        end
        return
    end
    for k, render in pairs(self.moveSymbolRenders) do
        FTween.KillTweens(render)
        render:RemoveFromParent(true)
    end
    self.moveSymbolRenders = {}
    self.moveSymbolDatas = {}
end


function BaseSlot:ShowMoveSymbol()
    for k, render in pairs(self.moveSymbolRenders) do
        render.visible = true
    end
    self.moveContainer.visible = true
    self.bottomContainer.visible = false
end

function BaseSlot:HideMoveSymbol()
    for k, render in pairs(self.moveSymbolRenders) do
        render.visible = false
    end
    self.bottomContainer.visible = true
end

-- @brief 延迟执行
function BaseSlot:DelayCall(cb, time)
    self:StopDelayCall()
    self.delayCallTimer =
        StartOnceTimer(
        function()
            self.delayCallTimer = nil
            cb()
        end,
        time
    )
end

function BaseSlot:StopDelayCall()
    if self.delayCallTimer then
        StopTimer(self.delayCallTimer)
        self.delayCallTimer = nil
    end
end

function BaseSlot:GetOrCreateDetails(index)
    if not self.details then
        self.details = FairyGUI.UIPackage.CreateObject("Game483", "details")
        self.details:SetPivot(0.25, 0.5, true)
        self.details.sortingOrder = 1000
        self.topContainer:AddChild(self.details)
        local btn = self.details:GetChild("btn")
        APIGateway.AddEventListener(btn,FGUIEventKey.onClick, function()
            self.details.visible = false
        end,true)
    end
    local detailsWidth = self.details.width
    local reelCfg = FCasinoCtx.gameCfg.Reel
    local logicX = Utils.GetReelIndex(index)
    local logicY = Utils.GetCellIndex(index)
    if logicX == reelCfg.xCellNumber - 1 then
        detailsWidth = 0 - detailsWidth
    end
    self.details:SetPivot(0.25, 0.5, true)
    self.details.x = (logicX ) * (reelCfg.reelWidth + reelCfg.reelSpace) + 0.5 * reelCfg.reelWidth
    self.details.y = (logicY + 0.5) * (reelCfg.reelHeight / reelCfg.yCellNumber) 
    self.details.visible = true
    return self.details
end

return BaseSlot
