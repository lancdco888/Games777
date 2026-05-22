local ReelConf = Import("..Cfgs.Reel")
local Defined = Import("..Cfgs.Defined")

local that = Class("LineKuang")

function that:ctor(parent, lineConfig)
    -- 顶层转轴容器
    self.lineContainer = FairyGUI.GComponent()
    self.lineContainer.width = parent.width
    self.lineContainer.height = parent.height
    parent:AddChild(self.lineContainer)
    self.lineKuangRenders = {}
    self:__initNodes()
end

function that:__initNodes()
    for i = 1, ReelConf.xCellNumber do
        local n = FairyGUI.UIPackage.CreateObject(Defined.GameName, "kuang")
        n.x = (i - 1) * (ReelConf.reelWidth + ReelConf.reelSpace) + 3
        n.y = 0 * (ReelConf.reelHeight / ReelConf.yCellNumber) + 2
        self.lineContainer:AddChild(n)
        self.lineKuangRenders[i] = n
    end
    self:hideAll()
end

function that:Next(cells)
    self:hideAll()
    for _, v in pairs(cells) do
        local x = self:GetReelIndex(v.index)
        local y = self:GetCellIndex(v.index)
        local n = self.lineKuangRenders[x]
        n.y = y * (ReelConf.reelHeight / ReelConf.yCellNumber) + 2
        n.visible = true
    end
end

function that:GetReelIndex(index)
    local reelCfg = FCasinoCtx.gameCfg.Reel
    return (index - 1) % reelCfg.xCellNumber + 1
end

-- @brief 获取Y轴格子下标
-- @return [0,2]
function that:GetCellIndex(index)
    local reelCfg = FCasinoCtx.gameCfg.Reel
    return math.floor((index - 1) / reelCfg.xCellNumber)
end

function that:hideAll()
    for _, v in pairs(self.lineKuangRenders) do
        v.visible = false
    end
end

function that:__delete()
    self.lineKuangRenders = {}
end

return that
