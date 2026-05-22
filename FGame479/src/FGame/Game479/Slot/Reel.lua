
local SymbolConfig = Import(".SymbolConfig")
local Utils = Import(".Utils")
local Reel = Class("Reel", BaseReel)
local BaseSlot = Import(".BaseSlot")
Reel.isspecial = false
Reel.isInfree = false
Reel.freeicotype = 0 -- 1普通模式， 2 红色模式 3 黄色模式
Reel.bgrender = {}
Reel.iswildtype = 0
Reel.loopicon = {}
-- @interface
-- @brief 返回随机图案数据
function Reel:RandomSymbolData()
    local data = {
        icon  = math.random(1, 10),
        type = 0
    }
    --第一列或者第五列出现ssc替换图标
    if data.icon == 10 and (self.idx == 1 or self.idx == 5)  then
        data.icon = math.random(1,9)
    end
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
   return FairyGUI.UIPackage.CreateObject("Game479", "Symbol")
end


-- @interface
-- @brief 刷新图案
-- @param render : FairyGUI.GComponent
-- @param data : any
-- @param index: number
function Reel:UpdateSymbol(render, data, index)
    local cfg = SymbolConfig[data.icon]
    render.visible = true
    -- 加载图标
    
    local loader = render:GetChild("loader")
    loader.visible = true
    loader.url = cfg.icon
    if cfg.loaderScale then
        loader.scale = cfg.loaderScale
    else
        loader.scale = vec2(1,1)
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
    self.isOpen = false
end

function Reel:SetMask(isShow)
    self.showMask = isShow
end

function Reel:SetOpen(isOpen)
    self.isOpen = isOpen
end
return Reel