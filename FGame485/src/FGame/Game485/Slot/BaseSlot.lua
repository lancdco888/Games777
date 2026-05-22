
local BaseSlot = Class("BaseSlot")
local TopSymbol = Import(".TopSymbol")

function BaseSlot:ctor(parent)
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
    -- 转轴
    self.reels = {}
    -- 顶部显示的图案
    self.topSymbols = {}
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

function BaseSlot:GetOrCreateTopSymbol(index,mode)
    local symbol = self.topSymbols[index]
    if not symbol then
        symbol = TopSymbol.New(self.topContainer, index, mode)
        self.topSymbols[index] = symbol
    end
    symbol:Reset()
    return symbol
end

-- @brief 移除顶层图案
-- @param index 为nil则移除所有
function BaseSlot:RemoveTopSymbol()
    if next(self.topSymbols) then
        for k, v in pairs(self.topSymbols) do
            v:ClearLine()
            v:Delete()
        end
        self.topSymbols = {}
    end
end

-- @brief 移除顶层图案
-- @param index 为nil则移除所有
function BaseSlot:KillTopSymbol()
    if next(self.topSymbols) then
        for k, v in pairs(self.topSymbols) do
            v:ClearLine()
        end
    end
end

return BaseSlot