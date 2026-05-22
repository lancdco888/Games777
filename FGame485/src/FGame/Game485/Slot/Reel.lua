
local Utils = Import(".Utils")
local SymbolConfig = Import(".SymbolConfig")
local Reel = Class("Reel", BaseReel)

-- @interface
-- @brief 返回随机图案数据
function Reel:RandomSymbolData()
    local data = {
        icon  = math.random(1, 8),
        value = 0,
        type  = 0,
        ishide = false
    }
    return data
end


-- @interface
-- @brief 图标排序接口
function Reel:OnUpdateSymbolZorder(render, data, index)
    render.sortingOrder = SymbolConfig[data.icon].zorder + index
end

-- @interface
-- @brief 创建渲染组件接口
function Reel:OnCreateSymbolRenderComponent()
    return FairyGUI.UIPackage.CreateObject("Game485", "Symbol")
end

-- @interface
-- @brief 刷新图案
-- @param render : FairyGUI.GComponent
-- @param data : any
-- @param index: number
function Reel:UpdateSymbol(render, data, index)
    local cfg = SymbolConfig[data.icon]
    local icon = render:GetChild("icon")
    --百变 (断线重连除外)
    if data.ishide == 1 and not self.isReconnect then --偷梁换柱 1
        icon.url = SymbolConfig[113].icon
    else
        icon.url = cfg.icon

        if Utils.IsBonus(data.icon) then
            Utils.SetBonusNum(icon,data)
        end
        --落地派模式 小牌
        if self.inTopupBouns and cfg.showMaskInTopupBouns then
            render:GetChild("mask").visible = true
        end
    end
end

-- @interface 
-- @brief 开始旋转回调函数
function Reel:OnScrollBegin()
    for i = 1, self.symbolNum do
        local render = self.arraySymbolDisplays[i].render
        if render then
            render.visible = true
        end
    end
end

-- @interface 
-- @brief 旋转结束回调函数
function Reel:OnScrollEnd()

end

return Reel