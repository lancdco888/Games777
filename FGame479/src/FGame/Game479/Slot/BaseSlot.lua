local BaseSlot = Class("BaseSlot")

function BaseSlot:ctor(parent,game)    
    -- 底层转轴容器（带裁剪功能）
    self.bottomContainer = FairyGUI.GComponent()
    self.bottomContainer.width = parent.width
    self.bottomContainer.height = parent.height
    self.bottomContainer:SetupOverflowHidden(true)
    parent:AddChild(self.bottomContainer)
    
    -- 顶层转轴容器
    self.topContainer = FairyGUI.GComponent()
    self.topContainer.width = parent.width
    self.topContainer.height = parent.height
    parent:AddChild(self.topContainer)
    
    self.parent = parent
    self.game = game
    -- 转轴
    self.reels = {}

    -- 顶部显示的图案
    self.topSymbolRenders = {}
end

function BaseSlot:__delete()
    for k, v in pairs(self.reels) do
        v:Delete()
    end
    self:RemoveTopSymbol()
    self.bottomContainer:RemoveFromParent(true)
    self.topContainer:RemoveFromParent(true)
end

function BaseSlot:QuickStop()
    for k, v in pairs(self.reels) do
        v:QuickStop()
    end
end

function BaseSlot:Update(dt)
    for k, v in pairs(self.reels) do
        v:Update(dt)
    end
end

function BaseSlot:SetVisible(value)
    -- self.parent.visible = value
    self.bottomContainer.visible = value
    self.topContainer.visible = value
end

function BaseSlot:GetOrCreateTopSymbol(index,reelCfgdata)
    local render = self.topSymbolRenders[index]
    if not render then
        --本地传入改变后的图形大小
        local reelCfg = reelCfgdata and reelCfgdata or FCasinoCtx.gameCfg.Reel

        -- 位于x轴的下标 [0,4]
        local logicX = self:GetReelIndex(index)
        -- 位于Y轴的下标 [0,2]
        local logicY = self:GetCellIndex(index)

        render = FairyGUI.UIPackage.CreateObject("Game479", "Symbol")
        render:SetPivot(0.5, 0.5, true)
        render.x = (logicX ) * (reelCfg.reelWidth + reelCfg.reelSpace) + 0.5 * reelCfg.reelWidth
        render.y = (logicY + 0.5) * (reelCfg.reelHeight / reelCfg.yCellNumber) 
        self.topContainer:AddChild(render)
        self.topSymbolRenders[index] = render
    end

    render.sortingOrder = 100-index
    render.visible = true

    return render
end


-- @brief 删除顶层图案
function BaseSlot:RemoveTopSymbol()
    for k, v in pairs(self.topSymbolRenders) do
        v:RemoveFromParent(true)
    end
    self.topSymbolRenders = {}
end

-- @brief 获取转轴下标
-- @return [0,4]
function BaseSlot:GetReelIndex(index)
    local reelCfg = FCasinoCtx.gameCfg.Reel
    return (index - 1) % reelCfg.xCellNumber
end

-- @brief 获取Y轴格子下标
-- @return [0,2]
function BaseSlot:GetCellIndex(index)
    local reelCfg = FCasinoCtx.gameCfg.Reel
    return math.floor((index - 1) / reelCfg.xCellNumber)
end
function BaseSlot:GetNode()
    return self.bottomContainer
end
return BaseSlot