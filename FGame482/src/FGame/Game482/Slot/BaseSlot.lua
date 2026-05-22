local Utils = Import(".Utils")
local BaseSlot = Class("BaseSlot")

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

    self.freeCount = 0
end

function BaseSlot:__delete()
    for k, v in pairs(self.reels) do
        v:Delete()
    end
    self:StopDelayCall()
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

-- @brief 移除顶层图案
-- @param index 为nil则移除所有
function BaseSlot:RemoveTopSymbol(index)
    if index == nil then
        for k,v in  pairs(self.topSymbols) do
            self.topSymbols[k]:Delete()
            self.topSymbols[k] = nil
        end
        self.topSymbols = {}
        
        local container = FCasinoCtx:GetGame().effectContainerObj
        if not container then
            return
        end
        -- Remove and destroy all container children
        for i = container.numChildren, 1, -1 do
            local child = container:GetChildAt(i - 1)
            -- if 
            if child.parent then
                child:RemoveFromParent(true)
            end
            -- if child then child:Delete() end
        end

    else
        if self.topSymbols[index] then
            self.topSymbols[index]:Delete()
            self.topSymbols[index] = nil
        end
    end
end

-- @brief 设置当前免费次数
-- function BaseSlot:SetFreeCount(value)
--     value = value or 0
--     value = math.max(value, 0)
--     self.freeCount = value
--     FCasinoCtx:GetGame().uiItems.free_spins.text = tostring(value)
-- end

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

return BaseSlot
